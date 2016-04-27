param (
	[string]$ocExe,
    [string]$token,
    [string]$namespace
)

Write-Verbose 'Entering oc.ps1'
Write-Verbose "ocExe = $ocExe"
Write-Verbose "token = $token"
Write-Verbose "namespace = $namespace"

# Import the Task.Common dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

if (-not (Test-Path -Path $ocExe -PathType Leaf)) {
    throw 'Openshift client not installed in the provided location.'
}

if(!$token)
{
    throw (Get-LocalizedString -Key "Token parameter is not set")
}

if(!$namespace)
{
    throw (Get-LocalizedString -Key "Namespace parameter is not set")
}

if(!(Test-Path $token -PathType Leaf))
{
    throw ("$token does not exist");
}
Write-Verbose "Reading token content"
$tokenContent = [IO.File]::ReadAllText("$token")

Write-Verbose "Calling Openshift client"

& $ocExe --token="$tokenContent" -n $namespace 2>&1 
if (-not $?) {
                Write-Error 'oc.exe failed. Exiting oc.ps1'
				exit 100 
}

Write-Verbose "Leaving script oc.ps1"
