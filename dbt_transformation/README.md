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
  ```yaml
  models:
  dbt_transformation:
      +materialized: table 

      src:
        +materialized: ephemeral

      metrics:
        +materialized: view
  ```
* In the `.sql` model file materialization can be configured using `{{ config(...) }}`, e.g.:
  ```sql
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
Semantic layer is a relatively new feature introduced by DBT to enable consistent and reliable metrics creation. While the fullest capability of the DBT Semantic Layer can be used in the paid version of dbt Cloud, dbt Core users still be able to utilise the most important part of it in [dbt MetricFlow](https://docs.getdbt.com/docs/build/about-metricflow). MetricFlow will help the user to define and manage the logic of your organization's metrics, preventing the confusion caused by multiple interpretations in the metrics calculation. DBT MetricFlow require the semantic model and metrics definition for the data models that have been created.
## Data Modeling
### Source (stagging)
Source in DBT resembles a staging area that enables the user to name and describe the data loaded into Bigquery. Source models are defined inside the `src` directory:
- `src_customers.sql`: source model for `customers.csv` data
- `src_transactions.sql`: source model for `transaction_product.csv` data
- `src_company_review.sql`: source model for `review_company.csv` data

These models generally contain some light transformations, for example to convert string to numerical data type on the `total_price_cleansed` column and trimming the whitespaces on the other string columns. Source models generally materialized using `ephemeral` materialization because we don't want these models available to be queried on the data warehouse.

Beside the basic testing scenario that you might already know(`unique`, `non_null`, etc). tests in the source models generally performed to intercept the non-standard value used to capture the data in the production, for example in the `total_price` column, we want the values in this column to match with certain regex (`[Rp]{1}(?P<amount>[\\\\d,\\\\.]+(?:\\\\?>\\\\.\\\\d{2}){0,})\\\\b`). This test scenario available in the dbt Great Expectation packages so we can use it directly in the `sources.yml`:
```yaml
...
  - tests:
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
### Seeds
Seeds in this project applied to `marketing_campaign.csv` data since this data will not directly related to transaction and will be maintained personally by the marketing team. Seeds feature in DBT is suitable to be implemented to a data that will not be changed frequently like our marketing campaign data that will be updated in monthly basis. Seeds model is defined inside the `seeds` directory. Once the `.csv` files upladed into this directory, it will be materialized when the `dbt run` executed.
### Dimensional modelling
Dimensional modelling applied to the models from the `src`, `snapshots`, and `seeds` directory to produce dimensions and fact tables. DBT also support surrogate key creation through `{{ dbt_utils.generate_surrogate_key([columns1, columns2, ...]) }}` macro that will generate the hashed value of the concatenation of the column(s) defined in the macro's argument. For example, in the `fct_company_reviews.sql` model, the surrogate key for unique identifier of the company review defined as,
```sql
SELECT 
    {{ dbt_utils.generate_surrogate_key(['customer_id', 'rating']) }} AS company_review_id,
    *
FROM company_reviews_with_cust_id
```
Interestingly,the `fct_transactions.sql` model implements a custom incremental materialization method. In the normal execution policy, DBT will detect the latest `transaction_date` from this table, and will only insert the data after the latest transaction date. Beside that, the execution can also be executed using the defined date range to perform backfilling to the data. By implementing this custom strategy, the model creation can be run more efficiently in the presence of big data.
### Metrics creation using semantic layer feature in DBT (DBT MetricFlow)
To produce the data products requested by the clients, several metrics should be created from the dimensional models. Before the introduction of semantic layer by DBT, the metrics can be created by directly querying the models or by calculating the metrics outside the DBT environment e.g. in the dashboard or jupyter notebook. The second option is the most dangerous behaviour we want to avoid since this practice can lead to confusion and multiple interpretation to the metrics. 

