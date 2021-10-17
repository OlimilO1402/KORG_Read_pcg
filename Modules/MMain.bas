Attribute VB_Name = "MMain"
Option Explicit
Private Declare Sub InitCommonControls Lib "comctl32.dll" ()

Public Sub Main()
    'MAudioSystem.InitAudioSystem
    MMidi.InitMidi
    Call InitCommonControls
    Form1.Show
End Sub
