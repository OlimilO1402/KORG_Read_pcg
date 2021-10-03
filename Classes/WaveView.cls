VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "WaveView"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private WithEvents mPBView As PictureBox
Attribute mPBView.VB_VarHelpID = -1
Private m_Wave        As WaveSound
Private m_FirstSample As Long
Private m_ZoomStepX   As Long '= 0,1,2,4,8,16,32.. bis 1 sample = 10 Pixel
Private m_ZoomStepY   As Long '= 0,1,2,4,8,16,32.. bis 1 sample = 10 Pixel
Private m_bDrag       As Boolean 'for drawing a rubberband rectangle
Private m_bDrawPoints As Boolean
Private m_OldDrawMode As DrawModeConstants
Private m_P1X  As Single 'Startpoint
Private m_P1Y  As Single 'Startpoint
'Private m_P2X  As Single 'der alte Endpunkt
'Private m_P2Y  As Single 'der alte Endpunkt
Private m_Width  As Single
Private m_Height As Single
Private m_StartIndex As Long
Private m_Brdr As Long
'Private m_dx As Double
'Private m_dy As Double

Private Sub Class_Initialize()
    m_Brdr = 8
End Sub

Friend Sub New_(aPBView As PictureBox)
    Set mPBView = aPBView
    mPBView.AutoRedraw = True
End Sub

Public Property Get CurrentWave() As WaveSound
    Set CurrentWave = m_Wave
End Property
Public Property Set CurrentWave(RHS As WaveSound)
    Set m_Wave = RHS
    ClearZoom
    'auch gleich neuzeichnen
    Call DrawWave
End Property
Private Sub ClearZoom()
    m_P1X = 0
    m_P1Y = 0
    m_Width = 0
    m_Height = 0
    m_StartIndex = 0
End Sub
Public Property Get DrawPoints() As Boolean
    DrawPoints = m_bDrawPoints
End Property
Public Property Let DrawPoints(RHS As Boolean)
    m_bDrawPoints = RHS
End Property

Public Property Get Width() As Single
    Width = m_Width 'm_P2X - m_P1X
    If Width <= 0 Then
        Width = mPBView.ScaleWidth
    End If
End Property
Public Property Get Height() As Single
    Height = m_Height 'm_P2Y - m_P1Y
    If Height <= 0 Then
        Height = mPBView.ScaleHeight
    End If
End Property

' #################### '    Rubberband Rectangle    ' #################### '
Private Sub mPBView_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    m_bDrag = (Button = vbLeftButton)
    If m_bDrag Then
        m_P1X = X:   m_P1Y = Y
        'm_P2X = X:   m_P2Y = Y
        m_Width = 0: m_Height = 0
    End If
End Sub
Private Sub mPBView_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    If m_bDrag Then
        ToggleDrawModeInvert
        'delete by drawing over with invert pen
        'mPBView.Line (m_P1X, m_P1Y)-(m_P2X, m_P2Y), , B
        mPBView.Line (m_P1X, m_P1Y)-(m_P1X + m_Width, m_P1Y + m_Height), , B
        'draw new with invert pen
        'm_P2X = X: m_P2Y = Y
        m_Width = X - m_P1X:        m_Height = Y - m_P1Y
        'mPBView.Line (m_P1X, m_P1Y)-(m_P2X, m_P2Y), , B
        mPBView.Line (m_P1X, m_P1Y)-(m_P1X + m_Width, m_P1Y + m_Height), , B
        ToggleDrawModeInvert
    End If
End Sub
Private Sub mPBView_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
    If Button = vbLeftButton Then
        If m_bDrag Then
            m_bDrag = False
            'delete old rectangle by drawing over
            ToggleDrawModeInvert
            'mPBView.Line (m_P1X, m_P1Y)-(m_P2X, m_P2Y), , B
            mPBView.Line (m_P1X, m_P1Y)-(m_P1X + m_Width, m_P1Y + m_Height), , B
            'm_OldX = 0:        m_OldY = 0
            ToggleDrawModeInvert
            Call DrawWave
        End If
    ElseIf Button = vbRightButton Then
        'Zoom zurücksetzen
        m_P1X = 0:   m_P1Y = 0
        m_Width = 0: m_Height = 0
        m_StartIndex = 0
        Call DrawWave
    End If
End Sub
Private Sub ToggleDrawModeInvert()
    If mPBView.DrawMode = DrawModeConstants.vbInvert Then
        mPBView.DrawMode = m_OldDrawMode
    Else
        m_OldDrawMode = mPBView.DrawMode
        mPBView.DrawMode = DrawModeConstants.vbInvert
    End If
End Sub

' #################### '    DrawWave    ' #################### '
Public Sub DrawWave()
    mPBView.ScaleMode = vbPixels
    Dim stp As Long:  stp = m_Wave.WaveFormat.BitsPerSample / 8
    Dim u   As Long:    u = m_Wave.WaveDataByteLength - 1
    Dim dx  As Single: dx = (mPBView.ScaleWidth - m_Brdr) / (u / stp) * mPBView.ScaleWidth / Me.Width
    Dim dy  As Single: 'dy = (Me.Height - m_Brdr) / (2 ^ (stp * 8))
                       dy = (mPBView.ScaleHeight - m_Brdr) / (2 ^ (stp * 8))
    'm_StartIndex = m_StartIndex
    m_StartIndex = m_StartIndex + ((u + 1) / stp) * m_P1X / (mPBView.ScaleWidth - m_Brdr)
    Call m_Wave.Draw(mPBView, Me.DrawPoints, m_StartIndex, m_Brdr, dx, dy)
End Sub
