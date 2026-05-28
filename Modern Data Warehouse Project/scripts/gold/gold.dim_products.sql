create view gold.dim_products as
select
	 product_key = ROW_NUMBER() over(order by pn.prd_start_dt, pn.prd_key ),
	 product_id = pn.prd_id,
	 product_number = pn.prd_key,
	 product_name = pn.prd_nm,
	 category_id = pn.cat_id,
	 category = pc.cat,
	 subcategory = pc.subcat,
	 pc.maintenance,
	 cost = pn.prd_cost,
	 product_line = pn.prd_line,
	 start_date = pn.prd_start_dt
from silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 pc
       on pn.cat_id = pc.id 
where pn.prd_end_dt is null    -- making sure that not to include history of the product prices in the gold layer
