# Personal Finance Tracker — Business Rules

This document contains main restrictions for app workflows which includes data manipulation,
currency management, etc

---

## Currency conversion

- Expenses store original amount and currency.
- ALL is the default/base currency for MVP conversions.
- MVP supports ALL, EUR, and USD with configurable static reference rates.
- Reference rates are approximate and are not live market rates.
- The applied conversion rate, converted amount, base currency, and rate capture timestamp are stored with the expense.
- Historical expenses are not recalculated when exchange rates change.

The capture timestamp records when the app applied the rate; it is not the expense date or a rate-provider validity date.
Legacy expenses in ALL can be converted exactly at 1:1. Legacy foreign-currency expenses without a saved rate retain their original amount and have no inferred converted value.

---

## Expense editing

Allowed:

- amount
- description
- category
- date
- payment method
- receipt info - photo or document

Currency:
Once an expense is persisted, its original currency becomes immutable

Historical conversion:
Never recalculated automatically.

---

## Budget

- Budgets are monthly.
- The period follows calendar months.
- A budget applies from the first day to the last day of the month.
- All budgets use the default currency.
- Budget amounts are stored in the default currency.
- Expenses in other currencies are converted to the budget currency using their historical conversion information.

If a category has expenses but no budget exists:

- Expenses are still tracked normally.
- Category spending is displayed.
- No remaining amount is calculated.
- UI indicates that no budget limit is configured.

---

## Recurring expenses:

- A recurring expense is a template for generating future expenses.
- Generated expenses behave like normal expenses.
- Recurring rules are not counted as spending until an expense is created.
- Recurring rules will have lastGeneratedDate and nextGenerationDate for better time manipulation
- If nextGenerationDate is in the past: user opened app after this date, the app will create every
  expense for the period that took place