## Overview

[YNAB](https://www.ynab.com/) (You Need A Budget) is a personal budgeting platform built around giving every dollar a job. This connector wraps version 1.87.0 of the YNAB REST API and lets Ballerina applications read and manage budget plans, accounts, categories, payees, months, money movements, transactions and scheduled transactions.

### Key features

- Read plans and plan settings, with delta requests based on server knowledge
- Manage accounts, categories and category groups, including monthly category budgets
- Create, update, import and delete transactions and scheduled transactions
- Browse payees and payee locations, and create or rename payees
- Review monthly budget summaries and money movements

## Setup guide

To use the connector you need a YNAB account and a personal access token.

1. Sign in to [YNAB](https://app.ynab.com/).
2. Open **Account Settings** and go to **Developer Settings**.
3. Under **Personal Access Tokens**, choose **New Token**, enter your password and copy the generated token. It is shown only once.

## Quickstart

To use the `ynab` connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

```ballerina
import ballerinax/ynab;
```

### Step 2: Instantiate a new connector

Create a `Config.toml` file with your access token:

```toml
accessToken = "<your-personal-access-token>"
```

Then create a client in your `.bal` file:

```ballerina
configurable string accessToken = ?;

final ynab:Client ynabClient = check new ({
    auth: {
        token: accessToken
    }
});
```

### Step 3: Invoke the connector operation

```ballerina
public function main() returns error? {
    ynab:PlanSummaryResponse _ = check ynabClient->getPlans();
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The `YNAB` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-ynab/tree/main/examples/), covering the following use cases:

* [Monthly budget summary](../examples/monthly_budget_summary/monthly_budget_summary.md) - lists open accounts and balances, summarises a month and flags overspent categories.
* [Expense recording workflow](../examples/expense_recording_workflow/expense_recording_workflow.md) - resolves an account and category by name and optionally records an expense.
