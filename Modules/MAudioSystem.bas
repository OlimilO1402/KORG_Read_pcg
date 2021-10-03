Attribute VB_Name = "MAudioSystem"
Option Explicit
#If VBA7 <> 1 Then
Public Enum LongPtr
    [_]
End Enum
#End If
Private Declare Function sndPlaySound Lib "winmm" Alias "sndPlaySoundW" ( _
    ByVal lpszSoundName As LongPtr, ByVal uFlags As Long) As Long
Private Declare Function PlaySoundFile Lib "winmm" Alias "PlaySoundA" ( _
    ByVal lpszName As LongPtr, ByVal hModule As Long, ByVal dwFlags As Long) As Long

Public Sub InitAudioSystem()
    '
End Sub

Public Sub PlayWAVfile(ByVal aFilename As String)
    Dim hr As Long: hr = PlaySoundFile(StrPtr(aFilename), 0, 0)
End Sub

Public Sub PlayWAV(aWav As WaveSound)
    'Dim hr As Long: hr = PlaySoundFile(aWav.pData, 0, 0)
    PlayWAVfile aWav.FileName
End Sub
