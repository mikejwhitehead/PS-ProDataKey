function Get-PDKGroups {
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
        $PDKPanelId
    )

    if (!$Global:PDKPanelSession){
        $Global:PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
    }
    elseif (((Get-Date) -ge [datetime]($Global:PDKPanelSession.expires_at).AddSeconds(-5))){
        $Global:PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
    }
    elseif ($Global:PDKPanelSession.id -ne $PDKPanelId){
        $Global:PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
    }

    $PDKGroupsEndpoint = "$($PDKPanelSession.uri)api/groups?page=0&per_page=50"
    $Headers = @{
        "Authorization" = "Bearer $($PDKPanelSession.panel_token)"
    }

    $PDKGroupsObject = @()
    $PDKGroupsResponse = Invoke-WebRequest -Method Get -Uri $PDKGroupsEndpoint -Headers $Headers -ContentType "application/json" -UseBasicParsing
    $PDKGroupsNextPage = ($PDKGroupsResponse.RelationLink.GetEnumerator() | Where-Object {$_.Key -eq 'next'}).Value

    $PDKGroupsObject += ($PDKGroupsResponse.Content | ConvertFrom-Json)
    while ($null -ne $PDKGroupsNextPage){
        $PDKGroupsResponse = Invoke-WebRequest -Method Get -Uri $PDKGroupsNextPage -Headers $Headers -ContentType "application/json" -UseBasicParsing
        $PDKGroupsNextPage = ForEach ($Link in ($PDKGroupsResponse.RelationLink.GetEnumerator() | Where-Object {$_.Key -eq 'next'})) {$Link.Value}
        $PDKGroupsObject += ($PDKGroupsResponse.Content | ConvertFrom-Json)
    }
    $PDKGroupsNextPage = $null
    $PDKGroupsObject = $PDKGroupsObject | Select-Object *,@{N="panelName";E={$PDKPanelSession.name}},@{N="panelId";E={$PDKPanelSession.id}},@{N="uri";E={"$($PDKPanelSession.uri)api/persons/$($_.id)"}}
    
    foreach ($PDKPerson in $PDKGroupsObject){
        $PDKPanelId = $PDKPerson.panelId
        $PDKUserId = $PDKPerson.id
        $PDKPersonDetails = Get-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -PDKUserId $PDKUserId | Select-Object cards,groups
        $PDKPerson | Add-Member -MemberType NoteProperty -Name 'cards' -Value $PDKPersonDetails.cards
        $PDKPerson | Add-Member -MemberType NoteProperty -Name 'groups' -Value $PDKPersonDetails.groups

        foreach ($PDKCard in $PDKPerson.cards){
            $PDKCard | Add-Member -MemberType NoteProperty -Name 'panelId' -Value $PDKPanelId
            $PDKCard | Add-Member -MemberType NoteProperty -Name 'panelName' -Value $PDKPerson.panelName
        }
    }

    $Global:PDKPanelSession = $null
    $PDKGroupsObject
}

function Get-PDKUser {
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
        $PDKUserId
    )

    if (!$Global:PDKPanelSession){
        $Global:PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
    }
    elseif (((Get-Date) -ge [datetime]($Global:PDKPanelSession.expires_at).AddSeconds(-5))){
        $Global:PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
    }
    elseif ($Global:PDKPanelSession.id -ne $PDKPanelId){
        $Global:PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
    }

    $PDKGroupsEndpoint = "$($PDKPanelSession.uri)api/persons/$($PDKUserId)"
    $Headers = @{
        "Authorization" = "Bearer $($PDKPanelSession.panel_token)"
    }

    $PDKGroupsResponse = (Invoke-WebRequest -Method Get -Uri $PDKGroupsEndpoint -Headers $Headers -ContentType "application/json" -UseBasicParsing).Content | ConvertFrom-Json
    $PDKGroupsResponse
}

Export-ModuleMember -Function 'Get-PDKGroups'