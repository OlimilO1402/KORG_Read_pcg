VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "KorgSampleFile"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
Private m_KDoc    As KorgDocument
Private m_KSFFile As KSFFile
Private m_Wave    As WaveSound
Private m_KMPIndex As Long 'in welcher KMP-datei
Private m_RLPIndex As Long 'an welcher Stelle in der KMP-Datei

Friend Sub New_(aKorgDoc As KorgDocument, _
                Optional aFilename As String, _
                Optional ByVal kmpIndex As Long, _
                Optional ByVal rlpIndex As Long)
    Set m_KDoc = aKorgDoc
    If Len(aFilename) > 0 Then Call Me.Load(aFilename)
    m_KMPIndex = kmpIndex
    m_RLPIndex = rlpIndex
End Sub
Public Property Get KorgDocument() As KorgDocument
    Set KorgDocument = m_KDoc
End Property
Public Sub Load(aFilename As String)
    Call MKSFFile.Load(m_KSFFile, aFilename)
End Sub
Public Function ToString() As String
    ToString = MKSFFile.KSFFileTostring(m_KSFFile)
End Function
Public Property Get FileName() As String
    FileName = m_KSFFile.FileName
End Property
Public Property Get Name() As String
    Name = UCase(Dir$(m_KSFFile.FileName))
End Property
Public Property Get SampleName() As String
    SampleName = BytarrToString(m_KSFFile.SampleParam.SampleName)
End Property

Friend Property Get pSoundData() As Long
    pSoundData = VarPtr(m_KSFFile.SampleData.SampleData(0))
End Property

Friend Property Get WaveFormat() As WaveFormat
    With m_KSFFile
        'channels, bitspersample, samplerate
        '1,        16,            44100
        With .SampleData
            WaveFormat = New_WaveFormat(.NumOfChnls, .SampleSize, .SampleRate)
        End With
    End With
End Property
Friend Property Get SamplerInfo() As WaveSamplerChunk
    Dim MSRLP As MultiSampleRelativeParam
    MSRLP = m_KDoc.MultiSampleRelativeParam(m_KMPIndex, m_RLPIndex)
    With SamplerInfo
        .Manufacturer = MMAid.Korg 'Korg = 66 '(0x42)
        If Not m_KDoc Is Nothing Then
            .Product = m_KDoc.ProductID
        End If
        .MIDIUnityNote = MSRLP.OriginalKey
        '.MIDIPitchFraction ?
        'If m_KSFFile.SampleParam.LoopEndAdress > 0 Then
        '
        '    .NumSampleLoops = 1
        '    ReDim .SampleLoops(0 To 1)
        '    .SampleLoops(0) = m_KSFFile.SampleParam.LoopStartAddress
        '    .SampleLoops(1) = m_KSFFile.SampleParam.LoopEndAdress
        'End If
        '.SMPTEFormat ?
        '.SMPTEOffset ?
        '.SamplerData ?
        .Header = New_ChunkHeader(WAVEid.smpl, LenB(SamplerInfo))
    End With
End Property
Friend Property Get LoopList() As SampleLoopList
    Dim i As Long
    Dim MSRLP As MultiSampleRelativeParam
    MSRLP = m_KDoc.MultiSampleRelativeParam(m_KMPIndex, m_RLPIndex)
    With LoopList
        .NumSampleLoops = 1
        .SamplerData = 0 '??
        ReDim .SampleLoops(0 To .NumSampleLoops - 1)
        For i = 0 To .NumSampleLoops - 1
            With .SampleLoops(i)
                .CuePointID = 0 'As Long
                .LoopType = LoopType.LoopForward   'As Long 'LoopType '0 - 0xFFFFFFFF
                .LoopStart = m_KSFFile.SampleParam.LoopStartAddress  'As Long '0 - 0xFFFFFFFF
                    'specifies the byte offset into the waveform data of the first sample to be played in the loop
                .LoopEnd = m_KSFFile.SampleParam.LoopEndAdress    'As Long '0 - 0xFFFFFFFF
                    'specifies the byte offset into the waveform data of the last  sample to be played in the loop
                .Fraction = 0   'As Long '0 - 0xFFFFFFFF
                .PlayCount = 0  'As Long '0 - 0xFFFFFFFF
            End With
        Next
    End With
