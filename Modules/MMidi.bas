Attribute VB_Name = "MMidi"
Option Explicit

'Midi Manufacturers Assiciation IDs
Public Enum MMAid
    Unknown = 0             '(0x00)
    Sequential_Circuits = 1 '(0x01)
    Big_Briar = 2           '(0x02)
    Octave_Plateau = 3      '(0x03)
    Moog = 4                '(0x04)
    Passport_Designs = 5    '(0x05)
    Lexicon = 6             '(0x06)
    Kurzweil = 7            '(0x07)
    Fender = 8              '(0x08)
    Gulbransen = 9          '(0x09)
    Delta_Labs = 10         '(0x0A)
    Sound_Comp = 11         '(0x0B)
    General_Electro = 12    '(0x0C)
    Techmar = 13            '(0x0D)
    Matthews_Research = 14  '(0x0E)
    Oberheim = 16           '(0x10)
    PAIA = 17               '(0x11)
    Simmons = 18            '(0x12)
    DigiDesign = 19         '(0x13)
    Fairlight = 20          '(0x14)
    JL_Cooper = 21          '(0x15)
    Lowery = 22             '(0x16)
    Lin = 23                '(0x17)
    Emu = 24                '(0x18)
    Peavey = 27             '(0x1B)
    Bon_Tempi = 32          '(0x20)
    S_I_E_L = 33            '(0x21)
    SyntheAxe = 35          '(0x23)
    Hohner = 36             '(0x24)
    Crumar = 37             '(0x25)
    Solton = 38             '(0x26)
    Jellinghaus_Ms = 39     '(0x27)
    CTS = 40                '(0x28)
    PPG = 41                '(0x29)
    Elka = 47               '(0x2F)
    Cheetah = 54            '(0x36)
    Waldorf = 62            '(0x3E)
    Kawai = 64              '(0x40)
    Roland = 65             '(0x41)
    Korg = 66               '(0x42)
    Yamaha = 67             '(0x43)
    Casio = 68              '(0x44)
    Kamiya_Studio = 70      '(0x46)
    Akai = 71               '(0x47)
    Victor = 72             '(0x48)
    Fujitsu = 75            '(0x4B)
    Sony = 76               '(0x4C)
    Teac = 78               '(0x4E)
    Matsushita = 80         '(0x50)
    Fostex = 81             '(0x51)
    Zoom = 82               '(0x52)
    'Matsushita = 84         '(0x54) 'Oops why twice?
    Suzuki = 85             '(0x55)
    Fuji_Sound = 86         '(0x56)
    Acoustic_Technical_Laboratory = 87 '(0x57)
    
End Enum
Private Type EnumMMAid
    Names() As String
    Values  As Collection
End Type
Public EnumMMAid As EnumMMAid
Private m_MidiKeyNames() As String

Public Sub InitMidi()
    Call InitMMAid
    Call InitMidiKeys
    'could now also read from the file ManufacturersIDs.ini
