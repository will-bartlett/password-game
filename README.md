# The Password Game

This project is intended to demonstrate some basic concepts around personal account security and password hygiene.

## Local debugging
You can run and debug the entire solution locally using Azure Functions tools and the Azure Storage emulator.

### Setup your dev environment

1. Install the [Azure Storage Emulator](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-emulator#get-the-storage-emulator).
2. Install the [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Ccsharp%2Cbash#install-the-azure-functions-core-tools).
3. Install [NodeJS LTS](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Ccsharp%2Cbash#install-the-azure-functions-core-tools).
4. Install [Visual Studio Code]().

### Get a SignalR instance

To actually run the chat locally, you'll need an Azure SignalR instance. [Create an Azure SignalR](https://docs.microsoft.com/en-us/azure/azure-signalr/signalr-tutorial-authenticate-azure-functions#create-an-azure-signalr-service-instance) dev/test instance with the _Serverless_ service mode and take note of the connection string.

### Create Azure Functions settings

1. Copy the contents of `backend-api/example.settings.json` to `backend-api/local.settings.json`.
2. Replace the value `YOUR_SIGNALR_CONNECTION_STRING` with your connection string from the previous section.

### Build the shared package

Run the following to build:
```bash
pushd ./shared
npm install
npm run build
popd
```

### Run the solution

1. Start the Azure Storage Emulator by launching it from the start menu. An icon will appear in the taskbar.
2. In VS Code, start the `backend-api` by choosing `Debug backend-api` from the Run and Debug tab and pressing the green arrow button.
3. In VS Code, start the `cat-game` app by choosing `Debug cat-game` from the Run and Debug tab and pressing the green arrow button.
4. In VS Code, start the `dog-game` app by choosing `Debug dog-game` from the Run and Debug tab and pressing the green arrow button.

## Automated deployment

The solution will be automatically deployed using GitHub actions when a push or completed pull request to the `main` branch occurs.

### GitHub workflow setup

To setup the GitHub Actions project deployment workflow for automated deployment to Azure, do the following:

(These commands use the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli).)

1. **Create a service principal for Terraform deployment:**

Note the service principal's appId, name, password, and tenant for use in the following steps.
```bash
# Create Service Principal 
az ad sp create-for-rbac --name http://YOUR_SERVICE_PRINCIPAL_NAME
```

2. **Create a storage account where Terraform state will be saved:**

Note the storage account name for use in step 4.

```bash
# Create Resource Group
az group create -n YOUR_RESOURCE_GROUP_NAME -l westus2
 
# Create Storage Account
az storage account create -n YOUR_STORAGE_ACCOUNT_NAME -g YOUR_RESOURCE_GROUP_NAME --sku Standard_LRS
 
# Create Storage Account Container
az storage container create -n tfstate --account-name YOUR_STORAGE_ACCOUNT_NAME

# Assign the Serivce Principal access
az role assignment create --assignee http://YOUR_SERVICE_PRINCIPAL_NAME --role Contributor -g YOUR_RESOURCE_GROUP_NAME
```

3. **Create a resource group where the solution will be deployed:**

_Use a different resource group name than step 2 otherwise the Terraform deployment will break._

Note the resource group name for use in step 4.

```bash
# Create Resource Group
az group create -n YOUR_RESOURCE_GROUP_NAME -l westus2

# Assign the Serivce Principal access
az role assignment create --assignee http://YOUR_SERVICE_PRINCIPAL_NAME --role Contributor -g YOUR_RESOURCE_GROUP_NAME
```
4. **Add the following secrets to your GitHub repository** ([GitHub docs](https://docs.github.com/en/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-a-repository)):

- `ARM_TENANT_ID`: Your Azure AD tenant ID
- `ARM_CLIENT_ID`: Your service principal app ID
- `ARM_CLIENT_SECRET`: Your service principal password
- `ARM_SUBSCRIPTION_ID`: Your Azure subscription ID
- `AZURE_TFSTATE_RESOURCE_GROUP`: The resource group name you created in step 2
- `AZURE_TFSTATE_STORAGE_ACCOUNT`: The storage account you created in step 2
- `AZURE_RESOURCE_GROUP`: The resource group name you created in step 3
