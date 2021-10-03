VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "WaveSound"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
Private m_FileName As String
Private m_Wave As TWaveSound
'Private m_Buffer() As Byte

Private Sub Class_Initialize()
    With m_Wave
        .RIFF = New_ChunkHeader(WAVEid.RIFF, 0)
        With .data
            .Header = New_ChunkHeader(WAVEid.data, 0)
            'ReDim .data(0)
        End With
    End With
End Sub
Friend Sub New_(wavformat As WaveFormat)
    m_Wave.WAVEfmt = New_WaveFormatChunk(wavformat)
End Sub

Friend Property Get WaveFormat() As WaveFormat
    WaveFormat = m_Wave.WAVEfmt.Format
End Property

Friend Property Get SamplerInfo() As WaveSamplerChunk
    SamplerInfo = m_Wave.smpl
End Property
Friend Property Let SamplerInfo(RHS As WaveSamplerChunk)
    m_Wave.smpl = RHS
End Property
Friend Property Get LoopList() As SampleLoopList
    LoopList = m_Wave.loops
End Property
Friend Property Let LoopList(RHS As SampleLoopList)
    m_Wave.loops = RHS
End Property
Friend Property Get InstrumentInfo() As InstrumentFormatChunk
    InstrumentInfo = m_Wave.inst
End Property
Friend Property Let InstrumentInfo(RHS As InstrumentFormatChunk)
    m_Wave.inst = RHS
End Property

Public Sub CopyDataFromKSF(ByVal pDat As Long, ByVal bLength As Long)
    Dim i As Long
    Dim stp As Long
    Dim bTmp As Byte
    If pDat = 0 Then Exit Sub
    If bLength <= 0 Then Exit Sub
    With m_Wave
        stp = .WAVEfmt.Format.BitsPerSample / 8
        With .data
            ReDim .data(0 To bLength - 1)
            Call RtlMoveMemory(.data(0), ByVal pDat, bLength)
            If stp > 1 Then
                For i = 0 To bLength - 2 Step stp
                    'die bytes swappen
                    bTmp = .data(i)
                    .data(i) = .data(i + 1)
                    .data(i + 1) = bTmp
                Next
            End If
        End With
    End With
End Sub
Public Sub Play()
    'If Len(m_FileName) > 0 Then Call MAudioSystem.PlayWAVfile(m_FileName)
    MAudioSystem.PlayWAV Me
End Sub
Public Property Get Ptr() As Long
    Ptr = VarPtr(m_Wave) '.data.data(0))
End Property

Public Property Get pData() As Long
    pData = VarPtr(m_Wave.data.data(0))
End Property
Public Property Get WaveDataByteLength() As Long
    WaveDataByteLength = SafeUbound(ArrPtr(m_Wave.data.data)) + 1
End Property

Public Sub Save(aFilename As String)
Try: On Error GoTo Catch
    Dim i As Long
    m_FileName = aFilename
    Dim FNr As Integer: FNr = FreeFile
    'die richtigen Längen eintragen
    With m_Wave
        With .data
            .Header.ChunkSize = SafeUbound(ArrPtr(.data)) + 1
        End With
        .RIFF.ChunkSize = LenB(.WAVEfmt) + _
                          LenB(.data.Header) + .data.Header.ChunkSize + _
                          LenB(.smpl)
    End With
    Open m_FileName For Binary Access Write As FNr
    With m_Wave
        Put FNr, , .RIFF
        Put FNr, , .WAVEfmt
        Put FNr, , .data.Header
        Put FNr, , .data.data
        Put FNr, , .smpl
        With .loops
            Put FNr, , .NumSampleLoops
            'ReDim .SampleLoops(0 To .NumSampleLoops)
            Put FNr, , .SamplerData
            If .NumSampleLoops > 0 Then
                For i = 0 To .NumSampleLoops - 1
                    Put FNr, , .SampleLoops(i)
                Next
            End If
        End With
        Put FNr, , .inst
    End With
Finally:
    Close FNr
    Exit Sub
Catch:
    MsgBox Err.Description
    GoTo Finally
End Sub
Public Property Get FileName() As String
    FileName = m_FileName
