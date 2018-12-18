function Get-PDKDevices {
    Param(
        # Your PDK ClientId
        [Parameter(Mandatory = $true)]
        [string]
        $PDKClientId,
        # Your PDK Client Secret
        [Parameter(Mandatory = $true)]
        [string]
        $PDKClientSecret,
        # Your PDK Panel Id
        [Parameter(Mandatory = $true)]
        [string]
        $PDKPanelId,
        # A PDK Panel Web Session Object
        [Parameter(Mandatory = $false)]
        [psobject]
        $PDKPanelSession
    )

    if (!$PDKPanelSession){
        $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
    }
    elseif (((Get-Date) -ge [datetime]($PDKPanelSession.expires_at).AddSeconds(-5))){
        $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
    }
    elseif ($PDKPanelSession.id -ne $PDKPanelId){
        $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
    }

    $PDKDevicesEndpoint = "$($PDKPanelSession.uri)api/devices?page=0&per_page=50"
    $Headers = @{
        "Authorization" = "Bearer $($PDKPanelSession.panel_token)"
    }

    $PDKDevicesObject = @()
    $PDKDevicesResponse = Invoke-WebRequest -Method Get -Uri $PDKDevicesEndpoint -Headers $Headers -ContentType "application/json" -UseBasicParsing
    $PDKDevicesObjectCount = $PDKDevicesResponse.Headers.'X-Total-Count'
    $PDKDevicesObject += ($PDKDevicesResponse.Content | ConvertFrom-Json)

    if ($PDKDevicesResponse.Headers.Link){
            $Links = @()
            ($PDKDevicesResponse.Headers.Link -split ',').Trim() | ForEach-Object {
            $Link = ($_ -split ';')
            $Link = New-Object psobject -Property @{"Link"=((($Link[0]) -replace '<','' -replace '>','')).Trim()
                                                    "Relation"=(($Link[1]) -replace "rel=`"","" -replace "`"","").Trim()}
            $Links += $Link
            }
        
        $PDKDevicesNextPage = ($Links | ? {$_.Relation -eq 'next'}).Link
    }

    while ($null -ne $PDKDevicesNextPage){

        $PDKDevicesResponse = Invoke-WebRequest -Method Get -Uri $PDKDevicesNextPage -Headers $Headers -ContentType "application/json" -UseBasicParsing
        $PDKDevicesObject += ($PDKDevicesResponse.Content | ConvertFrom-Json)

        if ($PDKDevicesResponse.Headers.Link){
            $Links = @()
            ($PDKDevicesResponse.Headers.Link -split ',').Trim() | ForEach-Object {
            $Link = ($_ -split ';')
            $Link = New-Object psobject -Property @{"Link"=((($Link[0]) -replace '<','' -replace '>','')).Trim()
                                                    "Relation"=(($Link[1]) -replace "rel=`"","" -replace "`"","").Trim()}
            $Links += $Link
            }
        
        $PDKDevicesNextPage = ($Links | Where-Object {$_.Relation -eq 'next'}).Link
        }

        else {$PDKDevicesNextPage = $null}
    }

    if ($PDKDevicesObject.Count -ne $PDKDevicesObjectCount){

        throw "Failed to query all Devices from PDK panel $PDKPanelId"

    }

    return $PDKDevicesObject | Select-Object id,port,delay,dwell,dps,rex,name,connection,forcedAlarm,autoOpenAfterFirstAllow,propAlarm,propDelay,partition,@{N='panelId';E={$PDKPanelId}},@{N='panelName';E={$PDKPanelSession.name}}
}

function Get-PDKDevice {
    Param(
        # Your PDK ClientId
        [Parameter(Mandatory = $true)]
        [string]
        $PDKClientId,
        # Your PDK Client Secret
        [Parameter(Mandatory = $true)]
        [string]
        $PDKClientSecret,
        # Your PDK Panel Id
        [Parameter(Mandatory = $true)]
        [string]
        $PDKPanelId,
        # Your PDK Device Id
        [Parameter(Mandatory = $true)]
        [int]
        $PDKDeviceId,
        # A PDK Panel Web Session Object
        [Parameter(Mandatory = $false)]
        [psobject]
        $PDKPanelSession
    )

    if (!$PDKPanelSession){
        $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
    }
    elseif (((Get-Date) -ge [datetime]($PDKPanelSession.expires_at).AddSeconds(-5))){
        $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
    }
    elseif ($PDKPanelSession.id -ne $PDKPanelId){
        $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
    }

    $PDKDevicesEndpoint = "$($PDKPanelSession.uri)api/devices/$($PDKDeviceId)"
    $Headers = @{
        "Authorization" = "Bearer $($PDKPanelSession.panel_token)"
    }

    $PDKDevicesResponse = (Invoke-WebRequest -Method Get -Uri $PDKDevicesEndpoint -Headers $Headers -ContentType "application/json" -UseBasicParsing).Content | ConvertFrom-Json
    $PDKDevicesResponse
}

Export-ModuleMember -Function Get-PDKDevices,Get-PDKDevice