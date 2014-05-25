<# 
	Script to change Site collection quota on a WSS v3 site.
	Usage ./set-SPQuota.ps1 -url "http://gil.gil.com" -template "2GB Sharepoint Site" -minsize "optional/integer" -whatif:$false
	Last modified 11/19/09 Gil
#>
param ([string]$url, [string]$template, [int]$minsize = 0, [switch]$whatif)

#Load the required SharePoint assemblies containing the classes used in the script
	[Reflection.Assembly]::Load("Microsoft.SharePoint,Version=12.0.0.0,Culture=neutral,PublicKeyToken=71e9bce111e9429c") | Out-Null

function Show-Usage
{
	#Write usage information to host
		Write-Host "Usage: .\set-SPQuota.ps1 -url <web application URL> -template <Quota template name> [-minsize <minimum size (Mb) a site collection must be>] [-whatif]`n" `
		-BackgroundColor Black -ForegroundColor blue

		break
}

function Check-Params
{
	#If any exception occurs, display usage and exit
		trap {Show-Usage; continue}
	
	#If either -url or -template were not specified, or if value of -url is not a valid url, display usage and exit
		if ((-not ([uri]$url).IsAbsoluteUri) -or (-not $template))
		{
			Show-Usage
		}
	
	#Create a reference to the Windows SharePoint Services Web Application service and store it in the $was variable
		$was = [Microsoft.SharePoint.Administration.SPFarm]::Local.Services | Where-Object {$_.TypeName -eq "Windows SharePoint Services Web Application"}
	
	#Retrieve the template from the collection of all quota templates by its name and store the reference in the $script:temp varaible.
		$script:qtemp = $was.QuotaTemplates[$template]
	
	#If the template could not be found, display a warning message and exit.
	#The warning message also includes names of all templates that do exist
	if (-not $script:qtemp)
	{
		Write-Host ('"{0}" is not a valid quota template name. The following quota templates are available: {1}{2}' `
			-f $template, ([string]::Join(", ", ($was.QuotaTemplates | ForEach-Object {$_.Name}))), "`n") -BackgroundColor Black -ForegroundColor Red
		break
	}
	
	#Create a reference to the target web application by using url lookup and store it in the $script:wa variable.
		$script:wa = [Microsoft.SharePoint.Administration.SPWebApplication]::Lookup($url)
	
	#If the web application could not be found, display a warning message and exit
		if (-not $script:wa)
		{
			Write-Host ("Could not find a SharePoint web application at " + $url + ". Application does not exist.`n") -BackgroundColor Black -ForegroundColor Red
			break
		}
}

#begining of the script
#Call the Check-Params function - this is the entry point to the script
	Check-Params

#Find only the Site Collection specified and change that. This was done by using where {$_.... to filter
	$script:wa.Sites | where {$_.Url -eq $url} |
		ForEach-Object `
		{
			#Check if the site of site collection is between the quota template limit and the specified minimum.
			#If it is not then the quota cannot be applied
				if (($_.Usage.Storage -le $script:qtemp.StorageMaximumLevel) -and ($_.Usage.Storage -gt ($minsize * 1Mb)))
				{
					# Site collection size is OK - display information message
						Write-Host $("Applying quota template `"{0}`" to site collection at {1}`nCurrent value: {2} Mb / New value: {3} Mb`n" `
						-f $template, $_.Url, ($_.Quota.StorageMaximumLevel / 1Mb), ($script:qtemp.StorageMaximumLevel / 1Mb)) `
						-ForegroundColor Green -BackgroundColor Black
					
					#If the -whatif parameter wasn't used, actually apply the template
					if (-not $whatif)
					{
						$_.Quota = $script:qtemp
					}
				}
				else
				{
					# Site collection is too large or too small for quota template - display a warning message
					Write-Host $("Skipping site collection at {0}`nCurrent site collection size of {1} Mb is outside the target range of {2} - {3} Mb `n" `
						-f $_.Url, ([math]::Round($_.Usage.Storage / 1Mb, 2)), ($script:qtemp.StorageMaximumLevel / 1Mb), $template) `
						-ForegroundColor Magenta -BackgroundColor Black;
				}
            $_.Dispose();
		}