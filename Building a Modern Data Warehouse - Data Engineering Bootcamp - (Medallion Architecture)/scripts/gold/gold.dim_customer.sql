
-- after joining table, check if any duplicates were introduced by the join logic
create view gold.dim_customers as 
select 
    customer_key = row_number() over(order by cst_id asc), 
	customer_id = ci.cst_id,
	customer_number = ci.cst_key,
	first_name = ci.cst_firstname,
	last_name =	ci.cst_lastname,
	country = la.cntry,
	marital_status = ci.cst_material_status,
	gender = case when ci.cst_gndr != 'n/a' then ci.cst_gndr -- crm is the master for gender info
	else coalesce(ca.gen, 'n/a')
	end,
	birth_date =ca.bdate,
	create_date = ci.cst_create_date

from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca 
on ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
on ci.cst_key = la.cid
