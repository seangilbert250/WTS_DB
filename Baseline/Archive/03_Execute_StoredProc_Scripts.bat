@echo off
echo Executing Stored Procedure scripts

FOR %%G in (..\..\Procedures\*.sql) DO (
	echo Executing %%G
	sqlcmd -Q "SELECT 'Executing %%G' GO" >> storedProc_scripts_output.txt
	sqlcmd -S OMEGA -E -d WTS -i "%%G" -o storedProc_scripts_output.txt
	)
	
ECHO >> storedProc_scripts_output.txt

pause