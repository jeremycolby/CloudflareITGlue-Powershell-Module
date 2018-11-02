function Get-CloudflareITGlueMatchingTable {
    $ZoneMatchMatrix = @()
    $AllZones = New-CloudflareWebRequest -Endpoint 'zones'
    
    foreach ($Zone in $AllZones.result) {
        
        $ZoneRecords = New-CloudflareWebRequest -Endpoint "zones/$($Zone.id)/dns_records"
        $ITGlueClientUIDRecord = $null

        foreach ($Record in $ZoneRecords.result) {
            if ($Record.name -eq "itglueclientuid.$($Record.zone_name)" -and $Record.content) {
                $ITGlueClientUIDRecord = $Record.content
            }
        }
        $Row = [ordered]@{
            ZoneId          = $Zone.id
            ZoneName        = $Zone.name
            ITGlueClientUID = $ITGlueClientUIDRecord
        }
        $ZoneMatchMatrix += New-Object psobject -Property $Row
    }
    if($ZoneMatchMatrix){
        try {
            $ZoneMatchMatrix | Export-Csv 'ITGlueCloudflareMatchingTable.csv' -NoTypeInformation
            Invoke-Item 'ITGlueCloudflareMatchingTable.csv'
        }
        catch {
            Write-Warning 'Unable to create ITGlueCloudflareMatchingTable.csv in current directory'
        }
    }
}