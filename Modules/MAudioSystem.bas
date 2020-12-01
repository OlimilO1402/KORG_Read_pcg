Attribute VB_Name = "MAudioSystem"
Option Explicit
Private Declare Function sndPlaySound Lib "winmm.dll" Alias "sndPlaySoundA" ( _
    ByVal lpszSoundName As String, ByVal uFlags As Long) As Long
Private Declare Function PlaySoundFile Lib "winmm.dll" Alias "PlaySoundA" ( _
    ByVal lpszName As String, ByVal hModule As Long, ByVal dwFlags As Long) As Long

Public Sub InitAudioSystem()
    
End Sub

Public Sub PlayWAVfile(aFilename As String)
    Dim hr As Long: hr = PlaySoundFile(aFilename, 0, 0)
End Sub

Public Sub PlayWAV(aWav As WaveSound)
    
End Sub
