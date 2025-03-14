; This file is part of Koda installation
; This script fixes default control names in forms, created in versions pror 1.7.x.x, when option "Strip 'A' prefix" was enabled,
; since new versions of Koda always strip prefixes at control creation time

$sForms = FileOpenDialog ("Open Koda 1.6.x.x or older file:", @ScriptDir, "Koda forms (*.kxf)|All (*.*)", 4)
If @error Then Exit

$oFormDoc = ObjCreate("Msxml2.DOMDocument")
$oFormDoc.async=0
$oFormDoc.resolveExternals = False
$oFormDoc.preserveWhiteSpace = True

$aFiles = StringSplit($sForms, "|")

If $aFiles[0] = 1 Then
    ProcessFile($aFiles[1])
Else
    For $i = 2 To $aFiles[0]
        ProcessFile($aFiles[1] & "\" & $aFiles[$i])
    Next
EndIf


Func ProcessFile($sFile)
    Local $sBackup = StringTrimRight($sFile, 4) & ".bak"
    $oFormDoc.Load($sFile)
    $oFormDoc.Save($sBackup) ; save backup
    ProcessNode($oFormDoc.documentElement) ; root node
    $oFormDoc.Save($sFile)
EndFunc

Func ProcessNode($oNode)
    Local $sClass = $oNode.getAttribute("type") ; get type of object
    Local $sName  = $oNode.getAttribute("name") ; get name of object
    $sClass = StringTrimLeft($sClass, 1) ; strip T from classname
    ; check if name is default, and strip prefix
    If StringLeft($sClass, 1) == "A" and StringRegExp($sName, "(?-i)" & $sClass & "\d+") Then 
        $oNode.setAttribute("name", StringTrimLeft($sName, 1))
    EndIf
    ; try to process subnodes
    Local $oCompNode = $oNode.selectSingleNode("components")
    Local $oCompList = $oCompNode.selectNodes("object")
    For $oSubNode In $oCompList
        ProcessNode($oSubNode)
    Next
EndFunc
