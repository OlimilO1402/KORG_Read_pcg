VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "KORGDocument"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
Private m_FileName   As String
Private m_PCGFile    As PCGFile
Private m_KSCFile    As KSCFile
Private m_KMPFiles() As KMPFile
Private m_KSFFiles   As Collection '() As KorgSampleFile 'Collection


Public Sub Load(aFilename As String)
Try: On Error GoTo Catch
    m_FileName = aFilename
    Set m_KSFFiles = New Collection
    
    'hmm das is jetzt unlogisch
    'wieso Datei nciht gefunden, wenn man doch
    'PCG
    Dim FNm As String: FNm = MFileInfo.ChangeExt(m_FileName, "PCG")
    If FileExists(FNm) Then
        Call LoadRelatedFile(FNm)
    Else
        MsgBox "File not found: " & vbCrLf & FNm
    End If
    
    'KSC
    FNm = MFileInfo.ChangeExt(m_FileName, "KSC")
    If FileExists(FNm) Then
        Call LoadRelatedFile(FNm)
        With m_KSCFile
            If .KMPFiles.count > 0 Then
                ReDim m_KMPFiles(0 To .KMPFiles.count - 1)
                Dim i As Integer
                Dim kmpFNm As String
                For i = 0 To SafeUbound(ArrPtr(m_KMPFiles))
                    kmpFNm = Left$(m_FileName, Len(m_FileName) - 4) & "\" & .KMPFiles.Item(i + 1)
                    Call MKMPFile.LoadKMPFile(m_KMPFiles(i), kmpFNm)
                Next
                Call MKMPFile.LoadAllKSFFiles(m_KMPFiles, Me)
            End If
            'If .KSFFiles.count > 0 Then
            '    Call MKSCFile.LoadAllKSFFiles(m_KSCFile, Me)
            'End If
        End With
    Else
        MsgBox "File not found: " & vbCrLf & FNm
    End If
    
    'die Extension überprüfen
    Dim ext As String: ext = UCase(Right$(m_FileName, 3))
    'KMP, KSF
    If ext = "KMP" Then
        ReDim m_KMPFiles(0)
        Call MKMPFile.LoadKMPFile(m_KMPFiles(0), m_FileName)
        Call MKMPFile.LoadAllKSFFiles(m_KMPFiles(), Me)
    ElseIf ext = "KSF" Then
        Call Me.AddKorgSampleFile(MNew.KorgSampleFile(Me, m_FileName))
    End If
    
    
    Exit Sub
Catch:
    Call ErrHandler("Load")
End Sub
Public Sub LoadRelatedFile(PCG_KSC_KMP_KSF_FileName As String) 'As Boolean
    m_FileName = PCG_KSC_KMP_KSF_FileName
    Dim ext As String: ext = UCase(Right$(m_FileName, 3))
    Select Case ext
    Case "PCG"
        Call MPCGFile.Load(m_PCGFile, m_FileName)
    Case "KSC"
        Call MKSCFile.LoadKSCFile(m_KSCFile, m_FileName)
        Call MKSCFile.LoadAllKSFFiles(m_KSCFile, Me)
    'Case "KMP": Call MKMPFile.LoadKMPFile(m_FileName)
    'Case "KSF": Call MKMPFile.LoadKMPFile(m_FileName)
    End Select
End Sub
Public Property Get FileName() As String
    FileName = m_FileName
End Property
Public Property Get Samples() As Collection
    Set Samples = m_KSFFiles
End Property
Friend Property Get MultiSampleRelativeParam(ByVal kmpIndex As Long, _
                                             ByVal rlpIndex As Long) As MultiSampleRelativeParam
    Dim u1 As Long: u1 = SafeUbound(ArrPtr(m_KMPFiles()))
    If u1 >= 0 And u1 >= kmpIndex Then
        With m_KMPFiles(kmpIndex)
            Dim u2 As Long: u2 = SafeUbound(ArrPtr(.RelativeParams.data()))
            If rlpIndex < 0 Then rlpIndex = 0
            If u2 >= 0 And u2 >= rlpIndex Then
                MultiSampleRelativeParam = m_KMPFiles(kmpIndex).RelativeParams.data(rlpIndex)
            End If
        End With
    End If
End Property
Public Property Get ProductID() As Long
    ProductID = m_PCGFile.FileHeader.ProductID
