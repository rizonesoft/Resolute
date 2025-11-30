#include "CompInfo.au3" ;If you are wanting to pull WMI data from different computers then Declare $cI_CompName as the computer name before the include.

#region Header
#comments-start
	Title:			Computer Information Automation UDF Library for AutoIt3 - EXAMPLES
	Filename:		CompInfoExamples.au3
	Description:	Examples using the UDF's from CompInfo.au3
	Author:			Jarvis J. Stubblefield (JSThePatriot) http://www.vortexrevolutions.com/
	Version:		00.03.08
	Last Update:	11.09.06
	Requirements:	AutoIt v3.2 +, Developed/Tested on WindowsXP Pro Service Pack 2
	Notes:			Errors associated with incorrect objects will be common user errors. AutoIt beta 3.1.1.63 has added an ObjName()
	function that will be used to trap and report most of these errors.
	
	Special thanks to Firestorm (Testing, Use), Koala (Testing, Bug Fix), and everyone else that has helped in the creation of this Example File.
#comments-end
#endregion Header

#region ---- Software Functions
#region -- Boot Configuration
Dim $BootConfig

_ComputerGetBootConfig($BootConfig)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $BootConfig[0][0] Step 1
	MsgBox(0, "Test _ComputerGetBootConfig", "Name: " & $BootConfig[$i][0] & @CRLF & _
			"Boot Directory: " & $BootConfig[$i][1] & @CRLF & _
			"Configuration Path: " & $BootConfig[$i][2] & @CRLF & _
			"Last Drive: " & $BootConfig[$i][3] & @CRLF & _
			"Description: " & $BootConfig[$i][4] & @CRLF & _
			"Scratch Directory: " & $BootConfig[$i][5] & @CRLF & _
			"Setting ID: " & $BootConfig[$i][6] & @CRLF & _
			"Temp Directory: " & $BootConfig[$i][7])
Next
#endregion Boot Configuration

#region -- Dependent Services
Dim $DependantService

_ComputerGetDependantServices($DependantService)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $DependantService[0][0] Step 1
	MsgBox(0, "Test _ComputerGetDependantServices", 			"Antecedent: " & $DependantService[$i][0] & @CRLF & _
			"Dependent: " & $DependantService[$i][1] & @CRLF & _
			"TypeOfDependency: " & $DependantService[$i][2])
Next
#endregion Dependent Services

#region -- Desktops
Dim $Desktop

_ComputerGetDesktops($Desktop)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $Desktop[0][0] Step 1
	MsgBox(0, "Test _ComputerGetDesktops", 			"Name: " & $Desktop[$i][0] & @CRLF & _
			"BorderWidth: " & $Desktop[$i][1] & @CRLF & _
			"CoolSwitch: " & $Desktop[$i][2] & @CRLF & _
			"CursorBlinkRate: " & $Desktop[$i][3] & @CRLF & _
			"Description: " & $Desktop[$i][4] & @CRLF & _
			"DragFullWindows: " & $Desktop[$i][5] & @CRLF & _
			"GridGranularity: " & $Desktop[$i][6] & @CRLF & _
			"IconSpacing: " & $Desktop[$i][7] & @CRLF & _
			"IconTitleFaceName: " & $Desktop[$i][8] & @CRLF & _
			"IconTitleSize: " & $Desktop[$i][9] & @CRLF & _
			"IconTitleWrap: " & $Desktop[$i][10] & @CRLF & _
			"Pattern: " & $Desktop[$i][11] & @CRLF & _
			"ScreenSaverActive: " & $Desktop[$i][12] & @CRLF & _
			"ScreenSaverExecutable: " & $Desktop[$i][13] & @CRLF & _
			"ScreenSaverSecure: " & $Desktop[$i][14] & @CRLF & _
			"ScreenSaverTimeout: " & $Desktop[$i][15] & @CRLF & _
			"SettingID: " & $Desktop[$i][16] & @CRLF & _
			"Wallpaper: " & $Desktop[$i][17] & @CRLF & _
			"WallpaperStretched: " & $Desktop[$i][18] & @CRLF & _
			"WallpaperTiled: " & $Desktop[$i][19])
Next
#endregion Desktops

#region -- EventLogs
Dim $EventLogs

_ComputerGetEventLogs($EventLogs)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $EventLogs[0][0] Step 1
	MsgBox(0, "Test _ComputerGetEventLogs", "Name: " & $EventLogs[$i][0] & @CRLF & _
			"AccessMask: " & $EventLogs[$i][1] & @CRLF & _
			"Archive: " & $EventLogs[$i][2] & @CRLF & _
			"Compressed: " & $EventLogs[$i][3] & @CRLF & _
			"Description: " & $EventLogs[$i][4] & @CRLF & _
			"CompressionMethod: " & $EventLogs[$i][5] & @CRLF & _
			"CreationClassName: " & $EventLogs[$i][6] & @CRLF & _
			"CreationDate: " & $EventLogs[$i][7] & @CRLF & _
			"CSCreationClassName: " & $EventLogs[$i][8] & @CRLF & _
			"CSName: " & $EventLogs[$i][9] & @CRLF & _
			"Drive: " & $EventLogs[$i][10] & @CRLF & _
			"EightDotThreeFileName: " & $EventLogs[$i][11] & @CRLF & _
			"Encrypted: " & $EventLogs[$i][12] & @CRLF & _
			"EncryptionMethod: " & $EventLogs[$i][13] & @CRLF & _
			"Extension: " & $EventLogs[$i][14] & @CRLF & _
			"FileName: " & $EventLogs[$i][15] & @CRLF & _
			"FileSize: " & $EventLogs[$i][16] & @CRLF & _
			"FileType: " & $EventLogs[$i][17] & @CRLF & _
			"FSCreationClassName: " & $EventLogs[$i][18] & @CRLF & _
			"FSName: " & $EventLogs[$i][19] & @CRLF & _
			"Hidden: " & $EventLogs[$i][20] & @CRLF & _
			"InstallDate: " & $EventLogs[$i][21] & @CRLF & _
			"InUseCount: " & $EventLogs[$i][22] & @CRLF & _
			"LastAccessed: " & $EventLogs[$i][23] & @CRLF & _
			"LastModified: " & $EventLogs[$i][24] & @CRLF & _
			"LogfileName: " & $EventLogs[$i][25] & @CRLF & _
			"Manufacturer: " & $EventLogs[$i][26] & @CRLF & _
			"MaxFileSize: " & $EventLogs[$i][27] & @CRLF & _
			"NumberOfRecords: " & $EventLogs[$i][28] & @CRLF & _
			"OverwriteOutDated: " & $EventLogs[$i][29] & @CRLF & _
			"OverWritePolicy: " & $EventLogs[$i][30] & @CRLF & _
			"Path: " & $EventLogs[$i][31] & @CRLF & _
			"Readable: " & $EventLogs[$i][32] & @CRLF & _
			"Sources: " & $EventLogs[$i][33] & @CRLF & _
			"Status: " & $EventLogs[$i][34] & @CRLF & _
			"System: " & $EventLogs[$i][35] & @CRLF & _
			"Version: " & $EventLogs[$i][36] & @CRLF & _
			"Writeable: " & $EventLogs[$i][37])
Next
#endregion EventLogs

#region -- Extensions
Dim $Extension

_ComputerGetExtensions($Extension)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg("Array contains no information.")
		Case 2
			_ErrorMsg("$colItems isnt an object.")
	EndSwitch
EndIf

For $i = 1 To $Extension[0][0] Step 1
	MsgBox(0, "Test _ComputerGetExtensions", "Name: " & $Extension[$i][0] & @CRLF & _
											"Admin Password Status: " & $Extension[$i][1] & @CRLF & _
											"Automatic Reset Boot Option: " & $Extension[$i][2] & @CRLF & _
											"Automatic Reset Capability: " & $Extension[$i][3] & @CRLF & _
											"Description: " & $Extension[$i][4] & @CRLF & _
											"Boot Option On Limit: " & $Extension[$i][5] & @CRLF & _
											"Boot Option On WatchDog: " & $Extension[$i][6] & @CRLF & _
											"Boot ROM Supported: " & $Extension[$i][7] & @CRLF & _
											"Bootup State: " & $Extension[$i][8] & @CRLF & _ 
											"Chassis Bootup State: " & $Extension[$i][9] & @CRLF & _
											"Creation Class Name: " & $Extension[$i][10] & @CRLF & _
											"Current Time Zone: " & $Extension[$i][11] & @CRLF & _
											"Daylight In Effect: " & $Extension[$i][12] & @CRLF & _
											"Domain: " & $Extension[$i][13] & @CRLF & _
											"Domain Role: " & $Extension[$i][14] & @CRLF & _
											"Enable Daylight Savings Time: " & $Extension[$i][15])
