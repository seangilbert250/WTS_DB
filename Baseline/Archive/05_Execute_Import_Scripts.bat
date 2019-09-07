@echo off
echo Executing data import scripts

FOR %%G in (DataInitialization\*.sql) DO (
	echo Executing %%G
	sqlcmd -Q "SELECT 'Executing %%G' GO" >> import_scripts_output.txt
	sqlcmd -S OMEGA -E -d WTS -I -x -i "%%G" >> import_scripts_output.txt
	)
	
ECHO >> import_scripts_output.txt

pause