## Departing Windows SysAdmin

We've all had colleagues leave our units for greener pastures. The idea behind this repo was to keep a collection of scripts to run when that happens and suggestions on next steps.

In our situation, the departing admin managed our file, print, and various other resource servers.

Each script is designed to be run on the server they are reporting on. Making sure we didn't miss anything due to a firewall configuration or GPO setting.

- File Server Script
 - Report on all established shares
 - Report sharing and ACL permissions for each share
- General Server Script
 - Report on the currently running processes. If possible, list the ports they are listening on
 - Report on all services on the system
 - Report on all scheduled tasks
 - For each determine which account they are running under and the location of the executable