Next
#endregion Extensions

#region -- Groups
Dim $Groups

_ComputerGetGroups($Groups)

For $i = 1 To $Groups[0][0] Step 1
	MsgBox(0, "Test _ComputerGetGroups", "Name: " & $Groups[$i][0] & @CRLF & _
			"Domain: " & $Groups[$i][1] & @CRLF & _
			"Status: " & $Groups[$i][2] & @CRLF & _
			"Local Account: " & $Groups[$i][3] & @CRLF & _
			"SID: " & $Groups[$i][4] & @CRLF & _
			"SIDType: " & $Groups[$i][5] & @CRLF & _
			"Description: " & $Groups[$i][6])
Next
#endregion Groups

#region -- Logged On Users
Dim $LoggedOnUser

_ComputerGetLoggedOnUsers($LoggedOnUser)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $LoggedOnUser[0][0] Step 1
	MsgBox(0, "Test _ComputerGetLoggedOnUsers", 			"DomainName: " & $LoggedOnUser[$i][0] & @CRLF & _
			"UserName: " & $LoggedOnUser[$i][1] & @CRLF & _
			"LogonID: " & $LoggedOnUser[$i][2])
Next
#endregion Logged On Users

#region -- Operating Systems
;NOTE: OSs contains alot of information, and may require a different output format.
Dim $OSs

_ComputerGetOSs($OSs)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $OSs[0][0] Step 1
	MsgBox(0, "Test _ComputerGetOSs", "Name: " & $OSs[$i][0] & @CRLF & _
			"Boot Device: " & $OSs[$i][1] & @CRLF & _
			"Build Number: " & $OSs[$i][2] & @CRLF & _
			"Build Type: " & $OSs[$i][3] & @CRLF & _
			"Description: " & $OSs[$i][4] & @CRLF & _
			"Code Set: " & $OSs[$i][5] & @CRLF & _
			"Country Code: " & $OSs[$i][6] & @CRLF & _
			"Creation Class Name: " & $OSs[$i][7] & @CRLF & _
			"CSCreation Class Name: " & $OSs[$i][8] & @CRLF & _
			"CSD Version: " & $OSs[$i][9] & @CRLF & _
			"CS Name: " & $OSs[$i][10] & @CRLF & _
			"Current Time Zone: " & $OSs[$i][11] & @CRLF & _
			"Data Execution Prevention_32BitApplications: " & $OSs[$i][12] & @CRLF & _
			"Data Execution Prevention_Available: " & $OSs[$i][13] & @CRLF & _
			"Data Execution Prevention_Drivers: " & $OSs[$i][14] & @CRLF & _
			"Data Execution Prevention_SupportPolicy: " & $OSs[$i][15] & @CRLF & _
			"Debug: " & $OSs[$i][16] & @CRLF & _
			"Distributed: " & $OSs[$i][17] & @CRLF & _
			"Encryption Level: " & $OSs[$i][18] & @CRLF & _
			"Foreground Application Boost: " & $OSs[$i][19] & @CRLF & _
			"Free Physical Memory: " & $OSs[$i][20] & @CRLF & _
			"Free Space In Paging Files: " & $OSs[$i][21] & @CRLF & _
			"Free Virtual Memory: " & $OSs[$i][22] & @CRLF & _
			"Install Date: " & $OSs[$i][23] & @CRLF & _
			"Large System Cache: " & $OSs[$i][24] & @CRLF & _
			"Last Boot Up Time: " & $OSs[$i][25] & @CRLF & _
			"Local Date Time: " & $OSs[$i][26] & @CRLF & _
			"Locale: " & $OSs[$i][27] & @CRLF & _
			"Manufacturer: " & $OSs[$i][28] & @CRLF & _
			"Max Number Of Processes: " & $OSs[$i][29] & @CRLF & _
			"Max Process Memory Size: " & $OSs[$i][30] & @CRLF & _
			"Number Of Licensed Users: " & $OSs[$i][31] & @CRLF & _
			"Number Of Processes: " & $OSs[$i][32] & @CRLF & _
			"Number Of Users: " & $OSs[$i][33] & @CRLF & _
			"Organization: " & $OSs[$i][34] & @CRLF & _
			"OS Language: " & $OSs[$i][35] & @CRLF & _
			"OS Product Suite: " & $OSs[$i][36] & @CRLF & _
			"OS Type: " & $OSs[$i][37] & @CRLF & _
			"Other Type Description: " & $OSs[$i][38] & @CRLF & _
			"Plus Product ID: " & $OSs[$i][39] & @CRLF & _
			"Plus Version Number: " & $OSs[$i][40] & @CRLF & _
			"Primary: " & $OSs[$i][41] & @CRLF & _
			"Product Type: " & $OSs[$i][42] & @CRLF & _
			"Quantum Length: " & $OSs[$i][43] & @CRLF & _
			"Quantum Type: " & $OSs[$i][44] & @CRLF & _
			"Registered User: " & $OSs[$i][45] & @CRLF & _
			"Serial Number: " & $OSs[$i][46] & @CRLF & _
			"Service Pack Major Version: " & $OSs[$i][47] & @CRLF & _
			"Service Pack Minor Version: " & $OSs[$i][48] & @CRLF & _
			"Size Stored In Paging Files: " & $OSs[$i][49] & @CRLF & _
			"Status: " & $OSs[$i][50] & @CRLF & _
			"Suite Mask: " & $OSs[$i][51] & @CRLF & _
			"System Device: " & $OSs[$i][52] & @CRLF & _
			"System Directory: " & $OSs[$i][53] & @CRLF & _
			"System Drive: " & $OSs[$i][54] & @CRLF & _
			"Total Swap Space Size: " & $OSs[$i][55] & @CRLF & _
			"Total Virtual Memory Size: " & $OSs[$i][56] & @CRLF & _
			"Total Visible Memory Size: " & $OSs[$i][57] & @CRLF & _
			"Version: " & $OSs[$i][58] & @CRLF & _
			"Windows Directory: " & $OSs[$i][59])
Next
#endregion

#region -- Print Jobs
Dim $PrintJob

_ComputerGetPrintJobs($PrintJob)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $PrintJob[0][0] Step 1
	MsgBox(0, "Test _ComputerGetPrintJobs", 			"Name: " & $PrintJob[$i][0] & @CRLF & _
			"DataType: " & $PrintJob[$i][1] & @CRLF & _
			"Document: " & $PrintJob[$i][2] & @CRLF & _
			"DriverName: " & $PrintJob[$i][3] & @CRLF & _
			"Description: " & $PrintJob[$i][4] & @CRLF & _
			"ElapsedTime: " & $PrintJob[$i][5] & @CRLF & _
			"HostPrintQueue: " & $PrintJob[$i][6] & @CRLF & _
			"JobId: " & $PrintJob[$i][7] & @CRLF & _
			"JobStatus: " & $PrintJob[$i][8] & @CRLF & _
			"Name: " & $PrintJob[$i][9] & @CRLF & _
			"Notify: " & $PrintJob[$i][10] & @CRLF & _
			"Owner: " & $PrintJob[$i][11] & @CRLF & _
			"PagesPrinted: " & $PrintJob[$i][12] & @CRLF & _
			"Parameters: " & $PrintJob[$i][13] & @CRLF & _
			"PrintProcessor: " & $PrintJob[$i][14] & @CRLF & _
			"Priority: " & $PrintJob[$i][15] & @CRLF & _
			"Size: " & $PrintJob[$i][16] & @CRLF & _
			"StartTime: " & $PrintJob[$i][17] & @CRLF & _
			"Status: " & $PrintJob[$i][18] & @CRLF & _
			"StatusMask: " & $PrintJob[$i][19] & @CRLF & _
			"TimeSubmitted: " & $PrintJob[$i][20] & @CRLF & _
			"TotalPages: " & $PrintJob[$i][21] & @CRLF & _
			"UntilTime: " & $PrintJob[$i][22])
Next
#endregion Print Jobs

#region -- Processes
Dim $Processes

