# Ballerina YNAB connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-ynab/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-ynab/actions/workflows/ci.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-ynab.svg)](https://github.com/ballerina-platform/module-ballerinax-ynab/commits/master)
[![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/ynab.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%ynab)

## Overview

[YNAB](https://www.ynab.com/) (You Need A Budget) is a personal budgeting platform built around giving every dollar a job. This connector wraps version 1.87.0 of the YNAB REST API and lets Ballerina applications read and manage budget plans, accounts, categories, payees, months, money movements, transactions and scheduled transactions.

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

* [Monthly budget summary](examples/monthly_budget_summary/monthly_budget_summary.md) - lists open accounts and balances, summarises a month and flags overspent categories.
* [Expense recording workflow](examples/expense_recording_workflow/expense_recording_workflow.md) - resolves an account and category by name and optionally records an expense.

## Build from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

    * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

4. Export Github Personal access token with read package permissions as follows,

    ```bash
    export packageUser=<Username>
    export packagePAT=<Personal access token>
    ```

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To run tests against different environments:

   ```bash
   ./gradlew clean test -Pgroups=<Comma separated groups/test cases>
   ```

5. To debug the package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:

    ```bash
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

8. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`ynab` package](https://central.ballerina.io/ballerinax/ynab/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
