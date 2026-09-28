@echo off
setlocal

set "CLI_JAR=lib\kotlinx-cli-jvm-0.3.6.jar"

if defined KOTLIN_HOME (
    set "KOTLINC=%KOTLIN_HOME%\bin\kotlinc.bat"
) else (
    set "KOTLINC=kotlinc.bat"
)

if not exist "%CLI_JAR%" (
    echo Library not found: %CLI_JAR%
    exit /b 1
)

if exist .build rmdir /s /q .build
mkdir .build\fatjar

call "%KOTLINC%" src\Main.kt -cp "%CLI_JAR%" -include-runtime -d .build\app-base.jar
if errorlevel 1 exit /b 1

pushd .build\fatjar
jar xf ..\app-base.jar
jar xf ..\..\%CLI_JAR%
del /q META-INF\*.SF META-INF\*.RSA META-INF\*.DSA 2>nul
jar cfe ..\..\app.jar MainKt .
set "RESULT=%ERRORLEVEL%"
popd

if not "%RESULT%"=="0" exit /b %RESULT%
echo Build completed: app.jar
exit /b 0
