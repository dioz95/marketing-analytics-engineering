# End Data Products

Once the data mart models created, the Data Analyst and Data Scientist can move to produce the deliverables asked by the client. For higher management team, [**Marketing Executive Dashboard**](https://lookerstudio.google.com/reporting/042e1c46-36ca-44e6-88e8-1d23ab697ebb) contains visualizations of the metrics that represent the performance of the marketing team. The dashboard is built using Looker Studio that has seamless integration to Bigquery. One advantage of utilising semantic layer in dbt, the Data Analyst can directly visualize the data mart without thinking about calculated field in the Looker Studio (or any other dashboarding tools).

<p align="center"><img src="https://github.com/dioz95/marketing-analytics-engineering/blob/main/assets/dashboard.jpg" width=700/></p>
<p align="center"><strong>Fig 1.</strong> Marketing Executive Dashboard</p>

Secondly, the Data Scientist proceed to his/her own notebook and access the data mart via Bigquery service account. The Data Scientist will pull the desired data mart to develop a customer segmentation using K-means algorithm from the scikit learn library.

<p align="center"><img src="https://github.com/dioz95/marketing-analytics-engineering/blob/main/assets/customer_rfm.png" width=700/></p>
<p align="center"><strong>Fig 2.</strong> Customer RFM graph</p>

According to the diagram, our customers can be segmented into three different groups:
* Cluster 0 are the customers who recently purchased our product, but less frequent and less to spend. It could be a group of **new customers**

* Cluster 1 are the customers who recently purchased our product, with the highest frequency and highest monetary value. It could be a group of **loyal customers**

* Cluster 2 are the customers who purchased our product a long time ago, less frequent, and less to spend. It could be a group of **churned customers**

This finding will then impact on how the marketing team should create a better approach to each customer in the groups. For example, the customers that are tagged as new customers, the company can provide special coupon codes to attract more transactions from these customers. Meanwhile, for the customers tagged as loyal customers, the company can provide enhanced after sales support or provide a loyalty card to maintain the customer relation to the company.
