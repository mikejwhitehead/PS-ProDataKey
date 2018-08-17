Import-Module .\PS-ProDataKey.psm1

$PDKClientId = '5b60600f9f83fc6c36cf1021'
$PDKClientSecret = 'AO1cXvXq7dFKPy3Haw4edWfNpuDj5omy'
$PDKPanelId = '1070E67'
$PDKPersonId = '9'

Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId

$PDKPersonsEndpoint = "$($PDKPanelSession.uri)api/persons"
#$Options = [uri]::EscapeDataString("page=0&per_page=10&sort=sort_order")
$Headers = @{
    "Authorization"="Bearer $($PDKPanelSession.token)"
}

$PDKPersons = Invoke-RestMethod -Method Get -Uri $PDKPersonsEndpoint -Headers $Headers -ContentType "application/json"
$PDKPersons | Select-Object *,@{N="panelName";E={$PDKPanelSession.name}},@{N="panelId";E={$PDKPanelSession.id}},@{N="uri";E={"$($PDKPanelSession.uri)api/persons/$($_.id)"}}

