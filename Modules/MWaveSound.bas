Attribute VB_Name = "MWaveSound"
Option Explicit
Private Const WAVE_FORMAT_PCM As Integer = 1
Public Enum WAVEid
    RIFF = &H46464952 '  'RIFF'
    Wave = &H45564157 '  'WAVE'
    fmt_ = &H20746D66 '  'fmt ' last char is a space!
    data = &H61746164 '  'data'
    smpl = &H6C706D73 '  'smpl'
    inst = &H74736E69 '  'inst'
End Enum
Public Type WaveFormatShort
    FormatTag      As Integer 'PCM = 1
    nChannels      As Integer '1, 2, 3, 4, 5, 6, 7, 8
    SamplesPerSec  As Long    '11025, 22050, 44100
    AvgBytesPerSec As Long
    BlockAlign     As Integer
End Type
Public Type WaveFormat
    FormatTag      As Integer '
    nChannels      As Integer '1, 2, 3, 4, 5, 6, 7, 8 (exmpl: 8 = 7.1)
    SamplesPerSec  As Long    '11025, ..., 22050, ..., 44100, ..., 48000, ..., 96000, ...
    AvgBytesPerSec As Long    '
    BlockAlign     As Integer '
    BitsPerSample  As Integer '8, 16, 24
End Type
Public Type WaveFormatChunk
    ID(0 To 3)     As Byte 'WAVE
    Header         As ChunkHeader ' 'fmt ' + Size
    Format         As WaveFormat
End Type
Public Type WaveDataChunk
    Header As ChunkHeader
    data() As Byte
End Type

' #################### '    Samplerinstrument specific    ' #################### '
Public Enum LoopType
    LoopForward = 0      '(normal)
    LoopAlternating = 1  '(forward/backward, aka Ping Pong)
    LoopBackward = 2     '(reverse)
    'Reserved = 3..31    'for future standard types
End Enum
Public Type SampleLoop
    CuePointID As Long
    LoopType   As Long 'LoopType '0 - 0xFFFFFFFF
    LoopStart  As Long '0 - 0xFFFFFFFF
        'specifies the byte offset into the waveform data of the first sample to be played in the loop
    LoopEnd    As Long '0 - 0xFFFFFFFF
        'specifies the byte offset into the waveform data of the last  sample to be played in the loop
    Fraction   As Long '0 - 0xFFFFFFFF 'specifies a fraction of a sample at which to loop. This allows a loop to be fine tuned at a resolution greater than one sample
    PlayCount  As Long '0 - 0xFFFFFFFF 'A value of 0 specifies an infinite sustain loop
End Type

'0x00 4 Chunk ID "smpl" (0x736D706C)
'0x04 4 Chunk Data Size 36 + (Num Sample Loops * 24) + Sampler Data
'0x08 4 Manufacturer 0 - 0xFFFFFFFF
'0x0C 4 Product 0 - 0xFFFFFFFF
'0x10 4 Sample Period 0 - 0xFFFFFFFF
'0x14 4 MIDI Unity Note 0 - 127
'0x18 4 MIDI Pitch Fraction 0 - 0xFFFFFFFF
'0x1C 4 SMPTE Format 0, 24, 25, 29, 30
'0x20 4 SMPTE Offset 0 - 0xFFFFFFFF
'0x24 4 Num Sample Loops 0 - 0xFFFFFFFF
'0x28 4 Sampler Data 0 - 0xFFFFFFFF
'0x2C List of Sample Loops
Public Enum SMPTEFormat
    NoSMPTEOffset = 0
    FramesPerSecond24 = 24
    FramesPerSecond25 = 25
    FramesPerSecond29 = 29 '30 with frame dropping
    FramesPerSecond30 = 30
End Enum
Public Type SMPTEOffsetTime
'0xhhmmssff
    hh As Byte
    mm As Byte
    ss As Byte
    ff As Byte
End Type
Public Type WaveSamplerChunk
    Header            As ChunkHeader
    Manufacturer      As Long ' 0 - 0xFFFFFFFF
    Product           As Long ' 0 - 0xFFFFFFFF
    SamplePeriod      As Long ' 0 - 0xFFFFFFFF
    MIDIUnityNote     As Long ' 0 - 127
    MIDIPitchFraction As Long ' 0 - 0xFFFFFFFF
    SMPTEFormat       As Long ' 0, 24, 25, 29, 30
    SMPTEOffset       As SMPTEOffsetTime ' 0 - 0xFFFFFFFF
End Type
Public Type SampleLoopList
    NumSampleLoops    As Long ' 0 - 0xFFFFFFFF
    SamplerData       As Long ' 0 - 0xFFFFFFFF
    'the number of bytes that will follow this chunk (including the entire sample loop list).
    SampleLoops()     As SampleLoop
End Type
Public Type InstrumentFormatChunk
    Header        As ChunkHeader
    UnshiftedNote As Byte '0 - 127
    'the same meaning as the sampler chunk's MIDI Unity Note which specifies the
    'musical note at which the sample will be played at it's original sample rate
    '(the sample rate specified in the format chunk
    FineTune      As Byte ' - 50 - 50 (Cents)
    'specifies how much the sample's pitch should be altered when the sound is
    'played back in cents (1/100 of a semitone). A negative value means that the
    'pitch should be played lower and a positive value means that it should be
    'played at a higher pitch.
    Gain          As Byte '-64 - 64 (dB)
    'specifies the number of decibels to adjust the output when it is played.
    'A value of 0dB means no change, 6dB means double the amplitude of each sample
    'and -6dB means to halve the amplitude of each sample. Every additional +/-6dB
    'will double or halve the amplitude again.
    LowNote       As Byte '0 - 127
    HighNote      As Byte '0 - 127
    'The note fields specify the MIDI note range for which the waveform should be played
    'when receiving MIDI note events (from software or triggered by a MIDI controller).
    'This range does not need to include the Unshifted Note value
    LowVelocity   As Byte '1 - 127
    HighVelocity  As Byte '1 - 127
    'The velocity fields specify the range of MIDI velocities that should cause the
    'waveform sto be played. 1 being the lightest amount and 127 being the hardest.
End Type
Public Type TWaveSound
    RIFF    As ChunkHeader
    WAVEfmt As WaveFormatChunk
    data    As WaveDataChunk
    smpl    As WaveSamplerChunk
    loops   As SampleLoopList
    inst    As InstrumentFormatChunk
End Type

Public Function New_WaveFormat(ByVal nChannels As Byte, _
                               ByVal BitsPerSample As Byte, _
                               ByVal SampleRate As Long) As WaveFormat
    With New_WaveFormat
        .FormatTag = WAVE_FORMAT_PCM
        .nChannels = nChannels
        .SamplesPerSec = SampleRate
        .BitsPerSample = BitsPerSample
        .BlockAlign = .nChannels * .BitsPerSample \ 8
        .AvgBytesPerSec = .BlockAlign * .SamplesPerSec
    End With
End Function
Public Function New_WaveFormatChunk(wavformat As WaveFormat) As WaveFormatChunk
    With New_WaveFormatChunk
        Call LongToChunkID(WAVEid.Wave, .ID)
        .Format = wavformat
        .Header = New_ChunkHeader(WAVEid.fmt_, LenB(.Format))
    End With
End Function

