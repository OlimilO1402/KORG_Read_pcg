Attribute VB_Name = "MPCGFile"
Option Explicit
'File Descriptions from
' http://www.karma-lab.com/karma/KARMA_Docs.html
'
'  PCG 's header
'    KORG ID          'KORG'  [4byte]
'    Product ID        0x50   [1byte]
'    File type         0x00   [1byte]
'    Major version     0x00   [1byte]
'    Minor version     0x01   [1byte]
'    Product Sub ID    0x01   [1byte] *11 ###NEW to Triton Extreme
'    Padding           0x00   [7byte]
Public Type PCGFileHeader
    KORGID(0 To 3) As Byte   '[4byte]
    ProductID      As Byte   '[1byte]
    FileType       As Byte   '[1byte] 'PCGFileType
    MajorVer       As Byte   '[1byte]
    MinorVer       As Byte   '[1byte]
    ProductSubID   As Byte   '[1byte]
    PadByte1       As Byte   '[1byte]
    PadByte2       As Byte   '[1byte]
    PadByte3       As Byte   '[1byte]
    PadByte4       As Byte   '[1byte]
    PadByte5       As Byte   '[1byte]
    PadByte6       As Byte   '[1byte]
    PadByte7       As Byte   '[1byte]
End Type                     'Sum: 16
Public Enum PCGFileType
    filetypePCG
    filetypeSNG 'Songfile
    filetypeEXL 'Midi Exclusive
End Enum
'
'  PCG chunk
'    chunk ID    'PCG1'  [4byte]
'    size of Chunk     [4byte] (Programs/Combinations...Global)
'Public Type PCGchunk
'    ChunkID(0 To 3) As Byte
'    ChunkSize       As Long
'End Type
Public Type ChunkHeader
    ChunkID(0 To 3) As Byte
    ChunkSize       As Long
End Type
Public Type BankHeader
    NumOfElem As Long
    SizeOfOne As Long
    BankID    As Long
End Type
Public Type BankChunk
    Header As ChunkHeader
    bank   As BankHeader
End Type
Public Type DataEntry
    '????
    'wie ist BankData aufgebaut?
    NName(0 To 15) As Byte
    data() As Byte
End Type
'    Banks()   As BankData
'End Type
'
'  program chunk
'    chunk ID    'PRG1'  [4byte]
'    size of Chunk     [4byte]
'Public Type ProgramChunk
'    ChunkID(0 To 3) As Byte
'    ChunkSize       As Long
'End Type

'  Program bank chunk
'    chunk ID    'PBK1'  [4byte] (Bank F = 'MBK1', for MOSS Program)
'    size of Chunk       [4byte]
'
'    num of program      [4byte]
'    size of a program   [4byte]
'    bank ID             [4byte] *1
'    program bank data   [variable]
'Public Type ProgramBankChunk
'    Header As ChunkHeader
'    Bank   As BankHeader
'End Type

'    Program V2 Parameters chunk                   <---new
'        Chunk ID        'PV2P'   [4byte]
'        size of Chunk            [4byte]
'
'    Program bank V2 Parameters chunk              <---new
'        Chunk ID        'PV2B'   [4byte]
'        size of Chunk            [4byte]   0x0000040C (1036)
'
'        num of program           [4byte]   0x00000080 (128)
'        size of V2 param         [4byte]   0x00000008 (  8)
'        bank ID                  [4byte]         *2
'        Program bank V2 param    [8 * 128 byte]  *11

'
'  combination chunk
'    chunk ID    'CMB1'  [4byte]
'    size of Chunk     [4byte]
'Public Type CombinationChunk
'    ChunkID(0 To 3) As Byte
'    ChunkSize       As Long
'End Type
'
'  Combination bank chunk
'    chunk ID    'CBK1'    [4byte]
'    size of Chunk         [4byte]
'
'    num of combination    [4byte]
'    size of a combination [4byte]
'    bank ID               [4byte] *2
'    combination bank data [variable]
'Public Type CombinationBankChunk
'    Header As ChunkHeader
'    Bank   As BankHeader
'End Type

