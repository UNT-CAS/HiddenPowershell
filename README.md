This vbscript will run powershell.exe hidden; since [`-WindowStyle Hidden` isn't sufficient](https://github.com/PowerShell/PowerShell/issues/3028).
Hopefully we'll have [a `pwshw.exe` soon](https://github.com/PowerShell/PowerShell/issues/3028#issuecomment-367169480) and this repo can be antiquated.

You're probably here because you've already realized that using [PowerShell's `-WindowStyle Hidden` parameter](https://docs.microsoft.com/en-us/powershell/scripting/core-powershell/console/powershell.exe-command-line-help#parameters) without this script, doesn't completely hide the powershell console.

# Usage

**Do not use `cscript.exe`; it will cause a console window to appear.**

```
wscript.exe HiddentPowershell.vbs -ExecutionPolicy ByPass -File "C:\Program Files\Get-HelloWorld.ps1"
```

This Will run Powershell in a completely hidden console by calling PowerShell like this:
```
powershell.exe -ExecutionPolicy ByPass -File "C:\Program Files\Get-HelloWorld.ps1"
```

I recommend that you also pass the `-WindowStyle Hidden` parameter, so that the executing powershell script knows that it's hidden.
You may also want to include the `-NonInteractive` parameter for the same reason.

If you have machines that have Windows Scripting Host (WSH) file extensions (like `.vbs`) disassociated from WSH; then you will need to add the `//E:vbscript` parameter:
```
wscript.exe //E:vbscript HiddentPowershell.vbs ...
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
If powershell exits with a non-zero exit code, the *Event ID* will be `1` (error).

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
