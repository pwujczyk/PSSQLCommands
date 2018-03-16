Module helps to perform basic operations on the SQL Server. It wraps SQL queries into methods. Using this module instead of invoking query:

`CREATE TABLE [schema].[TableName] (TableNameId INT IDENTITY(1,1) PRIMARY KEY`

We can use method

`New-SQLTable -SqlInstance "localhost" -DatabaseName "TableName" -SchemaName "schema"`


Methods are protected against invoking them twice. So before adding column, checks is performed if column doesn’t already exist.

* Test-SQLDatabase – checks if database exists returns $true or false
* Drop-SQLDatabase – drop database if exists. If database not exist nothing happens. If -Verbose parameter used information showed about this fact on the screen.
* New-SQLDatabase – create database if database exists nothing is done. If -Force parameter is used, before create Drop-SqlDatabase is invoked
* Test-SQLTable – checks if table with given name and schema exists
* Drop-SQLTable – drops table if table doesn’t exist nothing happens
* New-SQLTable – create new table if -Force is used first Drop-SQLTable is invoked. If used schema doesn’t exist it will be created (New-SQLSchema is invoked) Table is created only with primary key and one column Add-SQLColumn can be combined to create full table
* Test-SQLColumn – checks if column exists
* Drop-SQLColumn – drops column if column doesn’t exist nothing happen
* New-SQLColumn – create new column if -Force parameter is used Drop-SQL Column is invoked before creation
* Test-SqlSchema – checks if schema exists
* Drop-SqlSchema – drops schema if schema doesn’t exist nothing happen
* New-SqlSchema – create new schema
* Invoke-SQLQuery – ivokes query
* Ivoke-SQLScripts  – it takes all scripts from given directory and invoke them one by one

More information on the page: http://www.productivitytools.tech/sql-commands-in-powershell/
