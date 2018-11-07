function Get-ITGlueClientUIDList {
    $UIDList = @()
    $Progress = 0
    $Clients = New-ITGlueWebRequest -Endpoint 'organizations' -Method 'GET' | ForEach-Object data | Where-Object {
        $_.attributes.'organization-type-name' -eq 'Client'}

    foreach ($Client in $Clients) {
        Write-Progress -Activity 'ITGlueAPI' -Status 'Creating Client UID List' -CurrentOperation $Client.attributes.name -PercentComplete ($Progress / ($Clients | Measure-Object | ForEach-Object count) * 100)
        $UIDList += $Client.id + '__' + $Client.attributes.name
        $Progress++
    }
    if($UIDList){
        Write-Progress -Activity 'ITGlueAPI' -Status 'Complete' -PercentComplete 100
        try {
            $UIDList | Out-File 'ITGlueClientUIDList.txt'
            Invoke-Item 'ITGlueClientUIDList.txt'
        }
        catch {
            Write-Warning 'Unable to create ITGlueClientUIDList.txt in current directory'
        }
    }
}
