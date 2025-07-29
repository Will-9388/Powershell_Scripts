A collection of PowerShell scripts I use in professional environments to monitor state/health of various resources on Azure-hosted Windows Server instances. 
Server and service names are removed/placeholders.

CPU Usage Alarm.ps1 - Continually monitors for CPU usage spikes on list of remote servers and alerts immediately on exceeded threshold.

Memory Usage Alarm.ps1 - Continually monitors for Memory usage spikes on list of remote servers and alerts immediately on exceeded threshold.

Disk Space Check.ps1 - Check space for C and E drive of a list of remote servers

Service Alarm.ps1 - Continually monitors the state of critical services on a list of remote servers and alerts immediately on any state other than running. Updated to handle checking for multiple versions of a service and not alerting if one was off and one was on. Alerts only if both are off/missing. Also updated to handle some servers not utilizing one of the services.
