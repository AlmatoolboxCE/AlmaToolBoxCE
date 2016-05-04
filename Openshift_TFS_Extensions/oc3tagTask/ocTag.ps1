param (
	[string]$ocExe,
	[string]$server,
	[string]$username,
	[string]$password,
	[string]$clientCert,
	[string]$skipTls,
	[string]$source,
    [string]$destination,
    [string]$sourceType
)

$oldVerbose = $VerbosePreference
$VerbosePreference = "Continue"

Write-Verbose "Entering oc.ps1"

Write-Verbose "ocExe = $ocExe"
Write-Verbose "server = $server"
Write-Verbose "source = $source"
Write-Verbose "destination = $destination"
Write-Verbose "namespace = $namespace"
Write-Verbose "skipTls = $skipTls"
$clientCertEmpty = !$clientCert
Write-Verbose "clientCert ($clientCert) empty? $clientCertEmpty"
$usernameEmpty = !$username
Write-Verbose "username empty? $usernameEmpty"
$passwordEmpty = !$password
Write-Verbose "password empty? $passwordEmpty"

# Import the Task.Common dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

if (-not (Test-Path -Path $ocExe -PathType Leaf)) {
    throw 'Openshift client not installed in the provided location.'
}

if(!$source)
{
    throw (Get-LocalizedString -Key "Source parameter is not set")
}

if(!$destination)
{
    throw (Get-LocalizedString -Key "Destination parameter is not set")
}


if(!$clientCert -and (!$username -or !$password))
{
    throw (Get-LocalizedString -Key "Either clientCert or username and password must be set")
}

Write-Verbose "Constructing source Type parameter"

$sourceTypeStr = if(!$sourceType) {
	''
} Else {
	'--source=$sourceType'
}

Write-Verbose "Logging in"
If (!$clientCert) {
	& $ocExe login $server --username=$username --password=$password --insecure-skip-tls-verify=$skipTls
} Else {
	& $ocExe login $server --certificate-authority='$clientCert' --insecure-skip-tls-verify=$skipTls
} 

if (-not $?) {
                Write-Error 'oc.exe failed to log in. Exiting oc.ps1'
				$VerbosePreference = $oldVerbose
				exit 100 
}

Write-Verbose "Calling tag"
& $ocExe tag $sourceTypeStr $source $destination 2>&1 

if (-not $?) {
                Write-Error 'oc.exe failed. Exiting oc.ps1'
				$VerbosePreference = $oldVerbose
				exit 100 
}


Write-Verbose "Leaving script oc.ps1"

$VerbosePreference = $oldVerbose
