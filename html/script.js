/**
 * qb-banking-alc-knbx client UI script.
 * Handles NUI messages, interface state, settings and banking actions.
 * Modified by AitLilCat / ALC for the public GPL-3.0 community release.
 */

const translations = {
  nl: {
    bank_env: "Je bankomgeving is beschikbaar",
    start_now: "Begin direct",
    welcome_title: "Welkom bij je bankomgeving",
    welcome_subtitle:
      "Een nette Nederlandse bankervaring voor jouw roleplay server.",
    welcome_button: "Welkom",
    choose_language: "Kies je taal",
    language_subtitle: "Deze keuze wordt voor jouw speler onthouden.",
    pin_confirm: "Pincode bevestigen",
    pin_subtitle: "Voer je pincode in om de ATM te gebruiken.",
    confirm: "Bevestigen",
    close: "Sluiten",
    account: "Account",
    player: "Speler",
    accounts: "Rekeningen",
    dashboard: "Dashboard",
    money_management: "Geld Beheer",
    invoices: "Facturen",
    settings: "Instellingen",
    language: "Taal",
    theme: "Thema",
    light_mode: "Licht",
    dark_mode: "Donker",
    cash: "Cash",
    account_number: "Rekening nr.",
    atm_account: "ATM rekening",
    atm_actions: "ATM acties",
    choose_account: "Kies rekening",
    amount: "Bedrag",
    description: "Omschrijving",
    atm_reason: "ATM opname of storting",
    withdraw: "Opnemen",
    deposit: "Storten",
    payment_account: "Betaalrekening",
    income_monthly: "Maandinkomen",
    expenses: "Uitgaven",
    account_trend: "Rekeningverloop",
    latest_transactions: "Laatste transacties",
    no_transactions: "Nog geen transacties gevonden.",
    deposit_and_withdraw: "Storten en opnemen",
    salary_rent_atm: "Salaris, huur, ATM...",
    transfer: "Overmaken",
    internal_and_external: "Intern en extern",
    internal_transfer: "Interne overboeking",
    external_transfer: "Externe overboeking",
    from_account: "Van rekening",
    to_account: "Naar rekening",
    to_account_number: "Naar rekeningnummer",
    citizenid_or_account: "CitizenID / rekening",
    send: "Versturen",
    new_account_and_card: "Nieuwe rekening en kaart",
    new_account: "Nieuwe rekening",
    name: "Naam",
    savings_business: "spaarpot, bedrijf...",
    starting_amount: "Startbedrag",
    open_account: "Open rekening",
    debit_card: "Debetkaart",
    pin_code: "Pincode",
    order_card: "Kaart bestellen",
    tikkie: "Tikkie",
    frontend_preview: "Frontend preview",
    tikkie_helper: "Gebruik dit als basis voor een latere phone integratie.",
    quick_request: "Snelverzoek",
    tikkie_examples: "Lunch, boete, benzine...",
    tikkie_ready: "Tikkie frontend preview klaar.",
    generate_preview: "Genereer preview",
    invoices_penalties: "Facturen & Boetes",
    open_costs: "Openstaande penalties en kosten",
    pay: "Betaal",
    no_invoices: "Geen openstaande facturen of boetes gevonden.",
    close_account: "Opheffen",
    confirm_delete_title: "Wil je dit zeker weten?",
    confirm_delete_text:
      "Alles wat op deze rekening staat wordt opgeheven dus alles verdwijnt!",
    yes_delete: "Ja, opheffen",
    no_keep: "Nee, behouden",
    mood_negative_title: "Negatief",
    mood_negative_text: "Je saldo staat onder nul.",
    mood_low_title: "Laag saldo",
    mood_low_text: "Je saldo is laag, let op je uitgaven.",
    mood_good_title: "Gezond saldo",
    mood_good_text: "Je rekening ziet er netjes uit.",
    mood_ok_title: "Prima",
    mood_ok_text: "Je saldo is stabiel.",
    page_home_subtitle:
      "Overzicht van je rekening, verloop en laatste transacties.",
    page_money_subtitle:
      "Storten, opnemen, overmaken, rekeningbeheer en tikje preview op één plek.",
    page_invoices_subtitle: "Bekijk boetes, penalties en openstaande facturen.",
    theme_saved: "Instellingen opgeslagen.",
    account_deleted: "Rekening opgeheven.",
  },
  en: {
    bank_env: "Your banking environment is available",
    start_now: "Start now",
    welcome_title: "Welcome to your banking environment",
    welcome_subtitle:
      "A clean Dutch-inspired banking experience for your roleplay server.",
    welcome_button: "Welcome",
    choose_language: "Choose your language",
    language_subtitle: "This choice will be remembered for your player.",
    pin_confirm: "Confirm pin code",
    pin_subtitle: "Enter your pin code to use the ATM.",
    confirm: "Confirm",
    close: "Close",
    account: "Account",
    player: "Player",
    accounts: "Accounts",
    dashboard: "Dashboard",
    money_management: "Money Management",
    invoices: "Invoices",
    settings: "Settings",
    language: "Language",
    theme: "Theme",
    light_mode: "Light",
    dark_mode: "Dark",
    cash: "Cash",
    account_number: "Account no.",
    atm_account: "ATM account",
    atm_actions: "ATM actions",
    choose_account: "Choose account",
    amount: "Amount",
    description: "Description",
    atm_reason: "ATM withdrawal or deposit",
    withdraw: "Withdraw",
    deposit: "Deposit",
    payment_account: "Checking account",
    income_monthly: "Monthly income",
    expenses: "Expenses",
    account_trend: "Account trend",
    latest_transactions: "Latest transactions",
    no_transactions: "No transactions found yet.",
    deposit_and_withdraw: "Deposit and withdraw",
    salary_rent_atm: "Salary, rent, ATM...",
    transfer: "Transfer",
    internal_and_external: "Internal and external",
    internal_transfer: "Internal transfer",
    external_transfer: "External transfer",
    from_account: "From account",
    to_account: "To account",
    to_account_number: "To account number",
    citizenid_or_account: "CitizenID / account",
    send: "Send",
    new_account_and_card: "New account and card",
    new_account: "New account",
    name: "Name",
    savings_business: "savings, business...",
    starting_amount: "Starting amount",
    open_account: "Open account",
    debit_card: "Debit card",
    pin_code: "Pin code",
    order_card: "Order card",
    tikkie: "Tikkie",
    frontend_preview: "Frontend preview",
    tikkie_helper: "Use this as a base for later phone integration.",
    quick_request: "Quick request",
    tikkie_examples: "Lunch, fine, fuel...",
    tikkie_ready: "Tikkie frontend preview ready.",
    generate_preview: "Generate preview",
    invoices_penalties: "Invoices & Penalties",
    open_costs: "Outstanding penalties and costs",
    pay: "Pay",
    no_invoices: "No open invoices or penalties found.",
    close_account: "Close account",
    confirm_delete_title: "Are you sure?",
    confirm_delete_text:
      "Everything on this account will be removed, so all funds will disappear!",
    yes_delete: "Yes, delete",
    no_keep: "No, keep it",
    mood_negative_title: "Negative",
    mood_negative_text: "Your balance is below zero.",
    mood_low_title: "Low balance",
    mood_low_text: "Your balance is low, watch your spending.",
    mood_good_title: "Healthy balance",
    mood_good_text: "Your account is looking solid.",
    mood_ok_title: "Okay",
    mood_ok_text: "Your balance is stable.",
    page_home_subtitle:
      "Overview of your account, trend and latest transactions.",
    page_money_subtitle:
      "Deposit, withdraw, transfer, account management and tikkie preview in one place.",
    page_invoices_subtitle: "View penalties and outstanding invoices.",
    theme_saved: "Settings saved.",
    account_deleted: "Account deleted.",
  },
};

