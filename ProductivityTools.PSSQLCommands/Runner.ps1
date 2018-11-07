#
# Runner.ps1
#
clear
Write-Host "pawel"
cd $PSScriptRoot
Import-Module ".\ProductivityTools.PSSQLCommands.psm1" -Force
Test-SQLDatabase -SqlInstance ".\sql2017" -DatabaseName "pawel"
#New-SQLDatabase -SqlInstance ".\sql2014" -DatabaseName "paweltest123" -Path "d:\trash" -Verbose -Force
New-SQLTable  -SqlInstance ".\sql2014" -DatabaseName "paweltest123" -TableName "table1" -Verbose -Force
New-SqlSchema -SqlInstance ".\sql2014" -DatabaseName "paweltest123" -SchemaName "pawel" -Verbose -force
#New-SqlColumn -SqlInstance ".\sql2014" -DatabaseName "paweltest123" -TableName "table1" -ColumnName "Column1" -Type "Varchar(20) NOT NULL" -Verbose -Force
#Drop-Database -SqlInstance ".\sql2014" -DatabaseName "paweltest123" -Verbose