End Property
Friend Property Get InstrumentInfo() As InstrumentFormatChunk
    Dim MSRLP_1 As MultiSampleRelativeParam
    Dim MSRLP As MultiSampleRelativeParam
    MSRLP_1 = m_KDoc.MultiSampleRelativeParam(m_KMPIndex, m_RLPIndex - 1)
    MSRLP = m_KDoc.MultiSampleRelativeParam(m_KMPIndex, m_RLPIndex)
    With InstrumentInfo
        .UnshiftedNote = CByte(MSRLP.OriginalKey) ' As Byte '0 - 127
    'the same meaning as the sampler chunk's MIDI Unity Note which specifies the
    'musical note at which the sample will be played at it's original sample rate
    '(the sample rate specified in the format chunk
        .FineTune = CByte(MSRLP.Tune) '  As Byte ' - 50 - 50 (Cents)
    'specifies how much the sample's pitch should be altered when the sound is
    'played back in cents (1/100 of a semitone). A negative value means that the
    'pitch should be played lower and a positive value means that it should be
    'played at a higher pitch.
        .Gain = CByte(MSRLP.Level) '          As Byte '-64 - 64 (dB)
    'specifies the number of decibels to adjust the output when it is played.
    'A value of 0dB means no change, 6dB means double the amplitude of each sample
    'and -6dB means to halve the amplitude of each sample. Every additional +/-6dB
    'will double or halve the amplitude again.
        .LowNote = CByte(MSRLP_1.TopKey + 1) '       As Byte '0 - 127
        .HighNote = CByte(MSRLP.TopKey) '      As Byte '0 - 127
    'The note fields specify the MIDI note range for which the waveform should be played
    'when receiving MIDI note events (from software or triggered by a MIDI controller).
    'This range does not need to include the Unshifted Note value
        .LowVelocity = CByte(0)  '  As Byte '1 - 127
        .HighVelocity = CByte(0) '  As Byte '1 - 127
    'The velocity fields specify the range of MIDI velocities that should cause the
    'waveform sto be played. 1 being the lightest amount and 127 being the hardest.
        .Header = New_ChunkHeader(WAVEid.inst, LenB(InstrumentInfo))
    End With
End Property
Public Property Get Wave() As WaveSound
    If m_Wave Is Nothing Then
        With m_KSFFile.SampleData
            If SafeUbound(ArrPtr(.SampleData)) >= 0 Then
                Set m_Wave = MNew.WaveSound(Me.WaveFormat)
                Call m_Wave.CopyDataFromKSF(VarPtr(.SampleData(0)), UBound(.SampleData) + 1)
                m_Wave.SamplerInfo = Me.SamplerInfo
                m_Wave.LoopList = Me.LoopList
                m_Wave.InstrumentInfo = Me.InstrumentInfo
            Else
                Dim key As String: key = BytarrToString(m_KSFFile.SampleFile.KSFFileName)
                Dim KSF As KorgSampleFile
                If Len(key) > 0 Then Set KSF = m_KDoc.KorgSampleFile(key)
                If Not KSF Is Nothing Then
                    Set m_Wave = KSF.Wave
                End If
            End If
        End With
    End If
    Set Wave = m_Wave
End Property
Public Sub Play()
    'If m_Wave Is Nothing Then
    '    'm_Wave = new WaveSound
    'End If
    'm_Wave.Play
    'Call MAudioSystem.PlayWAV(Me.Wave)
    Dim wav As WaveSound: Set wav = Me.Wave
    If Not wav Is Nothing Then
        wav.Play
    End If
