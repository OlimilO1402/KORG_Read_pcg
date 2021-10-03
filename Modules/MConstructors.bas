Attribute VB_Name = "MNew"
Option Explicit

Public Function KorgSampleFile(aKorgDoc As KorgDocument, _
                               Optional aFilename As String, _
                               Optional ByVal kmpIndex As Long, _
                               Optional ByVal rlpIndex As Long) As KorgSampleFile
    Set KorgSampleFile = New KorgSampleFile: KorgSampleFile.New_ aKorgDoc, aFilename, kmpIndex, rlpIndex
End Function

Public Function WaveSound(wavformat As WaveFormat) As WaveSound
    Set WaveSound = New WaveSound: WaveSound.New_ wavformat
End Function

Public Function WaveView(aPBView As PictureBox) As WaveView
    Set WaveView = New WaveView: WaveView.New_ aPBView
End Function

