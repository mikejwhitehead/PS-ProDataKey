Remove-Module *
Remove-Variable * -ErrorAction 'Ignore'
Import-Module .\PS-ProDataKey.psm1

$PDKClientId = '5b60600f9f83fc6c36cf1021'
$PDKClientSecret = 'AO1cXvXq7dFKPy3Haw4edWfNpuDj5omy'
$PDKPanelId = '1070DLI'
$PDKUserId = $PDKUser.id

$PDKCardNumber = "12569"
$PDKCardDescription = "Test Card"

Add-PDKCard -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -PDKUserId $PDKUserId -PDKCardNumber $PDKCardNumber -PDKCardDescription $PDKCardDescription
Remove-PDKCard -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -PDKUserId $PDKUserId -PDKCardNumber $PDKCardNumber