Attribute VB_Name = "MKMPFile"
Option Explicit
Public Enum Use2ndStart
    DoNot = 1
    UseIt = 0
End Enum
Public Type MSP1Chunk
    Header         As ChunkHeader
    NName(0 To 15) As Byte
    NumOfSamples   As Byte
    Attributes     As Byte ' = Use2ndStart
End Type
Public Type MNO1Chunk
    Header    As ChunkHeader
    Reserved1 As Byte
    Reserved2 As Byte
    Reserved3 As Byte
    Reserved4 As Byte
End Type
Public Type MultiSampleRelativeParam
    OriginalKey  As Byte
    TopKey       As Byte 'Top key (0-127)
    Tune         As Byte 'Tune (-99..+99 cents)
    Level        As Byte 'Level (-99..+99 cents)
    Pan          As Byte 'Pan (0..127) currently unused)
    FilterCutoff As Byte 'Filter cutoff (ñ50...0 currently unused)
    KSFName(0 To 11) As Byte
End Type
Public Type RLP1Chunk
    Header As ChunkHeader
    data() As MultiSampleRelativeParam
End Type
Public Type RLP2Chunk
    RLP2Head As ChunkHeader
    data() As Byte '???
End Type
Public Type KMPFile
    FileName As String
    MSPProps       As MSP1Chunk
    MNO1Head       As MNO1Chunk
    RelativeParams As RLP1Chunk
    RLP2Data       As RLP2Chunk
End Type
Public Enum KMPID
    MSP1 = &H3150534D '  'MSP1'
    MNO1 = &H314F4E4D '  'MNO1'
    RLP1 = &H31504C52 '  'RLP1'
    RLP2 = &H32504C52 '  'RLP2'
End Enum

Public Sub LoadKMPFile(this As KMPFile, aFilename As String)
Try: On Error GoTo Catch
    Dim FNr As Integer: FNr = FreeFile
    Open aFilename For Binary Access Read As FNr
    'Debug.Print aFileName
    With this
        .FileName = aFilename
        Dim aChunk As ChunkHeader
        Do While Not EOF(FNr)
            Call ReadChunkHeader(aChunk, FNr)
            Dim ID As KMPID: ID = ChunkIDToLong(aChunk.ChunkID)
            Select Case ID 'ChunkIDToLong(aChunk.ChunkID) 'True
            Case KMPID.MSP1: .MSPProps.Header = aChunk
                             Call ReadMSP1Chunk(.MSPProps, FNr)
            Case KMPID.MNO1: .MNO1Head.Header = aChunk
                             Call ReadMNO1Chunk(.MNO1Head, FNr)
            Case KMPID.RLP1: .RelativeParams.Header = aChunk
                Call ReadMultiSampleRelativeParam(.RelativeParams.data, .MSPProps.NumOfSamples, FNr)
            Case KMPID.RLP2: .RLP2Data.RLP2Head = aChunk
                Call ReadRLP2Data(.RLP2Data, FNr)
            End Select
        Loop 'while not EOF
    End With
Finally:
    Close FNr
    Exit Sub
Catch:
    Call ErrHandler("LoadKMPFile")
    GoTo Finally
End Sub
Public Sub ReadMSP1Chunk(this As MSP1Chunk, FNr As Integer)
Try: On Error GoTo Catch
    With this
        Get FNr, , .NName
        Get FNr, , .NumOfSamples
        Get FNr, , .Attributes
    End With
    Exit Sub
Catch:
    Call ErrHandler("ReadMSP1Chunk")
End Sub
Public Sub ReadMNO1Chunk(this As MNO1Chunk, FNr As Integer)
Try: On Error GoTo Catch
    With this
        Get FNr, , .Reserved1
        Get FNr, , .Reserved2
        Get FNr, , .Reserved3
        Get FNr, , .Reserved4
    End With
    Exit Sub
Catch:
    Call ErrHandler("ReadMNO1Chunk")
End Sub
Public Sub ReadMultiSampleRelativeParam(data() As MultiSampleRelativeParam, ByVal count As Integer, FNr As Integer)
Try: On Error GoTo Catch
    ReDim data(0 To count - 1)
    Dim i As Integer
    For i = 0 To count - 1
        With data(i)
            Get FNr, , .OriginalKey
            Get FNr, , .TopKey
            Get FNr, , .Tune
            Get FNr, , .Level
            Get FNr, , .Pan
            Get FNr, , .FilterCutoff
            Get FNr, , .KSFName
        End With
    Next
    Exit Sub
Catch:
    Call ErrHandler("ReadMultiSampleRelativeParam")
End Sub
Public Sub ReadRLP2Data(this As RLP2Chunk, FNr As Integer)
Try: On Error GoTo Catch
    With this
        ReDim .data(0 To .RLP2Head.ChunkSize)
        Get FNr, , .data
    End With
    Exit Sub
Catch:
    Call ErrHandler("ReadRLP2Data")
