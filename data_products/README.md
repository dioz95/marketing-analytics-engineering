# End Data Products

Once the data mart models created, the Data Analyst and Data Scientist can move to produce the deliverables asked by the client. For higher management team, **Marketing Executive Dashboard** contains visualizations of the metrics that represent the performance of the marketing team. The dashboard is built using Looker Studio that has seamless integration to Bigquery. One advantage of utilising semantic layer in dbt, the Data Analyst can directly visualize the data mart without thinking about calculated field in the Looker Studio (or any other dashboarding tools).

Secondly, the Data Scientist proceed to his/her own notebook and access the data mart via Bigquery service account. The Data Scientist will pull the desired data mart to develop a customer segmentation using K-means algorithm from the scikit learn library.
