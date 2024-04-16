# Data Transformation using DBT
Data transformation in DBT generally performed inside the data warehouse. To be able to reproduce this step, the `.csv` data on the `./data` folder should already be loaded to Bigquery.
## Key Concepts
There are some key concepts of database design that implemented in this project:
* Materialization
* Model testing
* Semantic layer
### Materialization
Materializations are strategies for persisting dbt models in a warehouse. There are five types of materializations built into dbt. They are:
* table
* view
* incremental
* ephemeral
* materialized view
  
Materialization can be defined either in `dbt_profile.yml` or in the `.sql` mdodel.
* In the `dbt_profile.yml` materialization is defined under the `models` tag, e.g.:
  ```
  models:
  dbt_transformation:
      +materialized: table 

      src:
        +materialized: ephemeral

      metrics:
        +materialized: view
  ```
* In the `.sql` model file materialization can be configured using `{{ config(...) }}`, e.g.:
  ```
  {{
    config(materialized='table')
  }}
  
  select *
  from ...
  ```
You can also configure custom materializations in dbt. Custom materializations are a powerful way to extend dbt's functionality to meet your specific needs. Please refer to this link [(dbt materialization documentation)](https://docs.getdbt.com/docs/build/materializations) for the details.
### Model Testing
Testing in DBT applied on models, sources, snapshots, and seeds. The test can be performed to each column in predefined models. In this project the test is written using dbt built-in test package for the basic test scenario such as `unique` and `non_null`, and DBT Great Expectation package for a more sophisticated test scenario. The test scenarios are defined inside in `schema.yml` for each model and in `sources.yml` for the sources.
### Semantic Layer
Semantic layer is a relatively new feature introduced by DBT to enable consistent and reliable metrics creation. While the fullest capability of the DBT Semantic Layer can be used in the paid version of dbt Cloud, dbt Core users still be able to utilise the most important part of it in [dbt MetricFlow](https://docs.getdbt.com/docs/build/about-metricflow). MetricFlow will help the user to define and manage the logic of your organization's metrics, preventing the confusion caused by multiple interpretations in the metrics calculation.
## Data pipeline
### Source (stagging)
Source in DBT resembles a staging area that enables the user to name and describe the data loaded into Bigquery. Source models are defined inside the `src` directory:
- `src_customers.sql`: source model for `customers.csv` data
- `src_transactions.sql`: source model for `transaction_product.csv` data
- `src_company_review.sql`: source model for `review_company.csv` data

These models generally contain some light transformations, for example to convert string to numerical data type on the `total_price_cleansed` column and trimming the whitespaces on the other string columns. Source models generally materialized using `ephemeral` materialization because we don't want these models available to be queried on the data warehouse.

Beside the basic testing scenario that you might already know(`unique`, `non_null`, etc). tests in the source models generally performed to intercept the non-standard value used to capture the data in the production, for example in the `total_price` column, we want the values in this column to match with certain regex (`[Rp]{1}(?P<amount>[\\\\d,\\\\.]+(?:\\\\?>\\\\.\\\\d{2}){0,})\\\\b`). This test scenario available in the dbt Great Expectation packages so we can use it directly in the `sources.yml`:
```
...
    tests:
        - dbt_expectations.expect_column_values_to_match_regex:
            regex: "[Rp]{1}(?P<amount>[\\\\d,\\\\.]+(?:\\\\?>\\\\.\\\\d{2}){0,})\\\\b"
...
```
### Snapshot for the customer data (SCD Type II)
SCD Type II is applied to the customers data in a nonconventional way to fulfil the client request to detect the changes of customers' personal info while still maintaining the security of the data. The snapshot model produced from `scd_customers.sql` in the `scd` directory will only show the hashed (MD5) value of the customers' data. The snapshot is implemented using the `check` strategy that will trigger the SCD Type II following the changes to the customers' `phone_number`, `email`, and `city` columns in the source table.
```sql
{% snapshot scd_customers %}

{{ config(
    target_schema="marketing_analytics_dwh",
    strategy="check",
    unique_key='customer_id',
    check_cols=['phone_number_hashed', 'email_hashed', 'city_hashed'],
    invalidate_hard_deletes=True
) }}

SELECT
    customer_id,
    MD5(customer_name) AS customer_name_hashed,
    MD5(gender) AS gender_hashed,
    MD5(phone_number) AS phone_number_hashed,
    CONCAT(TO_BASE64(MD5(SPLIT(email, '@')[0])),'@', SPLIT(email, '@')[1]) AS email_hashed,
    MD5(city) AS city_hashed
FROM {{ ref('src_customers') }}

{% endsnapshot %}
```
### Dimensional modelling

### Metrics creation using semantic layer feature in DBT (DBT MetricFlow)

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
