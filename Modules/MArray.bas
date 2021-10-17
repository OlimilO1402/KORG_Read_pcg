Attribute VB_Name = "MArray"
Option Explicit

#If VBA7 = 0 Then
    Public Enum LongPtr
        [_]
    End Enum
#End If

Private Type SAFEARRAYBOUND
    cElements  As Long
    lLBound    As Long
End Type

Private Type SAFEARRAY1D
    cDims      As Integer  '2
    fFeatures  As Integer  '2 '4
    cbElements As Long     '4 '8
    cLocks     As Long     '4 '12
    pvData     As LongPtr  '4 '16
    cElements  As Long     '4 '20
    lLBound    As Long     '4 '24
                         'Sum: 24
    'Bounds(0 To 0) As SAFEARRAYBOUND
End Type

#If VBA7 Then
    Public Declare PtrSafe Function ArrPtr Lib "msvbvm60" Alias "VarPtr" (ByRef Arr() As Any) As LongPtr
    Public Declare PtrSafe Sub GetMem1 Lib "msvbvm60" (ByRef pSrc As Any, ByRef pDst As Any)
    Public Declare PtrSafe Sub GetMem2 Lib "msvbvm60" (ByRef pSrc As Any, ByRef pDst As Any)
    Public Declare PtrSafe Sub GetMem4 Lib "msvbvm60" (ByRef pSrc As Any, ByRef pDst As Any)
    Public Declare PtrSafe Sub GetMem8 Lib "msvbvm60" (ByRef pSrc As Any, ByRef pDst As Any)
    Public Declare PtrSafe Sub RtlMoveMemory Lib "kernel32" (ByRef Dst As Any, ByRef Src As Any, ByVal BytLength As Long)
    Public Declare PtrSafe Sub RtlZeroMemory Lib "kernel32" (ByRef Dst As Any, ByVal BytLength As Long)
    Public Declare PtrSafe Sub SafeArrayAccessData Lib "oleaut32" (ByVal psa As Any, ByRef ppvData_out As Any)
#Else
    Public Declare Function ArrPtr Lib "msvbvm60" Alias "VarPtr" (ByRef Arr() As Any) As LongPtr
    Public Declare Sub GetMem1 Lib "msvbvm60" (ByRef pSrc As Any, ByRef pDst As Any)
    Public Declare Sub GetMem2 Lib "msvbvm60" (ByRef pSrc As Any, ByRef pDst As Any)
    Public Declare Sub GetMem4 Lib "msvbvm60" (ByRef pSrc As Any, ByRef pDst As Any)
    Public Declare Sub GetMem8 Lib "msvbvm60" (ByRef pSrc As Any, ByRef pDst As Any)
    Public Declare Sub RtlMoveMemory Lib "kernel32" (ByRef Dst As Any, ByRef Src As Any, ByVal BytLength As Long)
    Public Declare Sub RtlZeroMemory Lib "kernel32" (ByRef Dst As Any, ByVal BytLength As Long)
    Public Declare Sub SafeArrayAccessData Lib "oleaut32" (ByVal psa As Any, ByRef ppvData_out As Any)
#End If

' #################### '    Pointer-Tools    ' #################### '

Public Function CLngPtr(v) As LongPtr
    CLngPtr = v
End Function

Public Function FncPtr(ByVal pFnc As LongPtr) As LongPtr
    FncPtr = pFnc
End Function

' #################### '    Array-Pointer-Tools    ' #################### '

Public Function DataPtr(ByVal SAPtr As LongPtr) As LongPtr
    SafeArrayAccessData SAPtr, DataPtr
End Function

Public Function VArrPtr(ByRef vArr As Variant) As LongPtr
    RtlMoveMemory VArrPtr, ByVal VarPtr(vArr) + 8, LenB(VArrPtr)
End Function
'above and below is quite the same
Public Function StrArrPtr(ByRef vArr As Variant) As LongPtr
    RtlMoveMemory StrArrPtr, ByVal VarPtr(vArr) + 8, LenB(StrArrPtr)
End Function

'Public Property Get SAPtr(ByVal pArr As LongPtr) As LongPtr
'Old, do not Use GetMem anymore, just because you have to distinguish between 32Bit(GetMem4) and 64Bit(GetMem8)
'    GetMem4 ByVal pArr, SAPtr
'End Property

Public Property Get SAPtr(ByVal pArr As LongPtr) As LongPtr
    RtlMoveMemory SAPtr, ByVal pArr, LenB(pArr)
End Property
Public Property Let SAPtr(ByVal pArr As LongPtr, ByVal RHS As LongPtr)
    RtlMoveMemory ByVal pArr, RHS, LenB(pArr)
End Property

Public Sub ZeroSAPtr(ByVal pArr As LongPtr)
    RtlZeroMemory ByVal pArr, LenB(pArr)
End Sub

Public Function UboundDim(Arr) As Long
    'not for array of ud-type
Try: On Error GoTo Catch
    UboundDim = UBound(Arr)
    Exit Function
Catch:
    UboundDim = -1
End Function

Public Function SafeUbound(ByVal pArr As LongPtr) As Long
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

Public Function Length(ByVal pArr As LongPtr) As Long
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

