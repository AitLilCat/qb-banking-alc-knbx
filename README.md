# 🏦 KNBX Banking — qb-banking-alc

> Ready to replace the original qb-banking.

A modern banking system for QBCore servers, focused on clean design, performance, and roleplay immersion.

---

## 🎬 Preview

![Intro](/.github/assets/Intro.gif)

---

## 📊 Dashboard

### Light Mode
![Dashboard Light](/main/.github/Assets/DashboardLight.png)

### Dark Mode
![Dashboard Dark](/main/.github/Assets/DashboardDark.png)

Light and dark mode can be toggled in-game via the **settings (⚙️) button**.

---

## 💸 Money Management

![Money Management](/main/.github/Assets/MoneyManagement.gif)

- Account creation and management  
- Deposit, withdraw, transfer  
- Debit card system (PIN-based)  
- Tikkie-style request preview  

---

## 🧠 Technical

- Vue-inspired structure (not a full framework)
- Built for FiveM NUI (HTML / CSS / JS)
- Lightweight and easily extendable

---

## 🌍 Language

Automatic language handling:

- Player preference (saved)
- Server config (`Config.Branding.country`)
- Fallback system

Supported:
- EN / NL

---

## ⚙️ Configuration

```lua
Config.Branding = {
    name = 'KNBX.',
    shortName = 'KNBX',
    country = 'EN'
}
