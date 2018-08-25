Import-Module .\PS-ProDataKey.psm1
Import-Module ActiveDirectory
$PDKUsers = Import-Csv D:\Development\pdkgroupmemberships.csv | Select-Object -Property * -ExcludeProperty PSComputerName
$PDKUsers = $PDKUsers | Sort-Object -Property cardNumber -Unique
$PDKUsers | Add-Member -MemberType NoteProperty -Name 'verified' -Value $null

foreach ($User in ($PDKUsers | Where-Object {($null -ne $_.lastName) -and ($_.lastName -ne "") -and ($_.lastName -notlike '*#*') -and ($_.lastName.Length -gt 1) -and ($_.firstName.Length -gt 1)})){
    $User.email = Get-PDKUserEmail -Firstname $User.firstName -Lastname $User.lastName
    
    if ($User.email){
        $User.verified = 'yes'
    }
}

foreach ($User in ($PDKUsers | ? {($_.email -eq $null) -and ($_.fullName -notlike "*Audax*" -and $_.fullName -notlike "*Temp*" -and $_.fullName -notlike "*Test*")})){

    $User.email = Get-PDKUserEmail -Lastname $User.lastName
    $User.verified = 'no'
}
foreach ($User in ($PDKUsers | Where-Object {$_.verified -eq $null})){
    $User.verified = 'no'
}

# Export Cards
$PDKUsers | Export-Csv D:\Development\pdkcards.csv -NoTypeInformation -Force

$ToVerifyCorrectEmail = $PDKUsers | Where-Object {($_.email -ne $null) -and ($_.verified -eq 'no')}
$ToVerifyEmail = $PDKUsers | Where-Object {$_.email -eq $null}
$Verified = $PDKUsers | Where-Object {$_.email -ne $null}

$ToVerifyCorrectEmail | Export-Csv C:\DataSources\ProDataKey\Verification\pdk_verifyCorrectEmail.csv -NoTypeInformation -Force
$ToVerifyEmail | Export-Csv C:\DataSources\ProDataKey\Verification\pdk_verifyNoEmail.csv -NoTypeInformation -Force
$Verified | Export-Csv C:\DataSources\ProDataKey\Verification\pdk_verifiedUsers.csv -NoTypeInformation -Force
$PDKUsers | Export-Csv C:\DataSources\ProDataKey\Verification\pdk_allUsers.csv -NoTypeInformation -Force