try {

	$iisVersion = (get-itemproperty HKLM:\SOFTWARE\Microsoft\InetStp\ -erroraction silentlycontinue | select MajorVersion).MajorVersion

	If($iisVersion -lt 6){
		Write-Host "IIS is not installed and it's required"
		Return
	}
	
	$anySqlServer = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server' -erroraction silentlycontinue).InstalledInstances.Count
	if ($anySqlServer -eq $null)
	{
		Write-Host "SQL Server is not installed and it's required"
		Return
	}

    Write-Host "Installing MS TFS Express"
	Install-ChocolateyPackage 'VisualStudioTFSExpress2012' 'exe' "/Quiet" 'http://download.microsoft.com/download/7/9/C/79C84B0F-12C1-48A5-B741-7DFE60F54CD0/TFS4/tfs_express.exe'
	
	Write-Host "Getting TFSConfig full path"
	$path = (Get-ChildItem -path $env:systemdrive\ -filter "tfsconfig.exe" -erroraction silentlycontinue  -recurse)[0].FullName

	Write-Host "Configuring TFS standard" do
	& $path unattend /configure /type:standard

    if ($lastExitCode -and ($lastExitCode -ne 0)) { throw "Install MS TFS Express failed." }    
} catch { 
    Write-ChocolateyFailure 'VisualStudioTFSExpress2012' "$($_.Exception.Message)"
}