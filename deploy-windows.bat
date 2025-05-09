@echo off
setlocal enabledelayedexpansion

echo ===================================================
echo UI-TARS Desktop Windows Deployment Script
echo ===================================================
echo This script will help you set up and deploy UI-TARS Desktop on Windows.
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Node.js is not installed or not in PATH.
    echo Please install Node.js v20 or later from https://nodejs.org/
    echo After installation, restart this script.
    pause
    exit /b 1
)

REM Check Node.js version
for /f "tokens=*" %%i in ('node -v') do set NODE_VERSION=%%i
echo Node.js version: %NODE_VERSION%
echo.

REM Check if pnpm is installed
where pnpm >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo PNPM is not installed. Installing it now...
    npm install -g pnpm
    if %ERRORLEVEL% neq 0 (
        echo Failed to install pnpm. Please install it manually with:
        echo npm install -g pnpm
        pause
        exit /b 1
    )
    echo PNPM installed successfully.
) else (
    echo PNPM is already installed.
)
echo.

REM Create .env file with user input
echo Setting up environment variables...
echo.

REM Check if .env file already exists
if exist .env (
    echo An existing .env file was found.
    set /p OVERWRITE=Do you want to overwrite it? (y/n): 
    if /i "!OVERWRITE!" neq "y" (
        echo Keeping existing .env file.
        goto SKIP_ENV_SETUP
    )
)

echo Please provide the following information for your .env file:
echo.

REM VLM Provider
echo Available VLM providers:
echo 1. OpenAI
echo 2. Azure OpenAI
echo 3. Anthropic
echo 4. Mistral
echo 5. DeepSeek
echo 6. Gemini
echo 7. HuggingFace
set /p VLM_PROVIDER_NUM=Enter the number of your VLM provider (default: 1): 

if "!VLM_PROVIDER_NUM!"=="" set VLM_PROVIDER_NUM=1

if "!VLM_PROVIDER_NUM!"=="1" (
    set VLM_PROVIDER=openai
) else if "!VLM_PROVIDER_NUM!"=="2" (
    set VLM_PROVIDER=azure
) else if "!VLM_PROVIDER_NUM!"=="3" (
    set VLM_PROVIDER=anthropic
) else if "!VLM_PROVIDER_NUM!"=="4" (
    set VLM_PROVIDER=mistral
) else if "!VLM_PROVIDER_NUM!"=="5" (
    set VLM_PROVIDER=deepseek
) else if "!VLM_PROVIDER_NUM!"=="6" (
    set VLM_PROVIDER=gemini
) else if "!VLM_PROVIDER_NUM!"=="7" (
    set VLM_PROVIDER=huggingface
) else (
    echo Invalid selection. Using OpenAI as default.
    set VLM_PROVIDER=openai
)

echo.
echo Selected VLM Provider: !VLM_PROVIDER!
echo.

REM API Key
set /p VLM_API_KEY=Enter your !VLM_PROVIDER! API Key: 
if "!VLM_API_KEY!"=="" (
    echo API Key cannot be empty.
    pause
    exit /b 1
)

REM Base URL (optional for some providers)
if "!VLM_PROVIDER!"=="huggingface" (
    set /p VLM_BASE_URL=Enter your HuggingFace endpoint URL: 
) else if "!VLM_PROVIDER!"=="azure" (
    set /p VLM_BASE_URL=Enter your Azure OpenAI endpoint URL: 
) else if "!VLM_PROVIDER!"=="openai" (
    set /p VLM_BASE_URL=Enter your OpenAI API URL (press Enter for default): 
    if "!VLM_BASE_URL!"=="" set VLM_BASE_URL=https://api.openai.com/v1
) else (
    set VLM_BASE_URL=
)

REM Model Name
if "!VLM_PROVIDER!"=="openai" (
    set /p VLM_MODEL_NAME=Enter the model name (default: gpt-4-vision-preview): 
    if "!VLM_MODEL_NAME!"=="" set VLM_MODEL_NAME=gpt-4-vision-preview
) else if "!VLM_PROVIDER!"=="azure" (
    set /p VLM_MODEL_NAME=Enter the Azure deployment name: 
) else if "!VLM_PROVIDER!"=="anthropic" (
    set /p VLM_MODEL_NAME=Enter the model name (default: claude-3-opus-20240229): 
    if "!VLM_MODEL_NAME!"=="" set VLM_MODEL_NAME=claude-3-opus-20240229
) else if "!VLM_PROVIDER!"=="mistral" (
    set /p VLM_MODEL_NAME=Enter the model name (default: mistral-large-latest): 
    if "!VLM_MODEL_NAME!"=="" set VLM_MODEL_NAME=mistral-large-latest
) else if "!VLM_PROVIDER!"=="deepseek" (
    set /p VLM_MODEL_NAME=Enter the model name (default: deepseek-v2): 
    if "!VLM_MODEL_NAME!"=="" set VLM_MODEL_NAME=deepseek-v2
) else if "!VLM_PROVIDER!"=="gemini" (
    set /p VLM_MODEL_NAME=Enter the model name (default: gemini-pro-vision): 
    if "!VLM_MODEL_NAME!"=="" set VLM_MODEL_NAME=gemini-pro-vision
) else if "!VLM_PROVIDER!"=="huggingface" (
    set /p VLM_MODEL_NAME=Enter your HuggingFace model name: 
)

