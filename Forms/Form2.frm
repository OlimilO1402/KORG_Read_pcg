VERSION 5.00
Begin VB.Form Form2 
   Caption         =   "KMP-Reader"
   ClientHeight    =   8295
   ClientLeft      =   225
   ClientTop       =   870
   ClientWidth     =   11415
   Icon            =   "Form2.frx":0000
   LinkTopic       =   "Form2"
   ScaleHeight     =   8295
   ScaleWidth      =   11415
   StartUpPosition =   3  'Windows-Standard
   Begin VB.TextBox TxtInfo 
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   6255
      Left            =   2640
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Beides
      TabIndex        =   5
      Text            =   "Form2.frx":554A
      Top             =   480
      Width           =   7695
   End
   Begin VB.PictureBox PBWaveView 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00000040&
      ForeColor       =   &H00FF0000&
      Height          =   4215
      Left            =   2640
      ScaleHeight     =   4155
      ScaleWidth      =   8595
      TabIndex        =   4
      Top             =   480
      Width           =   8655
   End
   Begin VB.CommandButton BtnPlay 
      Caption         =   "Play"
      Height          =   375
      Left            =   120
      TabIndex        =   3
      Top             =   120
      Width           =   2415
   End
   Begin VB.OptionButton OptView 
      Caption         =   "Wave"
      Height          =   375
      Left            =   3840
      Style           =   1  'Grafisch
      TabIndex        =   2
      Top             =   120
      Width           =   1215
   End
   Begin VB.OptionButton OptInfo 
      Caption         =   "Info"
      Height          =   375
      Left            =   2640
      Style           =   1  'Grafisch
      TabIndex        =   1
      Top             =   120
      Value           =   -1  'True
      Width           =   1215
   End
   Begin VB.ListBox LstKSFFiles 
      Height          =   6300
      Left            =   120
      TabIndex        =   0
      Top             =   480
      Width           =   2415
   End
   Begin VB.Menu mnuFile 
      Caption         =   "&File"
      Begin VB.Menu mnuFileSaveAsWav 
         Caption         =   "Save As &wav"
      End
      Begin VB.Menu mnuFileSaveWavAs 
         Caption         =   "Save wav &As..."
         Visible         =   0   'False
      End
      Begin VB.Menu mnuFileSaveAllWav 
         Caption         =   "&Save All wav"
      End
      Begin VB.Menu mnuFileSep 
         Caption         =   "-"
      End
      Begin VB.Menu mnuFileClose 
         Caption         =   "&Close"
      End
   End
   Begin VB.Menu mnuView 
      Caption         =   "&View"
      Begin VB.Menu mnuViewDrawpoints 
         Caption         =   "Draw &Points"
      End
   End
End
Attribute VB_Name = "Form2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private m_KDoc       As KorgDocument
Private m_CurKSFFile As KorgSampleFile
Private m_WaveView   As WaveView

Public Sub ShowModal(KDoc As KorgDocument, aForm As Form)
    Set m_WaveView = MNew.WaveView(Me.PBWaveView)
    Set m_KDoc = KDoc
    Call m_KDoc.KSFFilesToListBox(Me.LstKSFFiles)
    If LstKSFFiles.ListCount > 0 Then
        LstKSFFiles.ListIndex = 0
    End If
    'OptInfo.Value = True
    Me.Show vbModal, aForm
End Sub

Private Sub Form_Resize()
    Dim l As Single, T As Single, W As Single, H As Single
    Dim brdr As Single: brdr = 8 * Screen.TwipsPerPixelX
    l = PBWaveView.Left: T = PBWaveView.Top
    W = Me.ScaleWidth - l - brdr
    H = Me.ScaleHeight - T - brdr
    If W > 0 And H > 0 Then
        PBWaveView.Move l, T, W, H
        TxtInfo.Move l, T, W, H
        LstKSFFiles.Height = Me.ScaleHeight - LstKSFFiles.Top - brdr
        If OptView.Value Then OptView_Click
    End If
End Sub

Private Sub BtnPlay_Click()
    If Not m_CurKSFFile Is Nothing Then
        m_CurKSFFile.Play
        LstKSFFiles.SetFocus
    End If
End Sub

Private Sub LstKSFFiles_Click()
    Dim key As String
    With LstKSFFiles
        If .ListCount > 0 Then
            If .ListIndex >= 0 Then
                key = .List(.ListIndex)
                If UCase(Right$(key, 4)) = ".KSF" Then
                    'it is as samplefile
                    key = Trim$(key)
                    Set m_CurKSFFile = m_KDoc.KorgSampleFile(key)
                    UpdateView
                Else
                    TxtInfo.Text = m_KDoc.KMPFileToString(Trim$(key))
                End If
            End If
        End If
    End With
End Sub

Private Sub mnuFileClose_Click()
    Unload Me
End Sub

Private Sub mnuFileSaveAllWav_Click()
    Dim KSF As KorgSampleFile
    Dim wav As WaveSound
    Dim FNam As String
    For Each KSF In m_KDoc.Samples
        With KSF
            FNam = .FileName & "_" & Trim(.SampleName) & ".wav"
            Set wav = KSF.Wave
            If Not wav Is Nothing Then
                Call wav.Save(FNam)
            End If
        End With
    Next
End Sub

Private Sub mnuFileSaveAsWav_Click()
    If Not m_CurKSFFile Is Nothing Then
        Dim FNam As String
        FNam = m_CurKSFFile.FileName & "_" & m_CurKSFFile.SampleName & ".wav"
        Call m_CurKSFFile.Wave.Save(FNam)
    End If
End Sub

Private Sub mnuViewDrawpoints_Click()
    mnuViewDrawpoints.Checked = Not mnuViewDrawpoints.Checked
    m_WaveView.DrawPoints = mnuViewDrawpoints.Checked
    UpdateView
End Sub

Private Sub OptInfo_Click()
    TxtInfo.ZOrder 0
    UpdateView
End Sub

Private Sub OptView_Click()
    PBWaveView.ZOrder 0
    UpdateView
End Sub

Private Sub UpdateView()
    If Not m_CurKSFFile Is Nothing Then
        If OptView.Value Then
            'Call m_CurKSFFile.Draw(Me.PBWaveView, mnuViewDrawpoints.Checked)
            Set m_WaveView.CurrentWave = m_CurKSFFile.Wave
            m_WaveView.DrawWave
        Else
            TxtInfo.Text = m_CurKSFFile.ToString
        End If
    End If
End Sub

