function Get-PDKGroups {
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
        [Alias('id')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $PDKPanelId
    )

    Begin {
        $PDKGroupObject = @()
    }
    
    Process {

        foreach ($PanelId in $PDKPanelId) {

            $PDKPanelGroupObject = @()

            if (!$PDKPanelSession){
                $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PanelId
            }
            elseif (((Get-Date) -ge [datetime]($PDKPanelSession.expires_at).AddSeconds(-5))){
                $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PanelId
            }
            elseif ($PDKPanelSession.id -ne $PDKPanelId){
                $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PanelId        
            }

            $PDKPanelName = $PDKPanelSession.name

            $Headers = @{
                "Authorization" = "Bearer $($PDKPanelSession.panel_token)"
            }

            $PDKGroupEndpoint = "$($PDKPanelSession.uri)api/groups?page=0&per_page=50"
            $PDKGroupResponse = Invoke-WebRequest -Method Get -Uri $PDKGroupEndpoint -Headers $Headers -ContentType "application/json" -UseBasicParsing
            $PDKPanelGroupObject += ($PDKGroupResponse.Content | ConvertFrom-Json)

            $PDKPanelGroupObject | Add-Member -MemberType NoteProperty -Name 'panelId' -Value $null -ErrorAction Ignore
            $PDKPanelGroupObject | Add-Member -MemberType NoteProperty -Name 'panelName' -Value $null -ErrorAction Ignore
            $PDKPanelGroupObject | ForEach-Object {
                $_.panelId = $PanelId
                $_.panelName = $PDKPanelName
            }
            $PDKGroupObject += $PDKPanelGroupObject
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

Export-ModuleMember -Function 'Get-PDKGroups'