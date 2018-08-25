function Get-PDKGroupMemberships (
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
        $PDKGroupId
    )

)