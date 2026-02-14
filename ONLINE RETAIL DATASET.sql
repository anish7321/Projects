use online_retail_data;
select * from online_retail_dataset;

# CREATING COPY OF ORIGNAL DATASET

create table retail_datasets like online_retail_dataset;
insert retail_datasets select * from online_retail_dataset;
select * from retail_datasets;

## CHECKING FOR  DUPLICATES RECORD 

with duplicate_cte as(
select *, row_number() over(partition by 
InvoiceNo,StockCode,`Description`,Quantity,InvoiceDate,
Unitprice,CustomerID,Country) as row_num 
from retail_datasets) select  * from duplicate_cte where row_num > 1;

## CONVERTING DATA TYPE 

select InvoiceDate, str_to_date(InvoiceDate,'%d-%m-%Y%H:%i')
from retail_datasets;

update retail_datasets
set InvoiceDate = str_to_date(InvoiceDate,'%d-%m-%Y%H:%i');
alter table retail_datasets modify InvoiceDate datetime;
alter table retail_datasets modify column UnitPrice decimal(9,2);

# CHECKING AND HANDELLING NULL VALUES
select* from retail_datasets where InvoiceNo or 
StockCode or`Description`or
 Quantity or InvoiceDate or
Unitprice or CustomerID or Country is null ;

#FEATURE ENGEENNERING
alter table retail_datasets
add column revenue decimal(10,2),
add column is_return tinyint,
add column invoice_month date,
add column is_churned tinyint;

update retail_datasets
set
	revenue = Quantity * UnitPrice,
    is_return = case when quantity <0 then 1 else 0 end,
    invoice_month = Date_Format(InvoiceDate,'%Y-%m-01')
where InvoiceDate is not null;

select count(*) /count(distinct InvoiceNo) as avg_item_per_invoice
from retail_datasets where Quantity >0;

select StockCode,sum(revenue) as total_revenue from retail_datasets
where Quantity > 0
group by StockCode
order by total_revenue desc
limit 10;

select StockCode, sum(case when Quantity <0 then 1 else 0 end) *1.0/ count(*) as return_rate
from retail_datasets
group by StockCode
order by return_rate;


select
  StockCode,
  ABS(SUM(Quantity)) AS returned_units
from retail_datasets
where Quantity < 0
group by StockCode
order by returned_units desc;

select
	count(*) as total_customers,
    sum(order_counts = 1) as one_time_customer,
    sum(order_counts > 1) as repeated_customer
from(
	select CustomerID,count(distinct InvoiceNo) as order_counts
	from retail_datasets
	where CustomerId is not null
	group by CustomerID)T;
    
select
	CustomerId,
	sum(revenue) as customer_revenue
from retail_datasets
where Quantity  >0 and CustomerID is not null
group by CustomerID
order by customer_revenue desc;

select invoice_month,sum(revenue)
from retail_datasets where 
quantity > 0
group by invoice_month
order by invoice_month;

select 
	Country,
	sum(revenue) as revenue
from retail_datasets 
where Quantity >0
group by Country
order by revenue desc;

SELECT
    CustomerID,
    MAX(InvoiceDate) AS last_purchase_date
FROM retail_datasets
WHERE CustomerID IS NOT NULL
  AND Quantity > 0
GROUP BY CustomerID;

WITH customer_last_purchase AS (
    SELECT
        CustomerID,
        MAX(InvoiceDate) AS last_purchase_date
    FROM retail_datasets
    WHERE CustomerID IS NOT NULL
      AND Quantity > 0
    GROUP BY CustomerID
),
dataset_max_date AS (
    SELECT MAX(InvoiceDate) AS max_date
    FROM retail_datasets
)
SELECT
    c.CustomerID,
    c.last_purchase_date,
    CASE
        WHEN DATEDIFF(d.max_date, c.last_purchase_date) >= 90 THEN 1
        ELSE 0
    END AS is_churned
FROM customer_last_purchase c
CROSS JOIN dataset_max_date d;









