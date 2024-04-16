# CI/CD Implementation

DBT supports CI/CD pipeline like common software development framework. In the early stage of digital transformation, it would be easier to implement the data orchestration through GitHub Actions. The execution workflow is defined on the `python-app.yml` file.

The workflow requires variables that need to be stored as environmental variables such as our project and dataset name, and secret variables such as our Bigquery service account JSON content.

## Trigger

The workflow will be executed by two triggers:

- Once any commit pushed to the `main` branch
- Every 00.00 AM UTC as defined in the `cron` part

```yml
on:
  push:
    branches:
      - main
  schedule:
    - cron: "0 0 * * *"
```

## Bigquery Authentication

The execution steps are defined as a regular python application workflow. One of the trickiest part is to authenticate connection to our Bigquery project which performed in:

```yml
    - name: Authenticate using service account
    run: |
        mkdir -p ./dbt_transformation/.gcloud/
        echo "$KEYFILE_CONTENTS" > ./dbt_transformation/.gcloud/dbt-service-account.json
    shell: bash
    env:
        KEYFILE_CONTENTS: ${{ secrets.DBT_GOOGLE_BIGQUERY_KEYFILE }}
```

Here, the Bigquery service account JSON that stored in the secret variable is copied to the temporary folder `./dbt_transformation/.gcloud/`. This variable also needs to be defined in the `profiles.yml`. Once this step is executed successfully, then usually the steps below will be run without obstacles.
