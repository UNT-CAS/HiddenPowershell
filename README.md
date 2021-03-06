This VBScript will run powershell.exe hidden; since [`-WindowStyle Hidden` isn't sufficient](https://github.com/PowerShell/PowerShell/issues/3028).
Hopefully, we'll have [a `pwshw.exe` soon](https://github.com/PowerShell/PowerShell/issues/3028#issuecomment-367169480) and this repo can be antiquated.

You're probably here because you've already realized that using [PowerShell's `-WindowStyle Hidden` parameter](https://docs.microsoft.com/en-us/powershell/scripting/core-powershell/console/powershell.exe-command-line-help#parameters) without this script, doesn't completely hide the PowerShell console.

**If you're wanting to run something other than PowerShell hidden, try [HiddenRun](https://github.com/UNT-CAS/HiddenRun).**

# Usage

## Download HiddenPowershell.vbs

I suggest grabbing it at boot with a **startup script**, via GPO.
Users won't see the PowerShell console of a startup script, so it's not invasive.
Be sure to adjust the `$path` and keep the *Script Parameters* length under 520 characters; the max in GPO:

> powershell.exe -ExecutionPolicy Bypass -NoProfile -NonInteractive -WindowStyle Hidden -Command "$path = 'C:\Temp'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/UNT-CAS/HiddenPowershell/v1.0/HiddenPowershell.vbs' -OutFile ('{0}\HiddenPowershell.vbs' -f $path) -UseBasicParsing"

:bangbang: Wherever you put it, be sure *users* can read, but not write to it.

Be sure you check for the latest release.
I don't expect a lot of changes to this script, but now that it's open source ... who knows?

I know this seems simple, but practical implementation is usually a bit more complex.
[Here's how I've made it happen](http://blog.vertigion.com/2018/05/24/gpo-startup-script-practical-download/?utm_source=github&utm_medium=unt-cas&utm_campaign=hiddenpowershell).

## Execute Powershell

**Do not use `cscript.exe`; it will cause a console window to appear.**

```batch
wscript.exe HiddenPowershell.vbs -ExecutionPolicy ByPass -File "C:\Program Files\Get-HelloWorld.ps1"
```

This Will run Powershell in a completely hidden console by calling PowerShell like this:
```batch
powershell.exe -ExecutionPolicy ByPass -File "C:\Program Files\Get-HelloWorld.ps1"
```

I recommend that you also pass the `-WindowStyle Hidden` parameter so that the executing PowerShell script knows that it's hidden.
You may also want to include the `-NonInteractive` parameter for the same reason.

If you have machines that have Windows Scripting Host (WSH) file extensions (like `.vbs`) disassociated from WSH; then you will need to add the `//E:vbscript` parameter:

```batch
wscript.exe //E:vbscript HiddenPowershell.vbs ...
```

# Examples

## Run File

```batch
wscript.exe HiddenPowershell.vbs -ExecutionPolicy ByPass -File "C:\Program Files\Get-HelloWorld.ps1"
```

## Run URL

```batch
wscript.exe HiddenPowershell.vbs -ExecutionPolicy ByPass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequst -Uri 'https://raw.githubusercontent.com/Project/Repo/master/deploy.ps1' -UseBasicParsing | Invoke-Expression"
```

# Logging

Logging is done to *Event Viewer*.
There will be two events for every run of the script. One at the start of the run, and the other at the completion/finish.
The details of the logs are:

- **Event Path:** `Windows Logs\Application`
- **Source:** `WSH`
- **Event ID:** *Depends on Status*
  - *Success*: `0` Script Finished; Powershell Exited with `0`.
  - *Error*: `1` Script Finished; Powershell Exited with something other than `0`.
  - *Information*: `4` Script Starting

## Start

The *Event ID* of the *starting* message will always be `4` (informational).
Here's an example of what that will look like:

```
HiddenPowershell Running: 
	C:\Temp\HiddenPowershell.vbs
	powershell.exe -WindowStyle Hidden -ExecutionPolicy ByPass -Command Write-Host "Hello World!"
```

##  Finish

The *Event ID* of the *finished* message will be `0` (success).
If PowerShell exits with a non-zero exit code, the *Event ID* will be `1` (error).

Here's an example of what a *success* looks like; *Event ID* is `0`:
```
HiddenPowershell Exited: 
	C:\Temp\HiddenPowershell.vbs
	powershell.exe -WindowStyle Hidden -ExecutionPolicy ByPass -Command Write-Host "Hello World!"
	Exit Code: 0
```

Here's an example of what an *error* looks like; *Event ID* is `1`:
```
HiddenPowershell Exited: 
	C:\Temp\HiddenPowershell.vbs
	powershell.exe -WindowStyle Hidden -ExecutionPolicy ByPass -File ScriptDoesNotExist.ps1
	Exit Code: -196608
```
