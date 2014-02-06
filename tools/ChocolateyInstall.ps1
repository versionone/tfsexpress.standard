try {
    Write-Host "Installing MS TFS Express"
	Install-ChocolateyPackage 'VisualStudioTFSExpress2012' 'exe' "/Quiet" 'http://download.microsoft.com/download/7/9/C/79C84B0F-12C1-48A5-B741-7DFE60F54CD0/TFS4/tfs_express.exe'
	
	Write-Host "Getting TFSConfig full path"
	$path = (Get-ChildItem -path $env:systemdrive\ -filter "tfsconfig.exe" -erroraction silentlycontinue  -recurse)[0].FullName

    $TfsConfigIni = "config_standard.ini"

    Write-Host "Creating TFS standard configuration file"
	& $path unattend /create /type:standard /unattendfile:$TfsConfigIni

    Write-Host "Configuring TFS standard" do
	& $path unattend /configure /unattendfile:$TfsConfigIni

    if ($lastExitCode -and ($lastExitCode -ne 0)) { throw "Install MS TFS Express failed." }    
} catch { 
    Write-ChocolateyFailure 'VisualStudioTFSExpress2012' "$($_.Exception.Message)"
}