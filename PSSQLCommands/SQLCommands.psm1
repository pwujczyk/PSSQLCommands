function Drop-Database()
{
	[cmdletbinding()]
	param ([string]$SqlInstance,[string]$DatabaseName,[string]$Path)

	Write-Verbose "Drop-Database command invoked"

	$query= "EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'$DatabaseName'"
	InvokeQuery -Query $query -SqlInstance $SqlInstance
	$query= "ALTER DATABASE [$DatabaseName] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
			 DROP DATABASE $DatabaseName"
	InvokeQuery -Query $query -SqlInstance $SqlInstance

	Write-Verbose "Drop-Database command finished"
}

function New-SQLDatabase()
{
	[cmdletbinding()]
	param ([string]$SqlInstance,[string]$DatabaseName,[string]$Path,[switch] $Force)

	Write-Verbose "New-Database command invoked"

	if ($Force -eq $true)
	{
		Drop-Database -SqlInstance $SqlInstance -DatabaseName $DatabaseName
	}

	$logName=$DatabaseName+"_log"

	$query= "CREATE DATABASE $DatabaseName
 			CONTAINMENT = NONE
 			ON  PRIMARY 
			( NAME = N'$DatabaseName', FILENAME = N'$Path\$DatabaseName.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 			LOG ON 
			( NAME = N'$logName', FILENAME = N'$Path\$logName.ldf' , SIZE = 1792KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
			GO"
	InvokeQuery -SqlInstance $SqlInstance -Query $query 
	Write-Verbose "New-Database command finished"
}

function Test-SQLTable()
{
	[cmdletbinding()]
	param ([string]$SqlInstance, [string]$DatabaseName, [string]$Schema="dbo", [string]$TableName)

	$query="IF (EXISTS (SELECT TOP 1 * FROM INFORMATION_SCHEMA.TABLES 
				WHERE TABLE_SCHEMA = '$Schema' AND  TABLE_NAME = '$TableName'))
			BEGIN
				SELECT 1
			END
			else
			begin
				select 0
			end"
	
	$r=InvokeQuery -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Query $query 
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
	param ([string]$SqlInstance, [string]$DatabaseName, [string]$Schema="dbo", [string]$TableName)

	Write-Verbose "Drop-SQLTable command invoked"

	$test=Test-SQLTable -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Schema $Schema -TableName $TableName

	if ($test)
	{
		$query="DROP TABLE [$Schema].[$TableName]"
		InvokeQuery -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Query $query 
	}
	else {
		Write-Verbose "Table $TableName with schema $Schema in the Database $DatabaseName on the Instance $SqlInstance not exists"
	}
	Write-Verbose "Drop-SQLTable command finished"
}

function New-SQLTable()
{
	[cmdletbinding()]
	param ([string]$SqlInstance, [string]$DatabaseName, [string]$Schema="dbo", [string]$TableName,[switch]$Force)
	Write-Verbose "New-SQLTable command invoked"

	if ($Force -eq $true)
	{
		Drop-SQLTable -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Schema $Schema -TableName $TableName
	}

	$id=$TableName+"Id"
	$query="CREATE TABLE [$Schema].[$TableName]($id INT IDENTITY(1,1) PRIMARY KEY)"
	InvokeQuery -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Query $query 
	Write-Verbose "New-SQLTable command finished"
}

function Test-SQLColumn()
{
	[cmdletbinding()]
	param ([string]$SqlInstance, [string]$DatabaseName, [string]$Schema="dbo",[string]$TableName, [string]$Name, [string]$Type)

	$query="IF EXISTS(SELECT TOP 1 * FROM INFORMATION_SCHEMA.COLUMNS 
			WHERE [TABLE_NAME] = '$TableName'
			AND [COLUMN_NAME] = '$Name'
			AND [TABLE_SCHEMA] = '$Schema')
			BEGIN
				SELECT 1
			END
			else
			begin
				select 0
			end"
	
	$r=InvokeQuery -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Query $query 
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
	param ([string]$SqlInstance, [string]$DatabaseName, [string]$Schema="dbo",[string]$TableName, [string]$ColumnName, [string]$Type)

	Write-Verbose "Drop-Column command invoked"

	$test=Test-SQLColumn -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Schema $Schema -TableName $TableName -Name $ColumnName

	if ($test)
	{
		$query="ALTER TABLE [$Schema].[$TableName] DROP COLUMN $ColumnName"
		InvokeQuery -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Query $query 
	}
	else {
		Write-Verbose "Column $ColumnName in Table $TableName with schema $Schema in the Database $DatabaseName on the Instance $SqlInstance not exists"
	}
	Write-Verbose "Drop-Column command finished"
}

function New-SqlColumn()
{
	[cmdletbinding()]
	param ([string]$SqlInstance, [string]$DatabaseName, [string]$Schema="dbo",[string]$TableName, [string]$ColumnName, [string]$Type,[switch]$Force)
	
	if ($Force -eq $true)
	{
		Drop-SQLColumn -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Schema $Schema -TableName $TableName -ColumnName $ColumnName
	}
	
	$query="ALTER TABLE [$Schema].[$TableName] ADD $ColumnName $Type"
	InvokeQuery -SqlInstance $SqlInstance -DatabaseName $DatabaseName -Query $query 

}

function InvokeQuery([string]$SqlInstance,[string]$DatabaseName,[string]$Query)
{
	Write-Verbose -Message "On the $SqlInstance Instance in the $DatabaseName Database following query executed:"
	Write-Verbose -Message "$query"

	if ($DatabaseName -eq $null -or $DatabaseName -eq "")
	{
		$r= return Invoke-Sqlcmd -ServerInstance $SqlInstance -Query $query
	}
	else
	{
		$r= (Invoke-Sqlcmd -ServerInstance $SqlInstance -Database $DatabaseName -Query $query)
		return $r;
	}
}