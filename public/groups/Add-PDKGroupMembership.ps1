function Add-PDKGroupMembership {
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
        # Your PDK User Id
        [Parameter(Mandatory = $true)]
        [int]
        $PDKUserId,
        # An array of PDK Group ID's to add membership to
        [Parameter(Mandatory=$true)]
        [array]
        $PDKGroupId
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

    $PDKGroupObject = @{
        groups = $PDKGroupId
    }

    $PDKGroupObject = $PDKGroupObject | ConvertTo-Json
    $PDKGroupEndpoint = "$($PDKPanelSession.uri)api/persons/$($PDKUserId)/groups"
    
    $Headers = @{
        "Authorization" = "Bearer $($PDKPanelSession.panel_token)"
    }

    $PDKGroupObject = Invoke-WebRequest -Method Put -Uri $PDKGroupEndpoint -Headers $Headers -ContentType "application/json" -Body $PDKGroupObject
    $PDKPanelSession = $null
    Get-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -PDKUserId $PDKUserId
}

Export-ModuleMember -Function 'Add-PDKGroupMembership'