@ECHO OFF

setlocal

REM Get DateTime

FOR /F "TOKENS=1,2 DELIMS=/ " %%A IN ('DATE /T') DO SET mm=%%B
FOR /F "TOKENS=2,3 DELIMS=/ " %%A IN ('DATE /T') DO SET dd=%%B
FOR /F "TOKENS=3* DELIMS=/ " %%A IN ('DATE /T') DO SET yyyy=%%B

set yyyy=%yyyy:~0,4%
set d=%dd%-%mm%-%yyyy%

set t=%time%



REM Create Production Branch
ECHO Creating new Production Branch from WTS_SQL_DB_DB Trunk
c:
cd "C:\Program Files\TortoiseSVN\bin"
svn copy https://dev.cafdex.com:9443/svn/ITI_Folsom/LOCAL/Database/WTS_SQL_DB/trunk https://dev.cafdex.com:9443/svn/ITI_Folsom/LOCAL/Database/WTS_SQL_DB/branches/Production -m "Production Branch from Deployed Source on %d% at %t%"



endlocal


PAUSE