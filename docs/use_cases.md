## Create Expense

### Goal
- Creating and persisting the expense entity

### Trigger
- User submits the expense creation form.

### Input
- Input data includes the expense entity values: amount, currency, date, category, etc.

### Preconditions
- Required expense data is available.

### Main flow
1. Receive expense input data
2. Validate the input according to applicable business rules
3. Create the Expense entity
4. Persist the Expense
5. Return the result of the operation

### Business rules
- Required expense fields must be valid
- Expense amount must satisfy the defined amount constraints
- Historical currency conversion information is captured when the expense is created

### Result
- The expense instance is created correctly and persisted

### Failure cases
- Required input is missing
- Input violates business rules
- Expense cannot be persisted

---

## Update Expense

### Goal
- Update the expense entity with new data

### Trigger
- User submits the expense edit form.

### Input
Input data includes only the values that could be changed by business rules:
1. amount
2. date 
3. category
4. payment method
5. description
6. receipt

### Preconditions
- Necessary expense data is available to change the existing.

### Main flow
1. Receive expense input data that will replace existing
2. Validate the input according to applicable business rules
3. Updates the Expense entity
4. Persist the updated Expense
5. Return the result of the operation

### Business rules
- Required expense fields must be valid
- Expense amount must satisfy the defined amount constraints

### Result
- The expense instance is updated correctly and persisted

### Failure cases
- Required input is missing
- Input violates business rules
- Expense cannot be persisted

---

## Delete Expense

### Goal
- Delete the expense entity

### Trigger
- User submits the expense delete action.

### Input
- Necessary expense id

### Preconditions
- The expense is present in the persisted data

### Main flow
1. Receives expense id
2. Expense is found in the persisted data
3. Expense is deleted
4. Persist the updated expenses data
5. Return the result of the operation

### Business rules
None particular

### Result
- The expense instance is deleted successfully

### Failure cases
- The deletion flow was canceled by input
- Expense cannot be found in the existing data
- Expense deletion cannot be persisted

---

## Update Budget

### Goal
- Setting the budget limit for certain category

### Trigger
- User submits the category budgets editing

### Input
- Amount of budget for a month

### Preconditions
None

### Main flow
1. Receives the amount input data
2. Validate the input according to applicable business rules
3. Budget amount is updated
4. Persist the budget data
5. Return the result of the operation

### Business rules
- Budgets are monthly.
- A budget applies from the first day to the last day of the month.
- All budgets use the default currency.
- Expenses in other currencies are converted to the budget currency using their historical conversion information.

### Result
- The budget amount is set successfully

### Failure cases
- The input data is not valid
- Budget setting cannot be persisted

---

## Recurring rule creating

### Goal
- Setting the budget limit for certain category

### Trigger
- User submits the category budgets editing

### Input
- Amount of budget for a month

### Preconditions
None

### Main flow
1. Receives the amount input data
2. Validate the input according to applicable business rules
3. Budget amount is updated
4. Persist the budget data
5. Return the result of the operation

### Business rules
- Budgets are monthly.
- A budget applies from the first day to the last day of the month.
- All budgets use the default currency.
- Expenses in other currencies are converted to the budget currency using their historical conversion information.

### Result
- The budget amount is set successfully

### Failure cases
- The input data is not valid
- Budget setting cannot be persisted


