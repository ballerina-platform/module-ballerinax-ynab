# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Remote methods for operations 1.5.2 did not cover:
  - Categories and category groups: `createCategory`, `updateCategory`, `createCategoryGroup` and `updateCategoryGroup`.
  - Payees: `createPayee` and `updatePayee`.
  - Money movements: `getMoneyMovements`, `getMoneyMovementsByMonth`, `getMoneyMovementGroups` and `getMoneyMovementGroupsByMonth`.
  - Transactions: `deleteTransaction` and `getTransactionsByMonth`.
  - Scheduled transactions: `createScheduledTransaction`, `updateScheduledTransaction` and `deleteScheduledTransaction`.
- Typed request payloads for every method that sends a body, such as `PostAccountWrapper`, `PostTransactionsWrapper`, `PutTransactionWrapper`, `PatchTransactionsWrapper` and `PatchMonthCategoryWrapper`, and for the new methods (`PostCategoryWrapper`, `PatchCategoryWrapper`, `PostCategoryGroupWrapper`, `PatchCategoryGroupWrapper`, `PostPayeeWrapper`, `PatchPayeeWrapper`, `PostScheduledTransactionWrapper` and `PutScheduledTransactionWrapper`).
- A `*Queries` record for each operation that takes query parameters, such as `GetTransactionsQueries` and `GetPlansQueries`.
- The `untilDate` query parameter on `getTransactions`, `getTransactionsByAccount`, `getTransactionsByCategory` and `getTransactionsByPayee`.
- Types for fixed sets of values: `AccountType`, `SaveAccountType`, `TransactionClearedStatus`, `TransactionFlagColor` and `ScheduledTransactionFrequency`.
- New record fields, among them the `*Formatted` and `*Currency` amount fields (such as `Account.balanceFormatted` and `TransactionSummary.amountCurrency`), the debt fields of `Account` (`debtOriginalBalance`, `debtInterestRates`, `debtMinimumPayments` and `debtEscrowAmounts`) and `lastReconciledAt`, the goal fields of `Category` (such as `goalCadence`, `goalDay` and `goalTargetDate`), `flagName` on transactions and scheduled transactions, and `CategoryGroup.internal`.
- An optional `headers` parameter on every remote method, for sending extra request headers.
- New `ConnectionConfig` fields, taken from `http:ClientConfiguration`: `followRedirects`, `cookieConfig`, `socketConfig` and `laxDataBinding`.

### Changed

- **Breaking:** YNAB budgets are now called plans. The methods and records named after budgets are renamed, and every method under a plan takes a `planId` path parameter (was `budgetId`):

    | 1.5.2 | 2.0.0 |
    |---|---|
    | `getBudgets` | `getPlans` |
    | `getBudgetById` | `getPlanById` |
    | `getBudgetSettingsById` | `getPlanSettingsById` |
    | `getBudgetMonths` | `getPlanMonths` |
    | `getBudgetMonth` | `getPlanMonth` |
    | `BudgetSummary` | `PlanSummary` |
    | `BudgetSummaryResponse` | `PlanSummaryResponse` |
    | `BudgetDetail` | `PlanDetail` |
    | `BudgetDetailResponse` | `PlanDetailResponse` |
    | `BudgetSettings` | `PlanSettings` |
    | `BudgetSettingsResponse` | `PlanSettingsResponse` |

    The response data follows: `PlanSummaryResponseData` has `plans` and `defaultPlan` (were `budgets` and `default_budget`), and `PlanDetailResponseData` has `plan` (was `budget`).
- **Breaking:** the methods that send a body take a typed payload (was `byte[]`):

    ```ballerina
    // 1.5.2
    ynab:SaveTransactionsResponse res = check ynab->createTransaction(budgetId, payload.toJsonString().toBytes());
    ```

    ```ballerina
    // 2.0.0
    ynab:SaveTransactionsResponse res = check ynab->createTransaction(planId, {'transaction: {accountId, date: "2026-01-15", amount: -12500}});
    ```

- **Breaking:** query parameters are no longer positional. `lastKnowledgeOfServer`, `sinceDate`, `type` and `includeAccounts` are passed as named arguments, or as the operation's `*Queries` record. `type` is `"uncategorized"|"unapproved"` (was `string`).
- **Breaking:** the transaction payload records are replaced. `SaveTransaction` is now `NewTransaction` (for creating) and `ExistingTransaction` (for updating), both built on `SaveTransactionWithOptionalFields`, in which `accountId`, `date` and `amount` are optional. `UpdateTransaction` is now `SaveTransactionWithIdOrImportId`.
- **Breaking:** the response data records are renamed to Pascal case, for example `AccountsresponseData` is now `AccountsResponseData` and `TransactionsresponseData` is now `TransactionsResponseData`.
- **Breaking:** most record fields use camel case, mapped to the API's snake-case JSON names with `@jsondata:Name`. For example, `TransactionSummary.account_id` is now `accountId`, and `Account.cleared_balance` is now `clearedBalance`.
- **Breaking:** fields the API can return as `null`, such as `memo`, `payeeId`, `categoryId`, `transferAccountId`, `note` and the `Category` goal fields, are `anydata` (were `string` or `int`).
- **Breaking:** fields with a fixed set of values use the new types: `Account.type` is an `AccountType`, `SaveAccount.type` a `SaveAccountType`, `cleared` a `TransactionClearedStatus`, `flagColor` a `TransactionFlagColor`, `ScheduledTransactionSummary.frequency` a union of its values, `Category.goalType` a union of its values, and `HybridTransaction.type` is `"transaction"|"subtransaction"` (all were `string`).
- **Breaking:** `Account`, `Category`, `MonthSummary`, `MonthDetail`, `TransactionSummary`, `SubTransaction`, `ScheduledTransactionSummary` and `ScheduledSubTransaction` include a base record (such as `AccountBase`) that holds their original fields. `PlanDetail` lists the base records (for example `TransactionSummaryBase[] transactions`).
- **Breaking:** the default `serviceUrl` is `https://api.ynab.com/v1` (was `https://api.youneedabudget.com/v1`).
- **Breaking:** `ConnectionConfig.http1Settings` is now `http:ClientHttp1Settings` (was the connector's own `ClientHttp1Settings`).
- `CurrencyFormat.decimal_digits` is an `int:Signed32` (was `int`).
- `ConnectionConfig.timeout` defaults to 30 seconds (was 60).

### Removed

- **Breaking:** `bulkCreateTransactions`, with the `BulkTransactions`, `BulkResponse`, `BulkresponseData` and `BulkresponseDataBulk` records. Use `createTransaction` with a `transactions` array.
- **Breaking:** the `SaveAccountWrapper`, `SaveMonthCategoryWrapper`, `SaveTransactionWrapper`, `SaveTransactionsWrapper` and `UpdateTransactionsWrapper` records. Use the `Post*`, `Put*` and `Patch*` wrappers.
- **Breaking:** the `ErrorResponse` and `ErrorDetail` records. No method returned either.
- **Breaking:** the connector's own `ClientHttp1Settings` and `ProxyConfig` records. Use `http:ClientHttp1Settings` and `http:ProxyConfig` instead.