End Sub
Public Sub LoadAllKSFFiles(this() As KMPFile, aKorgDoc As KorgDocument)
    Dim i As Long, j As Long
    Dim KSF As KorgSampleFile
    Dim Path As String, FNam As String, PFN As String
Try: On Error GoTo Catch
    For i = 0 To SafeUbound(ArrPtr(this))
        With this(i)
            'wo liegen die KSF-Dateien?
            'in einem Unterverzeichnis das genauso heiﬂt wie der Dateiname ohne Extension
            Path = WithOutExtension(.FileName) & "\"  'Left$(.FileName, Len(.FileName) - 4) & "\"
            If Not DirExists(Path) Then
                'nein dann vielleicht im gleichen Verzeichnis wie die Datei
                Path = GetPath(.FileName)
            End If
            With .RelativeParams
                For j = 0 To SafeUbound(ArrPtr(.data))
                    With .data(j)
                        FNam = BytarrToString(.KSFName)
                        'Debug.Print FNam
                        If UCase(FNam) <> "SKIPPEDSAMPL" Then
                            PFN = Path & FNam
                            If FileExists(PFN) Then
                               aKorgDoc.AddKorgSampleFile MNew.KorgSampleFile(aKorgDoc, PFN, i, j)
                                'Call KSF.Load(PFN)
                                'col.Add KSF, UCase(FNam)
                            Else
                                MsgBox "File not found: " & PFN
                            End If
                        End If
                    End With
                Next
            End With
        End With
    Next
    Exit Sub
Catch:
    Call ErrHandler("LoadAllKSFFiles")
End Sub

' #################### '    ToString    ' #################### '
Public Function KMPFileToString(this As KMPFile) As String
    Dim s As String
    With this
        s = s & HeadlineToString("KMP-File:", .FileName) & vbCrLf
        s = s & MSP1ChunkToString(.MSPProps) & vbCrLf
        s = s & MNO1ChunkToString(.MNO1Head) & vbCrLf
        s = s & RelativeParamsToString(.RelativeParams) & vbCrLf
    End With
    KMPFileToString = s
End Function
Public Function MSP1ChunkToString(this As MSP1Chunk) As String
    Dim s As String
    With this
        s = s & ChunkHeaderToString(.Header) & vbCrLf
        s = s & "Name:         " & BytarrToString(.NName) & vbCrLf
        s = s & "NumOfSamples: " & CStr(.NumOfSamples) & vbCrLf
        s = s & "Attributes:   " & Use2ndStartToString(.Attributes) & vbCrLf
    End With
    MSP1ChunkToString = s
End Function
Public Function Use2ndStartToString(b As Byte) As String
    Dim s As String
    Dim u As Use2ndStart: u = b
    Select Case u
    Case DoNot: s = "Do not use 2nd start"
    Case UseIt: s = "Yes use 2nd start"
    End Select
    Use2ndStartToString = s
End Function
Public Function MNO1ChunkToString(this As MNO1Chunk) As String
    Dim s As String
    With this
        s = s & ChunkHeaderToString(.Header) '& vbCrLf
        s = s & "Reserved1-4: " & "x" & ByteToHex(.Reserved1) & ByteToHex(.Reserved2) _
                                      & ByteToHex(.Reserved3) & Hex$(.Reserved4) & vbCrLf
    End With
    MNO1ChunkToString = s
End Function
Public Function ByteToHex(b As Byte) As String
    ByteToHex = Hex$(b): If Len(ByteToHex) = 1 Then ByteToHex = "0" & ByteToHex
End Function
Public Function RelativeParamsToString(this As RLP1Chunk) As String
    Dim s As String
    With this
        s = s & ChunkHeaderToString(.Header) & vbCrLf
        Dim i As Integer
        For i = 0 To SafeUbound(ArrPtr(.data))
            s = s & MultiSampleRelativeParamToString(.data(i))
        Next
    End With
    RelativeParamsToString = s
End Function
Public Function MultiSampleRelativeParamToString(this As MultiSampleRelativeParam) As String
    Dim s As String
    With this
        s = s & "OriginalKey:  " & CStr(.OriginalKey) & " = " & MidiKeyToString(.OriginalKey) & vbCrLf
        s = s & "TopKey:       " & CStr(.TopKey) & " = " & MidiKeyToString(.TopKey) & vbCrLf
        s = s & "Tune:         " & CStr(.Tune) & vbCrLf
        s = s & "Level:        " & CStr(.Level) & vbCrLf
        s = s & "Pan:          " & CStr(.Pan) & vbCrLf
        s = s & "FilterCutoff: " & CStr(.FilterCutoff) & vbCrLf
        s = s & "KSF-filename: " & BytarrToString(.KSFName) & vbCrLf
    End With
    MultiSampleRelativeParamToString = s
End Function

' #################### '    ErrHandler    ' #################### '
Private Function ErrHandler(fncnam As String, Optional msgstyle As VbMsgBoxStyle) As VbMsgBoxResult
    ErrHandler = GlobalErrhandler("KMPFile", fncnam, msgstyle)
End Function

