#include-once
#region Header
#comments-start
	Title:			Computer Information Automation UDF Library for AutoIt3
	Filename:		CompInfo.au3
	Description:	A collection of UDF's that assist in gathering and setting information about a computer (Software and Hardware).
	Author:			Jarvis J. Stubblefield (JSThePatriot) http://www.vortexrevolutions.com/
	Version:		00.03.08
	Last Update:	11.09.06
	Requirements:	AutoIt v3.2 +, Developed/Tested on WindowsXP Pro Service Pack 2
	Notes:			Errors associated with incorrect objects will be common user errors. AutoIt beta 3.1.1.63 has added an ObjName()
	function that will be used to trap and report most of these errors.
	
	Special thanks to JdeB (WMI Introduction), SvenP (Scriptomatic), Firestorm (testing, ideas), gafrost (WMI Support),
	piccaso (COM Errors), RagnaroktA (testing, ideas, bug fixes), SmOke_N (testing), and everyone else that has helped in
	the creation of this UDF.
#comments-end
#endregion Header

#region Global Variables and Constants
If Not(IsDeclared("$cI_CompName")) Then
	Global	$cI_CompName = @ComputerName
EndIf
Global Const $cI_VersionInfo		= "00.03.08"
Global Const $cI_aName				= 0, _
			 $cI_aDesc				= 4
Global	$wbemFlagReturnImmediately	= 0x10, _	;DO NOT CHANGE
$wbemFlagForwardOnly		= 0x20				;DO NOT CHANGE
Global	$ERR_NO_INFO				= "Array contains no information", _
		$ERR_NOT_OBJ				= "$colItems isnt an object"
#endregion Global Variables and Constants

