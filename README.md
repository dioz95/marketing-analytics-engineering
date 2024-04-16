# Leveraging Best Practices of Analytics Engineering in Marketing Domain: A study case of enterprise digital transformation

This repo introduces the analytics engineering practices in supporting enterprise digital transformation, particularly within the marketing domain.

## Problem Statement

Company X is a new emerging start-up that recently received their first seed funding after having operated for 7 months. During their early business operation, they record their customer and transaction data in 3 main spreadsheets:

- `Customers`: record customers personal data and contact.
- `Transaction product`: record aggregated transaction activities for each customer for each product category.
- `Review company`: record customers rating (1 - 5) that represents their perception about company overall services.
  To support their sales performance, they also regularly create monthly marketing campaigns that require a few amount of costs that are recorded in the marketing campaign spreadsheet.

After several months running their business using quite a traditional approach, now they are thinking of doing digital transformation to their company to be able to compete with their current competitors. To solve this problem, they hire a team from data consultancy company that specifically assigned to work within the marketing team in order to create an automated data pipeline as well as producing end user data products with these specific requirements:

- They work in fast-paced environment, they want the system to be flexible to cope with this working culture.
- They want a dashboard that automatically updated on the daily basis to present summary about their sales and marketing campaign performance.
- They want to know the transaction profile of their customer and want to know how this profile can be used to enhance the revenue growth.
- They are committed to protect their customer data privacy.

## Working Process

To deliver the request raised by the user, the data consultant decided to go with a non-traditional ELT (Extract, Load, Transform) approach to streamline the data pipeline creation process.

- Data loading to Google Bigquery.
- Build data model and documentation using DBT.
- Create testing scenario using dbt test and dbt Great Expectations.
- Building semantic layer to enforce the metrics consistency and reusability of each metrics
- Developing data products:
  - Data Analys/Business Intelligence: _Marketing Executive Dashboard_
  - Data Scientist: _Customer RFM (Recency, Frequency, Monetary) Analysis_
- Code versioning and workflow orchestration using Git and GitHub Actions

## Project Structure

```
.
├── .github
│   └── workflows
├── .gitignore
├── README.md
├── data
│   ├── customers.csv
│   ├── marketing_campaign.csv
│   ├── review_company.csv
│   └── transaction_product.csv
├── data_products
│   └── CustomerSegmentation_K-Means.ipynb
├── dbt_transformation
│   ├── .gitignore
│   ├── .user.yml
│   ├── README.md
│   ├── analyses
│   ├── dbt_packages
│   ├── dbt_project.yml
│   ├── logs
│   ├── macros
│   ├── models
│   ├── package-lock.yml
│   ├── packages.yml
│   ├── profiles.yml
│   ├── seeds
│   ├── snapshots
│   ├── target
│   └── tests
├── requirements.txt
```

This project is served on 4 main directories that you can visit in this order:

- `data`: this folder contains the main spreadsheet used to record the customers, transactions, reviews, and marketing campaign data. These spreadsheets will be loaded to Bigquery as it is to be transformed using DBT on the next stage.
- `dbt_transformation`: this folder is where the analytics engineering practices are performed
  - Data transformation
  - Model testing
  - Semantic layer creation
  - Data documentation
- `data_products`: this folder contains the end product produced using the transformed data.
  - Marketing executive dashboard
  - Customer RFM analysis using K-Means clustering method
- `.github/workflows`: this folder contains `.yml` file for orchestrating the scheduled job to execute the model testing and creation.

## Getting Started
To reproduce this project you should follow this step:
1. Create Bigquery account (free tier is enough)
2. Download the bigquery service account json
3. Clone this repository
  ```bash
  git clone https://github.com/dioz95/marketing-analytics-engineering.git
  ```
3. Create a virtual environment with `python 3.11.x`
4. Install `requirements.txt` inside the virtual environment
5. Install `direnv` in your local machine. `direnv` is a shell extension tool to enable using your own `profile.yml` for local development. The installation instruction is available [here](https://direnv.net/).
6. Go to the root directory of the dbt project, in this case `dbt_transformation` folder, and create `.envrc` file:
  ```bash
  export DBT_GOOGLE_PROJECT=<your-bigquery-project-name>
  export DBT_GOOGLE_BIGQUERY_DATASET=<your-bigquery-dataset-name>
  export DBT_GOOGLE_BIGQUERY_KEYFILE=<your-bigquery-keyfile-json-path>
  ```
7. Inside the `dbt_transformation`, run `dbt debug`. If everything is set correctly, `dbt debug` should execute successfully.
