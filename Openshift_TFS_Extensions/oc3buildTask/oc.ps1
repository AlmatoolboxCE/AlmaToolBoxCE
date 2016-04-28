param (
	[string]$ocExe,
	[string]$server,
	[string]$username,
	[string]$password,
	[string]$clientCert,
	[bool]$skipTls,
	[string]$buildconfig,
    [string]$token,
    [string]$namespace
)


"Entering oc.ps1"

"ocExe = $ocExe"
"server = $server"
"buildconfig = $buildconfig"
"token = $token"
"namespace = $namespace"
"skipTls = $skipTls"
"clientCert empty? !$clientCert"
"username empty? !$username"
"password empty? !$password"

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

if(!$clientCert -end (!$username -or !$password))
{
    throw (Get-LocalizedString -Key "Either clientCert or username and password must be set")
}

if(!(Test-Path $token -PathType Leaf))
{
    throw ("$token does not exist");
}

"Reading token content"
$tokenContent = [IO.File]::ReadAllText("$token").Trim()

"Constructing login parameters"
$loginCredentials = If (!$clientCert) {
	-u $username -p $password
} Else {
	--certificate-authority="$clientCert"
} 

"Logging in: $ocExe login $server $loginCredentials --insecure-skip-tls-verify=$skipTls"
& $ocExe login $server $loginCredentials --insecure-skip-tls-verify=$skipTls 2>&1

"Calling start-build $ocExe --token="$tokenContent" start-build $buildconfig --follow -n $namespace"
& $ocExe --token="$tokenContent" start-build $buildconfig --follow -n $namespace 2>&1 

if (-not $?) {
                Write-Error 'oc.exe failed. Exiting oc.ps1'
				exit 100 
}

"Leaving script oc.ps1"
