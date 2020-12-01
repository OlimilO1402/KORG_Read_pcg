Attribute VB_Name = "MKSCFile"
Option Explicit
'The KSC - Fileformat:
'this is just a normal ANSI-File. The first line is a comment denoted with #
'and contains the line
'#KORG Script Version 1.0
'
'then there are two lines with KMP-filenames
'e.g:
'SUPER000.kmp
'SUPER001.kmp
'
'then there are two or more lines with KSF-filenames
'AGOG0011.ksf
'CABA0016.ksf
'CAST0017.ksf
'
'this files, (kmp and ksf) can be found in a subdir with the name of the KSC-file
'(wo ext) this subdir then has another two subdirs with the name of the KMP-files
'in this subdirs there are another more KSF-files
Public Type KSCFile
    FileName As String
    Lines    As Collection
    KMPFiles As Collection 'contains filenames as String
    KSFFiles As Collection 'contains filenames as String
End Type

Public Sub LoadKSCFile(this As KSCFile, aFilename As String)
Try: On Error GoTo Catch
    Dim FNr As Integer: FNr = FreeFile
    Dim sLin As String
    Dim ext As String
    With this
        .FileName = aFilename
        Set .Lines = New Collection
        Set .KMPFiles = New Collection
        Set .KSFFiles = New Collection
        Open .FileName For Input As FNr
        Do While Not EOF(FNr)
            Line Input #FNr, sLin
            .Lines.Add sLin
            ext = UCase(Right$(sLin, 3))
            If ext = "KMP" Then
                's_kmp = skmp & sArr(i) & vbCrLf
                .KMPFiles.Add sLin
            ElseIf ext = "KSF" Then
                's_ksf = s_ksf & sArr(i) & vbCrLf
                .KSFFiles.Add sLin
            End If
        Loop
    End With
Finally:
    Close FNr
    Exit Sub
Catch:
    Call ErrHandler("LoadKSCFile")
    GoTo Finally
End Sub

Public Sub LoadAllKSFFiles(this As KSCFile, aKorgDoc As KorgDocument)
    Dim vFNam 'As String
    Dim Path As String, FNam As String, PFN As String
    With this
        Path = WithOutExtension(.FileName) & "\"
        'Path = .FileName
        For Each vFNam In this.KSFFiles
            'Halt der Pfad fehlt!
            FNam = CStr(vFNam)
            PFN = Path & FNam
            Call aKorgDoc.AddKorgSampleFile(New_KorgSampleFile(aKorgDoc, PFN))
        Next
    End With
End Sub

' #################### '    ToString    ' #################### '
Public Function KSCFileToString(this As KSCFile) As String
    Dim l, s As String, s1 As String
    With this
        s1 = .FileName
        If Len(s1) = 0 Then Exit Function
        s = s & HeadlineToString("KSC-File", s1) & vbCrLf
        If Not .Lines Is Nothing Then
            If .Lines.count > 0 Then
                For Each l In .Lines
                    s = s & l & vbCrLf
                Next
            End If
        End If
    End With
    KSCFileToString = s
End Function

'FileNameConvention
'MultiSample
'  MS001003.KSF
'  MS: MultiSample
'    001: Multisamplenumber; first = 000
'       003: SampleNumber of the Multisample; first = 000
'
'DrumSample
'  DS___003.KSF
'  DS: Drum-Sample
'       003: Drumsample Number: first = 000
'
'KMP Filename
'  PIANO002.KMP
'  PIANO: first 5 chars of the multi sample name
'       002: Sample number; first = 000

' #################### '    ErrHandler    ' #################### '
Private Function ErrHandler(fncnam As String, Optional msgstyle As VbMsgBoxStyle) As VbMsgBoxResult
    ErrHandler = GlobalErrhandler("KSCFile", fncnam, msgstyle)
End Function

