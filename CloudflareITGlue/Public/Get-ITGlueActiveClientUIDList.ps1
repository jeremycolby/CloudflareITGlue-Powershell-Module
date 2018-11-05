function Get-ITGlueActiveClientUIDList {
    $UIDList = @()
    $Request = New-ITGlueWebRequest -Endpoint 'organizations' -Method 'GET' | ForEach-Object data | Where-Object {
        $_.attributes.'organization-type-name' -eq 'Client'}

    foreach ($Response in $Request) {
        $UIDList += $Response.id + '__' + $Response.attributes.name
    }
    if($UIDList){
        try {
            $UIDList | Out-File 'ITGlueActiveClientUIDList.txt'
            Invoke-Item 'ITGlueActiveClientUIDList.txt'
        }
        catch {
            Write-Warning 'Unable to create ITGlueActiveClientUIDList.txt in current directory'
        }
    }
}
