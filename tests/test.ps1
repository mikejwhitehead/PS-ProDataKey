Import-Module .\PS-ProDataKey.psm1

$PDKClientId = '5b60600f9f83fc6c36cf1021'
$PDKClientSecret = 'AO1cXvXq7dFKPy3Haw4edWfNpuDj5omy'

$PDKPanels = (Import-Csv 'C:\Users\mike.whitehead\Desktop\PDK - Panel IDs.csv').PanelID

$PDKUsers = Get-PDKUsers -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanels


$Cards = $PDKUsers | Select-Object id,firstName,lastName,enabled,panelName,panelId,@{N="cardNumber";E={$_.cards.cardNumber}},@{N='description';E={$_.cards.description}}
$AllCards | Export-Csv -Path D:\Development\pdkusers.csv -NoTypeInformation -Force

#$PDKUsers | Export-Csv C:\DataSources\ProDataKey\ProDataKeyUsers.csv -NoTypeInformation -Force

id        : 87
firstName : Tania
lastName  : Bautista Solis
enabled   : True
partition : 0
panelName : Perris Health Center
panelId   : 1070DLI
uri       : https://panel-1070DLI.pdk.io/api/persons/87

Get-PDKCards -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId | ForEach-Object {Get-PDKCard -PDKClientId $PDKClientId -PDKClientSecret $PDKClientId -PDKPanelId $PDKPanelId -PDKCardId $_.cardNumber -PDKUserId $_.id }