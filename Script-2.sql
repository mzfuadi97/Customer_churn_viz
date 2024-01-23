USE de_btpn;

-- Membuat view master_data
CREATE VIEW master_data AS 
    SELECT 
    	cdh.CLIENTNUM cust_id,
        cdh.customer_age,
        cdh.dependent_count, 
        cdh.gender,
        cdh.income_category,
        cdh.months_on_book, 
        cdh.total_relationship_count,
        cdh.months_inactive_12_mon,
        cdh.credit_limit,
        cdh.total_revolving_bal,
        cdh.total_trans_amt,
        cdh.avg_open_to_buy,
        cdh.total_trans_ct,
        cdh.avg_utilization_ratio,
        stat.status, 
        cat.card_category,
        edu.Education_Level, 
        mar.Marital_Status 
    FROM
        customer_data_history cdh
    LEFT JOIN status_db stat ON cdh.idstatus = stat.id
    LEFT JOIN category_db cat ON cdh.card_categoryid = cat.id
    LEFT JOIN education_db edu ON cdh.educationid = edu.id
    LEFT JOIN marital_db mar ON cdh.maritalid = mar.id;

-- Menarik data dari view master_table
SELECT 
    *
FROM 
    master_data ;
   
-- Membuat churn_data dari view
CREATE View churn_data AS (
SELECT *,
	CASE
	WHEN customer_age <= 25 THEN 'below 26'
	WHEN customer_age <= 35 THEN '26-35'
	WHEN customer_age <= 45 THEN '36-45'
	WHEN customer_age <= 55 THEN '46-55'
	WHEN customer_age <= 65 THEN '56-65'
WHEN customer_age > 65 THEN 'older than 65'
END AS age_seg,
ROUND((FLOOR(avg_utilization_ratio * 10)/10), 1) utilization_seg,
FLOOR(total_trans_amt/1000)*1000  total_trans_amt_seg
    FROM 
        master_data 
    WHERE status = 'Attrited Customer'
);

-- Menarik churn_data view 
select * from  churn_data;

-- Customer churn percentage
WITH t1_data as (
SELECT 
		status, 
		COUNT(*) AS jumlah_transaksi
	FROM master_data 
	GROUP BY 1
)
select *,
round(((jumlah_transaksi/(select sum(jumlah_transaksi) from t1_data)) * 100), 2) percetage
from t1_data ;

--  Mengurutkan utilize rate segement
select utilization_seg,
count(*) cust_count
from
churn_data 
group by utilization_seg
order by utilization_seg ;

-- Total Transaction Segment
SELECT total_trans_amt_seg, COUNT(*) total_cust
FROM churn_data
GROUP BY 1
ORDER BY 1;

-- Membuat Segment berdasarkan income dan gender
SELECT gender, income_category, COUNT(*) AS cust_count
FROM churn_data
GROUP BY gender, income_category
ORDER BY cust_count DESC, CASE
WHEN income_category ='Unknown' THEN 1
WHEN income_category ='Less than $40K' THEN 2
WHEN income_category ='$40K - $60K' THEN 3
WHEN income_category ='$60K - $80K' THEN 4
WHEN income_category ='$80K - $120K' THEN 5
WHEN income_category ='$120K +' THEN 6
END;
select 
status,
income_category,
Education_Level,
sum(total_trans_amt),
sum(total_trans_amt),
sum(total_revolving_bal),
sum(total_relationship_count),
sum(avg_utilization_ratio), 
count(*) total_cust 
from
master_data md 
group by 1,2,3;

