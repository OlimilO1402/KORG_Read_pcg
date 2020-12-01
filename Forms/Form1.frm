VERSION 5.00
Begin VB.Form Form1 
   AutoRedraw      =   -1  'True
   Caption         =   "TR Reader"
   ClientHeight    =   6015
   ClientLeft      =   165
   ClientTop       =   855
   ClientWidth     =   7575
   Icon            =   "Form1.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   401
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   505
   StartUpPosition =   3  'Windows-Standard
   Begin VB.TextBox TxtFileName 
      Height          =   285
      Left            =   120
      OLEDragMode     =   1  'Automatisch
      OLEDropMode     =   1  'Manuell
      TabIndex        =   1
      Top             =   120
      Width           =   6375
   End
   Begin VB.TextBox TxtFileContent 
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   5415
      Left            =   120
      MultiLine       =   -1  'True
      OLEDragMode     =   1  'Automatisch
      OLEDropMode     =   1  'Manuell
      ScrollBars      =   3  'Beides
      TabIndex        =   0
      Top             =   480
      Width           =   6375
   End
   Begin VB.Menu mnuFile 
      Caption         =   "&File"
      Begin VB.Menu mnuFileOpen 
         Caption         =   "&Open..."
      End
      Begin VB.Menu mnuFileSep 
         Caption         =   "-"
      End
      Begin VB.Menu mnuFileExit 
         Caption         =   "E&xit"
      End
   End
   Begin VB.Menu mnuView 
      Caption         =   "&View"
      Begin VB.Menu mnuViewShowSamples 
         Caption         =   "Show Samples"
      End
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private m_KORGDoc As KorgDocument

Private Sub Form_Load()
    Me.ScaleMode = vbPixels
    mnuViewShowSamples.Enabled = False
End Sub

Private Sub Form_Resize()
    Dim l As Single, T As Single, W As Single, H As Single
    Dim brdr As Single: brdr = 8
    l = brdr:     T = TxtFileContent.Top
    W = Me.ScaleWidth - brdr - l
    H = Me.ScaleHeight - brdr - T
    If W > 0 And H > 0 Then
        TxtFileName.Width = W
        Call TxtFileContent.Move(l, T, W, H)
    End If
End Sub

Private Sub mnuFileOpen_Click()
    With New OpenFileDialog
        .Filter = "KORG Program Combi Groups [*.pcg]" & "|*.pcg" & _
            "|" & "KORG script file [*.ksc]" & "|*.ksc" & _
            "|" & "KORG Multisample params [*.kmp]" & "|*.kmp" & _
            "|" & "KORG Sample File [*.ksf]" & "|*.ksf" & _
            "|" & "All Files [*.*]" & "|*.*"
        Dim p As String
        If Not m_KORGDoc Is Nothing Then p = m_KORGDoc.FileName
        If Len(p) = 0 Then p = App.Path
        .InitialDirectory = p
        If .ShowDialog(Me) = DialogResult_OK Then
            TxtFileName.Text = .FileName
            Call OpenKorgFile(TxtFileName.Text)
        End If
    End With
End Sub
Private Sub mnuFileExit_Click()
    Dim frm As Form
    For Each frm In VB.Forms
        Unload frm
    Next
End Sub
Private Sub mnuViewShowSamples_Click()
    If Not m_KORGDoc Is Nothing Then
        Call Form2.ShowModal(m_KORGDoc, Me)
    End If
End Sub

Private Sub TxtFileName_KeyUp(KeyCode As Integer, Shift As Integer)
    If KeyCode = KeyCodeConstants.vbKeyReturn Then
        Call OpenKorgFile(TxtFileName.Text)
    End If
End Sub
Private Sub TxtFileName_OLEDragDrop(data As DataObject, Effect As Long, Button As Integer, Shift As Integer, X As Single, Y As Single)
    If data.GetFormat(vbCFFiles) Then
        TxtFileName.Text = data.Files(1)
        Call OpenKorgFile(TxtFileName.Text)
    End If
End Sub
Private Sub TxtFileContent_OLEDragDrop(data As DataObject, Effect As Long, Button As Integer, Shift As Integer, X As Single, Y As Single)
    If data.GetFormat(vbCFFiles) Then
        TxtFileName.Text = data.Files(1)
        Call OpenKorgFile(TxtFileName.Text)
    End If
End Sub

Private Sub OpenKorgFile(aFnm As String)
    Set m_KORGDoc = New KorgDocument
    Call m_KORGDoc.Load(aFnm)
    TxtFileContent.Text = m_KORGDoc.ToString
    If m_KORGDoc.CountKorgSampleFiles > 0 Then
        mnuViewShowSamples.Enabled = True
    End If
End Sub

