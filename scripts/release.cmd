@echo off
setlocal

set "RELEASE_SCRIPT=%~dp0release"
set "BASH_EXE="

for /f "delims=" %%G in ('where git.exe 2^>nul') do (
	if not defined BASH_EXE if exist "%%~dpG..\bin\bash.exe" set "BASH_EXE=%%~dpG..\bin\bash.exe"
)

for %%B in (
	"%ProgramFiles%\Git\bin\bash.exe"
	"%ProgramFiles%\Git\usr\bin\bash.exe"
	"%LocalAppData%\Programs\Git\bin\bash.exe"
	"%LocalAppData%\Programs\Git\usr\bin\bash.exe"
) do (
	if not defined BASH_EXE if exist "%%~B" set "BASH_EXE=%%~B"
)

if not defined BASH_EXE (
	echo release: Git Bash is required. Install Git for Windows and try again. 1>&2
	exit /b 1
)

"%BASH_EXE%" "%RELEASE_SCRIPT%" %*
exit /b %ERRORLEVEL%