End Sub
Private Sub InitMMAid()
    Dim i As Long
    With EnumMMAid
        ReDim .Names(0 To 87)
        Set .Values = New Collection
        .Names(i) = "Unknown":              Call .Values.Add(i, .Names(i)): i = i + 1 '(0x00)
        .Names(i) = "Sequential Circuits":  Call .Values.Add(i, .Names(i)): i = i + 1 '(0x01)
        .Names(i) = "Big Briar":            Call .Values.Add(i, .Names(i)): i = i + 1 '(0x02)
        .Names(i) = "Octave Plateau":       Call .Values.Add(i, .Names(i)): i = i + 1 '(0x03)
        .Names(i) = "Moog":                 Call .Values.Add(i, .Names(i)): i = i + 1 '(0x04)
        .Names(i) = "Passport Designs"::    Call .Values.Add(i, .Names(i)): i = i + 1 '(0x05)
        .Names(i) = "Lexicon":              Call .Values.Add(i, .Names(i)): i = i + 1 '(0x06)
        .Names(i) = "Kurzweil":             Call .Values.Add(i, .Names(i)): i = i + 1 '(0x07)
        .Names(i) = "Fender":               Call .Values.Add(i, .Names(i)): i = i + 1 '(0x08)
        .Names(i) = "Gulbransen":           Call .Values.Add(i, .Names(i)): i = i + 1 '(0x09)
        .Names(i) = "Delta Labs":           Call .Values.Add(i, .Names(i)): i = i + 1 '(0x0A)
        .Names(i) = "Sound Comp":           Call .Values.Add(i, .Names(i)): i = i + 1 '(0x0B)
        .Names(i) = "General Electro":      Call .Values.Add(i, .Names(i)): i = i + 1 '(0x0C)
        .Names(i) = "Techmar":              Call .Values.Add(i, .Names(i)): i = i + 1 '(0x0D)
        .Names(i) = "Matthews Research":    Call .Values.Add(i, .Names(i)): i = i + 1 '(0x0E)
        i = i + 1
        .Names(i) = "Oberheim":             Call .Values.Add(i, .Names(i)): i = i + 1 '(0x10)
        .Names(i) = "PAIA":                 Call .Values.Add(i, .Names(i)): i = i + 1 '(0x11)
        .Names(i) = "Simmons":              Call .Values.Add(i, .Names(i)): i = i + 1 '(0x12)
        .Names(i) = "DigiDesign":           Call .Values.Add(i, .Names(i)): i = i + 1 '(0x13)
        .Names(i) = "Fairlight":            Call .Values.Add(i, .Names(i)): i = i + 1 '(0x14)
        .Names(i) = "JL Cooper":            Call .Values.Add(i, .Names(i)): i = i + 1 '(0x15)
        .Names(i) = "Lowery":               Call .Values.Add(i, .Names(i)): i = i + 1 '(0x16)
        .Names(i) = "Lin":                  Call .Values.Add(i, .Names(i)): i = i + 1 '(0x17)
        .Names(i) = "Emu":                  Call .Values.Add(i, .Names(i)): i = i + 1 '(0x18)
        i = i + 2
        .Names(i) = "Peavey":               Call .Values.Add(i, .Names(i)): i = i + 1 '(0x1B)
        i = i + 4
        .Names(i) = "Bon Tempi":            Call .Values.Add(i, .Names(i)): i = i + 1 '(0x20)
        .Names(i) = "S.I.E.L.":             Call .Values.Add(i, .Names(i)): i = i + 1 '(0x21)
        i = i + 1
        .Names(i) = "SyntheAxe":            Call .Values.Add(i, .Names(i)): i = i + 1 '(0x23)
        .Names(i) = "Hohner":               Call .Values.Add(i, .Names(i)): i = i + 1 '(0x24)
        .Names(i) = "Crumar":               Call .Values.Add(i, .Names(i)): i = i + 1 '(0x25)
        .Names(i) = "Solton":               Call .Values.Add(i, .Names(i)): i = i + 1 '(0x26)
        .Names(i) = "Jellinghaus Ms":       Call .Values.Add(i, .Names(i)): i = i + 1 '(0x27)
        .Names(i) = "CTS":                  Call .Values.Add(i, .Names(i)): i = i + 1 '(0x28)
        .Names(i) = "PPG":                  Call .Values.Add(i, .Names(i)): i = i + 1 '(0x29)
        i = i + 5
        .Names(i) = "Elka":                 Call .Values.Add(i, .Names(i)): i = i + 1 '(0x2F)
        i = i + 6
        .Names(i) = "Cheetah":              Call .Values.Add(i, .Names(i)): i = i + 1 '(0x36)
        i = i + 7
        .Names(i) = "Waldorf":              Call .Values.Add(i, .Names(i)): i = i + 1 '(0x3E)
        i = i + 1
        .Names(i) = "Kawai":                Call .Values.Add(i, .Names(i)): i = i + 1 '(0x40)
        .Names(i) = "Roland":               Call .Values.Add(i, .Names(i)): i = i + 1 '(0x41)
        .Names(i) = "Korg":                 Call .Values.Add(i, .Names(i)): i = i + 1 '(0x42)
        .Names(i) = "Yamaha":               Call .Values.Add(i, .Names(i)): i = i + 1 '(0x43)
        .Names(i) = "Casio":                Call .Values.Add(i, .Names(i)): i = i + 1 '(0x44)
        i = i + 1
        .Names(i) = "Kamiya_Studio":        Call .Values.Add(i, .Names(i)): i = i + 1 '(0x46)
        .Names(i) = "Akai":                 Call .Values.Add(i, .Names(i)): i = i + 1 '(0x47)
        .Names(i) = "Victor":               Call .Values.Add(i, .Names(i)): i = i + 1 '(0x48)
        i = i + 2
        .Names(i) = "Fujitsu":             Call .Values.Add(i, .Names(i)): i = i + 1 '(0x4B)
        .Names(i) = "Sony":                 Call .Values.Add(i, .Names(i)): i = i + 1 '(0x4C)
        i = i + 1 '77
        .Names(i) = "Teac":                Call .Values.Add(i, .Names(i)): i = i + 1 '(0x4E)
        i = i + 1 '79
        .Names(i) = "Matsushita":          Call .Values.Add(i, .Names(i)): i = i + 1 '(0x50)
        .Names(i) = "Fostex":              Call .Values.Add(i, .Names(i)): i = i + 1 '(0x51)
        .Names(i) = "Zoom ":               Call .Values.Add(i, .Names(i)): i = i + 1 '(0x52)
        '83
        'Matsushita = 84         '(0x54) 'Oops why twice?
        i = i + 2
        .Names(i) = "Suzuki":              Call .Values.Add(i, .Names(i)): i = i + 1 '(0x55)
        .Names(i) = "Fuji_Sound":          Call .Values.Add(i, .Names(i)): i = i + 1 '(0x56)
        .Names(i) = "Acoustic_Technical_Laboratory": Call .Values.Add(i, .Names(i)): i = i + 1 '(0x57)
        'for debugging
        'For i = 0 To 87
        '    If Len(.Names(i)) > 0 Then
        '        Debug.Print "    " & .Names(i) & " = " & CStr(.Values(.Names(i))) & " ' " & Hex$(.Values(.Names(i)))
        '    End If
        'Next
    End With