REM Additional Azure settings if needed
if "!VLM_PROVIDER!"=="azure" (
    set /p AZURE_API_VERSION=Enter Azure API version (default: 2023-05-15): 
    if "!AZURE_API_VERSION!"=="" set AZURE_API_VERSION=2023-05-15
)

REM Create .env file
echo Creating .env file...
(
    echo VLM_PROVIDER=!VLM_PROVIDER!
    echo VLM_API_KEY=!VLM_API_KEY!
    if not "!VLM_BASE_URL!"=="" echo VLM_BASE_URL=!VLM_BASE_URL!
    echo VLM_MODEL_NAME=!VLM_MODEL_NAME!
    if "!VLM_PROVIDER!"=="azure" (
        echo AZURE_API_VERSION=!AZURE_API_VERSION!
    )
) > .env

echo .env file created successfully.
echo.

:SKIP_ENV_SETUP

REM Ask if user wants to install dependencies
set /p INSTALL_DEPS=Do you want to install dependencies? (y/n, default: y): 
if /i "!INSTALL_DEPS!"=="" set INSTALL_DEPS=y
if /i "!INSTALL_DEPS!"=="y" (
    echo Installing dependencies...
    call pnpm install
    if %ERRORLEVEL% neq 0 (
        echo Failed to install dependencies.
        pause
        exit /b 1
    )
    echo Dependencies installed successfully.
) else (
    echo Skipping dependency installation.
)
echo.

REM Ask if user wants to build the application
set /p BUILD_APP=Do you want to build the application? (y/n, default: y): 
if /i "!BUILD_APP!"=="" set BUILD_APP=y
if /i "!BUILD_APP!"=="y" (
    echo Building the application...
    
    REM Determine which app to build
    set /p BUILD_CHOICE=Which app do you want to build? (1 for agent-tars, 2 for ui-tars, default: 1): 
    if "!BUILD_CHOICE!"=="" set BUILD_CHOICE=1
    
    if "!BUILD_CHOICE!"=="1" (
        echo Building Agent TARS...
        call pnpm run dev:agent-tars
    ) else if "!BUILD_CHOICE!"=="2" (
        echo Building UI TARS...
        call pnpm run dev:ui-tars
    ) else (
        echo Invalid choice. Building Agent TARS by default...
        call pnpm run dev:agent-tars
    )
    
    if %ERRORLEVEL% neq 0 (
        echo Failed to build the application.
        pause
        exit /b 1
    )
    echo Application built successfully.
) else (
    echo Skipping application build.
)
echo.

REM Ask if user wants to package the application
set /p PACKAGE_APP=Do you want to package the application for distribution? (y/n, default: n): 
if /i "!PACKAGE_APP!"=="" set PACKAGE_APP=n
if /i "!PACKAGE_APP!"=="y" (
    echo Packaging the application...
    
    REM Determine which app to package
    if "!BUILD_CHOICE!"=="1" (
        echo Packaging Agent TARS...
        cd apps/agent-tars
        call pnpm run package
    ) else if "!BUILD_CHOICE!"=="2" (
        echo Packaging UI TARS...
        cd apps/ui-tars
        call pnpm run package
    ) else (
        echo Invalid choice. Packaging Agent TARS by default...
        cd apps/agent-tars
        call pnpm run package
    )
    
    if %ERRORLEVEL% neq 0 (
        echo Failed to package the application.
        cd ../..
        pause
        exit /b 1
    )
    cd ../..
    echo Application packaged successfully.
) else (
    echo Skipping application packaging.
)
echo.

echo ===================================================
echo Deployment process completed!
echo ===================================================
echo.
echo If you built the application, you can run it in development mode with:
echo - For Agent TARS: pnpm run dev:agent-tars
echo - For UI TARS: pnpm run dev:ui-tars
echo.
echo If you packaged the application, you can find the installer in:
echo - For Agent TARS: apps/agent-tars/out/
echo - For UI TARS: apps/ui-tars/out/
echo.
echo Thank you for using UI-TARS Desktop!
echo.

pause
endlocal
