# CloudflareITGlue

## What does this do?
- Sync Cloudflare DNS Zones to ITGlue Client Organizations as Flex Assets with revision history

[Screenshot of FA here]

## How to use:
- Configure
- Schedule the sync command to run at an interval of your choosing


## Configuration
[Install Module](#install-module)  
[API Auth](#api-auth)  
[Create Flex Asset Type](#create-flex-asset-type)  
[Match Cloudflare DNS Zones to ITGlue Client Orgs](#match-cloudflare-dns-zones-to-itglue-client-orgs)  
[Sync](#sync)  

##
#### Install Module
Copy the module folder (CloudflareITGlue) to a Powershell module directory
>View Powershell Module directories with: `$env:PSModulePath -split ';'`

Lets use `%ProgramFiles%\WindowsPowerShell\Modules` 

##
#### API Auth
Obtain API Keys:
- Cloudflare API Key
	>1. Login to Cloudflare.
	>2. Go to  **My Profile**.
	>3. Scroll down to  **API Keys**  and locate  _Global API Key_.
	>4. Select  **API Key**  to see your API identifier.

- ITGlue API Key
	>1. Login to ITGlue.
	>2. Select the **Account** tab.
	>3. Select the **API Keys** tab.
	>4. Select the **+** symbol to add a new API Key.
	>5. Enter a name in the **Enter Name** field.
	>6. Select **Generate API Key** (Note: The API Key will only show in full when being generated)

Once ready with the API keys:

```powershell
Add-CloudflareITGlueAPIAuth
```
>This will prompt you for your info (API keys + Cloudflare email). The API keys will be encrypted and stored in the module directory.  Requires admin access for file creation.

```powershell
Get-CloudflareITGlueAPIAuth
```
>View Auth Info, API keys not shown in full.  
>(Not required for configuration)

```powershell
Remove-CloudflareITGlueAPIAuth
```
>Removes the auth info file from the module directory.  Requires admin access to delete file.  
>(Not required for configuration)
##
#### Create Flex Asset Type
##
#### Match Cloudflare DNS Zones to ITGlue Client Orgs
- Get Client UID List
- Get match table
- Set ClientUID TXT Record
#### Sync
##



## References
[Cloudflare API](https://api.cloudflare.com/)  
[ITGlue API](https://api.itglue.com/developer/)  
[Invoke-RestMethod](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod/)  
