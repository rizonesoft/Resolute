@echo off
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_FILE=%SCRIPT_DIR%MemBoost.au3"
set "LOG_FILE=%SCRIPT_DIR%build.log"
set "AUTOIT_DIR="
set "SCITE_DIR="

call :find_autoit_dir || exit /b 1

set "AUTOIT_EXE=%AUTOIT_DIR%AutoIt3.exe"
if not exist "%AUTOIT_EXE%" (
    echo [ERROR] Could not find AutoIt3.exe in "%AUTOIT_EXE%".
    echo [ERROR] Ensure AutoIt is installed or set AUTOIT3DIR before running this script.
    exit /b 1
)

call :find_scite_dir || exit /b 1
set "AUTOIT_WRAPPER=%SCITE_DIR%AutoIt3Wrapper\AutoIt3Wrapper.au3"
if not exist "%AUTOIT_WRAPPER%" (
    echo [ERROR] AutoIt3Wrapper was not found at "%AUTOIT_WRAPPER%".
    echo [ERROR] Please install SciTE4AutoIt3 or adjust AUTOIT3DIR to a location that contains AutoIt3Wrapper.
    exit /b 1
)

if not exist "%SCRIPT_FILE%" (
    echo [ERROR] Unable to locate MemBoost.au3 at "%SCRIPT_FILE%".
    exit /b 1
)

pushd "%SCRIPT_DIR%" >nul
echo [INFO] Building Memory Booster... > "%LOG_FILE%"
echo [INFO] Using AutoIt at "%AUTOIT_EXE%" >> "%LOG_FILE%"
echo [INFO] Wrapper script "%AUTOIT_WRAPPER%" >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"
"%AUTOIT_EXE%" "%AUTOIT_WRAPPER%" /NoStatus /prod /in "%SCRIPT_FILE%" >> "%LOG_FILE%" 2>&1
set "BUILD_EXIT=%ERRORLEVEL%"
popd >nul

if not "%BUILD_EXIT%"=="0" (
    echo [ERROR] Build failed. See build.log for details.
    type "%LOG_FILE%"
    exit /b %BUILD_EXIT%
)

echo [SUCCESS] Build completed. Outputs should be in the Resolute folder.
echo [SUCCESS] Full log stored at "%LOG_FILE%".
exit /b 0

:find_autoit_dir
if defined AUTOIT3DIR (
    set "AUTOIT_DIR=%AUTOIT3DIR%"
    goto :normalize_autoit
)
if defined AUTOITDIR (
    set "AUTOIT_DIR=%AUTOITDIR%"
    goto :normalize_autoit
)
for %%K in ("HKLM\SOFTWARE\AutoIt v3\AutoIt" "HKLM\SOFTWARE\WOW6432Node\AutoIt v3\AutoIt") do (
    for /f "tokens=2,*" %%A in ('reg query %%~K /v InstallDir 2^>nul ^| find /i "InstallDir"') do (
        set "AUTOIT_DIR=%%B"
    )
    if defined AUTOIT_DIR goto :normalize_autoit
)

call :resolve_from_uninstall "AutoIt3\Uninstall.exe" AUTOIT_DIR
if defined AUTOIT_DIR goto :normalize_autoit
call :resolve_from_uninstall "AutoIt3\Beta\Uninstall.exe" AUTOIT_DIR
if defined AUTOIT_DIR goto :normalize_autoit

for %%I in (AutoIt3.exe) do if not defined AUTOIT_DIR (
    set "AUTOIT_EXE_PATH=%%~$PATH:I"
    if defined AUTOIT_EXE_PATH (
        for %%P in ("!AUTOIT_EXE_PATH!") do set "AUTOIT_DIR=%%~dpP"
    )
)
if defined AUTOIT_DIR goto :normalize_autoit

echo [ERROR] AutoIt installation not detected. Set AUTOIT3DIR or install AutoIt.
exit /b 1

:normalize_autoit
if not defined AUTOIT_DIR goto :find_autoit_dir_end
if not "%AUTOIT_DIR:~-1%"=="\" set "AUTOIT_DIR=%AUTOIT_DIR%\"
exit /b 0

:find_scite_dir
if defined SCITE_DIR goto :normalize_scite
set "SCITE_DIR=%AUTOIT_DIR%SciTE\"
if exist "%SCITE_DIR%AutoIt3Wrapper\AutoIt3Wrapper.au3" goto :normalize_scite
set "SCITE_DIR="
call :resolve_from_uninstall "AutoIt3\SciTE\uninst.exe" SCITE_DIR
if defined SCITE_DIR goto :normalize_scite
echo [ERROR] SciTE4AutoIt3 installation not detected. Install SciTE or set AUTOIT3DIR to a full AutoIt install.
exit /b 1

:normalize_scite
if not "%SCITE_DIR:~-1%"=="\" set "SCITE_DIR=%SCITE_DIR%\"
exit /b 0

:find_autoit_dir_end
echo [ERROR] AutoIt installation not detected. Set AUTOIT3DIR or install AutoIt.
exit /b 1

:resolve_from_uninstall
set "REG_PATTERN=%~1"
set "REG_TARGET=%~2"
for /f "usebackq tokens=* delims=" %%I in (`powershell -NoLogo -NoProfile -Command ^
    "$pattern = '%REG_PATTERN%';" ^
    "$keys = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall';" ^
    "$item = Get-ChildItem $keys -ErrorAction SilentlyContinue | ForEach-Object { Get-ItemProperty $_.PsPath } | Where-Object { $_.UninstallString -like ('*' + $pattern + '*') } | Select-Object -First 1;" ^
    "if ($item) { $loc = if ($item.InstallLocation) { $item.InstallLocation } elseif ($item.UninstallString) { Split-Path $item.UninstallString } else { '' }; if ($loc) { [Console]::WriteLine($loc) } }"` ) do (
    set "%REG_TARGET%=%%~I"
)
if defined %REG_TARGET% (
    call :ensure_trailing_backslash %REG_TARGET%
)
exit /b 0

:ensure_trailing_backslash
set "_VAR_NAME=%~1"
for /f "tokens=1,* delims==" %%A in ('set %_VAR_NAME% 2^>nul ^| findstr /B /I "%_VAR_NAME%="') do (
    set "_VAR_VALUE=%%B"
)
if not defined _VAR_VALUE exit /b 0
if "!_VAR_VALUE:~-1!"=="\" exit /b 0
set "%_VAR_NAME%=!_VAR_VALUE!\"
exit /b 0