To create standardisation of metrics, `semantic_model.yml` and `metrics.yml` files created under `semantic_models` directory. These files will give semantic meaning to the models by stating the measures, entities, and dimensions prior to the metrics calculation. By doing this, each time the users want to query a metric, for example `Marketing to Budget Revenue Ratio (MBTR)` they can run:
```bash
mf query --metrics marketing_budget_revenue_ratio --group-by metric_time__month --order metric_time__month --start-time 2023-08-01 --end-time 2024-02-01
```
and this command will result:
```
 Success - query completed after 2.61 seconds
| metric_time__month   |   marketing_budget_revenue_ratio |
|:---------------------|---------------------------------:|
| 2023-08-01           |                             0.19 |
| 2023-09-01           |                             0.25 |
| 2023-10-01           |                             0.18 |
| 2023-11-01           |                             0.28 |
| 2023-12-01           |                             0.36 |
| 2024-01-01           |                             0.26 |
| 2024-02-01           |                             0.38 |
```
Morover, by using MetricFlow, DBT can generate most efficient SQL query to calculate such metric by adding `--explain` option in the command:
```bash
mf query --metrics marketing_budget_revenue_ratio --group-by metric_time__month --order metric_time__month --start-time 2023-08-01 --end-time 2024-02-01 --explain
```
which will result in:
```
 Success - query completed after 0.83 seconds
 SQL (remove --explain to see data or add --show-dataflow-plan to see the generated dataflow plan):
SELECT
  metric_time__month
  , CAST(total_marketing_budget AS FLOAT64) / CAST(NULLIF(total_revenue, 0) AS FLOAT64) AS marketing_budget_revenue_ratio
FROM (
  SELECT
    COALESCE(subq_9.metric_time__month, subq_19.metric_time__month) AS metric_time__month
    , MAX(subq_9.total_marketing_budget) AS total_marketing_budget
    , COALESCE(MAX(subq_19.total_revenue), 0) AS total_revenue
  FROM (
    SELECT
      DATE_TRUNC(start_date, month) AS metric_time__month
      , SUM(marketing_budget) AS total_marketing_budget
    FROM `loyal-saga-416712`.`marketing_analytics_dwh`.`fct_marketing_campaign` fct_marketing_campaign_src_10000
    WHERE DATE_TRUNC(start_date, day) BETWEEN '2023-08-01' AND '2024-02-29'
    GROUP BY
      metric_time__month
  ) subq_9
  FULL OUTER JOIN (
    SELECT
      metric_time__month
      , COALESCE(total_paid, 0) AS total_revenue
    FROM (
      SELECT
        subq_15.metric_time__month AS metric_time__month
        , subq_14.total_paid AS total_paid
      FROM (
        SELECT
          DATE_TRUNC(date_day, month) AS metric_time__month
        FROM `marketing_analytics_dwh`.`metricflow_time_spine` subq_16
        WHERE date_day BETWEEN '2023-08-01' AND '2024-02-29'
        GROUP BY
          metric_time__month
      ) subq_15
      LEFT OUTER JOIN (
        SELECT
          DATE_TRUNC(transaction_date, month) AS metric_time__month
          , SUM(total_paid) AS total_paid
        FROM `loyal-saga-416712`.`marketing_analytics_dwh`.`fct_transactions` fct_transactions_src_10000
        WHERE DATE_TRUNC(transaction_date, day) BETWEEN '2023-08-01' AND '2024-02-29'
        GROUP BY
          metric_time__month
      ) subq_14
      ON
        subq_15.metric_time__month = subq_14.metric_time__month
      WHERE subq_15.metric_time__month BETWEEN '2023-08-01' AND '2024-02-29'
    ) subq_18
  ) subq_19
  ON
    subq_9.metric_time__month = subq_19.metric_time__month
  GROUP BY
    metric_time__month
) subq_20
ORDER BY metric_time__month
```

