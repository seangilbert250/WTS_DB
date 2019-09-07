@echo off
echo Executing Table creation scripts

FOR %%G in (TableScripts\*.sql) DO (
	echo Executing %%G
	sqlcmd -Q "SELECT 'Executing %%G' GO" >> table_scripts_output.txt
	sqlcmd -S OMEGA -E -d WTS -i "%%G" >> table_scripts_output.txt
	)
	
ECHO >> table_scripts_output.txt

pause