'    Combination V2 Parameters chunk                  <---new
'        Chunk ID        'CV2P'   [4byte]
'        size of Chunk            [4byte]
'
'    Combination bank V2 Parameters chunk             <---new
'        Chunk ID        'CV2B'   [4byte]
'        size of Chunk            [4byte]   0x00000D0C (3340)
'
'        num of combination       [4byte]   0x00000080 (128)
'        size of V2 param         [4byte]   0x0000001A ( 26)
'        bank ID                  [4byte] (Bank A:0/B:1/C:2...)
'        Combination bank V2 param[26 * 128 byte] *12

'
'  drumkit chunk
'    chunk ID    'DKT1'  [4byte]
'    size of Chunk     [4byte]
'Public Type DrumkitChunk
'    ChunkID(0 To 3) As Byte
'    ChunkSize       As Long
'End Type
'
'  Drumkit bank chunk
'    chunk ID    'DBK1'  [4byte]
'    size of Chunk     [4byte]
'
'    num of drumkit      [4byte]
'    size of a drumkit   [4byte]
'    bank ID       [4byte] *3
'    drumkit bank data   [variable]
'Public Type DrumkitBankChunk
'    Header As ChunkHeader
'    Bank   As BankHeader
'End Type
'
'  Arpeggio chunk
'    chunk ID    'ARP1'  [4byte]
'    size of Chunk     [4byte]
'Public Type ArpeggioChunk
'    ChunkID(0 To 3) As Byte
'    ChunkSize       As Long
'End Type
'
'  Arpeggio bank chunk
'    chunk ID    'ABK1'  [4byte]
'    size of Chunk     [4byte]
'
'    num of arpp     [4byte]
'    size of a arpp      [4byte]
'    bank ID       [4byte] *4
'    arpp bank data      [variable]
'Public Type ArpeggioBankChunk
'    Header As ChunkHeader
'    Bank   As BankHeader
'End Type
'
'  Global chunk
'    chunk ID    'GLB1'  [4byte]
'    size of Chunk     [4byte] sizeof (CGlobal) ????
'    global setting data   [sizeof(CGlobal)]    ????
Public Type GlobalSetting
    data() As Byte
End Type

'
'  Divided File chunk
'    chunk ID    'DIV1'  [4byte]
'    size of Chunk     [4byte]
'
'    status            [2byte] 0:Undivided/1:Divided
'    random ID         [2byte]
'
'    program info      [2byte] *5
'    num of progbank   [2byte] *5
'    reserved [4byte]

'*5(Saved program's information)
' The item doesn't exist if bit is 0
' Bit  0  bank A
'      :       :
'      5       F
'      6       ExbA
'      :        :
'     13       ExbH
' num of progbank = 14


'    combination info  [2byte] *6
'    num of combibank  [2byte] *6
'    reserved [4byte]

'*6(Saved combination's information)
' The item doesn't exist if bit is 0
' Bit  0  bank A
'      :       :
'      4       F
'      7       ExbA
'      :        :
'     12       ExbH
' num of combibank = 13


'    drumkit info      [2byte] *7
'    num of dkitbank   [2byte] *7
'    reserved [4byte]

'*7(Saved drumkit's information)
' The item doesn't exist if bit is 0
' Bit  0  bank A/B
'      1       ExbA
'      :        :
'      8       ExbH
' num of dkitbank = 9


'    arpp info         [2byte] *8
'    num of arpp       [2byte] *8
'    reserved [4byte]



'    global info     [4byte] *9
'    reserved [4byte]
Public Type DividedFileInfo
    Info      As Integer
    NumOfElem As Integer
    Reserved  As Long
End Type
Public Type DividedFileHeaderChunk
    status      As Integer
    randomID    As Integer
    
    ProgramInfo As DividedFileInfo
    CombiInfo   As DividedFileInfo
    DrumkitInfo As DividedFileInfo
    ArppInfo    As DividedFileInfo
    GlobalInfo  As DividedFileInfo
End Type
Public Enum BankInfo
    
    Bank_A = &H1        'Bit 0
    Bank_B = &H2        'Bit 1
    Bank_C = &H4        'Bit 2
    Bank_D = &H8        'Bit 3
    Bank_E = &H10       'Bit 4
    Bank_F = &H20       'Bit 5
    Bank_01 = &H40      'Bit 6
    Bank_02 = &H80      'Bit 7
    
    Bank_ExbA = &H100   'Bit 8
    Bank_ExbB = &H200   'Bit 9
    Bank_ExbC = &H400   'Bit 10
    Bank_ExbD = &H800   'Bit 11
    Bank_ExbE = &H1000  'Bit 12
    Bank_ExbF = &H2000  'Bit 13
    Bank_ExbG = &H4000  'Bit 14
    Bank_ExbH = &H8000  'Bit 15
    