The metrics either can be materialized (in the `metrics`) prior to the data mart creation (in the `mart` directory), or directly materialized to the `mart` directory since MetricFlow also support multiple metrics creation. For example to create `mart_sales_performance.sql`:
```bash
mf query --metrics total_revenue,count_transactions,count_transacting_customers --group-by metric_time__month,transaction__is_transaction_amount_below_average,product_category_id__product_category --order metric_time__month --start-time 2023-08-01 --end-time 2024-03-01 --explain
```
will result in:
```
 Success - query completed after 1.06 seconds
 SQL (remove --explain to see data or add --show-dataflow-plan to see the generated dataflow plan):
SELECT
  COALESCE(subq_19.metric_time__month, subq_29.metric_time__month) AS metric_time__month
  , COALESCE(subq_19.transaction__is_transaction_amount_below_average, subq_29.transaction__is_transaction_amount_below_average) AS transaction__is_transaction_amount_below_average
  , COALESCE(subq_19.product_category_id__product_category, subq_29.product_category_id__product_category) AS product_category_id__product_category
  , COALESCE(MAX(subq_19.total_revenue), 0) AS total_revenue
  , MAX(subq_29.count_transactions) AS count_transactions
  , MAX(subq_29.count_transacting_customers) AS count_transacting_customers
FROM (
  SELECT
    metric_time__month
    , transaction__is_transaction_amount_below_average
    , product_category_id__product_category
    , COALESCE(total_paid, 0) AS total_revenue
  FROM (
    SELECT
      subq_15.metric_time__month AS metric_time__month
      , subq_14.transaction__is_transaction_amount_below_average AS transaction__is_transaction_amount_below_average
      , subq_14.product_category_id__product_category AS product_category_id__product_category
      , subq_14.total_paid AS total_paid
    FROM (
      SELECT
        DATE_TRUNC(date_day, month) AS metric_time__month
      FROM `marketing_analytics_dwh`.`metricflow_time_spine` subq_16
      WHERE date_day BETWEEN '2023-08-01' AND '2024-03-31'
      GROUP BY
        metric_time__month
    ) subq_15
    LEFT OUTER JOIN (
      SELECT
        subq_9.metric_time__month AS metric_time__month
        , subq_9.transaction__is_transaction_amount_below_average AS transaction__is_transaction_amount_below_average
        , dim_product_categories_src_10000.product_category AS product_category_id__product_category
        , SUM(subq_9.total_paid) AS total_paid
      FROM (
        SELECT
          DATE_TRUNC(transaction_date, month) AS metric_time__month
          , product_category_id
          , CASE
          WHEN total_paid < AVG(total_paid) OVER() THEN 1
          ELSE 0
        END AS transaction__is_transaction_amount_below_average
          , total_paid
        FROM `loyal-saga-416712`.`marketing_analytics_dwh`.`fct_transactions` fct_transactions_src_10000
        WHERE DATE_TRUNC(transaction_date, day) BETWEEN '2023-08-01' AND '2024-03-31'
      ) subq_9
      LEFT OUTER JOIN
        `loyal-saga-416712`.`marketing_analytics_dwh`.`dim_product_categories` dim_product_categories_src_10000
      ON
        subq_9.product_category_id = dim_product_categories_src_10000.product_category_id
      GROUP BY
        metric_time__month
        , transaction__is_transaction_amount_below_average
        , product_category_id__product_category
    ) subq_14
    ON
      subq_15.metric_time__month = subq_14.metric_time__month
    WHERE subq_15.metric_time__month BETWEEN '2023-08-01' AND '2024-03-31'
  ) subq_18
) subq_19
FULL OUTER JOIN (
  SELECT
    subq_23.metric_time__month AS metric_time__month
    , subq_23.transaction__is_transaction_amount_below_average AS transaction__is_transaction_amount_below_average
    , dim_product_categories_src_10000.product_category AS product_category_id__product_category
    , SUM(subq_23.count_transactions) AS count_transactions
    , COUNT(DISTINCT subq_23.count_transacting_customers) AS count_transacting_customers
  FROM (
    SELECT
      DATE_TRUNC(transaction_date, month) AS metric_time__month
      , product_category_id
      , CASE
      WHEN total_paid < AVG(total_paid) OVER() THEN 1
      ELSE 0
    END AS transaction__is_transaction_amount_below_average
      , 1 AS count_transactions
      , customer_id AS count_transacting_customers
    FROM `loyal-saga-416712`.`marketing_analytics_dwh`.`fct_transactions` fct_transactions_src_10000
    WHERE DATE_TRUNC(transaction_date, day) BETWEEN '2023-08-01' AND '2024-03-31'
  ) subq_23
  LEFT OUTER JOIN
    `loyal-saga-416712`.`marketing_analytics_dwh`.`dim_product_categories` dim_product_categories_src_10000
  ON
    subq_23.product_category_id = dim_product_categories_src_10000.product_category_id
  GROUP BY
    metric_time__month
    , transaction__is_transaction_amount_below_average
    , product_category_id__product_category
) subq_29
ON
  (
    subq_19.transaction__is_transaction_amount_below_average = subq_29.transaction__is_transaction_amount_below_average
  ) AND (
    subq_19.product_category_id__product_category = subq_29.product_category_id__product_category
  ) AND (
    subq_19.metric_time__month = subq_29.metric_time__month
  )
GROUP BY
  metric_time__month
  , transaction__is_transaction_amount_below_average
  , product_category_id__product_category
ORDER BY metric_time__month
```

Lastly to visualize the steps of metrics calculation, `--display-plans` option can be added to the MetricFlow command as:
```bash
mf query --metrics total_revenue,count_transactions,count_transacting_customers --group-by metric_time__month,transaction__is_transaction_amount_below_average,product_category_id__product_category --order metric_time__month --start-time 2023-08-01 --end-time 2024-03-01 --display-plans
```
this will produce [SVG file](https://github.com/dioz95/marketing-analytics-engineering/blob/main/assets/metics_plan.svg) that describe the query plans.

>Note: MetricFlow still does not support complex metrics calculation such as `metrics_customers_recency.sql` that use dynamic window functions to compute the day differences between a customer's last transaction date and last transaction date recorded in the `fct_transactions.sql` model.
### Data Mart
End products of the DBT transformation are concluded in two data mart models that will be used to build **Marketing Executive Dashboard** by the Data Analyst/BI:
- `mart_sales_performance.sql` that contains metrics:
    - `total_revenue`: sum of revenue gained from the transactions
    - `count_transactions`: count of transactions
    - `count_transacting_customers`: count of customers doing transactions
  that aggregated by these dimensions:
    - `metric_time__month`: year, month
    - `transaction__is_transaction_amount_below_average`: sign if a transaction value is above or below the average value of the whole transactions
    - `product_category_id__product_category`: product category purchased in a transaction
- `mart_marketing_campaign.sql` that contains metrics:
    - `total_revenue`: sum of revenue gained from the transactions
    - `total_marketing_budget`: sum of marketing budget spent for the campaign
    - `marketing_budget_revenue_ratio`: ratio of marketing budget to the total revenue
  that aggregated by `month` dimension
and one data mart that will be used to build **Customer RFM Analysis** by the Data Scientist:
- `mart_customer_rfm.sql`: that contains metrics:
    - `customer_recency`: customers' recency metrics
    - `customer_frequency`: customers' frequency metrics
    - `customer_monetary`: customers' monetary metrics
  that aggregated by these dimensions:
    - `customer_id`: customer id of the transacting customer
    - `customer_name_hashed`: hashed value of the customer's name
