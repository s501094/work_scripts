##################################################################################################
##################################################################################################
##																								##
##					Developer: Ty Ellis															##
##					Name: Old_Java_Removal_script												##
##					Version: 1.0																##
##					Written in: Powershell														##
##					Version: 5.1																##
##					Function: Removes Java 7 and Below.											##
##							: Default Uninstall and never reboot								##
##							  (Tool uses .exe for Execution)									##
##							: detects and removes old java versions								##
##							  (i.e. Java versions without Update								##
##																								##
##					Notes: Please do not use if you are not sure								##
##							What you are doing. 												##
##																								##
##																								##
##																								##
##																								##
##																								##
##################################################################################################
##################################################################################################
##																								##
##																								##
##	Define Variables: 																			##
##						$TDL = Temp DOwnload Loaction											##
##						$app = Java Applicaiton													##
##																								##
##																								##
##																								##
##################################################################################################
##################################################################################################

$7andBelow = $true
$TDL = "C:\Users\syshelp\AppData\Local\Temp\updates"

# Versions
$32bitJava = @()
$64bitJava = @()
$32bitVersions = @()
$64bitVersions = @()

# WMI query

if($7andBelow)
{
	$32bitJava += Get-WmiObject -Class Win32_Product | Where-Object {
		
		$_.Name -match "(?i)Java(\(TM\))*\s\d+(\sUpdate\s\d+)*$"
		
	}
	# find Java version 5 by GUID
	
	$32bitJava += Get-WmiObject -Class Win32_Product | Where-Object {
		
		($_.Name -match "(?i)J2SE\sRuntime\sEnvironment\s\d[.]\d(\sUpdate\s\d+)*$") -and ($_.IdentifyingNumber -match "^\{32")
	}
}
else
{
	$32bitJava += Get-WmiObject -Class Win32_Product | Where-Object {
		
		$_.Name -match "(?i)Java((\(TM\) 7)|(\s\d+))(\sUpdate\s\d+)*$"
	}
}

# 2nd WMI query for J-Updates 

if($7andBelow)
{
	
	$64bitJava += Get-WmiObject -Class Win32_Product | Where-Object {
		
		$_.Name -match "(?i)Java(\(TM\))*\s\d+(\sUpdate\s\d+)*\s[(]64-bit[)]$"
	}
	
	# v-5, cpu - by GUID
	
	$64bitJava += Get-WmiObject -Class Win32_Product | Where-Object {
		
		($_.Name -match "(?i)J2SE\sRuntime\sEnvironment\s\d[.]\d(\sUpdate\s\d+)*$") -and ($_.IdentifyingNumber -match "*\{64")
		
	}
}

else
{
	$64bitJava += Get-WmiObject -Class Win32_Product | Where-Object {
		
		$_.Name -match "(?i)Java((\(TM\) 7)|(\s\d+))(\sUpdate\s\d+)*\s[(]64-bit[)]$"
		
	}
}

# compare version

if(!(Test-path -Path $TDL))
{
	# create D if no Directory found
	
	New-Item -Path $TDL -Force -ItemType Directory -ErrorVariable $CDR
	
	if ($CDR)
	
	{
		write-host "Failed to create temp dir $TDL exiting script" -ForegroundColor Red
		
		write-host "Error: $CDR" -ForegroundColor Red
		
		exit
	}
}



# View 32 bit Versions

Foreach ($app in $32bitJava)
{
	if ($app -ne $null) { $32bitVersions += $app.Version }
}

# view 64bit versions

Foreach($app in $64bitJava)

{
	
	if($app -ne $null){$64bitVersions += $app.Version}
}


# sort by V

$sorted32bitVersions = $32bitVersions|%{ New-Object System.Version($_)}|sort

$sorted64bitVersions = $64bitVersions|%{ New-Object System.Version($_)}|sort

# 

if($sorted32bitVersions -isnot [system.array]){$sorted32bitVersions = @($sorted32bitVersions)}

if($sorted64bitVersions -isnot [system.array]){ $sorted64bitVersions = @($sorted64bitVersions)}

# newest ver 

$newest32bitVersion = $sorted32bitVersions[$sorted32bitVersions.GetUpperBound(0)]

$newest64bitVersion = $sorted64bitVersions[$sorted64bitVersions.GetUpperBound(0)]

Foreach($app in $32bitJava)
{
	if ($app -ne $null)
# clear old		
	{
		if(($app.Version -ne $newest32bitVersion) -and ($newest32bitVersion -ne $null))
		{
			$appGUID = $app.Properties["IdentifyingNumber"].Value.ToString()
			Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /norestart /x $($appGUID)" -Wait -Passthru
		}
	}
}

Foreach($app in $64bitJava)
{
	if($app -ne $null)
# clear old
	{
		if (($app.Version -ne $newest64bitVersion) -and ($newest64bitVersion -ne $null))
		{
			$appGUID = $app.Properties["IdentifyingNumber"].Value.ToString()
			
			Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn /norestart /x $($appGUID)" -Wait -Passthru
		}
	}
}

