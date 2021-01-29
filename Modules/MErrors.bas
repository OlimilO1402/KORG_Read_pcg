Attribute VB_Name = "MErrors"
Option Explicit

Public Function GlobalErrhandler(clsnam As String, procNam As String, Optional msgstyle As VbMsgBoxStyle = vbOKOnly) As VbMsgBoxResult
    GlobalErrhandler = MsgBox(clsnam & "::" & procNam & vbCrLf & Err.Description, msgstyle Or vbCritical)
End Function
