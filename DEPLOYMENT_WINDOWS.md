# UI-TARS Desktop Windows Deployment Guide

This guide explains how to deploy UI-TARS Desktop on Windows using the provided deployment script.

## Prerequisites

Before running the deployment script, ensure you have the following installed:

- **Node.js** (v20 or later) - [Download from nodejs.org](https://nodejs.org/)
- **Git** - [Download from git-scm.com](https://git-scm.com/downloads)

## Deployment Steps

1. **Clone the Repository**

   ```bash
   git clone https://github.com/zeeeepa/UI-TARS-desktop.git
   cd UI-TARS-desktop
   ```

2. **Run the Deployment Script**

   Double-click on `deploy-windows.bat` or run it from the command prompt:

   ```bash
   .\deploy-windows.bat
   ```

3. **Follow the Interactive Prompts**

   The script will guide you through the following steps:
   
   - Checking and installing prerequisites (Node.js, pnpm)
   - Setting up environment variables in a `.env` file
   - Installing dependencies
   - Building the application
   - Optionally packaging the application for distribution

## Environment Variables

During the deployment process, you'll be prompted to enter the following information:

- **VLM Provider**: Choose from OpenAI, Azure OpenAI, Anthropic, Mistral, DeepSeek, Gemini, or HuggingFace
- **API Key**: Your API key for the selected provider
- **Base URL**: The endpoint URL (required for some providers)
- **Model Name**: The name of the model to use

For Azure OpenAI, you'll also need to provide:
- **Azure API Version**: The API version to use (default: 2023-05-15)

## Running the Application

After deployment, you can run the application in development mode with:

- For Agent TARS: `pnpm run dev:agent-tars`
- For UI TARS: `pnpm run dev:ui-tars`

If you packaged the application, you can find the installer in:
- For Agent TARS: `apps/agent-tars/out/`
- For UI TARS: `apps/ui-tars/out/`

## Troubleshooting

If you encounter any issues during deployment:

1. **Dependency Installation Failures**
   - Try running `pnpm install` manually
   - Check your internet connection
   - Ensure you have the latest version of Node.js and pnpm

2. **Build Failures**
   - Check the error messages in the console
   - Ensure all required environment variables are set correctly
   - Try running the build command manually: `pnpm run dev:agent-tars` or `pnpm run dev:ui-tars`

3. **Packaging Failures**
   - Ensure you have sufficient disk space
   - Check if you have the necessary permissions to write to the output directory
   - Try running the package command manually from the appropriate app directory

## Additional Resources

- [UI-TARS Documentation](https://github.com/bytedance/UI-TARS/blob/main/README_deploy.md)
- [Agent TARS Quick Start Guide](https://agent-tars.com/doc/quick-start)
- [UI-TARS Model Deployment Guide](https://bytedance.sg.larkoffice.com/docx/TCcudYwyIox5vyxiSDLlgIsTgWf)

## Support

If you need further assistance, please:

1. Check the [GitHub Issues](https://github.com/zeeeepa/UI-TARS-desktop/issues) for known problems and solutions
2. Create a new issue if your problem hasn't been reported

Thank you for using UI-TARS Desktop!

