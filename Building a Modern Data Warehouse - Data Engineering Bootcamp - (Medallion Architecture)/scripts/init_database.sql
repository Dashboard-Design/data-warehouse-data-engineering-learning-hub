/*

Creates new database & schemas (bronze, silver, gold)

*/


use master;
go

create database DataWarehouse;

go
use Datawarehouse;

-- creating schemas
go
create schema bronze;

go
create schema silver;

go
create schema gold;