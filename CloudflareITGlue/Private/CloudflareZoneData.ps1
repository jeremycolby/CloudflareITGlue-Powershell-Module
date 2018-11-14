function Get-CloudflareZoneData {
    param(
        [Parameter(Mandatory = $true)][string]$ZoneId,
        [Parameter(Mandatory = $true)][pscustomobject]$ITGDomains
    )
    
    $Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-M-d HH:mm:ss")
    $ZoneInfo = New-CloudflareWebRequest -Endpoint "zones/$ZoneId"
    $ZoneRecords = New-CloudflareWebRequest -Endpoint "zones/$ZoneId/dns_records"
    $ZoneFileData = New-CloudflareWebRequest -Endpoint "zones/$ZoneId/dns_records/export"
    $OrgMatchId = $null
    $DomainTrackerId = $null
    
    foreach($ITGDomain in $ITGDomains){
        if($ZoneInfo.result.name.ToLower() -eq $ITGDomain.attributes.name.ToLower()){
            $OrgMatchId = $ITGDomain.attributes.'organization-id'
            $DomainTrackerId = $ITGDomain.id
        }
    }
    
    $ZoneFileData = $ZoneFileData.Replace(
        "@	3600	IN	SOA	$($ZoneInfo.result.name).	root.$($ZoneInfo.result.name).	(",
        "@	3600	IN	SOA	$($ZoneInfo.result.name_servers[0]). $((($CloudflareAPIEmail -split '@')[0]).Replace('.','\.') + '.'+ ($CloudflareAPIEmail -split '@')[1]). ("
    )
    $ZoneFileData = $ZoneFileData.Replace(
        ";; NS Records (YOU MUST CHANGE THIS)`n$($ZoneInfo.result.name).	1	IN	NS	" + 'REPLACE&ME$WITH^YOUR@NAMESERVER.',
        ";; NS Records`n$($ZoneInfo.result.name).	1	IN	NS	$($ZoneInfo.result.name_servers[0]).`n$($ZoneInfo.result.name).	1	IN	NS	$($ZoneInfo.result.name_servers[1])."
    )
    $ZoneFileData = $ZoneFileData.Replace(
        ';;   -- update the SOA record with the correct authoritative name server',
        ";;   -- update the SOA record with the correct authoritative name server`n;;   ** CloudflareITGlue Module: Updated $($Timestamp)"
    )
    $ZoneFileData = $ZoneFileData.Replace(
        ';;   -- update the SOA record with the contact e-mail address information',
        ";;   -- update the SOA record with the contact e-mail address information`n;;   ** CloudflareITGlue Module: Updated $($Timestamp)"
    )
    $ZoneFileData = $ZoneFileData.Replace(
        ';;   -- update the NS record(s) with the authoritative name servers for this domain.',
        ";;   -- update the NS record(s) with the authoritative name servers for this domain.`n;;   ** CloudflareITGlue Module: Updated $($Timestamp)"
    )
    $RecordsHtml = 
    '<div>
        <table id="RecordTable" style="width:100%">
            <thead>
                <th>Type</th>
                <th>Name</th>
                <th>Value</th>
                <th>Priority</th>
                <th>TTL</th>
                <th>Proxied</th>
                <th>Modified</th>
            </thead>
            <tbody>' +
            $(foreach ($Record in $ZoneRecords.result) {
                "<tr>
                    <td>$($Record.type)</td>
                    <td>$($Record.name)</td>
                    <td>$($Record.content)</td>
                    <td>$($Record.priority)</td>
                    <td>$(if ($Record.ttl -eq 1){'Auto'}else{$Record.ttl})</td>
                    <td>$($Record.proxied)</td>
                    <td>$(($Record.modified_on.Replace('T', ' ') -split '\.')[0])</td>
                </tr>"
            }) +
            '</tbody>
        </table>
    </div>'
    
    $ZoneData = [ordered]@{
        Name           = $ZoneInfo.result.name
        SyncDate       = $Timestamp
        CfNameServers  = $ZoneInfo.result.name_servers
        Status         = $ZoneInfo.result.status
        ZoneFileData   = $ZoneFileData
        RecordsHtml    = $RecordsHtml
        ITGOrg         = $OrgMatchId
        DomainTracker  = $DomainTrackerId
    }
    $ZoneData
}

function Get-CloudflareZoneDataArray {
    $ZoneDataArray = @()
    $AllZones = New-CloudflareWebRequest -Endpoint 'zones'
    [pscustomobject]$ITGDomains = New-ITGlueWebRequest -Endpoint 'domains' | ForEach-Object data

    $Progress = 0

    foreach ($Zone in $AllZones.result) {
        Write-Progress -Activity 'CloudflareAPI' -Status 'Getting Zone Data' -CurrentOperation $Zone.name -PercentComplete ($Progress / ($AllZones.result | Measure-Object | ForEach-Object count) * 100) -Id 1
        $ZoneData = Get-CloudflareZoneData -ZoneId $Zone.id -ITGDomains $ITGDomains
        if ($ZoneData) {
            $ZoneDataArray += New-Object psobject -Property $ZoneData
        }
        $Progress++
    }
    Write-Progress -Activity 'CloudflareAPI' -Status 'Complete' -PercentComplete 100 -Id 1
    $ZoneDataArray
}
