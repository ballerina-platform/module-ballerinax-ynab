// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.


import ballerina/http;
import ballerina/os;
import ballerina/test;

final boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";
final string serviceUrl = isLiveServer ? "https://api.ynab.com/v1" : "http://localhost:9090";
final string accessToken = isLiveServer ? os:getEnv("YNAB_ACCESS_TOKEN") : "test_token";
final string planId = isLiveServer ? "last-used" : "7b0c2a53-6d1e-4f3a-9a52-1c1d3f6a1e01";

final Client ynab = check new ({
    auth: {token: accessToken},
    httpVersion: isLiveServer ? http:HTTP_2_0 : http:HTTP_1_1
}, serviceUrl);

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetUser() returns error? {
    UserResponse response = check ynab->getUser();
    test:assertTrue(response.data.user.id.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetPlans() returns error? {
    PlanSummaryResponse response = check ynab->getPlans(includeAccounts = true);
    test:assertTrue(response.data.plans.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetPlanById() returns error? {
    PlanDetailResponse response = check ynab->getPlanById(planId);
    test:assertTrue(response.data.plan.name.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetAccounts() returns error? {
    AccountsResponse response = check ynab->getAccounts(planId);
    test:assertTrue(response.data.accounts.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
function testCreateAccount() returns error? {
    AccountResponse response = check ynab->createAccount(planId, {account: {name: "Holiday Fund", 'type: "savings", balance: 100000}});
    test:assertEquals(response.data.account.name, "Holiday Fund");
    test:assertEquals(response.data.account.'type, "savings");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetAccountById() returns error? {
    AccountsResponse accounts = check ynab->getAccounts(planId);
    AccountResponse response = check ynab->getAccountById(planId, accounts.data.accounts[0].id);
    test:assertEquals(response.data.account.id, accounts.data.accounts[0].id);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetCategories() returns error? {
    CategoriesResponse response = check ynab->getCategories(planId);
    test:assertTrue(response.data.categoryGroups.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetCategoryById() returns error? {
    CategoriesResponse categories = check ynab->getCategories(planId);
    string categoryId = categories.data.categoryGroups[0].categories[0].id;
    CategoryResponse response = check ynab->getCategoryById(planId, categoryId);
    test:assertEquals(response.data.category.id, categoryId);
}

@test:Config {groups: ["mock_tests"]}
function testUpdateCategory() returns error? {
    SaveCategoryResponse response = check ynab->updateCategory(planId, "c1d2e3f4-0002-4b6c-9d0e-1f2a3b4c5d6e", {category: {name: "Food"}});
    test:assertEquals(response.data.category.name, "Food");
}

@test:Config {groups: ["mock_tests"]}
function testCreateCategory() returns error? {
    SaveCategoryResponse response = check ynab->createCategory(planId, {category: {name: "Pets", categoryGroupId: "g1h2i3j4-0003-4c7d-8e1f-2a3b4c5d6e7f"}});
    test:assertEquals(response.data.category.name, "Pets");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetPayees() returns error? {
    PayeesResponse response = check ynab->getPayees(planId);
    test:assertTrue(response.data.payees.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetPayeeById() returns error? {
    PayeesResponse payees = check ynab->getPayees(planId);
    string payeeId = payees.data.payees[0].id;
    PayeeResponse response = check ynab->getPayeeById(planId, payeeId);
    test:assertEquals(response.data.payee.id, payeeId);
}

@test:Config {groups: ["mock_tests"]}
function testCreatePayee() returns error? {
    SavePayeeResponse response = check ynab->createPayee(planId, {payee: {name: "Book Store"}});
    test:assertEquals(response.data.payee.name, "Book Store");
}

@test:Config {groups: ["mock_tests"]}
function testUpdatePayee() returns error? {
    SavePayeeResponse response = check ynab->updatePayee(planId, "p1q2r3s4-0004-4d8e-9f2a-3b4c5d6e7f80", {payee: {name: "Corner Shop"}});
    test:assertEquals(response.data.payee.name, "Corner Shop");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetPlanMonths() returns error? {
    MonthSummariesResponse response = check ynab->getPlanMonths(planId);
    test:assertTrue(response.data.months.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetPlanMonth() returns error? {
    MonthDetailResponse response = check ynab->getPlanMonth(planId, "current");
    test:assertTrue(response.data.month.categories.length() >= 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetTransactions() returns error? {
    TransactionsResponse response = check ynab->getTransactions(planId);
    test:assertTrue(response.data.transactions.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
function testCreateTransaction() returns error? {
    SaveTransactionsResponse response = check ynab->createTransaction(planId, {
        'transaction: {accountId: "a1b2c3d4-0001-4a5b-8c9d-0e1f2a3b4c5d", date: "2026-09-20", amount: -23000, payeeName: "Corner Market"}
    });
    test:assertEquals(response.data.transactionIds.length(), 1);
    TransactionDetail[] created = response.data.transactions ?: [];
    test:assertEquals(created[0].amount, -23000);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetTransactionById() returns error? {
    TransactionsResponse transactions = check ynab->getTransactions(planId);
    if transactions.data.transactions.length() == 0 {
        test:assertFail("No transactions found in the plan to fetch by id");
    }
    string transactionId = transactions.data.transactions[0].id;
    TransactionResponse response = check ynab->getTransactionById(planId, transactionId);
    test:assertEquals(response.data.'transaction.id, transactionId);
}

@test:Config {groups: ["mock_tests"]}
function testUpdateTransaction() returns error? {
    TransactionResponse response = check ynab->updateTransaction(planId, "t1u2v3w4-0005-4e9f-8a3b-4c5d6e7f8091", {'transaction: {amount: -50000}});
    test:assertEquals(response.data.'transaction.amount, -50000);
}

@test:Config {groups: ["mock_tests"]}
function testDeleteTransaction() returns error? {
    SaveTransactionsResponse created = check ynab->createTransaction(planId, {
        'transaction: {accountId: "a1b2c3d4-0001-4a5b-8c9d-0e1f2a3b4c5d", date: "2026-09-21", amount: -1000}
    });
    TransactionResponse response = check ynab->deleteTransaction(planId, created.data.transactionIds[0]);
    test:assertTrue(response.data.'transaction.deleted);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetScheduledTransactions() returns error? {
    ScheduledTransactionsResponse response = check ynab->getScheduledTransactions(planId);
    test:assertTrue(response.data.scheduledTransactions.length() >= 0);
}

@test:Config {groups: ["mock_tests"]}
function testCreateScheduledTransaction() returns error? {
    ScheduledTransactionResponse response = check ynab->createScheduledTransaction(planId, {
        scheduledTransaction: {accountId: "a1b2c3d4-0001-4a5b-8c9d-0e1f2a3b4c5d", date: "2026-11-01", amount: -120000, frequency: "monthly"}
    });
    test:assertEquals(response.data.scheduledTransaction.amount, -120000);
}

@test:Config {groups: ["mock_tests"]}
function testGetScheduledTransactionById() returns error? {
    ScheduledTransactionResponse response = check ynab->getScheduledTransactionById(planId, "s1t2u3v4-0006-4fa0-9b4c-5d6e7f8091a2");
    test:assertEquals(response.data.scheduledTransaction.frequency, "monthly");
}

@test:Config {groups: ["mock_tests"]}
function testDeleteScheduledTransaction() returns error? {
    ScheduledTransactionResponse created = check ynab->createScheduledTransaction(planId, {
        scheduledTransaction: {accountId: "a1b2c3d4-0001-4a5b-8c9d-0e1f2a3b4c5d", date: "2026-12-01", amount: -500}
    });
    ScheduledTransactionResponse response = check ynab->deleteScheduledTransaction(planId, created.data.scheduledTransaction.id);
    test:assertTrue(response.data.scheduledTransaction.deleted);
}
