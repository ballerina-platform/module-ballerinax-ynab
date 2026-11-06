import ballerina/io;
import ballerinax/ynab;

configurable string accessToken = ?;
// The plan to report on; "last-used" selects the plan most recently used in YNAB.
configurable string planId = "last-used";
// The month to report on, as an ISO date (the first day of the month) or "current".
configurable string month = "current";

public function main() returns error? {
    ynab:Client ynabClient = check new ({auth: {token: accessToken}});

    // Step 1: Find the plan and list its open accounts.
    ynab:PlanSummaryResponse plans = check ynabClient->getPlans();
    io:println("Plans available: ", plans.data.plans.length());

    ynab:AccountsResponse accounts = check ynabClient->getAccounts(planId);
    int totalBalance = 0;
    foreach ynab:Account account in accounts.data.accounts {
        if account.closed || account.deleted {
            continue;
        }
        totalBalance += account.balance;
        io:println(string `Account ${account.name}: ${toAmount(account.balance)}`);
    }
    io:println("Total balance across open accounts: ", toAmount(totalBalance));

    // Step 2: Summarise the budget for the chosen month.
    ynab:MonthDetailResponse monthDetail = check ynabClient->getPlanMonth(planId, month);
    ynab:MonthDetail summary = monthDetail.data.month;
    io:println(string `Month ${summary.month}: income ${toAmount(summary.income)}, budgeted ${toAmount(summary.budgeted)}, activity ${toAmount(summary.activity)}`);

    // Step 3: Flag categories that are overspent this month.
    foreach ynab:Category category in summary.categories {
        if category.deleted || category.hidden || category.balance >= 0 {
            continue;
        }
        io:println(string `Overspent: ${category.name} by ${toAmount(-category.balance)}`);
    }
}

// Converts YNAB milliunits into a currency amount.
function toAmount(int milliunits) returns decimal => <decimal>milliunits / 1000d;
