Attribute VB_Name = "MFileInfo"
Option Explicit

Public Function FileExists(aFileName As String) As Boolean
Try: On Error GoTo Catch
    'Debug.Print aFileName
    FileExists = ((GetAttr(aFileName) And (vbDirectory Or vbVolume)) = 0)
Catch:
    'hier keine Fehlerbehandlung sondern einfach raus
End Function
Public Function DirExists(aDirectory As String) As Boolean
Try: On Error GoTo Catch
    ' Wenn ein Fehler aufgetreten ist, dann ist DirExists auf jeden Fall
    ' False, sonst ist es nur True, wenn auch das Directory-Attribut beim
    ' existierenden Objekt vorhanden ist.
    DirExists = ((GetAttr(aDirectory) And vbDirectory))
Catch:
    'hier keine Fehlerbehandlung sondern einfach raus
End Function
Public Function GetPath(aPathFileName As String) As String
    If Len(aPathFileName) Then
        Dim p As Long: p = InStrRev(aPathFileName, "\")
        If p > 0 Then GetPath = Left$(aPathFileName, p)
    End If
End Function
Public Function WithOutExtension(aPathFileName As String) As String
    If Len(aPathFileName) Then
        Dim p As Long: p = InStrRev(aPathFileName, ".")
        If p > 0 Then WithOutExtension = Left$(aPathFileName, p - 1)
    End If
End Function
Public Function ChangeExt(FNm As String, ext As String) As String
    Dim ppos As Long: ppos = InStrRev(FNm, ".")
    If ppos > 0 Then ChangeExt = Left$(FNm, ppos)
    ChangeExt = ChangeExt & ext
End Function

