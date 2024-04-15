# Data Transformation using DBT
Data transformation in DBT generally performed inside the data warehouse. To be able to reproduce this step, the `.csv` data on the `./data` folder should already be loaded to Bigquery.
## Materialization
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
## Testing

## Data pipeline
### Sources (stagging)

### Snapshot for the customer data (SCD Type II)

### Dimensional modelling

### Metrics creation using semantic layer feature in DBT (dbt metricflow)

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
