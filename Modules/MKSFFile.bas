Attribute VB_Name = "MKSFFile"
Option Explicit
Public Type SampleParamChunk
    Header As ChunkHeader           'SMP1'
    SampleName(0 To 15)   As Byte
    DefaultBankID         As Byte
    StartAddress1(0 To 2) As Byte
    StartAddress2         As Long
    LoopStartAddress      As Long
    LoopEndAdress         As Long
End Type
Public Type SampleNumberChunk
    Header As ChunkHeader           'SNO1'
    Number As Long                  'x28 = d40 ?
End Type
Public Type SampleDataChunk
    Header       As ChunkHeader     'SMD1'
    SampleRate   As Long
    Attributes   As Byte
                         'Sample parameter attributes
                         'LSB
                         'Bit 0 - 3: CompressionID
                         'Bit 4:    1=compressed data; 0=uncompressed data
                         'Bit 5:    1=Not Use 2nd Start; 0=Use It
                         'MSB
                         'Bit 6 - 7: NC (0)
    LoopTune     As Byte
    NumOfChnls   As Byte
    SampleSize   As Byte
    NumOfSamples As Long
    SampleData() As Byte
End Type
Public Type SampleFileNameChunk
    Header As ChunkHeader           'SMF1'
    KSFFileName(0 To 11) As Byte
End Type
Public Type KSFFile
    FileName  As String
    SampleParam  As SampleParamChunk
    SampleNumber As SampleNumberChunk
    SampleData   As SampleDataChunk
    SampleFile   As SampleFileNameChunk
End Type
Public Enum KSFID
    SMP1 = &H31504D53 '  'SMP1'
    SNO1 = &H314F4E53 '  'SNO1'
    SMD1 = &H31444D53 '  'SMD1'
    SMF1 = &H31464D53 '  'SMF1'
End Enum

Public Sub Load(this As KSFFile, aFilename As String)
Try: On Error GoTo Catch
    Dim FNr As Integer: FNr = FreeFile
    Dim sLin As String
    Dim ext As String
    With this
        .FileName = aFilename
        Open .FileName For Binary Access Read As FNr
        Dim aChunk As ChunkHeader
        Do While Not EOF(FNr)
            Call ReadChunkHeader(aChunk, FNr)
            Dim ID As KSFID: ID = ChunkIDToLong(aChunk.ChunkID)
            Select Case ID 'ChunkIDToLong(aChunk.ChunkID)
            Case SMP1: .SampleParam.Header = aChunk
                Call ReadSampleParamChunk(.SampleParam, FNr)
            Case SNO1: .SampleNumber.Header = aChunk
                Call ReadSampleNumberChunk(.SampleNumber, FNr)
            Case SMD1: .SampleData.Header = aChunk
                Call ReadSampleDataChunk(.SampleData, FNr)
            Case SMF1: .SampleFile.Header = aChunk
                Call ReadSampleFileNameChunk(.SampleFile, FNr)
            End Select
        Loop
    End With
Finally:
    Close FNr
    Exit Sub
Catch:
    Call ErrHandler("Load")
    GoTo Finally
End Sub

' #################### '      Read      ' #################### '
Public Sub ReadSampleParamChunk(this As SampleParamChunk, FNr As Integer)
Try: On Error GoTo Catch
    With this
        Get FNr, , .SampleName
        Get FNr, , .DefaultBankID
        Get FNr, , .StartAddress1 '(0 To 2) as Byte
        'Get FNr, , .StartAddress1(0)
        'Get FNr, , .StartAddress1(1)
        'Get FNr, , .StartAddress1(2)
        Get FNr, , .StartAddress2:    Call Rotate4(.StartAddress2)
        Get FNr, , .LoopStartAddress: Call Rotate4(.LoopStartAddress)
        Get FNr, , .LoopEndAdress:    Call Rotate4(.LoopEndAdress)
    End With
    Exit Sub
Catch:
    Call ErrHandler("ReadSampleParamChunk")
End Sub
Public Sub ReadSampleNumberChunk(this As SampleNumberChunk, FNr As Integer)
Try: On Error GoTo Catch
    With this
        Get FNr, , .Number: Call Rotate4(.Number)
    End With
    Exit Sub
Catch:
    Call ErrHandler("ReadSampleNumberChunk")
End Sub
Public Sub ReadSampleDataChunk(this As SampleDataChunk, FNr As Integer)
Try: On Error GoTo Catch
    With this
        Get FNr, , .SampleRate: Call Rotate4(.SampleRate)
        Get FNr, , .Attributes
        Get FNr, , .LoopTune
        Get FNr, , .NumOfChnls
        Get FNr, , .SampleSize
        Get FNr, , .NumOfSamples: Call Rotate4(.NumOfSamples)
        If .NumOfSamples > 0 Then
            Dim u As Long: u = .NumOfChnls * .SampleSize / 8 * .NumOfSamples - 1
            ReDim .SampleData(0 To u)
            Get FNr, , .SampleData
        End If
    End With
    Exit Sub