_ComputerGetProcesses($Processes)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $Processes[0][0] Step 1
	MsgBox(0, "Test _ComputerGetProcesses", "Name: " & $Processes[$i][0] & @CRLF & _
			"Command Line: " & $Processes[$i][1] & @CRLF & _
			"Creation Class Name: " & $Processes[$i][2] & @CRLF & _
			"Creation Date: " & $Processes[$i][3] & @CRLF & _
			"Description: " & $Processes[$i][4] & @CRLF & _
			"CS Creation Class Name: " & $Processes[$i][5] & @CRLF & _
			"CS Name: " & $Processes[$i][6] & @CRLF & _
			"Executable Path: " & $Processes[$i][7] & @CRLF & _
			"Execution State: " & $Processes[$i][8] & @CRLF & _
			"Handle: " & $Processes[$i][9] & @CRLF & _
			"Handle Count: " & $Processes[$i][10] & @CRLF & _
			"Kernel Mode Time: " & $Processes[$i][11] & @CRLF & _
			"Maximum Working Set Size: " & $Processes[$i][12] & @CRLF & _
			"Minimum Working Set Size: " & $Processes[$i][13] & @CRLF & _
			"OS Creation Class Name: " & $Processes[$i][14] & @CRLF & _
			"OS Name: " & $Processes[$i][15] & @CRLF & _
			"Other Operation Count: " & $Processes[$i][16] & @CRLF & _
			"Other Transfer Count: " & $Processes[$i][17] & @CRLF & _
			"Page Faults: " & $Processes[$i][18] & @CRLF & _
			"Page File Usage: " & $Processes[$i][19] & @CRLF & _
			"Parent Process ID: " & $Processes[$i][20] & @CRLF & _
			"Peak Page File Usage: " & $Processes[$i][21] & @CRLF & _
			"Peak Virtual Size: " & $Processes[$i][22] & @CRLF & _
			"Peak Working Set Size: " & $Processes[$i][23] & @CRLF & _
			"Priority: " & $Processes[$i][24] & @CRLF & _
			"Private Page Count: " & $Processes[$i][25] & @CRLF & _
			"Process ID: " & $Processes[$i][26] & @CRLF & _
			"Quota Non Paged Pool Usage: " & $Processes[$i][27] & @CRLF & _
			"Quota Paged Pool Usage: " & $Processes[$i][28] & @CRLF & _
			"Quota Peak Non Paged Pool Usage: " & $Processes[$i][29] & @CRLF & _
			"Quota Peak Paged Pool Usage: " & $Processes[$i][30] & @CRLF & _
			"Read Operation Count: " & $Processes[$i][31] & @CRLF & _
			"Read Transfer Count: " & $Processes[$i][32] & @CRLF & _
			"Session ID: " & $Processes[$i][33] & @CRLF & _
			"Status: " & $Processes[$i][34] & @CRLF & _
			"Thread Count: " & $Processes[$i][35] & @CRLF & _
			"User Mode Time: " & $Processes[$i][36] & @CRLF & _
			"Virtual Size: " & $Processes[$i][37] & @CRLF & _
			"Windows Version: " & $Processes[$i][38] & @CRLF & _
			"Working Set Size: " & $Processes[$i][39] & @CRLF & _
			"Write Operation Count: " & $Processes[$i][40] & @CRLF & _
			"Write Transfer Count: " & $Processes[$i][41])
Next
#endregion Processes

#region -- Services
Dim $Services

_ComputerGetServices($Services, "Running")
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $Services[0][0] Step 1
	MsgBox(0, "Test _ComputerGetServices", "Name: " & $Services[$i][0] & @CRLF & _
			"Accept Pause: " & $Services[$i][1] & @CRLF & _
			"Accept Stop: " & $Services[$i][2] & @CRLF & _
			"Check Point: " & $Services[$i][3] & @CRLF & _
			"Description: " & $Services[$i][4] & @CRLF & _
			"Creation Classname: " & $Services[$i][5] & @CRLF & _
			"Desktop Interact: " & $Services[$i][6] & @CRLF & _
			"Display Name: " & $Services[$i][7] & @CRLF & _
			"Error Control: " & $Services[$i][8] & @CRLF & _
			"Exit Code: " & $Services[$i][9] & @CRLF & _
			"Path Name: " & $Services[$i][10] & @CRLF & _
			"Process ID: " & $Services[$i][11] & @CRLF & _
			"Service Specific Exit Code: " & $Services[$i][12] & @CRLF & _
			"Service Type: " & $Services[$i][13] & @CRLF & _
			"Started: " & $Services[$i][14] & @CRLF & _
			"Start Mode: " & $Services[$i][15] & @CRLF & _
			"Start Name: " & $Services[$i][16] & @CRLF & _
			"State: " & $Services[$i][17] & @CRLF & _
			"Status: " & $Services[$i][18] & @CRLF & _
			"System Creation Classname: " & $Services[$i][19] & @CRLF & _
			"System Name: " & $Services[$i][20] & @CRLF & _
			"Tag ID: " & $Services[$i][21] & @CRLF & _
			"Wait Hint: " & $Services[$i][22])
Next
#endregion Services

#region -- Shares
Dim $Shares

_ComputerGetShares($Shares)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $Shares[0][0] Step 1
	MsgBox(0, "Test _ComputerGetShares", "Name: " & $Shares[$i][0] & @CRLF & _
			"Access Mask: " & $Shares[$i][1] & @CRLF & _
			"Allow Maximum: " & $Shares[$i][2] & @CRLF & _
			"Maximum Allowed: " & $Shares[$i][3] & @CRLF & _
			"Description: " & $Shares[$i][4] & @CRLF & _
			"Path: " & $Shares[$i][5] & @CRLF & _
			"Status: " & $Shares[$i][6] & @CRLF & _
			"Type: " & $Shares[$i][7])
Next
#endregion Shares

#region -- Software
Dim $Software

_ComputerGetSoftware($Software)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg("Array contains no data.")
	EndSwitch
EndIf

For $i = 1 To $Software[0][0] Step 1
	MsgBox(0, "_ComputerGetSoftware", "Name: " & $Software[$i][0] & @CRLF & _
			"Version: " & $Software[$i][1] & @CRLF & _
			"Publisher: " & $Software[$i][2] & @CRLF & _
			"Uninstall Path: " & $Software[$i][3])
Next
#endregion Software

#region -- Startup
Dim $Startup

_ComputerGetStartup($Startup)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $Startup[0][0] Step 1
	MsgBox(0, "Test _ComputerGetStartup", "Name: " & $Startup[$i][0] & @CRLF & _
			"User: " & $Startup[$i][1] & @CRLF & _
			"Location: " & $Startup[$i][2] & @CRLF & _
			"Command: " & $Startup[$i][3] & @CRLF & _
			"Description: " & $Startup[$i][4] & @CRLF & _
			"SettingID: " & $Startup[$i][5])
Next
#endregion Startup
#region -- Threads
Dim $Threads

_ComputerGetThreads($Threads)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $Threads[0][0] Step 1
	MsgBox(0, "Test _ComputerGetThreads", "Name: " & $Threads[$i][0] & @CRLF & _
			"Creation Class Name: " & $Threads[$i][1] & @CRLF & _
			"CS Creation Class Name: " & $Threads[$i][2] & @CRLF & _
			"CS Name: " & $Threads[$i][3] & @CRLF & _
			"Description: " & $Threads[$i][4] & @CRLF & _
			"Elapsed Time: " & $Threads[$i][5] & @CRLF & _
			"Execution State: " & $Threads[$i][6] & @CRLF & _
			"Handle: " & $Threads[$i][7] & @CRLF & _
			"Kernel Mode Time: " & $Threads[$i][8] & @CRLF & _
			"OS Creation Class Name: " & $Threads[$i][9] & @CRLF & _
			"OS Name: " & $Threads[$i][10] & @CRLF & _
			"Priority: " & $Threads[$i][11] & @CRLF & _
			"Priority Base: " & $Threads[$i][12] & @CRLF & _
			"Process Creation Class Name: " & $Threads[$i][13] & @CRLF & _
			"Process Handle: " & $Threads[$i][14] & @CRLF & _
			"Start Address: " & $Threads[$i][15] & @CRLF & _
			"Status: " & $Threads[$i][16] & @CRLF & _
			"Thread State: " & $Threads[$i][17] & @CRLF & _
			"Thread Wait Reason: " & $Threads[$i][18] & @CRLF & _
			"User Mode Time: " & $Threads[$i][19])
