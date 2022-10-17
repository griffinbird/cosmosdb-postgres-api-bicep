## Prerequisite
- Azure CLI
- Bicep extension

## Deploy
Enter the following command into your terminal. 
```sh
az deployment group create -g pg-demo -f cdb-pg-api.bicep
```
Follow the prompts, such as entering in a cluster name.