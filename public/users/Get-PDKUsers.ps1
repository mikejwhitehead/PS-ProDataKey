function Get-PDKUsers {
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
        # A PDK Panel Web Session Object
        [Parameter(Mandatory = $false)]
        [psobject]
        $PDKPanelSession,
        # Switch to set for returning PDK user details
        [Parameter(Mandatory=$false)]
        [switch]
        $Details
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

    $PDKPersonsEndpoint = "$($PDKPanelSession.uri)api/persons?page=0&per_page=50"
    $Headers = @{
        "Authorization" = "Bearer $($PDKPanelSession.panel_token)"
    }

    $PDKPersonsObject = @()
    $PDKPersonsResponse = Invoke-WebRequest -Method Get -Uri $PDKPersonsEndpoint -Headers $Headers -ContentType "application/json" -UseBasicParsing
    $PDKPersonsObjectCount = $PDKPersonsResponse.Headers.'X-Total-Count'
    $PDKPersonsObject += ($PDKPersonsResponse.Content | ConvertFrom-Json)

    if ($PDKPersonsResponse.Headers.Link){
            $Links = @()
            ($PDKPersonsResponse.Headers.Link -split ',').Trim() | ForEach-Object {
            $Link = ($_ -split ';')
            $Link = New-Object psobject -Property @{"Link"=((($Link[0]) -replace '<','' -replace '>','')).Trim()
                                                    "Relation"=(($Link[1]) -replace "rel=`"","" -replace "`"","").Trim()}
            $Links += $Link
            }
        
        $PDKPersonsNextPage = ($Links | ? {$_.Relation -eq 'next'}).Link
    }

    while ($null -ne $PDKPersonsNextPage){

        $PDKPersonsResponse = Invoke-WebRequest -Method Get -Uri $PDKPersonsNextPage -Headers $Headers -ContentType "application/json" -UseBasicParsing
        $PDKPersonsObject += ($PDKPersonsResponse.Content | ConvertFrom-Json)

        if ($PDKPersonsResponse.Headers.Link){
            $Links = @()
            ($PDKPersonsResponse.Headers.Link -split ',').Trim() | ForEach-Object {
            $Link = ($_ -split ';')
            $Link = New-Object psobject -Property @{"Link"=((($Link[0]) -replace '<','' -replace '>','')).Trim()
                                                    "Relation"=(($Link[1]) -replace "rel=`"","" -replace "`"","").Trim()}
            $Links += $Link
            }
        
        $PDKPersonsNextPage = ($Links | Where-Object {$_.Relation -eq 'next'}).Link
        }

        else {$PDKPersonsNextPage = $null}
    }

    if ($PDKPersonsObject.Count -ne $PDKPersonsObjectCount){

        throw "Failed to query all users from PDK panel $PDKPanelId"

    }

    $PDKPersonsObject = $PDKPersonsObject | Select-Object *,@{N="uri";E={"$($PDKPanelSession.uri)api/persons/$($_.id)"}}

    if ($Details){
        $PDKPersonsObjectDetails = @()
        foreach ($PDKPerson in $PDKPersonsObject){
            Write-Verbose "PDK User -- $($PDKPerson.firstname) + $($PDKPerson.lastName)"
            if (!$PDKPanelSession){
                $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
            }
            elseif (((Get-Date) -ge [datetime]($PDKPanelSession.expires_at).AddSeconds(-30))){
                $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
            }
            elseif ($PDKPanelSession.id -ne $PDKPanelId){
                $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
            }

            $PDKPersonEndpoint = $PDKPerson.uri
            $PDKPanelSessionToken = $PDKPanelSession.panel_token
        
            $Headers = @{
                "Authorization" = "Bearer $($PDKPanelSessionToken)"
            }
            
            $PDKPersonObjectDetails = Invoke-RestMethod -Method Get -Uri $PDKPersonEndpoint -Headers $Headers -ContentType "application/json"
            $PDKPersonsObjectDetails += $PDKPersonObjectDetails
            # Start-Job -Name "panel-$($PDKPerson.panelId)-$($PDKPerson.id)" -ScriptBlock {Invoke-RestMethod -Method Get -Uri $using:PDKPersonEndpoint -Headers $using:Headers -ContentType "application/json"} | Out-Null
    
        }

    # Get-Job | Wait-Job | Out-Null
    # $PDKPersonsObject = Get-Job | Receive-Job 
    $PDKPersonsObject = $PDKPersonsObjectDetails | Select-Object *,@{N="uri";E={"$($PDKPanelSession.uri)api/persons/$($_.id)"}}
    # Get-Job | Remove-Job

    }

$PDKPersonsObject | Select-Object *,@{N="panelName";E={$PDKPanelSession.name}},@{N="panelId";E={$PDKPanelSession.id}}

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
        $PDKUserId,
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

    $PDKPersonsEndpoint = "$($PDKPanelSession.uri)api/persons/$($PDKUserId)"
    $Headers = @{
        "Authorization" = "Bearer $($PDKPanelSession.panel_token)"
    }

    $PDKPersonsResponse = (Invoke-WebRequest -Method Get -Uri $PDKPersonsEndpoint -Headers $Headers -ContentType "application/json" -UseBasicParsing).Content | ConvertFrom-Json
    $PDKPersonsResponse
}

Export-ModuleMember -Function 'Get-PDKUsers','Get-PDKUser'