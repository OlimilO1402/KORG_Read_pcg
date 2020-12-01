Attribute VB_Name = "MArray"
Option Explicit
Private Type SAFEARRAYBOUND
    cElements  As Long
    lLBound    As Long
End Type

Private Type SAFEARRAY1D
    cDims      As Integer  '2
    fFeatures  As Integer  '2 '4
    cbElements As Long     '4 '8
    cLocks     As Long     '4 '12
    pvData     As Long     '4 '16
    cElements  As Long     '4 '20
    lLBound    As Long     '4 '24
                         'Sum: 24
    'Bounds(0 To 0) As SAFEARRAYBOUND
End Type

Public Declare Function ArrPtr Lib "msvbvm60" Alias "VarPtr" (ByRef arr() As Any) As Long
Public Declare Sub GetMem1 Lib "msvbvm60" (ByRef pSrc As Any, ByRef pDst As Any)
Public Declare Sub GetMem2 Lib "msvbvm60" (ByRef pSrc As Any, ByRef pDst As Any)
Public Declare Sub GetMem4 Lib "msvbvm60" (ByRef pSrc As Any, ByRef pDst As Any)
Public Declare Sub GetMem8 Lib "msvbvm60" (ByRef pSrc As Any, ByRef pDst As Any)
Public Declare Sub RtlMoveMemory Lib "kernel32" (ByRef pDst As Any, ByRef pSrc As Any, ByVal bLength As Long)

' #################### '    Array-tools    ' #################### '
Public Property Get SAPtr(ByVal pArr As Long) As Long
    Call GetMem4(ByVal pArr, SAPtr)
End Property
Public Function UboundDim(arr As Variant) As Long
    'not for array of ud-type
Try: On Error GoTo Catch
    UboundDim = UBound(arr)
    Exit Function
Catch:
    UboundDim = -1
End Function

Public Function SafeUbound(ByVal pArr As Long) As Long
    'for every array
    'usage: UboundArr(ArrPtr(myarr))
    If pArr = 0 Then
        SafeUbound = -1
    Else
        'UboundArr = UBound(arr)
        Dim sa As Long: sa = SAPtr(pArr)
        If sa = 0 Then
            SafeUbound = -1
        Else
            Call GetMem4(ByVal sa + 16, SafeUbound)
            If SafeUbound > 0 Then SafeUbound = SafeUbound - 1
        End If
    End If
End Function

Public Function Length(ByVal pArr As Long) As Long
    'for every array
    'usage: UboundArr(ArrPtr(myarr))
    If pArr = 0 Then
        Length = -1
    Else
        'UboundArr = UBound(arr)
        Dim sa As Long: sa = SAPtr(pArr)
        If sa <> 0 Then
            Call GetMem4(ByVal sa + 16, Length)
        End If
    End If
End Function

