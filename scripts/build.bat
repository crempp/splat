@echo off

:: Settings
set MSBUILD_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe"
SET BUILD_DEPS="-include=HTML5 -exclude=Linux -exclude=IOS  -exclude=Android -exclude=Mac"

set ENGINE_DIRECTORY=C:\TMP_BUILD\Engine
set ENGINE_REPO="https://github.com/EpicGames/UnrealEngine.git"
set ENGINE_CHECKOUT="4.22"

set PROJECT_DIRECTORY=C:\TMP_BUILD\Game
set PROJECT_REPO="git@github.com:crempp/splat.git"
set PROJECT_CHECKOUT="HEAD"
set PROJECT_NAME=splat

set ARCHIVE_DIRECTORY=C:\TMP_BUILD\Archive

set "ORIG_DIR=%cd%"

:: Ensure the directories exists
if not exist %ENGINE_DIRECTORY% (
	mkdir %ENGINE_DIRECTORY%
)
if not exist %PROJECT_DIRECTORY% (
	mkdir %PROJECT_DIRECTORY%
)
if not exist %ARCHIVE_DIRECTORY% (
	mkdir %ARCHIVE_DIRECTORY%
)
:: =======================================================================
:: STEP 1 - Setup
::     Clone the engine and game source and setup the build environment
::     You must have Visual Studio and the .NET Developer pack installed
::     https://www.microsoft.com/en-us/download/details.aspx?id=53321
:: =======================================================================

cd %ENGINE_DIRECTORY%

:: Checkout or update the engine
if exist %ENGINE_DIRECTORY%\Setup.bat (
	echo Updating the engine...
	cd %ENGINE_DIRECTORY%
	git fetch origin
	git pull origin %ENGINE_CHECKOUT%
	git submodule update --init --recursive
) ELSE (
	echo Cloning the engine from git...
	git clone %ENGINE_REPO% %ENGINE_DIRECTORY%

	echo Checking out the requested commit...
	cd %ENGINE_DIRECTORY%
	git checkout %ENGINE_CHECKOUT%
	git submodule update --init --recursive

	echo Adding dependencies...
	Setup.bat %BUILD_DEPS%
)

:: Checkout or update the project
if exist %PROJECT_DIRECTORY%\README.md (
	echo Updating the project...
	cd %PROJECT_DIRECTORY%
	git fetch origin
	git pull origin %PROJECT_CHECKOUT%
	git submodule update --init --recursive
) ELSE (
	echo Cloning the project from git...
	git clone %PROJECT_REPO% %PROJECT_DIRECTORY%

	echo Checking out the requested commit...
	cd %PROJECT_DIRECTORY%
	git checkout %PROJECT_CHECKOUT%
	git submodule update --init --recursive
)

:: Build Engine
GenerateProjectFiles.bat
%MSBUILD_PATH% UE4.sln

:: Move to project directory
cd %PROJECT_DIRECTORY%


:: =======================================================================
:: STEP 2 - Start Build
::     This step runs UnrealBuildTool.exe (through Build.bat)
::     https://ericlemes.com/2018/11/23/understanding-unreal-build-tool/
:: =======================================================================
REM%ENGINE_DIRECTORY%\Engine\Build\BatchFiles\Build.bat ^
REM    -projectfiles ^
REM	   -project=%PROJECT_DIRECTORY%\%PROJECT_NAME%.uproject ^
REM	   -game ^
REM	   -rocket ^
REM	   -progress
:: C:\TMP_BUILD\Engine\Engine\Build\BatchFiles\Build.bat -projectfiles -project=C:\TMP_BUILD\Game\splat.uproject -game -rocket -progress


:: =======================================================================
:: STEP 3 - Compile scripts
::     
:: =======================================================================
REM %MSBUILD_PATH% %PROJECT_DIRECTORY%\%PROJECT_NAME%.sln ^
REM     /t:build ^
REM     /p:Platform=Win64;verbosity=diagnostic
:: "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe" "C:\Source\PROJECT_NAME\PROJECT_NAME.sln" /t:build /p:Platform=Win64;verbosity=diagnostic


:: =======================================================================
:: STEP 4 - Build Files
::     
:: =======================================================================
%ENGINE_DIRECTORY%\Engine\Build\BatchFiles\RunUAT.bat ^
     BuildCookRun ^
	 -project=%PROJECT_DIRECTORY%\%PROJECT_NAME%.uproject ^
	 -noP4 ^
	 -platform=Win64 ^
	 -clientconfig=Development ^
	 -cook ^
	 -allmaps ^
	 -build ^
	 -stage ^
	 -pak ^
	 -archive ^
	 -archivedirectory=%ARCHIVE_DIRECTORY%
:: C:\TMP_BUILD\Engine\Engine\Build\BatchFiles\RunUAT.bat  BuildCookRun -project="C:\TMP_BUILD\Game\splat.uproject" -noP4 -platform=Win64 -clientconfig=Development -cook -allmaps -build -stage -pak -archive -archivedirectory="C:\TMP_BUILD\Archive"

:: =======================================================================
:: STEP 5 - Cook Project
::     
:: =======================================================================
%ENGINE_DIRECTORY%\Engine\Build\BatchFiles\RunUAT.bat ^
    BuildCookRun ^
	-project=%PROJECT_DIRECTORY%\%PROJECT_NAME%.uproject ^
	-noP4 ^
	-platform=Win64 ^
	-clientconfig=Development ^
	-cook ^
	-allmaps ^
	-NoCompile ^
	-stage ^
	-pak ^
	-archive ^
	-archivedirectory=%ARCHIVE_DIRECTORY%
::C:\TMP_BUILD\Engine\Engine\Build\BatchFiles\RunUAT.bat BuildCookRun -project="C:\TMP_BUILD\Game\splat.uproject" -noP4 -platform=Win64 -clientconfig=Development -cook -allmaps -NoCompile -stage -pak -archive -archivedirectory="C:\TMP_BUILD\Archive\splat"














cd %ORIG_DIR%