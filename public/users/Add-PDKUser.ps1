function Add-PDKUser {
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
        # The new users firstname
        [Parameter(Mandatory=$true)]
        [string]
        $FirstName,
        # The new users lastname
        [Parameter(Mandatory=$true)]
        [string]
        $LastName,
        # The users active date (YYYY-MM-DD)
        [Parameter()]
        [datetime]
        $ActiveDate,
        # The users expiry date (YYYY-MM-DD)
        [Parameter()]
        [datetime]
        $ExpiryDate,
        # The users Pin
        [Parameter()]
        [string]
        $Pin,
        # Set the users partiion
        [Parameter()]
        [int]
        $Partition=0,
        # Set to $false to disable PDKUser
        [Parameter(Mandatory=$false)]
        [bool]
        $Enabled = $true
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

    $PDKPersonObject = @{
        enabled = $Enabled
        partition = $Partition
        firstName = $FirstName
        lastName = $LastName
    }

    if (!$ActiveDate) {
        $ActiveDate = Get-Date
    }
    if (!$ExpiryDate) {
        $ExpiryDate = (Get-Date).AddYears(100)
    }
    if ($Pin) {
        $DuressPin = "9" + "$Pin"
        $PDKPersonObject.Add('pin',$Pin)
        $PDKPersonObject.Add('duressPin',$DuressPin)
    }

    $ActiveDateString = $($ActiveDate.ToString("yyyy-MM-dd"))
    $ExpiryDateString = $($ExpiryDate.ToString("yyyy-MM-dd"))
    $PDKPersonObject.Add('activeDate',$ActiveDateString)
    $PDKPersonObject.Add('expireDate',$ExpiryDateString)

    $PDKPersonObject = $PDKPersonObject | ConvertTo-Json

    $PDKPersonEndpoint = "$($PDKPanelSession.uri)api/persons"
    $Headers = @{
        "Authorization" = "Bearer $($PDKPanelSession.panel_token)"
    }

    $PDKPersonObject = ((Invoke-WebRequest -Method Post -Uri $PDKPersonEndpoint -Headers $Headers -ContentType "application/json" -Body $PDKPersonObject).Content | ConvertFrom-Json).id
    $PDKPanelSession = $null
    Get-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -PDKUserId $PDKPersonObject

}

Export-ModuleMember -Function 'Add-PDKUser'