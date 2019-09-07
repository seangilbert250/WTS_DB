@ECHO OFF

setlocal

REM Get DateTime

FOR /F "TOKENS=1,2 DELIMS=/ " %%A IN ('DATE /T') DO SET mm=%%B
FOR /F "TOKENS=2,3 DELIMS=/ " %%A IN ('DATE /T') DO SET dd=%%B
FOR /F "TOKENS=3* DELIMS=/ " %%A IN ('DATE /T') DO SET yyyy=%%B

set yyyy=%yyyy:~0,4%
set d=%dd%-%mm%-%yyyy%

set t=%time%
set dt=%d%%t%

REM Build Tag Name

REM Get Custom Tag Details from user
set /p custom_TagDetails=Enter Custom Tag Details(NO / Characters) 
if defined custom_TagDetails (set custom_TagDetails=: %custom_TagDetails%)

REM Get Custom Description Details from user
set /p custom_DescriptionDetails=Enter Custom Description Details(NO / Characters)
if defined custom_DescriptionDetails (set custom_DescriptionDetails=: %custom_DescriptionDetails%)


set defaultTag=Posted Prod Updated
REM defaultTag=%defaultTag%

set tagName=%defaultTag% %custom_TagDetails%%d%

REM tagName=%tagName%


REM Create Production Tag
ECHO Creating new tag from WTS_SQL_DB Development-Production Branch: "%tagName%"
c:
cd "C:\Program Files\TortoiseSVN\bin"
svn move https://dev.cafdex.com:9443/svn/ITI_Folsom/LOCAL/Database/WTS_SQL_DB/branches/Production/ https://dev.cafdex.com:9443/svn/ITI_Folsom/LOCAL/Database/WTS_SQL_DB/tags/Production/"%tagName%" -m "Moved Production Source from Production Branch in order to bring in Updated source: %d%at%t%%custom_DescriptionDetails%"


endlocal


PAUSE