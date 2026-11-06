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

listener http:Listener ep0 = new (9090);

const string MISSING_ID = "00000000-0000-0000-0000-000000000000";
const string PLAN_ID = "7b0c2a53-6d1e-4f3a-9a52-1c1d3f6a1e01";
const string ACCOUNT_ID = "a1b2c3d4-0001-4a5b-8c9d-0e1f2a3b4c5d";
const string CATEGORY_ID = "c1d2e3f4-0002-4b6c-9d0e-1f2a3b4c5d6e";
const string CATEGORY_GROUP_ID = "g1h2i3j4-0003-4c7d-8e1f-2a3b4c5d6e7f";
const string PAYEE_ID = "p1q2r3s4-0004-4d8e-9f2a-3b4c5d6e7f80";
const string TRANSACTION_ID = "t1u2v3w4-0005-4e9f-8a3b-4c5d6e7f8091";
const string SCHEDULED_ID = "s1t2u3v4-0006-4fa0-9b4c-5d6e7f8091a2";

function notFound(string name, string detail) returns ErrorResponseNotFound => {
    body: {'error: {id: "404.2", name: name, detail: detail}}
};

function badRequest(string detail) returns ErrorResponseBadRequest => {
    body: {'error: {id: "400", name: "bad_request", detail: detail}}
};

function sampleAccount(string id = ACCOUNT_ID, string name = "Everyday Checking") returns Account => {
    id,
    name,
    'type: "checking",
    onBudget: true,
    closed: false,
    note: "Primary spending account",
    balance: 250750,
    clearedBalance: 248250,
    unclearedBalance: 2500,
    transferPayeeId: PAYEE_ID,
    deleted: false,
    directImportLinked: true,
    directImportInError: false,
    balanceFormatted: "$250.75"
};

function sampleCategory(string id = CATEGORY_ID, string name = "Groceries") returns Category => {
    id,
    categoryGroupId: CATEGORY_GROUP_ID,
    categoryGroupName: "Everyday Expenses",
    name,
    hidden: false,
    internal: false,
    deleted: false,
    budgeted: 400000,
    activity: -125500,
    balance: 274500,
    note: "Weekly food shopping",
    balanceFormatted: "$274.50"
};

function samplePayee(string id = PAYEE_ID, string name = "Corner Market") returns Payee => {
    id,
    name,
    deleted: false,
    transferAccountId: ()
};

function sampleTransaction(string id = TRANSACTION_ID, int amount = -45990) returns TransactionDetail => {
    id,
    date: "2026-09-15",
    amount,
    memo: "Weekly groceries",
    cleared: "cleared",
    approved: true,
    flagColor: "blue",
    accountId: ACCOUNT_ID,
    accountName: "Everyday Checking",
    payeeId: PAYEE_ID,
    payeeName: "Corner Market",
    categoryId: CATEGORY_ID,
    categoryName: "Groceries",
    deleted: false,
    subtransactions: [],
    amountFormatted: "-$45.99"
};

function sampleScheduled(string id = SCHEDULED_ID) returns ScheduledTransactionDetail => {
    id,
    dateFirst: "2026-10-01",
    dateNext: "2026-11-01",
    frequency: "monthly",
    amount: -120000,
    memo: "Monthly rent",
    flagColor: "red",
    accountId: ACCOUNT_ID,
    accountName: "Everyday Checking",
    payeeId: PAYEE_ID,
    payeeName: "Corner Market",
    categoryId: CATEGORY_ID,
    categoryName: "Rent",
    deleted: false,
    subtransactions: [],
    amountFormatted: "-$120.00"
};

function sampleMonth(string month = "2026-09-01") returns MonthSummary => {
    month,
    note: "September budget",
    income: 520000,
    budgeted: 480000,
    activity: -310000,
    toBeBudgeted: 40000,
    ageOfMoney: 32,
    deleted: false
};

service / on ep0 {
    # Delete a scheduled transaction
    #
    # + planId - The id of the plan
    # + scheduledTransactionId - The id of the scheduled transaction
    # + return - The scheduled transaction was successfully deleted, or the scheduled transaction was not found
    resource function delete plans/[string planId]/scheduled_transactions/[string scheduledTransactionId]() returns ScheduledTransactionResponse|ErrorResponseNotFound {
        if scheduledTransactionId == MISSING_ID {
            return notFound("resource_not_found", "Scheduled transaction not found");
        }
        ScheduledTransactionDetail detail = sampleScheduled(scheduledTransactionId);
        detail.deleted = true;
        return {data: {scheduledTransaction: detail}};
    }

    # Delete a transaction
    #
    # + planId - The id of the plan
    # + transactionId - The id of the transaction
    # + return - The transaction was successfully deleted, or the transaction was not found
    resource function delete plans/[string planId]/transactions/[string transactionId]() returns TransactionResponse|ErrorResponseNotFound {
        if transactionId == MISSING_ID {
            return notFound("resource_not_found", "Transaction not found");
        }
        TransactionDetail detail = sampleTransaction(transactionId);
        detail.deleted = true;
        return {data: {serverKnowledge: 101, 'transaction: detail}};
    }

    # Get all plans
    #
    # + includeAccounts - Whether to include the list of plan accounts
    # + return - The list of plans, or no plans were found
    resource function get plans(@http:Query {name: "include_accounts"} boolean? includeAccounts) returns PlanSummaryResponse|ErrorResponseNotFound {
        PlanSummary plan = {
            id: PLAN_ID,
            name: "Household Budget",
            lastModifiedOn: "2026-09-30T10:15:30Z",
            firstMonth: "2026-01-01",
            lastMonth: "2026-12-01"
        };
        if includeAccounts is true {
            plan.accounts = [sampleAccount()];
        }
        return {data: {plans: [plan], defaultPlan: plan}};
    }

    # Get a plan
    #
    # + planId - The id of the plan
    # + lastKnowledgeOfServer - The starting server knowledge
    # + return - The requested plan, or the specified plan was not found
    resource function get plans/[string planId](@http:Query {name: "last_knowledge_of_server"} int? lastKnowledgeOfServer) returns PlanDetailResponse|ErrorResponseNotFound {
        if planId == MISSING_ID {
            return notFound("resource_not_found", "Plan not found");
        }
        return {
            data: {
                serverKnowledge: 100,
                plan: {
                    id: PLAN_ID,
                    name: "Household Budget",
                    lastModifiedOn: "2026-09-30T10:15:30Z",
                    firstMonth: "2026-01-01",
                    lastMonth: "2026-12-01",
                    accounts: [sampleAccount()],
                    payees: [samplePayee()]
                }
            }
        };
    }

    # Get all accounts
    #
    # + planId - The id of the plan
    # + lastKnowledgeOfServer - The starting server knowledge
    # + return - The list of requested accounts, or no accounts were found
    resource function get plans/[string planId]/accounts(@http:Query {name: "last_knowledge_of_server"} int? lastKnowledgeOfServer) returns AccountsResponse|ErrorResponseNotFound {
        return {data: {serverKnowledge: 100, accounts: [sampleAccount(), sampleAccount("a1b2c3d4-0010-4a5b-8c9d-0e1f2a3b4c5d", "Holiday Savings")]}};
    }

    # Get an account
    #
    # + planId - The id of the plan
    # + accountId - The id of the account
    # + return - The requested account, or the requested account was not found
    resource function get plans/[string planId]/accounts/[string accountId]() returns AccountResponse|ErrorResponseNotFound {
        if accountId == MISSING_ID {
            return notFound("resource_not_found", "Account not found");
        }
        return {data: {account: sampleAccount(accountId)}};
    }

    # Get all categories
    #
    # + planId - The id of the plan
    # + lastKnowledgeOfServer - The starting server knowledge
    # + return - The list of requested categories, or no categories were found
    resource function get plans/[string planId]/categories(@http:Query {name: "last_knowledge_of_server"} int? lastKnowledgeOfServer) returns CategoriesResponse|ErrorResponseNotFound {
        CategoryGroupWithCategories group = {
            id: CATEGORY_GROUP_ID,
            name: "Everyday Expenses",
            hidden: false,
            deleted: false,
            internal: false,
            categories: [sampleCategory(), sampleCategory("c1d2e3f4-0020-4b6c-9d0e-1f2a3b4c5d6e", "Dining Out")]
        };
        return {data: {serverKnowledge: 100, categoryGroups: [group]}};
    }

    # Get a category
    #
    # + planId - The id of the plan
    # + categoryId - The id of the category
    # + return - The requested category, or the requested category was not found
    resource function get plans/[string planId]/categories/[string categoryId]() returns CategoryResponse|ErrorResponseNotFound {
        if categoryId == MISSING_ID {
            return notFound("resource_not_found", "Category not found");
        }
        return {data: {category: sampleCategory(categoryId)}};
    }

    # Get all plan months
    #
    # + planId - The id of the plan
    # + lastKnowledgeOfServer - The starting server knowledge
    # + return - The list of plan months, or no plan months were found
    resource function get plans/[string planId]/months(@http:Query {name: "last_knowledge_of_server"} int? lastKnowledgeOfServer) returns MonthSummariesResponse|ErrorResponseNotFound {
        return {data: {serverKnowledge: 100, months: [sampleMonth(), sampleMonth("2026-08-01")]}};
    }

    # Get a plan month
    #
    # + planId - The id of the plan
    # + month - The plan month in ISO format
    # + return - The plan month detail, or the plan month was not found
    resource function get plans/[string planId]/months/[string month]() returns MonthDetailResponse|ErrorResponseNotFound {
        if month == MISSING_ID {
            return notFound("resource_not_found", "Plan month not found");
        }
        MonthDetail detail = {
            month,
            note: "September budget",
            income: 520000,
            budgeted: 480000,
            activity: -310000,
            toBeBudgeted: 40000,
            ageOfMoney: 32,
            deleted: false,
            categories: [sampleCategory()]
        };
        return {data: {month: detail}};
    }

    # Get all payees
    #
    # + planId - The id of the plan
    # + lastKnowledgeOfServer - The starting server knowledge
    # + return - The list of requested payees, or no payees were found
    resource function get plans/[string planId]/payees(@http:Query {name: "last_knowledge_of_server"} int? lastKnowledgeOfServer) returns PayeesResponse|ErrorResponseNotFound {
        return {data: {serverKnowledge: 100, payees: [samplePayee(), samplePayee("p1q2r3s4-0040-4d8e-9f2a-3b4c5d6e7f80", "City Utilities")]}};
    }

    # Get a payee
    #
    # + planId - The id of the plan
    # + payeeId - The id of the payee
    # + return - The requested payee, or the requested payee was not found
    resource function get plans/[string planId]/payees/[string payeeId]() returns PayeeResponse|ErrorResponseNotFound {
        if payeeId == MISSING_ID {
            return notFound("resource_not_found", "Payee not found");
        }
        return {data: {payee: samplePayee(payeeId)}};
    }

    # Get all scheduled transactions
    #
    # + planId - The id of the plan
    # + lastKnowledgeOfServer - The starting server knowledge
    # + return - The list of requested scheduled transactions, or none were found
    resource function get plans/[string planId]/scheduled_transactions(@http:Query {name: "last_knowledge_of_server"} int? lastKnowledgeOfServer) returns ScheduledTransactionsResponse|ErrorResponseNotFound {
        return {data: {serverKnowledge: 100, scheduledTransactions: [sampleScheduled()]}};
    }

    # Get a scheduled transaction
    #
    # + planId - The id of the plan
    # + scheduledTransactionId - The id of the scheduled transaction
    # + return - The requested scheduled transaction, or it was not found
    resource function get plans/[string planId]/scheduled_transactions/[string scheduledTransactionId]() returns ScheduledTransactionResponse|ErrorResponseNotFound {
        if scheduledTransactionId == MISSING_ID {
            return notFound("resource_not_found", "Scheduled transaction not found");
        }
        return {data: {scheduledTransaction: sampleScheduled(scheduledTransactionId)}};
    }

    # Get all transactions
    #
    # + planId - The id of the plan
    # + sinceDate - Only return transactions on or after this date
    # + untilDate - Only return transactions on or before this date
    # + 'type - Only return transactions of this type
    # + lastKnowledgeOfServer - The starting server knowledge
    # + return - The list of requested transactions, a bad request, or no transactions were found
    resource function get plans/[string planId]/transactions(@http:Query {name: "since_date"} string? sinceDate, @http:Query {name: "until_date"} string? untilDate, "uncategorized"|"unapproved"? 'type, @http:Query {name: "last_knowledge_of_server"} int? lastKnowledgeOfServer) returns TransactionsResponse|ErrorResponseBadRequest|ErrorResponseNotFound {
        return {data: {serverKnowledge: 100, transactions: [sampleTransaction(), sampleTransaction("t1u2v3w4-0050-4e9f-8a3b-4c5d6e7f8091", -12500)]}};
    }

    # Get a transaction
    #
    # + planId - The id of the plan
    # + transactionId - The id of the transaction
    # + return - The requested transaction, or the transaction was not found
    resource function get plans/[string planId]/transactions/[string transactionId]() returns TransactionResponse|ErrorResponseNotFound {
        if transactionId == MISSING_ID {
            return notFound("resource_not_found", "Transaction not found");
        }
        return {data: {serverKnowledge: 100, 'transaction: sampleTransaction(transactionId)}};
    }

    # Get user
    #
    # + return - The user information
    resource function get user() returns UserResponse {
        return {data: {user: {id: "u1v2w3x4-0007-4fb1-8c5d-6e7f8091a2b3"}}};
    }

    # Update a category
    #
    # + planId - The id of the plan
    # + categoryId - The id of the category
    # + payload - The category to update
    # + return - The category was successfully updated, or the request was invalid
    resource function patch plans/[string planId]/categories/[string categoryId](@http:Payload PatchCategoryWrapper payload) returns SaveCategoryResponse|ErrorResponseBadRequest {
        Category category = sampleCategory(categoryId);
        anydata name = payload.category?.name;
        if name is string {
            category.name = name;
        }
        return {data: {serverKnowledge: 102, category}};
    }

    # Update a payee
    #
    # + planId - The id of the plan
    # + payeeId - The id of the payee
    # + payload - The payee to update
    # + return - The payee was successfully updated, or the request was invalid
    resource function patch plans/[string planId]/payees/[string payeeId](@http:Payload PatchPayeeWrapper payload) returns SavePayeeResponse|ErrorResponseBadRequest {
        Payee payee = samplePayee(payeeId, payload.payee?.name ?: "Corner Market");
        return {data: {serverKnowledge: 102, payee}};
    }

    # Create an account
    #
    # + planId - The id of the plan
    # + payload - The account to create
    # + return - The account was successfully created, or the request was invalid
    resource function post plans/[string planId]/accounts(@http:Payload PostAccountWrapper payload) returns AccountResponse|ErrorResponseBadRequest {
        Account account = sampleAccount("a1b2c3d4-0099-4a5b-8c9d-0e1f2a3b4c5d", payload.account.name);
        account.'type = payload.account.'type;
        account.balance = payload.account.balance;
        return {data: {account}};
    }

    # Create a category
    #
    # + planId - The id of the plan
    # + payload - The category to create
    # + return - The category was successfully created, or the request was invalid
    resource function post plans/[string planId]/categories(@http:Payload PostCategoryWrapper payload) returns SaveCategoryResponse|ErrorResponseBadRequest {
        Category category = sampleCategory("c1d2e3f4-0099-4b6c-9d0e-1f2a3b4c5d6e");
        anydata name = payload.category?.name;
        if name is string {
            category.name = name;
        }
        return {data: {serverKnowledge: 102, category}};
    }

    # Create a payee
    #
    # + planId - The id of the plan
    # + payload - The payee to create
    # + return - The payee was successfully created, or the request was invalid
    resource function post plans/[string planId]/payees(@http:Payload PostPayeeWrapper payload) returns SavePayeeResponse|ErrorResponseBadRequest {
        return {data: {serverKnowledge: 102, payee: samplePayee("p1q2r3s4-0099-4d8e-9f2a-3b4c5d6e7f80", payload.payee.name)}};
    }

    # Create a scheduled transaction
    #
    # + planId - The id of the plan
    # + payload - The scheduled transaction to create
    # + return - The scheduled transaction was successfully created, or the request was invalid
    resource function post plans/[string planId]/scheduled_transactions(@http:Payload PostScheduledTransactionWrapper payload) returns ScheduledTransactionResponse|ErrorResponseBadRequest {
        ScheduledTransactionDetail detail = sampleScheduled("s1t2u3v4-0099-4fa0-9b4c-5d6e7f8091a2");
        detail.dateFirst = payload.scheduledTransaction.date;
        detail.dateNext = payload.scheduledTransaction.date;
        detail.accountId = payload.scheduledTransaction.accountId;
        int? amount = payload.scheduledTransaction?.amount;
        if amount is int {
            detail.amount = amount;
        }
        return {data: {scheduledTransaction: detail}};
    }

    # Create a transaction
    #
    # + planId - The id of the plan
    # + payload - The transaction or transactions to create
    # + return - The transactions were successfully created, a bad request, or a conflict
    resource function post plans/[string planId]/transactions(@http:Payload PostTransactionsWrapper payload) returns SaveTransactionsResponse|ErrorResponseBadRequest|ErrorResponseConflict {
        NewTransaction? single = payload?.'transaction;
        if single is () && payload?.transactions is () {
            return badRequest("Either transaction or transactions must be provided");
        }
        TransactionDetail created = sampleTransaction("t1u2v3w4-0099-4e9f-8a3b-4c5d6e7f8091");
        if single is NewTransaction {
            int? amount = single?.amount;
            if amount is int {
                created.amount = amount;
            }
        }
        return {data: {serverKnowledge: 103, transactionIds: [created.id], transactions: [created]}};
    }

    # Update a transaction
    #
    # + planId - The id of the plan
    # + transactionId - The id of the transaction
    # + payload - The transaction to update
    # + return - The transaction was successfully updated, or the request was invalid
    resource function put plans/[string planId]/transactions/[string transactionId](@http:Payload PutTransactionWrapper payload) returns TransactionResponse|ErrorResponseBadRequest {
        TransactionDetail updated = sampleTransaction(transactionId);
        int? amount = payload.'transaction?.amount;
        if amount is int {
            updated.amount = amount;
        }
        return {data: {serverKnowledge: 104, 'transaction: updated}};
    }
}

// Service-mode response types. `bal openapi --mode client` collapses 4XX/5XX
// to `error` and never emits these, so they are defined here for the mock only.
public type ErrorResponseBadRequest record {|
    *http:BadRequest;
    ErrorResponse body;
|};

public type ErrorResponseConflict record {|
    *http:Conflict;
    ErrorResponse body;
|};

public type ErrorResponseNotFound record {|
    *http:NotFound;
    ErrorResponse body;
|};

public type ErrorResponse record {
    ErrorDetail 'error;
};

public type ErrorDetail record {
    string name;
    string id;
    string detail;
};
