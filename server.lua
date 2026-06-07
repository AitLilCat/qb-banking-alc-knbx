local QBCore = exports['qb-core']:GetCoreObject()
local Accounts = {}
local Statements = {}
local Cooldowns = {}

local function getPlayerAndCitizenId(playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if not Player or not Player.PlayerData then return nil, nil end
    return Player, Player.PlayerData.citizenid
end

local function result(success, message, extra)
    local response = { success = success, message = message }
    if extra then
        for key, value in pairs(extra) do
            response[key] = value
        end
    end
    return response
end

local function trim(value)
    if type(value) ~= 'string' then return nil end
    return value:gsub('^%s+', ''):gsub('%s+$', '')
end

local function debugLog(message)
    if Config.Debug then
        print(('[qb-banking-alc-knbx] %s'):format(tostring(message)))
    end
end

local function currentMillis()
    if type(GetGameTimer) == 'function' then
        return GetGameTimer()
    end
    return math.floor(os.clock() * 1000)
end

local function checkCooldown(src, action)
    local cooldown = tonumber(Config.TransactionCooldown) or 1000
    if cooldown <= 0 then return true end

    local key = tostring(src) .. ':' .. tostring(action)
    local now = currentMillis()
    if Cooldowns[key] and Cooldowns[key] > now then
        return false
    end

    Cooldowns[key] = now + cooldown
    return true
end

local function sanitizeAccountName(value)
    local accountName = trim(value)
    if not accountName or accountName == '' then return nil end
    if #accountName > (Config.MaxAccountNameLength or 50) then return nil end
    if not accountName:match('^[%w%s%-%_%.]+$') then return nil end
    return accountName
end

local function sanitizeCitizenId(value)
    local citizenid = trim(tostring(value or ''))
    if not citizenid or citizenid == '' then return nil end
    if #citizenid > 50 then return nil end
    if not citizenid:match('^[%w%-_]+$') then return nil end
    return citizenid
end

local function sanitizeReason(value, fallback)
    local reason = trim(type(value) == 'string' and value or '')
    if not reason or reason == '' then reason = fallback end
    reason = tostring(reason or fallback or 'Bank transaction')
    if #reason > 50 then
        reason = reason:sub(1, 50)
    end
    return reason
end

local function validateMoneyAmount(value, allowZero)
    local amount = tonumber(value)
    if not amount or amount ~= amount or amount == math.huge or amount == -math.huge then
        return nil, Lang:t('error.amount')
    end

    if allowZero then
        if amount < 0 then return nil, Lang:t('error.amount') end
    elseif amount <= 0 then
        return nil, Lang:t('error.amount')
    end

    if amount % 1 ~= 0 then return nil, Lang:t('error.amount') end

    local maxAmount = tonumber(Config.MaxTransactionAmount) or 100000000
    if amount > maxAmount then return nil, Lang:t('error.amount') end

    return math.floor(amount), nil
end

local function decodeUsers(users)
    if type(users) == 'table' then return users end
    if type(users) ~= 'string' or users == '' then return {} end

    local ok, decoded = pcall(json.decode, users)
    if ok and type(decoded) == 'table' then return decoded end

    return {}
end

local function encodeUsers(users)
    return json.encode(type(users) == 'table' and users or {})
end

local function accountHasUser(account, citizenid)
    if not account or not citizenid then return false end
    for _, allowedCitizenId in ipairs(decodeUsers(account.users)) do
        if tostring(allowedCitizenId) == tostring(citizenid) then
            return true
        end
    end
    return false
end

local function isJobBoss(Player, accountName)
    local job = Player and Player.PlayerData and Player.PlayerData.job or {}
    return job.name == accountName and job.isboss == true
end

local function isGangBoss(Player, accountName)
    local gang = Player and Player.PlayerData and Player.PlayerData.gang or {}
    return gang.name == accountName and gang.isboss == true
end

local function canAccessAccount(Player, accountName)
    if accountName == 'checking' then return true end

    local safeAccountName = sanitizeAccountName(accountName)
    if not safeAccountName then return false, nil end

    local account = Accounts[safeAccountName]
    if not account then return false, nil end

    local citizenid = Player and Player.PlayerData and Player.PlayerData.citizenid
    if account.account_type == 'shared' then
        return account.citizenid == citizenid or accountHasUser(account, citizenid), account
    end

    if account.account_type == 'job' then
        return isJobBoss(Player, safeAccountName), account
    end

    if account.account_type == 'gang' then
        return isGangBoss(Player, safeAccountName), account
    end

    return false, account
end

local function canManageSharedAccount(Player, accountName)
    local safeAccountName = sanitizeAccountName(accountName)
    if not safeAccountName then return false, nil end

    local account = Accounts[safeAccountName]
    if not account then return false, nil end

    local citizenid = Player and Player.PlayerData and Player.PlayerData.citizenid
    return account.account_type == 'shared' and account.citizenid == citizenid, account
end

local function addAccountToList(accounts, statements, seenAccounts, accountName, accountInfo, citizenid)
    if seenAccounts[accountName] then return end
    seenAccounts[accountName] = true
    accounts[#accounts + 1] = accountInfo

    if accountName == 'checking' then
        statements.checking = Statements[citizenid] and Statements[citizenid].checking or {}
        return
    end

    if Statements[accountName] then
        statements[accountName] = Statements[accountName]
    end
end

local function getNumberOfAccounts(citizenid)
    local numberOfAccounts = 0
    for _, account in pairs(Accounts) do
        if account.citizenid == citizenid and account.account_type == 'shared' then
            numberOfAccounts = numberOfAccounts + 1
        end
    end
    return numberOfAccounts
end

local function createStoredAccount(accountName, accountBalance, accountType, citizenid, accountUsers)
    Accounts[accountName] = {
        citizenid = citizenid,
        account_name = accountName,
        account_balance = accountBalance,
        account_type = accountType,
        users = accountUsers or '[]'
    }
end

local function CreatePlayerAccount(playerId, accountName, accountBalance, accountUsers)
    local Player, citizenid = getPlayerAndCitizenId(playerId)
    if not Player or not citizenid then return false end

    local safeAccountName = sanitizeAccountName(accountName)
    local safeBalance = validateMoneyAmount(accountBalance or 0, true)
    if not safeAccountName or not safeBalance then return false end
    if safeAccountName == 'checking' or Accounts[safeAccountName] then return false end

    local users = encodeUsers(decodeUsers(accountUsers))
    createStoredAccount(safeAccountName, safeBalance, 'shared', citizenid, users)

    local insertSuccess = MySQL.insert.await('INSERT INTO bank_accounts (citizenid, account_name, account_balance, account_type, users) VALUES (?, ?, ?, ?, ?)', { citizenid, safeAccountName, safeBalance, 'shared', users })
    if not insertSuccess then
        Accounts[safeAccountName] = nil
        return false
    end

    return insertSuccess
end
exports('CreatePlayerAccount', CreatePlayerAccount)

local function CreateJobAccount(accountName, accountBalance)
    local safeAccountName = sanitizeAccountName(accountName)
    local safeBalance = validateMoneyAmount(accountBalance or 0, true)
    if not safeAccountName or not safeBalance then return false end
    if Accounts[safeAccountName] then return true end

    createStoredAccount(safeAccountName, safeBalance, 'job', nil, nil)
    local insertSuccess = MySQL.insert.await('INSERT INTO bank_accounts (account_name, account_balance, account_type) VALUES (?, ?, ?)', { safeAccountName, safeBalance, 'job' })
    if not insertSuccess then
        Accounts[safeAccountName] = nil
        return false
    end

    return insertSuccess
end
exports('CreateJobAccount', CreateJobAccount)

local function CreateGangAccount(accountName, accountBalance)
    local safeAccountName = sanitizeAccountName(accountName)
    local safeBalance = validateMoneyAmount(accountBalance or 0, true)
    if not safeAccountName or not safeBalance then return false end
    if Accounts[safeAccountName] then return true end

    createStoredAccount(safeAccountName, safeBalance, 'gang', nil, nil)
    local insertSuccess = MySQL.insert.await('INSERT INTO bank_accounts (account_name, account_balance, account_type) VALUES (?, ?, ?)', { safeAccountName, safeBalance, 'gang' })
    if not insertSuccess then
        Accounts[safeAccountName] = nil
        return false
    end

    return insertSuccess
end
exports('CreateGangAccount', CreateGangAccount)

local function CreateBankStatement(playerId, account, amount, reason, statementType, accountType)
    local Player, citizenid = getPlayerAndCitizenId(playerId)
    if not Player or not citizenid then return false end

    local safeAmount = validateMoneyAmount(amount)
    if not safeAmount then return false end

    local safeAccount = accountType == 'player' and 'checking' or sanitizeAccountName(account)
    if not safeAccount then return false end

    local safeReason = sanitizeReason(reason, 'Bank transaction')
    local safeType = statementType == 'deposit' and 'deposit' or 'withdraw'

    local newStatement = {
        citizenid = citizenid,
        amount = safeAmount,
        reason = safeReason,
        date = os.time() * 1000,
        statement_type = safeType
    }

    if accountType == 'player' then
        safeAccount = 'checking'
        if not Statements[citizenid] then Statements[citizenid] = {} end
        if not Statements[citizenid][safeAccount] then Statements[citizenid][safeAccount] = {} end
        Statements[citizenid][safeAccount][#Statements[citizenid][safeAccount] + 1] = newStatement
    else
        if not Statements[safeAccount] then Statements[safeAccount] = {} end
        Statements[safeAccount][#Statements[safeAccount] + 1] = newStatement
    end

    local insertSuccess = MySQL.insert.await('INSERT INTO bank_statements (citizenid, account_name, amount, reason, statement_type) VALUES (?, ?, ?, ?, ?)', { citizenid, safeAccount, safeAmount, safeReason, safeType })
    return insertSuccess ~= false and insertSuccess ~= nil
end
exports('CreateBankStatement', CreateBankStatement)

local function AddMoney(accountName, amount, reason)
    local safeAccountName = sanitizeAccountName(accountName)
    local safeAmount = validateMoneyAmount(amount)
    if not safeAccountName or not safeAmount or not Accounts[safeAccountName] then return false end

    local safeReason = sanitizeReason(reason, 'External Deposit')
    local accountToUpdate = Accounts[safeAccountName]
    accountToUpdate.account_balance = (tonumber(accountToUpdate.account_balance) or 0) + safeAmount

    if not Statements[safeAccountName] then Statements[safeAccountName] = {} end
    Statements[safeAccountName][#Statements[safeAccountName] + 1] = {
        amount = safeAmount,
        reason = safeReason,
        date = os.time() * 1000,
        statement_type = 'deposit'
    }

    MySQL.insert.await('INSERT INTO bank_statements (account_name, amount, reason, statement_type) VALUES (?, ?, ?, ?)', { safeAccountName, safeAmount, safeReason, 'deposit' })
    local updateSuccess = MySQL.update.await('UPDATE bank_accounts SET account_balance = account_balance + ? WHERE account_name = ?', { safeAmount, safeAccountName })
    return updateSuccess ~= false and updateSuccess ~= nil
end
exports('AddMoney', AddMoney)
exports('AddGangMoney', AddMoney)

local function RemoveMoney(accountName, amount, reason)
    local safeAccountName = sanitizeAccountName(accountName)
    local safeAmount = validateMoneyAmount(amount)
    if not safeAccountName or not safeAmount or not Accounts[safeAccountName] then return false end

    local accountToUpdate = Accounts[safeAccountName]
    local currentBalance = tonumber(accountToUpdate.account_balance) or 0
    if currentBalance < safeAmount then return false end

    local safeReason = sanitizeReason(reason, 'External Withdrawal')
    accountToUpdate.account_balance = currentBalance - safeAmount

    if not Statements[safeAccountName] then Statements[safeAccountName] = {} end
    Statements[safeAccountName][#Statements[safeAccountName] + 1] = {
        amount = safeAmount,
        reason = safeReason,
        date = os.time() * 1000,
        statement_type = 'withdraw'
    }

    MySQL.insert.await('INSERT INTO bank_statements (account_name, amount, reason, statement_type) VALUES (?, ?, ?, ?)', { safeAccountName, safeAmount, safeReason, 'withdraw' })
    local updateSuccess = MySQL.update.await('UPDATE bank_accounts SET account_balance = account_balance - ? WHERE account_name = ?', { safeAmount, safeAccountName })
    return updateSuccess ~= false and updateSuccess ~= nil
end
exports('RemoveMoney', RemoveMoney)
exports('RemoveGangMoney', RemoveMoney)

local function GetAccount(accountName)
    local safeAccountName = sanitizeAccountName(accountName)
    if not safeAccountName then return nil end
    return Accounts[safeAccountName]
end
exports('GetAccount', GetAccount)
exports('GetGangAccount', GetAccount)

local function GetAccountBalance(accountName)
    local account = GetAccount(accountName)
    return account and tonumber(account.account_balance) or 0
end
exports('GetAccountBalance', GetAccountBalance)

QBCore.Functions.CreateCallback('qb-banking:server:openBank', function(source, cb)
    local src = source
    local Player, citizenid = getPlayerAndCitizenId(src)
    if not Player or not citizenid then return cb({}, {}, {}, {}) end

    local job = Player.PlayerData.job or {}
    local gang = Player.PlayerData.gang or {}
    local jobAccountName = sanitizeAccountName(job.name or '')
    local gangAccountName = sanitizeAccountName(gang.name or '')
    if jobAccountName and jobAccountName ~= 'unemployed' and not Accounts[jobAccountName] then CreateJobAccount(jobAccountName, 0) end
    if gangAccountName and gangAccountName ~= 'none' and not Accounts[gangAccountName] then CreateGangAccount(gangAccountName, 0) end

    local accounts = {}
    local statements = {}
    local seenAccounts = {}

    addAccountToList(accounts, statements, seenAccounts, 'checking', { account_name = 'checking', account_type = 'checking', account_balance = Player.PlayerData.money.bank }, citizenid)

    for accountName, accountInfo in pairs(Accounts) do
        local hasAccess = canAccessAccount(Player, accountName)
        if hasAccess then
            addAccountToList(accounts, statements, seenAccounts, accountName, accountInfo, citizenid)
        end
    end

    local invoices = MySQL.query.await('SELECT id, amount, society, sender, sendercitizenid FROM phone_invoices WHERE citizenid = ?', { citizenid }) or {}
    cb(accounts, statements, Player.PlayerData, invoices)
end)

QBCore.Functions.CreateCallback('qb-banking:server:openATM', function(source, cb)
    local src = source
    local Player, citizenid = getPlayerAndCitizenId(src)
    if not Player or not citizenid then return cb({}, {}, {}) end

    local bankCards = Player.Functions.GetItemsByName('bank_card') or {}
    if #bankCards == 0 then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.card'), 'error')
        return cb({}, Player.PlayerData, {})
    end

    local acceptablePins = {}
    for _, bankCard in ipairs(bankCards) do
        if bankCard.info and bankCard.info.cardPin then
            acceptablePins[#acceptablePins + 1] = bankCard.info.cardPin
        end
    end

    local accounts = {}
    local seenAccounts = {}
    local blankStatements = {}
    addAccountToList(accounts, blankStatements, seenAccounts, 'checking', { account_name = 'checking', account_type = 'checking', account_balance = Player.PlayerData.money.bank }, citizenid)

    for accountName, accountInfo in pairs(Accounts) do
        local hasAccess = canAccessAccount(Player, accountName)
        if hasAccess then
            addAccountToList(accounts, blankStatements, seenAccounts, accountName, accountInfo, citizenid)
        end
    end

    cb(accounts, Player.PlayerData, acceptablePins)
end)

QBCore.Functions.CreateCallback('qb-banking:server:saveLanguage', function(source, cb, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return cb(result(false, 'Player not found')) end

    data = type(data) == 'table' and data or {}
    local lang = tostring(data.language or 'nl')
    if lang ~= 'nl' and lang ~= 'en' then lang = 'nl' end

    Player.Functions.SetMetaData('bankLanguage', lang)
    cb(result(true, 'Language saved', { language = lang }))
end)

QBCore.Functions.CreateCallback('qb-banking:server:saveSettings', function(source, cb, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return cb(result(false, 'Player not found')) end

    data = type(data) == 'table' and data or {}
    local lang = tostring(data.language or 'nl')
    local theme = tostring(data.theme or 'light')
    if lang ~= 'nl' and lang ~= 'en' then lang = 'nl' end
    if theme ~= 'light' and theme ~= 'dark' then theme = 'light' end

    Player.Functions.SetMetaData('bankLanguage', lang)
    Player.Functions.SetMetaData('bankTheme', theme)
    cb(result(true, 'Settings saved', { language = lang, theme = theme }))
end)

QBCore.Functions.CreateCallback('qb-banking:server:withdraw', function(source, cb, data)
    local src = source
    if not checkCooldown(src, 'withdraw') then return cb(result(false, Lang:t('error.error'))) end

    local Player, citizenid = getPlayerAndCitizenId(src)
    if not Player or not citizenid then return cb(result(false, Lang:t('error.error'))) end

    data = type(data) == 'table' and data or {}
    local accountName = sanitizeAccountName(data.accountName)
    local withdrawAmount, amountError = validateMoneyAmount(data.amount)
    local reason = sanitizeReason(data.reason, 'Bank Withdrawal')
    if not accountName then return cb(result(false, Lang:t('error.account'))) end
    if not withdrawAmount then return cb(result(false, amountError)) end

    if accountName == 'checking' then
        if Player.PlayerData.money.bank < withdrawAmount then return cb(result(false, Lang:t('error.money'))) end
        if not Player.Functions.RemoveMoney('bank', withdrawAmount, 'bank withdrawal') then return cb(result(false, Lang:t('error.money'))) end
        Player.Functions.AddMoney('cash', withdrawAmount, 'bank withdrawal')
        if not CreateBankStatement(src, 'checking', withdrawAmount, reason, 'withdraw', 'player') then return cb(result(false, Lang:t('error.error'))) end
        return cb(result(true, Lang:t('success.withdraw')))
    end

    local hasAccess, account = canAccessAccount(Player, accountName)
    if not account then return cb(result(false, Lang:t('error.account'))) end
    if not hasAccess then return cb(result(false, Lang:t('error.access'))) end

    if GetAccountBalance(accountName) < withdrawAmount then return cb(result(false, Lang:t('error.money'))) end
    if not RemoveMoney(accountName, withdrawAmount, reason) then return cb(result(false, Lang:t('error.error'))) end
    Player.Functions.AddMoney('cash', withdrawAmount, 'bank account: ' .. accountName .. ' withdrawal')
    cb(result(true, Lang:t('success.withdraw')))
end)

QBCore.Functions.CreateCallback('qb-banking:server:deposit', function(source, cb, data)
    local src = source
    if not checkCooldown(src, 'deposit') then return cb(result(false, Lang:t('error.error'))) end

    local Player, citizenid = getPlayerAndCitizenId(src)
    if not Player or not citizenid then return cb(result(false, Lang:t('error.error'))) end

    data = type(data) == 'table' and data or {}
    local accountName = sanitizeAccountName(data.accountName)
    local depositAmount, amountError = validateMoneyAmount(data.amount)
    local reason = sanitizeReason(data.reason, 'Bank Deposit')
    if not accountName then return cb(result(false, Lang:t('error.account'))) end
    if not depositAmount then return cb(result(false, amountError)) end

    if Player.PlayerData.money.cash < depositAmount then return cb(result(false, Lang:t('error.money'))) end

    if accountName == 'checking' then
        if not Player.Functions.RemoveMoney('cash', depositAmount, 'bank deposit') then return cb(result(false, Lang:t('error.money'))) end
        Player.Functions.AddMoney('bank', depositAmount, 'bank deposit')
        if not CreateBankStatement(src, 'checking', depositAmount, reason, 'deposit', 'player') then return cb(result(false, Lang:t('error.error'))) end
        return cb(result(true, Lang:t('success.deposit')))
    end

    local hasAccess, account = canAccessAccount(Player, accountName)
    if not account then return cb(result(false, Lang:t('error.account'))) end
    if not hasAccess then return cb(result(false, Lang:t('error.access'))) end

    if not Player.Functions.RemoveMoney('cash', depositAmount, 'bank account: ' .. accountName .. ' deposit') then return cb(result(false, Lang:t('error.money'))) end
    if not AddMoney(accountName, depositAmount, reason) then return cb(result(false, Lang:t('error.error'))) end
    cb(result(true, Lang:t('success.deposit')))
end)

QBCore.Functions.CreateCallback('qb-banking:server:internalTransfer', function(source, cb, data)
    local src = source
    if not checkCooldown(src, 'internalTransfer') then return cb(result(false, Lang:t('error.error'))) end

    local Player, citizenid = getPlayerAndCitizenId(src)
    if not Player or not citizenid then return cb(result(false, Lang:t('error.error'))) end

    data = type(data) == 'table' and data or {}
    local fromAccountName = sanitizeAccountName(data.fromAccountName)
    local toAccountName = sanitizeAccountName(data.toAccountName)
    local transferAmount, amountError = validateMoneyAmount(data.amount)
    local reason = sanitizeReason(data.reason, 'Internal transfer')

    if not fromAccountName or not toAccountName then return cb(result(false, Lang:t('error.account'))) end
    if fromAccountName == toAccountName then return cb(result(false, Lang:t('error.error'))) end
    if not transferAmount then return cb(result(false, amountError)) end

    if fromAccountName ~= 'checking' then
        local fromAccess, fromAccount = canAccessAccount(Player, fromAccountName)
        if not fromAccount then return cb(result(false, Lang:t('error.account'))) end
        if not fromAccess then return cb(result(false, Lang:t('error.access'))) end
        if GetAccountBalance(fromAccountName) < transferAmount then return cb(result(false, Lang:t('error.money'))) end
    elseif Player.PlayerData.money.bank < transferAmount then
        return cb(result(false, Lang:t('error.money')))
    end

    if toAccountName ~= 'checking' then
        local toAccess, toAccount = canAccessAccount(Player, toAccountName)
        if not toAccount then return cb(result(false, Lang:t('error.account'))) end
        if not toAccess then return cb(result(false, Lang:t('error.access'))) end
    end

    if fromAccountName == 'checking' then
        if not Player.Functions.RemoveMoney('bank', transferAmount, reason) then return cb(result(false, Lang:t('error.money'))) end
        if toAccountName == 'checking' then
            Player.Functions.AddMoney('bank', transferAmount, reason)
        else
            if not AddMoney(toAccountName, transferAmount, reason) then return cb(result(false, Lang:t('error.error'))) end
        end
        if not CreateBankStatement(src, 'checking', transferAmount, reason, 'withdraw', 'player') then return cb(result(false, Lang:t('error.error'))) end
    else
        if not RemoveMoney(fromAccountName, transferAmount, reason) then return cb(result(false, Lang:t('error.error'))) end
        if toAccountName == 'checking' then
            Player.Functions.AddMoney('bank', transferAmount, reason)
            if not CreateBankStatement(src, 'checking', transferAmount, reason, 'deposit', 'player') then return cb(result(false, Lang:t('error.error'))) end
        else
            if not AddMoney(toAccountName, transferAmount, reason) then return cb(result(false, Lang:t('error.error'))) end
        end
    end

    cb(result(true, Lang:t('success.transfer')))
end)

QBCore.Functions.CreateCallback('qb-banking:server:externalTransfer', function(source, cb, data)
    local src = source
    if not checkCooldown(src, 'externalTransfer') then return cb(result(false, Lang:t('error.error'))) end

    local Player, citizenid = getPlayerAndCitizenId(src)
    if not Player or not citizenid then return cb(result(false, Lang:t('error.error'))) end

    data = type(data) == 'table' and data or {}
    local toCitizenId = sanitizeCitizenId(data.toAccountNumber)
    local fromAccountName = sanitizeAccountName(data.fromAccountName)
    local transferAmount, amountError = validateMoneyAmount(data.amount)
    local reason = sanitizeReason(data.reason, 'External transfer')

    if not toCitizenId or not fromAccountName then return cb(result(false, Lang:t('error.account'))) end
    if not transferAmount then return cb(result(false, amountError)) end

    local toPlayer = QBCore.Functions.GetPlayerByCitizenId(toCitizenId)
    if not toPlayer then return cb(result(false, Lang:t('error.noUser'))) end

    if fromAccountName == 'checking' then
        if Player.PlayerData.money.bank < transferAmount then return cb(result(false, Lang:t('error.money'))) end
        if not Player.Functions.RemoveMoney('bank', transferAmount, reason) then return cb(result(false, Lang:t('error.money'))) end
        toPlayer.Functions.AddMoney('bank', transferAmount, reason)
        if not CreateBankStatement(src, 'checking', transferAmount, reason, 'withdraw', 'player') then return cb(result(false, Lang:t('error.error'))) end
        if not CreateBankStatement(toPlayer.PlayerData.source, 'checking', transferAmount, reason, 'deposit', 'player') then return cb(result(false, Lang:t('error.error'))) end
        return cb(result(true, Lang:t('success.transfer')))
    end

    local hasAccess, account = canAccessAccount(Player, fromAccountName)
    if not account then return cb(result(false, Lang:t('error.account'))) end
    if not hasAccess then return cb(result(false, Lang:t('error.access'))) end
    if GetAccountBalance(fromAccountName) < transferAmount then return cb(result(false, Lang:t('error.money'))) end

    if not RemoveMoney(fromAccountName, transferAmount, reason) then return cb(result(false, Lang:t('error.error'))) end
    toPlayer.Functions.AddMoney('bank', transferAmount, reason)
    if not CreateBankStatement(toPlayer.PlayerData.source, 'checking', transferAmount, reason, 'deposit', 'player') then return cb(result(false, Lang:t('error.error'))) end
    cb(result(true, Lang:t('success.transfer')))
end)

QBCore.Functions.CreateCallback('qb-banking:server:payInvoice', function(source, cb, data)
    local src = source
    if not checkCooldown(src, 'payInvoice') then return cb(result(false, Lang:t('error.error'))) end

    local Player, citizenid = getPlayerAndCitizenId(src)
    if not Player or not citizenid then return cb(result(false, Lang:t('error.error'))) end

    data = type(data) == 'table' and data or {}
    local invoiceId = tonumber(data.invoiceId)
    if not invoiceId or invoiceId % 1 ~= 0 or invoiceId <= 0 then return cb(result(false, Lang:t('error.error'))) end

    local invoice = MySQL.single.await('SELECT id, amount, society, sender, sendercitizenid FROM phone_invoices WHERE id = ? AND citizenid = ?', { invoiceId, citizenid })
    if not invoice then return cb(result(false, Lang:t('error.error'))) end

    local amount, amountError = validateMoneyAmount(invoice.amount)
    if not amount then return cb(result(false, amountError)) end
    if Player.PlayerData.money.bank < amount then return cb(result(false, Lang:t('error.money'))) end

    if not Player.Functions.RemoveMoney('bank', amount, 'paid invoice') then return cb(result(false, Lang:t('error.money'))) end

    local societyAccount = sanitizeAccountName(invoice.society or '')
    if societyAccount and Accounts[societyAccount] then
        AddMoney(societyAccount, amount, 'Invoice payment')
    end

    CreateBankStatement(src, 'checking', amount, sanitizeReason(invoice.sender or invoice.society or 'Invoice', 'Invoice'), 'withdraw', 'player')
    MySQL.query.await('DELETE FROM phone_invoices WHERE id = ? AND citizenid = ?', { invoiceId, citizenid })

    cb(result(true, Lang:t('success.transfer')))
end)

QBCore.Functions.CreateCallback('qb-banking:server:orderCard', function(source, cb, data)
    local src = source
    if not checkCooldown(src, 'orderCard') then return cb(result(false, Lang:t('error.error'))) end

    local Player, citizenid = getPlayerAndCitizenId(src)
    if not Player or not citizenid then return cb(result(false, Lang:t('error.error'))) end

    data = type(data) == 'table' and data or {}
    local pin = trim(tostring(data.pin or ''))
    if not pin or not pin:match('^%d%d%d%d$') then return cb(result(false, Lang:t('error.pin'))) end

    local cardNumber = math.random(1000000000000000, 9999999999999999)
    local info = {
        citizenid = citizenid,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        cardNumber = cardNumber,
        cardPin = tonumber(pin),
    }

    exports['qb-inventory']:AddItem(src, 'bank_card', 1, false, info, 'qb-banking:server:orderCard')
    cb(result(true, Lang:t('success.card')))
end)

QBCore.Functions.CreateCallback('qb-banking:server:openAccount', function(source, cb, data)
    local src = source
    if not checkCooldown(src, 'openAccount') then return cb(result(false, Lang:t('error.error'))) end

    local Player, citizenid = getPlayerAndCitizenId(src)
    if not Player or not citizenid then return cb(result(false, Lang:t('error.error'))) end

    data = type(data) == 'table' and data or {}
    local accountName = sanitizeAccountName(data.accountName)
    local initialAmount, amountError = validateMoneyAmount(data.amount or 0, true)

    if not accountName or accountName == 'checking' then return cb(result(false, Lang:t('error.account'))) end
    if not initialAmount then return cb(result(false, amountError)) end
    if Accounts[accountName] then return cb(result(false, Lang:t('error.account'))) end
    if getNumberOfAccounts(citizenid) >= Config.maxAccounts then return cb(result(false, Lang:t('error.accounts'))) end
    if Player.PlayerData.money.bank < initialAmount then return cb(result(false, Lang:t('error.money'))) end

    if initialAmount > 0 and not Player.Functions.RemoveMoney('bank', initialAmount, 'opened account ' .. accountName) then
        return cb(result(false, Lang:t('error.money')))
    end

    if not CreatePlayerAccount(src, accountName, initialAmount, json.encode({})) then return cb(result(false, Lang:t('error.error'))) end
    if initialAmount > 0 then
        if not CreateBankStatement(src, accountName, initialAmount, 'Initial deposit', 'deposit', 'shared') then return cb(result(false, Lang:t('error.error'))) end
        if not CreateBankStatement(src, 'checking', initialAmount, 'Initial deposit for ' .. accountName, 'withdraw', 'player') then return cb(result(false, Lang:t('error.error'))) end
    end

    TriggerEvent('qb-log:server:CreateLog', 'banking', 'Account Opened', 'green', string.format('**%s** opened account **%s** with an initial deposit of **$%s**', GetPlayerName(src), accountName, initialAmount))
    cb(result(true, Lang:t('success.account')))
end)

QBCore.Functions.CreateCallback('qb-banking:server:renameAccount', function(source, cb, data)
    local src = source
    if not checkCooldown(src, 'renameAccount') then return cb(result(false, Lang:t('error.error'))) end

    local Player, citizenid = getPlayerAndCitizenId(src)
    if not Player or not citizenid then return cb(result(false, Lang:t('error.error'))) end

    data = type(data) == 'table' and data or {}
    local oldName = sanitizeAccountName(data.oldName)
    local newName = sanitizeAccountName(data.newName)
    if not oldName or not newName or newName == 'checking' then return cb(result(false, Lang:t('error.account'))) end
    if Accounts[newName] then return cb(result(false, Lang:t('error.account'))) end

    local canManage, account = canManageSharedAccount(Player, oldName)
    if not account then return cb(result(false, Lang:t('error.account'))) end
    if not canManage then return cb(result(false, Lang:t('error.access'))) end

    Accounts[newName] = account
    Accounts[newName].account_name = newName
    Accounts[oldName] = nil

    if Statements[oldName] then
        Statements[newName] = Statements[oldName]
        Statements[oldName] = nil
    end

    local dbResult = MySQL.update.await('UPDATE bank_accounts SET account_name = ? WHERE account_name = ? AND citizenid = ?', { newName, oldName, citizenid })
    if not dbResult then return cb(result(false, Lang:t('error.error'))) end

    MySQL.update.await('UPDATE bank_statements SET account_name = ? WHERE account_name = ?', { newName, oldName })
    TriggerEvent('qb-log:server:CreateLog', 'banking', 'Account Renamed', 'red', string.format('**%s** renamed **%s** to **%s**', GetPlayerName(src), oldName, newName))
    cb(result(true, Lang:t('success.rename')))
end)

QBCore.Functions.CreateCallback('qb-banking:server:deleteAccount', function(source, cb, data)
    local src = source
    if not checkCooldown(src, 'deleteAccount') then return cb(result(false, Lang:t('error.error'))) end

    local Player, citizenid = getPlayerAndCitizenId(src)
    if not Player or not citizenid then return cb(result(false, Lang:t('error.error'))) end

    data = type(data) == 'table' and data or {}
    local accountName = sanitizeAccountName(data.accountName)
    if not accountName or accountName == 'checking' then return cb(result(false, Lang:t('error.account'))) end

    local canManage, account = canManageSharedAccount(Player, accountName)
    if not account then return cb(result(false, Lang:t('error.account'))) end
    if not canManage then return cb(result(false, Lang:t('error.access'))) end

    Accounts[accountName] = nil
    Statements[accountName] = nil

    local dbResult = MySQL.rawExecute.await('DELETE FROM bank_accounts WHERE account_name = ? AND citizenid = ?', { accountName, citizenid })
    if not dbResult then return cb(result(false, Lang:t('error.error'))) end

    TriggerEvent('qb-log:server:CreateLog', 'banking', 'Account Deleted', 'red', string.format('**%s** deleted account **%s**', GetPlayerName(src), accountName))
    cb(result(true, Lang:t('success.delete')))
end)

QBCore.Functions.CreateCallback('qb-banking:server:addUser', function(source, cb, data)
    local src = source
    if not checkCooldown(src, 'addUser') then return cb(result(false, Lang:t('error.error'))) end

    local Player, citizenid = getPlayerAndCitizenId(src)
    if not Player or not citizenid then return cb(result(false, Lang:t('error.error'))) end

    data = type(data) == 'table' and data or {}
    local accountName = sanitizeAccountName(data.accountName)
    local userToAdd = sanitizeCitizenId(data.userName)
    if not accountName or not userToAdd then return cb(result(false, Lang:t('error.account'))) end

    local canManage, account = canManageSharedAccount(Player, accountName)
    if not account then return cb(result(false, Lang:t('error.account'))) end
    if not canManage then return cb(result(false, Lang:t('error.access'))) end
    if accountHasUser(account, userToAdd) or account.citizenid == userToAdd then return cb(result(false, Lang:t('error.user'))) end

    local users = decodeUsers(account.users)
    users[#users + 1] = userToAdd
    local usersData = encodeUsers(users)
    Accounts[accountName].users = usersData

    local dbResult = MySQL.update.await('UPDATE bank_accounts SET users = ? WHERE account_name = ? AND citizenid = ?', { usersData, accountName, citizenid })
    if not dbResult then return cb(result(false, Lang:t('error.error'))) end

    TriggerEvent('qb-log:server:CreateLog', 'banking', 'User Added', 'green', string.format('**%s** added **%s** to **%s**', GetPlayerName(src), userToAdd, accountName))
    cb(result(true, Lang:t('success.userAdd')))
end)

QBCore.Functions.CreateCallback('qb-banking:server:removeUser', function(source, cb, data)
    local src = source
    if not checkCooldown(src, 'removeUser') then return cb(result(false, Lang:t('error.error'))) end

    local Player, citizenid = getPlayerAndCitizenId(src)
    if not Player or not citizenid then return cb(result(false, Lang:t('error.error'))) end

    data = type(data) == 'table' and data or {}
    local accountName = sanitizeAccountName(data.accountName)
    local userToRemove = sanitizeCitizenId(data.userName)
    if not accountName or not userToRemove then return cb(result(false, Lang:t('error.account'))) end

    local canManage, account = canManageSharedAccount(Player, accountName)
    if not account then return cb(result(false, Lang:t('error.account'))) end
    if not canManage then return cb(result(false, Lang:t('error.access'))) end

    local users = decodeUsers(account.users)
    local userFound = false
    for i = #users, 1, -1 do
        if tostring(users[i]) == tostring(userToRemove) then
            table.remove(users, i)
            userFound = true
            break
        end
    end

    if not userFound then return cb(result(false, Lang:t('error.noUser'))) end

    local usersData = encodeUsers(users)
    Accounts[accountName].users = usersData

    local dbResult = MySQL.update.await('UPDATE bank_accounts SET users = ? WHERE account_name = ? AND citizenid = ?', { usersData, accountName, citizenid })
    if not dbResult then return cb(result(false, Lang:t('error.error'))) end

    TriggerEvent('qb-log:server:CreateLog', 'banking', 'User Removed', 'red', string.format('**%s** removed **%s** from **%s**', GetPlayerName(src), userToRemove, accountName))
    cb(result(true, Lang:t('success.userRemove')))
end)

QBCore.Functions.CreateUseableItem('bank_card', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.Functions.GetItemByName(item.name) then
        TriggerClientEvent('qb-banking:client:useCard', source)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local prefix = tostring(src) .. ':'
    for key in pairs(Cooldowns) do
        if key:sub(1, #prefix) == prefix then
            Cooldowns[key] = nil
        end
    end
end)

CreateThread(function()
    local accounts = MySQL.query.await('SELECT * FROM bank_accounts') or {}
    for _, account in ipairs(accounts) do
        local safeAccountName = sanitizeAccountName(account.account_name)
        if safeAccountName then
            account.account_name = safeAccountName
            account.account_balance = tonumber(account.account_balance) or 0
            account.users = account.users or '[]'
            Accounts[safeAccountName] = account
        end
    end

    for job in pairs(QBCore.Shared.Jobs or {}) do
        local jobAccountName = sanitizeAccountName(job)
        if jobAccountName and not Accounts[jobAccountName] then
            CreateJobAccount(jobAccountName, 0)
        end
    end

    debugLog(('Loaded %s bank accounts'):format(tostring(#accounts)))
end)

CreateThread(function()
    local statements = MySQL.query.await('SELECT * FROM bank_statements') or {}
    for _, statement in ipairs(statements) do
        if statement.account_name == 'checking' then
            if statement.citizenid then
                if not Statements[statement.citizenid] then Statements[statement.citizenid] = {} end
                if not Statements[statement.citizenid].checking then Statements[statement.citizenid].checking = {} end
                Statements[statement.citizenid].checking[#Statements[statement.citizenid].checking + 1] = statement
            end
        else
            local safeAccountName = sanitizeAccountName(statement.account_name)
            if safeAccountName then
                if not Statements[safeAccountName] then Statements[safeAccountName] = {} end
                Statements[safeAccountName][#Statements[safeAccountName] + 1] = statement
            end
        end
    end

    debugLog(('Loaded %s bank statements'):format(tostring(#statements)))
end)

QBCore.Commands.Add('givecash', 'Give Cash', { { name = 'id', help = 'Player ID' }, { name = 'amount', help = 'Amount' } }, true, function(source, args)
    local src = source
    if not checkCooldown(src, 'givecash') then return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.error'), 'error') end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local targetId = tonumber(args[1])
    if not targetId then return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.noUser'), 'error') end

    local target = QBCore.Functions.GetPlayer(targetId)
    if not target then return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.noUser'), 'error') end

    local amount, amountError = validateMoneyAmount(args[2])
    if not amount then return TriggerClientEvent('QBCore:Notify', src, amountError, 'error') end

    local playerPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(targetId)
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)

    if #(playerCoords - targetCoords) > 5 then return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.toofar'), 'error') end
    if Player.PlayerData.money.cash < amount then return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.money'), 'error') end
    if not Player.Functions.RemoveMoney('cash', amount, 'cash transfer') then return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.money'), 'error') end

    target.Functions.AddMoney('cash', amount, 'cash transfer')
    TriggerClientEvent('QBCore:Notify', src, string.format(Lang:t('success.give'), amount), 'success')
    TriggerClientEvent('QBCore:Notify', target.PlayerData.source, string.format(Lang:t('success.receive'), amount), 'success')
end)
