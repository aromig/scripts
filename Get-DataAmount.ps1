Function Get-DataAmount
{
<#
		.SYNOPSIS
			Gathers file sizes and quantities from a remote Windows machine. The script first gathers from the logged in user's profile and then prompts for other folders to check.
			
		.PARAMETER Computer
			Required. The name of the remote computer. If you do not specifiy one, you will be prompted.
			
		.EXAMPLE
			PS C:\> Get-DataAmount RETDAYV-9600030
		
		.NOTES
			Created by Adam Romig (Adam.Romig@ReedElsevier.com)
			Last Updated: 2013-06-24
#>
	[CmdletBinding()]
	Param(
	[Parameter(ValueFromPipeline=$true,Mandatory=$true)] [ValidateNotNullOrEmpty()]
		[string] $Computer
	)

	Clear-Host
	$strComputer = $Computer.toUpper()
	
	$objProfile = @()
	$objAdditional = @()
	
	$sumFiles = 0

	#Test Connectivity
	Write-Progress -Activity "Establishing Connection to $Computer" -Status "Checking Connectivity" -CurrentOperation "Please Wait"
	
	if ($strComputer -and $strComputer -notlike '.' -and !(Test-Connection -Quiet $strComputer)){
		Write-Host -BackgroundColor Black -ForegroundColor Red "$strComputer Unreachable"
		continue
	}
	
	Write-Progress -Activity "Collecting Data Size" -Status "Determining User Profile Path" -CurrentOperation "Please Wait"
	
	#Determine Operating System
	$wmiOS = Get-WmiObject -Computer $strComputer -Class Win32_OperatingSystem
	if ($wmiOS.Caption.StartsWith("Microsoft Windows 7")) { $strOS = "Win7" }
	elseif ($wmiOS.Caption.StartsWith("Microsoft Windows XP")) { $strOS = "WinXP" }
	
	#Get User Profile Path
	$wmiComputerSystem = Get-WmiObject -computer $strComputer -Class Win32_ComputerSystem
	if ($wmiComputerSystem.Username)
	{
		$arrDomainID = $wmiComputerSystem.Username.Split("\")
		$strUsername = $arrDomainID[1]
	}
	else
	{
		$strUsername = ""
	}
	if ($strOS -eq "WinXP") { $strUserProfile = "\Documents and Settings\" + $strUsername }
	else { $strUserProfile = "\Users\" + $strUsername }
	
	#Map PSDrive
	[void] (New-PSDrive -Name GetData -PSProvider FileSystem -root \\$strComputer\C`$$strUserProfile -ErrorVariable errPSDrive -ErrorAction SilentlyContinue)
	
	if ($errPSDrive)
	{
		[void] (New-PSDrive -Name GetData -PSProvider FileSystem -root \\$strComputer\D`$$strUserProfile -ErrorVariable errPSDrive -ErrorAction SilentlyContinue)
		$dDrive = 1
	}
	
	Write-Progress -Activity "Collecting Data Size" -Status "Calculating Profile Folder Sizes" -CurrentOperation "Please Wait"

	"Computer Name: $strComputer"
	"Operating System: $strOS`n`r"
	
	$profileFldrs = Get-ChildItem GetData:\ | ?{ $_.PSIsContainer } | Select-Object FullName
	foreach ($i in $profileFldrs)
	{
		if ($i.FullName.toLower().EndsWith("desktop"))
		{
			Write-Progress -Activity "Collecting Data Size" -Status "Calculating Profile Folder Sizes : Desktop" -CurrentOperation "Please Wait"
			$colItems = Get-ChildItem $i.FullName -Recurse | Measure-Object -Property length -Sum -ErrorAction SilentlyContinue
			$sumDesktop = ($colItems.sum / 1GB)
			$strDesktop = "{0:N2}" -f ($colItems.sum / 1GB) + " GB"
			#"Desktop   : $strDesktop"
			$item = '' | Select Location,SizeGB,NumberOfFiles
			$item.Location = "Desktop"
			$item.SizeGB = $strDesktop -replace " GB", ""
			$item.NumberOfFiles = (Get-ChildItem $i.FullName -Recurse | Where-Object {!$_.PSIsContainer}).Count
			$sumFiles += (Get-ChildItem $i.FullName -Recurse | Measure-Object | Where-Object {!$_.PSIsContainer}).Count
			$objProfile += $item
		}
		
		if ($i.FullName.toLower().EndsWith("favorites"))
		{
			Write-Progress -Activity "Collecting Data Size" -Status "Calculating Profile Folder Sizes : Favorites" -CurrentOperation "Please Wait"
			$colItems = Get-ChildItem $i.FullName -Recurse | Measure-Object -Property length -Sum -ErrorAction SilentlyContinue
			$sumFavorites = ($colItems.sum / 1GB)
			$strFavorites = "{0:N2}" -f ($colItems.sum / 1GB) + " GB"
			#"Favorites : $strFavorites"
			$item = '' | Select Location,SizeGB,NumberOfFiles
			$item.Location = "Favorites"
			$item.SizeGB = $strFavorites -replace " GB", ""
			$item.NumberOfFiles = (Get-ChildItem $i.FullName -Recurse | Where-Object {!$_.PSIsContainer}).Count
			$sumFiles += (Get-ChildItem $i.FullName -Recurse | Measure-Object | Where-Object {!$_.PSIsContainer}).Count
			$objProfile += $item
		}
		
		if ($i.FullName.toLower().EndsWith("documents"))
		{
			Write-Progress -Activity "Collecting Data Size" -Status "Calculating Profile Folder Sizes : Documents" -CurrentOperation "Please Wait"
			$colItems = Get-ChildItem $i.FullName -Recurse | Measure-Object -Property length -Sum -ErrorAction SilentlyContinue
			$sumDocuments = ($colItems.sum / 1GB)
			$strDocuments = "{0:N2}" -f ($colItems.sum / 1GB) + " GB"
			#"Documents : $strDocuments"
			$item = '' | Select Location,SizeGB,NumberOfFiles
			$item.Location = "Documents"
			$item.SizeGB = $strDocuments -replace " GB", ""
			$item.NumberOfFiles = (Get-ChildItem $i.FullName -Recurse | Where-Object {!$_.PSIsContainer}).Count
			$sumFiles += (Get-ChildItem $i.FullName -Recurse | Measure-Object | Where-Object {!$_.PSIsContainer}).Count
			$objProfile += $item
		}
		
		if ($i.FullName.toLower().EndsWith("music"))
		{
			Write-Progress -Activity "Collecting Data Size" -Status "Calculating Profile Folder Sizes : Music" -CurrentOperation "Please Wait"
			$colItems = Get-ChildItem $i.FullName -Recurse | Measure-Object -Property length -Sum -ErrorAction SilentlyContinue
			$sumMusic = ($colItems.sum / 1GB)
			$strMusic = "{0:N2}" -f ($colItems.sum / 1GB) + " GB"
			#"Music     : $strMusic"
			$item = '' | Select Location,SizeGB,NumberOfFiles
			$item.Location = "Music"
			$item.SizeGB = $strMusic -replace " GB", ""
			$item.NumberOfFiles = (Get-ChildItem $i.FullName -Recurse | Where-Object {!$_.PSIsContainer}).Count
			$sumFiles += (Get-ChildItem $i.FullName -Recurse | Measure-Object | Where-Object {!$_.PSIsContainer}).Count
			$objProfile += $item
		}
		
		if ($i.FullName.toLower().EndsWith("pictures"))
		{
			Write-Progress -Activity "Collecting Data Size" -Status "Calculating Profile Folder Sizes : Pictures" -CurrentOperation "Please Wait"
			$colItems = Get-ChildItem $i.FullName -Recurse | Measure-Object -Property length -Sum -ErrorAction SilentlyContinue
			$sumPictures = ($colItems.sum / 1GB)
			$strPictures = "{0:N2}" -f ($colItems.sum / 1GB) + " GB"
			#"Pictures  : $strPictures"
			$item = '' | Select Location,SizeGB,NumberOfFiles
			$item.Location = "Pictures"
			$item.SizeGB = $strPictures -replace " GB", ""
			$item.NumberOfFiles = (Get-ChildItem $i.FullName -Recurse | Where-Object {!$_.PSIsContainer}).Count
			$sumFiles += (Get-ChildItem $i.FullName -Recurse | Measure-Object | Where-Object {!$_.PSIsContainer}).Count
			$objProfile += $item
		}
		
		if ($i.FullName.toLower().EndsWith("videos"))
		{
			Write-Progress -Activity "Collecting Data Size" -Status "Calculating Profile Folder Sizes : Videos" -CurrentOperation "Please Wait"
			$colItems = Get-ChildItem $i.FullName -Recurse | Measure-Object -Property length -Sum -ErrorAction SilentlyContinue
			$sumVideos = ($colItems.sum / 1GB)
			$strVideos = "{0:N2}" -f ($colItems.sum / 1GB) + " GB"
			#"Videos    : $strVideos"
			$item = '' | Select Location,SizeGB,NumberOfFiles
			$item.Location = "Videos"
			$item.SizeGB = $strVideos -replace " GB", ""
			$item.NumberOfFiles = (Get-ChildItem $i.FullName -Recurse | Measure-Object | Where-Object {!$_.PSIsContainer}).Count
			$sumFiles += (Get-ChildItem $i.FullName -Recurse | Measure-Object | Where-Object {!$_.PSIsContainer}).Count
			$objProfile += $item
		}
	}
	
	#Include Hidden Outlook Folder
	if ($strOS -eq "WinXP") { $pathOLK = "GetData:\Local Settings\Application Data\Microsoft\Outlook" }
	else { $pathOLK = "GetData:\AppData\Roaming\Microsoft\Outlook" }
	Write-Progress -Activity "Collecting Data Size" -Status "Calculating Profile Folder Sizes : Hidden Outlook Files" -CurrentOperation "Please Wait"
	if (Test-Path -Path $pathOLK)
	{
		$countOLK = 0
		$colFiles = Get-ChildItem $pathOLK | Select-Object Name, Length
		$sumOLK = 0
		foreach ($i in $colFiles)
		{
			if ($i.Name.EndsWith(".pst"))
			{
				$sumOLK += $i.Length
				$countOLK++
			}
		}
		if ($sumOLK -gt 0)
		{
			$strOLK = "{0:N2}" -f ($sumOLK / 1GB) + " GB"
			#"Outlook   : $strOLK (Hidden Folder)"
			#"Outlook   : $strOLK -- \\$strComputer\C`$" + $pathOLK -replace "GetData:", $strUserProfile
			$item = '' | Select Location,SizeGB,NumberOfFiles
			$item.Location = "Outlook (Hidden Folder)"
			$item.SizeGB = $strOLK -replace " GB", ""
			$item.NumberOfFiles = $countOLK
			$sumFiles += $countOLK
			$objProfile += $item
		}
	}
	
	Write-Object "Profile Folders -- $strUserProfile" $objProfile "Table"
	
	
	#Prompt for additional folders. Cancel continues routine.
	Write-Progress -Activity "Collecting Data Size" -Status "Prompting for Additional Folders to Calculate" -CurrentOperation "Please Select Folders"
	$remotePath = '\\' + $strComputer + '\C$'
	$extraFolders = @()
	$sumFolders = 0
	
	Do
	{
		$folder = Select-Folder -message 'Select Additional Folders to Calculate. Press Cancel when complete.' -path $remotePath
		if ($folder)
		{
			$extraFolders += $folder
			$folderName = Split-Path $folder -Leaf
			Write-Progress -Activity "Collecting Data Size" -Status "Added Additional Folder : $folderName" -CurrentOperation "Please Select Folders"
		}
	}
	While ($folder)
	
	if ($dDrive -eq 1)
	{
		$remotePath = '\\' + $strComputer + '\D$'
		Do
		{
			$folder = Select-Folder -message 'Select Additional Folders to Calculate. Press Cancel when complete.' -path $remotePath
			if ($folder)
			{
				$extraFolders += $folder
				$folderName = Split-Path $folder -Leaf
				Write-Progress -Activity "Collecting Data Size" -Status "Added Additional Folder : $folderName" -CurrentOperation "Please Select Folders"
			}
		}
		While ($folder)
	}
	
	#Calculate Chosen Folders
	foreach ($folder in $extraFolders)
	{
		$folderName = Split-Path $folder -Leaf
		Write-Progress -Activity "Collecting Data Size" -Status "Calculating Addtional Folder : $folderName" -CurrentOperation "Please Wait"
		$colItems = Get-ChildItem $folder -Recurse | Measure-Object -Property length -Sum -ErrorAction SilentlyContinue
		$sumFolders += ($colItems.sum / 1GB)
		#$folderName + " : {0:N2}" -f ($colItems.sum / 1GB) + " GB"
		$item = '' | Select Folder,SizeGB,NumberOfFiles
		$item.Folder = $folderName
		$item.SizeGB = "{0:N2}" -f ($colItems.sum / 1GB)
		$item.NumberOfFiles = (Get-ChildItem $folder -Recurse | Where-Object {!$_.PSIsContainer}).Count
		$sumFiles += (Get-ChildItem $folder -Recurse | Measure-Object | Where-Object {!$_.PSIsContainer}).Count
		$objAdditional += $item
	}
	
	Write-Object "Additional Folders" $objAdditional "Table"
	
	#Show Totals
	$sumProfile = $sumDesktop + $sumFavorites + $sumDocuments
	if ($strOS = "Win7") { $sumProfile = $sumProfile + $sumMusic + $sumPictures + $sumVideos }
	$sumTotal = $sumProfile + $sumFolders
	"`n`rTotal : {0:N2}" -f $sumTotal + " GB ({0:N2}" -f $sumProfile + " GB in Profile)"
	"Total Files : $sumFiles`n`r"
}

Function Select-Folder($message='Select a folder', $path = 17)
{
	$objShellApp = New-Object -ComObject Shell.Application
	$browseFolder = $objShellApp.BrowseForFolder(0, $message, 0, $path)
	if ($browseFolder -ne $null) { $browseFolder.self.Path }
}

#Create a function to write output -- Borrowed from Chris Pawel's Get-Info
Function Write-Object ([String]$strTitle,$objResult,[String]$type)
{
	#Write-Console
	Write-Host -ForegroundColor DarkGreen "---------------------------------------------------------------------------"
	Write-Host -ForegroundColor Green "    $strTitle"
	Write-Host -ForegroundColor DarkGreen "---------------------------------------------------------------------------"
	Write-Host $null
	if ($type -EQ "List"){ Write-Output $objResult | Format-List }
	if ($type -EQ "Table"){ Write-Output $objResult | Format-Table -AutoSize -Wrap }
}