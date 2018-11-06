function Get-ITGlueClientUIDList {
    $UIDList = @()
    $Request = New-ITGlueWebRequest -Endpoint 'organizations' -Method 'GET' | ForEach-Object data | Where-Object {
        $_.attributes.'organization-type-name' -eq 'Client'}

    foreach ($Response in $Request) {
        $UIDList += $Response.id + '__' + $Response.attributes.name
    }
    if($UIDList){
        try {
            $UIDList | Out-File 'ITGlueClientUIDList.txt'
            Invoke-Item 'ITGlueClientUIDList.txt'
        }
        catch {
            Write-Warning 'Unable to create ITGlueClientUIDList.txt in current directory'
        }
    }
}