function Test-SQLDatabase()
{
	[cmdletbinding()]
	param ([string]$SqlInstance, [string]$DatabaseName)

	$query="IF EXISTS (SELECT name FROM master.sys.databases WHERE name = N'$DatabaseName')
			BEGIN
				SELECT 1
			END
			else
			begin
				select 0
			end"
	
	$r=Invoke-SQLQuery -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Query $query 
	if ($r[0] -eq 1)
	{
		return $true
	}
	else {
		return $false
	}
}

function Drop-SQLDatabase()
{
	[cmdletbinding()]
	param ([string]$SqlInstance,[string]$DatabaseName)

	Write-Verbose "Drop-Database command invoked"

	$test=Test-SQLDatabase -SqlInstance $SqlInstance -DatabaseName $DatabaseName  

	if ($test)
	{
		$query= "EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'$DatabaseName'"
		Invoke-SQLQuery -Query $query -SqlInstance $SqlInstance
		$query= "ALTER DATABASE [$DatabaseName] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
				 DROP DATABASE $DatabaseName"
		Invoke-SQLQuery -Query $query -SqlInstance $SqlInstance
	}
	else
	{
		Write-Verbose "Database $DatabaseName on the Instance $SqlInstance not exists"
	}

	Write-Verbose "Drop-Database command finished"
}

function New-SQLDatabase()
{
	[cmdletbinding()]
	param([string]$SqlInstance,[string]$DatabaseName,[string]$Path,[switch]$Force)

	Write-Verbose "New-Database command invoked"

	if ($Force -eq $true)
	{
		Drop-SQLDatabase -SqlInstance $SqlInstance -DatabaseName $DatabaseName
	}
	
	$test=Test-SQLDatabase -SqlInstance $SqlInstance -DatabaseName $DatabaseName  
	if ($test)
	{
		Write-Verbose "Database $DatabaseName on the Instance $SqlInstance exists"
	}
	else
	{
		$logName=$DatabaseName+"_log"

		$query= "CREATE DATABASE $DatabaseName
 				CONTAINMENT = NONE
 				ON  PRIMARY 
				( NAME = N'$DatabaseName', FILENAME = N'$Path\$DatabaseName.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 				LOG ON 
				( NAME = N'$logName', FILENAME = N'$Path\$logName.ldf' , SIZE = 1792KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
				GO"
		Invoke-SQLQuery -SqlInstance $SqlInstance -Query $query 
	}
	Write-Verbose "New-Database command finished"
}

function Test-SQLTable()
{
	[cmdletbinding()]
	param ([string]$SqlInstance, [string]$DatabaseName, [string]$SchemaName="dbo", [string]$TableName)

	$query="IF (EXISTS (SELECT TOP 1 * FROM INFORMATION_SCHEMA.TABLES 
				WHERE TABLE_SCHEMA = '$SchemaName' AND  TABLE_NAME = '$TableName'))
			BEGIN
				SELECT 1
			END
			else
			begin
				select 0
			end"
	
	$r=Invoke-SQLQuery -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Query $query 
	if ($r[0] -eq 1)
	{
		return $true
	}
	else {
		return $false
	}
}

function Drop-SQLTable()
{
	[cmdletbinding()]
	param ([string]$SqlInstance, [string]$DatabaseName, [string]$SchemaName="dbo", [string]$TableName)

	Write-Verbose "Drop-SQLTable command invoked"

	$test=Test-SQLTable -SqlInstance $SqlInstance -DatabaseName $DatabaseName -SchemaName $SchemaName -TableName $TableName

	if ($test)
	{
		$query="DROP TABLE [$SchemaName].[$TableName]"
		Invoke-SQLQuery -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Query $query 
	}
	else {
		Write-Verbose "Table $TableName with schema $SchemaName in the Database $DatabaseName on the Instance $SqlInstance not exists"
	}
	Write-Verbose "Drop-SQLTable command finished"
}

function New-SQLTable()
{
	[cmdletbinding()]
	param ([string]$SqlInstance, [string]$DatabaseName, [string]$SchemaName="dbo", [string]$TableName,[switch]$Force)
	Write-Verbose "New-SQLTable command invoked"

	if ($Force -eq $true)
	{
		Drop-SQLTable -SqlInstance $SqlInstance -DatabaseName $DatabaseName -SchemaName $SchemaName -TableName $TableName
	}
	
	New-SqlSchema -SqlInstance $SqlInstance -DatabaseName $DatabaseName -SchemaName $SchemaName -Verbose

	$id=$TableName+"Id"
	$query="CREATE TABLE [$SchemaName].[$TableName]($id INT IDENTITY(1,1) PRIMARY KEY)"
	Invoke-SQLQuery -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Query $query 
	Write-Verbose "New-SQLTable command finished"
}

