# Personal Finance Tracker — Business Rules

This document contains main restrictions for app workflows which includes data manipulation,
currency management, etc

---

## Currency conversion

- Expenses store original amount and currency.
- Conversion rate is captured at expense creation.
- Historical expenses are not recalculated when exchange rates change.

Implementation: Expense will contain necessary historical info as exchange currency, base currency

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