End Sub

Public Sub Draw(aView As PictureBox, Optional ByVal bPoints As Boolean)
    Call Me.Wave.Draw(aView, bPoints)
    Exit Sub
'    Dim x As Long, dx As Double ', xLoop As Long
'    Dim y As Long, dy As Double ', yLoop As Long
'    Dim color As Long
'    Dim brdr As Long: brdr = 8
'    Dim ix As Long, u As Long
'    Dim iy As Long
'    Dim stp As Long
'    'Dim shL8 As Long: shL8 = 2 ^ 8
'    Dim h2 As Long
'    aView.Cls
'    aView.ScaleMode = vbPixels
'    'bPoints = True
'    With m_KSFFile.SampleData
'        u = SafeUbound(ArrPtr(.SampleData))
'        If u <= (.NumOfSamples - 1) Then
'            Debug.Print "u: " & CStr(u) & " " & CStr(.NumOfSamples)
'            Exit Sub
'        End If
'        stp = .SampleSize / 8
'        h2 = aView.ScaleHeight / 2
'        x = 0
'        y = h2
'        'die Mittellinie zeichnen
'        color = aView.ForeColor
'        aView.ForeColor = vbWhite
'        aView.Line (x, y)-(aView.ScaleWidth, y)
'        aView.ForeColor = color
'
'        If .NumOfSamples <= 0 Then Exit Sub
'        dx = aView.ScaleWidth / .NumOfSamples  '* 50
'        dy = (aView.ScaleHeight - brdr) / (2 ^ .SampleSize)
'        aView.CurrentX = x
'        aView.CurrentY = y
'        For ix = 0 To (.NumOfSamples * stp) - 1 Step stp
'            If stp = 1 Then
'                iy = CLng(.SampleData(ix))
'            Else
'                iy = CLng(ConvertToSignedInt16(.SampleData(ix), .SampleData(ix + 1)))
'            End If
'            x = ix * dx / stp
'            y = iy * dy + h2
'            If bPoints Then
'                aView.PSet (x, y)
'            Else
'                aView.Line -(x, y)
'            End If
'        Next
'        'draw a vert line at the beginning and end of the loop
'        'If ix = (m_KSFFile.SampleParam.LoopStartAddress \ stp) Then
'        If m_KSFFile.SampleParam.LoopStartAddress > 0 Then
'            'xLoop = x
'            'yLoop = 0
'            x = m_KSFFile.SampleParam.LoopStartAddress * dx / stp
'            'x = m_KSFFile.SampleParam.LoopStartAddress * dx
'            color = aView.ForeColor
'            aView.ForeColor = vbGreen 'vbYellow
'            aView.Line (x, 0)-(x, aView.ScaleHeight)
'            'aView.PSet (x, y)
'            aView.ForeColor = color
'        End If
'        'If ix = (m_KSFFile.SampleParam.LoopEndAdress \ 2) Then
'        If m_KSFFile.SampleParam.LoopEndAdress > 0 Then
'            color = aView.ForeColor
'            aView.ForeColor = vbYellow
'            x = m_KSFFile.SampleParam.LoopEndAdress * dx / stp
'            'x = m_KSFFile.SampleParam.LoopEndAdress * dx
'            aView.Line (x, 0)-(x, aView.ScaleHeight)
'            'aView.PSet (x, y)
'            aView.ForeColor = color
'        End If
'    End With
End Sub
'Private Function ConvertToSignedInt16(ByVal hi As Byte, ByVal lo As Byte) As Integer
'    GetMem2 CLng(lo + hi * &H100&), ConvertToSignedInt16
'End Function
'
' #################### '    ErrHandler    ' #################### '
Private Function ErrHandler(fncnam As String, Optional msgstyle As VbMsgBoxStyle) As VbMsgBoxResult
    ErrHandler = GlobalErrhandler("KorgSampleFile", fncnam, msgstyle)
End Function

