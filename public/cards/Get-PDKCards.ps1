function Get-PDKCards {
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

    $PDKCards = Get-PDKUsers -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -PDKPanelSession $PDKPanelSession | ForEach-Object {Invoke-WebRequest -Method Get -Uri "$($PDKPanelSession.uri)api/persons/$($_.id)/cards" -Headers @{"Authorization" = "Bearer $($PDKPanelSession.panel_token)"} -ContentType "application/json" -UseBasicParsing}
    
    return $PDKCards
}

Export-ModuleMember -Function 'Get-PDKCards'