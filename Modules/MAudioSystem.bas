Attribute VB_Name = "MAudioSystem"
Option Explicit

Private Enum PlaySoundFlags
    SND_ALIAS_START = 0       '
    SND_SYNC = &H0            'The sound is played synchronously and the function does not return until the sound ends.
    SND_ASYNC = &H1           'The sound is played asynchronously and the function returns immediately after beginning the sound. To terminate an asynchronously played sound, call sndPlaySound with lpszSound set to NULL.
    SND_NODEFAULT = &H2       'If the sound cannot be found, the function returns silently without playing the default sound.
    SND_MEMORY = &H4          'The parameter specified by lpszSound points to an image of a waveform sound in memory. The data passed must be trusted by the application.
    SND_LOOP = &H8            'The sound plays repeatedly until sndPlaySound is called again with the lpszSound parameter set to NULL. You must also specify the SND_ASYNC flag to loop sounds.
    SND_NOSTOP = &H10         'If a sound is currently playing in the same process, the function immediately returns FALSE, without playing the requested sound.
    
    'Note: Requires Windows Vista or later.
    SND_SYSTEM                'If this flag is set then, the sound is assigned to the audio session for system notification sounds, else the sound is assigned to the default audio session for the application's process.
                              'The system volume-control program (SndVol) displays a volume slider that controls system notification sounds. Setting this flag puts the sound under the control of that volume slider
    SND_SENTRY                'If this flag is set, the function triggers a SoundSentry event when the sound is played. SoundSentry is an accessibility feature that causes the computer to display a visual cue when a
                              'sound is played. If the user did not enable SoundSentry, the visual cue is not displayed.
    
    SND_VALID = &H1F          '
    SND_PURGE = &H40          'Not supported.
    SND_APPLICATION = &H80    'The pszSound parameter is an application-specific alias in the registry. You can combine this flag with the SND_ALIAS or SND_ALIAS_ID flag to specify an application-defined sound alias.
    SND_NOWAIT = &H2000       'Not supported.
    SND_ALIAS = &H10000       'The pszSound parameter is a system-event alias in the registry or the WIN.INI file. Do not use with either SND_FILENAME or SND_RESOURCE.
    SND_FILENAME = &H20000    'The pszSound parameter is a file name. If the file cannot be found, the function plays the default sound unless the SND_NODEFAULT flag is set.
    SND_RESOURCE = &H40004    'The pszSound parameter is a resource identifier; hmod must identify the instance that contains the resource.
                              'For more information, see Playing WAVE Resources: https://docs.microsoft.com/de-de/windows/win32/multimedia/playing-wave-resources?redirectedfrom=MSDN
    SND_ALIAS_ID = &H110000   'The pszSound parameter is a predefined identifier for a system-event alias. See Remarks.
    SND_TYPE_MASK = &H170007  '
    SND_VALIDFLAGS = &H17201F '
    SND_RESERVED = &HFF000000 '
End Enum
Private Enum WinBOOL
    bFALSE = 0
    bTRUE = 1
End Enum

'https://docs.microsoft.com/en-us/previous-versions/dd798676(v=vs.85)
Private Declare Function sndPlaySoundW Lib "winmm" (ByVal lpSound As LongPtr, ByVal uFlags As PlaySoundFlags) As Long

'https://docs.microsoft.com/en-us/previous-versions/dd743680(v=vs.85)
Private Declare Function PlaySoundW Lib "winmm" (ByVal lpSound As LongPtr, ByVal hMod As Long, ByVal uFlags As PlaySoundFlags) As Long

Private Declare Function GetLastError Lib "kernel32.dll" () As Long

'Public Sub InitAudioSystem()
'    '
'End Sub
'
'Public Sub PlayWAVfile(ByVal aFilename As String)
'    Dim hr As Long: hr = PlaySoundFile(StrPtr(aFilename), 0, 0)
'End Sub
'
'Public Sub PlayWAV(aWav As WaveSound)
'    Dim hr As Long: hr = PlaySoundFile(aWav.pData, 0, 0)
'    'PlayWAVfile aWav.FileName
'End Sub

Public Sub Play(aSound)
    Dim ptr As LongPtr
    Dim flag As PlaySoundFlags: flag = PlaySoundFlags.SND_ASYNC
    Dim vt As VbVarType: vt = VarType(aSound)
    If vt = vbString Then
        flag = flag Or PlaySoundFlags.SND_FILENAME
        ptr = StrPtr(aSound)
    Else
        flag = flag Or PlaySoundFlags.SND_MEMORY
        If vt = vbLong Then
            ptr = CLngPtr(aSound)
        'ElseIf vt = vbLongPtr Then
        '    ptr = CLngPtr(aSound)
        Else
            ptr = DataPtr(SAPtr(VArrPtr(aSound)))
        End If
    End If
    
    'Dim b As WinBOOL: b = sndPlaySoundW(ptr, flag)
    Dim b As WinBOOL: b = PlaySoundW(ptr, 0, flag)
    
    If b Then Exit Sub
    Dim e As Long: e = Err.LastDllError
    If e = 0 Then e = GetLastError
    If e = 0 Then Exit Sub
    'MsgBox Err.Description
    MsgBox Hex(e)
End Sub

