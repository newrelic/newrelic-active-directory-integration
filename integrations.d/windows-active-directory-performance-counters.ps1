#region Top of Script

#requires -version 4

<#
.SYNOPSIS
	Queries for target Active Directory Perfmon counter values
.DESCRIPTION
    This script uses a static list of values locally
.NOTES
	Version:		1.0
	Author:			Zack Mutchler
	Creation Date:	13-Mar-2023
	Purpose/Change:	Initial script development
#>

#endregion Top of Script

#####-----------------------------------------------------------------------------------------#####

#region Execution 

# Build an empty PSObject to add our results to
$results = New-Object -TypeName PSCustomObject

# Build an array of PSCustomObjects to hold our target counters
$counters = @(
  # Number of connected address book client sessions
  [ PSCustomObject ]@{ counterName = "addressBookClientSessions"; counterPath = "\NTDS\AB Client Sessions" }
  # The number of objects remaining until the full synchronization is completed
  [ PSCustomObject ]@{ counterName = "inboundFullSyncObjectsRemaining"; counterPath = "\NTDS\DRA Inbound Full Sync Objects Remaining" }
  # The number of object property values received from inbound replication partners that are DNs that reference other objects
  [ PSCustomObject ]@{ counterName = "draInbound"; counterPath = "\NTDS\DRA Inbound Values (DNs only)/sec" }
  # The number of object property values containing DNs sent to outbound replication partners
  [ PSCustomObject ]@{ counterName = "draOutbound"; counterPath = "\NTDS\DRA Outbound Values (DNs only)/sec" }
  # The number of directory synchronizations that are queued for this server but not yet processed
  [ PSCustomObject ]@{ counterName = "draPendingReplicationSync"; counterPath = "\NTDS\DRA Pending Replication Synchronizations" }
  # The number of directory reads per second
  [ PSCustomObject ]@{ counterName = "directoryReadsPerSec"; counterPath = "\NTDS\DS Directory Reads/sec" }
  # The number of directory writes per second
  [ PSCustomObject ]@{ counterName = "directoryWritesPerSec"; counterPath = "\NTDS\DS Directory Writes/sec" }
  # The number of pending update notifications that are queued but not yet transmitted to clients
  [ PSCustomObject ]@{ counterName = "directoryNotifyQueueSize"; counterPath = "\NTDS\DS Notify Queue Size" }
  # The current number of threads that the directory service is using
  [ PSCustomObject ]@{ counterName = "directoryThreadsInUse"; counterPath = "\NTDS\DS Threads in Use" }
  # The current number of threads that the LDAP subsytem of the local directory service uses
  [ PSCustomObject ]@{ counterName = "ldapActiveThreads"; counterPath = "\NTDS\LDAP Active Threads" }
  # The time (in milliseconds) that is taken to complete the last LDAP bind
  [ PSCustomObject ]@{ counterName = "ldapBindTime"; counterPath = "\NTDS\LDAP Bind Time" }
  # The number of currently connected LDAP client sessions
  [ PSCustomObject ]@{ counterName = "ldapClientSessions"; counterPath = "\NTDS\LDAP Client Sessions" }
  # The rate at which LDAP clients perform search operations
  [ PSCustomObject ]@{ counterName = "ldapSearchesPerSec"; counterPath = "\NTDS\LDAP Searches/sec" }
  # The number of LDAP binds per second
  [ PSCustomObject ]@{ counterName = "ldapSuccessfulBindsPerSec"; counterPath = "\NTDS\LDAP Successful Binds/sec" }
  # The combined rate at which all processors on the computer are switched from one thread to another
  [ PSCustomObject ]@{ counterName = "contextSwitchesPerSec"; counterPath = "\System\Context Switches/sec" }
  # The number of threads waiting to be executed in queue
  [ PSCustomObject ]@{ counterName = "processorQueueLength"; counterPath = "\System\Processor Queue Length" }
)

# Iterate through our target counters and grab our results
foreach( $c in $counters ) {

    $results | Add-Member -MemberType NoteProperty -Name $c.CounterName -Value (Get-Counter -MaxSamples 1 -Counter $c.counterPath | Select-Object -ExpandProperty CounterSamples).CookedValue

}

# Print the results to STDOUT in JSON for Flex to pickup
$results | ConvertTo-Json

#endregion Execution