const bankingApp = Vue.createApp({
  data() {
    return {
      isBankOpen: false,
      isATMOpen: false,
      showPinPrompt: false,
      showOnboarding: false,
      onboardingStep: "welcome",
      showSettings: false,
      showDeleteConfirm: false,
      currentLanguage: "en",
      theme: "light",
      notification: null,
      activeView: "home",
      accounts: [],
      statements: {},
      selectedAccountStatement: "checking",
      deleteTarget: null,
      playerName: "",
      accountNumber: "",
      playerCash: 0,
      playerJob: null,
      playerJobPayment: 0,
      selectedMoneyAccount: null,
      selectedMoneyAmount: 0,
      moneyReason: "",
      internalFromAccount: null,
      internalToAccount: null,
      internalTransferAmount: 0,
      externalAccountNumber: "",
      externalFromAccount: null,
      externalTransferAmount: 0,
      transferReason: "",
      debitPin: "",
      enteredPin: "",
      acceptablePins: [],
      tempBankData: null,
      createAccountName: "",
      createAccountAmount: 0,
      invoiceItems: [],
      brandName: "KNBX",
    };
  },
  computed: {
    accountStatements() {
      return this.statements[this.selectedAccountStatement] || [];
    },
    currentAccountBalance() {
      const account = this.accounts.find(
        (acc) => acc.name === this.selectedAccountStatement,
      );
      return account ? Number(account.balance || 0) : 0;
    },
    totalWithdrawals() {
      return this.accountStatements
        .filter((s) => s.type === "withdraw")
        .reduce((sum, s) => sum + Number(s.amount || 0), 0);
    },
    monthlyIncomeEstimate() {
      if (this.playerJobPayment && Number(this.playerJobPayment) > 0) {
        return Number(this.playerJobPayment) * 30;
      }
      return 150;
    },
    chartStatements() {
      return this.accountStatements.slice(0, 8).reverse();
    },
    chartPoints() {
      const data = this.chartStatements;
      if (!data.length)
        return [
          { x: 40, y: 180 },
          { x: 960, y: 180 },
        ];
      let running = 0;
      const totals = data.map((s) => {
        running +=
          s.type === "deposit" ? Number(s.amount || 0) : -Number(s.amount || 0);
        return running;
      });
      const min = Math.min(...totals, 0);
      const max = Math.max(...totals, 1);
      const range = Math.max(max - min, 1);
      return totals.map((val, idx) => {
        const x = 40 + idx * (920 / Math.max(data.length - 1, 1));
        const y = 230 - ((val - min) / range) * 180;
        return { x, y };
      });
    },
    chartPath() {
      const pts = this.chartPoints;
      return pts
        .map((p, i) => `${i === 0 ? "M" : "L"} ${p.x} ${p.y}`)
        .join(" ");
    },
    chartAreaPath() {
      const pts = this.chartPoints;
      if (!pts.length) return "";
      const start = pts[0];
      const end = pts[pts.length - 1];
      return `${this.chartPath} L ${end.x} 250 L ${start.x} 250 Z`;
    },
    moodStatus() {
      const bal = this.currentAccountBalance;
      if (bal < 0)
        return {
          class: "bad",
          emoji: "☹️",
          label: this.t("mood_negative_title"),
          text: this.t("mood_negative_text"),
        };
      if (bal < 100)
        return {
          class: "warn",
          emoji: "🙂",
          label: this.t("mood_low_title"),
          text: this.t("mood_low_text"),
        };
      if (bal > 500)
        return {
          class: "good",
          emoji: "😄",
          label: this.t("mood_good_title"),
          text: this.t("mood_good_text"),
        };
      return {
        class: "warn",
        emoji: "🙂",
        label: this.t("mood_ok_title"),
        text: this.t("mood_ok_text"),
      };
    },
    pageTitle() {
      if (this.isATMOpen && !this.isBankOpen) return "ATM";
      const titles = {
        home: this.t("dashboard"),
        money: this.t("money_management"),
        invoices: this.t("invoices"),
      };
      return titles[this.activeView] || this.t("dashboard");
    },
    pageSubtitle() {
      if (this.isATMOpen && !this.isBankOpen) return this.t("pin_subtitle");
      const subtitles = {
        home: this.t("page_home_subtitle"),
        money: this.t("page_money_subtitle"),
        invoices: this.t("page_invoices_subtitle"),
      };
      return subtitles[this.activeView] || "";
    },
  },
  methods: {
    t(key) {
      return (
        (translations[this.currentLanguage] &&
          translations[this.currentLanguage][key]) ||
        translations.nl[key] ||
        key
      );
    },
    persistSettings(payload = {}) {
      return axios
        .post(`https://${GetParentResourceName()}/saveSettings`, {
          language: payload.language || this.currentLanguage,
          theme: payload.theme || this.theme,
        })
        .catch(() => {});
    },
    selectLanguage(lang) {
      this.currentLanguage = lang;
      this.persistSettings({ language: lang, theme: this.theme }).then(() => {
        this.showOnboarding = false;
        this.onboardingStep = "welcome";
        if (this.tempBankData && this.tempBankData.pinNumbers) {
          this.showPinPrompt = true;
        }
      });
    },
    changeLanguage(lang) {
      this.currentLanguage = lang;
      this.persistSettings({ language: lang, theme: this.theme });
      this.addNotification(this.t("theme_saved"), "success");
    },
    openSettings() {
      this.showSettings = true;
    },
    changeTheme(theme) {
      this.theme = theme;
      document.body.setAttribute("data-theme", theme);
      this.persistSettings({ language: this.currentLanguage, theme: theme });
      this.addNotification(this.t("theme_saved"), "success");
    },
    hydrateCommon(bankData) {
      const playerData = bankData.playerData || {};
      this.playerName =
        `${playerData.charinfo?.firstname ?? ""}`.trim() || this.t("player");
      this.accountNumber = playerData.citizenid || "";
      this.playerCash = Number(playerData.money?.cash || 0);
      this.playerJob = playerData.job || null;
      this.playerJobPayment = Number(playerData.job?.payment || 0);

      // Language preference fallback.
      const country = (bankData.branding?.country || "EN").toLowerCase();

      this.currentLanguage =
        bankData.language === "en" || bankData.language === "nl"
          ? bankData.language
          : country === "nl"
            ? "nl"
            : "en";

      this.theme =
        bankData.theme === "dark" || bankData.theme === "light"
          ? bankData.theme
          : "light";

      document.body.setAttribute("data-theme", this.theme);

      this.brandName =
        (bankData.branding && bankData.branding.shortName) || "KNBX";

      this.accounts = [];
      (bankData.accounts || []).forEach((account) => {
        this.accounts.push({
          name: account.account_name,
          type: account.account_type,
          balance: Number(account.account_balance || 0),
          users: account.users,
          id: account.id,
        });
      });
    },
    openBank(bankData) {
      this.hydrateCommon(bankData);
      this.statements = {};
      Object.keys(bankData.statements || {}).forEach((accountKey) => {
        this.statements[accountKey] = bankData.statements[accountKey].map(
          (statement) => ({
            id: statement.id,
            date: statement.date,
            reason: statement.reason || "Transaction",
            amount: Number(statement.amount || 0),
            type: statement.statement_type,
            user: statement.citizenid,
          }),
        );
      });
      this.invoiceItems = (bankData.invoices || []).map((invoice) => ({
        id: invoice.id,
        title: invoice.sender || invoice.society || "Invoice",
        description: invoice.society
          ? `${invoice.society}`
          : "Openstaande factuur",
        amount: Number(invoice.amount || 0),
        sendercitizenid: invoice.sendercitizenid,
        society: invoice.society,
      }));
      this.selectedAccountStatement = this.accounts[0]?.name || "checking";
      this.selectedMoneyAccount = this.accounts[0] || null;
      this.activeView = "home";
      this.isATMOpen = false;
      this.isBankOpen = true;
      this.showOnboarding = !bankData.language;
      this.onboardingStep = "welcome";
    },
    openATM(bankData) {
      this.hydrateCommon(bankData);
      this.selectedMoneyAccount = this.accounts[0] || null;
      this.isBankOpen = false;
      this.isATMOpen = true;
      this.showOnboarding = !bankData.language;
      this.tempBankData = bankData;
      this.onboardingStep = "welcome";
    },
    pinPrompt(enteredPin) {
      const bankData = this.tempBankData;
      this.acceptablePins = Array.from(bankData.pinNumbers || []);
      if (this.acceptablePins.includes(parseInt(enteredPin))) {
        this.showPinPrompt = false;
        this.enteredPin = "";
        this.isATMOpen = true;
      } else {
        this.addNotification(
          this.currentLanguage === "en"
            ? "Incorrect pin code."
            : "Pincode onjuist.",
          "error",
        );
      }
    },
    withdrawMoney() {
      if (!this.selectedMoneyAccount || this.selectedMoneyAmount <= 0) return;
      axios
        .post(`https://${GetParentResourceName()}/withdraw`, {
          accountName: this.selectedMoneyAccount.name,
          amount: Number(this.selectedMoneyAmount),
          reason: this.moneyReason,
        })
        .then((response) => {
          if (response.data.success) {
            const account = this.accounts.find(
              (acc) => acc.name === this.selectedMoneyAccount.name,
            );
            if (account) {
              account.balance -= Number(this.selectedMoneyAmount);
              this.playerCash += Number(this.selectedMoneyAmount);
              this.addStatement(
                this.accountNumber,
                this.selectedMoneyAccount.name,
                this.moneyReason || this.t("withdraw"),
                Number(this.selectedMoneyAmount),
                "withdraw",
              );
            }
            this.resetMoneyFields();
          }
          this.addNotification(
            response.data.message,
            response.data.success ? "success" : "error",
          );
        });
    },
    depositMoney() {
      if (!this.selectedMoneyAccount || this.selectedMoneyAmount <= 0) return;
      axios
        .post(`https://${GetParentResourceName()}/deposit`, {
          accountName: this.selectedMoneyAccount.name,
          amount: Number(this.selectedMoneyAmount),
          reason: this.moneyReason,
        })
        .then((response) => {
          if (response.data.success) {
            const account = this.accounts.find(
              (acc) => acc.name === this.selectedMoneyAccount.name,
            );
            if (account) {
              account.balance += Number(this.selectedMoneyAmount);
              this.playerCash -= Number(this.selectedMoneyAmount);
              this.addStatement(
                this.accountNumber,
                this.selectedMoneyAccount.name,
                this.moneyReason || this.t("deposit"),
                Number(this.selectedMoneyAmount),
                "deposit",
              );
            }
            this.resetMoneyFields();
          }
          this.addNotification(
            response.data.message,
            response.data.success ? "success" : "error",
          );
        });
    },
    internalTransfer() {
      if (
        !this.internalFromAccount ||
        !this.internalToAccount ||
        this.internalTransferAmount <= 0
      )
        return;
      axios
        .post(`https://${GetParentResourceName()}/internalTransfer`, {
          fromAccountName: this.internalFromAccount.name,
          toAccountName: this.internalToAccount.name,
          amount: Number(this.internalTransferAmount),
          reason: this.transferReason,
        })
        .then((response) => {
          if (response.data.success) {
            const fromAccount = this.accounts.find(
              (acc) => acc.name === this.internalFromAccount.name,
            );
            const toAccount = this.accounts.find(
              (acc) => acc.name === this.internalToAccount.name,
            );
            if (fromAccount)
              fromAccount.balance -= Number(this.internalTransferAmount);
            if (toAccount)
              toAccount.balance += Number(this.internalTransferAmount);
            this.addStatement(
              this.accountNumber,
              this.internalFromAccount.name,
              this.transferReason || this.t("internal_transfer"),
              Number(this.internalTransferAmount),
              "withdraw",
            );
            this.addStatement(
              this.accountNumber,
              this.internalToAccount.name,
              this.transferReason || this.t("internal_transfer"),
              Number(this.internalTransferAmount),
              "deposit",
            );
            this.internalTransferAmount = 0;
            this.transferReason = "";
            this.internalFromAccount = null;
            this.internalToAccount = null;
          }
          this.addNotification(
            response.data.message,
            response.data.success ? "success" : "error",
          );
        });
    },
    externalTransfer() {
      if (
        !this.externalFromAccount ||
        !this.externalAccountNumber ||
        this.externalTransferAmount <= 0
      )
        return;
      axios
        .post(`https://${GetParentResourceName()}/externalTransfer`, {
          fromAccountName: this.externalFromAccount.name,
          toAccountNumber: this.externalAccountNumber,
          amount: Number(this.externalTransferAmount),
          reason: this.transferReason,
        })
        .then((response) => {
          if (response.data.success) {
            const fromAccount = this.accounts.find(
              (acc) => acc.name === this.externalFromAccount.name,
            );
            if (fromAccount)
              fromAccount.balance -= Number(this.externalTransferAmount);
            this.addStatement(
              this.accountNumber,
              this.externalFromAccount.name,
              this.transferReason || this.t("external_transfer"),
              Number(this.externalTransferAmount),
              "withdraw",
            );
            this.externalTransferAmount = 0;
            this.transferReason = "";
            this.externalFromAccount = null;
            this.externalAccountNumber = "";
          }
          this.addNotification(
            response.data.message,
            response.data.success ? "success" : "error",
          );
        });
    },
    orderDebitCard() {
      if (!this.debitPin) return;
      axios
        .post(`https://${GetParentResourceName()}/orderCard`, {
          pin: this.debitPin,
        })
        .then((response) => {
          if (response.data.success) this.debitPin = "";
          this.addNotification(
            response.data.message,
            response.data.success ? "success" : "error",
          );
        });
    },
    openAccount() {
      if (!this.createAccountName || this.createAccountAmount < 0) return;
      axios
        .post(`https://${GetParentResourceName()}/openAccount`, {
          accountName: this.createAccountName,
          amount: Number(this.createAccountAmount),
        })
        .then((response) => {
          if (response.data.success) {
            const checkingAccount =
              this.accounts.find((acc) => acc.name === "checking") ||
              this.accounts[0];
            if (checkingAccount)
              checkingAccount.balance -= Number(this.createAccountAmount);
            this.accounts.push({
              name: this.createAccountName,
              type: "shared",
              balance: Number(this.createAccountAmount),
              users: JSON.stringify([this.playerName]),
            });
            this.statements[this.createAccountName] = [
              {
                id: Date.now(),
                date: Date.now(),
                reason: "Initial deposit",
                amount: Number(this.createAccountAmount),
                type: "deposit",
                user: this.accountNumber,
              },
            ];
            if (checkingAccount)
              this.addStatement(
                this.accountNumber,
                checkingAccount.name,
                "Initial deposit",
                Number(this.createAccountAmount),
                "withdraw",
              );
            this.createAccountName = "";
            this.createAccountAmount = 0;
          }
          this.addNotification(
            response.data.message,
            response.data.success ? "success" : "error",
          );
        });
    },
    payInvoice(invoice) {
      axios
        .post(`https://${GetParentResourceName()}/payInvoice`, {
          invoiceId: invoice.id,
        })
        .then((response) => {
          if (response.data.success) {
            const checking =
              this.accounts.find((acc) => acc.name === "checking") ||
              this.accounts[0];
            if (checking) {
              checking.balance -= Number(invoice.amount);
              this.addStatement(
                this.accountNumber,
                checking.name,
                invoice.title,
                Number(invoice.amount),
                "withdraw",
              );
            }
            this.invoiceItems = this.invoiceItems.filter(
              (x) => x.id !== invoice.id,
            );
          }
          this.addNotification(
            response.data.message,
            response.data.success ? "success" : "error",
          );
        });
    },
    promptDeleteSelectedAccount() {
      const target = this.accounts.find(
        (a) => a.name === this.selectedAccountStatement,
      );
      if (!target || target.name === "checking") return;
      this.deleteTarget = target;
      this.showDeleteConfirm = true;
    },
    deleteSelectedAccountConfirmed() {
      if (!this.deleteTarget) return;
      axios
        .post(`https://${GetParentResourceName()}/deleteAccount`, {
          accountName: this.deleteTarget.name,
        })
        .then((response) => {
          if (response.data.success) {
            this.accounts = this.accounts.filter(
              (a) => a.name !== this.deleteTarget.name,
            );
            delete this.statements[this.deleteTarget.name];
            this.selectedAccountStatement = "checking";
            this.selectedMoneyAccount = this.accounts[0] || null;
            this.showDeleteConfirm = false;
            this.deleteTarget = null;
          }
          this.addNotification(
            response.data.message || this.t("account_deleted"),
            response.data.success ? "success" : "error",
          );
        });
    },
    addStatement(user, accountName, reason, amount, type) {
      if (!this.statements[accountName]) this.statements[accountName] = [];
      this.statements[accountName].unshift({
        id: Date.now() + Math.random(),
        date: Date.now(),
        reason,
        amount: Number(amount || 0),
        type,
        user,
      });
    },
    addNotification(message, type) {
      this.notification = { message, type };
      setTimeout(() => {
        this.notification = null;
      }, 2500);
    },
    resetMoneyFields() {
      this.selectedMoneyAmount = 0;
      this.moneyReason = "";
    },
    selectAccount(account) {
      this.selectedAccountStatement = account.name;
      this.selectedMoneyAccount = account;
    },
    setActiveView(view) {
      this.activeView = view;
    },
    formatEuro(amount) {
      return new Intl.NumberFormat(
        this.currentLanguage === "en" ? "en-GB" : "nl-NL",
        { style: "currency", currency: "EUR" },
      ).format(Number(amount || 0));
    },
    formatDate(timestamp) {
      const date = new Date(parseInt(timestamp) || timestamp);
      if (Number.isNaN(date.getTime())) return "Unknown";
      return date.toLocaleString(
        this.currentLanguage === "en" ? "en-GB" : "nl-NL",
        {
          day: "2-digit",
          month: "2-digit",
          year: "numeric",
          hour: "2-digit",
          minute: "2-digit",
        },
      );
    },
    amountPrefix(type) {
      return type === "deposit" ? "+ " : "- ";
    },
    prettifyAccountName(name) {
      if (!name) return this.t("account");
      const map = {
        checking:
          this.currentLanguage === "en" ? "Checking account" : "Betaalrekening",
        savings:
          this.currentLanguage === "en" ? "Savings account" : "Spaarrekening",
      };
      return map[name] || name.charAt(0).toUpperCase() + name.slice(1);
    },
    initials(name) {
      if (!name) return "QB";
      return name
        .split(" ")
        .filter(Boolean)
        .slice(0, 2)
        .map((x) => x[0].toUpperCase())
        .join("");
    },
    handleMessage(event) {
      const data = event.data;
      if (data.action === "openBank") {
        this.openBank(data);
      } else if (data.action === "openATM") {
        this.tempBankData = data;
        this.hydrateCommon(data);
        if (!data.language) {
          this.showOnboarding = true;
          this.onboardingStep = "welcome";
          this.isBankOpen = false;
          this.isATMOpen = false;
          this.showPinPrompt = false;
        } else {
          this.showPinPrompt = true;
        }
      }
    },
    handleKeydown(event) {
      if (event.key === "Escape") this.closeApplication();
    },
    closeApplication() {
      this.isBankOpen = false;
      this.isATMOpen = false;
      this.showPinPrompt = false;
      this.showOnboarding = false;
      this.showSettings = false;
      this.showDeleteConfirm = false;
      this.enteredPin = "";
      axios.post(`https://${GetParentResourceName()}/closeApp`, {});
    },
  },
  mounted() {
    document.addEventListener("keydown", this.handleKeydown);
    window.addEventListener("message", this.handleMessage);
    document.body.setAttribute("data-theme", this.theme);
  },
  beforeUnmount() {
    document.removeEventListener("keydown", this.handleKeydown);
    window.removeEventListener("message", this.handleMessage);
  },
}).mount("#app");

