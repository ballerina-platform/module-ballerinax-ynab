# Examples

The `ballerinax/ynab` connector provides practical examples illustrating usage in various scenarios.

| Example | Description |
|---|---|
| [monthly_budget_summary](./monthly_budget_summary/monthly_budget_summary.md) | Lists open accounts, summarises a month and flags overspent categories. |
| [expense_recording_workflow](./expense_recording_workflow/expense_recording_workflow.md) | Resolves an account and category by name and optionally records an expense. |

## Prerequisites

1. A YNAB personal access token for the `ballerinax/ynab` connector.
2. A `Config.toml` in each example directory, as described in that example's document.

## Running an example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the examples with the local module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
