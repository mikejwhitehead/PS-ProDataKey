function Get-PDKUserEmail {
    Param(
        # The PDK users firstname
        [Parameter(Mandatory=$false)]
        [string]
        $Firstname,
        # The PDK users lastname
        [Parameter(Mandatory=$false)]
        [string]
        $Lastname
    )

    if ($Firstname -and $Lastname){
        $adObject = Get-ADUser -Filter {sn -eq $lastName -and GivenName -eq $firstName} -ErrorAction SilentlyContinue -Properties mail
    }
    elseif ($Firstname -and !$Lastname) {
        $adObject = Get-ADUser -Filter {GivenName -eq $firstName} -ErrorAction SilentlyContinue -Properties mail
    }
    elseif (!$Firstname -and $Lastname){
        $adObject = Get-ADUser -Filter {sn -eq $lastName} -ErrorAction SilentlyContinue -Properties mail
    }
    elseif (!$Firstname -and !$Lastname){
        $adObject = $null
    }

    if (!$adObject){
        return $null
    }

    if ($adObject.Count -gt 1){
        return $null
    }
    else {
        return $adObject.mail
    }
}
Export-ModuleMember -Function 'Get-PDKUserEmail'

