# Monthly budget summary

This example lists the open accounts of a YNAB plan with their balances, summarises the income, budgeted and activity amounts of a month, and flags categories that are overspent in that month.

## Prerequisites

- Ballerina Swan Lake 2201.12.0 or later
- Create a `Config.toml` in this directory:
  ```toml
  accessToken = "<your-personal-access-token>"
  planId = "last-used"
  month = "current"
  ```

## Run the example

```bash
bal run
```
