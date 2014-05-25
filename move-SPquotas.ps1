<#
	This script is meant to export a webapp's quota templates to a CSV
	This can serve as a backup or an easy way to transfer quotas to a lab environment
	or another SP farm.
	
	Syntax: ./move-SPquotas.ps1 -originalWA "http://SP01WA001"  -destinationWA "http://SP02WA001"
#>
param( $originalWA,$destinationWA)

if($originalWA -and $destinationWA)
{
	#Grab the original web app and export the templates
		$wa = Get-SPWebApplication $originalWA
		
		if($wa)
		{
			$wa.WebService.QuotaTemplates | Export-Csv -Path c:\temp\quotas.csv
		}
		else
		{
			Write-Host "Unable to retreive original web app"
			return
		}

	#Retreive destination web app and add the templates.
		$desWA = Get-SPWebApplication $destinationWA
		
		if($desWA)
		{
			$WAquotas = $desWA.WebService.QuotaTemplates		
		}
		else
		{
			Write-Host "Unable to retreive destionation web app"
			return
		}

		$quotaTemplates = Import-Csv -Path c:\temp\quotas.csv

	#Loop through each template and add it to farm.
		if($quotaTemplates)
		{		
			foreach ($template in $quotaTemplates)
			{
				$currentTemplate = New-Object -TypeName Microsoft.SharePoint.Administration.SPQuotaTemplate
				$currentTemplate.Name = $template.Name
				$currentTemplate.StorageMaximumLevel = $template.StorageMaximumLevel
				$currentTemplate.StorageWarningLevel = $template.StorageWarningLevel
					
				$WAquotas.Add($currentTemplate)
			}
		}
		else
		{
			Write-Host "Unable to get quota from files"
			return
		}
}
else
{
	Write-Host "Please specify both original and destionation WA urls"
}