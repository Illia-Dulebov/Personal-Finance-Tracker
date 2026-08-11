# Personal Finance Tracker — Project Roadmap

This document contains main flows of how user add expenses, sees them and how user is interacting
with the MVP application

## App entry flow

---

1. User opens application.
2. User sees the loading splash screen
3. App loads necessary dependencies and data - Firebase, local storage, etc
4. User sees the main screen of the app with dashboard which contains the list of latest expenses
5. User can manipulate with expenses as he likes - add, delete, update.

Possible future features and issues:

1. Authentication is not required for MVP, later it could be added for syncs and giving more
   opportunities - statistics, budgets, etc.
2. Different currency support - during registration, user could pick 1 or more currencies he wants
   to work with

---

## Screens list

### Home Screen - Dashboard

* Purpose: Main screen of the app
* Shows: Expenses list starting from latest
* Actions: Add expense, period picking, bottom navigation bar buttons, delete expense, update
  expense, filters manipulation
* Navigation: Add expense, Statistics, Budget

### Add Expense Screen

* Purpose: Adding expense
* Shows: Input fields for the expense
* Actions: Filling input fields, submitting the expense
* Navigation: Home Screen

### Edit Expense Screen

* Purpose: Editing expense
* Shows: Input fields with current expense info
* Actions: Editing input fields, change the expense
* Navigation: Home Screen

### Statistics screen

* Purpose: Detailed expense analysis in reports and charts
* Shows: Charts, tables, reports by periods, categories, etc.
* Actions: Filters picking - period, category, currency
* Navigation: Home Screen, Budget

### Budget screen

* Purpose: Monthly budget manipulating and adding recurring expenses rules
* Shows: Tab with main categories and its budgets, list with short info expenses for this budget,
  tab with recurring expenses rules
* Actions: Changing categories budgets, manipulating with recurring expenses rules
* Navigation: Home Screen, Statistics

---

## User actions

### Add Expense

Goal:
User wants to record new expense

Starting point:
Home screen

Flow:

1. User opens the "Add expense"
2. User enters amount - obliged
3. User enters currency - obliged
4. User enters description(optional)
5. User enters category - obliged
6. User enters payment method - obliged
7. User enters date(if not picked, will be set to current)
8. User attach receipt or its photo(optional)
9. User confirms submitting expense

Expected result:

- Expense is correctly validated.
- Expense is created.
- Expense appears in dashboard.
- Related totals are updated: budget, statistics

### Edit Expense

Goal:
User wants to edit existing expense

Starting point:
Home screen

Flow:

1. User opens the "Edit expense"
2. User edit amount
3. User edits description
4. User edits category
5. User edits payment method
6. User edits date
7. User attach receipt or its photo
8. User confirms editing expense

Expected result:

- Expense is correctly validated.
- Expense is edited.
- Related totals are updated: budget, statistics


### Budget setting

Goal:
User wants to put the budgets for main categories

Starting point:
Budget screen

Flow:

1. User opens the "Budget"
2. User selects category
3. User inputs necessary amount

Expected result:

- Budget amount is correctly validated.
- Budget amounts edits automatically when action type is done.
- If sum of expenses is more than entered budget, the budget number will become red

### Recurring rule setting

Goal:
User wants to create recurring expense

Starting point:
Budget screen

Flow:

1. User opens the "Budget"
2. User opens "Recurring expenses" tab
3. User press button "Add recurring expense"
4. User inputs the Expense without receipt and date
5. User inputs checkmark of the period - monthly, weekly or daily
6. User inputs the day of the expense happening
7. User presses confirm button

Expected result:

- Recurring rule is correctly validated.
- Recurring rule is created
- Recurring rules are checked during the app entrance
- If it is due date of recurring expense, the app will automatically create this expense

### Recurring rule deleting

Goal:
User wants to delete recurring expense rule

Starting point:
Budget screen

Flow:

1. User opens the "Budget"
2. User opens "Recurring expenses" tab
3. User press button "Delete recurring expense" near existing recurring rule

Expected result:

- Recurring rule is created
- Deleted recurring rule is not performed during app entrance

### Statistics

Goal:
User wants to discover statistics data

Starting point:
Statistics screen

Flow:

1. User opens the "Statistics"
2. User uses necessary filters
3. User discover statistics data

Expected result:

- Charts, reports and overall data is correctly shown
- Filters are applied correctly to the screen data

### Statistics - make report

Goal:
User wants to make report

Starting point:
Statistics screen

Flow:

1. User opens the "Statistics"
2. User uses necessary filters
3. User presses button "Make report"
4. Report is downloaded to the device or user can share it

Expected result:

- Filters are applied correctly to the data
- Report is downloaded successfully
- Report is shared successfully



