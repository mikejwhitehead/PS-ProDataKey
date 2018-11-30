function Update-PDKCard {
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
        # Your PDK Card Number
        [Parameter(Mandatory=$true)]
        [int]
        $PDKCardNumber,
        # A description for your PDK Card
        [Parameter(Mandatory=$true)]
        [string]
        $PDKCardDescription,
        # A PDK Panel Web Session Object
        [Parameter(Mandatory = $false)]
        [psobject]
        $PDKPanelSession
    )

    if ($Verbose) {
        $OriginalVerbosePreference = $VerbosePreference
        $VerbosePreference = "Continue"
    }

    if (!$PDKPanelSession){
        $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
    }
    elseif (((Get-Date) -ge [datetime]($PDKPanelSession.expires_at).AddSeconds(-5))){
        $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
    }
    elseif ($PDKPanelSession.id -ne $PDKPanelId){
        $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
    }

    Write-Output @"
Querying PDK...

PDK Panel  : $($PDKPanelId)
PDK UserId : $($PDKUserId)

"@

    Try{

        $PDKUser = Get-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -PDKUserId $PDKUserId -PDKPanelSession $PDKPanelSession

    }
    Catch{
        Write-Output "The query did not complete. Exiting"
        $VerbosePreference = $OriginalVerbosePreference
        Exit 100
    }

    if ($PDKUser) {

        $PDKUserCardDescription = ($PDKUser.cards | Where-Object {$_.cardNumber -eq $PDKCardNumber}).description

        Write-Output @"
PDK User found...

FirstName        : $($PDKUser.firstname)
LastName         : $($PDKUser.lastname)
Card Description : $($PDKUserCardDescription)

"@        
    }

    Try{
 
        Write-Output @"
Changing card description...

From   : $($PDKUserCardDescription)
To     : $($PDKCardDescription)

Removing old description...
"@
        Remove-PDKCard -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -PDKUserId $PDKUserId -PDKCardNumber $PDKCardNumber -PDKPanelSession $PDKPanelSession | Out-Null
    }
    Catch{

        Write-Output "Unable to remove old card description. Exiting"
        $VerbosePreference = $OriginalVerbosePreference
        Exit 100
    }

    Try{
        Write-Output @"
Adding new description...
"@

        Add-PDKCard -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -PDKUserId $PDKUserId -PDKCardNumber $PDKCardNumber -PDKCardDescription $PDKCardDescription -PDKPanelSession $PDKPanelSession | Out-Null

    }
    Catch{

        Write-Output "Unable to add new card description. This user is now without a card. Please fix ASAP Exiting"
        $VerbosePreference = $OriginalVerbosePreference
        Exit 100
    }

    $VerbosePreference = $OriginalVerbosePreference
    Write-Output "Finished updating card"
}

Export-ModuleMember -Function 'Update-PDKCard'