End Enum
'
'  Item Name 's Information chunk
'    chunk ID    'INI1'  [4byte]
'    size of Chunk       [4byte] *10 variable
'
'    num of items        [4byte] *10 variable
'      1st Item 's chunk ID  [4byte] *10
'      1st Item 's bank ID   [4byte] *10
'      1st Item 's name      [20byte] *10
'             :
'      Nth Item 's chunk ID  [4byte] *10
'      Nth Item 's bank ID   [4byte] *10
'      Nth Item 's name      [20byte] *10
Public Type ItemNameInfo
    ChunkID(0 To 3)  As Byte
    BankID   As Long
    ItemName(0 To 19) As Byte
End Type
Public Type ItemInfoChunk
    NumOfItems As Long
    Names() As ItemNameInfo
End Type

Public Enum PCGID
    Korg = &H47524F4B '  'KORG'
    PCG1 = &H31474350 '  'PCG1'
    
    PRG1 = &H31475250 '  'PRG1'
    PBK1 = &H314B4250 '  'PBK1'
    
    PV2P = &H50325650 '  'PV2P'
    PV2B = &H42325650 '  'PV2B'
    
    MBK1 = &H314B424D '  'MBK1' 'Moss Bank
    
    CMB1 = &H31424D43 '  'CMB1'
    CBK1 = &H314B4243 '  'CBK1'
    
    CV2P = &H50325643 '  'CV2P'
    CV2B = &H42325643 '  'CV2B'
    
    DKT1 = &H31544B44 '  'DKT1'
    DBK1 = &H314B4244 '  'DBK1'
    
    ARP1 = &H31505241 '  'ARP1'
    ABK1 = &H314B4241 '  'ABK1'
    
    GLB1 = &H31424C47 '  'GLB1'
    
    DIV1 = &H31564944 '  'DIV1'
    
    INI1 = &H31494E49 '  'INI1'
    INI2 = &H32494E49 '  'INI2'
    
    CSM1 = &H314D5343 '  'CSM1'
End Enum

Private Type CheckSumInfo
    CheckSumProgBankA     As Integer ' [2byte]
    CheckSumProgBankB     As Integer ' [2byte]
    CheckSumProgBankC     As Integer ' [2byte]
    CheckSumProgBankD     As Integer ' [2byte]
    CheckSumProgBankE     As Integer ' [2byte]
    CheckSumProgBankF     As Integer ' [2byte]
    CheckSumProgBankGM    As Integer ' [2byte]
    CheckSumProgBankGMV1  As Integer ' [2byte]
    CheckSumProgBankGMDrm As Integer ' [2byte]
    CheckSumCombiBankA    As Integer ' [2byte]
    CheckSumCombiBankB    As Integer ' [2byte]
    CheckSumCombiBankC    As Integer ' [2byte]
    CheckSumCombiBankD    As Integer ' [2byte]
    CheckSumDrum00_15     As Integer ' [2byte]
    CheckSumDrum16_31     As Integer ' [2byte]
    CheckSumDrum32_47     As Integer ' [2byte]
    CheckSumDrum48_63     As Integer ' [2byte]
    CheckSumDrum64_72     As Integer ' [2byte]
    CheckSumArpp00_63     As Integer ' [2byte]
    CheckSumArpp64_79     As Integer ' [2byte]
    CheckSumArpp80_95     As Integer ' [2byte]
    CheckSumGlobal        As Integer ' [2byte]
