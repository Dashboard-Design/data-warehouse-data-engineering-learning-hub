/*

bulk inserting data to the bronze layer

*/

create or alter procedure bronze.load_bronze as

Begin

	declare @start_time datetime, @end_time datetime
	declare @pipeline_start_time datetime, @pipeline_end_time datetime

	begin try
	
	set @pipeline_start_time = getdate()

	print '==========================================================';
	print '>>> Loading Bronze Layer CRM Tables'	
	print '==========================================================';

	set @start_time = GETDATE();
	truncate table bronze.crm_cust_info
	bulk insert bronze.crm_cust_info
	from 'D:\. Courses\Udemy - Building a Modern Data Warehouse - Data Engineering Bootcamp 2025-3\01. Introduction\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
	with ( 
		firstrow = 2,
		fieldterminator = ',',
		tablock
	)
	set @end_time = GETDATE();

	print '>> Load Duration: ' + cast( datediff(second, @start_time, @end_time) as nvarchar )+ ' seconds';
	print '============================================================='

	set @start_time = GETDATE();
	truncate table bronze.crm_prd_info
	bulk insert bronze.crm_prd_info
	from 'D:\. Courses\Udemy - Building a Modern Data Warehouse - Data Engineering Bootcamp 2025-3\01. Introduction\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	with ( 
		firstrow = 2,
		fieldterminator = ',',
		tablock
	)
	set @end_time = GETDATE();
	print '>> Load Duration: ' + cast( datediff(second, @start_time, @end_time) as nvarchar )+ ' seconds';
	print '============================================================='

	set @start_time = GETDATE();
	truncate table bronze.crm_sales_details;
	bulk insert bronze.crm_sales_details
	from 'D:\. Courses\Udemy - Building a Modern Data Warehouse - Data Engineering Bootcamp 2025-3\01. Introduction\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
	with ( 
		firstrow = 2,
		fieldterminator = ',',
		tablock
	)
	set @end_time = GETDATE();
	print '>> Load Duration: ' + cast( datediff(second, @start_time, @end_time) as nvarchar )+ ' seconds';
	print '============================================================='

	print '==========================================================';
	print '>>> Loading Bronze Layer ERP Tables'	
	print '==========================================================';


	set @start_time = GETDATE();
	truncate table bronze.erp_cust_az12;
	bulk insert bronze.erp_cust_az12
	from 'D:\. Courses\Udemy - Building a Modern Data Warehouse - Data Engineering Bootcamp 2025-3\01. Introduction\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
	with ( 
		firstrow = 2,
		fieldterminator = ',',
		tablock
	)
	set @end_time = GETDATE();
	print '>> Load Duration: ' + cast( datediff(second, @start_time, @end_time) as nvarchar )+ ' seconds';
	print '============================================================='


	set @start_time = GETDATE();
	truncate table bronze.erp_loc_a101;
	bulk insert bronze.erp_loc_a101
	from 'D:\. Courses\Udemy - Building a Modern Data Warehouse - Data Engineering Bootcamp 2025-3\01. Introduction\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
	with ( 
		firstrow = 2,
		fieldterminator = ',',
		tablock
	)
	set @end_time = GETDATE();
	print '>> Load Duration: ' + cast( datediff(second, @start_time, @end_time) as nvarchar )+ ' seconds';
	print '============================================================='

	set @start_time = GETDATE();
	truncate table bronze.erp_px_cat_g1v2;
	bulk insert bronze.erp_px_cat_g1v2
	from 'D:\. Courses\Udemy - Building a Modern Data Warehouse - Data Engineering Bootcamp 2025-3\01. Introduction\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
	with ( 
		firstrow = 2,
		fieldterminator = ',',
		tablock
	)
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

END;


exec bronze.load_bronze