End Sub
Private Sub InitMidiKeys()
    Dim i As Long
    ReDim m_MidiKeyNames(0 To 12)
    m_MidiKeyNames(i) = "C": i = i + 1
    m_MidiKeyNames(i) = "C#": i = i + 1
    m_MidiKeyNames(i) = "D": i = i + 1
    m_MidiKeyNames(i) = "D#": i = i + 1
    m_MidiKeyNames(i) = "E": i = i + 1
    m_MidiKeyNames(i) = "F": i = i + 1
    m_MidiKeyNames(i) = "F#": i = i + 1
    m_MidiKeyNames(i) = "G": i = i + 1
    m_MidiKeyNames(i) = "G#": i = i + 1
    m_MidiKeyNames(i) = "A": i = i + 1
    m_MidiKeyNames(i) = "A#": i = i + 1
    'm_MidiKeyNames(i) = "H": i = i + 1
    m_MidiKeyNames(i) = "B": i = i + 1
End Sub
Public Function MidiKeyToString(ByVal aKey As Byte) As String
    '0 = "C-2"
    '1 = "C#-2"
    '60 = "C3'
    Dim s As String
    s = m_MidiKeyNames((aKey) Mod 12)
    s = s & CStr((aKey \ 12)) '- 2) 'wirklich -2 ???
    MidiKeyToString = s
End Function
