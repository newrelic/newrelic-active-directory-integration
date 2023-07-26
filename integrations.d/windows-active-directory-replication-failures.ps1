 #region Top of Script

#requires -version 4

<#
.SYNOPSIS
	Queries for Active Directory Replication Failures
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

# Grab information about failed replications
$failures = Get-ADReplicationFailure -Target $( $env:COMPUTERNAME )

if( $null -eq $failures ) {

    $results += New-Object -TypeName PSObject -Property @{

            failureCount = '';
            failureType = '';
            failureError = '';
            firstFailureTime = '';
            server = ''

        }

}
else {

    foreach( $f in $failures ) {

        $results += New-Object -TypeName PSObject -Property @{

            failureCount = $f.FailureCount;
            failureType = $f.FailureType.ToString();
            failureError =$f.LastError;
            firstFailureTime = $f.FirstFailureTime.ToString("MM/dd/yyyy h:mm:ss tt");
            server = $f.Server

        }

    }

}

# Print the results to STDOUT in JSON for Flex to pickup
$results | ConvertTo-Json

#endregion Execution