End Type
Public Type PCGFile
    FileName   As String
    FileHeader As PCGFileHeader
    PCGChunk   As ChunkHeader
    
    ProgramChunk      As ChunkHeader
    ProgramBank       As BankChunk
    ProgramData()     As DataEntry
    
    ProgrV2Chunk      As ChunkHeader
    ProgrV2Bank       As BankChunk
    ProgrV2Data()     As DataEntry
    
    CombinationChunk  As ChunkHeader
    CombinationBank   As BankChunk
    CombinationData() As DataEntry
    
    CombiV2Chunk      As ChunkHeader
    CombiV2Bank       As BankChunk
    CombiV2Data()     As DataEntry
    
    DrumkitChunk      As ChunkHeader
    DrumkitBank       As BankChunk
    DrumkitData()     As DataEntry
    
    ArpeggioChunk     As ChunkHeader
    ArpeggioBank      As BankChunk
    ArpeggioData()    As DataEntry
    
    GlobalChunk       As ChunkHeader
    GlobalBank        As GlobalSetting
    
    DividedFileChunk As ChunkHeader
    DividedFileData  As DividedFileHeaderChunk
    
    ItemNameChunk    As ChunkHeader
    ItemNameData     As ItemInfoChunk
    
    ItemName2Chunk   As ChunkHeader
    ItemName2Data    As ItemInfoChunk
    
    CheckSumChunk    As ChunkHeader
    CheckSumData     As CheckSumInfo
End Type

Public Declare Sub GetMem4 Lib "msvbvm60" (ByRef pSrc As Any, ByRef pDst As Any)
Public Declare Sub GetMem2 Lib "msvbvm60" (ByRef pSrc As Any, ByRef pDst As Any)

Public Sub Load(this As PCGFile, aFilename)
Try: On Error GoTo Catch
    Dim FNr As Integer: FNr = FreeFile
    Open aFilename For Binary Access Read As FNr
    With this
        .FileName = aFilename
        Call ReadPCGFileHeader(.FileHeader, FNr)
        Call ReadChunkHeader(.PCGChunk, FNr)
        If ChunkIDToPCGID(.FileHeader.KORGID) = Korg Then
            Dim aChunk As ChunkHeader
            Do While Not EOF(FNr)
                Call ReadChunkHeader(aChunk, FNr)
                Dim ID As PCGID: ID = ChunkIDToPCGID(aChunk.ChunkID)
                Select Case True 'ChunkIDToPCGID(aChunk.ChunkID) 'True
                Case ID = PRG1
                    .ProgramChunk = aChunk
                    Call ReadBankChunk(.ProgramBank, FNr)
                    Call ReadDataEntries(.ProgramData, .ProgramBank.bank, FNr)
                Case ID = PV2P 'new for Karma V2
                    .ProgrV2Chunk = aChunk
                    Call ReadBankChunk(.ProgrV2Bank, FNr)
                    Call ReadDataEntries(.ProgrV2Data, .ProgrV2Bank.bank, FNr)
                Case ID = CMB1
                    .CombinationChunk = aChunk
                    Call ReadBankChunk(.CombinationBank, FNr)
                    Call ReadDataEntries(.CombinationData, .CombinationBank.bank, FNr)
                Case ID = CV2P 'new for Karma V2
                    .CombiV2Chunk = aChunk
                    Call ReadBankChunk(.CombiV2Bank, FNr)
                    Call ReadDataEntries(.CombiV2Data, .CombiV2Bank.bank, FNr)
                Case ID = DKT1
                    .DrumkitChunk = aChunk
                    Call ReadBankChunk(.DrumkitBank, FNr)
                    Call ReadDataEntries(.DrumkitData, .DrumkitBank.bank, FNr)
                Case ID = ARP1
                    .ArpeggioChunk = aChunk
                    Call ReadBankChunk(.ArpeggioBank, FNr)
                    Call ReadDataEntries(.ArpeggioData, .ArpeggioBank.bank, FNr)
                Case ID = GLB1
                    .GlobalChunk = aChunk
                    'dont know how big it must be
                    '.GlobalBank.Data
                    'Call ReadBankHeader(.GlobalBank, FNr)
                    'With .GlobalBank
                    '    Call ReadBank(.Header, .Bank, FNr)
                    'End With
                Case ID = DIV1
                    .DividedFileChunk = aChunk
                    Call ReadDividedFileHeaderChunk(.DividedFileData, FNr)
                Case ID = INI1
                    .ItemNameChunk = aChunk
                    Call ReadItemInfoChunk(.ItemNameData, FNr)
                Case ID = CSM1
                    'CheckSum chunk
                    .CheckSumChunk = aChunk
                    Call ReadCheckSumInfo(.CheckSumData, FNr)
                End Select
            Loop
        End If
    End With
    GoTo Finally