End Property
Public Function ToString() As String
    Dim s As String
    's = s & m_FileName & vbCrLf
    s = s & MPCGFile.PCGFileToString(m_PCGFile) & IIf(Len(s) > 0, vbCrLf, "")
    s = s & MKSCFile.KSCFileToString(m_KSCFile) & IIf(Len(s) > 0, vbCrLf, "")
    Dim i As Integer
    For i = 0 To SafeUbound(ArrPtr(m_KMPFiles))
        s = s & MKMPFile.KMPFileToString(m_KMPFiles(i)) & IIf(Len(s) > 0, vbCrLf, "")
    Next
    's = s &
    If Len(s) = 0 Then
        Dim KSF As KorgSampleFile
        For Each KSF In Me.Samples
            s = s & KSF.ToString & IIf(Len(s) > 0, vbCrLf, "")
        Next
    End If
    ToString = s
    
End Function
Public Function KMPFileToString(KMPFilename As String) As String
    Dim i As Long, u As Long
    Dim s As String
    Dim n As String
    u = SafeUbound(ArrPtr(m_KMPFiles))
    For i = 0 To u
        With m_KMPFiles(i)
            n = BytarrToString(m_KMPFiles(i).MSPProps.NName)
            If UCase(Trim$(n)) = UCase(KMPFilename) Then
                's = s & .FileName & vbCrLf
                's = s & MKMPFile.KMPFileToString(m_KMPFiles(i))
                'KMPFileToString = s
                KMPFileToString = MKMPFile.KMPFileToString(m_KMPFiles(i))
                Exit Function
            End If
        End With
        'Exit For
    Next
End Function
Public Sub AddKorgSampleFile(aKSFFile As KorgSampleFile) 'As KorgSampleFile
    Call m_KSFFiles.Add(aKSFFile, aKSFFile.Name)
End Sub
Public Property Get CountKorgSampleFiles() As Long
    CountKorgSampleFiles = m_KSFFiles.count
End Property
Public Sub KSFFilesToListBox(aListBox As ListBox)
    aListBox.Clear
    'mmm Mist,
    'was macht man mit den Dateien die nicht in
    'einfach nur alle hintereinander
    
    'Dim KSF As KorgSampleFile
    'For Each KSF In m_KSFFiles
    '    Call aListBox.AddItem(KSF.Name)
    'Next
    Dim Nam 'As String
    If Not m_KSCFile.KSFFiles Is Nothing Then
        For Each Nam In m_KSCFile.KSFFiles
            Call aListBox.AddItem(CStr(Nam))
        Next
    End If
    'oder getrennt pro KMP-File
    Dim i As Long, j As Long
    Dim u As Long: u = SafeUbound(ArrPtr(m_KMPFiles))
    If u >= 0 Then
        For i = 0 To u
            With m_KMPFiles(i)
                'Call aListBox.AddItem(.FileName)
                Call aListBox.AddItem(BytarrToString(.MSPProps.NName))
                For j = 0 To SafeUbound(ArrPtr(.RelativeParams.data)) '.MSPProps.NumOfSamples - 1
                    Nam = BytarrToString(.RelativeParams.data(j).KSFName)
                    If Nam <> "SKIPPEDSAMPL" Then
                        Call aListBox.AddItem("   " & Nam)
                    End If
                Next
            End With
        Next
    Else
        'jetzt noch schauen ob es überhaupt nur KSF-Files gibt
        If Not m_KSFFiles Is Nothing Then
            If m_KSFFiles.count > 0 Then
                Dim KSF As KorgSampleFile
                For Each KSF In m_KSFFiles
                    Call aListBox.AddItem(KSF.Name)
                Next
            End If
        End If
    End If
End Sub
Public Property Get KorgSampleFile(aKSFFileNamekey As String) As KorgSampleFile
    If Len(aKSFFileNamekey) > 0 Then
        If ContainsKey(m_KSFFiles, aKSFFileNamekey) Then
            Set KorgSampleFile = m_KSFFiles.Item(aKSFFileNamekey)
        End If
    End If
End Property
Public Sub SaveAllWave()

End Sub
Private Function ContainsKey(col As Collection, ByVal key As String) As Boolean
    On Error Resume Next
    If VarType(col.Item(key)) <> vbEmpty Then '
    End If
    If Err.Number = 0 Then ContainsKey = True
    On Error GoTo 0
End Function

' #################### '    ErrHandler    ' #################### '
Private Function ErrHandler(fncnam As String, Optional msgstyle As VbMsgBoxStyle) As VbMsgBoxResult
    ErrHandler = GlobalErrhandler("KORGDocument", fncnam, msgstyle)
End Function


