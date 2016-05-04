param (
	[string]$ocExe,
	[string]$server,
	[string]$username,
	[string]$password,
	[string]$clientCert,
	[string]$skipTls,
	[string]$buildconfig,
    [string]$token,
    [string]$namespace
)

$oldVerbose = $VerbosePreference
$VerbosePreference = "Continue"

Write-Verbose "Entering oc.ps1"

Write-Verbose "ocExe = $ocExe"
Write-Verbose "server = $server"
Write-Verbose "buildconfig = $buildconfig"
Write-Verbose "token = $token"
Write-Verbose "namespace = $namespace"
Write-Verbose "skipTls = $skipTls"
$clientCertEmpty = !$clientCert
Write-Verbose "clientCert empty? $clientCertEmpty"
$usernameEmpty = !$username
Write-Verbose "username empty? $usernameEmpty"
$passwordEmpty = !$password
Write-Verbose "password empty? $passwordEmpty"

# Import the Task.Common dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

if (-not (Test-Path -Path $ocExe -PathType Leaf)) {
    throw 'Openshift client not installed in the provided location.'
}

if(!$buildconfig)
{
    throw (Get-LocalizedString -Key "Buildconfig parameter is not set")
}

if(!$token)
{
    throw (Get-LocalizedString -Key "Token parameter is not set")
}

if(!$namespace)
{
    throw (Get-LocalizedString -Key "Namespace parameter is not set")
}

if(!$clientCert -and (!$username -or !$password))
{
    throw (Get-LocalizedString -Key "Either clientCert or username and password must be set")
}

if(!(Test-Path $token -PathType Leaf))
{
    throw ("$token does not exist");
}

Write-Verbose "Reading token content"
$tokenContent = [IO.File]::ReadAllText("$token").Trim()

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

Write-Verbose "Calling start-build"
& $ocExe --token="$tokenContent" start-build $buildconfig --follow -n $namespace 2>&1 

if (-not $?) {
                Write-Error 'oc.exe failed. Exiting oc.ps1'
				$VerbosePreference = $oldVerbose
				exit 100 
}


Write-Verbose "Leaving script oc.ps1"

$VerbosePreference = $oldVerbose
