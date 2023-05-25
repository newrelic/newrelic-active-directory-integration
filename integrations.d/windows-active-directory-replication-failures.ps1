#region Top of Script

#requires -version 4

<#
.SYNOPSIS
	Queries for Active Directory Replication Failures
.DESCRIPTION
    This script uses cmdlets from the Active-Directory module in PowerShell
.NOTES
	Version:		1.0
	Author:			Zack Mutchler
	Creation Date:	12-April-2023
	Purpose/Change:	Initial script development
#>

#endregion Top of Script

#####-----------------------------------------------------------------------------------------#####

#region Execution 

# Build an empty PSObject to add our results to
$results = New-Object -TypeName PSCustomObject

# Grab information about failed replications
$failures = Get-ADReplicationFailure -Target $( $env:COMPUTERNAME )

if( $null -eq $failures ) {

    $results | Add-Member -MemberType NoteProperty -Name 'failureCount' -Value ''
    $results | Add-Member -MemberType NoteProperty -Name 'failureType' -Value ''
    $results | Add-Member -MemberType NoteProperty -Name 'failureError' -Value ''
    $results | Add-Member -MemberType NoteProperty -Name 'firstFailureTime' -Value ''
    $results | Add-Member -MemberType NoteProperty -Name 'server' -Value ''

}
else {

    foreach( $f in $failures ) {

        $results | Add-Member -MemberType NoteProperty -Name 'failureCount' -Value $f.FailureCount
        $results | Add-Member -MemberType NoteProperty -Name 'failureType' -Value $f.FailureType.ToString()
        $results | Add-Member -MemberType NoteProperty -Name 'lastError' -Value $f.LastError
        $results | Add-Member -MemberType NoteProperty -Name 'firstFailureTime' -Value $f.FirstFailureTime.ToString("MM/dd/yyyy h:mm:ss tt")
        $results | Add-Member -MemberType NoteProperty -Name 'server' -Value $f.Server

    }

}

# Print the results to STDOUT in JSON for Flex to pickup
$results | ConvertTo-Json

#endregion Execution
