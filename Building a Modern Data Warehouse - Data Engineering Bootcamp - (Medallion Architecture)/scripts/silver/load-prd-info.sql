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



/* Data Quality Check */

-- 1
select *,
	prd_end_dt_test =
	 lead(prd_start_dt,1) over( partition by prd_key order by prd_start_dt )
from bronze.crm_prd_info
where prd_start_dt > prd_end_dt

-- 2
select distinct prd_line
from bronze.crm_prd_info

-- 3
select prd_key, prd_cost
from bronze.crm_prd_info
where prd_cost < 0 or prd_cost is null

-- 4
select prd_key, prd_nm
from bronze.crm_prd_info
where prd_nm != TRIM(prd_nm)