Next
#endregion Threads

#region -- Users
Dim $Users

_ComputerGetUsers($Users)

For $i = 1 To $Users[0][0] Step 1
	MsgBox(0, "Test _ComputerGetUsers", "Name: " & $Users[$i][0] & @CRLF & _
			"Domain: " & $Users[$i][1] & @CRLF & _
			"Status: " & $Users[$i][2] & @CRLF & _
			"Local Account: " & $Users[$i][3] & @CRLF & _
			"SID: " & $Users[$i][4] & @CRLF & _
			"SIDType: " & $Users[$i][5] & @CRLF & _
			"Description: " & $Users[$i][6] & @CRLF & _
			"Full Name: " & $Users[$i][7] & @CRLF & _
			"Disabled: " & $Users[$i][8] & @CRLF & _
			"Lockout: " & $Users[$i][9] & @CRLF & _
			"Password Changeable: " & $Users[$i][10] & @CRLF & _
			"Password Expires: " & $Users[$i][11] & @CRLF & _
			"Password Required: " & $Users[$i][12] & @CRLF & _
			"Account Type: " & $Users[$i][13])
Next
#endregion Users
#endregion Software Functions

#region ---- Hardware Functions
#region -- Battery
Dim $Battery

_ComputerGetBattery($Battery)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $Battery[0][0] Step 1
	MsgBox(0, "Test _ComputerGetBattery", 			"Name: " & $Battery[$i][0] & @CRLF & _
			"Availability: " & $Battery[$i][1] & @CRLF & _
			"BatteryRechargeTime: " & $Battery[$i][2] & @CRLF & _
			"BatteryStatus: " & $Battery[$i][3] & @CRLF & _
			"Description: " & $Battery[$i][4] & @CRLF & _
			"Chemistry: " & $Battery[$i][5] & @CRLF & _
			"ConfigManagerErrorCode: " & $Battery[$i][6] & @CRLF & _
			"ConfigManagerUserConfig: " & $Battery[$i][7] & @CRLF & _
			"CreationClassName: " & $Battery[$i][8] & @CRLF & _
			"DesignCapacity: " & $Battery[$i][9] & @CRLF & _
			"DesignVoltage: " & $Battery[$i][10] & @CRLF & _
			"DeviceID: " & $Battery[$i][11] & @CRLF & _
			"ErrorCleared: " & $Battery[$i][12] & @CRLF & _
			"ErrorDescription: " & $Battery[$i][13] & @CRLF & _
			"EstimatedChargeRemaining: " & $Battery[$i][14] & @CRLF & _
			"EstimatedRunTime: " & $Battery[$i][15] & @CRLF & _
			"ExpectedBatteryLife: " & $Battery[$i][16] & @CRLF & _
			"ExpectedLife: " & $Battery[$i][17] & @CRLF & _
			"FullChargeCapacity: " & $Battery[$i][18] & @CRLF & _
			"LastErrorCode: " & $Battery[$i][19] & @CRLF & _
			"MaxRechargeTime: " & $Battery[$i][20] & @CRLF & _
			"PNPDeviceID: " & $Battery[$i][21] & @CRLF & _
			"PowerManagementCapabilities: " & $Battery[$i][22] & @CRLF & _
			"PowerManagementSupported: " & $Battery[$i][23] & @CRLF & _
			"SmartBatteryVersion: " & $Battery[$i][24] & @CRLF & _
			"Status: " & $Battery[$i][25] & @CRLF & _
			"StatusInfo: " & $Battery[$i][26] & @CRLF & _
			"SystemCreationClassName: " & $Battery[$i][27] & @CRLF & _
			"SystemName: " & $Battery[$i][28] & @CRLF & _
			"TimeOnBattery: " & $Battery[$i][29] & @CRLF & _
			"TimeToFullCharge: " & $Battery[$i][30])
Next
#endregion Battery

#region -- BIOS
Dim $BIOS

_ComputerGetBIOS($BIOS)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $BIOS[0][0] Step 1
	MsgBox(0, "Test _ComputerGetBIOS", "Name: " & $BIOS[$i][0] & @CRLF & _
			"Status: " & $BIOS[$i][1] & @CRLF & _
			"BIOS Characteristics: " & $BIOS[$i][2] & @CRLF & _
			"BIOS Version: " & $BIOS[$i][3] & @CRLF & _
			"Description: " & $BIOS[$i][4] & @CRLF & _
			"Build Number: " & $BIOS[$i][5] & @CRLF & _
			"Code Set: " & $BIOS[$i][6] & @CRLF & _
			"Current Language: " & $BIOS[$i][7] & @CRLF & _
			"Identification Code: " & $BIOS[$i][8] & @CRLF & _
			"Installable Languages: " & $BIOS[$i][9] & @CRLF & _
			"Language Edition: " & $BIOS[$i][10] & @CRLF & _
			"List of Languages: " & $BIOS[$i][11] & @CRLF & _
			"Manufacturer: " & $BIOS[$i][12] & @CRLF & _
			"Other Target OS: " & $BIOS[$i][13] & @CRLF & _
			"Primary BIOS: " & $BIOS[$i][14] & @CRLF & _
			"Release Date: " & $BIOS[$i][15] & @CRLF & _
			"Serial Number: " & $BIOS[$i][16] & @CRLF & _
			"SM BIOS BIOS Version: " & $BIOS[$i][17] & @CRLF & _
			"SM BIOS Major Version: " & $BIOS[$i][18] & @CRLF & _
			"SM BIOS Minor Version: " & $BIOS[$i][19] & @CRLF & _
			"SM BIOS Present: " & $BIOS[$i][20] & @CRLF & _
			"Software Element ID: " & $BIOS[$i][21] & @CRLF & _
			"Software Element State: " & $BIOS[$i][22] & @CRLF & _
			"Target Operating System: " & $BIOS[$i][23] & @CRLF & _
			"Version: " & $BIOS[$i][24])
Next
#endregion BIOS

#region -- Drives
Dim $Drives

_ComputerGetDrives($Drives) ;Defaults to "FIXED"
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg("DriveGetDrive Error!")
		Case 2
			_ErrorMsg("DriveGetFileSystem Error!")
		Case 3
			_ErrorMsg("DriveGetLabel Error!")
		Case 4
			_ErrorMsg("DriveGetSerial Error!")
		Case 5
			_ErrorMsg("DriveSpaceFree Error!")
		Case 6
			_ErrorMsg("DriveSpaceTotal Error!")
	EndSwitch
EndIf

For $i = 1 To $Drives[0][0] Step 1
	MsgBox(0, "Drive: " & $Drives[$i][0], "FileSystem: " & $Drives[$i][1] & @CRLF & "Label: " & $Drives[$i][2] & @CRLF & "Serial #: " & $Drives[$i][3] & @CRLF & "Free Space: " & Round($Drives[$i][4] / 1024, 2) & "GB" & @CRLF & "Total Space: " & Round($Drives[$i][5] / 1024, 2) & "GB")
Next
#endregion Drives

#region -- Keyboard
Dim $Keyboard

_ComputerGetKeyboard($Keyboard)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $Keyboard[0][0] Step 1
	MsgBox(0, "Test _ComputerGetKeyboard", "Name: " & $Keyboard[$i][0] & @CRLF & _
			"Availability: " & $Keyboard[$i][1] & @CRLF & _
			"Config Manager Error Code: " & $Keyboard[$i][2] & @CRLF & _
			"Config Manager User Config: " & $Keyboard[$i][3] & @CRLF & _
			"Description: " & $Keyboard[$i][4] & @CRLF & _
			"Creation Class Name: " & $Keyboard[$i][5] & @CRLF & _
			"Device ID: " & $Keyboard[$i][6] & @CRLF & _
			"Error Cleared: " & $Keyboard[$i][7] & @CRLF & _
			"Error Description: " & $Keyboard[$i][8] & @CRLF & _
			"Is Locked: " & $Keyboard[$i][9] & @CRLF & _
			"Last Error Code: " & $Keyboard[$i][10] & @CRLF & _
			"Layout: " & $Keyboard[$i][11] & @CRLF & _
			"Number of Function Keys: " & $Keyboard[$i][12] & @CRLF & _
			"Password: " & $Keyboard[$i][13] & @CRLF & _
			"PNP Device ID: " & $Keyboard[$i][14] & @CRLF & _
			"Power Management Capabilities: " & $Keyboard[$i][15] & @CRLF & _
			"Power Management Supported: " & $Keyboard[$i][16] & @CRLF & _
			"Status: " & $Keyboard[$i][17] & @CRLF & _
			"Status Info: " & $Keyboard[$i][18] & @CRLF & _
			"System Creation Class Name: " & $Keyboard[$i][19] & @CRLF & _
			"System Name: " & $Keyboard[$i][20])
