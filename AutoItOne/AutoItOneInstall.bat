@echo off
echo Setting up AutoIt environment variables and file associations...

:: Set environment variables permanently using setx
setx SciTE_HOME "%~dp0SciTE"
setx SciTE_USERHOME "%~dp0SciTE"

:: Create file association for .au3 files
ftype AutoIt3Script="%~dp0SciTE\SciTE.exe" "%%1"
assoc .au3=AutoIt3Script

:: Set the icon for .au3 files
reg add "HKCR\AutoIt3Script\DefaultIcon" /ve /t REG_SZ /d "%~dp0SciTE\au3script_v11.ico" /f

echo Setup complete!
echo Please restart any open command prompts for the environment variables to take effect.
pause 