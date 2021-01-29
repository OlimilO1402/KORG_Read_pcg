VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   6015
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   6585
   LinkTopic       =   "Form1"
   ScaleHeight     =   6015
   ScaleWidth      =   6585
   StartUpPosition =   3  'Windows-Standard
   Begin VB.TextBox Text2 
      Height          =   285
      Left            =   120
      OLEDragMode     =   1  'Automatisch
      OLEDropMode     =   1  'Manuell
      TabIndex        =   1
      Top             =   120
      Width           =   6375
   End
   Begin VB.TextBox Text1 
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
      ScrollBars      =   3  'Beides
      TabIndex        =   0
      Top             =   480
      Width           =   6375
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private m_pcgfilename As String
Private m_PCGFile As PCGFile

Private Sub Form_Load()
    Me.ScaleMode = vbPixels
    'm_pcgfilename = "D:\Inet_Download\KORGForums\guitar\GUITAR.pcg"
    'm_pcgfilename = "D:\Inet_Download\KORGForums\EnigmaFlute\ENIMGA.PCG"
    'm_pcgfilename = "D:\Inet_Download\KORGForums\orchestral\ORCH.PCG"
    'm_pcgfilename = "D:\Inet_Download\KORGForums\real-kit\KIT.PCG"
    'm_pcgfilename = "D:\Inet_Download\KORGForums\real-kit\KIT.PCG"
    'm_pcgfilename = "D:\Inet_Download\KORG\Triton_PCG-Files\rose\ROSE.PCG"
    'm_pcgfilename = "D:\Inet_Download\KORG\Triton_PCG-Files\rose2\ROSE2.PCG"
    'm_pcgfilename = "D:\Inet_Download\KORG\Triton_PCG-Files\rose3\ROSE3.PCG"
    'm_pcgfilename = "D:\Inet_Download\KORG\Triton_PCG-Files\rose4\ROSE4.PCG"
    'm_pcgfilename = "D:\Inet_Download\KORG\Triton_PCG-Files\rose5\ROSEV.PCG"
    'm_pcgfilename = "D:\Inet_Download\KORG\Triton_PCG-Files\rose-acoustica\RoseAco.PCG"
    Text2.Text = App.Path & "\" & "GUITAR.PCG"
    'Call MPCGFile.Load(m_PCGFile, m_pcgfilename)
    'Text1.Text = MPCGFile.PCGFileToString(m_PCGFile)
    
End Sub

Private Sub Form_Resize()
    Dim L As Single, T As Single, W As Single, H As Single
    Dim brdr As Single: brdr = 8
    L = brdr:     T = Text1.Top
    W = Me.ScaleWidth - brdr - L
    H = Me.ScaleHeight - brdr - T
    If W > 0 And H > 0 Then
        Text2.Width = W
        Call Text1.Move(L, T, W, H)
    End If
End Sub

Private Sub Text2_KeyUp(KeyCode As Integer, Shift As Integer)
    If KeyCode = 13 Then
        m_pcgfilename = Text2.Text
        Call MPCGFile.Load(m_PCGFile, m_pcgfilename)
        Text1.Text = m_pcgfilename & vbCrLf & _
            MPCGFile.PCGFileToString(m_PCGFile)
    End If
End Sub

Private Sub Text2_OLEDragDrop(Data As DataObject, Effect As Long, Button As Integer, Shift As Integer, X As Single, Y As Single)
    If Data.GetFormat(vbCFFiles) Then
        Text2.Text = Data.Files(1)
    End If
End Sub
