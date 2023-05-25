<a href="https://opensource.newrelic.com/oss-category/#community-project"><picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/newrelic/opensource-website/raw/main/src/images/categories/dark/Community_Project.png"><source media="(prefers-color-scheme: light)" srcset="https://github.com/newrelic/opensource-website/raw/main/src/images/categories/Community_Project.png"><img alt="New Relic Open Source community project banner." src="https://github.com/newrelic/opensource-website/raw/main/src/images/categories/Community_Project.png"></picture></a>

# New Relic Active Directory Integration

The New Relic Active Directory monitoring integration includes the configuration files required to successfully monitor the health and availability of your Active Directory environment.

## Installation

### Prerequisites

* These configuration files require use of the New Relic Infrastructure Agent (NRIA) and interact with the [Flex](https://docs.newrelic.com/docs/infrastructure/host-integrations/host-integrations-list/flex-integration-tool-build-your-own-integration/), [Logging](https://docs.newrelic.com/docs/logs/forward-logs/forward-your-logs-using-infrastructure-agent/#winevtlog), and [Windows Services](https://docs.newrelic.com/docs/infrastructure/host-integrations/host-integrations-list/windows-services-integration/) capabilities of NRIA.

### Process

At a high-level, installation of this integration includes the following steps.

1. Clone this repository.
2. Copy the contents of both `integrations.d` and `logging.d` into the associated directories on your target server.
3. Restart the `New Relic Infrastructure Agent` service.

#### PowerShell sample

**Copy files to target server**

```powershell
# integrations.d
Copy-Item -Path "<pathToRepo>\integrations.d\*" -Destination "C:\Program Files\New Relic\newrelic-infra\integrations.d" -Recurse

# logging.d
Copy-Item -Path "<pathToRepo>\logging.d\*" -Destination "C:\Program Files\New Relic\newrelic-infra\logging.d" -Recurse
```

**Restart the agent**

```powershell
Restart-Service -Name "newrelic-infra" -Force
```

### Directory structure

```bash
C:\Program Files\New Relic\newrelic-infra\
    ├── integrations.d
    │   ├── windows-active-directory-performance-counters.ps1
    │   ├── windows-active-directory-performance-counters.yml
    │   ├── windows-active-directory-replication-checks.yml
    │   ├── windows-active-directory-replication-failures.ps1
    │   ├── windows-active-directory-replication-partners.ps1
    │   └── windows-active-directory-services.yml
    └── logging.d
        └── windows-active-directory.yml
```

## Details of Configuration Files

### integrations.d

#### Performance Counters

`windows-active-directory-performance-counters.yml`

Configuration file for [Flex](https://docs.newrelic.com/docs/infrastructure/host-integrations/host-integrations-list/flex-integration-tool-build-your-own-integration/).

`windows-active-directory-performance-counters.ps1`

PowerShell script that collects telemetry from the following Performance Counters:

|                    **COUNTER**                   |                                                      **DESCRIPTION**                                                      |
|------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| `\NTDS\AB Client Sessions`                       | Number of connected address book client sessions                                                                          |
| `\NTDS\DRA Inbound Full Sync Objects Remaining`  | The number of objects remaining until the full synchronization is completed                                               |
| `\NTDS\DRA Inbound Values (DNs only)/sec`        | The number of object property values received from inbound replication partners that are DNs that reference other objects |
| `\NTDS\DRA Outbound Values (DNs only)/sec`       | The number of object property values containing DNs sent to outbound replication partners                                 |
| `\NTDS\DRA Pending Replication Synchronizations` | The number of directory synchronizations that are queued for this server but not yet processed                            |
| `\NTDS\DS Directory Reads/sec`                   | The number of directory reads per second                                                                                  |
| `\NTDS\DS Directory Writes/sec`                  | The number of directory writes per second                                                                                 |
| `\NTDS\DS Notify Queue Size`                     | The number of pending update notifications that are queued but not yet transmitted to clients                             |
| `\NTDS\DS Threads in Use`                        | The current number of threads that the directory service is using                                                         |
| `\NTDS\LDAP Active Threads`                      | The current number of threads that the LDAP subsytem of the local directory service uses                                  |
| `\NTDS\LDAP Bind Time`                           | The time (in milliseconds) that is taken to complete the last LDAP bind                                                   |
| `\NTDS\LDAP Client Sessions`                     | The number of currently connected LDAP client sessions                                                                    |
| `\NTDS\LDAP Searches/sec`                        | The rate at which LDAP clients perform search operations                                                                  |
| `\NTDS\LDAP Successful Binds/sec`                | The number of LDAP binds per second                                                                                       |
| `\System\Context Switches/sec`                   | The combined rate at which all processors on the computer are switched from one thread to another                         |
| `\System\Processor Queue Length`                 | The number of threads waiting to be executed in queue                                                                     |

##### See your data

In New Relic, you can query your results with this NRQL pattern:

```
FROM activeDirectoryHealthChecks SELECT
    latest(addressBookClientSessions),
    latest(inboundFullSyncObjectsRemaining),
    latest(draInbound),
    latest(draOutbound),
    latest(draPendingReplicationSync),
    latest(directoryReadsPerSec),
    latest(directoryWritesPerSec),
    latest(directoryNotifyQueueSize),
    latest(directoryThreadsInUse),
    latest(ldapActiveThreads),
    latest(ldapBindTime),
    latest(ldapClientSessions),
    latest(ldapSearchesPerSec),
    latest(ldapSuccessfulBindsPerSec),
    latest(contextSwitchesPerSec),
    latest(processorQueueLength)
SINCE 1 DAY AGO
LIMIT MAX
```

#### Replication Checks

`windows-active-directory-replication-checks.yml`

Configuration file for [Flex](https://docs.newrelic.com/docs/infrastructure/host-integrations/host-integrations-list/flex-integration-tool-build-your-own-integration/).

`windows-active-directory-replication-failures.ps1`

This PowerShell script uses the [Get-ADReplicationFailure cmdlet](https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-adreplicationfailure?view=windowsserver2022-ps) to query the latest replication failures from the Active Directory environment on the local host.

`windows-active-directory-replication-partners.ps1`

This PowerShell script uses the [Get-ADReplicationPartnerMetadata cmdlet](https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-adreplicationpartnermetadata?view=windowsserver2022-ps) to query the replication partner data from the Active Directory environment on the local host.

##### See your data

In New Relic, you can query your replication failures with this NRQL pattern:

```
FROM activeDirectoryReplicationFailures SELECT
    latest(failureType) AS 'Type',
    latest(failureError) AS 'Error',
    latest(firstFailureTime) AS 'First Failure',
    latest(failureCount) AS 'Attempts Made'
FACET
    server
SINCE 1 DAY AGO
LIMIT MAX
```

In New Relic, you can query your replication partner results with this NRQL pattern:

```
FROM activeDirectoryReplicationPartners SELECT
    latest(lastReplicationAttempt) AS 'Last Attempt',
    latest(lastReplicationSuccess) AS 'Last Success'
FACET
    server AS 'Source',
    partner AS 'Partner',
    if(lastReplicationSuccess != lastReplicationAttempt, 'Failed Replication', 'Successful Replication') AS 'Current Status'
SINCE 1 DAY AGO
LIMIT MAX
```

#### Services

`windows-active-directory-services.yml`

This configuration file for the [Windows services integration](https://docs.newrelic.com/docs/infrastructure/host-integrations/host-integrations-list/windows-services-integration/) collects the status of the following services:

|  **SERVICE NAME** |          **DESCRIPTION**         |
|-----------------|--------------------------------|
| `ADWS`              | Active Directory Web Services    |
| `DFS`               | Distributed File System          |
| `DFSR`              | DFS Replication                  |
| `DNS`               | DNS Server                       |
| `Dnscache`          | DNS Client                       |
| `IsmServ`           | Intersite Messaging              |
| `kdc`               | Kerberos Key Distribution Center |
| `lanmanserver`      | Server                           |
| `lanmanworkstation` | Workstation                      |
| `Netlogon`          | Net logon                        |
| `NTDS`              | Active Directory Domain Services |
| `RpcSs`             | Remote Procedure Call (RPC)      |
| `SamSs`             | Security Accounts Manager        |
| `W32Time`           | Windows Time                     |

##### See your data

In New Relic, you can query your results with this NRQL pattern:

```
FROM Metric SELECT
    latest(timestamp) AS 'Reporting Time',
    latest(state) AS 'Current State',
    latest(start_mode) AS 'Start Mode'
FACET
    hostname AS 'Host',
    display_name AS 'Display Name',
    service_name AS 'Service Name',
    process_id AS 'Parent PID',
    run_as AS 'Service Account'
WHERE label.primary_app = 'active_directory'
SINCE 1 DAY AGO
LIMIT MAX
```

### logging.d

#### Event Logs

`windows-active-directory.yml`

This configuration file for the [NRIA logging integration](https://docs.newrelic.com/docs/logs/forward-logs/forward-your-logs-using-infrastructure-agent/#winevtlog) collects the status of the following Event Logs:

| **CHANNEL** | **EVENT ID** | **DESCRIPTION** |
|-----------|------------|------------|
| Security | `4609` | Windows is shutting down |
| Security | `4616` | The system time was changed |
| Security | `4625` | An account failed to log on |
| Security | `4648` | A logon was attempted using explicit credentials |
| Security | `4649` | A replay attach was detected |
| Security | `4950` | An IPsec Main Mode security association was established |
| Security | `4697` | A service was installed in the system |
| Security | `4713` | Kerberos policy was changed |
| Security | `4714` | Encrypted data recovery policy was changed |
| Security | `4719` | System audit policy was changed |
| Security | `4720` | A user account was created |
| Security | `4723` | An attempt was made to change an account's password |
| Security | `4724` | An attempt was made to reset an accounts password |
| Security | `4725` | A user account was disabled |
| Security | `4726` | A user account was deleted |
| Security | `4738` | A user account was changed |
| Security | `4739` | Domain Policy was changed |
| Security | `4740` | A user account was locked out |
| Security | `4781` | A computer account was created |
| System | `1083` | The security descriptor version number could not be determined |
| System | `1202` | Security policies were propagated with warning. 0x534 : No mapping between account names and security IDs was done |
| System | `1265` | The attempt to establish a replication link for the following writable directory partition failed |
| System | `1311` | The Knowledge Consistency Checker (KCC) has detected problems with the following directory partition |
| System | `1388` | During the past [number] days; replication errors in one or more directory partitions have caused replication to be disabled for the specified naming context on the current domain controller |
| System | `1645` | Active Directory Domain Services has detected that the domain is still using the default password for the 'Administrator' account |
| System | `5805` | The session setup from the computer [computer name] failed to authenticate |
| System | `5807` | During the past [number] days; there have been a few replication errors in the forest. There may be network or connectivity problems in the forest |

##### See your data

In New Relic, you can query your results with this NRQL pattern:

```
FROM Log SELECT
  hostname AS 'Host',
  Channel,
  EventID,
  message AS 'Message'
WHERE logtype = 'active_directory'
SINCE 1 DAY AGO
LIMIT MAX
```

## Support

New Relic hosts and moderates an online forum where you can interact with New Relic employees as well as other customers to get help and share best practices. Like all official New Relic open source projects, there's a related Community topic in the New Relic Explorers Hub. You can find this project's topic/threads here:

>TO-DO :: Add the url for the support thread here: discuss.newrelic.com

## Contribute

We encourage your contributions to improve [project name]! Keep in mind that when you submit your pull request, you'll need to sign the CLA via the click-through using CLA-Assistant. You only have to sign the CLA one time per project.

If you have any questions, or to execute our corporate CLA (which is required if your contribution is on behalf of a company), drop us an email at opensource@newrelic.com.

**A note about vulnerabilities**

As noted in our [security policy](../../security/policy), New Relic is committed to the privacy and security of our customers and their data. We believe that providing coordinated disclosure by security researchers and engaging with the security community are important means to achieve our security goals.

If you believe you have found a security vulnerability in this project or any of New Relic's products or websites, we welcome and greatly appreciate you reporting it to New Relic through [HackerOne](https://hackerone.com/newrelic).

If you would like to contribute to this project, review [these guidelines](./CONTRIBUTING.md).

To all contributors, we thank you!  Without your contribution, this project would not be what it is today.  We also host a community project page dedicated to [Project Name](<LINK TO https://opensource.newrelic.com/projects/... PAGE>).

## License
New Relic Active Directory Integration is licensed under the [Apache 2.0](http://apache.org/licenses/LICENSE-2.0.txt) License.
