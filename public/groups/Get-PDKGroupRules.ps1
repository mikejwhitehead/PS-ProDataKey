function Get-PDKGroupRules {
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
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PDKPanelId,
        # Your PDK Group ID
        [Parameter(Mandatory=$false)]
        [int]
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

    $PDKGroupEndpoint = "$($PDKPanelSession.uri)api/groups/$($PDKGroupId)/rules?page=0&per_page=50"
    $Headers = @{
        "Authorization" = "Bearer $($PDKPanelSession.panel_token)"
    }

    $PDKGroupObject = @()
    $PDKGroupResponse = Invoke-WebRequest -Method Get -Uri $PDKGroupEndpoint -Headers $Headers -ContentType "application/json" -UseBasicParsing
    $PDKGroupObjectCount = $PDKGroupResponse.Headers.'X-Total-Count'
    $PDKGroupObject += ($PDKGroupResponse.Content | ConvertFrom-Json)

    if ($PDKGroupResponse.Headers.Link){
            $Links = @()
            ($PDKGroupResponse.Headers.Link -split ',').Trim() | ForEach-Object {
            $Link = ($_ -split ';')
            $Link = New-Object psobject -Property @{"Link"=((($Link[0]) -replace '<','' -replace '>','')).Trim()
                                                    "Relation"=(($Link[1]) -replace "rel=`"","" -replace "`"","").Trim()}
            $Links += $Link
            }
        
        $PDKGroupNextPage = ($Links | Where-Object {$_.Relation -eq 'next'}).Link
    }

    while ($null -ne $PDKGroupNextPage){

        $PDKGroupResponse = Invoke-WebRequest -Method Get -Uri $PDKGroupNextPage -Headers $Headers -ContentType "application/json" -UseBasicParsing
        $PDKGroupObject += ($PDKGroupResponse.Content | ConvertFrom-Json)

        if ($PDKGroupResponse.Headers.Link){
            $Links = @()
            ($PDKGroupResponse.Headers.Link -split ',').Trim() | ForEach-Object {
            $Link = ($_ -split ';')
            $Link = New-Object psobject -Property @{"Link"=((($Link[0]) -replace '<','' -replace '>','')).Trim()
                                                    "Relation"=(($Link[1]) -replace "rel=`"","" -replace "`"","").Trim()}
            $Links += $Link
            }
        
        $PDKGroupNextPage = ($Links | Where-Object {$_.Relation -eq 'next'}).Link
        }

        else {$PDKGroupNextPage = $null}
    }

    #$PDKGroupObject = $PDKGroupObject | Select-Object *,@{N="panelName";E={$PDKPanelSession.name}},@{N="panelId";E={$PDKPanelSession.id}},@{N="uri";E={"$($PDKPanelSession.uri)api/persons/$($_.id)"}}
    
    if ($PDKGroupObject.Count -ne $PDKGroupObjectCount){
    
        throw "Failed to query all users from PDK panel $PDKPanelId"

    }

    $PDKPanelSession = $null

    if (!$PDKGroupObject){
        return $null
    }
    else{
        return $PDKGroupObject
    }
}

Export-ModuleMember -Function 'Get-PDKGroupRules'