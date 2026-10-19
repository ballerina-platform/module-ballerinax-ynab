_Author_:  Dimuthu Madushan \
_Created_: 2026/10/19 \
_Updated_: 2026/10/19 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from YNAB. 
The OpenAPI specification is obtained from [wso2/api-specs](https://github.com/wso2/api-specs/blob/main/openapi/ynab/ynab/v1/openapi.yaml).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

1. Change `PlanSummaryResponseData default_plan` to nullable
- **Original**: The `default_plan` field in `PlanSummaryResponseData` was `not nullable`.
- **Updated**: The `default_plan` field has been updated to be `nullable`.
- **Reason**: The API can return a null value for this field.
<!-- auto-generated -->

2. Downgrade the OpenAPI version from `3.1.1` to `3.0.3`
- **Original**: The specification declared `openapi: 3.1.1`.
- **Updated**: The specification declares `openapi: 3.0.3`.
- **Reason**: `bal openapi flatten` drops the `type` of every parameter and property schema in a 3.1.1 document (path parameters became `schema: {}`, so all operations with a path parameter were skipped by the generator and only 2 of 44 operations were generated). Under 3.0.3 all 44 operations are generated. Properties declared with a 3.1 type array such as `type: [string, "null"]` are not understood as 3.0 types and are generated as `anydata`.
- **Change made in**: the original specification `docs/spec/openapi.yaml`.

3. Change the items of `PlanDetail.accounts` from `AccountBase` to `Account`
- **Original**: `PlanDetail` extends `PlanSummary` (whose `accounts` is `Account[]`) and redeclares `accounts` as `AccountBase[]`.
- **Updated**: `PlanDetail.accounts` is an array of `Account`.
- **Reason**: The redeclared field type is not a subtype of the inherited one, so the generated `PlanDetail` record failed to compile.
- **Change made in**: the original specification `docs/spec/openapi.yaml`.

4. Simplify `info.description`
- **Original**: The description was a general note on the API's REST design, JSON format and error responses.
- **Updated**: The description is a short summary of what the API gives access to, with a link to the API documentation.
- **Reason**: `info.description` becomes the documentation of the generated `Client` class, so it should describe the API rather than its transport details.
- **Change made in**: the original specification `docs/spec/openapi.yaml`.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/aligned_ballerina_openapi.json -o ballerina --mode client --client-methods remote --license docs/license.txt
```

Note: The license year is hardcoded to 2026, change if necessary.
