<#
	Script will login to SharePoint Online and parse the lists in the site.
	It then gathers the items and checks for the user specified in $originalUser
	Once found it will update the appropriate values to change the modifyBy and author value.

	In the example below I am changing the items I've authored to the ITadmin user.

	Last modified 05/19/15 Gil
#>

#Load necessary module to connect to SPOService
	Import-Module Microsoft.Online.SharePoint.PowerShell

#Login Information for script - Edit appropriately
	$User = "gil@gilTestSPO.onmicrosoft.com" #what you use to login to SPO as an admin
	$Pass = "M78g3lZrJ"  #Your password for that account
	$WebUrl = "https://gilTestSPO.sharepoint.com/" #URL
	$originalUser = "gil@gilTestSPO.onmicrosoft.com"
	$newUser = "itadmin@gilTestSPO.onmicrosoft.com"

#Connect to SharePoint Online service
	Write-Host "Logging into SharePoint online service." -ForegroundColor Green

	$Context = New-Object Microsoft.SharePoint.Client.ClientContext($WebUrl)
	$Context.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User, (ConvertTo-SecureString $Pass -AsPlainText -Force))

#Get the Necessary List
	Write-Host "Getting the required list." -ForegroundColor Green

	$webSite = $Context.Web
	$Lists = $webSite.Lists
	$Context.Load($Lists)
	$Context.ExecuteQuery()

	#Grab the user before we head into the lists
		$siteUsers = $Context.Web.SiteUsers
		$user = $siteUsers.GetByEmail($newUser)

		$Context.Load($user)
		$Context.ExecuteQuery()

	#Parse through the lists
		foreach($List in $Lists)
		{
			"Working on {0}" -f $List.Title

			#Query for items
				$camlQuery = New-Object -TypeName Microsoft.SharePoint.Client.CamlQuery
				$camlQuery.ViewXml = "<View><Query><Where></Where></Query><RowLimit>10000</RowLimit></View>"

				$Items = $List.GetItems($camlQuery)

				#Init the items found
				$Context.Load($Items)
				$Context.ExecuteQuery()

				foreach($item in $Items)
				{
					if($item["Modified_x0020_By"] -like "*$originalUser")
					{
						"Found {0} by {1} on {2}" -f $item["FileRef"], $item["Created_x0020_By"], $item["Created_x0020_Date"]

						$item["Author"] = $user
				        	$item["Editor"] = $user
						$item.Update()
						$Context.ExecuteQuery()
					}
				}
		}

Write-Host "Your changes have now been made." -ForegroundColor Green