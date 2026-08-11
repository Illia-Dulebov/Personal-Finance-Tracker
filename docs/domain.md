# Domain

---

## Expense

### Represents
A record of money that was spent.

### State
- identifier
- amount
- currency
- date
- category
- payment method
- description
- receipt
- original exchange rate / converted value
- recurring rule reference (optional)

### Behaviour
- validate its own basic invariants
- represent a specific expense occurrence

### Relationships
- Expenses are related to recurring rules
- Expenses references Category


## Currency

### Represents
A classification used for the currency identification

### State
- identifier
- country
- label
- full name
- short name

### Behaviour
- none specific identified yet

### Relationships
- Currency must be referenced to the Expense


## Category

### Represents
A classification used to group expenses.

### State
- identifier
- name
- description
- distinguishing sign - emoji

### Behaviour
- validate its own basic invariants

### Relationships
- every expense must have category


## Budget

### Represents
An entity that shows monthly limit for certain category

### State
- identifier
- amount
- category

### Behaviour
- validate its amount - non negative


## Recurring rule

### Represents
A template for creating expenses in periodic time

### State
- identifier
- amount
- currency
- number of day - date
- category
- payment method
- description
- period

### Behaviour
- validate its own invariants

### Relationships
- relates to expenses by creating them
