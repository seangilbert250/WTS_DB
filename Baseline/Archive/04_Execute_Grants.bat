@echo off
echo Executing Grants
sqlcmd -Q "SELECT 'Executing ..\..\Security\00_Grants.sql' GO" >> grants_scripts_output.txt
sqlcmd -S OMEGA -E -d WTS -i ..\..\Security\00_Grants.sql >> grants_scripts_output.txt
	
ECHO >> grants_scripts_output.txt

pause