Catch:
    MsgBox Err.Description
Finally:
    Close FNr
End Sub
' #################### '       Read       ' #################### '
Public Sub ReadPCGFileHeader(this As PCGFileHeader, ByVal FNr As Integer)
Try: On Error GoTo Catch
    Get FNr, , this
    Exit Sub
Catch:
    MsgBox "ReadPCGFileHeader: " & Err.Description
End Sub
Public Function New_ChunkHeader(ByVal ID As Long, ByVal ChunkSize As Long) As ChunkHeader
    With New_ChunkHeader
        Call GetMem4(ID, .ChunkID(0))
        .ChunkSize = ChunkSize
    End With
End Function
Public Sub ReadChunkHeader(this As ChunkHeader, ByVal FNr As Integer)
Try: On Error GoTo Catch
    Get FNr, , this
    Call Rotate4(this.ChunkSize)
    Exit Sub
Catch:
    MsgBox "ReadChunkHeader: " & Err.Description
End Sub
Public Sub ReadBankHeader(this As BankHeader, ByVal FNr As Integer)
Try: On Error GoTo Catch
    With this
        Get FNr, , .NumOfElem
        Get FNr, , .SizeOfOne
        Get FNr, , .BankID
        Call Rotate4(.NumOfElem)
        Call Rotate4(.SizeOfOne)
        Call Rotate4(.BankID)
    End With
    Exit Sub
Catch:
    MsgBox "ReadBankHeader: " & Err.Description
End Sub
Public Sub ReadBankChunk(this As BankChunk, ByVal FNr As Integer)
Try: On Error GoTo Catch
    With this
        Call ReadChunkHeader(.Header, FNr)
        Call ReadBankHeader(.bank, FNr)
    End With
    Exit Sub
Catch:
    MsgBox "ReadBankChunk: " & Err.Description
End Sub
Public Sub ReadDataEntries(this() As DataEntry, Header As BankHeader, ByVal FNr As Integer)
Try: On Error GoTo Catch
    Dim i As Integer, u1 As Integer, u2 As Integer
    With Header
        u1 = .NumOfElem - 1
        ReDim this(0 To u1)
        u2 = .SizeOfOne - (SafeUbound(ArrPtr(this(0).NName)) + 1) - 1
    End With
    For i = 0 To u1
        With this(i)
            Get FNr, , .NName
            ReDim .data(u2)
            Get FNr, , .data
        End With
    Next
    Exit Sub
Catch:
    MsgBox "ReadDataEntries: " & Err.Description
End Sub
'Public Sub ReadGlobalSettings(glob As globBank, ByVal FNr As Integer)
'    With glob
'
'    End With
'End Sub

Public Sub ReadDividedFileHeaderChunk(this As DividedFileHeaderChunk, ByVal FNr As Integer)
Try: On Error GoTo Catch
    Get FNr, , this
    With this
        Call Rotate2(.ProgramInfo.NumOfElem)
        Call Rotate2(.CombiInfo.NumOfElem)
        Call Rotate2(.DrumkitInfo.NumOfElem)
        Call Rotate2(.ArppInfo.NumOfElem)
        Call Rotate2(.GlobalInfo.NumOfElem)
    End With
    Exit Sub
Catch:
    MsgBox "ReadDividedFileHeaderChunk: " & Err.Description
End Sub
Public Sub ReadItemInfoChunk(this As ItemInfoChunk, ByVal FNr As Integer)
Try: On Error GoTo Catch
    Dim i As Integer
    With this
        Get FNr, , .NumOfItems
        Call Rotate4(.NumOfItems)
        
        ReDim .Names(0 To .NumOfItems - 1)
        'ReDim .Names(0 To 4 - 1)
        Get FNr, , .Names
        For i = 0 To .NumOfItems - 1
            With .Names(i)
                Call Rotate4(.BankID)
            End With
        Next
    End With
    Exit Sub
Catch:
    MsgBox "ReadItemInfoChunk: " & Err.Description
End Sub

Public Sub ReadCheckSumInfo(this As CheckSumInfo, ByVal FNr As Integer)
Try: On Error GoTo Catch
    Get FNr, , this
    Exit Sub