Next
#endregion Keyboard

#region -- Memory
Dim $Memory

_ComputerGetMemory($Memory)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $Memory[0][0] Step 1
	MsgBox(0, "Test _ComputerGetMemory", 			"Name: " & $Memory[$i][0] & @CRLF & _
			"BankLabel: " & $Memory[$i][1] & @CRLF & _
			"Capacity: " & $Memory[$i][2] & @CRLF & _
			"CreationClassName: " & $Memory[$i][3] & @CRLF & _
			"Description: " & $Memory[$i][4] & @CRLF & _
			"DataWidth: " & $Memory[$i][5] & @CRLF & _
			"DeviceLocator: " & $Memory[$i][6] & @CRLF & _
			"FormFactor: " & $Memory[$i][7] & @CRLF & _
			"HotSwappable: " & $Memory[$i][8] & @CRLF & _
			"InterleaveDataDepth: " & $Memory[$i][9] & @CRLF & _
			"InterleavePosition: " & $Memory[$i][10] & @CRLF & _
			"Manufacturer: " & $Memory[$i][11] & @CRLF & _
			"MemoryType: " & $Memory[$i][12] & @CRLF & _
			"Model: " & $Memory[$i][13] & @CRLF & _
			"OtherIdentifyingInfo: " & $Memory[$i][14] & @CRLF & _
			"PartNumber: " & $Memory[$i][15] & @CRLF & _
			"PositionInRow: " & $Memory[$i][16] & @CRLF & _
			"PoweredOn: " & $Memory[$i][17] & @CRLF & _
			"Removable: " & $Memory[$i][18] & @CRLF & _
			"Replaceable: " & $Memory[$i][19] & @CRLF & _
			"SerialNumber: " & $Memory[$i][20] & @CRLF & _
			"SKU: " & $Memory[$i][21] & @CRLF & _
			"Speed: " & $Memory[$i][22] & @CRLF & _
			"Status: " & $Memory[$i][23] & @CRLF & _
			"Tag: " & $Memory[$i][24] & @CRLF & _
			"TotalWidth: " & $Memory[$i][25] & @CRLF & _
			"TypeDetail: " & $Memory[$i][26] & @CRLF & _
			"Version: " & $Memory[$i][27])
Next
#endregion Memory

#region -- Monitors
Dim $Monitor

_ComputerGetMonitors($Monitor)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $Monitor[0][0] Step 1
	MsgBox(0, "Test _ComputerGetMonitors", 			"Name: " & $Monitor[$i][0] & @CRLF & _
			"Availability: " & $Monitor[$i][1] & @CRLF & _
			"Bandwidth: " & $Monitor[$i][2] & @CRLF & _
			"ConfigManagerErrorCode: " & $Monitor[$i][3] & @CRLF & _
			"Description: " & $Monitor[$i][4] & @CRLF & _
			"ConfigManagerUserConfig: " & $Monitor[$i][5] & @CRLF & _
			"CreationClassName: " & $Monitor[$i][6] & @CRLF & _
			"DeviceID: " & $Monitor[$i][7] & @CRLF & _
			"DisplayType: " & $Monitor[$i][8] & @CRLF & _
			"ErrorCleared: " & $Monitor[$i][9] & @CRLF & _
			"ErrorDescription: " & $Monitor[$i][10] & @CRLF & _
			"IsLocked: " & $Monitor[$i][11] & @CRLF & _
			"LastErrorCode: " & $Monitor[$i][12] & @CRLF & _
			"MonitorManufacturer: " & $Monitor[$i][13] & @CRLF & _
			"MonitorType: " & $Monitor[$i][14] & @CRLF & _
			"PixelsPerXLogicalInch: " & $Monitor[$i][15] & @CRLF & _
			"PixelsPerYLogicalInch: " & $Monitor[$i][16] & @CRLF & _
			"PNPDeviceID: " & $Monitor[$i][17] & @CRLF & _
			"PowerManagementCapabilities: " & $Monitor[$i][18] & @CRLF & _
			"PowerManagementSupported: " & $Monitor[$i][19] & @CRLF & _
			"ScreenHeight: " & $Monitor[$i][20] & @CRLF & _
			"ScreenWidth: " & $Monitor[$i][21] & @CRLF & _
			"Status: " & $Monitor[$i][22] & @CRLF & _
			"StatusInfo: " & $Monitor[$i][23] & @CRLF & _
			"SystemCreationClassName: " & $Monitor[$i][24] & @CRLF & _
			"SystemName: " & $Monitor[$i][25])
Next
#endregion Monitors

#region -- Motherboard
Dim $Motherboard

_ComputerGetMotherboard($Motherboard)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $Motherboard[0][0] Step 1
	MsgBox(0, "Test _ComputerGetMotherboard", 			"Name: " & $Motherboard[$i][0] & @CRLF & _
			"Availability: " & $Motherboard[$i][1] & @CRLF & _
			"ConfigManagerErrorCode: " & $Motherboard[$i][2] & @CRLF & _
			"ConfigManagerUserConfig: " & $Motherboard[$i][3] & @CRLF & _
			"Description: " & $Motherboard[$i][4] & @CRLF & _
			"CreationClassName: " & $Motherboard[$i][5] & @CRLF & _
			"DeviceID: " & $Motherboard[$i][6] & @CRLF & _
			"ErrorCleared: " & $Motherboard[$i][7] & @CRLF & _
			"ErrorDescription: " & $Motherboard[$i][8] & @CRLF & _
			"LastErrorCode: " & $Motherboard[$i][9] & @CRLF & _
			"PNPDeviceID: " & $Motherboard[$i][10] & @CRLF & _
			"PowerManagementCapabilities: " & $Motherboard[$i][11] & @CRLF & _
			"PowerManagementSupported: " & $Motherboard[$i][12] & @CRLF & _
			"PrimaryBusType: " & $Motherboard[$i][13] & @CRLF & _
			"RevisionNumber: " & $Motherboard[$i][14] & @CRLF & _
			"SecondaryBusType: " & $Motherboard[$i][15] & @CRLF & _
			"Status: " & $Motherboard[$i][16] & @CRLF & _
			"StatusInfo: " & $Motherboard[$i][17] & @CRLF & _
			"SystemCreationClassName: " & $Motherboard[$i][18] & @CRLF & _
			"SystemName: " & $Motherboard[$i][19])
Next
#endregion Motherboard

#region -- Mouse
Dim $Mouse

_ComputerGetMouse($Mouse)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $Mouse[0][0] Step 1
	MsgBox(0, "Test _ComputerGetMouse", "Name: " & $Mouse[$i][0] & @CRLF & _
			"Availability: " & $Mouse[$i][1] & @CRLF & _
			"Config Manager Error Code: " & $Mouse[$i][2] & @CRLF & _
			"Config Manager User Config: " & $Mouse[$i][3] & @CRLF & _
			"Description: " & $Mouse[$i][4] & @CRLF & _
			"Creation Class Name: " & $Mouse[$i][5] & @CRLF & _
			"Device ID: " & $Mouse[$i][6] & @CRLF & _
			"Device Interface: " & $Mouse[$i][7] & @CRLF & _
			"Double Speed Threshold: " & $Mouse[$i][8] & @CRLF & _
			"Error Cleared: " & $Mouse[$i][9] & @CRLF & _
			"Error Description: " & $Mouse[$i][10] & @CRLF & _
			"Handedness: " & $Mouse[$i][11] & @CRLF & _
			"Hardware Type: " & $Mouse[$i][12] & @CRLF & _
			"Inf File Name: " & $Mouse[$i][13] & @CRLF & _
			"Inf Section: " & $Mouse[$i][14] & @CRLF & _
			"Is Locked: " & $Mouse[$i][15] & @CRLF & _
			"Last Error Code: " & $Mouse[$i][16] & @CRLF & _
			"Manufacturer: " & $Mouse[$i][17] & @CRLF & _
			"Number Of Buttons: " & $Mouse[$i][18] & @CRLF & _
			"PNP Device ID: " & $Mouse[$i][19] & @CRLF & _
			"Pointing Type: " & $Mouse[$i][20] & @CRLF & _
			"Power Management Capabilities: " & $Mouse[$i][21] & @CRLF & _
			"Power Management Supported: " & $Mouse[$i][22] & @CRLF & _
			"Quad Speed Threshold: " & $Mouse[$i][23] & @CRLF & _
			"Resolution: " & $Mouse[$i][24] & @CRLF & _
			"Sample Rate: " & $Mouse[$i][25] & @CRLF & _
			"Status: " & $Mouse[$i][26] & @CRLF & _
			"Status Info: " & $Mouse[$i][27] & @CRLF & _
			"Synch: " & $Mouse[$i][28] & @CRLF & _
			"System Creation Class Name: " & $Mouse[$i][29] & @CRLF & _
			"System Name: " & $Mouse[$i][30])
