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
        $PDKPanelId
    )
    if (!$Global:PDKPanelSession){
        $Global:PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
    }

    $PDKCardsEndpoint = "$($PDKPanelSession.uri)api/cards?page=0&per_page=50"
    #$Options = [uri]::EscapeDataString("page=0&per_page=10&sort=sort_order")
    $Headers = @{
        "Authorization" = "Bearer $($PDKPanelSession.token)"
    }

    $PDKCardsObject = @()

    $PDKCardsResponse = Invoke-WebRequest -Method Get -Uri $PDKCardsEndpoint -Headers $Headers -ContentType "application/json" -UseBasicParsing
    $PDKCardsNextPage = ($PDKCardsResponse.RelationLink.GetEnumerator() | Where-Object {$_.Key -eq 'next'}).Value

    $PDKCardsObject += ($PDKCardsResponse.Content | ConvertFrom-Json)
    while ($null -ne $PDKCardsNextPage){
        $PDKCardsResponse = Invoke-WebRequest -Method Get -Uri $PDKCardsNextPage -Headers $Headers -ContentType "application/json" -UseBasicParsing
        $PDKCardsNextPage = ForEach ($Link in ($PDKCardsResponse.RelationLink.GetEnumerator() | Where-Object {$_.Key -eq 'next'})) {$Link.Value}
        $PDKCardsObject += ($PDKCardsResponse.Content | ConvertFrom-Json)
    }
    $PDKCardsNextPage = $null
    $PDKCardsObject = $PDKCardsObject | Select-Object *,@{N="panelName";E={$PDKPanelSession.name}},@{N="panelId";E={$PDKPanelSession.id}},@{N="uri";E={"$($PDKPanelSession.uri)api/persons/$($_.id)/cards/$($_.cardNumber)"}}
    $PDKCardsObject
}

function Get-PDKCard {
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
        # Your PDK Card Id
        [Parameter(Mandatory = $true)]
        [int]
        $PDKCardId,
        # The PDK UserId Assigned to Card
        [Parameter(Mandatory = $true)]
        [int]
        $PDKUserId
    )

    if (!$Global:PDKPanelSession){
        $Global:PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
    }
    $PDKCardsEndpoint = "$($PDKPanelSession.uri)api/persons/$($PDKUserId)/cards/$($PDKCardId)"
    $Headers = @{
        "Authorization" = "Bearer $($PDKPanelSession.token)"
    }

    $PDKCardsResponse = (Invoke-WebRequest -Method Get -Uri $PDKCardsEndpoint -Headers $Headers -ContentType "application/json" -UseBasicParsing).Content | ConvertFrom-Json
    $PDKCardsResponse
}

Export-ModuleMember -Function 'Get-PDKCards','Get-PDKCard'