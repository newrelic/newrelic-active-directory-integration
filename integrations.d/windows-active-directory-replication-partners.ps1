#region Top of Script

#requires -version 4

<#
.SYNOPSIS
	Queries for Active Directory Replication Partners
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

# Grab information about replication partners
$partners = Get-ADReplicationPartnerMetadata -Target $( $env:COMPUTERNAME )


if( $null -eq $partners ) {

    $results | Add-Member -MemberType NoteProperty -Name 'partner' -Value ''
    $results | Add-Member -MemberType NoteProperty -Name 'lastReplicationAttempt' -Value ''
    $results | Add-Member -MemberType NoteProperty -Name 'lastReplicationSuccess' -Value ''
    $results | Add-Member -MemberType NoteProperty -Name 'server' -Value ''

}
else {

    foreach( $p in $partners ) {

        $results | Add-Member -MemberType NoteProperty -Name 'partner' -Value $p.Partner.Split( ',' )[ 1 ].Trim().Replace( 'CN=', '')
        $results | Add-Member -MemberType NoteProperty -Name 'lastReplicationAttempt' -Value $p.LastReplicationAttempt.ToString("MM/dd/yyyy h:mm:ss tt")
        $results | Add-Member -MemberType NoteProperty -Name 'lastReplicationSuccess' -Value $p.LastReplicationSuccess.ToString("MM/dd/yyyy h:mm:ss tt")
        $results | Add-Member -MemberType NoteProperty -Name 'server' -Value $p.Server

    }

}

# Print the results to STDOUT in JSON for Flex to pickup
$results | ConvertTo-Json

#endregion Execution