Next
#endregion Mouse

#region -- Network Cards
Dim $NetworkCards

_ComputerGetNetworkCards($NetworkCards)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $NetworkCards[0][0] Step 1
	MsgBox(0, "Test _ComputerGetNetworkCards", "Name: " & $NetworkCards[$i][0] & @CRLF & _
			"Adapter Type: " & $NetworkCards[$i][1] & @CRLF & _
			"Adapter Type ID: " & $NetworkCards[$i][2] & @CRLF & _
			"Auto Sense: " & $NetworkCards[$i][3] & @CRLF & _
			"Description: " & $NetworkCards[$i][4] & @CRLF & _
			"Availability: " & $NetworkCards[$i][5] & @CRLF & _
			"Config Manager Error Code: " & $NetworkCards[$i][6] & @CRLF & _
			"Config Manager User Config: " & $NetworkCards[$i][7] & @CRLF & _
			"Creation Class Name: " & $NetworkCards[$i][8] & @CRLF & _
			"Device ID: " & $NetworkCards[$i][9] & @CRLF & _
			"Error Cleared: " & $NetworkCards[$i][10] & @CRLF & _
			"Error Description: " & $NetworkCards[$i][11] & @CRLF & _
			"Index: " & $NetworkCards[$i][12] & @CRLF & _
			"Installed: " & $NetworkCards[$i][13] & @CRLF & _
			"Last Error Code: " & $NetworkCards[$i][14] & @CRLF & _
			"MAC Address: " & $NetworkCards[$i][15] & @CRLF & _
			"Manufacturer: " & $NetworkCards[$i][16] & @CRLF & _
			"Max Number Controlled: " & $NetworkCards[$i][17] & @CRLF & _
			"Max Speed: " & $NetworkCards[$i][18] & @CRLF & _
			"Net Connection ID: " & $NetworkCards[$i][19] & @CRLF & _
			"Net Connection Status: " & $NetworkCards[$i][20] & @CRLF & _
			"Network Addresses: " & $NetworkCards[$i][21] & @CRLF & _
			"Permanent Address: " & $NetworkCards[$i][22] & @CRLF & _
			"PNP Device ID: " & $NetworkCards[$i][23] & @CRLF & _
			"Power Management Capabilities: " & $NetworkCards[$i][24] & @CRLF & _
			"Power Management Supported: " & $NetworkCards[$i][25] & @CRLF & _
			"Product Name: " & $NetworkCards[$i][26] & @CRLF & _
			"Service Name: " & $NetworkCards[$i][27] & @CRLF & _
			"Speed: " & $NetworkCards[$i][28] & @CRLF & _
			"Status: " & $NetworkCards[$i][29] & @CRLF & _
			"Status Info: " & $NetworkCards[$i][30] & @CRLF & _
			"System Creation Class Name: " & $NetworkCards[$i][31] & @CRLF & _
			"System Name: " & $NetworkCards[$i][32] & @CRLF & _
			"Time Of Last Reset: " & $NetworkCards[$i][33])
Next
#endregion

#region -- Printers
;NOTE: Printers contains alot of information, and may require a different output format.
Dim $Print

_ComputerGetPrinters($Print)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $Print[0][0] Step 1
	MsgBox(0, "Test _ComputerGetPrinters", "Name: " & $Print[$i][0] & @CRLF & _
			"Attributes: " & $Print[$i][1] & @CRLF & _
			"Availability: " & $Print[$i][2] & @CRLF & _
			"AvailableJobSheets: " & $Print[$i][3] & @CRLF & _
			"Description: " & $Print[$i][4] & @CRLF & _
			"AveragePagesPerMinute: " & $Print[$i][5] & @CRLF & _
			"Capabilities: " & $Print[$i][6] & @CRLF & _
			"CapabilityDescriptions: " & $Print[$i][7] & @CRLF & _
			"CharSetsSupported: " & $Print[$i][8] & @CRLF & _
			"Comment: " & $Print[$i][9] & @CRLF & _
			"ConfigManagerErrorCode: " & $Print[$i][10] & @CRLF & _
			"ConfigManagerUserConfig: " & $Print[$i][11] & @CRLF & _
			"CreationClassName: " & $Print[$i][12] & @CRLF & _
			"CurrentCapabilities: " & $Print[$i][13] & @CRLF & _
			"CurrentCharSet: " & $Print[$i][14] & @CRLF & _
			"CurrentLanguage: " & $Print[$i][15] & @CRLF & _
			"CurrentMimeType: " & $Print[$i][16] & @CRLF & _
			"CurrentNaturalLanguage: " & $Print[$i][17] & @CRLF & _
			"CurrentPaperType: " & $Print[$i][18] & @CRLF & _
			"Default: " & $Print[$i][19] & @CRLF & _
			"DefaultCapabilities: " & $Print[$i][20] & @CRLF & _
			"DefaultCopies: " & $Print[$i][21] & @CRLF & _
			"DefaultLanguage: " & $Print[$i][22] & @CRLF & _
			"DefaultMimeType: " & $Print[$i][23] & @CRLF & _
			"DefaultNumberUp: " & $Print[$i][24] & @CRLF & _
			"DefaultPaperType: " & $Print[$i][25] & @CRLF & _
			"DefaultPriority: " & $Print[$i][26] & @CRLF & _
			"DetectedErrorState: " & $Print[$i][27] & @CRLF & _
			"DeviceID: " & $Print[$i][28] & @CRLF & _
			"Direct: " & $Print[$i][29] & @CRLF & _
			"DoCompleteFirst: " & $Print[$i][30] & @CRLF & _
			"DriverName: " & $Print[$i][31] & @CRLF & _
			"EnableBIDI: " & $Print[$i][32] & @CRLF & _
			"EnableDevQueryPrint: " & $Print[$i][33] & @CRLF & _
			"ErrorCleared: " & $Print[$i][34] & @CRLF & _
			"ErrorDescription: " & $Print[$i][35] & @CRLF & _
			"ErrorInformation: " & $Print[$i][36] & @CRLF & _
			"ExtendedDetectedErrorState: " & $Print[$i][37] & @CRLF & _
			"ExtendedPrinttatus: " & $Print[$i][38] & @CRLF & _
			"Hidden: " & $Print[$i][39] & @CRLF & _
			"HorizontalResolution: " & $Print[$i][40] & @CRLF & _
			"JobCountSinceLastReset: " & $Print[$i][42] & @CRLF & _
			"KeepPrintedJobs: " & $Print[$i][43] & @CRLF & _
			"LanguagesSupported: " & $Print[$i][44] & @CRLF & _
			"LastErrorCode: " & $Print[$i][45] & @CRLF & _
			"Local: " & $Print[$i][46] & @CRLF & _
			"Location: " & $Print[$i][47] & @CRLF & _
			"MarkingTechnology: " & $Print[$i][48] & @CRLF & _
			"MaxCopies: " & $Print[$i][49] & @CRLF & _
			"MaxNumberUp: " & $Print[$i][50] & @CRLF & _
			"MaxSizeSupported: " & $Print[$i][51] & @CRLF & _
			"MimeTypesSupported: " & $Print[$i][52] & @CRLF & _
			"NaturalLanguagesSupported: " & $Print[$i][53] & @CRLF & _
			"Network: " & $Print[$i][54] & @CRLF & _
			"PaperSizesSupported: " & $Print[$i][55] & @CRLF & _
			"PaperTypesAvailable: " & $Print[$i][56] & @CRLF & _
			"Parameters: " & $Print[$i][57] & @CRLF & _
			"PNPDeviceID: " & $Print[$i][58] & @CRLF & _
			"PortName: " & $Print[$i][59] & @CRLF & _
			"PowerManagementCapabilities: " & $Print[$i][60] & @CRLF & _
			"PowerManagementSupported: " & $Print[$i][61] & @CRLF & _
			"PrinterPaperNames: " & $Print[$i][62] & @CRLF & _
			"Printtate: " & $Print[$i][63] & @CRLF & _
			"Printtatus: " & $Print[$i][64] & @CRLF & _
			"PrintJobDataType: " & $Print[$i][65] & @CRLF & _
			"PrintProcessor: " & $Print[$i][66] & @CRLF & _
			"Priority: " & $Print[$i][67] & @CRLF & _
			"Published: " & $Print[$i][68] & @CRLF & _
			"Queued: " & $Print[$i][69] & @CRLF & _
			"RawOnly: " & $Print[$i][70] & @CRLF & _
			"SeparatorFile: " & $Print[$i][71] & @CRLF & _
			"ServerName: " & $Print[$i][72] & @CRLF & _
			"Shared: " & $Print[$i][73] & @CRLF & _
			"ShareName: " & $Print[$i][74] & @CRLF & _
			"SpoolEnabled: " & $Print[$i][75] & @CRLF & _
			"Status: " & $Print[$i][77] & @CRLF & _
			"StatusInfo: " & $Print[$i][78] & @CRLF & _
			"SystemCreationClassName: " & $Print[$i][79] & @CRLF & _
			"SystemName: " & $Print[$i][80] & @CRLF & _
			"VerticalResolution: " & $Print[$i][83] & @CRLF & _
			"WorkOffline: " & $Print[$i][84])
