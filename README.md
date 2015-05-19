DevOps-PowerShell
=================

A collection of useful powerShell scripts to automate processes.
![devOps powershell scripts](https://github.com/misterGF/DevOps-PowerShell/blob/master/assets/cogs.gif)

* **Change SharePoint item owner in Office 365 - O365** - Script will login to SharePoint Online and parse the lists in the site. It then gathers the items and checks for the user specified in $originalUser. Once found it will update the appropriate values to change the modifyBy and author value based on what is in $newUser.

* **Check SQL DBCC Status** - Script to parse the event logs and pull out the results of a weekly DBCC check.
	I need to make sure they run properly weekly without errors. At the end I log the results
	into a database to furter process in a summary email (other script).

* **Export public folder data using outlook** - Script is meant to export a public folder from outlook into a PST.
	It requires that you have outlook installed on a machine AND have a configured exchange profile.

* **Export SharePoint quota templates** - Script is meant to export a webapp's quota templates to a CSV. This can be used as a backup or an easy way to transfer quotas to a lab environment or another SP farm.

* **Change SharePoint quota for WSS** -  Script to change Site collection quota on a WSS v3 site.

* **Rewrite host file** - Script is meant to rewrite the hostfile. The hostfile can be pesky with it's encoding so it is important that we write the file in a certain way. The script removes an row from the hostfile. It can be easily modified to add lines as well.

* **Send messages via SMTPAuth** - Script is using meant to send messages using SMTPauth to an exchange server. This script can be used for sending bulk messages, load testing, SMTP log generating, etc. I used it as a helper script that would help me detect spammer trends based on SMTP auth message counts.
