<#
	This script is meant to rewrite the hostfile.
	The hostfile can be pesky with it's encoding so it is important that we write the file in a certain way.
	The script removes an row from the hostfile. It can be easily modified to add lines as well.
	
	Syntax: ./remove-fromHostFile -ip "173.194.74.121" -site "blog.gferreira.me"
	
	Additional info can be found here: http://blog.gferreira.me/2011/01/yank-out-that-entry.html
#>
param ($ip, $site)

if($ip -and $site)
{
	#Get content and create a backup file of the host file
		$hostFile = Get-Content "C:\Windows\System32\drivers\etc\hosts"
		$hostFile | Out-File "C:\Windows\System32\drivers\etc\hosts-BAKUP"
		
	#Parse through file and find correct line to remove
		foreach ($line in $hostFile)
		{
			if ($line -eq "$ip	$site")
			{
				Write-Output "Found the line! Excluding it from new host file"
			}
			else
			{
				$newHost += $line
			}
		}
		
	#Export HostFile using correct encoding
		$newHost | Out-File C:\Windows\System32\drivers\etc\hosts -Encoding:ascii -ErrorAction:SilentlyContinue
			
}
else
{
	Write-Host "Both IP and site are required"
}


	