<#
	Quick script to parse the event logs and pull out the results of a weekly DBCC check.
	I need to make sure they run properly weekly without errors. At the end I log the results
	into a database to furter process in a summary email (other script).
	
	Last modified: 4-13-2011 GF

#>

#Add SQL snapin if you are using a db for logging
	Add-PSSnapin "SqlServerCmdletSnapin100" -ErrorAction:SilentlyContinue
	Add-PSSnapin "SqlServerProviderSnapin100" -ErrorAction:SilentlyContinue
	
#initial variables
	$servers = "sql01.my.lab","sql02.my.lab"

#Setup time frame that you need
	$lastSaturday = (get-date).AddDays("-2")

#Parse through each server and grab the results
	foreach ($server in $servers)
		{
			#Grab DBCC after the date I specified on the server we are currently working with.
			$results = get-eventlog -logname application -computername $server -After $lastSaturday  | where {($_.eventID -eq 8957)} 
			
			#If we found something we'll grab the details.
			if ($results)
				{
					foreach ($entry in $results)
					{
						#Grab values we care to log
						$time = $entry.TimeWritten
						$source = $entry.Source
						$errorCount = $entry.ReplacementStrings[7] #log how many errors the event log tells us we have.
						$message = $entry.ReplacementStrings[1] + " " + $entry.ReplacementStrings[5] + " on " + $entry.ReplacementStrings[2] + " found " + $errorCount + " errors"
				
						#If there is no errors then we are good and we set the pass to 1! That will help us to filter later when generating a report.
						switch ($errorCount)
							{
								"0"   {$pass = 1}
								default {$pass = 0}
							}
								
						#Construct SQL insert											
						$sqlcmd = "insert into dbo.DBCCresults values ('$time','$source',' $message','$pass','$errorCount')"		
						Invoke-Sqlcmd -serverInstance "mgmtServer.my.lab" -Database "myEnv" -Username "sa" -Password "removedForDemo" -Query $sqlCmd				
					}
			
				}
		}