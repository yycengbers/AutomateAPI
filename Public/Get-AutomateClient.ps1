function Get-AutomateClient {
    <#
    .SYNOPSIS
        Get Client information out of the Automate API
    .DESCRIPTION
        Connects to the Automate API and returns one or more full client objects
    .PARAMETER AllClients
        Returns all clients in Automate, regardless of amount
    .PARAMETER Condition
        A custom condition to build searches that can be used to search for specific things. Supported operators are '=', 'eq', '>', '>=', '<', '<=', 'and', 'or', '()', 'like', 'contains', 'in', 'not'.
        The 'not' operator is only used with 'in', 'like', or 'contains'. The '=' and 'eq' operator are the same. String values can be surrounded with either single or double quotes. IE (RemoteAgentLastContact <= 2019-12-18T00:50:19.575Z)
        Boolean values are specified as 'true' or 'false'. Parenthesis can be used to control the order of operations and group conditions.
    .PARAMETER OrderBy
        A comma separated list of fields that you want to order by finishing with either an asc or desc.
    .PARAMETER ClientName
        Client name to search for, uses wildcards so full client name is not needed
    .PARAMETER ClientID
        ClientID to search for, integer, -ClientID 1
    .OUTPUTS
        Client objects
    .NOTES
        Version:        1.0
        Author:         Gavin Stone and Andrea Mastellone
        Creation Date:  2019-03-19
        Purpose/Change: Initial script development
        Modified Date:  2020-04-25
        Purpose/Change: Remove location specific items - will expand in to a new cmdlet. Pulling by ID is currently bugged due to bug in actual API
    .EXAMPLE
        Get-AutomateClient -AllClients
    .EXAMPLE
        Get-AutomateClient -ClientId 4
    .EXAMPLE
        Get-AutomateClient -ClientName "Rancor"
    .EXAMPLE
        Get-AutomateClient -Condition "(City = 'Baltimore')"
    #>
        param (
            [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "IndividualClient")]
            [Alias('ID')]
            [int32[]]$ClientId,

            [Parameter(Mandatory = $false, ParameterSetName = "AllResults")]
            [switch]$AllClients,

            [Parameter(Mandatory = $false, ParameterSetName = "ByCondition")]
            [string]$Condition,

            [Parameter(Mandatory = $false, ParameterSetName = "CustomBuiltCondition")]
            [Parameter(Mandatory = $false, ParameterSetName = "AllResults")]
            [Parameter(Mandatory = $false, ParameterSetName = "ByCondition")]
            [string]$IncludeFields,

            [Parameter(Mandatory = $false, ParameterSetName = "CustomBuiltCondition")]
            [Parameter(Mandatory = $false, ParameterSetName = "AllResults")]
            [Parameter(Mandatory = $false, ParameterSetName = "ByCondition")]
            [string]$ExcludeFields,

            [Parameter(Mandatory = $false, ParameterSetName = "CustomBuiltCondition")]
            [Parameter(Mandatory = $false, ParameterSetName = "AllResults")]
            [Parameter(Mandatory = $false, ParameterSetName = "ByCondition")]
            [string]$OrderBy,

            [Alias("Client")]
            [Parameter(Mandatory = $false, ParameterSetName = "CustomBuiltCondition")]
            [string]$ClientName
        )

        $ArrayOfConditions = @()

        
        if ($ClientID) {
            Return Get-AutomateAPIGeneric -AllResults -Endpoint "clients" -IDs $(($ClientID) -join ",")
        }

        if ($AllClients) {
            Return Get-AutomateAPIGeneric -AllResults -Endpoint "clients" -IncludeFields $IncludeFields -ExcludeFields $ExcludeFields -OrderBy $OrderBy
        }

        if ($Condition) {
            Return Get-AutomateAPIGeneric -AllResults -Endpoint "clients" -Condition $Condition -IncludeFields $IncludeFields -ExcludeFields $ExcludeFields -OrderBy $OrderBy
        }

        if ($ClientName) {
            $ArrayOfConditions += "(Name like '%$ClientName%')"
        }

        $ClientFinalCondition = Get-ConditionsStacked -ArrayOfConditions $ArrayOfConditions

        return Get-AutomateAPIGeneric -AllResults -Endpoint "clients" -Condition $ClientFinalCondition -IncludeFields $IncludeFields -ExcludeFields $ExcludeFields -OrderBy $OrderBy
    }