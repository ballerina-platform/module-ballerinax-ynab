# Expense recording workflow

This example resolves an account and a budget category by name, optionally records an expense against them, and then lists the account's transactions since the expense date. The expense is only created when `createExpense` is set to `true`; otherwise the workflow prints a preview.

## Prerequisites

- Ballerina Swan Lake 2201.12.0 or later
- Create a `Config.toml` in this directory:
  ```toml
  accessToken = "<your-personal-access-token>"
  planId = "last-used"
  accountName = "<account-name>"
  categoryName = "<category-name>"
  payeeName = "<payee-name>"
  amount = -25000
  date = "2026-09-20"
  createExpense = false
  ```

## Run the example

```bash
bal run
```