// ===== KNBX UI CONFIG STABLE =====
(function () {
  if (window.__knbxUiConfigBound) return;
  window.__knbxUiConfigBound = true;

  window.KNBX_UI_CONFIG = {
    ShowGear: true,
    ShowTikkie: true,
    ShowRekeningen: true,
    ShowGeldBeheer: true,
    ShowStortenOpnemen: true,
    ShowOvermaken: true,
    ShowInternExtern: true,
  };

  function setVisible(id, visible) {
    const el = document.getElementById(id);
    if (!el) return;
    el.style.display = visible ? "" : "none";
  }

  function applyKnBxUiConfig() {
    const cfg = window.KNBX_UI_CONFIG || {};

    // global controls
    setVisible("gear-button", cfg.ShowGear !== false);
    setVisible("nav-money-button", cfg.ShowGeldBeheer !== false);

    // money view panels
    setVisible("section-geldbeheer", cfg.ShowGeldBeheer !== false);
    setVisible("section-rekeningen", cfg.ShowRekeningen !== false);
    setVisible("section-tikkie", cfg.ShowTikkie !== false);

    const showTransferParent = cfg.ShowOvermaken !== false;
    setVisible("section-overmaken", showTransferParent);

    // internal/external inside transfer card
    const showInternExtern =
      showTransferParent && cfg.ShowInternExtern !== false;
    setVisible("section-internextern-internal", showInternExtern);
    setVisible("section-internextern-external", showInternExtern);

    // deposit/withdraw buttons inside money card
    const moneyCard = document.getElementById("section-geldbeheer");
    if (moneyCard) {
      const moneyButtons = moneyCard.querySelector(".button-row");
      if (moneyButtons) {
        moneyButtons.style.display =
          cfg.ShowStortenOpnemen !== false ? "" : "none";
      }
    }
  }

  function scheduleApply() {
    setTimeout(applyKnBxUiConfig, 30);
    setTimeout(applyKnBxUiConfig, 150);
    setTimeout(applyKnBxUiConfig, 400);
  }

  window.addEventListener("message", function (event) {
    const data = event.data || {};
    if (data.uiConfig) {
      window.KNBX_UI_CONFIG = Object.assign(
        {},
        window.KNBX_UI_CONFIG,
        data.uiConfig,
      );
      scheduleApply();
    } else if (data.type === "config" && data.data) {
      window.KNBX_UI_CONFIG = Object.assign(
        {},
        window.KNBX_UI_CONFIG,
        data.data,
      );
      scheduleApply();
    } else if (data.action === "openBank" || data.action === "openATM") {
      if (data.uiConfig) {
        window.KNBX_UI_CONFIG = Object.assign(
          {},
          window.KNBX_UI_CONFIG,
          data.uiConfig,
        );
      }
      scheduleApply();
    }
  });

  document.addEventListener("DOMContentLoaded", function () {
    scheduleApply();

    const app = document.getElementById("app");
    if (app && typeof MutationObserver !== "undefined") {
      const observer = new MutationObserver(function () {
        applyKnBxUiConfig();
      });
      observer.observe(app, {
        childList: true,
        subtree: true,
        attributes: true,
      });
    }
  });
})();

// End of file: ALC
