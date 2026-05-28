
drop view if exists gold.fact_sales

create view gold.fact_sales as
select 
	order_number = sd.sls_ord_num,
	pr.product_key,
	cu.customer_key,
	order_date = sd.sls_order_dt,
	shipping_date = sd.sls_ship_dt,
	due_date = sd.sls_due_dt,
	sales_amount = sd.sls_sales,
	quantity = sd.sls_quantity,
	price = sd.sls_price
from silver.crm_sales_details sd
left join gold.dim_products pr
  on sd.sls_prd_key = pr.product_number
left join gold.dim_customers cu
  on sd.sls_cust_id = cu.customer_id




--- testing 

  select *
  from gold.fact_sales f
  left join gold.dim_products p 
    on f.product_key = p.product_key 
 where p.product_key is null