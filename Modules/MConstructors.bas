Attribute VB_Name = "MConstructors"
Option Explicit

Public Function New_KorgSampleFile(aKorgDoc As KorgDocument, _
                                   Optional aFilename As String, _
                                   Optional ByVal kmpIndex As Long, _
                                   Optional ByVal rlpIndex As Long) As KorgSampleFile
    Set New_KorgSampleFile = New KorgSampleFile
    Call New_KorgSampleFile.NewC(aKorgDoc, aFilename, kmpIndex, rlpIndex)
End Function

Public Function New_WaveSound(wavformat As WaveFormat) As WaveSound
    Set New_WaveSound = New WaveSound
    Call New_WaveSound.NewC(wavformat)
End Function

Public Function New_WaveView(aPBView As PictureBox) As WaveView
    Set New_WaveView = New WaveView
    Call New_WaveView.NewC(aPBView)
End Function