Catch:
    MsgBox "ReadCheckSumInfo: " & Err.Description
End Sub

Public Sub Rotate4(ByRef lngval As Long)
    Dim b(0 To 3) As Byte
    Dim tmp As Byte
    Call GetMem4(lngval, b(0))
    tmp = b(0):    b(0) = b(3):    b(3) = tmp:
    tmp = b(1):    b(1) = b(2):    b(2) = tmp
    Call GetMem4(b(0), lngval)
End Sub
Public Sub Rotate2(ByRef IntVal As Integer)
    Dim b(0 To 1) As Byte
    Dim tmp As Byte
    Call GetMem2(IntVal, b(0))
    tmp = b(0):    b(0) = b(1):    b(1) = tmp:
    Call GetMem2(b(0), IntVal)
End Sub
Public Function ChunkIDToLong(aID() As Byte) As Long
    'ChunkIDToPCGID = IDToLong(aID)
    Call GetMem4(aID(0), ChunkIDToLong)
End Function
Public Sub LongToChunkID(ByVal lngval As Long, b() As Byte)
    Call GetMem4(lngval, b(0))
End Sub
Public Function ChunkIDToPCGID(aID() As Byte) As PCGID
    'ChunkIDToPCGID = IDToLong(aID)
    Call GetMem4(aID(0), ChunkIDToPCGID)
End Function

' #################### '    ToString    ' #################### '
Public Function ChunkIDToString(aID() As Byte) As String
    Dim i As Integer
    For i = 0 To 3 'alle müssen ungleich 0 sein
        If aID(i) = 0 Then Exit Function
    Next
    ChunkIDToString = StrConv(aID, vbUnicode)
End Function
Public Function BytarrToString(b() As Byte) As String
    Dim s As String: s = StrConv(b, vbUnicode)
    Dim pos As Integer: pos = InStr(1, s, vbNullChar, vbBinaryCompare)
    If pos > 0 Then s = Left(s, pos - 1)
    BytarrToString = s
End Function
Public Function PCGFileToString(this As PCGFile) As String
    Dim s As String, s1 As String
    Dim i As Integer, u As Integer
    Dim KORGID As PCGID
    With this
        KORGID = ChunkIDToLong(.FileHeader.KORGID)
        If KORGID <> PCGID.Korg Then Exit Function
        s = s & HeadlineToString("PCG-File:", .FileName) & vbCrLf
        s1 = PCGHeaderToString(.FileHeader) & vbCrLf
        If Len(s1) > 0 Then s = s & HeadlineToString("FileHeader:", s1)
        
        s1 = ChunkHeaderToString(.PCGChunk)
        If Len(s1) > 0 Then s = s & HeadlineToString("PCGChunk:", s1 & vbCrLf)
        
        s1 = ChunkHeaderToString(.DividedFileChunk)
        If Len(s1) > 0 Then
            's = s & s1
            s = s & HeadlineToString("DividedFileChunk:", s1 & vbCrLf)
            s = s & DividedFileHeaderChunkToString(.DividedFileData) & vbCrLf
            's = s & s1 '""
        End If
        
        s1 = ChunkHeaderToString(.ItemNameChunk)
        If Len(s1) > 0 Then
            s = s & HeadlineToString("ItemNameChunk:", s1)
            s = s & ItemInfoChunkToString(.ItemNameData)
            's = s & ""
        End If
        
        s1 = ChunkHeaderToString(.ProgramChunk)
        If Len(s1) > 0 Then
            s = s & HeadlineToString("ProgramChunk:", s1 & vbCrLf)
            With .ProgramBank
                s = s & BankToString(.Header, .bank)
            End With
            s = s & DataEntriesToString(.ProgramData)
        End If
        
        s1 = ChunkHeaderToString(.ProgrV2Chunk)
        If Len(s1) > 0 Then
            s = s & HeadlineToString("Program V2 Chunk:", s1 & vbCrLf)
            With .ProgrV2Bank
                s = s & BankToString(.Header, .bank)
            End With
            s = s & DataEntriesToString(.ProgrV2Data)
        End If
        
        s1 = ChunkHeaderToString(.CombinationChunk)
        If Len(s1) > 0 Then
            s = s & HeadlineToString("CombinationChunk:", s1)
            With .CombinationBank
                s = s & BankToString(.Header, .bank)
            End With
            s = s & DataEntriesToString(.CombinationData)
        End If
        
        s1 = ChunkHeaderToString(.CombiV2Chunk)
        If Len(s1) > 0 Then
            s = s & HeadlineToString("Combination V2 Chunk:", s1)
            With .CombiV2Bank
                s = s & BankToString(.Header, .bank)
            End With
            s = s & DataEntriesToString(.CombiV2Data)
        End If
        
        s1 = ChunkHeaderToString(.DrumkitChunk)
        If Len(s1) > 0 Then
            s = s & HeadlineToString("DrumkitChunk:", s1)
            With .DrumkitBank
                s = s & BankToString(.Header, .bank)
            End With
            s = s & DataEntriesToString(.DrumkitData)
        End If
                
        s1 = ChunkHeaderToString(.ArpeggioChunk)
        If Len(s1) > 0 Then
            s = s & HeadlineToString("ArpeggioChunk:", s1)
            With .ArpeggioBank
                s = s & BankToString(.Header, .bank)
            End With
            s = s & DataEntriesToString(.ArpeggioData)
        End If
        
    End With
    PCGFileToString = s
