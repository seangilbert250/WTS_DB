@echo off
echo Executing function scripts

FOR %%G in (..\..\Functions\*.sql) DO (
	echo Executing %%G
	sqlcmd -Q "SELECT 'Executing %%G' GO" >> function_scripts_output.txt
	sqlcmd -S OMEGA -E -d WTS -i "%%G" -o function_scripts_output.txt
	)
	
ECHO >> function_scripts_output.txt

pause