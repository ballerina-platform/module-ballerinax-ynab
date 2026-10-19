import ballerina/io;
import ballerinax/ynab;

configurable string accessToken = ?;
configurable string planId = "last-used";
// The name of the account that the expense is charged to.
configurable string accountName = ?;
// The name of the budget category to look up for reference.
configurable string categoryName = ?;
// The payee name and amount (in milliunits, negative for an outflow) of the expense.
configurable string payeeName = ?;
configurable int amount = ?;
// The transaction date as an ISO date (YYYY-MM-DD).
configurable string date = ?;
// Set to true to actually create the transaction; the workflow only previews it otherwise.
configurable boolean createExpense = false;

public function main() returns error? {
    if amount >= 0 {
        return error(string `An expense amount must be negative, got ${amount}`);
    }
    ynab:Client ynabClient = check new ({auth: {token: accessToken}});

    // Step 1: Resolve the account the expense is charged to.
    ynab:AccountsResponse accounts = check ynabClient->getAccounts(planId);
    ynab:Account[] matchingAccounts = from ynab:Account account in accounts.data.accounts
        where account.name == accountName && !account.closed && !account.deleted
        select account;
    if matchingAccounts.length() != 1 {
        return error(string `Expected exactly one open account named ${accountName}, found ${matchingAccounts.length()}`);
    }
    string accountId = matchingAccounts[0].id;

    // Step 2: Resolve the budget category.
    ynab:CategoriesResponse categories = check ynabClient->getCategories(planId);
    string[] categoryIds = from ynab:CategoryGroupWithCategories group in categories.data.categoryGroups
        from ynab:Category category in group.categories
        where category.name == categoryName && !category.deleted
        select category.id;
    if categoryIds.length() != 1 {
        return error(string `Expected exactly one category named ${categoryName}, found ${categoryIds.length()}`);
    }
    string categoryId = categoryIds[0];

    // Step 3: Record the expense, only when explicitly enabled.
    if createExpense {
        ynab:SaveTransactionsResponse created = check ynabClient->createTransaction(planId, {
            'transaction: {
                accountId,
                date,
                amount,
                payeeName,
                categoryId,
                memo: "Recorded by the expense recording workflow",
                cleared: "uncleared"
            }
        });
        io:println("Created transactions: ", created.data.transactionIds);
    } else {
        io:println(string `Preview: ${toAmount(amount)} to ${payeeName} on ${date} from ${accountName} (${categoryName})`);
    }

    // Step 4: List the account's recent transactions since the expense date.
    ynab:TransactionsResponse transactions = check ynabClient->getTransactions(planId, sinceDate = date);
    foreach ynab:TransactionDetail txn in transactions.data.transactions {
        if txn.accountId == accountId && !txn.deleted {
            anydata payee = txn?.payeeName;
            io:println(string `${txn.date}: ${toAmount(txn.amount)} ${payee is string ? payee : "unknown payee"}`);
        }
    }
}

// Converts YNAB milliunits into a currency amount.
function toAmount(int milliunits) returns decimal => <decimal>milliunits / 1000d;
