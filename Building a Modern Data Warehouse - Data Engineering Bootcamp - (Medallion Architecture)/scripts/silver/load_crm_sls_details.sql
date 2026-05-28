insert into silver.crm_sales_details (

	sls_prd_key,
	sls_cust_id,
	sls_ord_num,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
)
select 
	sls_prd_key,
	sls_cust_id,
	sls_ord_num,
	sls_order_dt = 
	case
		when sls_order_dt = 0 then null
		when len(sls_order_dt) != 8 then null
		else cast( cast( sls_order_dt as varchar ) as date)
	end,
	sls_ship_dt = 
	case
		when sls_ship_dt = 0 then null
		when len(sls_ship_dt) != 8 then null
		else cast( cast( sls_ship_dt as varchar ) as date)
	end,
	sls_due_dt = 
	case
		when sls_due_dt = 0 then null
		when len(sls_due_dt) != 8 then null
		else cast( cast( sls_due_dt as varchar ) as date)
	end,
	sls_sales = 
	case 
		when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price)
		then abs(sls_price) * sls_quantity
		else sls_sales
	end,
	sls_quantity,
	sls_price =
	case 
		when sls_price is null or sls_price = 0 then sls_sales / nullif(sls_quantity,0)
		when sls_price < 0 then abs(sls_price)
		else sls_price
	end

from bronze.crm_sales_details



/*   ====================   */
/*   Data Quality Checks   */
/*  ====================  */

select 
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ord_num,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
from bronze.crm_sales_details
where sls_prd_key not in (select prd_key from silver.crm_prd_info) 


select 
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ord_num,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
from bronze.crm_sales_details
where sls_cust_id not in (select cst_id from silver.crm_cust_info) 


select 
	sls_order_dt
from bronze.crm_sales_details
where 	sls_order_dt = 0 or len(sls_order_dt) != 8 or sls_order_dt > 20500101



select 
	sls_order_dt
from bronze.crm_sales_details
where 	sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt



select 
	sls_sales,
	sls_price,
	sls_quantity
from bronze.crm_sales_details
where 	sls_sales != sls_price * sls_quantity 
		or sls_sales is null or sls_quantity is null or sls_price is null
		or sls_sales<=0  or sls_quantity<=0 or sls_price<=0
order by sls_sales, sls_price, sls_quantity