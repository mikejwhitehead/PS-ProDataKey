function Get-PDKGroup {
    Param(
        # Your PDK ClientId
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PDKClientId,
        # Your PDK Client Secret
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PDKClientSecret,
        # Your PDK Panel Id
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [Alias('panelId')]
        [ValidateNotNullOrEmpty()]
        [string]
        $PDKPanelId,
        # Your PDK Group ID
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [int[]]
        $PDKGroupID
    )

    Begin {
        $PDKGroupObject = @()
    }
    
    Process {

        foreach ($GroupID in $PDKGroupID) {

            if (!$PDKPanelSession){
                $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
            }
            elseif (((Get-Date) -ge [datetime]($PDKPanelSession.expires_at).AddSeconds(-5))){
                $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
            }
            elseif ($PDKPanelSession.id -ne $PDKPanelId){
                $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
            }

            $Headers = @{
                "Authorization" = "Bearer $($PDKPanelSession.panel_token)"
            }

            $PDKGroupEndpoint = "$($PDKPanelSession.uri)api/groups/$GroupID"
            $PDKGroupResponse = Invoke-WebRequest -Method Get -Uri $PDKGroupEndpoint -Headers $Headers -ContentType "application/json" -UseBasicParsing
            $PDKGroupObject += ($PDKGroupResponse.Content | ConvertFrom-Json)
        }
    }
    
    End {

       $PDKPanelSession = $null

        if (!$PDKGroupObject){
            return $null
        }
        else{
            return $PDKGroupObject
        }
    }
}

Export-ModuleMember -Function 'Get-PDKGroup'