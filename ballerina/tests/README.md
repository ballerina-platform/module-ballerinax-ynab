# Running Tests

## Prerequisites

To run the tests against the live YNAB API you need a personal access token for a YNAB account that has at least one plan with accounts, categories, payees and transactions.

## Test environments

The suite runs against a local mock service by default. Set `IS_LIVE_SERVER=true` to run the live-capable tests against `https://api.ynab.com/v1`. Tests that create, update or delete data run against the mock service only.

| Variable | Used for |
|---|---|
| `IS_LIVE_SERVER` | Set to `true` to use the live API instead of the mock service |
| `YNAB_ACCESS_TOKEN` | Personal access token sent as a bearer token |

## Running the tests

```bash
# Mock tests (default)
bal test --groups mock_tests

# Live tests
IS_LIVE_SERVER=true YNAB_ACCESS_TOKEN=<token> bal test --groups live_tests
```
