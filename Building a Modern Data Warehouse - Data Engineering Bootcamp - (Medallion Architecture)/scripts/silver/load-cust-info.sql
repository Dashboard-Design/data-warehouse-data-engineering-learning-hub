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


/*         Quality Check Queries         */ 

-- checking unwanted spaces
-- expectation: No results

select cst_firstname
from bronze.crm_cust_info
where cst_firstname != TRIM(cst_firstname)


-- data standardization & consistency
select distinct cst_gndr
from bronze.crm_cust_info

-- checking unique primary keys

select cst_id, count(*)
from bronze.crm_cust_info
group by cst_id
having count(*) >1

/*
29449	2
29473	2
29433	2
NULL	3
29483	2
29466	3
*/