Catch:
    Call ErrHandler("ReadSampleDataChunk")
End Sub
Public Sub ReadSampleFileNameChunk(this As SampleFileNameChunk, FNr As Integer)
Try: On Error GoTo Catch
    With this
        Get FNr, , .KSFFileName
    End With
    Exit Sub
Catch:
    Call ErrHandler("ReadSampleFileNameChunk")
End Sub
Private Function Rotate3Byte(b() As Byte) As Long
    Dim bTmp(0 To 3) As Byte
    bTmp(0) = b(2)
    'b(1) = b(1)
    b(2) = b(0)
    Call GetMem4(bTmp(0), Rotate3Byte)
End Function

' #################### '    ToString    ' #################### '
Public Function KSFFileTostring(this As KSFFile) As String
    Dim s As String
    With this
        s = s & "KSF-File" & vbCrLf & _
                "========" & vbCrLf
        s = s & "FileName:    " & .FileName & vbCrLf
        s = s & SampleParamChunkToString(.SampleParam) & vbCrLf
        s = s & SampleNumberChunkToString(.SampleNumber) & vbCrLf
        s = s & SampleDataChunkToString(.SampleData) & vbCrLf
        s = s & SampleFileNameChunkToString(.SampleFile) & vbCrLf
    End With
    KSFFileTostring = s
End Function
Public Function SampleParamChunkToString(this As SampleParamChunk) As String
    Dim s As String
    With this
        s = s & ChunkHeaderToString(.Header)
        s = s & "SampleName:    " & """" & BytarrToString(.SampleName) & """" & vbCrLf
        s = s & "DefaultBankID: " & CStr(.DefaultBankID) & vbCrLf
        s = s & "StartAddress1: " & CStr(Rotate3Byte(.StartAddress1)) & vbCrLf
        s = s & "StartAddress2: " & CStr(.StartAddress2) & vbCrLf
        s = s & "LoopStartAddr: " & CStr(.LoopStartAddress) & vbCrLf
        s = s & "LoopEndAddr:   " & CStr(.LoopEndAdress) & vbCrLf
    End With
    SampleParamChunkToString = s
End Function
Public Function SampleNumberChunkToString(this As SampleNumberChunk) As String
    Dim s As String
    With this
        s = s & ChunkHeaderToString(.Header)
        s = s & "Number:    " & CStr(.Number) & vbCrLf
    End With
    SampleNumberChunkToString = s
End Function
Public Function SampleDataChunkToString(this As SampleDataChunk) As String
    Dim s As String
    With this
        s = s & ChunkHeaderToString(.Header)
        s = s & "SampleRate:   " & CStr(.SampleRate) & vbCrLf
        s = s & "Attributes:   " & AttributesToString(.Attributes) & vbCrLf
        s = s & "LoopTune:     " & CStr(.LoopTune) & vbCrLf
        s = s & "NumOfChnls:   " & CStr(.NumOfChnls) & vbCrLf
        s = s & "SampleSize:   " & CStr(.SampleSize) & vbCrLf
        s = s & "NumOfSamples: " & CStr(.NumOfSamples) & vbCrLf
    End With
    SampleDataChunkToString = s
End Function
Public Function AttributesToString(ByVal attr As Byte) As String
    Dim s As String
    s = s & "CompressionID:   " & "0x" & Hex$(CompressionID(attr))
    s = s & "; IsComressedData: " & CStr(IsCompressedData(attr)) & "; "
    s = s & Use2ndStartToString(Use2ndStart(attr)) & "; "
    AttributesToString = s
End Function
Public Function SampleFileNameChunkToString(this As SampleFileNameChunk) As String
    Dim s As String
    Dim FNam As String
    With this
        FNam = BytarrToString(.KSFFileName)
        If Len(FNam) > 0 Then
            s = s & ChunkHeaderToString(.Header)
            s = s & "KSFFileName: " & FNam & vbCrLf
        End If
    End With
    SampleFileNameChunkToString = s
End Function

' #################### '   Properties   ' #################### '
Public Property Get CompressionID(ByVal attr As Byte) As Byte
    CompressionID = CompressionID Or (attr And &H1)
    CompressionID = CompressionID Or (attr And &H2)
    CompressionID = CompressionID Or (attr And &H4)
    CompressionID = CompressionID Or (attr And &H8)
End Property
Public Property Get IsCompressedData(ByVal attr As Byte) As Boolean
    IsCompressedData = (attr And &H10) = &H10
End Property
Public Property Get Use2ndStart(ByVal attr As Byte) As Use2ndStart
    ' 1=Not Use 2nd Start; 0=Use It
    Use2ndStart = Abs((attr And &H20) = &H20)
End Property
'Bit 6 & 7: NC(0) ???

' #################### '    ErrHandler    ' #################### '
Private Function ErrHandler(fncnam As String, Optional msgstyle As VbMsgBoxStyle) As VbMsgBoxResult
    ErrHandler = GlobalErrhandler("KSFFile", fncnam, msgstyle)
End Function

