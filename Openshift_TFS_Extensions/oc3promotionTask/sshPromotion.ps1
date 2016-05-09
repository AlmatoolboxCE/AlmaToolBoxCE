param (
    [string]$dockerMachine,
    [string]$username,
	[string]$password,
    [string]$ocRegistry,
	[string]$sourceTag,
    [string]$targetTag
)

$oldVerbose = $VerbosePreference
$VerbosePreference = "Continue"

Write-Verbose 'Entering sshPromotion.ps1'
Write-Verbose "dockerMachine = $dockerMachine"
$usernameEmpty = !$username
Write-Verbose "username empty? $usernameEmpty"
$passwordEmpty = !$password
Write-Verbose "password empty? $passwordEmpty"
Write-Verbose "ocRegistry = $ocRegistry"
Write-Verbose "sourceTag = $sourceTag"
Write-Verbose "targetTag = $targetTag"


# Import the Task.Common dll that has all the cmdlets we need for Build
#import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

if(!$dockerMachine)
{
    throw (Get-LocalizedString -Key "dockerMachine parameter is not set")
}
if(!$username)
{
    throw (Get-LocalizedString -Key "username parameter is not set")
}
if(!$password)
{
    throw (Get-LocalizedString -Key "password parameter is not set")
}
if(!$ocRegistry)
{
    throw (Get-LocalizedString -Key "ocRegistry parameter is not set")
}
if(!$sourceTag)
{
    throw (Get-LocalizedString -Key "sourceTag parameter is not set")
}
if(!$targetTag)
{
    throw (Get-LocalizedString -Key "targetTag parameter is not set")
}

Write-Verbose "Checking plink.exe..."
$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PlinkLocation = $myDir + "\Plink.exe"
If (-not (Test-Path $PlinkLocation)){
   Write-Host "Plink.exe not found, trying to download..."
   $WC = new-object net.webclient
   $WC.DownloadFile("http://the.earth.li/~sgtatham/putty/latest/x86/plink.exe",$PlinkLocation)
   If (-not (Test-Path $PlinkLocation)){
      Write-Host "Unable to download plink.exe, please download from the following URL and add it to the same folder as this script: http://the.earth.li/~sgtatham/putty/latest/x86/plink.exe"
      Exit 100
   } Else {
      $PlinkEXE = Get-ChildItem $PlinkLocation
      If ($PlinkEXE.Length -gt 0) {
         Write-Host "Plink.exe downloaded, continuing script"
      } Else {
         Write-Host "Unable to download plink.exe, please download from the following URL and add it to the same folder as this script: http://the.earth.li/~sgtatham/putty/latest/x86/plink.exe"
         Exit 100
      }
   }  
}
Write-Verbose "Constructing unix command"
$src = "$ocRegistry/$sourceTag"
Write-Verbose "$src"
$tgt = "$ocRegistry/$targetTag"
Write-Verbose "$tgt"
$UnixCmd = '"' + "docker pull $src && docker tag $src $tgt && docker push $tgt" + '"'

Write-Verbose "The command is $UnixCmd"
& $PlinkLocation -ssh $username@$dockerMachine -pw $password $UnixCmd 2>&1

Write-Verbose "Leaving script sshPromotion.ps1"

$VerbosePreference = $oldVerbose