function Test-SQLColumn()
{
	[cmdletbinding()]
	param ([string]$SqlInstance, [string]$DatabaseName, [string]$SchemaName="dbo",[string]$TableName, [string]$ColumnName, [string]$Type)

	$query="IF EXISTS(SELECT TOP 1 * FROM INFORMATION_SCHEMA.COLUMNS 
			WHERE [TABLE_NAME] = '$TableName'
			AND [COLUMN_NAME] = '$ColumnName'
			AND [TABLE_SCHEMA] = '$SchemaName')
			BEGIN
				SELECT 1
			END
			else
			begin
				select 0
			end"
	
	$r=Invoke-SQLQuery -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Query $query 
	if ($r[0] -eq 1)
	{
		return $true
	}
	else {
		return $false
	}
}

function Drop-SQLColumn()
{
	[cmdletbinding()]
	param ([string]$SqlInstance, [string]$DatabaseName, [string]$SchemaName="dbo",[string]$TableName, [string]$ColumnName, [string]$Type)

	Write-Verbose "Drop-Column command invoked"

	$test=Test-SQLColumn -SqlInstance $SqlInstance -DatabaseName $DatabaseName -SchemaName $SchemaName -TableName $TableName -Name $ColumnName

	if ($test)
	{
		$query="ALTER TABLE [$SchemaName].[$TableName] DROP COLUMN $ColumnName"
		Invoke-SQLQuery -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Query $query 
	}
	else {
		Write-Verbose "Column $ColumnName in Table $TableName with schema $SchemaName in the Database $DatabaseName on the Instance $SqlInstance not exists"
	}
	Write-Verbose "Drop-Column command finished"
}

function New-SqlColumn()
{
	[cmdletbinding()]
	param ([string]$SqlInstance, [string]$DatabaseName, [string]$SchemaName="dbo",[string]$TableName, [string]$ColumnName, [string]$Type,[switch]$Force)
	
	if ($Force -eq $true)
	{
		Drop-SQLColumn -SqlInstance $SqlInstance -DatabaseName $DatabaseName -SchemaName $SchemaName -TableName $TableName -ColumnName $ColumnName
	}
	
	$query="ALTER TABLE [$SchemaName].[$TableName] ADD [$ColumnName] $Type"
	Invoke-SQLQuery -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Query $query 
}

function Test-SqlSchema()
{
	[cmdletbinding()]
	param ([string]$SqlInstance, [string]$DatabaseName, [string]$SchemaName)

	$query="IF EXISTS (SELECT TOP 1 * FROM sys.schemas WHERE name = '$SchemaName')
			BEGIN
				SELECT 1
			END
			else
			begin
				select 0
			end"
	
	$r=Invoke-SQLQuery -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Query $query 
	if ($r[0] -eq 1)
	{
		return $true
	}
	else {
		return $false
	}
}

function Drop-SqlSchema()
{
	[cmdletbinding()]
	param ([string]$SqlInstance, [string]$DatabaseName, [string]$SchemaName)

	Write-Verbose "Drop-SqlSchema command invoked"

	$test=Test-SqlSchema -SqlInstance $SqlInstance -DatabaseName $DatabaseName -SchemaName $SchemaName  

	if ($test)
	{
		$query="DROP SCHEMA $SchemaName"
		Invoke-SQLQuery -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Query $query 
	}
	else {
		Write-Verbose "Schema $SchemaName in table $TableName in the Database $DatabaseName on the Instance $SqlInstance not exists"
	}
	Write-Verbose "Drop-SqlSchema command finished"
}

function New-SqlSchema()
{
	[cmdletbinding()]
	param ([string]$SqlInstance, [string]$DatabaseName, [string]$SchemaName="dbo")
	
	$test=Test-SqlSchema -SqlInstance $SqlInstance -DatabaseName $DatabaseName -SchemaName $SchemaName  
	if ($test)
	{
		Write-Verbose "Schema $SchemaName on the SqlInstance $SqlInstance in the DatabaseName $DatabaseName exists"
	}
	else 
	{
		$query="CREATE SCHEMA $SchemaName"
		Invoke-SQLQuery -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Query $query 
	}
}

function Invoke-SQLQuery()
{
	[cmdletbinding()]
	param ([string]$SqlInstance,[string]$DatabaseName,[string]$Query)
	

	Write-Verbose -Message "On the $SqlInstance Instance in the $DatabaseName Database following query executed:"
	Write-Verbose -Message "$query"

	if ($DatabaseName -eq $null -or $DatabaseName -eq "")
	{
		$r = return Invoke-Sqlcmd -ServerInstance $SqlInstance -Query $query
		return $r
	}
	else
	{
		$r = (Invoke-Sqlcmd -ServerInstance $SqlInstance -Database $DatabaseName -Query $query)
		return $r;
	}
}

function Ivoke-SQLScripts()
{
	[cmdletbinding()]
	param ([string]$SqlInstance,[string]$DatabaseName,[string]$Directory)
	
	$path="$directory\*.sql"
	$sqlFiles=Get-ChildItem -Path $path
	
	foreach($sql in $sqlFiles)
	{
		Invoke-Sqlcmd -ServerInstance $SqlInstance -Database $DatabaseName -InputFile $sql	
	}
}