#
# Runner.ps1
#
clear
Write-Host "pawel"
cd $PSScriptRoot
Import-Module ".\SQLCommands.psm1" -Force
#New-SQLDatabase -SqlInstance ".\sql2014" -DatabaseName "paweltest123" -Path "d:\trash" -Verbose -Force
New-SQLTable  -SqlInstance ".\sql2014" -DatabaseName "paweltest123" -TableName "table1" -Verbose -Force
#New-SqlColumn -SqlInstance ".\sql2014" -DatabaseName "paweltest123" -TableName "table1" -ColumnName "Column1" -Type "Varchar(20) NOT NULL" -Verbose -Force
#Drop-Database -SqlInstance ".\sql2014" -DatabaseName "paweltest123" -Verbose