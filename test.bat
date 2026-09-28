@echo off
setlocal EnableDelayedExpansion

if not exist app.jar call build.bat
if errorlevel 1 exit /b 1

set /a PASSED=0
set /a TOTAL=10

call :test "successful access" 0 "--login alice --password qwerty --action read --resource A.B.C --volume 10"
call :test "help" 1 "--help"
call :test "wrong password" 2 "--login alice --password wrong --action read --resource A --volume 1"
call :test "wrong login" 3 "--login unknown --password qwerty --action read --resource A --volume 1"
call :test "unknown action" 4 "--login alice --password qwerty --action delete --resource A --volume 1"
call :test "access denied" 5 "--login alice --password qwerty --action write --resource PUBLIC --volume 1"
call :test "missing resource" 6 "--login alice --password qwerty --action read --resource A.UNKNOWN --volume 1"
call :test "invalid resource format" 7 "--login alice --password qwerty --action read --resource A..B --volume 1"
call :test "invalid volume" 7 "--login alice --password qwerty --action read --resource A --volume text"
call :test "volume exceeded" 8 "--login alice --password qwerty --action read --resource A.B.C --volume 21"

echo !PASSED!/!TOTAL!
if !PASSED! EQU !TOTAL! exit /b 0
exit /b 1

:test
set "NAME=%~1"
set "EXPECTED=%~2"
set "ARGS=%~3"
call run.bat !ARGS! >nul 2>nul
set "ACTUAL=!ERRORLEVEL!"
if "!ACTUAL!"=="!EXPECTED!" (
    echo OK   !NAME! ^(code !ACTUAL!^)
    set /a PASSED+=1
) else (
    echo FAIL !NAME! ^(expected !EXPECTED!, got !ACTUAL!^)
)
exit /b 0