End Property
'Public Sub Load(aFileName As String)
'
'End Sub
'Public Sub Draw(aView As PictureBox, _
'                Optional ByVal bPoints As Boolean, _
'                Optional ByVal StartIndex As Long, _
'                Optional ByVal StartX As Long, _
'                Optional ByVal dx As Double, _
'                Optional ByVal dy As Double)
'    Dim X As Long ', xLoop As Long
'    Dim Y As Long ', yLoop As Long
'    Dim color As Long
'    Dim ix As Long, u As Long
'    Dim iy As Long
'    Dim stp As Long
'    Dim h2 As Long
'
'    aView.Cls
'    aView.ScaleMode = vbPixels
'
'    With m_Wave
'        u = SafeUbound(ArrPtr(.data.data))
'        stp = .WAVEfmt.Format.BitsPerSample / 8
'        h2 = aView.ScaleHeight / 2
'
'        'die Mittellinie zeichnen
'        color = aView.ForeColor   'die Farbe nachher wieder zurückschreiben
'        aView.ForeColor = vbWhite '
'        X = 0:        Y = h2
'        aView.Line (X, Y)-(aView.ScaleWidth, Y)
'        aView.ForeColor = color
'
'        'dx und dy ermitteln
'        If dx = 0 Then dx = (aView.ScaleWidth - brdr) / (u / stp)
'        If dy = 0 Then dy = (aView.ScaleHeight - brdr) / (2 ^ (stp * 8))
'
'        aView.CurrentX = X
'        aView.CurrentY = Y
'
'
'        With .data
'            For ix = StartIndex * stp To u - 1 Step stp
'                If stp = 1 Then     '8-Bit
'                    iy = CLng(.data(ix))
'                ElseIf stp = 2 Then '16-Bit
'                    iy = CLng(ConvertToSignedInt16(.data(ix + 1), .data(ix)))
'                    'Call GetMem2(.data(i), iy)
'                ElseIf stp = 3 Then '24-Bit
'                    iy = ConvertToSignedInt32(.data(ix + 2), .data(ix + 1), .data(ix))
'                End If
'                X = ix * dx / stp
'                Y = iy * dy + h2
'                If bPoints Then
'                    aView.PSet (X, Y)
'                Else
'                    aView.Line -(X, Y)
'                End If
'            Next
''            'draw a vert line at the beginning and end of the loop
''            'If ix = (m_KSFFile.SampleParam.LoopStartAddress \ stp) Then
''            If m_KSFFile.SampleParam.LoopStartAddress > 0 Then
''                'xLoop = x
''                'yLoop = 0
''                x = m_KSFFile.SampleParam.LoopStartAddress * dx / stp
''                'x = m_KSFFile.SampleParam.LoopStartAddress * dx
''                color = aView.ForeColor
''                aView.ForeColor = vbGreen 'vbYellow
''                aView.Line (x, 0)-(x, aView.ScaleHeight)
''                'aView.PSet (x, y)
''                aView.ForeColor = color
''            End If
''            'If ix = (m_KSFFile.SampleParam.LoopEndAdress \ 2) Then
''            If m_KSFFile.SampleParam.LoopEndAdress > 0 Then
''                color = aView.ForeColor
''                aView.ForeColor = vbYellow
''                x = m_KSFFile.SampleParam.LoopEndAdress * dx / stp
''                'x = m_KSFFile.SampleParam.LoopEndAdress * dx
''                aView.Line (x, 0)-(x, aView.ScaleHeight)
''                'aView.PSet (x, y)
''                aView.ForeColor = color
''            End If
'            For ix = 0 To m_Wave.loops.NumSampleLoops - 1
'                With m_Wave.loops.SampleLoops(ix)
'
'                    X = .LoopStart * dx '/ stp
'                    aView.ForeColor = vbGreen 'vbYellow
'                    aView.Line (X, 0)-(X, aView.ScaleHeight)
'
'                    X = .LoopEnd * dx '/ stp
'                    aView.ForeColor = vbYellow
'                    aView.Line (X, 0)-(X, aView.ScaleHeight)
'
'                End With
'            Next
'            aView.ForeColor = color
'        End With
'    End With
'End Sub
Public Sub Draw(aView As PictureBox, _
                Optional ByVal bPoints As Boolean, _
                Optional ByVal StartIndex As Long, _
                Optional ByVal StartX As Long, _
                Optional ByVal dx As Double, _
                Optional ByVal dy As Double)
                    
    Dim X As Long ', xLoop As Long
    Dim Y As Long ', yLoop As Long
    Dim color As Long
    Dim ix As Long, u As Long
    Dim iy As Long
    Dim stp As Long
    Dim h2 As Long
    Dim brdr As Long: brdr = 8
    
    aView.Cls
    aView.ScaleMode = vbPixels
    
    With m_Wave
        u = SafeUbound(ArrPtr(.data.data))
        stp = .WAVEfmt.Format.BitsPerSample / 8
        h2 = aView.ScaleHeight / 2
        
        'die Mittellinie zeichnen
        color = aView.ForeColor   'die Farbe nachher wieder zurückschreiben
        aView.ForeColor = vbWhite '
        X = 0:        Y = h2
        aView.Line (X, Y)-(aView.ScaleWidth, Y)
        aView.ForeColor = color
        
        'dx und dy ermitteln
        If dx = 0 Then dx = (aView.ScaleWidth - brdr) / (u / stp)
        If dy = 0 Then dy = (aView.ScaleHeight - brdr) / (2 ^ (stp * 8))
        
        aView.CurrentX = X
        aView.CurrentY = Y
        
        
        With .data
            For ix = StartIndex * stp To u - 1 Step stp
                If stp = 1 Then     '8-Bit
                    iy = CLng(.data(ix))
                ElseIf stp = 2 Then '16-Bit
                    iy = CLng(ConvertToSignedInt16(.data(ix + 1), .data(ix)))
                    'Call GetMem2(.data(i), iy)
                ElseIf stp = 3 Then '24-Bit
                    iy = ConvertToSignedInt32(.data(ix + 2), .data(ix + 1), .data(ix))
                End If
                X = (ix - StartIndex * stp) * dx / stp
                Y = iy * dy + h2
                If bPoints Then
                    aView.PSet (X, Y)
                Else
                    aView.Line -(X, Y)
                End If
            Next
