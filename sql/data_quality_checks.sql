-- D1. 行数与时间范围
select count(*) as total_rows, min(sale_date) as earliest_date, max(sale_date) as latest_date, COUNT(DISTINCT date_trunc('month', sale_date)) as number_month
from fact_sales

-- D2. 主键唯一性
select count(*) as total_rows, count(distinct sale_id) as distinct_sale
from fact_sales

select sale_id, count(*) as repeat_sale
from fact_sales
group by sale_id 
having repeat_sale>1

-- D3. 每列空值数
SELECT COUNT(*) - COUNT(sale_id)            AS null_sale_id,
       COUNT(*) - COUNT(sale_date)          AS null_sale_date,
       COUNT(*) - COUNT(customer_id)        AS null_customer_id,
       COUNT(*) - COUNT(product_id)         AS null_product_id,
       COUNT(*) - COUNT(port_id)            AS null_port_id,
       COUNT(*) - COUNT(tonnes_wet)         AS null_tonnes_wet,
       COUNT(*) - COUNT(moisture_pct)       AS null_moisture_pct,
       COUNT(*) - COUNT(price_rmb_per_wmt)  AS null_price,
       COUNT(*) - COUNT(amount_rmb)         AS null_amount,
       COUNT(*) - COUNT(index_usd_per_dmt)  AS null_index,
       COUNT(*) - COUNT(usd_cny_rate)       AS null_fx_rate,
       COUNT(*) - COUNT(salesperson)        AS null_salesperson,
       COUNT(CASE WHEN TRIM(salesperson) = '' THEN 1 END) AS blank_salesperson
FROM fact_sales;

-- D4a. 数值列范围
SELECT MIN(tonnes_wet)          AS min_tonnes,
       MAX(tonnes_wet)          AS max_tonnes,
       AVG(tonnes_wet)          AS avg_tonnes,
       MIN(moisture_pct)        AS min_moisture,
       MAX(moisture_pct)        AS max_moisture,
       AVG(moisture_pct)        AS avg_moisture,
       MIN(price_rmb_per_wmt)   AS min_price,
       MAX(price_rmb_per_wmt)   AS max_price,
       AVG(price_rmb_per_wmt)   AS avg_price,
       MIN(amount_rmb)          AS min_amount,
       MAX(amount_rmb)          AS max_amount,
       AVG(amount_rmb)          AS avg_amount
FROM fact_sales;


-- E1 case when练习
with deal_sep as (SELECT sale_id, tonnes_wet,
       CASE WHEN tonnes_wet >= 30000 THEN '大单'
            WHEN tonnes_wet >= 10000 THEN '中单'
            ELSE '小单'
 		END AS deal_size
		FROM fact_sales)
select deal_size, count(deal_size) as deal_num from deal_sep
group by deal_size 

-- E2 case when年成交量
with year_num as (select 	sale_id, 
							sale_date,
						CASE WHEN date_trunc('year', sale_date) = 2025 then '2025成交量'
							 WHEN date_trunc('year', sale_date) = 2026 then '2026成交量'
							 ELSE '非近两年'
							 END AS sales_size
							 from fact_sales)
select * from year_num
							 
							 
							 
							 select sales_num, count(sales_size) as sales_num from year_num 
group by sales_num 


select * from fact_sales

SELECT COUNT(CASE WHEN year(sale_date) = 2025 THEN 1 END) AS cnt_2025,
       COUNT(CASE WHEN year(sale_date) = 2026 THEN 1 END) AS cnt_2026
FROM fact_sales;


-- D4b 业务合理性
select 	count(case when tonnes_wet <=0 then 1 end) as bad_tonnes,
		count(case when moisture_pct <0 or moisture_pct>15 then 1 end) as bad_moisture,
		count(case when price_rmb_per_wmt <=0 then 1 END) as bad_price,
		count(case when ABS(amount_rmb - price_rmb_per_wmt * tonnes_wet) > 1 then 1 END) as bad_amount
from fact_sales


-- D5 分类列的值清单
Select salesperson, count(sale_id) as num_sale 
from fact_sales
group by salesperson
order by num_sale desc

-- D5b
Select COUNT(DISTINCT salesperson), COUNT(DISTINCT TRIM(salesperson)) from fact_sales

--D5c
select customer_type, count(customer_type) from dim_customer
group by customer_type

--D6 月成交量
select 	date_trunc('month', sale_date) as month, 
		count (sale_id) as num_sales_month, 
		AVG(num_sales_month) OVER () as avg_num_sales, 
		case when num_sales_month < 0.5*avg_num_sales or num_sales_month > 1.5*avg_num_sales then '异常'
		else '正常'
		end as "月成交量是否正常"
from fact_sales
group by "month" 
order by "month" ASC 

--D6 (a)
WITH monthly AS (
    SELECT date_trunc('month', sale_date) AS month,
           COUNT(*) AS num_sales_month
    FROM fact_sales
    GROUP BY 1
),
with_avg AS (
    SELECT month, num_sales_month,
           AVG(num_sales_month) OVER () AS avg_num_sales
    FROM monthly
)
SELECT *,
       CASE WHEN num_sales_month < 0.5 * avg_num_sales
              OR num_sales_month > 1.5 * avg_num_sales THEN '异常'
            ELSE '正常'
       END AS month_status
FROM with_avg
ORDER BY month

--D6 (b)有没有未来日期
select COUNT(CASE WHEN sale_date > current_date THEN 1 END) as future_dates
from fact_sales

--D7 外键完整性
SELECT 	COUNT(CASE WHEN dim_customer.customer_id IS NULL THEN 1 END) AS orphan_customer,
		COUNT(CASE WHEN dim_product.product_id IS NULL THEN 1 END) AS orphan_product,
		COUNT(CASE WHEN dim_port.port_id IS NULL THEN 1 END) AS orphan_port
FROM fact_sales
LEFT JOIN dim_customer ON fact_sales.customer_id = dim_customer.customer_id
LEFT JOIN dim_product ON fact_sales.product_id = dim_product.product_id
LEFT JOIN dim_port ON fact_sales.port_id = dim_port.port_id


select* from fact_sales