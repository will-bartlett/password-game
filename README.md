# The Password Game

This project is intented to demonstrate some basic concepts around personal account security and password hygiene.

## Automated deployment

The solution will be automatically deployed using GitHub actions when a push or completed pull request to the `main` branch occurs.

### GitHub workflow setup

To setup the GitHub Actions project deployment workflow for automated deployment to Azure, do the following:

(These command use the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli).)

1. **Create a service principal for Terraform deployment:**
```bash
# Create Service Principal 
az ad sp create-for-rbac --name http://YOUR_SERVICE_PRINCIPAL_NAME
```
Note service principal appId, name, password, and tenant for use in the other steps.

2. **Create a storage account where Terraform state will be saved:**
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
Note the storage account name for use in step 4.

3. **Create a resource group where the solution will be deployed:**
```bash
# Create Resource Group
az group create -n YOUR_RESOURCE_GROUP_NAME -l westus2

# Assign the Serivce Principal access
az role assignment create --assignee http://YOUR_SERVICE_PRINCIPAL_NAME --role Contributor -g YOUR_RESOURCE_GROUP_NAME
```
Note the resource group name for use in step 4.

4. **Add the following secrets to your GitHub repository** ([GitHub docs](https://docs.github.com/en/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-a-repository)):
- `ARM_TENANT_ID`: Your Azure AD tenant ID
- `ARM_CLIENT_ID`: Your service principal app ID
- `ARM_CLIENT_SECRET`: Your service principal password
- `ARM_SUBSCRIPTION_ID`: Your Azure subscription ID
- `AZURE_TFSTATE_RESOURCE_GROUP`: The resource group name you created in step 2
- `AZURE_TFSTATE_STORAGE_ACCOUNT`: The storage account you created in step 2
- `AZURE_RESOURCE_GROUP`: The resource group name you created in step 3