'            'draw a vert line at the beginning and end of the loop
'            'If ix = (m_KSFFile.SampleParam.LoopStartAddress \ stp) Then
'            If m_KSFFile.SampleParam.LoopStartAddress > 0 Then
'                'xLoop = x
'                'yLoop = 0
'                x = m_KSFFile.SampleParam.LoopStartAddress * dx / stp
'                'x = m_KSFFile.SampleParam.LoopStartAddress * dx
'                color = aView.ForeColor
'                aView.ForeColor = vbGreen 'vbYellow
'                aView.Line (x, 0)-(x, aView.ScaleHeight)
'                'aView.PSet (x, y)
'                aView.ForeColor = color
'            End If
'            'If ix = (m_KSFFile.SampleParam.LoopEndAdress \ 2) Then
'            If m_KSFFile.SampleParam.LoopEndAdress > 0 Then
'                color = aView.ForeColor
'                aView.ForeColor = vbYellow
'                x = m_KSFFile.SampleParam.LoopEndAdress * dx / stp
'                'x = m_KSFFile.SampleParam.LoopEndAdress * dx
'                aView.Line (x, 0)-(x, aView.ScaleHeight)
'                'aView.PSet (x, y)
'                aView.ForeColor = color
'            End If
            For ix = 0 To m_Wave.loops.NumSampleLoops - 1
                With m_Wave.loops.SampleLoops(ix)

                    X = (.LoopStart - StartIndex) * dx '/ stp
                    aView.ForeColor = vbGreen 'vbYellow
                    aView.Line (X, 0)-(X, aView.ScaleHeight)
                                        
                    X = (.LoopEnd - StartIndex) * dx '/ stp
                    aView.ForeColor = vbYellow
                    aView.Line (X, 0)-(X, aView.ScaleHeight)
                    
                End With
            Next
            aView.ForeColor = color
        End With
    End With
End Sub

Private Function ConvertToSignedInt16(ByVal hi As Byte, ByVal lo As Byte) As Integer
    GetMem2 CLng(lo + hi * &H100&), ConvertToSignedInt16
End Function
Private Function ConvertToSignedInt32(ByVal hi As Byte, ByVal md As Byte, ByVal lo As Byte) As Long
    GetMem4 CLng(lo + md * &H100& + hi * &H10000), ConvertToSignedInt32
End Function
' #################### '    ErrHandler    ' #################### '
Private Function ErrHandler(fncnam As String, Optional msgstyle As VbMsgBoxStyle) As VbMsgBoxResult
    ErrHandler = GlobalErrhandler("WaveSound", fncnam, msgstyle)
End Function