End Function
Public Function HeadlineToString(HL As String, s1 As String) As String
    HeadlineToString = HL & vbCrLf & String$(Len(HL), "=") & vbCrLf & s1
End Function
Public Function PCGHeaderToString(this As PCGFileHeader) As String
    Dim s As String
    With this
        s = s & "KORGID:       " & StrConv(.KORGID, vbUnicode) & vbCrLf
        s = s & "ProductID:    " & "x" & Hex$(.ProductID) & vbCrLf
        s = s & "FileType:     " & PCGFileTypeToString(.FileType) & vbCrLf
        s = s & "MajorVer:     " & CStr(.MajorVer) & vbCrLf
        s = s & "MinorVer:     " & CStr(.MinorVer) & vbCrLf
        s = s & "ProductSubID: " & ProductSubIDToString(.ProductSubID) & vbCrLf
    End With
    PCGHeaderToString = s
End Function
Public Function PCGFileTypeToString(ByVal ft As PCGFileType) As String
    Dim s As String
    Select Case ft
    Case filetypePCG: s = "PCG-File"
    Case filetypeSNG: s = "SNG-File"
    Case filetypeEXL: s = "EXL-File"
    End Select
    PCGFileTypeToString = s
End Function
Public Function ProductSubIDToString(ByVal psid As Long) As String
    Select Case psid
    Case 0: ProductSubIDToString = "TRITON/TRITON-Rack/TRITON-Studio"
    Case 1: ProductSubIDToString = "TRITON-Extreme"
    End Select
End Function
Public Function BankToString(Head As ChunkHeader, bank As BankHeader) As String
    Dim s As String
    Dim sHd As String: sHd = ChunkHeaderToString(Head)
    If Len(sHd) > 0 Then
        s = s & sHd
        s = s & BankHeaderToString(bank)
    End If
    BankToString = s
End Function
Public Function ChunkHeaderToString(this As ChunkHeader) As String
    Dim s As String
    Dim sID As String
    With this
        sID = ChunkIDToString(.ChunkID)
        If Len(sID) > 0 Then
            s = s & "ChunkID:   " & sID & vbCrLf
            s = s & "ChunkSize: " & CStr(.ChunkSize) & vbCrLf
        End If
    End With
    ChunkHeaderToString = s
End Function
Public Function BankHeaderToString(this As BankHeader) As String
    Dim s As String
    With this
        s = s & "NumOfElem: " & CStr(.NumOfElem) & vbCrLf
        s = s & "SizeOfOne: " & CStr(.SizeOfOne) & vbCrLf
        s = s & "BankID: " & Hex$(.BankID) & vbCrLf ' ChunkIDToString(.BankID()) & vbCrLf
    End With
    BankHeaderToString = s
End Function
Public Function DataEntriesToString(this() As DataEntry)
    Dim s As String
    Dim i As Integer, u1 As Integer ', u2 As Integer
    u1 = SafeUbound(ArrPtr(this))
    For i = 0 To u1
        s = s & CStr(i) & ": " & BytarrToString(this(i).NName) & vbCrLf
    Next
    DataEntriesToString = s