Next
#endregion Printers

#region -- Processors
Dim $Processors

_ComputerGetProcessors($Processors)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $Processors[0][0] Step 1
	MsgBox(0, "Test _ComputerGetProcessors", "Name: " & $Processors[$i][0] & @CRLF & _
			"Address Width: " & $Processors[$i][1] & @CRLF & _
			"Architecture: " & $Processors[$i][2] & @CRLF & _
			"Availability: " & $Processors[$i][3] & @CRLF & _
			"Description: " & $Processors[$i][4] & @CRLF & _
			"Config Manager Error Code: " & $Processors[$i][5] & @CRLF & _
			"Config Manager User Config: " & $Processors[$i][6] & @CRLF & _
			"CPU Status: " & $Processors[$i][7] & @CRLF & _
			"Creation Class Name: " & $Processors[$i][8] & @CRLF & _
			"Current Clock Speed: " & $Processors[$i][9] & @CRLF & _
			"Current Voltage: " & $Processors[$i][10] & @CRLF & _
			"Data Width: " & $Processors[$i][11] & @CRLF & _
			"Device ID: " & $Processors[$i][12] & @CRLF & _
			"Error Cleared: " & $Processors[$i][13] & @CRLF & _
			"Error Description: " & $Processors[$i][14] & @CRLF & _
			"Ext Clock: " & $Processors[$i][15] & @CRLF & _
			"Family: " & $Processors[$i][16] & @CRLF & _
			"L2 Cache Size: " & $Processors[$i][17] & @CRLF & _
			"L2 Cache Speed: " & $Processors[$i][18] & @CRLF & _
			"Last Error Code: " & $Processors[$i][19] & @CRLF & _
			"Level: " & $Processors[$i][20] & @CRLF & _
			"Load Percentage: " & $Processors[$i][21] & @CRLF & _
			"Manufacturer: " & $Processors[$i][22] & @CRLF & _
			"Max Clock Speed: " & $Processors[$i][23] & @CRLF & _
			"Other Family Description: " & $Processors[$i][24] & @CRLF & _
			"PNP Device ID: " & $Processors[$i][25] & @CRLF & _
			"Power Management Capabilities: " & $Processors[$i][26] & @CRLF & _
			"Power Management Supported: " & $Processors[$i][27] & @CRLF & _
			"Processor ID: " & $Processors[$i][28] & @CRLF & _
			"Processor Type: " & $Processors[$i][29] & @CRLF & _
			"Revision: " & $Processors[$i][30] & @CRLF & _
			"Role: " & $Processors[$i][31] & @CRLF & _
			"Socket Designation: " & $Processors[$i][32] & @CRLF & _
			"Status: " & $Processors[$i][33] & @CRLF & _
			"Status Info: " & $Processors[$i][34] & @CRLF & _
			"Stepping: " & $Processors[$i][35] & @CRLF & _
			"System Creation Class Name: " & $Processors[$i][36] & @CRLF & _
			"System Name: " & $Processors[$i][37] & @CRLF & _
			"Unique ID: " & $Processors[$i][38] & @CRLF & _
			"Upgrade Method: " & $Processors[$i][39] & @CRLF & _
			"Version: " & $Processors[$i][40] & @CRLF & _
			"Voltage Caps: " & $Processors[$i][41])
Next
#endregion Processors

#region -- Sound Cards
Dim $SoundCards

_ComputerGetSoundCards($SoundCards)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $SoundCards[0][0] Step 1
	MsgBox(0, "Test _ComputerGetSoundCards", "Name: " & $SoundCards[$i][0] & @CRLF & _
			"Availability: " & $SoundCards[$i][1] & @CRLF & _
			"Config Manager Error Code: " & $SoundCards[$i][2] & @CRLF & _
			"Config Manager User Config: " & $SoundCards[$i][3] & @CRLF & _
			"Description: " & $SoundCards[$i][4] & @CRLF & _
			"Creation Class Name: " & $SoundCards[$i][5] & @CRLF & _
			"Device ID: " & $SoundCards[$i][6] & @CRLF & _
			"DMA Buffer Size: " & $SoundCards[$i][7] & @CRLF & _
			"Error Cleared: " & $SoundCards[$i][8] & @CRLF & _
			"Error Description: " & $SoundCards[$i][9] & @CRLF & _
			"Last Error Code: " & $SoundCards[$i][10] & @CRLF & _
			"Manufacturer: " & $SoundCards[$i][11] & @CRLF & _
			"MPU 401 Address: " & $SoundCards[$i][12] & @CRLF & _
			"PNP Device ID: " & $SoundCards[$i][13] & @CRLF & _
			"Power Management Capabilities: " & $SoundCards[$i][14] & @CRLF & _
			"Power Management Supported: " & $SoundCards[$i][15] & @CRLF & _
			"Product Name: " & $SoundCards[$i][16] & @CRLF & _
			"Status: " & $SoundCards[$i][17] & @CRLF & _
			"Status Info: " & $SoundCards[$i][18] & @CRLF & _
			"System Creation Class Name: " & $SoundCards[$i][19] & @CRLF & _
			"System Name: " & $SoundCards[$i][20])
Next
#endregion Sound Cards

#region -- System
Dim $System

_ComputerGetSystem($System)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg("Array contains no information.")
		Case 2
			_ErrorMsg("$colItems isnt an object.")
	EndSwitch
EndIf