#region Software Functions
;===============================================================================
; Description:      Returns the Boot Configuration information in an array.
; Parameter(s):     $aBootConfigInfo - By Reference - Boot Configuration Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Boot Configuration Information.
;						$aBootConfigInfo[$i][0]  = Name
;						$aBootConfigInfo[$i][1]  = Boot Directory
;						$aBootConfigInfo[$i][2]  = Configuration Path
;						$aBootConfigInfo[$i][3]  = Last Drive
;						$aBootConfigInfo[$i][4]  = Description
;						$aBootConfigInfo[$i][5]  = Scratch Directory
;						$aBootConfigInfo[$i][6]  = Setting ID
;						$aBootConfigInfo[$i][7]  = Temp Directory
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetBootConfig(ByRef $aBootConfigInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aBootConfigInfo[1][8], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_BootConfiguration", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aBootConfigInfo[UBound($aBootConfigInfo) + 1][8]
			$aBootConfigInfo[$i][0]  = $objItem.Name
			$aBootConfigInfo[$i][1]  = $objItem.BootDirectory
			$aBootConfigInfo[$i][2]  = $objItem.ConfigurationPath
			$aBootConfigInfo[$i][3]  = $objItem.LastDrive
			$aBootConfigInfo[$i][4]  = $objItem.Description
			$aBootConfigInfo[$i][5]  = $objItem.ScratchDirectory
			$aBootConfigInfo[$i][6]  = $objItem.SettingID
			$aBootConfigInfo[$i][7]  = $objItem.TempDirectory
			$i += 1
		Next
		$aBootConfigInfo[0][0] = UBound($aBootConfigInfo) - 1
		If $aBootConfigInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetBootConfig

;===============================================================================
; Description:      Returns the DependantService information in an array.
; Parameter(s):     $aDependantServiceInfo - By Reference - DependantService Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of DependantService Information.
;						$aDependantServiceInfo[$i][0]	= Antecedent
;						$aDependantServiceInfo[$i][1]	= Dependent
;						$aDependantServiceInfo[$i][2]	= TypeOfDependency
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information.
;											2 - $colItems isnt an object.
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetDependantServices(ByRef $aDependantServiceInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aDependantServiceInfo[1][3], $i = 1

	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_DependentService", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aDependantServiceInfo[UBound($aDependantServiceInfo) + 1][3]
			$aDependantServiceInfo[$i][0]	= $objItem.Antecedent
			$aDependantServiceInfo[$i][1]	= $objItem.Dependent
			$aDependantServiceInfo[$i][2]	= $objItem.TypeOfDependency
			$i += 1
		Next
		$aDependantServiceInfo[0][0] = UBound($aDependantServiceInfo) - 1
		If $aDependantServiceInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetDependantServices

;===============================================================================
; Description:      Returns the Desktop information in an array.
; Parameter(s):     $aDesktopInfo - By Reference - Desktop Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Desktop Information.
;						$aDesktopInfo[$i][0]	= Name
;						$aDesktopInfo[$i][1]	= BorderWidth
;						$aDesktopInfo[$i][2]	= CoolSwitch
;						$aDesktopInfo[$i][3]	= CursorBlinkRate
;						$aDesktopInfo[$i][4]	= Description
;						$aDesktopInfo[$i][5]	= DragFullWindows
;						$aDesktopInfo[$i][6]	= GridGranularity
;						$aDesktopInfo[$i][7]	= IconSpacing
;						$aDesktopInfo[$i][8]	= IconTitleFaceName
;						$aDesktopInfo[$i][9]	= IconTitleSize
;						$aDesktopInfo[$i][10]	= IconTitleWrap
;						$aDesktopInfo[$i][11]	= Pattern
;						$aDesktopInfo[$i][12]	= ScreenSaverActive
;						$aDesktopInfo[$i][13]	= ScreenSaverExecutable
;						$aDesktopInfo[$i][14]	= ScreenSaverSecure
;						$aDesktopInfo[$i][15]	= ScreenSaverTimeout
;						$aDesktopInfo[$i][16]	= SettingID
;						$aDesktopInfo[$i][17]	= Wallpaper
;						$aDesktopInfo[$i][18]	= WallpaperStretched
;						$aDesktopInfo[$i][19]	= WallpaperTiled
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information.
;											2 - $colItems isnt an object.
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetDesktops(ByRef $aDesktopInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aDesktopInfo[1][20], $i = 1

	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Desktop", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aDesktopInfo[UBound($aDesktopInfo) + 1][20]
			$aDesktopInfo[$i][0]	= $objItem.Name
			$aDesktopInfo[$i][1]	= $objItem.BorderWidth
			$aDesktopInfo[$i][2]	= $objItem.CoolSwitch
			$aDesktopInfo[$i][3]	= $objItem.CursorBlinkRate
			$aDesktopInfo[$i][4]	= $objItem.Description
			$aDesktopInfo[$i][5]	= $objItem.DragFullWindows
			$aDesktopInfo[$i][6]	= $objItem.GridGranularity
			$aDesktopInfo[$i][7]	= $objItem.IconSpacing
			$aDesktopInfo[$i][8]	= $objItem.IconTitleFaceName
			$aDesktopInfo[$i][9]	= $objItem.IconTitleSize
			$aDesktopInfo[$i][10]	= $objItem.IconTitleWrap
			$aDesktopInfo[$i][11]	= $objItem.Pattern
			$aDesktopInfo[$i][12]	= $objItem.ScreenSaverActive
			$aDesktopInfo[$i][13]	= $objItem.ScreenSaverExecutable
			$aDesktopInfo[$i][14]	= $objItem.ScreenSaverSecure
			$aDesktopInfo[$i][15]	= $objItem.ScreenSaverTimeout
			$aDesktopInfo[$i][16]	= $objItem.SettingID
			$aDesktopInfo[$i][17]	= $objItem.Wallpaper
			$aDesktopInfo[$i][18]	= $objItem.WallpaperStretched
			$aDesktopInfo[$i][19]	= $objItem.WallpaperTiled
			$i += 1
		Next
		$aDesktopInfo[0][0] = UBound($aDesktopInfo) - 1
		If $aDesktopInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetDesktops

;===============================================================================
; Description:      Returns the EventLog information in an array.
; Parameter(s):     $aEventLogInfo - By Reference - EventLog Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of EventLog Information.
;						$aEventLogInfo[0][0]   = Number of EventLogs
;						$aEventLogInfo[$i][0]  = Name ($i starts at 1)
;						$aEventLogInfo[$i][1]  = Access Mask
;						$aEventLogInfo[$i][2]  = Archive
;						$aEventLogInfo[$i][3]  = Compressed
;						$aEventLogInfo[$i][4]  = Description
;						$aEventLogInfo[$i][5]  = Compression Method
;						$aEventLogInfo[$i][6]  = Creation Class Name
;						$aEventLogInfo[$i][7]  = Creation Date
;						$aEventLogInfo[$i][8]  = CS Creation Class Name
;						$aEventLogInfo[$i][9]  = CS Name
;						$aEventLogInfo[$i][10] = Drive
;						$aEventLogInfo[$i][11] = Eight Dot Three File Name
;						$aEventLogInfo[$i][12] = Encrypted
;						$aEventLogInfo[$i][13] = Encryption Method
;						$aEventLogInfo[$i][14] = Extension
;						$aEventLogInfo[$i][15] = File Name
;						$aEventLogInfo[$i][16] = File Size
;						$aEventLogInfo[$i][17] = File Type
;						$aEventLogInfo[$i][18] = FS Creation Class Name
;						$aEventLogInfo[$i][19] = FS Name
;						$aEventLogInfo[$i][20] = Hidden
;						$aEventLogInfo[$i][21] = Install Date
;						$aEventLogInfo[$i][22] = In Use Count
;						$aEventLogInfo[$i][23] = Last Accessed
;						$aEventLogInfo[$i][24] = Last Modified
;						$aEventLogInfo[$i][25] = Log file Name
;						$aEventLogInfo[$i][26] = Manufacturer
;						$aEventLogInfo[$i][27] = Max File Size
;						$aEventLogInfo[$i][28] = Number Of Records
;						$aEventLogInfo[$i][29] = Overwrite Out Dated
;						$aEventLogInfo[$i][30] = Overwrite Policy
;						$aEventLogInfo[$i][31] = Path
;						$aEventLogInfo[$i][32] = Readable
;						$aEventLogInfo[$i][33] = Sources
;						$aEventLogInfo[$i][34] = Status
;						$aEventLogInfo[$i][35] = System
;						$aEventLogInfo[$i][36] = Version
;						$aEventLogInfo[$i][37] = Writeable
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetEventLogs(ByRef $aEventLogInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aEventLogInfo[1][38], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_NTEventLogFile", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aEventLogInfo[UBound($aEventLogInfo) + 1][38]
			$aEventLogInfo[$i][0]  = $objItem.Name
			$aEventLogInfo[$i][1]  = $objItem.AccessMask
			$aEventLogInfo[$i][2]  = $objItem.Archive
			$aEventLogInfo[$i][3]  = $objItem.Compressed
			$aEventLogInfo[$i][4]  = $objItem.Description
			$aEventLogInfo[$i][5]  = $objItem.CompressionMethod
			$aEventLogInfo[$i][6]  = $objItem.CreationClassName
			$aEventLogInfo[$i][7]  = __StringToDate($objItem.CreationDate)
			$aEventLogInfo[$i][8]  = $objItem.CSCreationClassName
			$aEventLogInfo[$i][9]  = $objItem.CSName
			$aEventLogInfo[$i][10] = $objItem.Drive
			$aEventLogInfo[$i][11] = $objItem.EightDotThreeFileName
			$aEventLogInfo[$i][12] = $objItem.Encrypted
			$aEventLogInfo[$i][13] = $objItem.EncryptionMethod
			$aEventLogInfo[$i][14] = $objItem.Extension
			$aEventLogInfo[$i][15] = $objItem.FileName
			$aEventLogInfo[$i][16] = $objItem.FileSize
			$aEventLogInfo[$i][17] = $objItem.FileType
			$aEventLogInfo[$i][18] = $objItem.FSCreationClassName
			$aEventLogInfo[$i][19] = $objItem.FSName
			$aEventLogInfo[$i][20] = $objItem.Hidden
			$aEventLogInfo[$i][21] = __StringToDate($objItem.InstallDate)
			$aEventLogInfo[$i][22] = $objItem.InUseCount
			$aEventLogInfo[$i][23] = __StringToDate($objItem.LastAccessed)
			$aEventLogInfo[$i][24] = __StringToDate($objItem.LastModified)
			$aEventLogInfo[$i][25] = $objItem.LogfileName
			$aEventLogInfo[$i][26] = $objItem.Manufacturer
			$aEventLogInfo[$i][27] = $objItem.MaxFileSize
			$aEventLogInfo[$i][28] = $objItem.NumberOfRecords
			$aEventLogInfo[$i][29] = $objItem.OverwriteOutDated
			$aEventLogInfo[$i][30] = $objItem.OverWritePolicy
			$aEventLogInfo[$i][31] = $objItem.Path
			$aEventLogInfo[$i][32] = $objItem.Readable
			$aEventLogInfo[$i][33] = $objItem.Sources(0)
			$aEventLogInfo[$i][34] = $objItem.Status
			$aEventLogInfo[$i][35] = $objItem.System
			$aEventLogInfo[$i][36] = $objItem.Version
			$aEventLogInfo[$i][37] = $objItem.Writeable
			$i += 1
		Next
		$aEventLogInfo[0][0] = UBound($aEventLogInfo) - 1
		If $aEventLogInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetEventLogs

;===============================================================================
; Description:      Returns the Extension information in an array.
; Parameter(s):     $aExtensionInfo - By Reference - Extension Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Extension Information.
;						$aExtensionInfo[0][0]   = Number of Extensions
;						$aExtensionInfo[$i][0]  = Name ($i starts at 1)
;						$aExtensionInfo[$i][1]  = Action ID
;						$aExtensionInfo[$i][2]  = Argument
;						$aExtensionInfo[$i][3]  = Command
;						$aExtensionInfo[$i][4]  = Description
;						$aExtensionInfo[$i][5]  = Direction
;						$aExtensionInfo[$i][6]  = Extension
;						$aExtensionInfo[$i][7]  = MIME
;						$aExtensionInfo[$i][8]  = Prog ID
;						$aExtensionInfo[$i][9]  = Shell New
;						$aExtensionInfo[$i][10] = Shell New Value
;						$aExtensionInfo[$i][11] = Software Element ID
;						$aExtensionInfo[$i][12] = Software Element State
;						$aExtensionInfo[$i][13] = Target Operating System
;						$aExtensionInfo[$i][14] = Verb
;						$aExtensionInfo[$i][15] = Version
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetExtensions(ByRef $aExtensionInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aExtensionInfo[1][16], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_ExtensionInfoAction", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aExtensionInfo[UBound($aExtensionInfo) + 1][16]
			$aExtensionInfo[$i][0]  = $objItem.Name
			$aExtensionInfo[$i][1]  = $objItem.ActionID
			$aExtensionInfo[$i][2]  = $objItem.Argument
			$aExtensionInfo[$i][3]  = $objItem.Command
			$aExtensionInfo[$i][4]  = $objItem.Description
			$aExtensionInfo[$i][5]  = $objItem.Direction
			$aExtensionInfo[$i][6]  = $objItem.Extension
			$aExtensionInfo[$i][7]  = $objItem.MIME
			$aExtensionInfo[$i][8]  = $objItem.ProgID
			$aExtensionInfo[$i][9]  = $objItem.ShellNew
			$aExtensionInfo[$i][10] = $objItem.ShellNewValue
			$aExtensionInfo[$i][11] = $objItem.SoftwareElementID
			$aExtensionInfo[$i][12] = $objItem.SoftwareElementState
			$aExtensionInfo[$i][13] = $objItem.TargetOperatingSystem
			$aExtensionInfo[$i][14] = $objItem.Verb
			$aExtensionInfo[$i][15] = $objItem.Version
			$i += 1
		Next
		$aExtensionInfo[0][0] = UBound($aExtensionInfo) - 1
		If $aExtensionInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetExtensions

;===============================================================================
; Description:      Returns the User Groups and information in an array.
; Parameter(s):     $aGroupInfo - By Reference - Group Name and Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Group Information.
;						$aGroupInfo[0][0]  = Number of Groups
;						$aGroupInfo[$i][0] = Name ($i starts at 1)
;						$aGroupInfo[$i][1] = Doamin
;						$aGroupInfo[$i][2] = Status
;						$aGroupInfo[$i][3] = Local Account
;						$aGroupInfo[$i][4] = Description
;						$aGroupInfo[$i][5] = SID
;						$aGroupInfo[$i][6] = SID Type
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetGroups(ByRef $aGroupInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aGroupInfo[1][7], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Group", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aGroupInfo[UBound($aGroupInfo) + 1][7]
			$aGroupInfo[$i][0] = $objItem.Name
			$aGroupInfo[$i][1] = $objItem.Domain
			$aGroupInfo[$i][2] = $objItem.Status
			$aGroupInfo[$i][3] = $objItem.LocalAccount
			$aGroupInfo[$i][4] = $objItem.Description
			$aGroupInfo[$i][5] = $objItem.SID
			$aGroupInfo[$i][6] = $objItem.SIDType
			$i += 1
		Next
		$aGroupInfo[0][0] = UBound($aGroupInfo) - 1
		If $aGroupInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetGroups

;===============================================================================
; Description:      Returns the LoggedOnUser information in an array.
; Parameter(s):     $aLoggedOnUserInfo - By Reference - LoggedOnUser Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of LoggedOnUser Information.
;						$aLoggedOnUserInfo[$i][0]	= Domain Name
;						$aLoggedOnUserInfo[$i][1]	= User Name
;						$aLoggedOnUserInfo[$i][2]	= Logon ID
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information.
;											2 - $colItems isnt an object.
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetLoggedOnUsers(ByRef $aLoggedOnUserInfo)
	Local $colItems, $objWMIService, $objItem
	Local $LoggedOnUserInfo, $linePattern, $aExpRet
	Dim $aLoggedOnUserInfo[1][3], $i = 1

	$linePattern = '(?i)(?:=")([^"]*)'
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_LoggedOnUser", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

	If IsObj($colItems) Then
		For $objItem In $colItems
			$LoggedOnUserInfo &= $objItem.Antecedent
			$LoggedOnUserInfo &= $objItem.Dependent
		Next
		$aExpRet = StringRegExp($LoggedOnUserInfo, $linePattern, 3)
		ReDim $aLoggedOnUserInfo[UBound($aExpRet)/3 + 1][3]
		Local $j = 0
		For $i = 1 To UBound($aLoggedOnUserInfo) - 1 Step 1
			$aLoggedOnUserInfo[$i][0] = $aExpRet[$j]
			$aLoggedOnUserInfo[$i][1] = $aExpRet[$j+1]
			$aLoggedOnUserInfo[$i][2] = $aExpRet[$j+2]
			$j += 3
		Next
		$aLoggedOnUserInfo[0][0] = UBound($aLoggedOnUserInfo) - 1
		If $aLoggedOnUserInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetLoggedOnUsers

;===============================================================================
; Description:      Returns the OS information in an array.
; Parameter(s):     $aOSInfo - By Reference - OS Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of OS Information.
;						$aOSInfo[$i][0]  = Name
;						$aOSInfo[$i][1]  = Boot Device
;						$aOSInfo[$i][2]  = Build Number
;						$aOSInfo[$i][3]  = Build Type
;						$aOSInfo[$i][4]  = Description
;						$aOSInfo[$i][5]  = CodeSet
;						$aOSInfo[$i][6]  = Country Code
;						$aOSInfo[$i][7]  = Creation Class Name
;						$aOSInfo[$i][8]  = CS Creation Class Name
;						$aOSInfo[$i][9]  = CSD Version
;						$aOSInfo[$i][10] = CS Name
;						$aOSInfo[$i][11] = Current Time Zone
;						$aOSInfo[$i][12] = DataExecutionPrevention_32BitApplications
;						$aOSInfo[$i][13] = DataExecutionPrevention_Available
;						$aOSInfo[$i][14] = DataExecutionPrevention_Drivers
;						$aOSInfo[$i][15] = DataExecutionPrevention_SupportPolicy
;						$aOSInfo[$i][16] = Debug
;						$aOSInfo[$i][17] = Distributed
;						$aOSInfo[$i][18] = Encryption Level
;						$aOSInfo[$i][19] = Foreground Application Boost
;						$aOSInfo[$i][20] = Free Physical Memory
;						$aOSInfo[$i][21] = Free Space In Paging Files
;						$aOSInfo[$i][22] = Free Virtual Memory
;						$aOSInfo[$i][23] = Install Date
;						$aOSInfo[$i][24] = Large System Cache
;						$aOSInfo[$i][25] = Last Boot Up Time
;						$aOSInfo[$i][26] = Local Date Time
;						$aOSInfo[$i][27] = Locale
;						$aOSInfo[$i][28] = Manufacturer
;						$aOSInfo[$i][29] = Max Number Of Processes
;						$aOSInfo[$i][30] = Max Process Memory Size
;						$aOSInfo[$i][31] = Number Of Licensed Users
;						$aOSInfo[$i][32] = Number Of Processes
;						$aOSInfo[$i][33] = Number Of Users
;						$aOSInfo[$i][34] = Organization
;						$aOSInfo[$i][35] = OS Language
;						$aOSInfo[$i][36] = OS Product Suite
;						$aOSInfo[$i][37] = OS Type
;						$aOSInfo[$i][38] = Other Type Description
;						$aOSInfo[$i][39] = Plus Product ID
;						$aOSInfo[$i][40] = Plus Version Number
;						$aOSInfo[$i][41] = Primary
;						$aOSInfo[$i][42] = Product Type
;						$aOSInfo[$i][43] = Quantum Length
;						$aOSInfo[$i][44] = Quantum Type
;						$aOSInfo[$i][45] = Registered User
;						$aOSInfo[$i][46] = Serial Number
;						$aOSInfo[$i][47] = Service Pack Major Version
;						$aOSInfo[$i][48] = Service Pack Minor Version
;						$aOSInfo[$i][49] = Size Stored In Paging Files
;						$aOSInfo[$i][50] = Status
;						$aOSInfo[$i][51] = Suite Mask
;						$aOSInfo[$i][52] = System Device
;						$aOSInfo[$i][53] = System Directory
;						$aOSInfo[$i][54] = System Drive
;						$aOSInfo[$i][55] = Total Swap Space Size
;						$aOSInfo[$i][56] = Total Virtual Memory Size
;						$aOSInfo[$i][57] = Total Visible Memory Size
;						$aOSInfo[$i][58] = Version
;						$aOSInfo[$i][59] = Windows Directory
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetOSs(ByRef $aOSInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aOSInfo[1][60], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_OperatingSystem", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aOSInfo[UBound($aOSInfo) + 1][60]
			$aOSInfo[$i][0]  = $objItem.Name
			$aOSInfo[$i][1]  = $objItem.BootDevice
			$aOSInfo[$i][2]  = $objItem.BuildNumber
			$aOSInfo[$i][3]  = $objItem.BuildType
			$aOSInfo[$i][4]  = $objItem.Description
			$aOSInfo[$i][5]  = $objItem.CodeSet
			$aOSInfo[$i][6]  = $objItem.CountryCode
			$aOSInfo[$i][7]  = $objItem.CreationClassName
			$aOSInfo[$i][8]  = $objItem.CSCreationClassName
			$aOSInfo[$i][9]  = $objItem.CSDVersion
			$aOSInfo[$i][10] = $objItem.CSName
			$aOSInfo[$i][11] = $objItem.CurrentTimeZone
			$aOSInfo[$i][12] = $objItem.DataExecutionPrevention_32BitApplications
			$aOSInfo[$i][13] = $objItem.DataExecutionPrevention_Available
			$aOSInfo[$i][14] = $objItem.DataExecutionPrevention_Drivers
			$aOSInfo[$i][15] = $objItem.DataExecutionPrevention_SupportPolicy
			$aOSInfo[$i][16] = $objItem.Debug
			$aOSInfo[$i][17] = $objItem.Distributed
			$aOSInfo[$i][18] = $objItem.EncryptionLevel
			$aOSInfo[$i][19] = $objItem.ForegroundApplicationBoost
			$aOSInfo[$i][20] = $objItem.FreePhysicalMemory
			$aOSInfo[$i][21] = $objItem.FreeSpaceInPagingFiles
			$aOSInfo[$i][22] = $objItem.FreeVirtualMemory
			$aOSInfo[$i][23] = __StringToDate($objItem.InstallDate)
			$aOSInfo[$i][24] = $objItem.LargeSystemCache
			$aOSInfo[$i][25] = __StringToDate($objItem.LastBootUpTime)
			$aOSInfo[$i][26] = __StringToDate($objItem.LocalDateTime)
			$aOSInfo[$i][27] = $objItem.Locale
			$aOSInfo[$i][28] = $objItem.Manufacturer
			$aOSInfo[$i][29] = $objItem.MaxNumberOfProcesses
			$aOSInfo[$i][30] = $objItem.MaxProcessMemorySize
			$aOSInfo[$i][31] = $objItem.NumberOfLicensedUsers
			$aOSInfo[$i][32] = $objItem.NumberOfProcesses
			$aOSInfo[$i][33] = $objItem.NumberOfUsers
			$aOSInfo[$i][34] = $objItem.Organization
			$aOSInfo[$i][35] = $objItem.OSLanguage
			$aOSInfo[$i][36] = $objItem.OSProductSuite
			$aOSInfo[$i][37] = $objItem.OSType
			$aOSInfo[$i][38] = $objItem.OtherTypeDescription
			$aOSInfo[$i][39] = $objItem.PlusProductID
			$aOSInfo[$i][40] = $objItem.PlusVersionNumber
			$aOSInfo[$i][41] = $objItem.Primary
			$aOSInfo[$i][42] = $objItem.ProductType
			$aOSInfo[$i][43] = $objItem.QuantumLength
			$aOSInfo[$i][44] = $objItem.QuantumType
			$aOSInfo[$i][45] = $objItem.RegisteredUser
			$aOSInfo[$i][46] = $objItem.SerialNumber
			$aOSInfo[$i][47] = $objItem.ServicePackMajorVersion
			$aOSInfo[$i][48] = $objItem.ServicePackMinorVersion
			$aOSInfo[$i][49] = $objItem.SizeStoredInPagingFiles
			$aOSInfo[$i][50] = $objItem.Status
			$aOSInfo[$i][51] = $objItem.SuiteMask
			$aOSInfo[$i][52] = $objItem.SystemDevice
			$aOSInfo[$i][53] = $objItem.SystemDirectory
			$aOSInfo[$i][54] = $objItem.SystemDrive
			$aOSInfo[$i][55] = $objItem.TotalSwapSpaceSize
			$aOSInfo[$i][56] = $objItem.TotalVirtualMemorySize
			$aOSInfo[$i][57] = $objItem.TotalVisibleMemorySize
			$aOSInfo[$i][58] = $objItem.Version
			$aOSInfo[$i][59] = $objItem.WindowsDirectory
			$i += 1
		Next
		$aOSInfo[0][0] = UBound($aOSInfo) - 1
		If $aOSInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetOSs

;===============================================================================
; Description:      Returns the PrintJob information in an array.
; Parameter(s):     $aPrintJobInfo - By Reference - PrintJob Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of PrintJob Information.
;						$aPrintJobInfo[$i][0]	= Name
;						$aPrintJobInfo[$i][1]	= DataType
;						$aPrintJobInfo[$i][2]	= Document
;						$aPrintJobInfo[$i][3]	= DriverName
;						$aPrintJobInfo[$i][4]	= Description
;						$aPrintJobInfo[$i][5]	= ElapsedTime
;						$aPrintJobInfo[$i][6]	= HostPrintQueue
;						$aPrintJobInfo[$i][7]	= JobId
;						$aPrintJobInfo[$i][8]	= JobStatus
;						$aPrintJobInfo[$i][9]	= Name
;						$aPrintJobInfo[$i][10]	= Notify
;						$aPrintJobInfo[$i][11]	= Owner
;						$aPrintJobInfo[$i][12]	= PagesPrinted
;						$aPrintJobInfo[$i][13]	= Parameters
;						$aPrintJobInfo[$i][14]	= PrintProcessor
;						$aPrintJobInfo[$i][15]	= Priority
;						$aPrintJobInfo[$i][16]	= Size
;						$aPrintJobInfo[$i][17]	= StartTime
;						$aPrintJobInfo[$i][18]	= Status
;						$aPrintJobInfo[$i][19]	= StatusMask
;						$aPrintJobInfo[$i][20]	= TimeSubmitted
;						$aPrintJobInfo[$i][21]	= TotalPages
;						$aPrintJobInfo[$i][22]	= UntilTime
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information.
;											2 - $colItems isnt an object.
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetPrintJobs(ByRef $aPrintJobInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aPrintJobInfo[1][23], $i = 1

	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_PrintJob", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aPrintJobInfo[UBound($aPrintJobInfo) + 1][23]
			$aPrintJobInfo[$i][0]	= $objItem.Name
			$aPrintJobInfo[$i][1]	= $objItem.DataType
			$aPrintJobInfo[$i][2]	= $objItem.Document
			$aPrintJobInfo[$i][3]	= $objItem.DriverName
			$aPrintJobInfo[$i][4]	= $objItem.Description
			$aPrintJobInfo[$i][5]	= __StringToDate($objItem.ElapsedTime)
			$aPrintJobInfo[$i][6]	= $objItem.HostPrintQueue
			$aPrintJobInfo[$i][7]	= $objItem.JobId
			$aPrintJobInfo[$i][8]	= $objItem.JobStatus
			$aPrintJobInfo[$i][9]	= $objItem.Name
			$aPrintJobInfo[$i][10]	= $objItem.Notify
			$aPrintJobInfo[$i][11]	= $objItem.Owner
			$aPrintJobInfo[$i][12]	= $objItem.PagesPrinted
			$aPrintJobInfo[$i][13]	= $objItem.Parameters
			$aPrintJobInfo[$i][14]	= $objItem.PrintProcessor
			$aPrintJobInfo[$i][15]	= $objItem.Priority
			$aPrintJobInfo[$i][16]	= $objItem.Size
			$aPrintJobInfo[$i][17]	= __StringToDate($objItem.StartTime)
			$aPrintJobInfo[$i][18]	= $objItem.Status
			$aPrintJobInfo[$i][19]	= $objItem.StatusMask
			$aPrintJobInfo[$i][20]	= __StringToDate($objItem.TimeSubmitted)
			$aPrintJobInfo[$i][21]	= $objItem.TotalPages
			$aPrintJobInfo[$i][22]	= __StringToDate($objItem.UntilTime)
			$i += 1
		Next
		$aPrintJobInfo[0][0] = UBound($aPrintJobInfo) - 1
		If $aPrintJobInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetPrintJobs

;===============================================================================
; Description:      Returns the Process information in an array.
; Parameter(s):     $aProcessInfo - By Reference - Process Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Process Information.
;						$aProcessInfo[0][0]   = Number of Processes
;						$aProcessInfo[$i][0]  = Name ($i starts at 1)
;						$aProcessInfo[$i][1]  = Command Line
;						$aProcessInfo[$i][2]  = Creation Class Name
;						$aProcessInfo[$i][3]  = Creation Date
;						$aProcessInfo[$i][4]  = Description
;						$aProcessInfo[$i][5]  = CS Creation Class Name
;						$aProcessInfo[$i][6]  = CS Name
;						$aProcessInfo[$i][7]  = Executable Path
;						$aProcessInfo[$i][8]  = Execution State
;						$aProcessInfo[$i][9]  = Handle
;						$aProcessInfo[$i][10] = Handle Count
;						$aProcessInfo[$i][11] = Kernel Mode Time
;						$aProcessInfo[$i][12] = Maximum Working Set Size
;						$aProcessInfo[$i][13] = Minimum Working Set Size
;						$aProcessInfo[$i][14] = OS Creation Class Name
;						$aProcessInfo[$i][15] = OS Name
;						$aProcessInfo[$i][16] = Other Operation Count
;						$aProcessInfo[$i][17] = Other Transfer Count
;						$aProcessInfo[$i][18] = Page Faults
;						$aProcessInfo[$i][19] = Page File Usage
;						$aProcessInfo[$i][20] = Parent Process ID
;						$aProcessInfo[$i][21] = Peak Page File Usage
;						$aProcessInfo[$i][22] = Peak Virtual Size
;						$aProcessInfo[$i][23] = Peak Working Set Size
;						$aProcessInfo[$i][24] = Priority
;						$aProcessInfo[$i][25] = Private Page Count
;						$aProcessInfo[$i][26] = Process ID
;						$aProcessInfo[$i][27] = Quota Non Paged Pool Usage
;						$aProcessInfo[$i][28] = Quota Paged Pool Usage
;						$aProcessInfo[$i][29] = Quota Peak Non Paged Pool Usage
;						$aProcessInfo[$i][30] = Quota Peak Paged Pool Usage
;						$aProcessInfo[$i][31] = Read Operation Count
;						$aProcessInfo[$i][32] = Read Transfer Count
;						$aProcessInfo[$i][33] = Session ID
;						$aProcessInfo[$i][34] = Status
;						$aProcessInfo[$i][35] = Thread Count
;						$aProcessInfo[$i][36] = User Mode Time
;						$aProcessInfo[$i][37] = Virtual Size
;						$aProcessInfo[$i][38] = Windows Version
;						$aProcessInfo[$i][39] = Working Set Size
;						$aProcessInfo[$i][40] = Write Operation Count
;						$aProcessInfo[$i][41] = Write Transfer Count
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetProcesses(ByRef $aProcessInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aProcessInfo[1][42], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Process", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aProcessInfo[UBound($aProcessInfo) + 1][42]
			$aProcessInfo[$i][0]  = $objItem.Name
			$aProcessInfo[$i][1]  = $objItem.CommandLine
			$aProcessInfo[$i][2]  = $objItem.CreationClassName
			$aProcessInfo[$i][3]  = __StringToDate($objItem.CreationDate)
			$aProcessInfo[$i][4]  = $objItem.Description
			$aProcessInfo[$i][5]  = $objItem.CSCreationClassName
			$aProcessInfo[$i][6]  = $objItem.CSName
			$aProcessInfo[$i][7]  = $objItem.ExecutablePath
			$aProcessInfo[$i][8]  = $objItem.ExecutionState
			$aProcessInfo[$i][9]  = $objItem.Handle
			$aProcessInfo[$i][10] = $objItem.HandleCount
			$aProcessInfo[$i][11] = $objItem.KernelModeTime
			$aProcessInfo[$i][12] = $objItem.MaximumWorkingSetSize
			$aProcessInfo[$i][13] = $objItem.MinimumWorkingSetSize
			$aProcessInfo[$i][14] = $objItem.OSCreationClassName
			$aProcessInfo[$i][15] = $objItem.OSName
			$aProcessInfo[$i][16] = $objItem.OtherOperationCount
			$aProcessInfo[$i][17] = $objItem.OtherTransferCount
			$aProcessInfo[$i][18] = $objItem.PageFaults
			$aProcessInfo[$i][19] = $objItem.PageFileUsage
			$aProcessInfo[$i][20] = $objItem.ParentProcessId
			$aProcessInfo[$i][21] = $objItem.PeakPageFileUsage
			$aProcessInfo[$i][22] = $objItem.PeakVirtualSize
			$aProcessInfo[$i][23] = $objItem.PeakWorkingSetSize
			$aProcessInfo[$i][24] = $objItem.Priority
			$aProcessInfo[$i][25] = $objItem.PrivatePageCount
			$aProcessInfo[$i][26] = $objItem.ProcessId
			$aProcessInfo[$i][27] = $objItem.QuotaNonPagedPoolUsage
			$aProcessInfo[$i][28] = $objItem.QuotaPagedPoolUsage
			$aProcessInfo[$i][29] = $objItem.QuotaPeakNonPagedPoolUsage
			$aProcessInfo[$i][30] = $objItem.QuotaPeakPagedPoolUsage
			$aProcessInfo[$i][31] = $objItem.ReadOperationCount
			$aProcessInfo[$i][32] = $objItem.ReadTransferCount
			$aProcessInfo[$i][33] = $objItem.SessionId
			$aProcessInfo[$i][34] = $objItem.Status
			$aProcessInfo[$i][35] = $objItem.ThreadCount
			$aProcessInfo[$i][36] = $objItem.UserModeTime
			$aProcessInfo[$i][37] = $objItem.VirtualSize
			$aProcessInfo[$i][38] = $objItem.WindowsVersion
			$aProcessInfo[$i][39] = $objItem.WorkingSetSize
			$aProcessInfo[$i][40] = $objItem.WriteOperationCount
			$aProcessInfo[$i][41] = $objItem.WriteTransferCount
			$i += 1
		Next
		$aProcessInfo[0][0] = UBound($aProcessInfo) - 1
		If $aProcessInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetProcesses

;===============================================================================
; Description:      Returns the services information in an array.
; Parameter(s):     $aServicesInfo - By Reference - Services Information array.
;					$sState - OPTIONAL - Accepted values 'All' or 'Stopped' or
;										'Running'
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Services Information.
;						$aServicesInfo[0][0]   = Number of Services
;						$aServicesInfo[$i][0]  = Name ($i starts at 1)
;						$aServicesInfo[$i][1]  = Accept Pause
;						$aServicesInfo[$i][2]  = Accept Stop
;						$aServicesInfo[$i][3]  = Check Point
;						$aServicesInfo[$i][4]  = Description
;						$aServicesInfo[$i][5]  = Creation Class Name
;						$aServicesInfo[$i][6]  = Desktop Interact
;						$aServicesInfo[$i][7]  = Display Name
;						$aServicesInfo[$i][8]  = Error Control
;						$aServicesInfo[$i][9]  = Exit Code
;						$aServicesInfo[$i][10] = Path Name
;						$aServicesInfo[$i][11] = Process ID
;						$aServicesInfo[$i][12] = Service Specific Exit Code
;						$aServicesInfo[$i][13] = Service Type
;						$aServicesInfo[$i][14] = Started
;						$aServicesInfo[$i][15] = Start Mode
;						$aServicesInfo[$i][16] = Start Name
;						$aServicesInfo[$i][17] = State
;						$aServicesInfo[$i][18] = Status
;						$aServicesInfo[$i][19] = System Creation Class Name
;						$aServicesInfo[$i][20] = System Name
;						$aServicesInfo[$i][21] = Tag ID
;						$aServicesInfo[$i][22] = Wait Hint
;
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetServices(ByRef $aServicesInfo, $sState = "All")
	Local $cI_Compname = @ComputerName, $wbemFlagReturnImmediately = 0x10, $wbemFlagForwardOnly = 0x20
	Local $colItems, $objWMIService, $objItem
	Dim $aServicesInfo[1][23], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Service", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			If $sState <> "All" Then
				If $sState = "Stopped" AND $objItem.State <> "Stopped" Then ContinueLoop
				If $sState = "Running" AND $objItem.State <> "Running" Then ContinueLoop
			EndIf
			ReDim $aServicesInfo[UBound($aServicesInfo) + 1][23]
			$aServicesInfo[$i][0]  = $objItem.Name
			$aServicesInfo[$i][1]  = $objItem.AcceptPause
			$aServicesInfo[$i][2]  = $objItem.AcceptStop
			$aServicesInfo[$i][3]  = $objItem.CheckPoint
			$aServicesInfo[$i][4]  = $objItem.Description
			$aServicesInfo[$i][5]  = $objItem.CreationClassName
			$aServicesInfo[$i][6]  = $objItem.DesktopInteract
			$aServicesInfo[$i][7]  = $objItem.DisplayName
			$aServicesInfo[$i][8]  = $objItem.ErrorControl
			$aServicesInfo[$i][9]  = $objItem.ExitCode
			$aServicesInfo[$i][10] = $objItem.PathName
			$aServicesInfo[$i][11] = $objItem.ProcessId
			$aServicesInfo[$i][12] = $objItem.ServiceSpecificExitCode
			$aServicesInfo[$i][13] = $objItem.ServiceType
			$aServicesInfo[$i][14] = $objItem.Started
			$aServicesInfo[$i][15] = $objItem.StartMode
			$aServicesInfo[$i][16] = $objItem.StartName
			$aServicesInfo[$i][17] = $objItem.State
			$aServicesInfo[$i][18] = $objItem.Status
			$aServicesInfo[$i][19] = $objItem.SystemCreationClassName
			$aServicesInfo[$i][20] = $objItem.SystemName
			$aServicesInfo[$i][21] = $objItem.TagId
			$aServicesInfo[$i][22] = $objItem.WaitHint
			$i += 1
		Next
		$aServicesInfo[0][0] = UBound($aServicesInfo) - 1
		If $aServicesInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetServices

;===============================================================================
; Description:      Returns the Shares and information in an array.
; Parameter(s):     $aShareInfo - By Reference - Shares and Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Share Information.
;						$aShareInfo[0][0]   = Number of Shares
;						$aShareInfo[$i][0]  = Name ($i starts at 1)
;						$aShareInfo[$i][1]  = Access Mask
;						$aShareInfo[$i][2]  = Allow Maximum
;						$aShareInfo[$i][3]  = Maximum Allowed
;						$aShareInfo[$i][4]  = Description
;						$aShareInfo[$i][5]  = Path
;						$aShareInfo[$i][6]  = Status
;						$aShareInfo[$i][7]  = Type
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetShares(ByRef $aShareInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aShareInfo[1][8], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Share", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aShareInfo[UBound($aShareInfo) + 1][8]
			$aShareInfo[$i][0]  = $objItem.Name
			$aShareInfo[$i][1]  = $objItem.AccessMask
			$aShareInfo[$i][2]  = $objItem.AllowMaximum
			$aShareInfo[$i][3]  = $objItem.MaximumAllowed
			$aShareInfo[$i][4]  = $objItem.Description
			$aShareInfo[$i][5]  = $objItem.Path
			$aShareInfo[$i][6]  = $objItem.Status
			$aShareInfo[$i][7]  = $objItem.Type
			$i += 1
		Next
		$aShareInfo[0][0] = UBound($aShareInfo) - 1
		If $aShareInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetShares

;===============================================================================
; Description:      Returns the Software information in an array.
; Parameter(s):     $aSoftwareInfo - By Reference - Software Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Software Information.
;						$aSoftwareInfo[0][0]   = Number of Software Installed
;						$aSoftwareInfo[$i][0]  = Name ($i starts at 1)
;						$aSoftwareInfo[$i][1]  = Version
;						$aSoftwareInfo[$i][2]  = Publisher
;						$aSoftwareInfo[$i][3]  = Uninstall String
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetSoftware(ByRef $aSoftwareInfo)
	Local Const $UnInstKey	= "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
	Local $i = 1
	Dim $aSoftwareInfo[1][4]
	
	While 1
		$AppKey	= RegEnumKey($UnInstKey, $i)
		If @error <> 0 Then ExitLoop
		ReDim $aSoftwareInfo[UBound($aSoftwareInfo) + 1][4]
		$aSoftwareInfo[$i][0]	= StringStripWS(StringReplace(RegRead($UnInstKey & "\" & $AppKey, "DisplayName"), " (remove only)", ""), 3)
		$aSoftwareInfo[$i][1]	= StringStripWS(RegRead($UnInstKey & "\" & $AppKey, "DisplayVersion"), 3)
		$aSoftwareInfo[$i][2]	= StringStripWS(RegRead($UnInstKey & "\" & $AppKey, "Publisher"), 3)
		$aSoftwareInfo[$i][3]	= StringStripWS(RegRead($UnInstKey & "\" & $AppKey, "UninstallString"), 3)
		$i += 1
	WEnd
	
	$aSoftwareInfo[0][0] = UBound($aSoftwareInfo, 1) - 1
	If $aSoftwareInfo[0][0] < 1 Then
		SetError(1, 1, 0)
	EndIf
EndFunc

;===============================================================================
; Description:      Returns the startup information in an array.
; Parameter(s):     $aStartupInfo - By Reference - Startup Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Startup Information.
;						$aStartupInfo[0][0]   = Number of Startups
;						$aStartupInfo[$i][0]  = Name ($i starts at 1)
;						$aStartupInfo[$i][1]  = User
;						$aStartupInfo[$i][2]  = Location
;						$aStartupInfo[$i][3]  = Command
;						$aStartupInfo[$i][4]  = Description
;						$aStartupInfo[$i][5]  = Setting ID
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetStartup(ByRef $aStartupInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aStartupInfo[1][6], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_StartupCommand", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aStartupInfo[UBound($aStartupInfo) + 1][6]
			$aStartupInfo[$i][0] = $objItem.Name
			$aStartupInfo[$i][1] = $objItem.User
			$aStartupInfo[$i][2] = $objItem.Location
			$aStartupInfo[$i][3] = $objItem.Command
			$aStartupInfo[$i][4] = $objItem.Description
			$aStartupInfo[$i][5] = $objItem.SettingID
			$i += 1
		Next
		$aStartupInfo[0][0] = UBound($aStartupInfo) - 1
		If $aStartupInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetStartup

;===============================================================================
; Description:      Returns the Thread information in an array.
; Parameter(s):     $aThreadInfo - By Reference - Thread Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Thread Information.
;						$aThreadInfo[0][0]   = Number of Threads
;						$aThreadInfo[$i][0]  = Name ($i starts at 1)
;						$aThreadInfo[$i][1]  = Creation Class Name
;						$aThreadInfo[$i][2]  = CS Creation Class Name
;						$aThreadInfo[$i][3]  = CS Name
;						$aThreadInfo[$i][4]  = Description
;						$aThreadInfo[$i][5]  = Elapsed Time
;						$aThreadInfo[$i][6]  = Execution State
;						$aThreadInfo[$i][7]  = Handle
;						$aThreadInfo[$i][8]  = Kernel Mode Time
;						$aThreadInfo[$i][9]  = OS Creation Class Name
;						$aThreadInfo[$i][10] = OS Name
;						$aThreadInfo[$i][11] = Priority
;						$aThreadInfo[$i][12] = Priority Base
;						$aThreadInfo[$i][13] = Process Creation Class Name
;						$aThreadInfo[$i][14] = Process Handle
;						$aThreadInfo[$i][15] = Start Address
;						$aThreadInfo[$i][16] = Status
;						$aThreadInfo[$i][17] = Thread State
;						$aThreadInfo[$i][18] = Thread Wait Reason
;						$aThreadInfo[$i][19] = User Mode Time
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetThreads(ByRef $aThreadInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aThreadInfo[1][20], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Thread", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aThreadInfo[UBound($aThreadInfo) + 1][20]
			$aThreadInfo[$i][0]  = $objItem.Name
			$aThreadInfo[$i][1]  = $objItem.CreationClassName
			$aThreadInfo[$i][2]  = $objItem.CSCreationClassName
			$aThreadInfo[$i][3]  = $objItem.CSName
			$aThreadInfo[$i][4]  = $objItem.Description
			$aThreadInfo[$i][5]  = $objItem.ElapsedTime
			$aThreadInfo[$i][6]  = $objItem.ExecutionState
			$aThreadInfo[$i][7]  = $objItem.Handle
			$aThreadInfo[$i][8]  = $objItem.KernelModeTime
			$aThreadInfo[$i][9]  = $objItem.OSCreationClassName
			$aThreadInfo[$i][10] = $objItem.OSName
			$aThreadInfo[$i][11] = $objItem.Priority
			$aThreadInfo[$i][12] = $objItem.PriorityBase
			$aThreadInfo[$i][13] = $objItem.ProcessCreationClassName
			$aThreadInfo[$i][14] = $objItem.ProcessHandle
			$aThreadInfo[$i][15] = $objItem.StartAddress
			$aThreadInfo[$i][16] = $objItem.Status
			$aThreadInfo[$i][17] = $objItem.ThreadState
			$aThreadInfo[$i][18] = $objItem.ThreadWaitReason
			$aThreadInfo[$i][19] = $objItem.UserModeTime
			$i += 1
		Next
		$aThreadInfo[0][0] = UBound($aThreadInfo) - 1
		If $aThreadInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetThreads

;===============================================================================
; Description:      Returns the Users and information in an array.
; Parameter(s):     $aUserInfo - By Reference - User Name and Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of User Information.
;						$aUserInfo[0][0]   = Number of Users
;						$aUserInfo[$i][0]  = Name ($i starts at 1)
;						$aUserInfo[$i][1]  = Doamin
;						$aUserInfo[$i][2]  = Status
;						$aUserInfo[$i][3]  = Local Account
;						$aUserInfo[$i][4]  = Description
;						$aUserInfo[$i][5]  = SIDType
;						$aUserInfo[$i][6]  = SID
;						$aUserInfo[$i][7]  = Full Name
;						$aUserInfo[$i][8]  = Disabled
;						$aUserInfo[$i][9]  = Lockout
;						$aUserInfo[$i][10] = Password Changeable
;						$aUserInfo[$i][11] = Password Expires
;						$aUserInfo[$i][12] = Password Required
;						$aUserInfo[$i][13] = Account Type
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetUsers(ByRef $aUserInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aUserInfo[1][14], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_UserAccount", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aUserInfo[UBound($aUserInfo) + 1][14]
			$aUserInfo[$i][0]  = $objItem.Name
			$aUserInfo[$i][1]  = $objItem.Domain
			$aUserInfo[$i][2]  = $objItem.Status
			$aUserInfo[$i][3]  = $objItem.LocalAccount
			$aUserInfo[$i][4]  = $objItem.Description
			$aUserInfo[$i][5]  = $objItem.SIDType
			$aUserInfo[$i][6]  = $objItem.SID
			$aUserInfo[$i][7]  = $objItem.FullName
			$aUserInfo[$i][8]  = $objItem.Disabled
			$aUserInfo[$i][9]  = $objItem.Lockout
			$aUserInfo[$i][10] = $objItem.PasswordChangeable
			$aUserInfo[$i][11] = $objItem.PasswordExpires
			$aUserInfo[$i][12] = $objItem.PasswordRequired
			$aUserInfo[$i][13] = $objItem.AccountType
			$i += 1
		Next
		$aUserInfo[0][0] = UBound($aUserInfo) - 1
		If $aUserInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetUsers
#endregion Software Functions

#region Hardware Functions
;===============================================================================
; Description:      Returns the Battery information in an array.
; Parameter(s):     $aBatteryInfo - By Reference - Battery Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Battery Information.
;						$aBatteryInfo[$i][0]	= Name
;						$aBatteryInfo[$i][1]	= Availability
;						$aBatteryInfo[$i][2]	= BatteryRechargeTime
;						$aBatteryInfo[$i][3]	= BatteryStatus
;						$aBatteryInfo[$i][4]	= Description
;						$aBatteryInfo[$i][5]	= Chemistry
;						$aBatteryInfo[$i][6]	= ConfigManagerErrorCode
;						$aBatteryInfo[$i][7]	= ConfigManagerUserConfig
;						$aBatteryInfo[$i][8]	= CreationClassName
;						$aBatteryInfo[$i][9]	= DesignCapacity
;						$aBatteryInfo[$i][10]	= DesignVoltage
;						$aBatteryInfo[$i][11]	= DeviceID
;						$aBatteryInfo[$i][12]	= ErrorCleared
;						$aBatteryInfo[$i][13]	= ErrorDescription
;						$aBatteryInfo[$i][14]	= EstimatedChargeRemaining
;						$aBatteryInfo[$i][15]	= EstimatedRunTime
;						$aBatteryInfo[$i][16]	= ExpectedBatteryLife
;						$aBatteryInfo[$i][17]	= ExpectedLife
;						$aBatteryInfo[$i][18]	= FullChargeCapacity
;						$aBatteryInfo[$i][19]	= LastErrorCode
;						$aBatteryInfo[$i][20]	= MaxRechargeTime
;						$aBatteryInfo[$i][21]	= PNPDeviceID
;						$aBatteryInfo[$i][22]	= PowerManagementCapabilities
;						$aBatteryInfo[$i][23]	= PowerManagementSupported
;						$aBatteryInfo[$i][24]	= SmartBatteryVersion
;						$aBatteryInfo[$i][25]	= Status
;						$aBatteryInfo[$i][26]	= StatusInfo
;						$aBatteryInfo[$i][27]	= SystemCreationClassName
;						$aBatteryInfo[$i][28]	= SystemName
;						$aBatteryInfo[$i][29]	= TimeOnBattery
;						$aBatteryInfo[$i][30]	= TimeToFullCharge
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information.
;											2 - $colItems isnt an object.
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetBattery(ByRef $aBatteryInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aBatteryInfo[1][31], $i = 1

	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Battery", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aBatteryInfo[UBound($aBatteryInfo) + 1][31]
			$aBatteryInfo[$i][0]	= $objItem.Name
			$aBatteryInfo[$i][1]	= $objItem.Availability
			$aBatteryInfo[$i][2]	= $objItem.BatteryRechargeTime
			$aBatteryInfo[$i][3]	= $objItem.BatteryStatus
			$aBatteryInfo[$i][4]	= $objItem.Description
			$aBatteryInfo[$i][5]	= $objItem.Chemistry
			$aBatteryInfo[$i][6]	= $objItem.ConfigManagerErrorCode
			$aBatteryInfo[$i][7]	= $objItem.ConfigManagerUserConfig
			$aBatteryInfo[$i][8]	= $objItem.CreationClassName
			$aBatteryInfo[$i][9]	= $objItem.DesignCapacity
			$aBatteryInfo[$i][10]	= $objItem.DesignVoltage
			$aBatteryInfo[$i][11]	= $objItem.DeviceID
			$aBatteryInfo[$i][12]	= $objItem.ErrorCleared
			$aBatteryInfo[$i][13]	= $objItem.ErrorDescription
			$aBatteryInfo[$i][14]	= $objItem.EstimatedChargeRemaining
			$aBatteryInfo[$i][15]	= $objItem.EstimatedRunTime
			$aBatteryInfo[$i][16]	= $objItem.ExpectedBatteryLife
			$aBatteryInfo[$i][17]	= $objItem.ExpectedLife
			$aBatteryInfo[$i][18]	= $objItem.FullChargeCapacity
			$aBatteryInfo[$i][19]	= $objItem.LastErrorCode
			$aBatteryInfo[$i][20]	= $objItem.MaxRechargeTime
			$aBatteryInfo[$i][21]	= $objItem.PNPDeviceID
			$aBatteryInfo[$i][22]	= $objItem.PowerManagementCapabilities(0)
			$aBatteryInfo[$i][23]	= $objItem.PowerManagementSupported
			$aBatteryInfo[$i][24]	= $objItem.SmartBatteryVersion
			$aBatteryInfo[$i][25]	= $objItem.Status
			$aBatteryInfo[$i][26]	= $objItem.StatusInfo
			$aBatteryInfo[$i][27]	= $objItem.SystemCreationClassName
			$aBatteryInfo[$i][28]	= $objItem.SystemName
			$aBatteryInfo[$i][29]	= $objItem.TimeOnBattery
			$aBatteryInfo[$i][30]	= $objItem.TimeToFullCharge
			$i += 1
		Next
		$aBatteryInfo[0][0] = UBound($aBatteryInfo) - 1
		If $aBatteryInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetBattery

;===============================================================================
; Description:      Returns the BIOS information in an array.
; Parameter(s):     $aBIOSInfo - By Reference - BIOS Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of BIOS Information.
;						$aBIOSInfo[0][0]   = Number of BIOSs
;						$aBIOSInfo[$i][0]  = Name ($i starts at 1)
;						$aBIOSInfo[$i][1]  = Status
;						$aBIOSInfo[$i][2]  = BIOS Characteristics
;						$aBIOSInfo[$i][3]  = BIOS Version
;						$aBIOSInfo[$i][4]  = Description
;						$aBIOSInfo[$i][5]  = Build Number
;						$aBIOSInfo[$i][6]  = Code Set
;						$aBIOSInfo[$i][7]  = Current Language
;						$aBIOSInfo[$i][8]  = Identification Code
;						$aBIOSInfo[$i][9]  = Installable Languages
;						$aBIOSInfo[$i][10] = Language Edition
;						$aBIOSInfo[$i][11] = List Of Languages
;						$aBIOSInfo[$i][12] = Manufacturer
;						$aBIOSInfo[$i][13] = Other Target OS
;						$aBIOSInfo[$i][14] = Primary BIOS
;						$aBIOSInfo[$i][15] = Release Date
;						$aBIOSInfo[$i][16] = Serial Number
;						$aBIOSInfo[$i][17] = SM BIOS BIOS Version
;						$aBIOSInfo[$i][18] = SM BIOS Major Version
;						$aBIOSInfo[$i][19] = SM BIOS Minor Version
;						$aBIOSInfo[$i][20] = SM BIOS Present
;						$aBIOSInfo[$i][21] = Software Element ID
;						$aBIOSInfo[$i][22] = Software Element State
;						$aBIOSInfo[$i][23] = Target Operating System
;						$aBIOSInfo[$i][24] = Version
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetBIOS(ByRef $aBIOSInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aBIOSInfo[1][25], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_BIOS", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aBIOSInfo[UBound($aBIOSInfo) + 1][25]
			$aBIOSInfo[$i][0]  = $objItem.Name
			$aBIOSInfo[$i][1]  = $objItem.Status
			$aBIOSInfo[$i][2]  = $objItem.BiosCharacteristics(0)
			$aBIOSInfo[$i][3]  = $objItem.BIOSVersion(0)
			$aBIOSInfo[$i][4]  = $objItem.Description
			$aBIOSInfo[$i][5]  = $objItem.BuildNumber
			$aBIOSInfo[$i][6]  = $objItem.CodeSet
			$aBIOSInfo[$i][7]  = $objItem.CurrentLanguage
			$aBIOSInfo[$i][8]  = $objItem.IdentificationCode
			$aBIOSInfo[$i][9]  = $objItem.InstallableLanguages
			$aBIOSInfo[$i][10] = $objItem.LanguageEdition
			$aBIOSInfo[$i][11] = $objItem.ListOfLanguages(0)
			$aBIOSInfo[$i][12] = $objItem.Manufacturer
			$aBIOSInfo[$i][13] = $objItem.OtherTargetOS
			$aBIOSInfo[$i][14] = $objItem.PrimaryBIOS
			$aBIOSInfo[$i][15] = __StringToDate($objItem.ReleaseDate)
			$aBIOSInfo[$i][16] = $objItem.SerialNumber
			$aBIOSInfo[$i][17] = $objItem.SMBIOSBIOSVersion
			$aBIOSInfo[$i][18] = $objItem.SMBIOSMajorVersion
			$aBIOSInfo[$i][19] = $objItem.SMBIOSMinorVersion
			$aBIOSInfo[$i][20] = $objItem.SMBIOSPresent
			$aBIOSInfo[$i][21] = $objItem.SoftwareElementID
			$aBIOSInfo[$i][22] = $objItem.SoftwareElementState
			$aBIOSInfo[$i][23] = $objItem.TargetOperatingSystem
			$aBIOSInfo[$i][24] = $objItem.Version
			$i += 1
		Next
		$aBIOSInfo[0][0] = UBound($aBIOSInfo) - 1
		If $aBIOSInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetBIOS

;===============================================================================
; Description:      Returns the drive information based on $sDriveType in a two
;					dimensional array. First dimension is the index for each set
;					of drive information.
; Parameter(s):     $aDriveInfo - By Reference - Drive information in an array.
;					$sDriveType - 	Type of drive to return the information on.
;									Options: "ALL", "CDROM", "REMOVABLE", "FIXED",
;									"NETWORK", "RAMDISK", or "UNKNOWN"
;									Defaults to "FIXED" drives.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of drive information.
;						$aDriveInfo[0][0] = Number of Drives
;						The second dimension is as follows: ($i starts at 1)
;							[$i][0] - Drive Letter (ex. C:\)
;							[$i][1] - File System
;							[$i][2] - Label
;							[$i][3] - Serial Number
;							[$i][4] - Free Space
;							[$i][5] - Total Space
;                   On Failure - Return 0 - @error - 1
;								@extended:	 1 = DriveGetDrive		Error
;											 2 = DriveGetFileSystem Error
;											 3 = DriveGetLabel		Error
;											 4 = DriveGetSerial		Error
;											 5 = DriveSpaceFree		Error
;											 6 = DriveSpaceTotal	Error
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetDrives(ByRef $aDriveInfo, $sDriveType = "FIXED")
	Local $drive
	$drive = DriveGetDrive($sDriveType)
	If NOT @error Then
		Dim $aDriveInfo[UBound($drive)][6]
		$aDriveInfo[0][0] = $drive[0]
		For $i = 1 To $aDriveInfo[0][0] Step 1
			$aDriveInfo[$i][0] = StringUpper($drive[$i] & "\")
			$aDriveInfo[$i][1] = DriveGetFileSystem($drive[$i])
			If @error Then SetError(1, 2, 0)
			$aDriveInfo[$i][2] = DriveGetLabel($drive[$i])
			If @error Then SetError(1, 3, 0)
			$aDriveInfo[$i][3] = DriveGetSerial($drive[$i])
			If @error Then SetError(1, 4, 0)
			$aDriveInfo[$i][4] = DriveSpaceFree($drive[$i])
			If @error Then SetError(1, 5, 0)
			$aDriveInfo[$i][5] = DriveSpaceTotal($drive[$i])
			If @error Then SetError(1, 6, 0)
		Next
	Else
		SetError(1, 1, 0)
	EndIf
EndFunc ;_ComputerGetDrives

;===============================================================================
; Description:      Returns the Keyboard information in an array.
; Parameter(s):     $aKeyboardInfo - By Reference - Keyboard Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Keyboard Information.
;						$aKeyboardInfo[0][0]   = Number of Keyboards
;						$aKeyboardInfo[$i][0]  = Name ($i starts at 1)
;						$aKeyboardInfo[$i][1]  = Availability
;						$aKeyboardInfo[$i][2]  = Config Manager Error Code
;						$aKeyboardInfo[$i][3]  = Config Manager User Config
;						$aKeyboardInfo[$i][4]  = Description
;						$aKeyboardInfo[$i][5]  = Creation Class Name
;						$aKeyboardInfo[$i][6]  = Device ID
;						$aKeyboardInfo[$i][7]  = Error Cleared
;						$aKeyboardInfo[$i][8]  = Error Description
;						$aKeyboardInfo[$i][9]  = Is Locked
;						$aKeyboardInfo[$i][10] = Last Error Code
;						$aKeyboardInfo[$i][11] = Layout
;						$aKeyboardInfo[$i][12] = Number Of Function Keys
;						$aKeyboardInfo[$i][13] = Password
;						$aKeyboardInfo[$i][14] = PNP Device ID
;						$aKeyboardInfo[$i][15] = Power Management Capabilities
;						$aKeyboardInfo[$i][16] = Power Management Supported
;						$aKeyboardInfo[$i][17] = Status
;						$aKeyboardInfo[$i][18] = Status Info
;						$aKeyboardInfo[$i][19] = System Creation Class Name
;						$aKeyboardInfo[$i][20] = System Name
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetKeyboard(ByRef $aKeyboardInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aKeyboardInfo[1][21], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Keyboard", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aKeyboardInfo[UBound($aKeyboardInfo) + 1][21]
			$aKeyboardInfo[$i][0]  = $objItem.Name
			$aKeyboardInfo[$i][1]  = $objItem.Availability
			$aKeyboardInfo[$i][2]  = $objItem.ConfigManagerErrorCode
			$aKeyboardInfo[$i][3]  = $objItem.ConfigManagerUserConfig
			$aKeyboardInfo[$i][4]  = $objItem.Description
			$aKeyboardInfo[$i][5]  = $objItem.CreationClassName
			$aKeyboardInfo[$i][6]  = $objItem.DeviceID
			$aKeyboardInfo[$i][7]  = $objItem.ErrorCleared
			$aKeyboardInfo[$i][8]  = $objItem.ErrorDescription
			$aKeyboardInfo[$i][9]  = $objItem.IsLocked
			$aKeyboardInfo[$i][10] = $objItem.LastErrorCode
			$aKeyboardInfo[$i][11] = $objItem.Layout
			$aKeyboardInfo[$i][12] = $objItem.NumberOfFunctionKeys
			$aKeyboardInfo[$i][13] = $objItem.Password
			$aKeyboardInfo[$i][14] = $objItem.PNPDeviceID
			$aKeyboardInfo[$i][15] = $objItem.PowerManagementCapabilities(0)
			$aKeyboardInfo[$i][16] = $objItem.PowerManagementSupported
			$aKeyboardInfo[$i][17] = $objItem.Status
			$aKeyboardInfo[$i][18] = $objItem.StatusInfo
			$aKeyboardInfo[$i][19] = $objItem.SystemCreationClassName
			$aKeyboardInfo[$i][20] = $objItem.SystemName
			$i += 1
		Next
		$aKeyboardInfo[0][0] = UBound($aKeyboardInfo) - 1
		If $aKeyboardInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetKeyboard

;===============================================================================
; Description:      Returns the Memory information in an array.
; Parameter(s):     $aMemoryInfo - By Reference - Memory Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Memory Information.
;						$aMemoryInfo[$i][0]		= Name
;						$aMemoryInfo[$i][1]		= BankLabel
;						$aMemoryInfo[$i][2]		= Capacity
;						$aMemoryInfo[$i][3]		= CreationClassName
;						$aMemoryInfo[$i][4]		= Description
;						$aMemoryInfo[$i][5]		= DataWidth
;						$aMemoryInfo[$i][6]		= DeviceLocator
;						$aMemoryInfo[$i][7]		= FormFactor
;						$aMemoryInfo[$i][8]		= HotSwappable
;						$aMemoryInfo[$i][9]		= InterleaveDataDepth
;						$aMemoryInfo[$i][10]	= InterleavePosition
;						$aMemoryInfo[$i][11]	= Manufacturer
;						$aMemoryInfo[$i][12]	= MemoryType
;						$aMemoryInfo[$i][13]	= Model
;						$aMemoryInfo[$i][14]	= OtherIdentifyingInfo
;						$aMemoryInfo[$i][15]	= PartNumber
;						$aMemoryInfo[$i][16]	= PositionInRow
;						$aMemoryInfo[$i][17]	= PoweredOn
;						$aMemoryInfo[$i][18]	= Removable
;						$aMemoryInfo[$i][19]	= Replaceable
;						$aMemoryInfo[$i][20]	= SerialNumber
;						$aMemoryInfo[$i][21]	= SKU
;						$aMemoryInfo[$i][22]	= Speed
;						$aMemoryInfo[$i][23]	= Status
;						$aMemoryInfo[$i][24]	= Tag
;						$aMemoryInfo[$i][25]	= TotalWidth
;						$aMemoryInfo[$i][26]	= TypeDetail
;						$aMemoryInfo[$i][27]	= Version
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information.
;											2 - $colItems isnt an object.
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetMemory(ByRef $aMemoryInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aMemoryInfo[1][28], $i = 1

	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_PhysicalMemory", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aMemoryInfo[UBound($aMemoryInfo) + 1][28]
			$aMemoryInfo[$i][0]		= $objItem.Name
			$aMemoryInfo[$i][1]		= $objItem.BankLabel
			$aMemoryInfo[$i][2]		= $objItem.Capacity
			$aMemoryInfo[$i][3]		= $objItem.CreationClassName
			$aMemoryInfo[$i][4]		= $objItem.Description
			$aMemoryInfo[$i][5]		= $objItem.DataWidth
			$aMemoryInfo[$i][6]		= $objItem.DeviceLocator
			$aMemoryInfo[$i][7]		= $objItem.FormFactor
			$aMemoryInfo[$i][8]		= $objItem.HotSwappable
			$aMemoryInfo[$i][9]		= $objItem.InterleaveDataDepth
			$aMemoryInfo[$i][10]	= $objItem.InterleavePosition
			$aMemoryInfo[$i][11]	= $objItem.Manufacturer
			$aMemoryInfo[$i][12]	= $objItem.MemoryType
			$aMemoryInfo[$i][13]	= $objItem.Model
			$aMemoryInfo[$i][14]	= $objItem.OtherIdentifyingInfo
			$aMemoryInfo[$i][15]	= $objItem.PartNumber
			$aMemoryInfo[$i][16]	= $objItem.PositionInRow
			$aMemoryInfo[$i][17]	= $objItem.PoweredOn
			$aMemoryInfo[$i][18]	= $objItem.Removable
			$aMemoryInfo[$i][19]	= $objItem.Replaceable
			$aMemoryInfo[$i][20]	= $objItem.SerialNumber
			$aMemoryInfo[$i][21]	= $objItem.SKU
			$aMemoryInfo[$i][22]	= $objItem.Speed
			$aMemoryInfo[$i][23]	= $objItem.Status
			$aMemoryInfo[$i][24]	= $objItem.Tag
			$aMemoryInfo[$i][25]	= $objItem.TotalWidth
			$aMemoryInfo[$i][26]	= $objItem.TypeDetail
			$aMemoryInfo[$i][27]	= $objItem.Version
			$i += 1
		Next
		$aMemoryInfo[0][0] = UBound($aMemoryInfo) - 1
		If $aMemoryInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetMemory

;===============================================================================
; Description:      Returns the Monitor information in an array.
; Parameter(s):     $aMonitorInfo - By Reference - Monitor Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Monitor Information.
;						$aMonitorInfo[$i][0]	= Name
;						$aMonitorInfo[$i][1]	= Availability
;						$aMonitorInfo[$i][2]	= Bandwidth
;						$aMonitorInfo[$i][3]	= ConfigManagerErrorCode
;						$aMonitorInfo[$i][4]	= Description
;						$aMonitorInfo[$i][5]	= ConfigManagerUserConfig
;						$aMonitorInfo[$i][6]	= CreationClassName
;						$aMonitorInfo[$i][7]	= DeviceID
;						$aMonitorInfo[$i][8]	= DisplayType
;						$aMonitorInfo[$i][9]	= ErrorCleared
;						$aMonitorInfo[$i][10]	= ErrorDescription
;						$aMonitorInfo[$i][11]	= IsLocked
;						$aMonitorInfo[$i][12]	= LastErrorCode
;						$aMonitorInfo[$i][13]	= MonitorManufacturer
;						$aMonitorInfo[$i][14]	= MonitorType
;						$aMonitorInfo[$i][15]	= PixelsPerXLogicalInch
;						$aMonitorInfo[$i][16]	= PixelsPerYLogicalInch
;						$aMonitorInfo[$i][17]	= PNPDeviceID
;						$aMonitorInfo[$i][18]	= PowerManagementCapabilities
;						$aMonitorInfo[$i][19]	= PowerManagementSupported
;						$aMonitorInfo[$i][20]	= ScreenHeight
;						$aMonitorInfo[$i][21]	= ScreenWidth
;						$aMonitorInfo[$i][22]	= Status
;						$aMonitorInfo[$i][23]	= StatusInfo
;						$aMonitorInfo[$i][24]	= SystemCreationClassName
;						$aMonitorInfo[$i][25]	= SystemName
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information.
;											2 - $colItems isnt an object.
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetMonitors(ByRef $aMonitorInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aMonitorInfo[1][26], $i = 1

	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_DesktopMonitor", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aMonitorInfo[UBound($aMonitorInfo) + 1][26]
			$aMonitorInfo[$i][0]	= $objItem.Name
			$aMonitorInfo[$i][1]	= $objItem.Availability
			$aMonitorInfo[$i][2]	= $objItem.Bandwidth
			$aMonitorInfo[$i][3]	= $objItem.ConfigManagerErrorCode
			$aMonitorInfo[$i][4]	= $objItem.Description
			$aMonitorInfo[$i][5]	= $objItem.ConfigManagerUserConfig
			$aMonitorInfo[$i][6]	= $objItem.CreationClassName
			$aMonitorInfo[$i][7]	= $objItem.DeviceID
			$aMonitorInfo[$i][8]	= $objItem.DisplayType
			$aMonitorInfo[$i][9]	= $objItem.ErrorCleared
			$aMonitorInfo[$i][10]	= $objItem.ErrorDescription
			$aMonitorInfo[$i][11]	= $objItem.IsLocked
			$aMonitorInfo[$i][12]	= $objItem.LastErrorCode
			$aMonitorInfo[$i][13]	= $objItem.MonitorManufacturer
			$aMonitorInfo[$i][14]	= $objItem.MonitorType
			$aMonitorInfo[$i][15]	= $objItem.PixelsPerXLogicalInch
			$aMonitorInfo[$i][16]	= $objItem.PixelsPerYLogicalInch
			$aMonitorInfo[$i][17]	= $objItem.PNPDeviceID
			$aMonitorInfo[$i][18]	= $objItem.PowerManagementCapabilities(0)
			$aMonitorInfo[$i][19]	= $objItem.PowerManagementSupported
			$aMonitorInfo[$i][20]	= $objItem.ScreenHeight
			$aMonitorInfo[$i][21]	= $objItem.ScreenWidth
			$aMonitorInfo[$i][22]	= $objItem.Status
			$aMonitorInfo[$i][23]	= $objItem.StatusInfo
			$aMonitorInfo[$i][24]	= $objItem.SystemCreationClassName
			$aMonitorInfo[$i][25]	= $objItem.SystemName
			$i += 1
		Next
		$aMonitorInfo[0][0] = UBound($aMonitorInfo) - 1
		If $aMonitorInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetMonitors

;===============================================================================
; Description:      Returns the Motherboard information in an array.
; Parameter(s):     $aMotherboardInfo - By Reference - Motherboard Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Motherboard Information.
;						$aMotherboardInfo[$i][0]	= Name
;						$aMotherboardInfo[$i][1]	= Availability
;						$aMotherboardInfo[$i][2]	= ConfigManagerErrorCode
;						$aMotherboardInfo[$i][3]	= ConfigManagerUserConfig
;						$aMotherboardInfo[$i][4]	= Description
;						$aMotherboardInfo[$i][5]	= CreationClassName
;						$aMotherboardInfo[$i][6]	= DeviceID
;						$aMotherboardInfo[$i][7]	= ErrorCleared
;						$aMotherboardInfo[$i][8]	= ErrorDescription
;						$aMotherboardInfo[$i][9]	= LastErrorCode
;						$aMotherboardInfo[$i][10]	= PNPDeviceID
;						$aMotherboardInfo[$i][11]	= PowerManagementCapabilities
;						$aMotherboardInfo[$i][12]	= PowerManagementSupported
;						$aMotherboardInfo[$i][13]	= PrimaryBusType
;						$aMotherboardInfo[$i][14]	= RevisionNumber
;						$aMotherboardInfo[$i][15]	= SecondaryBusType
;						$aMotherboardInfo[$i][16]	= Status
;						$aMotherboardInfo[$i][17]	= StatusInfo
;						$aMotherboardInfo[$i][18]	= SystemCreationClassName
;						$aMotherboardInfo[$i][19]	= SystemName
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information.
;											2 - $colItems isnt an object.
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetMotherboard(ByRef $aMotherboardInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aMotherboardInfo[1][20], $i = 1

	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_MotherboardDevice", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aMotherboardInfo[UBound($aMotherboardInfo) + 1][20]
			$aMotherboardInfo[$i][0]	= $objItem.Name
			$aMotherboardInfo[$i][1]	= $objItem.Availability
			$aMotherboardInfo[$i][2]	= $objItem.ConfigManagerErrorCode
			$aMotherboardInfo[$i][3]	= $objItem.ConfigManagerUserConfig
			$aMotherboardInfo[$i][4]	= $objItem.Description
			$aMotherboardInfo[$i][5]	= $objItem.CreationClassName
			$aMotherboardInfo[$i][6]	= $objItem.DeviceID
			$aMotherboardInfo[$i][7]	= $objItem.ErrorCleared
			$aMotherboardInfo[$i][8]	= $objItem.ErrorDescription
			$aMotherboardInfo[$i][9]	= $objItem.LastErrorCode
			$aMotherboardInfo[$i][10]	= $objItem.PNPDeviceID
			$aMotherboardInfo[$i][11]	= $objItem.PowerManagementCapabilities(0)
			$aMotherboardInfo[$i][12]	= $objItem.PowerManagementSupported
			$aMotherboardInfo[$i][13]	= $objItem.PrimaryBusType
			$aMotherboardInfo[$i][14]	= $objItem.RevisionNumber
			$aMotherboardInfo[$i][15]	= $objItem.SecondaryBusType
			$aMotherboardInfo[$i][16]	= $objItem.Status
			$aMotherboardInfo[$i][17]	= $objItem.StatusInfo
			$aMotherboardInfo[$i][18]	= $objItem.SystemCreationClassName
			$aMotherboardInfo[$i][19]	= $objItem.SystemName
			$i += 1
		Next
		$aMotherboardInfo[0][0] = UBound($aMotherboardInfo) - 1
		If $aMotherboardInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetMotherboard

;===============================================================================
; Description:      Returns the Mouse information in an array.
; Parameter(s):     $aMouseInfo - By Reference - Mouse Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Mouse Information.
;						$aMouseInfo[0][0]   = Number of Mice
;						$aMouseInfo[$i][0]  = Name ($i starts at 1)
;						$aMouseInfo[$i][1]  = Availability
;						$aMouseInfo[$i][2]  = Config Manager Error Code
;						$aMouseInfo[$i][3]  = Config Manager User Config
;						$aMouseInfo[$i][4]  = Description
;						$aMouseInfo[$i][5]  = Creation Class Name
;						$aMouseInfo[$i][6]  = Device ID
;						$aMouseInfo[$i][7]  = Device Interface
;						$aMouseInfo[$i][8]  = Double Speed Threshold
;						$aMouseInfo[$i][9]  = Error Cleared
;						$aMouseInfo[$i][10] = Error Description
;						$aMouseInfo[$i][11] = Handedness
;						$aMouseInfo[$i][12] = Hardware Type
;						$aMouseInfo[$i][13] = Inf File Name
;						$aMouseInfo[$i][14] = Inf Section
;						$aMouseInfo[$i][15] = Is Locked
;						$aMouseInfo[$i][16] = Last Error Code
;						$aMouseInfo[$i][17] = Manufacturer
;						$aMouseInfo[$i][18] = Number Of Buttons
;						$aMouseInfo[$i][19] = PNP Device ID
;						$aMouseInfo[$i][20] = Pointing Type
;						$aMouseInfo[$i][21] = Power Management Capabilities
;						$aMouseInfo[$i][22] = Power Management Supported
;						$aMouseInfo[$i][23] = Quad Speed Threshold
;						$aMouseInfo[$i][24] = Resolution
;						$aMouseInfo[$i][25] = Sample Rate
;						$aMouseInfo[$i][26] = Status
;						$aMouseInfo[$i][27] = Status Info
;						$aMouseInfo[$i][28] = Synch
;						$aMouseInfo[$i][29] = System Creation Class Name
;						$aMouseInfo[$i][30] = System Name
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetMouse(ByRef $aMouseInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aMouseInfo[1][31], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_PointingDevice", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aMouseInfo[UBound($aMouseInfo) + 1][31]
			$aMouseInfo[$i][0]  = $objItem.Name
			$aMouseInfo[$i][1]  = $objItem.Availability
			$aMouseInfo[$i][2]  = $objItem.ConfigManagerErrorCode
			$aMouseInfo[$i][3]  = $objItem.ConfigManagerUserConfig
			$aMouseInfo[$i][4]  = $objItem.Description
			$aMouseInfo[$i][5]  = $objItem.CreationClassName
			$aMouseInfo[$i][6]  = $objItem.DeviceID
			$aMouseInfo[$i][7]  = $objItem.DeviceInterface
			$aMouseInfo[$i][8]  = $objItem.DoubleSpeedThreshold
			$aMouseInfo[$i][9]  = $objItem.ErrorCleared
			$aMouseInfo[$i][10] = $objItem.ErrorDescription
			$aMouseInfo[$i][11] = $objItem.Handedness
			$aMouseInfo[$i][12] = $objItem.HardwareType
			$aMouseInfo[$i][13] = $objItem.InfFileName
			$aMouseInfo[$i][14] = $objItem.InfSection
			$aMouseInfo[$i][15] = $objItem.IsLocked
			$aMouseInfo[$i][16] = $objItem.LastErrorCode
			$aMouseInfo[$i][17] = $objItem.Manufacturer
			$aMouseInfo[$i][18] = $objItem.NumberOfButtons
			$aMouseInfo[$i][19] = $objItem.PNPDeviceID
			$aMouseInfo[$i][20] = $objItem.PointingType
			$aMouseInfo[$i][21] = $objItem.PowerManagementCapabilities(0)
			$aMouseInfo[$i][22] = $objItem.PowerManagementSupported
			$aMouseInfo[$i][23] = $objItem.QuadSpeedThreshold
			$aMouseInfo[$i][24] = $objItem.Resolution
			$aMouseInfo[$i][25] = $objItem.SampleRate
			$aMouseInfo[$i][26] = $objItem.Status
			$aMouseInfo[$i][27] = $objItem.StatusInfo
			$aMouseInfo[$i][28] = $objItem.Synch
			$aMouseInfo[$i][29] = $objItem.SystemCreationClassName
			$aMouseInfo[$i][30] = $objItem.SystemName
			$i += 1
		Next
		$aMouseInfo[0][0] = UBound($aMouseInfo) - 1
		If $aMouseInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetMouse

;===============================================================================
; Description:      Returns the Network information in an array.
; Parameter(s):     $aNetworkInfo - By Reference - Network Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Network Information.
;						$aNetworkInfo[0][0]   = Number of Network Cards
;						$aNetworkInfo[$i][0]  = Name ($i starts at 1)
;						$aNetworkInfo[$i][1]  = Adapter Type
;						$aNetworkInfo[$i][2]  = Adapter Type ID
;						$aNetworkInfo[$i][3]  = Auto Sense
;						$aNetworkInfo[$i][4]  = Description
;						$aNetworkInfo[$i][5]  = Availability
;						$aNetworkInfo[$i][6]  = Config Manager Error Code
;						$aNetworkInfo[$i][7]  = Config Manager User Config
;						$aNetworkInfo[$i][8]  = Creation Class Name
;						$aNetworkInfo[$i][9]  = Device ID
;						$aNetworkInfo[$i][10] = Error Cleared
;						$aNetworkInfo[$i][11] = Error Description
;						$aNetworkInfo[$i][12] = Index
;						$aNetworkInfo[$i][13] = Installed
;						$aNetworkInfo[$i][14] = Last Error Code
;						$aNetworkInfo[$i][15] = MAC Address
;						$aNetworkInfo[$i][16] = Manufacturer
;						$aNetworkInfo[$i][17] = Max Number Controlled
;						$aNetworkInfo[$i][18] = Max Speed
;						$aNetworkInfo[$i][19] = Net Connection ID
;						$aNetworkInfo[$i][20] = Net Connection Status
;						$aNetworkInfo[$i][21] = Network Addresses
;						$aNetworkInfo[$i][22] = Permanent Address
;						$aNetworkInfo[$i][23] = PNP Device ID
;						$aNetworkInfo[$i][24] = Power Management Capabilities
;						$aNetworkInfo[$i][25] = Power Management Supported
;						$aNetworkInfo[$i][26] = Product Name
;						$aNetworkInfo[$i][27] = Service Name
;						$aNetworkInfo[$i][28] = Speed
;						$aNetworkInfo[$i][29] = Status
;						$aNetworkInfo[$i][30] = Status Info
;						$aNetworkInfo[$i][31] = System Creation Class Name
;						$aNetworkInfo[$i][32] = System Name
;						$aNetworkInfo[$i][33] = Time Of Last Reset
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetNetworkCards(ByRef $aNetworkInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aNetworkInfo[1][34], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapter", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aNetworkInfo[UBound($aNetworkInfo) + 1][34]
			$aNetworkInfo[$i][0]  = $objItem.Name
			$aNetworkInfo[$i][1]  = $objItem.AdapterType
			$aNetworkInfo[$i][2]  = $objItem.AdapterTypeId
			$aNetworkInfo[$i][3]  = $objItem.AutoSense
			$aNetworkInfo[$i][4]  = $objItem.Description
			$aNetworkInfo[$i][5]  = $objItem.Availability
			$aNetworkInfo[$i][6]  = $objItem.ConfigManagerErrorCode
			$aNetworkInfo[$i][7]  = $objItem.ConfigManagerUserConfig
			$aNetworkInfo[$i][8]  = $objItem.CreationClassName
			$aNetworkInfo[$i][9]  = $objItem.DeviceID
			$aNetworkInfo[$i][10] = $objItem.ErrorCleared
			$aNetworkInfo[$i][11] = $objItem.ErrorDescription
			$aNetworkInfo[$i][12] = $objItem.Index
			$aNetworkInfo[$i][13] = $objItem.Installed
			$aNetworkInfo[$i][14] = $objItem.LastErrorCode
			$aNetworkInfo[$i][15] = $objItem.MACAddress
			$aNetworkInfo[$i][16] = $objItem.Manufacturer
			$aNetworkInfo[$i][17] = $objItem.MaxNumberControlled
			$aNetworkInfo[$i][18] = $objItem.MaxSpeed
			$aNetworkInfo[$i][19] = $objItem.NetConnectionID
			$aNetworkInfo[$i][20] = $objItem.NetConnectionStatus
			$aNetworkInfo[$i][21] = $objItem.NetworkAddresses(0)
			$aNetworkInfo[$i][22] = $objItem.PermanentAddress
			$aNetworkInfo[$i][23] = $objItem.PNPDeviceID
			$aNetworkInfo[$i][24] = $objItem.PowerManagementCapabilities(0)
			$aNetworkInfo[$i][25] = $objItem.PowerManagementSupported
			$aNetworkInfo[$i][26] = $objItem.ProductName
			$aNetworkInfo[$i][27] = $objItem.ServiceName
			$aNetworkInfo[$i][28] = $objItem.Speed
			$aNetworkInfo[$i][29] = $objItem.Status
			$aNetworkInfo[$i][30] = $objItem.StatusInfo
			$aNetworkInfo[$i][31] = $objItem.SystemCreationClassName
			$aNetworkInfo[$i][32] = $objItem.SystemName
			$aNetworkInfo[$i][33] = __StringToDate($objItem.TimeOfLastReset)
			$i += 1
		Next
		$aNetworkInfo[0][0] = UBound($aNetworkInfo) - 1
		If $aNetworkInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetNetworkCards

;===============================================================================
; Description:      Returns the Printer information in an array.
; Parameter(s):     $aPrinterInfo - By Reference - Printer Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Printer Information.
;						$aPrinterInfo[0][0]   = Number of Printers
;						$aPrinterInfo[$i][0]  = Name ($i starts at 1)
;						$aPrinterInfo[$i][1]  = Attributes
;						$aPrinterInfo[$i][2]  = Availability
;						$aPrinterInfo[$i][3]  = Available Job Sheets
;						$aPrinterInfo[$i][4]  = Description
;						$aPrinterInfo[$i][5]  = Average Pages Per Minute
;						$aPrinterInfo[$i][6]  = Capabilities
;						$aPrinterInfo[$i][7]  = Capability Descriptions
;						$aPrinterInfo[$i][8]  = Char Sets Supported
;						$aPrinterInfo[$i][9]  = Comment
;						$aPrinterInfo[$i][10] = Config Manager Error Code
;						$aPrinterInfo[$i][11] = Config Manager User Config
;						$aPrinterInfo[$i][12] = Creation Class Name
;						$aPrinterInfo[$i][13] = Current Capabilities
;						$aPrinterInfo[$i][14] = Current CharSet
;						$aPrinterInfo[$i][15] = Current Language
;						$aPrinterInfo[$i][16] = Current Mime Type
;						$aPrinterInfo[$i][17] = Current Natural Language
;						$aPrinterInfo[$i][18] = Current Paper Type
;						$aPrinterInfo[$i][19] = Default
;						$aPrinterInfo[$i][20] = Default Capabilities
;						$aPrinterInfo[$i][21] = Default Copies
;						$aPrinterInfo[$i][22] = Default Language
;						$aPrinterInfo[$i][23] = Default Mime Type
;						$aPrinterInfo[$i][24] = Default Number Up
;						$aPrinterInfo[$i][25] = Default Paper Type
;						$aPrinterInfo[$i][26] = Default Priority
;						$aPrinterInfo[$i][27] = Detected Error State
;						$aPrinterInfo[$i][28] = Device ID
;						$aPrinterInfo[$i][29] = Direct
;						$aPrinterInfo[$i][30] = Do Complete First
;						$aPrinterInfo[$i][31] = Driver Name
;						$aPrinterInfo[$i][32] = Enable BIDI
;						$aPrinterInfo[$i][33] = Enable Dev Query Print
;						$aPrinterInfo[$i][34] = Error Cleared
;						$aPrinterInfo[$i][35] = Error Description
;						$aPrinterInfo[$i][36] = Error Information
;						$aPrinterInfo[$i][37] = Extended Detected Error State
;						$aPrinterInfo[$i][38] = Extended Printer Status
;						$aPrinterInfo[$i][39] = Hidden
;						$aPrinterInfo[$i][40] = Horizontal Resolution
;						$aPrinterInfo[$i][41] = Install Date
;						$aPrinterInfo[$i][42] = Job Count Since Last Reset
;						$aPrinterInfo[$i][43] = Keep Printed Jobs
;						$aPrinterInfo[$i][44] = Languages Supported
;						$aPrinterInfo[$i][45] = Last Error Code
;						$aPrinterInfo[$i][46] = Local
;						$aPrinterInfo[$i][47] = Location
;						$aPrinterInfo[$i][48] = Marking Technology
;						$aPrinterInfo[$i][49] = Max Copies
;						$aPrinterInfo[$i][50] = Max Number Up
;						$aPrinterInfo[$i][51] = Max Size Supported
;						$aPrinterInfo[$i][52] = Mime Types Supported
;						$aPrinterInfo[$i][53] = Natural Languages Supported
;						$aPrinterInfo[$i][54] = Network
;						$aPrinterInfo[$i][55] = Paper Sizes Supported
;						$aPrinterInfo[$i][56] = Paper Types Available
;						$aPrinterInfo[$i][57] = Parameters
;						$aPrinterInfo[$i][58] = PNP Device ID
;						$aPrinterInfo[$i][59] = Port Name
;						$aPrinterInfo[$i][60] = Power Management Capabilities
;						$aPrinterInfo[$i][61] = Power Management Supported
;						$aPrinterInfo[$i][62] = Printer Paper Names
;						$aPrinterInfo[$i][63] = Printer State
;						$aPrinterInfo[$i][64] = Printer Status
;						$aPrinterInfo[$i][65] = Print Job Data Type
;						$aPrinterInfo[$i][66] = Print Processor
;						$aPrinterInfo[$i][67] = Priority
;						$aPrinterInfo[$i][68] = Published
;						$aPrinterInfo[$i][69] = Queued
;						$aPrinterInfo[$i][70] = Raw Only
;						$aPrinterInfo[$i][71] = Separator File
;						$aPrinterInfo[$i][72] = Server Name
;						$aPrinterInfo[$i][73] = Shared
;						$aPrinterInfo[$i][74] = Share Name
;						$aPrinterInfo[$i][75] = Spool Enabled
;						$aPrinterInfo[$i][76] = Start Time
;						$aPrinterInfo[$i][77] = Status
;						$aPrinterInfo[$i][78] = Status Info
;						$aPrinterInfo[$i][79] = System Creation Class Name
;						$aPrinterInfo[$i][80] = System Name
;						$aPrinterInfo[$i][81] = Time Of Last Reset
;						$aPrinterInfo[$i][82] = Until Time
;						$aPrinterInfo[$i][83] = Vertical Resolution
;						$aPrinterInfo[$i][84] = Work Offline
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetPrinters(ByRef $aPrinterInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aPrinterInfo[1][85], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Printer", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aPrinterInfo[UBound($aPrinterInfo) + 1][85]
			$aPrinterInfo[$i][0]  = $objItem.Name
			$aPrinterInfo[$i][1]  = $objItem.Attributes
			$aPrinterInfo[$i][2]  = $objItem.Availability
			$aPrinterInfo[$i][3]  = $objItem.AvailableJobSheets(0)
			$aPrinterInfo[$i][4]  = $objItem.Description
			$aPrinterInfo[$i][5]  = $objItem.AveragePagesPerMinute
			$aPrinterInfo[$i][6]  = $objItem.Capabilities(0)
			$aPrinterInfo[$i][7]  = $objItem.CapabilityDescriptions(0)
			$aPrinterInfo[$i][8]  = $objItem.CharSetsSupported(0)
			$aPrinterInfo[$i][9]  = $objItem.Comment
			$aPrinterInfo[$i][10] = $objItem.ConfigManagerErrorCode
			$aPrinterInfo[$i][11] = $objItem.ConfigManagerUserConfig
			$aPrinterInfo[$i][12] = $objItem.CreationClassName
			$aPrinterInfo[$i][13] = $objItem.CurrentCapabilities(0)
			$aPrinterInfo[$i][14] = $objItem.CurrentCharSet
			$aPrinterInfo[$i][15] = $objItem.CurrentLanguage
			$aPrinterInfo[$i][16] = $objItem.CurrentMimeType
			$aPrinterInfo[$i][17] = $objItem.CurrentNaturalLanguage
			$aPrinterInfo[$i][18] = $objItem.CurrentPaperType
			$aPrinterInfo[$i][19] = $objItem.Default
			$aPrinterInfo[$i][20] = $objItem.DefaultCapabilities(0)
			$aPrinterInfo[$i][21] = $objItem.DefaultCopies
			$aPrinterInfo[$i][22] = $objItem.DefaultLanguage
			$aPrinterInfo[$i][23] = $objItem.DefaultMimeType
			$aPrinterInfo[$i][24] = $objItem.DefaultNumberUp
			$aPrinterInfo[$i][25] = $objItem.DefaultPaperType
			$aPrinterInfo[$i][26] = $objItem.DefaultPriority
			$aPrinterInfo[$i][27] = $objItem.DetectedErrorState
			$aPrinterInfo[$i][28] = $objItem.DeviceID
			$aPrinterInfo[$i][29] = $objItem.Direct
			$aPrinterInfo[$i][30] = $objItem.DoCompleteFirst
			$aPrinterInfo[$i][31] = $objItem.DriverName
			$aPrinterInfo[$i][32] = $objItem.EnableBIDI
			$aPrinterInfo[$i][33] = $objItem.EnableDevQueryPrint
			$aPrinterInfo[$i][34] = $objItem.ErrorCleared
			$aPrinterInfo[$i][35] = $objItem.ErrorDescription
			$aPrinterInfo[$i][36] = $objItem.ErrorInformation(0)
			$aPrinterInfo[$i][37] = $objItem.ExtendedDetectedErrorState
			$aPrinterInfo[$i][38] = $objItem.ExtendedPrinterStatus
			$aPrinterInfo[$i][39] = $objItem.Hidden
			$aPrinterInfo[$i][40] = $objItem.HorizontalResolution
			$aPrinterInfo[$i][41] = __StringToDate($objItem.InstallDate)
			$aPrinterInfo[$i][42] = $objItem.JobCountSinceLastReset
			$aPrinterInfo[$i][43] = $objItem.KeepPrintedJobs
			$aPrinterInfo[$i][44] = $objItem.LanguagesSupported(0)
			$aPrinterInfo[$i][45] = $objItem.LastErrorCode
			$aPrinterInfo[$i][46] = $objItem.Local
			$aPrinterInfo[$i][47] = $objItem.Location
			$aPrinterInfo[$i][48] = $objItem.MarkingTechnology
			$aPrinterInfo[$i][49] = $objItem.MaxCopies
			$aPrinterInfo[$i][50] = $objItem.MaxNumberUp
			$aPrinterInfo[$i][51] = $objItem.MaxSizeSupported
			$aPrinterInfo[$i][52] = $objItem.MimeTypesSupported(0)
			$aPrinterInfo[$i][53] = $objItem.NaturalLanguagesSupported(0)
			$aPrinterInfo[$i][54] = $objItem.Network
			$aPrinterInfo[$i][55] = $objItem.PaperSizesSupported(0)
			$aPrinterInfo[$i][56] = $objItem.PaperTypesAvailable(0)
			$aPrinterInfo[$i][57] = $objItem.Parameters
			$aPrinterInfo[$i][58] = $objItem.PNPDeviceID
			$aPrinterInfo[$i][59] = $objItem.PortName
			$aPrinterInfo[$i][60] = $objItem.PowerManagementCapabilities(0)
			$aPrinterInfo[$i][61] = $objItem.PowerManagementSupported
			$aPrinterInfo[$i][62] = $objItem.PrinterPaperNames(0)
			$aPrinterInfo[$i][63] = $objItem.PrinterState
			$aPrinterInfo[$i][64] = $objItem.PrinterStatus
			$aPrinterInfo[$i][65] = $objItem.PrintJobDataType
			$aPrinterInfo[$i][66] = $objItem.PrintProcessor
			$aPrinterInfo[$i][67] = $objItem.Priority
			$aPrinterInfo[$i][68] = $objItem.Published
			$aPrinterInfo[$i][69] = $objItem.Queued
			$aPrinterInfo[$i][70] = $objItem.RawOnly
			$aPrinterInfo[$i][71] = $objItem.SeparatorFile
			$aPrinterInfo[$i][72] = $objItem.ServerName
			$aPrinterInfo[$i][73] = $objItem.Shared
			$aPrinterInfo[$i][74] = $objItem.ShareName
			$aPrinterInfo[$i][75] = $objItem.SpoolEnabled
			$aPrinterInfo[$i][76] = __StringToDate($objItem.StartTime)
			$aPrinterInfo[$i][77] = $objItem.Status
			$aPrinterInfo[$i][78] = $objItem.StatusInfo
			$aPrinterInfo[$i][79] = $objItem.SystemCreationClassName
			$aPrinterInfo[$i][80] = $objItem.SystemName
			$aPrinterInfo[$i][81] = __StringToDate($objItem.TimeOfLastReset)
			$aPrinterInfo[$i][82] = __StringToDate($objItem.UntilTime)
			$aPrinterInfo[$i][83] = $objItem.VerticalResolution
			$aPrinterInfo[$i][84] = $objItem.WorkOffline
			$i += 1
		Next
		$aPrinterInfo[0][0] = UBound($aPrinterInfo) - 1
		If $aPrinterInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetPrinters

;===============================================================================
; Description:      Returns the Processor information in an array.
; Parameter(s):     $aProcessorInfo - By Reference - Processor Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Processor Information.
;						$aProcessorInfo[0][0]   = Number of Processors
;						$aProcessorInfo[$i][0]  = Name ($i starts at 1)
;						$aProcessorInfo[$i][1]  = Address Width
;						$aProcessorInfo[$i][2]  = Architecture
;						$aProcessorInfo[$i][3]  = Availability
;						$aProcessorInfo[$i][4]  = Description
;						$aProcessorInfo[$i][5]  = Config Manager Error Code
;						$aProcessorInfo[$i][6]  = Config Manager User Config
;						$aProcessorInfo[$i][7]  = CPU Status
;						$aProcessorInfo[$i][8]  = Creation Class Name
;						$aProcessorInfo[$i][9]  = Current Clock Speed
;						$aProcessorInfo[$i][10] = Current Voltage
;						$aProcessorInfo[$i][11] = Data Width
;						$aProcessorInfo[$i][12] = Device ID
;						$aProcessorInfo[$i][13] = Error Cleared
;						$aProcessorInfo[$i][14] = Error Description
;						$aProcessorInfo[$i][15] = Ext Clock
;						$aProcessorInfo[$i][16] = Family
;						$aProcessorInfo[$i][17] = L2 Cache Size
;						$aProcessorInfo[$i][18] = L2 Cache Speed
;						$aProcessorInfo[$i][19] = Last Error Code
;						$aProcessorInfo[$i][20] = Level
;						$aProcessorInfo[$i][21] = Load Percentage
;						$aProcessorInfo[$i][22] = Manufacturer
;						$aProcessorInfo[$i][23] = Max Clock Speed
;						$aProcessorInfo[$i][24] = Other Family Description
;						$aProcessorInfo[$i][25] = PNP Device ID
;						$aProcessorInfo[$i][26] = Power Management Capabilities
;						$aProcessorInfo[$i][27] = Power Management Supported
;						$aProcessorInfo[$i][28] = Processor ID
;						$aProcessorInfo[$i][29] = Processor Type
;						$aProcessorInfo[$i][30] = Revision
;						$aProcessorInfo[$i][31] = Role
;						$aProcessorInfo[$i][32] = Socket Designation
;						$aProcessorInfo[$i][33] = Status
;						$aProcessorInfo[$i][34] = Status Info
;						$aProcessorInfo[$i][35] = Stepping
;						$aProcessorInfo[$i][36] = System Creation Class Name
;						$aProcessorInfo[$i][37] = System Name
;						$aProcessorInfo[$i][38] = Unique ID
;						$aProcessorInfo[$i][39] = Upgrade Method
;						$aProcessorInfo[$i][40] = Version
;						$aProcessorInfo[$i][41] = Voltage Caps
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetProcessors(ByRef $aProcessorInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aProcessorInfo[1][42], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Processor", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aProcessorInfo[UBound($aProcessorInfo) + 1][42]
			$aProcessorInfo[$i][0]  = StringStripWS($objItem.Name, 1)
			$aProcessorInfo[$i][1]  = $objItem.AddressWidth
			$aProcessorInfo[$i][2]  = $objItem.Architecture
			$aProcessorInfo[$i][3]  = $objItem.Availability
			$aProcessorInfo[$i][4]  = $objItem.Description
			$aProcessorInfo[$i][5]  = $objItem.ConfigManagerErrorCode
			$aProcessorInfo[$i][6]  = $objItem.ConfigManagerUserConfig
			$aProcessorInfo[$i][7]  = $objItem.CpuStatus
			$aProcessorInfo[$i][8]  = $objItem.CreationClassName
			$aProcessorInfo[$i][9]  = $objItem.CurrentClockSpeed
			$aProcessorInfo[$i][10] = $objItem.CurrentVoltage
			$aProcessorInfo[$i][11] = $objItem.DataWidth
			$aProcessorInfo[$i][12] = $objItem.DeviceID
			$aProcessorInfo[$i][13] = $objItem.ErrorCleared
			$aProcessorInfo[$i][14] = $objItem.ErrorDescription
			$aProcessorInfo[$i][15] = $objItem.ExtClock
			$aProcessorInfo[$i][16] = $objItem.Family
			$aProcessorInfo[$i][17] = $objItem.L2CacheSize
			$aProcessorInfo[$i][18] = $objItem.L2CacheSpeed
			$aProcessorInfo[$i][19] = $objItem.LastErrorCode
			$aProcessorInfo[$i][20] = $objItem.Level
			$aProcessorInfo[$i][21] = $objItem.LoadPercentage
			$aProcessorInfo[$i][22] = $objItem.Manufacturer
			$aProcessorInfo[$i][23] = $objItem.MaxClockSpeed
			$aProcessorInfo[$i][24] = $objItem.OtherFamilyDescription
			$aProcessorInfo[$i][25] = $objItem.PNPDeviceID
			$aProcessorInfo[$i][26] = $objItem.PowerManagementCapabilities(0)
			$aProcessorInfo[$i][27] = $objItem.PowerManagementSupported
			$aProcessorInfo[$i][28] = $objItem.ProcessorId
			$aProcessorInfo[$i][29] = $objItem.ProcessorType
			$aProcessorInfo[$i][30] = $objItem.Revision
			$aProcessorInfo[$i][31] = $objItem.Role
			$aProcessorInfo[$i][32] = $objItem.SocketDesignation
			$aProcessorInfo[$i][33] = $objItem.Status
			$aProcessorInfo[$i][34] = $objItem.StatusInfo
			$aProcessorInfo[$i][35] = $objItem.Stepping
			$aProcessorInfo[$i][36] = $objItem.SystemCreationClassName
			$aProcessorInfo[$i][37] = $objItem.SystemName
			$aProcessorInfo[$i][38] = $objItem.UniqueId
			$aProcessorInfo[$i][39] = $objItem.UpgradeMethod
			$aProcessorInfo[$i][40] = $objItem.Version
			$aProcessorInfo[$i][41] = $objItem.VoltageCaps
			$i += 1
		Next
		$aProcessorInfo[0][0] = UBound($aProcessorInfo) - 1
		If $aProcessorInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetProcessors

;===============================================================================
; Description:      Returns the SoundCard information in an array.
; Parameter(s):     $aSoundCardInfo - By Reference - SoundCard Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of SoundCard Information.
;						$aSoundCardInfo[0][0]   = Number of Sound Cards
;						$aSoundCardInfo[$i][0]  = Name ($i starts at 1)
;						$aSoundCardInfo[$i][1]  = Availability
;						$aSoundCardInfo[$i][2]  = Config Manager Error Code
;						$aSoundCardInfo[$i][3]  = Config Manager User Config
;						$aSoundCardInfo[$i][4]  = Description
;						$aSoundCardInfo[$i][5]  = Creation Class Name
;						$aSoundCardInfo[$i][6]  = Device ID
;						$aSoundCardInfo[$i][7]  = DMA Buffer Size
;						$aSoundCardInfo[$i][8]  = Error Cleared
;						$aSoundCardInfo[$i][9]  = Error Description
;						$aSoundCardInfo[$i][10] = Last Error Code
;						$aSoundCardInfo[$i][11] = Manufacturer
;						$aSoundCardInfo[$i][12] = MPU 401 Address
;						$aSoundCardInfo[$i][13] = PNP Device ID
;						$aSoundCardInfo[$i][14] = Power Management Capabilities
;						$aSoundCardInfo[$i][15] = Power Management Supported
;						$aSoundCardInfo[$i][16] = Product Name
;						$aSoundCardInfo[$i][17] = Status
;						$aSoundCardInfo[$i][18] = Status Info
;						$aSoundCardInfo[$i][19] = System Creation Class Name
;						$aSoundCardInfo[$i][20] = System Name
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetSoundCards(ByRef $aSoundCardInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aSoundCardInfo[1][21], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_SoundDevice", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aSoundCardInfo[UBound($aSoundCardInfo) + 1][21]
			$aSoundCardInfo[$i][0]  = $objItem.Name
			$aSoundCardInfo[$i][1]  = $objItem.Availability
			$aSoundCardInfo[$i][2]  = $objItem.ConfigManagerErrorCode
			$aSoundCardInfo[$i][3]  = $objItem.ConfigManagerUserConfig
			$aSoundCardInfo[$i][4]  = $objItem.Description
			$aSoundCardInfo[$i][5]  = $objItem.CreationClassName
			$aSoundCardInfo[$i][6]  = $objItem.DeviceID
			$aSoundCardInfo[$i][7]  = $objItem.DMABufferSize
			$aSoundCardInfo[$i][8]  = $objItem.ErrorCleared
			$aSoundCardInfo[$i][9]  = $objItem.ErrorDescription
			$aSoundCardInfo[$i][10] = $objItem.LastErrorCode
			$aSoundCardInfo[$i][11] = $objItem.Manufacturer
			$aSoundCardInfo[$i][12] = $objItem.MPU401Address
			$aSoundCardInfo[$i][13] = $objItem.PNPDeviceID
			$aSoundCardInfo[$i][14] = $objItem.PowerManagementCapabilities(0)
			$aSoundCardInfo[$i][15] = $objItem.PowerManagementSupported
			$aSoundCardInfo[$i][16] = $objItem.ProductName
			$aSoundCardInfo[$i][17] = $objItem.Status
			$aSoundCardInfo[$i][18] = $objItem.StatusInfo
			$aSoundCardInfo[$i][19] = $objItem.SystemCreationClassName
			$aSoundCardInfo[$i][20] = $objItem.SystemName
			$i += 1
		Next
		$aSoundCardInfo[0][0] = UBound($aSoundCardInfo) - 1
		If $aSoundCardInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetSoundCards

;===============================================================================
; Description:      Returns the System information in an array.
; Parameter(s):     $aSystemInfo - By Reference - System Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of System Information.
;						$aSystemInfo[$i][0]  = Name
;						$aSystemInfo[$i][1]  = Admin Password Status
;						$aSystemInfo[$i][2]  = Automatic Reset Boot Option
;						$aSystemInfo[$i][3]  = Automatic Reset Capability
;						$aSystemInfo[$i][4]  = Description
;						$aSystemInfo[$i][5]  = Boot Option On Limit
;						$aSystemInfo[$i][6]  = Boot Option On Watch Dog
;						$aSystemInfo[$i][7]  = Boot ROM Supported
;						$aSystemInfo[$i][8]  = Bootup State
;						$aSystemInfo[$i][9]  = Chassis Bootup State
;						$aSystemInfo[$i][10] = Creation Class Name
;						$aSystemInfo[$i][11] = Current Time Zone
;						$aSystemInfo[$i][12] = Daylight In Effect
;						$aSystemInfo[$i][13] = Domain
;						$aSystemInfo[$i][14] = Domain Role
;						$aSystemInfo[$i][15] = Enable Daylight Savings Time
;						$aSystemInfo[$i][16] = Front Panel Reset Status
;						$aSystemInfo[$i][17] = Infrared Supported
;						$aSystemInfo[$i][18] = Initial Load Info
;						$aSystemInfo[$i][19] = Keyboard Password Status
;						$aSystemInfo[$i][20] = Last Load Info
;						$aSystemInfo[$i][21] = Manufacturer
;						$aSystemInfo[$i][22] = Model
;						$aSystemInfo[$i][23] = Name Format
;						$aSystemInfo[$i][24] = Network Server Mode Enabled
;						$aSystemInfo[$i][25] = Number Of Processors
;						$aSystemInfo[$i][26] = OEM Logo Bitmap
;						$aSystemInfo[$i][27] = OEM String Array
;						$aSystemInfo[$i][28] = Part Of Domain
;						$aSystemInfo[$i][29] = Pause After Reset
;						$aSystemInfo[$i][30] = Power Management Capabilities
;						$aSystemInfo[$i][31] = Power Management Supported
;						$aSystemInfo[$i][32] = Power On Password Status
;						$aSystemInfo[$i][33] = Power State
;						$aSystemInfo[$i][34] = Power Supply State
;						$aSystemInfo[$i][35] = Primary Owner Contact
;						$aSystemInfo[$i][36] = Primary Owner Name
;						$aSystemInfo[$i][37] = Reset Capability
;						$aSystemInfo[$i][38] = Reset Count
;						$aSystemInfo[$i][39] = Reset Limit
;						$aSystemInfo[$i][40] = Roles
;						$aSystemInfo[$i][41] = Status
;						$aSystemInfo[$i][42] = Support Contact Description
;						$aSystemInfo[$i][43] = System Startup Delay
;						$aSystemInfo[$i][44] = System Startup Options
;						$aSystemInfo[$i][45] = System Startup Setting
;						$aSystemInfo[$i][46] = System Type
;						$aSystemInfo[$i][47] = Thermal State
;						$aSystemInfo[$i][48] = Total Physical Memory
;						$aSystemInfo[$i][49] = User Name
;						$aSystemInfo[$i][50] = Wake Up Type
;						$aSystemInfo[$i][51] = Workgroup
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetSystem(ByRef $aSystemInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aSystemInfo[1][52], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aSystemInfo[UBound($aSystemInfo) + 1][52]
			$aSystemInfo[$i][0]  = $objItem.Name
			$aSystemInfo[$i][1]  = $objItem.AdminPasswordStatus
			$aSystemInfo[$i][2]  = $objItem.AutomaticResetBootOption
			$aSystemInfo[$i][3]  = $objItem.AutomaticResetCapability
			$aSystemInfo[$i][4]  = $objItem.Description
			$aSystemInfo[$i][5]  = $objItem.BootOptionOnLimit
			$aSystemInfo[$i][6]  = $objItem.BootOptionOnWatchDog
			$aSystemInfo[$i][7]  = $objItem.BootROMSupported
			$aSystemInfo[$i][8]  = $objItem.BootupState
			$aSystemInfo[$i][9]  = $objItem.ChassisBootupState
			$aSystemInfo[$i][10] = $objItem.CreationClassName
			$aSystemInfo[$i][11] = $objItem.CurrentTimeZone
			$aSystemInfo[$i][12] = $objItem.DaylightInEffect
			$aSystemInfo[$i][13] = $objItem.Domain
			$aSystemInfo[$i][14] = $objItem.DomainRole
			$aSystemInfo[$i][15] = $objItem.EnableDaylightSavingsTime
			$aSystemInfo[$i][16] = $objItem.FrontPanelResetStatus
			$aSystemInfo[$i][17] = $objItem.InfraredSupported
			$aSystemInfo[$i][18] = $objItem.InitialLoadInfo(0)
			$aSystemInfo[$i][19] = $objItem.KeyboardPasswordStatus
			$aSystemInfo[$i][20] = $objItem.LastLoadInfo
			$aSystemInfo[$i][21] = $objItem.Manufacturer
			$aSystemInfo[$i][22] = $objItem.Model
			$aSystemInfo[$i][23] = $objItem.NameFormat
			$aSystemInfo[$i][24] = $objItem.NetworkServerModeEnabled
			$aSystemInfo[$i][25] = $objItem.NumberOfProcessors
			$aSystemInfo[$i][26] = $objItem.OEMLogoBitmap(0)
			$aSystemInfo[$i][27] = $objItem.OEMStringArray(0)
			$aSystemInfo[$i][28] = $objItem.PartOfDomain
			$aSystemInfo[$i][29] = $objItem.PauseAfterReset
			$aSystemInfo[$i][30] = $objItem.PowerManagementCapabilities(0)
			$aSystemInfo[$i][31] = $objItem.PowerManagementSupported
			$aSystemInfo[$i][32] = $objItem.PowerOnPasswordStatus
			$aSystemInfo[$i][33] = $objItem.PowerState
			$aSystemInfo[$i][34] = $objItem.PowerSupplyState
			$aSystemInfo[$i][35] = $objItem.PrimaryOwnerContact
			$aSystemInfo[$i][36] = $objItem.PrimaryOwnerName
			$aSystemInfo[$i][37] = $objItem.ResetCapability
			$aSystemInfo[$i][38] = $objItem.ResetCount
			$aSystemInfo[$i][39] = $objItem.ResetLimit
			$aSystemInfo[$i][40] = $objItem.Roles(0)
			$aSystemInfo[$i][41] = $objItem.Status
			$aSystemInfo[$i][42] = $objItem.SupportContactDescription(0)
			$aSystemInfo[$i][43] = $objItem.SystemStartupDelay
			$aSystemInfo[$i][44] = $objItem.SystemStartupOptions(0)
			$aSystemInfo[$i][45] = $objItem.SystemStartupSetting
			$aSystemInfo[$i][46] = $objItem.SystemType
			$aSystemInfo[$i][47] = $objItem.ThermalState
			$aSystemInfo[$i][48] = $objItem.TotalPhysicalMemory
			$aSystemInfo[$i][49] = $objItem.UserName
			$aSystemInfo[$i][50] = $objItem.WakeUpType
			$aSystemInfo[$i][51] = $objItem.Workgroup
			$i += 1
		Next
		$aSystemInfo[0][0] = UBound($aSystemInfo) - 1
		If $aSystemInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetSystem

;===============================================================================
; Description:      Returns the System Product information in an array.
; Parameter(s):     $aSysProductInfo - By Reference - System Product Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of System Product Information.
;						$aKeyboardInfo[0][0]   = Number of Keyboards
;						$aKeyboardInfo[$i][0]  = Name ($i starts at 1)
;						$aKeyboardInfo[$i][1]  = Identifying Number
;						$aKeyboardInfo[$i][2]  = SKU Number
;						$aKeyboardInfo[$i][3]  = UUID
;						$aKeyboardInfo[$i][4]  = Description
;						$aKeyboardInfo[$i][5]  = Vendor
;						$aKeyboardInfo[$i][6]  = Version
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetSystemProduct(ByRef $aSysProductInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aSysProductInfo[1][7], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystemProduct", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aSysProductInfo[UBound($aSysProductInfo) + 1][7]
			$aSysProductInfo[$i][0]  = $objItem.Name
			$aSysProductInfo[$i][1]  = $objItem.IdentifyingNumber
			$aSysProductInfo[$i][2]  = $objItem.SKUNumber
			$aSysProductInfo[$i][3]  = $objItem.UUID
			$aSysProductInfo[$i][4]  = $objItem.Description
			$aSysProductInfo[$i][5]  = $objItem.Vendor
			$aSysProductInfo[$i][6]  = $objItem.Version
			$i += 1
		Next
		$aSysProductInfo[0][0] = UBound($aSysProductInfo) - 1
		If $aSysProductInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetSystemProduct

;===============================================================================
; Description:      Returns the Video information in an array.
; Parameter(s):     $aVideoInfo - By Reference - Video Information array.
; Requirement(s):   None
; Return Value(s):  On Success - Returns array of Video Information.
;						$aVideoInfo[0][0]   = Number of Video Cards
;						$aVideoInfo[$i][0]  = Name ($i starts at 1)
;						$aVideoInfo[$i][1]  = Accelerator Capabilities
;						$aVideoInfo[$i][2]  = Adapter Compatibility
;						$aVideoInfo[$i][3]  = Adapter DAC Type
;						$aVideoInfo[$i][4]  = Description
;						$aVideoInfo[$i][5]  = Adapter RAM
;						$aVideoInfo[$i][6]  = Availability
;						$aVideoInfo[$i][7]  = Capability Descriptions
;						$aVideoInfo[$i][8]  = Color Table Entries
;						$aVideoInfo[$i][9]  = Config Manager Error Code
;						$aVideoInfo[$i][10] = Config Manager User Config
;						$aVideoInfo[$i][11] = Creation Class Name
;						$aVideoInfo[$i][12] = Current Bits Per Pixel
;						$aVideoInfo[$i][13] = Current Horizontal Resolution
;						$aVideoInfo[$i][14] = Current Number Of Colors
;						$aVideoInfo[$i][15] = Current Number Of Columns
;						$aVideoInfo[$i][16] = Current Number Of Rows
;						$aVideoInfo[$i][17] = Current Refresh Rate
;						$aVideoInfo[$i][18] = Current Scan Mode
;						$aVideoInfo[$i][19] = Current Vertical Resolution
;						$aVideoInfo[$i][20] = Device ID
;						$aVideoInfo[$i][21] = Device Specific Pens
;						$aVideoInfo[$i][22] = Dither Type
;						$aVideoInfo[$i][23] = Driver Date
;						$aVideoInfo[$i][24] = Driver Version
;						$aVideoInfo[$i][25] = Error Cleared
;						$aVideoInfo[$i][26] = Error Description
;						$aVideoInfo[$i][27] = ICM Intent
;						$aVideoInfo[$i][28] = ICM Method
;						$aVideoInfo[$i][29] = Inf Filename
;						$aVideoInfo[$i][30] = Inf Section
;						$aVideoInfo[$i][31] = Installed Display Drivers
;						$aVideoInfo[$i][32] = Last Error Code
;						$aVideoInfo[$i][33] = Max Memory Supported
;						$aVideoInfo[$i][34] = Max Number Controlled
;						$aVideoInfo[$i][35] = Max Refresh Rate
;						$aVideoInfo[$i][36] = Min Refresh Rate
;						$aVideoInfo[$i][37] = Monochrome
;						$aVideoInfo[$i][38] = Number Of Color Planes
;						$aVideoInfo[$i][39] = Number Of Video Pages
;						$aVideoInfo[$i][40] = PNP Device ID
;						$aVideoInfo[$i][41] = Power Management Capabilities
;						$aVideoInfo[$i][42] = Power Management Supported
;						$aVideoInfo[$i][43] = Protocol Supported
;						$aVideoInfo[$i][44] = Reserved System Palette Entries
;						$aVideoInfo[$i][45] = Specification Version
;						$aVideoInfo[$i][46] = Status
;						$aVideoInfo[$i][47] = Status Info
;						$aVideoInfo[$i][48] = System Creation Class Name
;						$aVideoInfo[$i][49] = System Name
;						$aVideoInfo[$i][50] = System Palette Entries
;						$aVideoInfo[$i][51] = Time Of Last Reset
;						$aVideoInfo[$i][52] = Video Architecture
;						$aVideoInfo[$i][53] = Video Memory Type
;						$aVideoInfo[$i][54] = Video Mode
;						$aVideoInfo[$i][55] = Video Mode Description
;						$aVideoInfo[$i][56] = Video Processor
;                   On Failure - @error = 1 and Returns 0
;								@extended = 1 - Array contains no information
;											2 - $colItems isnt an object
; Author(s):        Jarvis Stubblefield (support "at" vortexrevolutions "dot" com)
; Note(s):
;===============================================================================
Func _ComputerGetVideoCards(ByRef $aVideoInfo)
	Local $colItems, $objWMIService, $objItem
	Dim $aVideoInfo[1][59], $i = 1
	
	$objWMIService = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_VideoController", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	
	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $aVideoInfo[UBound($aVideoInfo) + 1][59]
			$aVideoInfo[$i][0]  = $objItem.Name
			$aVideoInfo[$i][1]  = $objItem.AcceleratorCapabilities(0)
			$aVideoInfo[$i][2]  = $objItem.AdapterCompatibility
			$aVideoInfo[$i][3]  = $objItem.AdapterDACType
			$aVideoInfo[$i][4]  = $objItem.Description
			$aVideoInfo[$i][5]  = $objItem.AdapterRAM
			$aVideoInfo[$i][6]  = $objItem.Availability
			$aVideoInfo[$i][7]  = $objItem.CapabilityDescriptions(0)
			$aVideoInfo[$i][8]  = $objItem.ColorTableEntries
			$aVideoInfo[$i][9]  = $objItem.ConfigManagerErrorCode
			$aVideoInfo[$i][10] = $objItem.ConfigManagerUserConfig
			$aVideoInfo[$i][11] = $objItem.CreationClassName
			$aVideoInfo[$i][12] = $objItem.CurrentBitsPerPixel
			$aVideoInfo[$i][13] = $objItem.CurrentHorizontalResolution
			$aVideoInfo[$i][14] = $objItem.CurrentNumberOfColors
			$aVideoInfo[$i][15] = $objItem.CurrentNumberOfColumns
			$aVideoInfo[$i][16] = $objItem.CurrentNumberOfRows
			$aVideoInfo[$i][17] = $objItem.CurrentRefreshRate
			$aVideoInfo[$i][18] = $objItem.CurrentScanMode
			$aVideoInfo[$i][19] = $objItem.CurrentVerticalResolution
			$aVideoInfo[$i][20] = $objItem.DeviceID
			$aVideoInfo[$i][21] = $objItem.DeviceSpecificPens
			$aVideoInfo[$i][22] = $objItem.DitherType
			$aVideoInfo[$i][23] = __StringToDate($objItem.DriverDate)
			$aVideoInfo[$i][24] = $objItem.DriverVersion
			$aVideoInfo[$i][25] = $objItem.ErrorCleared
			$aVideoInfo[$i][26] = $objItem.ErrorDescription
			$aVideoInfo[$i][27] = $objItem.ICMIntent
			$aVideoInfo[$i][28] = $objItem.ICMMethod
			$aVideoInfo[$i][29] = $objItem.InfFilename
			$aVideoInfo[$i][30] = $objItem.InfSection
			$aVideoInfo[$i][31] = $objItem.InstalledDisplayDrivers
			$aVideoInfo[$i][32] = $objItem.LastErrorCode
			$aVideoInfo[$i][33] = $objItem.MaxMemorySupported
			$aVideoInfo[$i][34] = $objItem.MaxNumberControlled
			$aVideoInfo[$i][35] = $objItem.MaxRefreshRate
			$aVideoInfo[$i][36] = $objItem.MinRefreshRate
			$aVideoInfo[$i][37] = $objItem.Monochrome
			$aVideoInfo[$i][38] = $objItem.NumberOfColorPlanes
			$aVideoInfo[$i][39] = $objItem.NumberOfVideoPages
			$aVideoInfo[$i][40] = $objItem.PNPDeviceID
			$aVideoInfo[$i][41] = $objItem.PowerManagementCapabilities(0)
			$aVideoInfo[$i][42] = $objItem.PowerManagementSupported
			$aVideoInfo[$i][43] = $objItem.ProtocolSupported
			$aVideoInfo[$i][44] = $objItem.ReservedSystemPaletteEntries
			$aVideoInfo[$i][45] = $objItem.SpecificationVersion
			$aVideoInfo[$i][46] = $objItem.Status
			$aVideoInfo[$i][47] = $objItem.StatusInfo
			$aVideoInfo[$i][48] = $objItem.SystemCreationClassName
			$aVideoInfo[$i][49] = $objItem.SystemName
			$aVideoInfo[$i][50] = $objItem.SystemPaletteEntries
			$aVideoInfo[$i][51] = __StringToDate($objItem.TimeOfLastReset)
			$aVideoInfo[$i][52] = $objItem.VideoArchitecture
			$aVideoInfo[$i][53] = $objItem.VideoMemoryType
			$aVideoInfo[$i][54] = $objItem.VideoMode
			$aVideoInfo[$i][55] = $objItem.VideoModeDescription
			$aVideoInfo[$i][56] = $objItem.VideoProcessor
			$i += 1
		Next
		$aVideoInfo[0][0] = UBound($aVideoInfo) - 1
		If $aVideoInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetVideoCards
#endregion Hardware Functions

#region Internal Functions
; **********************************************************************************
; Internal Functions with names starting with two underscores will not be documented
; as user functions.
; **********************************************************************************
Func __StringVersion()
	Return $cI_VersionInfo
EndFunc ;_StringVersion

Func __StringToDate($dtmDate)
	Return (StringMid($dtmDate, 5, 2) & "/" & _
			StringMid($dtmDate, 7, 2) & "/" & StringLeft($dtmDate, 4) _
			& " " & StringMid($dtmDate, 9, 2) & ":" & StringMid($dtmDate, 11, 2) & ":" & StringMid($dtmDate,13, 2))
EndFunc ;__StringToDate Function created by SvenP Modified by JSThePatriot
#endregion Internal Functions