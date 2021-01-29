Die Ressourcenskriptdatei, RessourceS.rc editieren,
dann die Batchdatei MakeRes.bat doppelklicken.

Achtung Bug: 
Es wird kein Pfad akzeptiert, der mit einem T bzw. t beginnt.
oder Pfade immer mit Doppelbackslash ausrüsten, da /t irgend-
eine Bedeutung hat 

seit manifest.exe.manifest
folgende Codezeilen im Projekt hinzufügen:
irgendwo in einem Modul:

Public Declare Sub InitCommonControls Lib "comctl32.dll" () 
'oder
Private Declare Sub Application_EnableVisualStyles Lib "comctl32.dll" Alias "InitCommonControls" ()

'irgendwo zum programmstart, im Startformular oder in Sub Main
Private Sub Form_Initialize()
  Call InitCommonControls
End Sub

Konstanten sind in der Headerdatei RessourceS.h definiert