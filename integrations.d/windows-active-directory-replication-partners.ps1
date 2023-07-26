 #region Top of Script

#requires -version 4

<#
.SYNOPSIS
	Queries for Active Directory Replication Partners
.DESCRIPTION
    This script uses cmdlets from the Active-Directory module in PowerShell
.NOTES
	Version:		1.1
	Author:			Zack Mutchler
	Creation Date:	26-July-2023
	Purpose/Change:	Fix issue where multiple replication partners was breaking collection

	Version:		1.0
	Author:			Zack Mutchler
	Creation Date:	12-April-2023
	Purpose/Change:	Initial script development
#>

#endregion Top of Script

#####-----------------------------------------------------------------------------------------#####

#region Execution 

# Build an empty array to add our results to
$results = @()

# Grab information about replication partners
$partners = Get-ADReplicationPartnerMetadata -Target $( $env:COMPUTERNAME )


if( $null -eq $partners ) {

    $results += New-Object -TypeName PSObject -Property @{

            partner = '';
            lastReplicationAttempt = '';
            lastReplicationSuccess = '';
            server = ''

        }

}
else {

    foreach( $p in $partners ) {

        $results += New-Object -TypeName PSObject -Property @{

            partner = $p.Partner.Split( ',' )[ 1 ].Trim().Replace( 'CN=', '');
            lastReplicationAttempt = $p.LastReplicationAttempt.ToString("MM/dd/yyyy h:mm:ss tt");
            lastReplicationSuccess = $p.LastReplicationSuccess.ToString("MM/dd/yyyy h:mm:ss tt");
            server = $p.Server

        }

    }

}

# Print the results to STDOUT in JSON for Flex to pickup
$results | ConvertTo-Json

#endregion Execution