For $i = 1 To $System[0][0] Step 1
	MsgBox(0, "Test _ComputerGetSystem", "Name: " & $System[$i][0] & @CRLF & _
											"Admin Password Status: " & $System[$i][1] & @CRLF & _
											"Automatic Reset Boot Option: " & $System[$i][2] & @CRLF & _
											"Automatic Reset Capability: " & $System[$i][3] & @CRLF & _
											"Description: " & $System[$i][4] & @CRLF & _
											"Boot Option On Limit: " & $System[$i][5] & @CRLF & _
											"Boot Option On WatchDog: " & $System[$i][6] & @CRLF & _
											"Boot ROM Supported: " & $System[$i][7] & @CRLF & _
											"Bootup State: " & $System[$i][8] & @CRLF & _
											"Chassis Bootup State: " & $System[$i][9] & @CRLF & _
											"Creation Class Name: " & $System[$i][10] & @CRLF & _
											"Current Time Zone: " & $System[$i][11] & @CRLF & _
											"Daylight In Effect: " & $System[$i][12] & @CRLF & _
											"Domain: " & $System[$i][13] & @CRLF & _
											"Domain Role: " & $System[$i][14] & @CRLF & _
											"Enable Daylight Savings Time: " & $System[$i][15] & @CRLF & _
											"Front Panel Reset Status: " & $System[$i][16] & @CRLF & _
											"Infrared Supported: " & $System[$i][17] & @CRLF & _
											"Initial Load Info: " & $System[$i][18] & @CRLF & _
											"Keyboard Password Status: " & $System[$i][19] & @CRLF & _
											"Last Load Info: " & $System[$i][20] & @CRLF & _
											"Manufacturer: " & $System[$i][21] & @CRLF & _
											"Model: " & $System[$i][22] & @CRLF & _
											"Name Format: " & $System[$i][23] & @CRLF & _
											"Network Server Mode Enabled: " & $System[$i][24] & @CRLF & _
											"Number Of Processors: " & $System[$i][25] & @CRLF & _
											"OEM Logo Bitmap: " & $System[$i][26] & @CRLF & _
											"OEM String Array: " & $System[$i][27] & @CRLF & _
											"Part Of Domain: " & $System[$i][28] & @CRLF & _
											"Pause After Reset: " & $System[$i][29] & @CRLF & _
											"Power Management Capabilities: " & $System[$i][30] & @CRLF & _
											"Power Management Supported: " & $System[$i][31] & @CRLF & _
											"Power On Password Status: " & $System[$i][32] & @CRLF & _
											"Power State: " & $System[$i][33] & @CRLF & _
											"Power Supply State: " & $System[$i][34] & @CRLF & _
											"Primary Owner Contact: " & $System[$i][35] & @CRLF & _
											"Primary Owner Name: " & $System[$i][36] & @CRLF & _
											"Reset Capability: " & $System[$i][37] & @CRLF & _
											"Reset Count: " & $System[$i][38] & @CRLF & _
											"Reset Limit: " & $System[$i][39] & @CRLF & _
											"Roles: " & $System[$i][40] & @CRLF & _
											"Status: " & $System[$i][41] & @CRLF & _
											"Support Contact Description: " & $System[$i][42] & @CRLF & _
											"System Startup Delay: " & $System[$i][43] & @CRLF & _
											"System Startup Options: " & $System[$i][44] & @CRLF & _
											"System Startup Setting: " & $System[$i][45] & @CRLF & _
											"System Type: " & $System[$i][46] & @CRLF & _
											"Thermal State: " & $System[$i][47] & @CRLF & _
											"Total Physical Memory: " & $System[$i][48] & @CRLF & _
											"User Name: " & $System[$i][49] & @CRLF & _
											"Wake Up Type: " & $System[$i][50] & @CRLF & _
											"Workgroup: " & $System[$i][51])
Next
#endregion System

#region -- System Product
;NOTE: UUID will return 0000's if it is unable to create a UUID.
Dim $SystemProduct

_ComputerGetSystemProduct($SystemProduct)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $SystemProduct[0][0] Step 1
	MsgBox(0, "Test _ComputerGetSystemProduct", "Name: " & $SystemProduct[$i][0] & @CRLF & _
			"Identifying Number: " & $SystemProduct[$i][1] & @CRLF & _
			"SKU Number: " & $SystemProduct[$i][2] & @CRLF & _
			"UUID: " & $SystemProduct[$i][3] & @CRLF & _
			"Description: " & $SystemProduct[$i][4] & @CRLF & _
			"Vendor: " & $SystemProduct[$i][5] & @CRLF & _
			"Version: " & $SystemProduct[$i][6])
Next
#endregion System Product

#region -- Video Cards
Dim $VideoCards

_ComputerGetVideoCards($VideoCards)
If @error Then
	$error = @error
	$extended = @extended
	Switch $extended
		Case 1
			_ErrorMsg($ERR_NO_INFO)
		Case 2
			_ErrorMsg($ERR_NOT_OBJ)
	EndSwitch
EndIf

For $i = 1 To $VideoCards[0][0] Step 1
	MsgBox(0, "Test _ComputerGetVideoCards", "Name: " & $VideoCards[$i][0] & @CRLF & _
			"Accelerator Capabilities: " & $VideoCards[$i][1] & @CRLF & _
			"Adapter Compatibility: " & $VideoCards[$i][2] & @CRLF & _
			"Adapter DAC Type: " & $VideoCards[$i][3] & @CRLF & _
			"Description: " & $VideoCards[$i][4] & @CRLF & _
			"Adapter RAM: " & $VideoCards[$i][5] & @CRLF & _
			"Availability: " & $VideoCards[$i][6] & @CRLF & _
			"Capability Descriptions: " & $VideoCards[$i][7] & @CRLF & _
			"Color Table Entries: " & $VideoCards[$i][8] & @CRLF & _
			"Config Manager Error Code: " & $VideoCards[$i][9] & @CRLF & _
			"Config Manager User Config: " & $VideoCards[$i][10] & @CRLF & _
			"Creation Class Name: " & $VideoCards[$i][11] & @CRLF & _
			"Current Bits Per Pixel: " & $VideoCards[$i][12] & @CRLF & _
			"Current Horizontal Resolution: " & $VideoCards[$i][13] & @CRLF & _
			"Current Number Of Colors: " & $VideoCards[$i][14] & @CRLF & _
			"Current Number Of Columns: " & $VideoCards[$i][15] & @CRLF & _
			"Current Number Of Rows: " & $VideoCards[$i][16] & @CRLF & _
			"Current Refresh Rate: " & $VideoCards[$i][17] & @CRLF & _
			"Current Scan Mode: " & $VideoCards[$i][18] & @CRLF & _
			"Current Vertical Resolution: " & $VideoCards[$i][19] & @CRLF & _
			"Device ID: " & $VideoCards[$i][20] & @CRLF & _
			"Device Specific Pens: " & $VideoCards[$i][21] & @CRLF & _
			"Dither Type: " & $VideoCards[$i][22] & @CRLF & _
			"Driver Date: " & $VideoCards[$i][23] & @CRLF & _
			"Driver Version: " & $VideoCards[$i][24] & @CRLF & _
			"Error Cleared: " & $VideoCards[$i][25] & @CRLF & _
			"Error Description: " & $VideoCards[$i][26] & @CRLF & _
			"ICM Intent: " & $VideoCards[$i][27] & @CRLF & _
			"ICM Method: " & $VideoCards[$i][28] & @CRLF & _
			"Inf Filename: " & $VideoCards[$i][29] & @CRLF & _
			"Inf Section: " & $VideoCards[$i][30] & @CRLF & _
			"Installed Display Drivers: " & $VideoCards[$i][31] & @CRLF & _
			"Last Error Code: " & $VideoCards[$i][32] & @CRLF & _
			"Max Memory Supported: " & $VideoCards[$i][33] & @CRLF & _
			"Max Number Controlled: " & $VideoCards[$i][34] & @CRLF & _
			"Max Refresh Rate: " & $VideoCards[$i][35] & @CRLF & _
			"Min Refresh Rate: " & $VideoCards[$i][36] & @CRLF & _
			"Monochrome: " & $VideoCards[$i][37] & @CRLF & _
			"Number Of Color Planes: " & $VideoCards[$i][38] & @CRLF & _
			"Number Of Video Pages: " & $VideoCards[$i][39] & @CRLF & _
			"PNP Device ID: " & $VideoCards[$i][40] & @CRLF & _
			"Power Management Capabilities: " & $VideoCards[$i][41] & @CRLF & _
			"Power Management Supported: " & $VideoCards[$i][42] & @CRLF & _
			"Protocol Supported: " & $VideoCards[$i][43] & @CRLF & _
			"Reserved System Palette Entries: " & $VideoCards[$i][44] & @CRLF & _
			"Specification Version: " & $VideoCards[$i][45] & @CRLF & _
			"Status: " & $VideoCards[$i][46] & @CRLF & _
			"Status Info: " & $VideoCards[$i][47] & @CRLF & _
			"System Creation Class Name: " & $VideoCards[$i][48] & @CRLF & _
			"System Name: " & $VideoCards[$i][49] & @CRLF & _
			"System Palette Entries: " & $VideoCards[$i][50] & @CRLF & _
			"Time Of Last Reset: " & $VideoCards[$i][51] & @CRLF & _
			"Video Architecture: " & $VideoCards[$i][52] & @CRLF & _
			"Video Memory Type: " & $VideoCards[$i][53] & @CRLF & _
			"Video Mode: " & $VideoCards[$i][54] & @CRLF & _
			"Video Mode Description: " & $VideoCards[$i][55] & @CRLF & _
			"Video Processor: " & $VideoCards[$i][56])
Next
#endregion Video Cards

#endregion Hardware Functions

#region ---- Internal Functions
Func _ErrorMsg($message, $time = 0)
	MsgBox(48 + 262144, "Error!", $message, $time)
EndFunc
#endregion Internal Functions