End Function
Public Function DividedFileInfoToString(this As DividedFileInfo) As String
    Dim s As String
    With this
        s = s & "Info:      " & CStr(.Info) & vbCrLf
        s = s & "NumOfElem: " & CStr(.NumOfElem) & vbCrLf
    End With
    DividedFileInfoToString = s
End Function

Public Function DividedFileHeaderChunkToString(this As DividedFileHeaderChunk) As String
    Dim s As String
    With this
        's = s & vbCrLf
        s = s & "DividedFileHeaderChunk" & vbCrLf
        s = s & "======================" & vbCrLf
        s = s & "Status:   " & .status & vbCrLf
        s = s & "RandomID: " & .randomID & vbCrLf
        s = s & DividedFileInfoToString(.ProgramInfo) '& vbCrLf
        s = s & DividedFileInfoToString(.CombiInfo) '& vbCrLf
        s = s & DividedFileInfoToString(.DrumkitInfo) '& vbCrLf
        s = s & DividedFileInfoToString(.ArppInfo) '& vbCrLf
        s = s & DividedFileInfoToString(.GlobalInfo) ' & vbCrLf
    End With
    DividedFileHeaderChunkToString = s
End Function

Public Function ItemInfoChunkToString(this As ItemInfoChunk) As String
    Dim s As String
    With this
        If .NumOfItems > 0 Then
            s = s & "NumOfItems: " & CStr(.NumOfItems) & vbCrLf & vbCrLf
            Dim i As Integer
            For i = 0 To .NumOfItems - 1
                s = s & ItemNameInfoToString(.Names(i)) & vbCrLf
            Next
        End If
    End With
    ItemInfoChunkToString = s
End Function
Public Function ItemNameInfoToString(this As ItemNameInfo) As String
    Dim s As String
    With this
        s = s & "ChunkID:  " & ChunkIDToString(.ChunkID) & vbCrLf
        s = s & "BankID:   " & Hex$(.BankID) & vbCrLf
        s = s & "ItemName: " & BytarrToString(.ItemName) & vbCrLf
    End With
    ItemNameInfoToString = s
End Function

' #################### '    ErrHandler    ' #################### '
Private Function ErrHandler(fncnam As String, Optional msgstyle As VbMsgBoxStyle) As VbMsgBoxResult
    ErrHandler = GlobalErrhandler("PCGFile", fncnam, msgstyle)
End Function

'    inst = &H74736E69 '  'inst'

'Option Explicit
'Private Declare Sub GetMem4 Lib "msvbvm60" (ByRef pSrc As Any, ByRef pDst As Any)
'
'Private Sub Form_Load()
'    'Text1.MultiLine = True
'    'Text1.ScrollBars = 3 'both
'    Text1.FontName = "Courier New"
'    Text1.FontSize = 10
'    '
'    Dim arr
'    arr = Array("KORG", _
'                "PCG1", "PRG1", "PBK1", "MBK1", "PV2P", "PV2B", _
'                "CMB1", "CBK1", "CV2P", "CV2B", _
'                "DKT1", "DBK1", _
'                "ARP1", "ABK1", "GLB1", "DIV1", _
'                "INI1", "INI2", "CSM1", _
'                "MSP1", "MNO1", "RLP1", "RLP2", _
'                "SMP1", "SNO1", "SMD1", "SMF1", _
'                "RIFF", "WAVE", "fmt ", "data", "smpl", "inst")
'    '
'    Dim i As Long
'    Dim l As Long
'    Dim s As String
'    Dim bArr() As Byte
'    For i = 0 To UBound(arr)
'        bArr = StrConv(CStr(arr(i)), vbFromUnicode)
'        Call GetMem4(bArr(0), l)
'        s = s & "    " & CStr(arr(i)) & " = " & "&H" & Hex$(l) & " '  '" & CStr(arr(i)) & "'" & vbCrLf
'    Next
'    Text1.Text = s
'End Sub
'
'Private Function StrToLong(s As String) As Long
'    Dim bArr() As Byte
'    bArr = StrConv(s, vbFromUnicode)
'    Call GetMem4(bArr(0), StrToLong)
'End Function

