# Company Data

This folder contains the dataset required to be migrated to the data warehouse. Ideally this data should be uploaded to separated Bigquery dataset than the dataset where the transformation occured. And, this dataset should be protected by limited access to leverage the protection of customers data.

Most data can be uploaded as it is with automatic schema detection, except the `transaction_products.csv` data. If you want to replicate the same result as me, you can define the schema as:

```json
[
  {
    "name": "transaction_id",
    "mode": "REQUIRED",
    "type": "INTEGER"
  },
  {
    "name": "transaction_date",
    "mode": "REQUIRED",
    "type": "DATETIME"
  },
  {
    "name": "buyer_name",
    "mode": "NULLABLE",
    "type": "STRING"
  },
  {
    "name": "product_category",
    "mode": "NULLABLE",
    "type": "STRING"
  },
  {
    "name": "total_price",
    "mode": "NULLABLE",
    "type": "STRING"
  },
  {
    "name": "rating",
    "mode": "NULLABLE",
    "type": "FLOAT"
  }
]
```
