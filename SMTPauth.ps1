<#
	This script is using meant to send messages using SMTPauth to an exchange server
	This script can be used for sending bulk messages, load testing, SMTP log generating, etc.
	I used it as a helper script that would help me detect spammer trends based on SMTP auth message counts
	last updated: 01/10/2013 Gil
#>

	#Define your variables here
		$smtpHost = 'mySecure.SMTPserver.com'
		$userSAMname = 'gil' #This should be the SAMname of a user that has permissions to authenticate against exchange
		$userPassword = 'mySuperSecurePW!!!' #User PW
		$windowsDomain = 'myDomain' #Windows domain name	
		$sender = 'gil@sender.com' #Send email address
		$recipient = 'loadedBox@sender.com' #Recipient email address
		$msgCount = 300 #How many messages to send out
	
	#Some other variables
		$successCount, $ErrorCount = 0 #Let's keep track of successful/error messages.
		$SmtpClient = new-object system.net.mail.smtpClient  
		$smtpclient.Host = $smtpHost
	
	#Authentication based on http://msdn.microsoft.com/en-us/library/59x2s2s6.aspx
		$myCreds = New-Object System.Net.NetworkCredential
		$myCreds.UserName = $userSAMname
		$myCreds.Password = $userPassword		
		$myCreds.Domain = $windowsDomain
 
 	#Create SMTP object and authenticate
		$myCredentialCache = New-Object System.Net.CredentialCache	
		$myCredentialCache.Add($SmtpClient.Host,25,"NTLM",$myCreds)
		$SmtpClient.Credentials = $myCredentialCache.GetCredential($SmtpClient.Host,25,"NTLM")
	
	#let's loop through the messages and send out based
	for($i=1; $i -le $msgCount; $i++)
		{
    		if($i%10 -eq 0)
			{	sleep -Seconds 10 }
							
			$smtpclient.Send($sender, $recipient, "Internal Message $i", "This is a test. Bulk message #$i") #Send message
			
			if($?) #Detect successful or not
				{	$successCount++	}
			else
				{	$ErrorCount++	}								
		}
	
	Write-Host "Success: $successCount"
	Write-Host "Error: $errorCount"