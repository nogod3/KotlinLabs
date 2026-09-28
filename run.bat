@echo off
if not exist app.jar call build.bat
if errorlevel 1 exit /b 1
java -jar app.jar %*
exit /b %ERRORLEVEL%
