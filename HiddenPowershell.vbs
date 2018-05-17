' Usage:
'   wscript.exe //E:vbscript HiddentPowershell.vbs -ExecutionPolicy ByPass -File "C:\Program Files\Get-HelloWorld.ps1"
'
' Will run Powershell in a hidden console, like this:
'   powershell.exe -ExecutionPolicy ByPass -File "C:\Program Files\Get-HelloWorld.ps1"
'
' More Info: https://github.com/UNT-CAS/HiddenPowershell

Set oShell = CreateObject("Wscript.Shell")

Const LOG_EVENT_SUCCESS = 0
Const LOG_EVENT_ERROR = 1
Const LOG_EVENT_INFORMATION = 4

Dim iExitStatus : iExitStatus = LOG_EVENT_SUCCESS
Dim sArgs : sArgs = "powershell.exe"
Dim sMessage : sMessage = ""

For Each sArg in Wscript.Arguments
    If InStr(sArg, " ") > 0 Then
        ' If there's a space in the argument, wrap it in quotes.
        sArgs = sArgs & " """ & sArg & """"
    Else
        sArgs = sArgs & " " & sArg
    End If
Next

sMessage = "HiddenPowershell Running: " _
            & vbCrLf & vbTab & Wscript.ScriptFullName _
            & vbCrLf & vbTab & sArgs
oShell.LogEvent LOG_EVENT_INFORMATION, sMessage

iReturn = oShell.Run(sArgs, 0, True)

If iReturn <> 0 Then    
    iExitStatus = LOG_EVENT_ERROR
End If

sMessage = "HiddenPowershell Exited: " _
            & vbCrLf & vbTab & Wscript.ScriptFullName _
            & vbCrLf & vbTab & sArgs _
            & vbCrLf & vbTab & "Exit Code: " & iReturn
oShell.LogEvent iExitStatus, sMessage

Wscript.Quit iReturn
