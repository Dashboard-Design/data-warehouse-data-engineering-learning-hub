/*

Stored Procedure that inserts data automatically to the silver layer


*/


create or alter procedure silver.load_silver as

begin

	declare @start_time datetime, @end_time datetime
	declare @pipeline_start_time datetime, @pipeline_end_time datetime

	begin try
	
	set @pipeline_start_time = getdate()

	print '==========================================================';
	print '>>> Loading Silver Layer CRM & ERP Tables'	
	print '==========================================================';

	set @start_time = GETDATE();

	-- inserting silver crm_prod_info
	truncate table silver.crm_prd_info
	insert into silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost, 
		prd_line,
		prd_start_dt,
		prd_end_dt 
	)
	select 
		prd_id,
		cat_id  = REPLACE(SUBSTRING(prd_key,1, 5), '-', '_'),
		prd_key = SUBSTRING(prd_key,7, len(prd_key)),
		prd_nm,
		prd_cost = ISNULL(prd_cost, 0), 
		prd_line =
		case
			upper(trim(prd_line))
			when 'M' then 'Mountain'
			when 'R' then 'Road'
			when 'S' then 'Other Sales'
			when 'T' then 'Touring'
			else 'n/a'
		end,
		prd_start_dt = cast( prd_start_dt as date ),
		prd_end_dt =
		cast ( lead(prd_start_dt,1) over( partition by prd_key order by prd_start_dt ) - 1 as date)

	from bronze.crm_prd_info

	set @end_time = GETDATE();
	print '>> Load Duration: ' + cast( datediff(second, @start_time, @end_time) as nvarchar )+ ' seconds';
	print '============================================================='

	set @start_time = GETDATE();
	-- inserting silver crm_cust_info
	truncate table silver.crm_cust_info
	insert into silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_material_status,
		cst_gndr,
		cst_create_date
	)
	select 
		cst_id,
		cst_key,
		TRIM(cst_firstname) as cst_first_name,
		TRIM(cst_lastname) as cst_last_name,
		case when upper(trim(cst_material_status)) = 'M' then 'Married'
			when upper(trim(cst_material_status)) = 'S' then 'Single'
			else 'n/a'
		end as cst_material_status,
		case when upper(trim(cst_gndr)) = 'M' then 'Male'
			 when upper(trim(cst_gndr)) = 'F' then 'Female'
			 else 'n/a'
		 end as cst_gndr,
		cst_create_date
	from 
		(
		 select *,
		 flag_last = ROW_NUMBER() over(partition by cst_id order by cst_create_date desc)
		 from bronze.crm_cust_info
		) a
	where flag_last = 1

	set @end_time = GETDATE();
	print '>> Load Duration: ' + cast( datediff(second, @start_time, @end_time) as nvarchar )+ ' seconds';
	print '============================================================='
	

	set @start_time = GETDATE();
	-- inserting silver crm_sls_details
	truncate table silver.crm_sales_details
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

	set @end_time = GETDATE();
	print '>> Load Duration: ' + cast( datediff(second, @start_time, @end_time) as nvarchar )+ ' seconds';
	print '============================================================='


	set @start_time = GETDATE();
	-- inserting erp_cust_az12
	truncate table silver.erp_cust_az12
	insert into silver.erp_cust_az12 (
		cid,
		bdate,
		gen
	)
	select 
		cid = 
		case 
			when cid like 'NAS%' then substring(cid, 4, len(cid)) 
			else cid
		end, 
		bdate =
		case 
			when bdate > GETDATE() then null
			else bdate
		end,	 
		gen = 
		case 
			when upper( trim(gen) ) in ('F','FEMALE') then 'Female'
			when upper( trim(gen) ) in ('M', 'MALE') then 'Male'
			else 'n/a'
		end
	from bronze.erp_cust_az12

	set @end_time = GETDATE();
	print '>> Load Duration: ' + cast( datediff(second, @start_time, @end_time) as nvarchar )+ ' seconds';
	print '============================================================='

	
	set @start_time = GETDATE();
	--- Inserting erp_loc_a101
	truncate table silver.erp_loc_a101  
	insert into silver.erp_loc_a101(
		cid,
		cntry
	)
	select 
		   cid = replace(cid, '-',''),
		   cntry =
		   case
				when upper(trim(cntry)) in ('US', 'USA', 'UNITED STATES')  then 'UNITED STATES'
				when upper(trim(cntry)) = 'DE' then 'Germany'
				when trim(cntry) ='' or cntry is null then 'n/a'
				else trim(cntry)
			end
	  from bronze.erp_loc_a101
	
	set @end_time = GETDATE();
	print '>> Load Duration: ' + cast( datediff(second, @start_time, @end_time) as nvarchar )+ ' seconds';
	print '============================================================='


	set @start_time = GETDATE();
	--- Inserting erp__px_cat_g1v2
	truncate table silver.erp_px_cat_g1v2
	insert into silver.erp_px_cat_g1v2(
		 id,
		 cat,
		 subcat,
		 maintenance	

	)
	select
		 id,
		 cat,
		 subcat,
		 maintenance
	from bronze.erp_px_cat_g1v2

	set @end_time = GETDATE();
	print '>> Load Duration: ' + cast( datediff(second, @start_time, @end_time) as nvarchar )+ ' seconds';
	print '============================================================='


	set @pipeline_end_time = getdate()
	print '>> Load Duration: ' + cast( datediff(second, @pipeline_start_time, @pipeline_end_time) as nvarchar )+ ' seconds';
	print '====================== End of Loading Data ==============================='
	

	end try

	
	begin catch
	
	print '>>>> Error Occured during loading bronze layer <<<<'
	print 'Error Message ' + error_message() 


	end catch


end


exec silver.load_silver