#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Wizard.ico
#AutoIt3Wrapper_Res_Comment=Generate the MessageBox, Dialogs, Color, and Fonts code according to the user choices and copy the generated code to the clipboard or Standard Output (if the command-line parameter /StdOut is provided) for later use.
#AutoIt3Wrapper_Res_Description=Code Wizard
#AutoIt3Wrapper_Res_Fileversion=1.5.4.0
#AutoIt3Wrapper_Res_LegalCopyright=Giuseppe Criaco/Gary Frost
#AutoIt3Wrapper_Res_Field=Email|gcriaco@quipo.it
#AutoIt3Wrapper_Res_Field=Email|custompcs@charter.net
#AutoIt3Wrapper_Res_Field=Release Date|1/15/2006
#AutoIt3Wrapper_Res_Field=Update Date|6/19/2016
#AutoIt3Wrapper_Res_Field=Internal Name|CodeWizard.exe
#AutoIt3Wrapper_Res_Field=Status|Prod
#AutoIt3Wrapper_Add_Constants=n

#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;===================================================================================================================================================
;
; Program Name:     CodeWizard()
; Description:      Generate the MessageBox and Dialog box code according to the
;                   user choices
; Parameter(s):     /StdOut [optional - from command line] - Copy the generated
;					AutoIt code to the Console instead of Clipboard
; Requirement(s):   None
; Return Value(s):  None
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>, Gary Frost <gary.frost@arnold.af.mil>
; Changelog:		6/19/2016, updated by Cyberyeye: 1.5.4.0
;							- Fix Icon Ressource Number for Messagebox Tab & ToolTip Tab
;							- Check/Fix missing includes using AutoIt3Wrapper_Add_Constants=y
;							- Added Opt("MustDeclareVars", 1) to fix undeclared variables
;							- Replaced msgbox() magic number by constant name
;							- Added GUISetIcon var (au3.ico)
;							- Removed unusefull old AutoIt3Wrapper directive
;
;===================================================================================================================================================
;
#Region - Include
#include <AutoItConstants.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <Constants.au3>
#include <EditConstants.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <Inet.au3>
#include <ListViewConstants.au3>
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <TrayConstants.au3>
#include <WindowsConstants.au3>
#EndRegion - Include
Opt("MustDeclareVars", 1)
#Region - Declarations
Global $Button, $sMsgBox, $asMsgText, $sMText, $sIPwdChr, $iWidth, $iHeight, $iLeft, $iTop, $sInputBox, _
		$sIPrompt, $sMFlag, $asFonts, $iOpt, $sOpt, $sSTText, $sSpashText, $sText, $sSTFlag, $sTitle, $sImageExt, _
		$sSpashImage, $sTitle, $iTFlag, $sX, $sY, $sToolTip, $iToolTipIcon, $iToolTipOptions

Dim $G_SZVERSION = "Code Wizard 1.5.4.0"
Dim $sOutType = "ClipBoard"
Dim $TITLE = $G_SZVERSION
Dim $FOREGROUND = "Black", $BACKGROUND = "White", $GUIBACKGROUND = "Slate Gray"
Dim $W_HEIGHT = 610, $W_WIDTH = 753, $FONTWEIGHT = 400, $FONTSELECTED[8]
Dim $GROUP[8], $STR_OLDFONTSIZE = 10, $STR_OLDFONTWEIGHT = 400, $Enabled = 0

Opt("TrayIconHide", 0) ;0=show, 1=hide tray icon

If WinExists($G_SZVERSION) Then Exit ; It's already running
AutoItWinSetTitle($G_SZVERSION)

HotKeySet("{F1}", "_ContextualHelp")

If $CMDLINE[0] = 1 Then
	If $CMDLINE[1] = "/StdOut" Then
		$sOutType = "Console"
	EndIf
EndIf

Global $CodeWizardIniPath
; Check for SCITE_USERHOME Env variable and used that when specified.
; Else use Program directory
If EnvGet("SCITE_USERHOME") <> "" And FileExists(EnvGet("SCITE_USERHOME")) Then
	$CodeWizardIniPath = EnvGet("SCITE_USERHOME") & "\CodeWizard"
ElseIf EnvGet("SCITE_HOME") <> "" And FileExists(EnvGet("SCITE_HOME")) Then
	$CodeWizardIniPath = EnvGet("SCITE_HOME") & "\CodeWizard"
Else
	$CodeWizardIniPath = @ScriptDir
EndIf


If @Compiled Then
	DirCreate($CodeWizardIniPath)
	FileInstall("colors.ini", $CodeWizardIniPath & "\colors.ini")
EndIf

If (Not FileExists($CodeWizardIniPath & "\colors.ini")) Then
	#Region --- CodeWizard generated code Start ---
	;MsgBox features: Title=Yes, Text=Yes, Buttons=OK, Icon=Warning
	MsgBox($MB_ICONWARNING, "File Not Found", "Required file not found (" & $CodeWizardIniPath & "\colors.ini" & ")" & @CRLF & "" & @CRLF & "CodeWizard will now exit!!!")
	#EndRegion --- CodeWizard generated code Start ---
	Exit
EndIf

Global $T_STR = ""
Global $ARRAY = IniReadSection($CodeWizardIniPath & "\colors.ini", "SCHEMES")
If @error Then
	MsgBox($MB_SYSTEMMODAL, "Error occured", ", Error reading : " & $CodeWizardIniPath & "\colors.ini file.")
	Exit
Else
	For $I = 1 To $ARRAY[0][0]
		If (StringLen($T_STR) == 0) Then
			$T_STR = $ARRAY[$I][1]
		Else
			$T_STR = $T_STR & "|" & $ARRAY[$I][1]
		EndIf
	Next
EndIf
#EndRegion - Declarations

#Region - 2016 Fix Icon Ressource Number Declarations
Global $Icon_Warning = "101", $Icon_Question = "102", $Icon_Critical = "103", $Icon_Informational = "104"
#EndRegion - 2016 Fix Icon Ressource Number Declarations

#Region - 2016 GUISetIcon
Global $sWow64 = ""
If @AutoItX64 Then $sWow64 = "\Wow6432Node"
Global $sFileAu3Ico = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE" & $sWow64 & "\AutoIt v3\AutoIt", "InstallDir") & "\icons\au3.ico"
#EndRegion - 2016 GUISetIcon

#Region - GUI objects creation
;==================================================================
; create the Main window
;==================================================================
Global $MAIN_WINDOW = GUICreate($TITLE, $W_WIDTH, $W_HEIGHT)
If Not IsDeclared('Gray') Then Dim $Gray = 0xbebebe
GUISetBkColor($Gray)
If FileExists($sFileAu3Ico) Then GUISetIcon($sFileAu3Ico) ; Added by Cyberyeye
Global $MENUFILE = GUICtrlCreateMenu("&File")
Global $MENUFILECLOSE = GUICtrlCreateMenuItem("E&xit", $MENUFILE)
Global $MENUHELP = GUICtrlCreateMenu("&Help")
Global $MENUHELPContents = GUICtrlCreateMenuItem("C&ontents", $MENUHELP)
Global $MENUHELPABOUT = GUICtrlCreateMenuItem("&About...", $MENUHELP)

;==================================================================
; create the Top child window
;==================================================================
Global $CONTROL_ID_WINDOW = GUICreate("Control ID", $W_WIDTH - 5, 40, 0, 0, $WS_CHILD + $WS_DLGFRAME, -1, $MAIN_WINDOW)
Global $LBL_CFC = GUICtrlCreateLabel("Control ID (Font/Cursor/Control Color):", 10, 10, 180, 15, $SS_RIGHT)
Global $CTLID = GUICtrlCreateInput("", 190, 8, 130, 20)
GUICtrlSetTip($CTLID, 'Enter the Control ID Name')
Global $CTL_INCLUDE_COMMENTS = GUICtrlCreateCheckbox("Include Comment Block", 350, 10, 150, 20)
GUICtrlSetTip($CTL_INCLUDE_COMMENTS, 'Comments/Description from Help file')
Global $CTLTESTINPUT = GUICtrlCreateButton("Enter Example Text", 500, 10, 120, 20)
GUICtrlSetTip($CTLTESTINPUT, 'Text will show in the Label to the left')

;==================================================================
; create the child window for the tab control
;==================================================================
Global $TAB_WINDOW = GUICreate("TABS WINDOW", 492, $W_HEIGHT - 70, 256, 45, $WS_CHILD + $WS_DLGFRAME, -1, $MAIN_WINDOW)
Global $btnTitle = GUICtrlCreateButton("&Title", 10, 510, 100)
GUICtrlSetTip($btnTitle, "Find the Script Title")
Global $btnPreview = GUICtrlCreateButton("&Preview", 120, 510, 100)
GUICtrlSetTip($btnPreview, "Show the MessageBox/Dialog Box")
Global $btnCopy = GUICtrlCreateButton("&Copy 2 SciTE", 230, 510, 100)

If $sOutType = "Console" Then
	GUICtrlSetTip($btnCopy, "Copy the generated AutoIt code to the Console")
Else
	GUICtrlSetTip($btnCopy, "Copy the generated AutoIt code to the Clipboard")
EndIf

Global $btnExit = GUICtrlCreateButton("&Exit", 340, 510, 100)
GUICtrlSetTip($btnExit, "Quit the program")

;==================================================================
; create the tab control
;==================================================================
Global $TAB = GUICtrlCreateTab(15, 5, 465, $W_HEIGHT - 110, $TCS_MULTILINE)

;==================================================================
; MessageBox Tab Item Objects
;==================================================================
Global $tabMsgBox = GUICtrlCreateTabItem("MessageBox")
Dim $Light_Gray = 0xd3d3d3
GUICtrlSetBkColor($TAB, $Light_Gray)
;Title Group
GUICtrlCreateGroup("Title", 20, 55, 205, 65)
Global $txtMTitle = GUICtrlCreateInput("", 30, 85, 185, 20)
GUICtrlSetState(-1, $GUI_FOCUS)
GUICtrlSetTip(-1, "The title of the message box.")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

;Text Object
GUICtrlCreateLabel("Text", 20, 135, 30)
Global $txtMText = GUICtrlCreateEdit("", 20, 150, 420, 70, $ES_AUTOVSCROLL + $WS_VSCROLL + $ES_MULTILINE + $ES_WANTRETURN)
GUICtrlSetTip(-1, "The text of the message box.")
#Region - 2016 Fix Icon on Messagebox Tab
;Icons Group
GUICtrlCreateGroup("Icons", 235, 55, 205, 65)
Global $chkMWarning = GUICtrlCreateCheckbox("", 255, 70, 40, 40, $BS_PUSHLIKE + $BS_ICON)
GUICtrlSetTip(-1, "Warning")
GUICtrlSetImage(-1, "user32.dll", $Icon_Warning)
Global $chkMQuestion = GUICtrlCreateCheckbox("", 295, 70, 40, 40, $BS_PUSHLIKE + $BS_ICON)
GUICtrlSetTip(-1, "Question")
GUICtrlSetImage(-1, "user32.dll", $Icon_Question)
Global $chkMCritical = GUICtrlCreateCheckbox("", 335, 70, 40, 40, $BS_PUSHLIKE + $BS_ICON)
GUICtrlSetTip(-1, "Critical")
GUICtrlSetImage(-1, "user32.dll", $Icon_Critical)
Global $chkMInfo = GUICtrlCreateCheckbox("", 375, 70, 40, 40, $BS_PUSHLIKE + $BS_ICON)
GUICtrlSetTip(-1, "Informational")
GUICtrlSetImage(-1, "user32.dll", $Icon_Informational)
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
#EndRegion - 2016 Fix Icon on Messagebox Tab
;Options Group
GUICtrlCreateGroup("Options", 235, 320, 205, 70)
GUICtrlCreateLabel("Timeout", 245, 345, 40, 20)
Global $txtMTimeout = GUICtrlCreateInput("", 245, 360, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "Optional Timeout in seconds. After the timeout has elapsed the message box will be automatically closed.")
Global $chkMConstants = GUICtrlCreateCheckbox("Use Constants", 340, 362, 85)
GUICtrlSetTip(-1, "Use Constants (Constants.au3) in resulting code.")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

;Buttons
GUICtrlCreateGroup("Buttons", 20, 220, 205, 170)
Global $optMOK = GUICtrlCreateRadio("OK", 30, 240, 100, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
Global $optMYesNo = GUICtrlCreateRadio("Yes, No", 30, 260, 100, 20)
Global $optMOKCancel = GUICtrlCreateRadio("OK, Cancel", 30, 280, 100, 20)
Global $optMYesNoCancel = GUICtrlCreateRadio("Yes, No, Cancel", 30, 300, 100, 20)
Global $optMAbortRetryIgnore = GUICtrlCreateRadio("Abort, Retry, Ignore", 30, 320, 120, 20)
Global $optMRetryCancel = GUICtrlCreateRadio("Retry, Cancel", 30, 340, 100, 20)
Global $optMCancelTryContinue = GUICtrlCreateRadio("Cancel, Try Again, Continue", 30, 360, 150, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

;Modality Group
GUICtrlCreateGroup("Modality", 20, 400, 205, 90)
Global $optApplication = GUICtrlCreateRadio("Application", 30, 420, 100, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
Global $optMSysModal = GUICtrlCreateRadio("System Modal", 30, 440, 100, 20)
Global $optMTaskModal = GUICtrlCreateRadio("Task Modal", 30, 460, 100, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

;Miscellaneous Group
GUICtrlCreateGroup("Miscellaneous", 235, 400, 205, 90)
Global $chkMTopMost = GUICtrlCreateCheckbox("Top-most attribute", 245, 425, 130, 20)
Global $chkMRightJust = GUICtrlCreateCheckbox("Right-justified title/text", 245, 455, 150, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

;Default buttons Group
GUICtrlCreateGroup("Default Button", 235, 220, 205, 90)
Global $optMFirst = GUICtrlCreateRadio("First Button", 245, 240, 130, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
Global $optMSecond = GUICtrlCreateRadio("Second Button", 245, 260, 130, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
Global $optMThird = GUICtrlCreateRadio("Third Button", 245, 280, 130, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

GUICtrlSetState($txtMTitle, $GUI_FOCUS)
GUICtrlCreateTabItem("") ; end tabitem definition

;==================================================================
; InputBox Tab Item Objects
;==================================================================
Global $tabInputBox = GUICtrlCreateTabItem("InputBox")

; Text Objects
GUICtrlCreateLabel("Title", 20, 60, 20)
Global $txtITitle = GUICtrlCreateInput("", 20, 75, 420, 20)
GUICtrlSetState(-1, $GUI_FOCUS)
GUICtrlSetTip(-1, "The title of the input box")
GUICtrlCreateLabel("Prompt", 20, 120, 50)
Global $txtIPrompt = GUICtrlCreateEdit("", 20, 135, 420, 70, $ES_AUTOVSCROLL + $WS_VSCROLL + $ES_MULTILINE + $ES_WANTRETURN)
GUICtrlSetTip(-1, "A message to the user indicating what kind of input is expected")
GUICtrlCreateLabel("Default text", 20, 230, 100)
Global $txtIDefault = GUICtrlCreateInput("", 20, 245, 420, 20)
GUICtrlSetTip(-1, "The value that the input box starts with")

;Options Group
GUICtrlCreateGroup("Options [Optional]", 20, 290, 420, 70)
GUICtrlCreateLabel("Input length", 30, 310, 100)
Global $txtIChrLen = GUICtrlCreateInput("", 30, 325, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "The maximum length of the input box")
GUICtrlCreateLabel("Password char", 140, 310, 100)
Global $txtIPwdChr = GUICtrlCreateInput("", 140, 325, 70, 20)
GUICtrlSetTip(-1, "The character to replace all typed characters with")
GUICtrlSetLimit($txtIPwdChr, 1, 0)
GUICtrlCreateLabel("Timeout", 250, 310, 100)
Global $txtITimeOut = GUICtrlCreateInput("", 250, 325, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "How many seconds to wait before automatically cancelling the InputBox")
Global $chkIMandatory = GUICtrlCreateCheckbox("Mandatory", 360, 325, 70, 20)
GUICtrlSetTip(-1, "Input is Mandatory; i.e. you must enter something")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

;Position Group
GUICtrlCreateGroup("Position [Optional]", 20, 390, 420, 70)
GUICtrlCreateLabel("Width", 30, 410, 100)
Global $txtIWidth = GUICtrlCreateInput("", 30, 425, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "The width of the window. If defined, height must also be defined. Use -1 for default width")
GUICtrlCreateLabel("Height", 140, 410, 100)
Global $txtIHeight = GUICtrlCreateInput("", 140, 425, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "The height of the window. If defined, width must also be defined. Use -1 for default height")
GUICtrlCreateLabel("Left", 250, 410, 100)
Global $txtILeft = GUICtrlCreateInput("", 250, 425, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "The left side of the input box. By default, the box is centered. If defined, top must also be defined")
GUICtrlCreateLabel("Top", 360, 410, 60)
Global $txtITop = GUICtrlCreateInput("", 360, 425, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "The top of the input box. By default, the box is centered. If defined, left must also be defined")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

GUICtrlCreateTabItem("") ; end tabitem definition

;==================================================================
; ToolTip Tab Item Objects
;==================================================================
Global $tabToolTip = GUICtrlCreateTabItem("ToolTip")

Dim $Light_Gray = 0xd3d3d3
GUICtrlSetBkColor($TAB, $Light_Gray)

;Title Group
GUICtrlCreateGroup("Title", 20, 65, 205, 65)
Global $txtTTitle = GUICtrlCreateInput("", 30, 95, 185, 20)
GUICtrlSetState(-1, $GUI_FOCUS)
GUICtrlSetTip(-1, "The title of the ToolTip. Requires IE5+")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

;Text Object
GUICtrlCreateLabel("Text", 20, 165, 30)
Global $txtTText = GUICtrlCreateEdit("", 20, 180, 420, 70, $ES_AUTOVSCROLL + $WS_VSCROLL + $ES_MULTILINE + $ES_WANTRETURN)
GUICtrlSetTip(-1, "The text of the ToolTip. An empty string clears a displaying tooltip.")
#Region - 2016 Fix Icon on ToolTip Tab
;Icons Group
GUICtrlCreateGroup("Icons", 235, 65, 205, 65)
Global $chkTWarning = GUICtrlCreateCheckbox("", 280, 80, 40, 40, $BS_PUSHLIKE + $BS_ICON)
GUICtrlSetTip(-1, "Warning")
GUICtrlSetImage(-1, "user32.dll", $Icon_Warning)
Global $chkTCritical = GUICtrlCreateCheckbox("", 320, 80, 40, 40, $BS_PUSHLIKE + $BS_ICON)
GUICtrlSetTip(-1, "Critical")
GUICtrlSetImage(-1, "user32.dll", $Icon_Critical)
Global $chkTInfo = GUICtrlCreateCheckbox("", 360, 80, 40, 40, $BS_PUSHLIKE + $BS_ICON)
GUICtrlSetTip(-1, "Informational")
GUICtrlSetImage(-1, "user32.dll", $Icon_Informational)
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
#EndRegion - 2016 Fix Icon on ToolTip Tab
;Options Group
GUICtrlCreateGroup("Options", 20, 290, 420, 60)
Global $chkTBalloonTip = GUICtrlCreateCheckbox("Balloon Tip", 60, 320, 150, 20)
GUICtrlSetTip(-1, "Display as Balloon Tip. Requires IE5+")
Global $chkTCenterTip = GUICtrlCreateCheckbox("Center the tip at the x,y coordinates", 220, 320, 200)
GUICtrlSetTip(-1, "Center the tip at the x,y coordinates instead of using them for the upper left corner.")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

;Coordinates Group
GUICtrlCreateGroup("Coordinates [Optional]", 20, 390, 420, 70)
GUICtrlCreateLabel("X", 60, 430, 10)
Global $txtTX = GUICtrlCreateInput("", 75, 425, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "The x position of the tooltip.")
GUICtrlCreateLabel("Y", 295, 430, 10)
Global $txtTY = GUICtrlCreateInput("", 310, 425, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "The y position of the tooltip.")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

GUICtrlSetState($txtTTitle, $GUI_FOCUS)
GUICtrlCreateTabItem("") ; end tabitem definition

;==================================================================
; SplashTextOn Tab Item Objects
;==================================================================
$tabMsgBox = GUICtrlCreateTabItem("SplashText")

; Title Group
GUICtrlCreateGroup("", 20, 50, 420, 60)
Global $chkSTTitle = GUICtrlCreateCheckbox("Title Bar", 30, 50, 60, 20)
GUICtrlSetTip(-1, "With Title Bar/Thin bordered titleless window")
Global $lblSTTitle = GUICtrlCreateLabel("Title", 30, 80, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
Global $txtSTTitle = GUICtrlCreateInput("", 60, 75, 210, 20)
GUICtrlSetTip(-1, "The Title of the splash window")
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetState(-1, $GUI_FOCUS)
Global $chkSTWinMove = GUICtrlCreateCheckbox("Windows can be moved", 290, 75, 140, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

;Text
GUICtrlCreateLabel("Text", 20, 115, 50)
Global $txtSTText = GUICtrlCreateEdit("", 20, 130, 420, 70, $ES_AUTOVSCROLL + $WS_VSCROLL + $ES_MULTILINE + $ES_WANTRETURN)
GUICtrlSetTip(-1, "The Text of the splash window")

;Options Group
GUICtrlCreateGroup("Options", 20, 210, 205, 90)
Global $chkSTOnTop = GUICtrlCreateCheckbox("Always On Top", 30, 230, 150, 20)
GUICtrlSetTip(-1, 'Set the "Always On Top" attribute')
Global $chkSTVertical = GUICtrlCreateCheckbox("Centered vertically text", 30, 250, 150)
GUICtrlSetTip(-1, "Centered vertically text")
Global $chkSTConstants = GUICtrlCreateCheckbox("Use Constants", 30, 270, 85)
GUICtrlSetTip(-1, "Use Constants (Constants.au3) in resulting code.")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

;Text Justification Group
GUICtrlCreateGroup("Text Justification", 235, 210, 205, 90)
Global $optJustCenter = GUICtrlCreateRadio("Center", 245, 230, 150, 20)
GUICtrlSetTip(-1, "Text is center justified")
GUICtrlSetState(-1, $GUI_CHECKED)
Global $optJustLeft = GUICtrlCreateRadio("Left", 245, 250, 150, 20)
GUICtrlSetTip(-1, "Text is left justified")
Global $optJustRight = GUICtrlCreateRadio("Right", 245, 270, 150, 20)
GUICtrlSetTip(-1, "Text is right justified")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

;Fonts Group
GUICtrlCreateGroup("Font [Optional]", 20, 320, 420, 70)
GUICtrlCreateLabel("Font Name", 30, 340, 100)
Global $txtSTFontName = GUICtrlCreateInput("", 30, 355, 70, 20)
GUICtrlSetTip(-1, "Font to use (OS default GUI font is used if the font is "" or is not found)")
GUICtrlCreateLabel("Font size", 140, 340, 100)
Global $txtSTFontSize = GUICtrlCreateInput("", 140, 355, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "Font size (default is 12; standard sizes are 6 8 9 10 11 12 14 16 18 20 22 24 26 28 36 48 72)")
GUICtrlSetLimit($txtIPwdChr, 1, 0)
GUICtrlCreateLabel("Font weight", 250, 340, 100)
Global $txtSTFontWeight = GUICtrlCreateInput("", 250, 355, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "Font weight (0 - 1000, default = 400 = normal). A value > 1000 is treated as zero")
Global $btnSTFonts = GUICtrlCreateButton("Choose", 360, 355, 70, 20)
GUICtrlSetTip(-1, "Show the Fonts Selection dialog box")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

;Position Group
GUICtrlCreateGroup("Position [Optional]", 20, 410, 420, 70)
GUICtrlCreateLabel("Width", 30, 430, 100)
Global $txtSTWidth = GUICtrlCreateInput("", 30, 445, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "Width of window in pixels (default 500)")
GUICtrlCreateLabel("Height", 140, 430, 100)
Global $txtSTHeight = GUICtrlCreateInput("", 140, 445, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "Height of window in pixels (default 400)")
GUICtrlCreateLabel("Left", 250, 430, 100)
Global $txtSTLeft = GUICtrlCreateInput("", 250, 445, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "Position from left (in pixels) of splash window. (default is centered)")
GUICtrlCreateLabel("Top", 360, 430, 60)
Global $txtSTTop = GUICtrlCreateInput("", 360, 445, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "Position from top (in pixels) of splash window. (default is centered)")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

GUICtrlCreateTabItem("") ; end tabitem definition

;==================================================================
; SplashImageOn Tab Item Objects
;==================================================================
$tabMsgBox = GUICtrlCreateTabItem("SplashImage")

; Title Group
GUICtrlCreateGroup("", 20, 70, 420, 60)
Global $chkSITitle = GUICtrlCreateCheckbox("Title Bar", 30, 70, 60, 20)
GUICtrlSetTip(-1, "With Title Bar/Thin bordered titleless window")
Global $lblSITitle = GUICtrlCreateLabel("Title", 30, 100, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
Global $txtSITitle = GUICtrlCreateInput("", 60, 95, 210, 20)
GUICtrlSetTip(-1, "The Title of the splash window")
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetState(-1, $GUI_FOCUS)
Global $chkSIWinMove = GUICtrlCreateCheckbox("Windows can be moved", 290, 100, 140, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

;File
GUICtrlCreateLabel("Image", 20, 195, 50)
Global $txtSIFile = GUICtrlCreateInput("", 60, 190, 300, 20)
GUICtrlSetTip(-1, "The Text of the splash window")
Global $btnSIImage = GUICtrlCreateButton("Open", 370, 190, 70, 20)
GUICtrlSetTip(-1, "Show the Open File dialog box")

;Options Group
GUICtrlCreateGroup("Options", 20, 260, 420, 60)
Global $chkSIOnTop = GUICtrlCreateCheckbox("Always On Top", 60, 290, 150, 20)
GUICtrlSetTip(-1, 'Set the "Always On Top" attribute')
Global $chkSIConstants = GUICtrlCreateCheckbox("Use Constants", 320, 290, 90)
GUICtrlSetTip(-1, "Use Constants (Constants.au3) in resulting code.")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

;Position Group
GUICtrlCreateGroup("Position [Optional]", 20, 390, 420, 70)
GUICtrlCreateLabel("Width", 30, 410, 100)
Global $txtSIWidth = GUICtrlCreateInput("", 30, 425, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "Width of window in pixels (default 500)")
GUICtrlCreateLabel("Height", 140, 410, 100)
Global $txtSIHeight = GUICtrlCreateInput("", 140, 425, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "Height of window in pixels (default 400)")
GUICtrlCreateLabel("Left", 250, 410, 100)
Global $txtSILeft = GUICtrlCreateInput("", 250, 425, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "Position from left (in pixels) of splash window. (default is centered)")
GUICtrlCreateLabel("Top", 360, 410, 60)
Global $txtSITop = GUICtrlCreateInput("", 360, 425, 70, 20, $ES_NUMBER)
GUICtrlSetTip(-1, "Position from top (in pixels) of splash window. (default is centered)")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

GUICtrlCreateTabItem("") ; end tabitem definition

;==================================================================
; create the control colors tab
;==================================================================
Global $TAB_COLOR = GUICtrlCreateTabItem("Colors")

Global $COLORSCHEME = GUICtrlCreateCombo("", 165, 60, 125, -1, $CBS_DROPDOWNLIST) ; create first item
GUICtrlSetData($COLORSCHEME, $T_STR, $ARRAY[1][1]) ; add other items
GUICtrlSetTip($COLORSCHEME, "Select a color scheme")

$GROUP[0] = GUICtrlCreateGroup("Set Control Color", 20, 90, 230, 80)
GUICtrlSetFont($GROUP[0], 9, 600, -1, "Times New Roman")
Global $CTLTEXTCOLOR = GUICtrlCreateButton("Set Text Color", 35, 110, 90, 20)
GUICtrlSetTip($CTLTEXTCOLOR, "Set Control Text Color From List")
Global $CTL_DIALOG_TEXTCOLOR = GUICtrlCreateButton("Fgnd Color Picker", 135, 110, 100, 20)
GUICtrlSetTip($CTL_DIALOG_TEXTCOLOR, "Select Text Color From Color Dialog")
Global $CTLBACKCOLOR = GUICtrlCreateButton("Set Back Color", 35, 140, 90, 20)
GUICtrlSetTip($CTLBACKCOLOR, "Set Control Background Color From List")
Global $CTL_DIALOG_BACKCOLOR = GUICtrlCreateButton("Bkgnd Color Picker", 135, 140, 100, 20)
GUICtrlSetTip($CTL_DIALOG_BACKCOLOR, "Select Background Color From Color Dialog")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
GUICtrlCreateLabel("Control Text Code:", 20, 222, 125, 15, $SS_RIGHT)
Global $CTLTEXTCODE = GUICtrlCreateEdit("0x000000", 150, 220, 55, 20, $ES_READONLY)
GUICtrlCreateLabel("Control Background Code:", 20, 242, 125, 15, $SS_RIGHT)
Global $CTLBKGRNDCODE = GUICtrlCreateEdit("0xFFFFFF", 150, 240, 55, 20, $ES_READONLY)
$GROUP[1] = GUICtrlCreateGroup("Create Control Code", 40, 290, 175, 90)
GUICtrlSetFont($GROUP[1], 9, 600, -1, "Times New Roman")
Global $CREATE_GUICTRLSETCOLOR = GUICtrlCreateButton("Create GUICtrlSetColor", 65, 315, 130, 20)
GUICtrlSetTip($CREATE_GUICTRLSETCOLOR, 'Sets the text color of a control.' & @CRLF & @CRLF & 'GUICtrlSetColor ( controlID, textcolor)' & @CRLF & @CRLF & 'Parameters' & @CRLF & 'controlID The control identifier (controlID) as returned by a GUICtrlCreate... function.' & @CRLF & 'textcolor The RGB color to use.')
Global $CREATE_GUICTRLSETBKCOLOR = GUICtrlCreateButton("Create GUICtrlSetBkColor", 65, 345, 130, 20)
GUICtrlSetTip($CREATE_GUICTRLSETBKCOLOR, 'Sets the background color of a control.' & @CRLF & @CRLF & 'GUICtrlSetBkColor ( controlID, backgroundcolor )' & @CRLF & @CRLF & 'Parameters' & @CRLF & 'controlID The control identifier (controlID) as returned by a GUICtrlCreate... function.' & @CRLF & 'backgroundcolor The RGB color to use.')
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
$FONTSELECTED[2] = "Times New Roman"
$FONTSELECTED[3] = 10
$GROUP[6] = GUICtrlCreateGroup("Set GUI Color", 260, 90, 170, 80)
GUICtrlSetFont($GROUP[6], 9, 600, -1, "Times New Roman")
Global $GUIBACKCOLOR = GUICtrlCreateButton("Set Back Color", 300, 110, 90, 20)
GUICtrlSetTip($GUIBACKCOLOR, "Set GUI Background Color From List")
Global $GUI_DIALOG_BACKCOLOR = GUICtrlCreateButton("Color Picker", 300, 140, 90, 20)
GUICtrlSetTip($GUI_DIALOG_BACKCOLOR, "Select GUI Color From Color Dialog")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
GUICtrlCreateLabel("GUI Background Code:", 250, 222, 125, 15, $SS_RIGHT)
Global $GUIBKGRNDCODE = GUICtrlCreateEdit("0x708090", 380, 220, 55, 20, $ES_READONLY)
$GROUP[7] = GUICtrlCreateGroup("Create GUI Code", 260, 290, 175, 60)
GUICtrlSetFont($GROUP[7], 9, 600, -1, "Times New Roman")
Global $CREATE_GUISETBKCOLOR = GUICtrlCreateButton("Create GUISetBkColor", 285, 315, 130, 20)
GUICtrlSetTip($CREATE_GUISETBKCOLOR, 'Sets the background color of the GUI window.' & @CRLF & @CRLF & 'GUISetBkColor ( background [, winhandle] )' & @CRLF & @CRLF & 'Parameters' & @CRLF & 'background Background color of the dialog box.' & @CRLF & 'winhandle [optional] Windows handle as returned by GUICreate (default is the previously used window).')
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

GUICtrlCreateTabItem("") ; end tabitem definition

;==================================================================
; create the control fonts tab
;==================================================================
Global $TAB_FONTS_CURSORS = GUICtrlCreateTabItem("Control Fonts/Cursors")
$GROUP[2] = GUICtrlCreateGroup("Set Font", 40, 60, 175, 130)
GUICtrlSetFont($GROUP[2], 9, 600, -1, "Times New Roman")
Global $CTRLSELECTFONTS = GUICtrlCreateButton("Choose", 90, 80, 70, 20)
GUICtrlSetTip($CTRLSELECTFONTS, "Show the Fonts Selection dialog box")
GUICtrlCreateLabel("Font Name", 55, 105, 100)
Global $CTRLFONTNAME = GUICtrlCreateInput("Times New Roman", 55, 120, 140, 20, $ES_READONLY)
GUICtrlSetTip($CTRLFONTNAME, "Font to use")
GUICtrlCreateLabel("Font size", 55, 145, 100)
Global $CTRLFONTSIZE = GUICtrlCreateInput("10", 55, 160, 70, 20, $ES_NUMBER)
GUICtrlSetTip($CTRLFONTSIZE, "Font size (default is 10; standard sizes are 6 8 9 10 11 12 14 16 18 20 22 24 26 28 36 48 72)")
GUICtrlCreateLabel("Font weight", 130, 145, 100)
Global $CTRLFONTWEIGHT = GUICtrlCreateInput("400", 130, 160, 70, 20, $ES_NUMBER)
GUICtrlSetTip($CTRLFONTWEIGHT, "Font weight (0 - 1000, default = 400 = normal). A value > 1000 is treated as zero")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
$GROUP[3] = GUICtrlCreateGroup("Create Fonts Code", 40, 320, 175, 60)
GUICtrlSetFont($GROUP[3], 9, 600, -1, "Times New Roman")
Global $CREATE_GUICTRLSETFONT = GUICtrlCreateButton("Create GUICtrlSetFont", 65, 345, 130, 20)
GUICtrlSetTip($CREATE_GUICTRLSETFONT, 'Sets the font for a control.' & @CRLF & @CRLF & 'GUICtrlSetFont (controlID, size [, weight [, attribute [, fontname]]] )' & @CRLF & @CRLF & 'Parameters' & @CRLF & 'controlID The control identifier (controlID) as returned by a GUICtrlCreate... function.' & @CRLF & 'size Fontsize (default is 9).' & @CRLF & 'weight [optional] Font weight (default 400 = normal).' & @CRLF & 'attribute [optional] To define italic:2 underlined:4 strike:8 char format (add together the values of all the styles required, 2+4 = italic and underlined).' & @CRLF & 'fontname [optional] The name of the font to use.')
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

$GROUP[4] = GUICtrlCreateGroup("Set Cursor", 260, 60, 175, 250)
GUICtrlSetFont($GROUP[4], 9, 600, -1, "Times New Roman")
Global $CTLSETCURSOR = GUICtrlCreateCombo("APPSTARTING", 295, 80, 130, 220, $CBS_SORT + $CBS_SIMPLE) ; create first item
GUICtrlSetData($CTLSETCURSOR, "ARROW|CROSS|HELP|IBEAM|ICON|NO|SIZE|SIZEALL|SIZENESW|SIZENS|SIZENWSE|SIZEWE|UPARROW|WAIT", "ARROW") ; add other items
GUICtrlSetTip($CTLSETCURSOR, "Show Control cursor, hold cursor for sample label")
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
$GROUP[5] = GUICtrlCreateGroup("Create Cursor Code", 260, 320, 175, 60)
GUICtrlSetFont($GROUP[5], 9, 600, -1, "Times New Roman")
Global $CREATE_GUICTRLSETCURSOR = GUICtrlCreateButton("Create GUICtrlSetCursor", 280, 345, 130, 20)
GUICtrlSetTip($CREATE_GUICTRLSETCURSOR, 'Sets mouse cursor icon for a particular control.' & @CRLF & @CRLF & 'GUICtrlSetCursor ( controlID, cursorID )' & @CRLF & @CRLF & 'Parameters' & @CRLF & 'controlID The control identifier (controlID) as returned by a GUICtrlCreate... function.' & @CRLF & 'cursorID cursor ID as used by Windows SetCursor API (use -1 for the default cursor for the control)')
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

GUICtrlCreateTabItem("") ; end tabitem definition

;==================================================================
; create the left side child window
;==================================================================
Global $TEST_WINDOW = GUICreate("Color Picker", 251, $W_HEIGHT - 70, 0, 45, $WS_CHILD + $WS_DLGFRAME, -1, $MAIN_WINDOW)
Global $TEST_LABEL = GUICtrlCreateLabel($FOREGROUND & " on " & $BACKGROUND, 1, 10, 247, 100, $SS_SUNKEN + $SS_CENTER)
If Not IsDeclared('Black') Then Dim $BLACK = 0x000000
GUICtrlSetColor($TEST_LABEL, $BLACK)
If Not IsDeclared('White') Then Dim $WHITE = 0xFFFFFF
GUICtrlSetBkColor($TEST_LABEL, $WHITE)
GUICtrlSetFont($TEST_LABEL, 9, 400, -1, "Times New Roman")
Global $LV_FILELIST = GUICtrlCreateListView("Name|Hex Value", 17, 120, 215, $W_HEIGHT - 202, BitOR($LVS_SINGLESEL, $LVS_SHOWSELALWAYS, $LVS_NOSORTHEADER), BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_HEADERDRAGDROP, $LVS_EX_REGIONAL))
_BuildList($LV_FILELIST, $ARRAY[1][1])
If Not IsDeclared('Slate_Gray') Then Dim $SLATE_GRAY = 0x708090
GUISetBkColor($SLATE_GRAY)
GUISetState(@SW_SHOW, $MAIN_WINDOW)
GUISetState(@SW_SHOW, $CONTROL_ID_WINDOW)
GUISetState(@SW_SHOW, $TAB_WINDOW)
GUISetState(@SW_SHOW, $TEST_WINDOW)
_EnableDisable(0)
#EndRegion - GUI objects creation

#Region GUI management
$Button = $optMOK

;==================================================================
; Wait for a button to be pressed
;==================================================================
Do
Global 	$MSG = GUIGetMsg()
	If ($STR_OLDFONTSIZE <> GUICtrlRead($CTRLFONTSIZE) Or _
			$STR_OLDFONTWEIGHT <> GUICtrlRead($CTRLFONTWEIGHT)) Then
		$STR_OLDFONTSIZE = GUICtrlRead($CTRLFONTSIZE)
		$STR_OLDFONTWEIGHT = GUICtrlRead($CTRLFONTWEIGHT)
		GUICtrlSetFont($TEST_LABEL, GUICtrlRead($CTRLFONTSIZE), _
				GUICtrlRead($CTRLFONTWEIGHT), $FONTSELECTED[1], GUICtrlRead($CTRLFONTNAME))
	EndIf

	Select
		Case $MSG = $CTLTESTINPUT
			Global $STR_TESTINPUT = InputBox("Sample", "Enter Sample Text:", "")
			If (StringLen($STR_TESTINPUT) == 0) Then
				$STR_TESTINPUT = $FOREGROUND & " on " & $BACKGROUND
			EndIf
			GUICtrlSetData($TEST_LABEL, $STR_TESTINPUT)

		Case $MSG = $COLORSCHEME ; color scheme selected
			_BuildList($LV_FILELIST, ControlGetText($TAB_WINDOW, "", $COLORSCHEME))

		Case $MSG = $CTLTEXTCOLOR ; change control textcolor
			If (_GUICtrlListView_GetSelectedCount($LV_FILELIST)) Then
				_SetTestControl($TEST_WINDOW, $LV_FILELIST, $TEST_LABEL, $CTLTEXTCODE, $FOREGROUND, $BACKGROUND, 1)
			EndIf

		Case $MSG = $CTL_DIALOG_TEXTCOLOR
			Global $Adv_Colour = _ChooseColor(2)
			If Not @error Then
				$FOREGROUND = $Adv_Colour
				_SetTestControl($TEST_WINDOW, $LV_FILELIST, $TEST_LABEL, $CTLTEXTCODE, $FOREGROUND, $BACKGROUND, 1, 1)
			EndIf

		Case $MSG = $CTLBACKCOLOR ; change control backcolor
			If (_GUICtrlListView_GetSelectedCount($LV_FILELIST)) Then
				_SetTestControl($TEST_WINDOW, $LV_FILELIST, $TEST_LABEL, $CTLBKGRNDCODE, $FOREGROUND, $BACKGROUND)
			EndIf

		Case $MSG = $CTL_DIALOG_BACKCOLOR
			$Adv_Colour = _ChooseColor(2)
			If Not @error Then
				$BACKGROUND = $Adv_Colour
				_SetTestControl($TEST_WINDOW, $LV_FILELIST, $TEST_LABEL, $CTLBKGRNDCODE, $FOREGROUND, $BACKGROUND, 0, 1)
			EndIf

		Case $MSG = $CREATE_GUICTRLSETCOLOR ; create the function call
			Global $SCONTROLID = StringReplace(GUICtrlRead($CTLID), " ", "_")
			_SendCode($sOutType, _
					_BuildControl($SCONTROLID, _
					_CreateHeader("GUICtrlSetColor", GUICtrlRead($CTL_INCLUDE_COMMENTS), $FOREGROUND, _
					GUICtrlRead($CTLTEXTCODE)), "", $FOREGROUND, ")"))

		Case $MSG = $CREATE_GUICTRLSETBKCOLOR ; create the function call
			$SCONTROLID = StringReplace(GUICtrlRead($CTLID), " ", "_")
			_SendCode($sOutType, _
					_BuildControl($SCONTROLID, _
					_CreateHeader("GUICtrlSetBkColor", GUICtrlRead($CTL_INCLUDE_COMMENTS), $BACKGROUND, _
					GUICtrlRead($CTLBKGRNDCODE)), "", $BACKGROUND, ")"))

		Case $MSG = $GUIBACKCOLOR ; change gui backcolor
			If (_GUICtrlListView_GetSelectedCount($LV_FILELIST)) Then
				$GUIBACKGROUND = _GUICtrlListView_GetItemText($LV_FILELIST, -1, 0)
				GUISetBkColor(_GUICtrlListView_GetItemText($LV_FILELIST, -1, 1))
				GUICtrlSetData($GUIBKGRNDCODE, _GUICtrlListView_GetItemText($LV_FILELIST, -1, 1))
			EndIf

		Case $MSG = $GUI_DIALOG_BACKCOLOR
			$Adv_Colour = _ChooseColor(2)
			If Not @error Then
				$GUIBACKGROUND = $Adv_Colour
				GUISetBkColor($GUIBACKGROUND)
				GUICtrlSetData($GUIBKGRNDCODE, $GUIBACKGROUND)
			EndIf

		Case $MSG = $CREATE_GUISETBKCOLOR ; create the function call
			If (StringMid(String($GUIBACKGROUND), 1, 2) <> '0x') Then
				_SendCode($sOutType, _
						_CreateHeader("GUISetBkColor", GUICtrlRead($CTL_INCLUDE_COMMENTS), $GUIBACKGROUND, _
						GUICtrlRead($GUIBKGRNDCODE)) & "$" & StringReplace($GUIBACKGROUND, " ", "_") & _CreateFooter(")"))
			Else
				_SendCode($sOutType, _
						_CreateHeader("GUISetBkColor", GUICtrlRead($CTL_INCLUDE_COMMENTS), $GUIBACKGROUND, _
						GUICtrlRead($GUIBKGRNDCODE)) & StringReplace($GUIBACKGROUND, " ", "_") & _CreateFooter(")"))
			EndIf

		Case $MSG = $CTRLSELECTFONTS
			Local $Font = _ChooseFont($FONTSELECTED[2], $FONTSELECTED[3])
			If (Not @error) Then
				$FONTSELECTED[0] = $Font[0]
				$FONTSELECTED[1] = $Font[1]
				$FONTSELECTED[2] = $Font[2]
				$FONTSELECTED[3] = $Font[3]
				$FONTSELECTED[4] = $Font[4]
				GUICtrlSetData($CTRLFONTNAME, $FONTSELECTED[2])
				GUICtrlSetData($CTRLFONTSIZE, $FONTSELECTED[3])
				GUICtrlSetData($CTRLFONTWEIGHT, $FONTSELECTED[4])
				GUICtrlSetFont($TEST_LABEL, GUICtrlRead($CTRLFONTSIZE), _
						GUICtrlRead($CTRLFONTWEIGHT), $FONTSELECTED[1], GUICtrlRead($CTRLFONTNAME))
			EndIf

		Case $MSG = $CREATE_GUICTRLSETFONT ; create the function call
			$SCONTROLID = StringReplace(GUICtrlRead($CTLID), " ", "_")
			_SendCode($sOutType, _
					_BuildControl($SCONTROLID, _
					_CreateHeader("GUICtrlSetFont", GUICtrlRead($CTL_INCLUDE_COMMENTS)), _
					GUICtrlRead($CTRLFONTSIZE) & ',' & GUICtrlRead($CTRLFONTWEIGHT) & ',' & _
					$FONTSELECTED[1] & ',"' & GUICtrlRead($CTRLFONTNAME), "", '")'))

		Case $MSG = $CTLSETCURSOR ; change control cursor
			GUICtrlSetCursor($TEST_LABEL, _SetCursorValue(GUICtrlRead($CTLSETCURSOR)))

		Case $MSG = $CREATE_GUICTRLSETCURSOR ; create the function call
			$SCONTROLID = StringReplace(GUICtrlRead($CTLID), " ", "_")
			_SendCode($sOutType, _
					_BuildControl($SCONTROLID, _
					_CreateHeader("GUICtrlSetCursor", GUICtrlRead($CTL_INCLUDE_COMMENTS), "Cursor_" & _
					GUICtrlRead($CTLSETCURSOR), _SetCursorValue(GUICtrlRead($CTLSETCURSOR))), "", "Cursor_" & _
					GUICtrlRead($CTLSETCURSOR), ")"))

		Case $MSG = $MENUHELPContents
			_ContentsHelp()

		Case $MSG = $MENUHELPABOUT
			GUISetState(@SW_HIDE, $MAIN_WINDOW)
			_About($TITLE, $MAIN_WINDOW)
			GUISetState(@SW_SHOW, $MAIN_WINDOW)

		Case $MSG = $btnExit Or $MSG = $MENUFILECLOSE
			ExitLoop

		Case $MSG = $btnTitle
			$sTitle = _GetScriptTitle()
			GUICtrlSetData($txtMTitle, $sTitle)
			GUICtrlSetData($txtITitle, $sTitle)
			GUICtrlSetData($txtSTTitle, $sTitle)
			GUICtrlSetData($txtSITitle, $sTitle)
			GUICtrlSetData($txtTTitle, $sTitle)

		Case Else
			Select
				Case GUICtrlRead($TAB) = 0 ;MessageBox Wizard
					If ($Enabled) Then
						$Enabled = 0
						_EnableDisable($Enabled)
					EndIf
					_MsgBoxMgt($MSG)

				Case GUICtrlRead($TAB) = 1 ;InputBox Wizard
					If ($Enabled) Then
						$Enabled = 0
						_EnableDisable($Enabled)
					EndIf
					_InputBoxMgt($MSG)

				Case GUICtrlRead($TAB) = 2 ;ToolTip Wizard
					If ($Enabled) Then
						$Enabled = 0
						_EnableDisable($Enabled)
					EndIf
					_ToolTipMgt($MSG)

				Case GUICtrlRead($TAB) = 3 ;SplashText Wizard
					If ($Enabled) Then
						$Enabled = 0
						_EnableDisable($Enabled)
					EndIf
					_SplashTextMgt($MSG)

				Case GUICtrlRead($TAB) = 4 ;SplashImage Wizard
					If ($Enabled) Then
						$Enabled = 0
						_EnableDisable($Enabled)
					EndIf
					_SplashImageMgt($MSG)

				Case Else
					If (Not $Enabled) Then
						$Enabled = 1
						_EnableDisable($Enabled)
					EndIf

			EndSelect
	EndSelect
Until $MSG = $GUI_EVENT_CLOSE

GUIDelete($TEST_WINDOW)
GUIDelete($TAB_WINDOW)
GUIDelete($CONTROL_ID_WINDOW)
GUIDelete($MAIN_WINDOW)
#EndRegion GUI management

#Region Functions

;===============================================================================
; Function Name:    _SetTestControl()
; Description:      Sets the Foreground/Background color and the data
;
; Parameter(s):     $TEST_WINDOW			- gui window to test settings on
;                   $LV_FILELIST       - listview control
;                   $TEST_LABEL        - label control
;                   $CTL               - Forground or Background Hex control
;                   $FOREGROUND        - string containing the foreground color
;                   $BACKGROUND        - string containing the background color
;                   [$SET_FG]          - determines if setting foreground or background
; Requirement(s):   _GUICtrlLVGetItemText
; Return Value(s):  None
;
; Author(s):        Gary Frost <gary.frost@arnold.af.mil>
;===============================================================================

Func _SetTestControl($TEST_WINDOW, $LV_FILELIST, $TEST_LABEL, $CTL, ByRef $FOREGROUND, ByRef $BACKGROUND, $SET_FG = 0, $COLORPICKER = 0)
	Local $HEXCODE
	If ($SET_FG And Not $COLORPICKER) Then
		$HEXCODE = _GUICtrlListView_GetItemText($LV_FILELIST, -1, 1)
		$FOREGROUND = _GUICtrlListView_GetItemText($LV_FILELIST, -1, 0)
		GUICtrlSetColor($TEST_LABEL, $HEXCODE)
	ElseIf (Not $COLORPICKER) Then
		$HEXCODE = _GUICtrlListView_GetItemText($LV_FILELIST, -1, 1)
		$BACKGROUND = _GUICtrlListView_GetItemText($LV_FILELIST, -1, 0)
		GUICtrlSetBkColor($TEST_LABEL, $HEXCODE)
	ElseIf ($SET_FG And $COLORPICKER) Then
		$HEXCODE = $FOREGROUND
		GUICtrlSetColor($TEST_LABEL, $HEXCODE)
	ElseIf ($COLORPICKER) Then
		$HEXCODE = $BACKGROUND
		GUICtrlSetBkColor($TEST_LABEL, $HEXCODE)
	EndIf
	GUICtrlSetData($CTL, $HEXCODE)
	GUICtrlSetData($TEST_LABEL, $FOREGROUND & " on " & $BACKGROUND)
EndFunc   ;==>_SetTestControl

;===============================================================================
; Function Name:    _CreateHeader()
; Description:      Builds the template header with the control name
;
; Parameter(s):     $SCONTROL		- gui control set function name
;
; Requirement(s):   None
; Return Value(s):  string for the template
;
; Author(s):        Gary Frost <gary.frost@arnold.af.mil>
;===============================================================================

Func _CreateHeader($SCONTROL, $INCLUDE_COMMENTS, $S_CTLVARNAME = "", $S_CTLVALUE = "")
	Local $TEMPLATE
	If ($INCLUDE_COMMENTS == $GUI_CHECKED) Then
		Select
			Case $SCONTROL = "GUISetBkColor"
				$TEMPLATE = @CRLF & "#comments-start" & @CRLF & "GUISetBkColor ( background [, winhandle] )" & @CRLF & @CRLF & _
						"Sets the background color of the GUI window." & @CRLF & _
						"Parameters:" & @CRLF & _
						"   background Background color of the dialog box." & @CRLF & _
						"   winhandle [optional] Windows handle as returned by GUICreate (default is the previously used window)." & @CRLF & _
						"#comments-end" & @CRLF
			Case $SCONTROL = "GUICtrlSetColor"
				$TEMPLATE = @CRLF & "#comments-start" & @CRLF & "GUICtrlSetColor ( controlID, textcolor)" & @CRLF & @CRLF & _
						"Sets the text color of a control." & @CRLF & _
						"Parameters:" & @CRLF & _
						"   controlID The control identifier (controlID) as returned by a GUICtrlCreate... function." & @CRLF & _
						"   textcolor The RGB color to use." & @CRLF & _
						"#comments-end" & @CRLF
			Case $SCONTROL = "GUICtrlSetBkColor"
				$TEMPLATE = @CRLF & "#comments-start" & @CRLF & "GUICtrlSetBkColor ( controlID, backgroundcolor )" & @CRLF & @CRLF & _
						"Sets the background color of a control." & @CRLF & _
						"Parameters:" & @CRLF & _
						"   controlID The control identifier (controlID) as returned by a GUICtrlCreate... function." & @CRLF & _
						"   backgroundcolor The RGB color to use." & @CRLF & _
						"#comments-end" & @CRLF
			Case $SCONTROL = "GUICtrlSetCursor"
				$TEMPLATE = @CRLF & "#comments-start" & @CRLF & "GUICtrlSetCursor ( controlID, cursorID )" & @CRLF & @CRLF & _
						"Sets mouse cursor icon for a particular control." & @CRLF & _
						"Parameters:" & @CRLF & _
						"   controlID The control identifier (controlID) as returned by a GUICtrlCreate... function." & @CRLF & _
						"   cursorID cursor ID as used by Windows SetCursor API (use -1 for the default cursor for the control)" & @CRLF & _
						"#comments-end" & @CRLF
			Case $SCONTROL = "GUICtrlSetFont"
				$TEMPLATE = @CRLF & "#comments-start" & @CRLF & "GUICtrlSetFont (controlID, size [, weight [, attribute [, fontname]]] )" & @CRLF & @CRLF & _
						"Sets the font for a control." & @CRLF & _
						"Parameters:" & @CRLF & _
						"   controlID The control identifier (controlID) as returned by a GUICtrlCreate... function." & @CRLF & _
						"   size Fontsize (default is 9)." & @CRLF & _
						"   weight [optional] Font weight (default 400 = normal)." & @CRLF & _
						"   attribute [optional] To define italic:2 underlined:4 strike:8 char format" & @CRLF & _
						"              (add together the values of all the styles required, 2+4 = italic and underlined)." & @CRLF & _
						"   fontname [optional] The name of the font to use." & @CRLF & _
						"#comments-end" & @CRLF
		EndSelect
	EndIf
	If ($S_CTLVARNAME And StringMid(String($S_CTLVARNAME), 1, 2) <> '0x') Then
		Return @CRLF & "#Region --- CodeWizard generated code Start ---" & $TEMPLATE & @CRLF & _
				"If Not IsDeclared('" & StringReplace($S_CTLVARNAME, " ", "_") & _
				"') Then Local $" & StringReplace($S_CTLVARNAME, " ", "_") & " = " & $S_CTLVALUE & @CRLF & $SCONTROL & "("
	Else
		Return @CRLF & "#Region --- CodeWizard generated code Start ---" & $TEMPLATE & @CRLF & $SCONTROL & "("
	EndIf
EndFunc   ;==>_CreateHeader

;===============================================================================
; Function Name:    _BuildControl()
; Description:      Builds the template
; Parameter(s):     $SCONTROLID		- control
;                   $SHEADER        - string created by _CreateHeader
;                   $S_CTLINFO      - string representing the change to the control
;                   $S_CTLEND       - string for the end of the function
; Requirement(s):   _CreateFooter
; Return Value(s):  template string
; Author(s):        Gary Frost <gary.frost@arnold.af.mil>
;===============================================================================

Func _BuildControl(ByRef $SCONTROLID, $SHEADER, $S_CTLINFO, $S_CTLVARNAME, $S_CTLEND)
	Local $S_TEMPLATE
	; Build the controlID
	If ($SCONTROLID == "") Then
		$S_TEMPLATE = $SHEADER & '"controlID",' & $S_CTLINFO
	Else
		If (StringInStr(StringMid($SCONTROLID, 1, 1), "$") == 0) Then
			$SCONTROLID = "$" & $SCONTROLID
		EndIf
		$S_TEMPLATE = $SHEADER & $SCONTROLID & "," & $S_CTLINFO
	EndIf
	; Build the color
	If ($S_CTLVARNAME And StringMid(String($S_CTLVARNAME), 1, 2) <> '0x') Then
		$S_TEMPLATE = $S_TEMPLATE & "$" & StringReplace($S_CTLVARNAME, " ", "_") & _CreateFooter($S_CTLEND)
	ElseIf (StringMid(String($S_CTLVARNAME), 1, 2) == '0x') Then
		$S_TEMPLATE = $S_TEMPLATE & $S_CTLVARNAME & _CreateFooter($S_CTLEND)
	Else
		$S_TEMPLATE = $S_TEMPLATE & _CreateFooter($S_CTLEND)
	EndIf
	Return $S_TEMPLATE
EndFunc   ;==>_BuildControl

;===============================================================================
; Function Name:    _CreateFooter()
; Description:      Builds the template Footer
; Parameter(s):     $S_END    		- string for the end of the function
; Requirement(s):   None
; Return Value(s):  string for the template
; Author(s):        Gary Frost <gary.frost@arnold.af.mil>
;===============================================================================
Func _CreateFooter($S_END)
	Return $S_END & @CRLF & "#EndRegion --- CodeWizard generated code End ---" & @CRLF
EndFunc   ;==>_CreateFooter

;===============================================================================
; Function Name:    _BuildList()
; Description:      Builds the the rows in the Listview
; Parameter(s):     $lv				- ListView control
;                   $SCHEME		- Color scheme
; Requirement(s):   _GUICtrlLVClear
; Return Value(s):  None
; Author(s):        Gary Frost <gary.frost@arnold.af.mil>
;===============================================================================

;~ Func _BuildList($LV,$SCHEME)
Func _BuildList($LV, $SCHEME)
	Local $LVM_SETCOLUMNWIDTH = 0x101E
	Local $X, $COLORS
	_GUICtrlListView_DeleteAllItems($LV)
	$COLORS = IniReadSection($CodeWizardIniPath & "\colors.ini", $SCHEME)
	If Not @error Then
		Local $ARRAY
		For $I = 1 To $COLORS[0][0]
			$ARRAY = StringSplit($COLORS[$I][1], ",")
			GUICtrlCreateListViewItem($ARRAY[1] & "|" & $ARRAY[2], $LV)
		Next
	EndIf
	GUICtrlSendMsg($LV, $LVM_SETCOLUMNWIDTH, 0, 120) ;
	GUICtrlSendMsg($LV, $LVM_SETCOLUMNWIDTH, 1, 75) ;
EndFunc   ;==>_BuildList

;===============================================================================
; Function Name:    _SetCursorValue()
; Description:      Get the value of the cursor
; Parameter(s):     $SCURSOR  	  - Cursor name
; Requirement(s):   None
; Return Value(s):  Cursor value
; Author(s):        Gary Frost <gary.frost@arnold.af.mil>
;===============================================================================

Func _SetCursorValue($SCURSOR)
	Local $X, $ARRAY = StringSplit("APPSTARTING,ARROW,CROSS,HELP,IBEAM,ICON,NO,SIZE,SIZEALL,SIZENESW," & _
			"SIZENS,SIZENWSE,SIZEWE,UPARROW,WAIT,ARROW", ",")
	For $X = 1 To $ARRAY[0]
		If ($SCURSOR == $ARRAY[$X]) Then Return $X
	Next
EndFunc   ;==>_SetCursorValue

;===============================================================================
; Function Name:    _SendCode()
; Description:      Sends string to Console or Clipboard
; Parameter(s):		$SOUTTYPE		- where to send
;					$S_TEMPLATE		- string to send
; Requirement(s):   None
; Return Value(s):  None
; Author(s):        Gary Frost <gary.frost@arnold.af.mil>
;===============================================================================

Func _SendCode($sOutType, $S_TEMPLATE)
	If $sOutType = "Console" Then
		ConsoleWrite(StringReplace($S_TEMPLATE, @CRLF, @LF))
		Exit
	Else
		ClipPut($S_TEMPLATE)
	EndIf
EndFunc   ;==>_SendCode

;===============================================================================
; Function Name:    _About()
; Description:      Self describing
; Parameter(s):		$TITLE       - Script Title
;					$MAIN_WINDOW - control ID
; Requirement(s):   None
; Return Value(s):  None
; Author(s):        Gary Frost <custompcs@charter.net>
;===============================================================================

Func _About($TITLE, $MAIN_WINDOW)
	Local $CLOSE, $LABEL, $LABEL2, $MSG, $ABOUT_WINDOW
	Local $ABOUT_TEXT = "CodeWizard" & @CRLF & _
			"Purpose / Logic:" & @CRLF & _
			"   Help in Creating MessageBox, Dialogs, Colors, Fonts, Cursors for GUI" & @CRLF & @CRLF & _
			"Modifications:" & @CRLF & _
			"      03/14/05 - Started program" & @CRLF & _
			"      Last Modified date: 12/19/05" & @CRLF & @CRLF & _
			"Devolopment Team:"
	Local $ABOUT_AUTHOR = "Gary Frost/Giuseppe Criaco"
	Local $MAILTO = "Gary.Frost@arnold.af.mil;CustomPCs@charter.com;gcriaco@quipo.it"
	$ABOUT_WINDOW = GUICreate($TITLE, 500, 250, -1, -1, -1, -1, $MAIN_WINDOW)
	#Region --- CodeWizard generated code Start ---
	If Not IsDeclared('Cadet_Blue_3') Then Dim $Cadet_Blue_3 = 0x7AC5CD
	GUISetBkColor($Cadet_Blue_3)
	#EndRegion --- CodeWizard generated code Start ---
	$LABEL = GUICtrlCreateLabel($ABOUT_TEXT, 10, 10, 450, 125)
	$LABEL2 = _GuiCtrlCreateHyperlink($ABOUT_AUTHOR, 27, 130, 443, 20, 0x0000ff, 'E-Mail ' & $MAILTO & " (comments/questions)")
	$CLOSE = GUICtrlCreateButton("Close", 200, 190, 85, 20)
	GUISetState()
	Do
		$MSG = GUIGetMsg()
		Select
			Case $MSG = $CLOSE
				ExitLoop
			Case $MSG = $LABEL2
				_INetMail($MAILTO, "Regarding " & $TITLE, "")
		EndSelect
	Until $MSG = $GUI_EVENT_CLOSE
	GUIDelete($ABOUT_WINDOW)
EndFunc   ;==>_About

;===============================================================================
;
; Function Name:    _GuiCtrlCreateHyperlink()
; Description:      Creates a label that acts as a hyperlink
;
; Parameter(s):		$s_Text       - Label text
;							$i_Left		  - Label left coord
;							[$i_Top]      - Label top coord
;							[$i_Width]	  - Label width
;							[$i_Height]	  - Label height
;							[$i_Color]	  - Text Color
;							[$s_ToolTip]  - Hyperlink ToolTip
;							[$i_Style]	  - Label style
;							[$i_ExStyle]  - Label extended style
;
; Requirement(s):   None
; Return Value(s):  Control ID
;
; Author(s):        Saunders <krawlie@hotmail.com>
;
;===============================================================================

Func _GuiCtrlCreateHyperlink($S_TEXT, $I_LEFT, $I_TOP, _
		$I_WIDTH = -1, $I_HEIGHT = -1, $I_COLOR = 0x0000ff, $S_TOOLTIP = '', $I_STYLE = -1, $I_EXSTYLE = -1)
	Local $I_CTRLID
	$I_CTRLID = GUICtrlCreateLabel($S_TEXT, $I_LEFT, $I_TOP, $I_WIDTH, $I_HEIGHT, $I_STYLE, $I_EXSTYLE)
	If $I_CTRLID <> 0 Then
		GUICtrlSetFont($I_CTRLID, -1, -1, 4)
		GUICtrlSetColor($I_CTRLID, $I_COLOR)
		GUICtrlSetCursor($I_CTRLID, 0)
		If $S_TOOLTIP <> '' Then
			GUICtrlSetTip($I_CTRLID, $S_TOOLTIP)
		EndIf
	EndIf
	Return $I_CTRLID
EndFunc   ;==>_GuiCtrlCreateHyperlink

;===================================================================================================================================================
;
; Function Name:    _MsgBoxMgt($msg)
; Description:      MessageBox Management
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  None
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;
Func _MsgBoxMgt($MSG)
	Select
		Case $MSG = $chkMWarning
			GUICtrlSetState($chkMQuestion, $GUI_UNCHECKED)
			GUICtrlSetState($chkMCritical, $GUI_UNCHECKED)
			GUICtrlSetState($chkMInfo, $GUI_UNCHECKED)

		Case $MSG = $chkMQuestion
			GUICtrlSetState($chkMWarning, $GUI_UNCHECKED)
			GUICtrlSetState($chkMCritical, $GUI_UNCHECKED)
			GUICtrlSetState($chkMInfo, $GUI_UNCHECKED)

		Case $MSG = $chkMCritical
			GUICtrlSetState($chkMWarning, $GUI_UNCHECKED)
			GUICtrlSetState($chkMQuestion, $GUI_UNCHECKED)
			GUICtrlSetState($chkMInfo, $GUI_UNCHECKED)

		Case $MSG = $chkMInfo
			GUICtrlSetState($chkMWarning, $GUI_UNCHECKED)
			GUICtrlSetState($chkMQuestion, $GUI_UNCHECKED)
			GUICtrlSetState($chkMCritical, $GUI_UNCHECKED)

		Case $MSG = $optMOK
			$Button = $optMOK
			GUICtrlSetState($optMFirst, $GUI_CHECKED)
			GUICtrlSetState($optMFirst, $GUI_ENABLE)
			GUICtrlSetState($optMSecond, $GUI_DISABLE)
			GUICtrlSetState($optMThird, $GUI_DISABLE)

		Case $MSG = $optMOKCancel
			$Button = $optMOKCancel
			GUICtrlSetState($optMFirst, $GUI_CHECKED)
			GUICtrlSetState($optMFirst, $GUI_ENABLE)
			GUICtrlSetState($optMSecond, $GUI_ENABLE)
			GUICtrlSetState($optMThird, $GUI_DISABLE)

		Case $MSG = $optMYesNo
			$Button = $optMYesNo
			GUICtrlSetState($optMFirst, $GUI_CHECKED)
			GUICtrlSetState($optMFirst, $GUI_ENABLE)
			GUICtrlSetState($optMSecond, $GUI_ENABLE)
			GUICtrlSetState($optMThird, $GUI_DISABLE)

		Case $MSG = $optMYesNoCancel
			$Button = $optMYesNoCancel
			GUICtrlSetState($optMFirst, $GUI_CHECKED)
			GUICtrlSetState($optMFirst, $GUI_ENABLE)
			GUICtrlSetState($optMSecond, $GUI_ENABLE)
			GUICtrlSetState($optMThird, $GUI_ENABLE)

		Case $MSG = $optMAbortRetryIgnore
			$Button = $optMAbortRetryIgnore
			GUICtrlSetState($optMFirst, $GUI_CHECKED)
			GUICtrlSetState($optMFirst, $GUI_ENABLE)
			GUICtrlSetState($optMSecond, $GUI_ENABLE)
			GUICtrlSetState($optMThird, $GUI_ENABLE)

		Case $MSG = $optMRetryCancel
			$Button = $optMRetryCancel
			GUICtrlSetState($optMFirst, $GUI_CHECKED)
			GUICtrlSetState($optMFirst, $GUI_ENABLE)
			GUICtrlSetState($optMSecond, $GUI_ENABLE)
			GUICtrlSetState($optMThird, $GUI_DISABLE)

		Case $MSG = $optMCancelTryContinue
			$Button = $optMCancelTryContinue
			GUICtrlSetState($optMFirst, $GUI_CHECKED)
			GUICtrlSetState($optMFirst, $GUI_ENABLE)
			GUICtrlSetState($optMSecond, $GUI_ENABLE)
			GUICtrlSetState($optMThird, $GUI_ENABLE)

		Case $MSG = $btnPreview ;Preview Button
			$sMFlag = _SetFlag()
			MsgBox($sMFlag, GUICtrlRead($txtMTitle), GUICtrlRead($txtMText), GUICtrlRead($txtMTimeout))

		Case $MSG = $btnCopy ;Copy Button
			_TextConvert($txtMText)
			_MComments()
			$sMFlag = _SetFlag()

			;Enclose Title in double-quotes/single-quotes
			$sTitle = GUICtrlRead($txtMTitle)
			If StringInStr($sTitle, Chr(34)) <> 0 Then
				$sTitle = "'" & $sTitle & "'"
			Else
				$sTitle = Chr(34) & $sTitle & Chr(34)
			EndIf

			Select
				Case $Button = $optMOK
					If GUICtrlRead($txtMTimeout) = "" Then
						$sMsgBox = $sMsgBox & "MsgBox(" & $sMFlag & "," & $sTitle & "," & $sText & ")"
					Else
						$sMsgBox = $sMsgBox & "If Not IsDeclared(" & Chr(34) & "iMsgBoxAnswer" & Chr(34) & ") Then Local $iMsgBoxAnswer" & @CRLF & _
								"$iMsgBoxAnswer = MsgBox(" & $sMFlag & "," & $sTitle & "," _
								 & $sText & "," & GUICtrlRead($txtMTimeout) & ")" & @CRLF & _
								"Select" & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = -1 ;Timeout" & @CRLF & @CRLF & _
								@TAB & "Case Else                ;OK" & @CRLF & @CRLF & _
								"EndSelect"
					EndIf

				Case $Button = $optMOKCancel
					If GUICtrlRead($txtMTimeout) = "" Then
						$sMsgBox = $sMsgBox & "If Not IsDeclared(" & Chr(34) & "iMsgBoxAnswer" & Chr(34) & ") Then Local $iMsgBoxAnswer" & @CRLF & _
								"$iMsgBoxAnswer = MsgBox(" & $sMFlag & "," & $sTitle & "," _
								 & $sText & ")" & @CRLF & _
								"Select" & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 1 ;OK" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 2 ;Cancel" & @CRLF & @CRLF & _
								"EndSelect"
					Else
						$sMsgBox = $sMsgBox & "If Not IsDeclared(" & Chr(34) & "iMsgBoxAnswer" & Chr(34) & ") Then Local $iMsgBoxAnswer" & @CRLF & _
								"$iMsgBoxAnswer = MsgBox(" & $sMFlag & "," & $sTitle & "," _
								 & $sText & "," & GUICtrlRead($txtMTimeout) & ")" & @CRLF & _
								"Select" & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 1 ;OK" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 2 ;Cancel" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = -1 ;Timeout" & @CRLF & @CRLF & _
								"EndSelect"
					EndIf

				Case $Button = $optMYesNo
					If GUICtrlRead($txtMTimeout) = "" Then
						$sMsgBox = $sMsgBox & "If Not IsDeclared(" & Chr(34) & "iMsgBoxAnswer" & Chr(34) & ") Then Local $iMsgBoxAnswer" & @CRLF & _
								"$iMsgBoxAnswer = MsgBox(" & $sMFlag & "," & $sTitle & "," _
								 & $sText & ")" & @CRLF & _
								"Select" & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 6 ;Yes" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 7 ;No" & @CRLF & @CRLF & _
								"EndSelect"
					Else
						$sMsgBox = $sMsgBox & "If Not IsDeclared(" & Chr(34) & "iMsgBoxAnswer" & Chr(34) & ") Then Local $iMsgBoxAnswer" & @CRLF & _
								"$iMsgBoxAnswer = MsgBox(" & $sMFlag & "," & $sTitle & "," _
								 & $sText & "," & GUICtrlRead($txtMTimeout) & ")" & @CRLF & _
								"Select" & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 6 ;Yes" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 7 ;No" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = -1 ;Timeout" & @CRLF & @CRLF & _
								"EndSelect"
					EndIf

				Case $Button = $optMYesNoCancel
					If GUICtrlRead($txtMTimeout) = "" Then
						$sMsgBox = $sMsgBox & "If Not IsDeclared(" & Chr(34) & "iMsgBoxAnswer" & Chr(34) & ") Then Local $iMsgBoxAnswer" & @CRLF & _
								"$iMsgBoxAnswer = MsgBox(" & $sMFlag & "," & $sTitle & "," _
								 & $sText & ")" & @CRLF & _
								"Select" & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 6 ;Yes" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 7 ;No" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 2 ;Cancel" & @CRLF & @CRLF & _
								"EndSelect"
					Else
						$sMsgBox = $sMsgBox & "If Not IsDeclared(" & Chr(34) & "iMsgBoxAnswer" & Chr(34) & ") Then Local $iMsgBoxAnswer" & @CRLF & _
								"$iMsgBoxAnswer = MsgBox(" & $sMFlag & "," & $sTitle & "," _
								 & $sText & "," & GUICtrlRead($txtMTimeout) & ")" & @CRLF & _
								"Select" & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 6 ;Yes" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 7 ;No" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 2 ;Cancel" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = -1 ;Timeout" & @CRLF & @CRLF & _
								"EndSelect"
					EndIf

				Case $Button = $optMAbortRetryIgnore
					If GUICtrlRead($txtMTimeout) = "" Then
						$sMsgBox = $sMsgBox & "If Not IsDeclared(" & Chr(34) & "iMsgBoxAnswer" & Chr(34) & ") Then Local $iMsgBoxAnswer" & @CRLF & _
								"$iMsgBoxAnswer = MsgBox(" & $sMFlag & "," & $sTitle & "," _
								 & $sText & ")" & @CRLF & _
								"Select" & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 3 ;Abort" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 4 ;Retry" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 5 ;Ignore" & @CRLF & @CRLF & _
								"EndSelect"
					Else
						$sMsgBox = $sMsgBox & "If Not IsDeclared(" & Chr(34) & "iMsgBoxAnswer" & Chr(34) & ") Then Local $iMsgBoxAnswer" & @CRLF & _
								"$iMsgBoxAnswer = MsgBox(" & $sMFlag & "," & $sTitle & "," _
								 & $sText & "," & GUICtrlRead($txtMTimeout) & ")" & @CRLF & _
								"Select" & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 3 ;Abort" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 4 ;Retry" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 5 ;Ignore" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = -1 ;Timeout" & @CRLF & @CRLF & _
								"EndSelect"
					EndIf

				Case $Button = $optMRetryCancel
					If GUICtrlRead($txtMTimeout) = "" Then
						$sMsgBox = $sMsgBox & "If Not IsDeclared(" & Chr(34) & "iMsgBoxAnswer" & Chr(34) & ") Then Local $iMsgBoxAnswer" & @CRLF & _
								"$iMsgBoxAnswer = MsgBox(" & $sMFlag & "," & $sTitle & "," _
								 & $sText & ")" & @CRLF & _
								"Select" & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 4 ;Retry" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 2 ;Cancel" & @CRLF & @CRLF & _
								"EndSelect"
					Else
						$sMsgBox = $sMsgBox & "If Not IsDeclared(" & Chr(34) & "iMsgBoxAnswer" & Chr(34) & ") Then Local $iMsgBoxAnswer" & @CRLF & _
								"$iMsgBoxAnswer = MsgBox(" & $sMFlag & "," & $sTitle & "," _
								 & $sText & "," & GUICtrlRead($txtMTimeout) & ")" & @CRLF & _
								"Select" & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 4 ;Retry" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 2 ;Cancel" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = -1 ;Timeout" & @CRLF & @CRLF & _
								"EndSelect"
					EndIf

				Case $Button = $optMCancelTryContinue
					If GUICtrlRead($txtMTimeout) = "" Then
						$sMsgBox = $sMsgBox & "If Not IsDeclared(" & Chr(34) & "iMsgBoxAnswer" & Chr(34) & ") Then Local $iMsgBoxAnswer" & @CRLF & _
								"$iMsgBoxAnswer = MsgBox(" & $sMFlag & "," & $sTitle & "," _
								 & $sText & ")" & @CRLF & _
								"Select" & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 2 ;Cancel" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 10 ;Try Again" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 11 ;Continue" & @CRLF & @CRLF & _
								"EndSelect"
					Else
						$sMsgBox = $sMsgBox & "If Not IsDeclared(" & Chr(34) & "iMsgBoxAnswer" & Chr(34) & ") Then Local $iMsgBoxAnswer" & @CRLF & _
								"$iMsgBoxAnswer = MsgBox(" & $sMFlag & "," & $sTitle & "," _
								 & $sText & "," & GUICtrlRead($txtMTimeout) & ")" & @CRLF & _
								"Select" & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 2  ;Cancel" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 10 ;Try Again" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = 11 ;Continue" & @CRLF & @CRLF & _
								@TAB & "Case $iMsgBoxAnswer = -1 ;Timeout" & @CRLF & @CRLF & _
								"EndSelect"
					EndIf
			EndSelect

			If GUICtrlRead($chkMConstants) = $GUI_CHECKED Then
				$sMsgBox = StringReplace($sMsgBox, "1 ;OK", "$IDOK")
				$sMsgBox = StringReplace($sMsgBox, "2 ;Cancel", "$IDCANCEL")
				$sMsgBox = StringReplace($sMsgBox, "3 ;Abort", "$IDABORT")
				$sMsgBox = StringReplace($sMsgBox, "4 ;Retry", "$IDRETRY")
				$sMsgBox = StringReplace($sMsgBox, "5 ;Ignore", "$IDIGNORE")
				$sMsgBox = StringReplace($sMsgBox, "6 ;Yes", "$IDYES")
				$sMsgBox = StringReplace($sMsgBox, "7 ;No", "$IDNO")
				$sMsgBox = StringReplace($sMsgBox, "10 ;Try Again", "$IDTRYAGAIN")
				$sMsgBox = StringReplace($sMsgBox, "11 ;Continue", "$IDCONTINUE")
			EndIf

			$sMsgBox = $sMsgBox & @CRLF & "#EndRegion --- CodeWizard generated code End ---" & @CRLF ;Comment string with MessageBox features
			_SendCode($sOutType, $sMsgBox)
	EndSelect
EndFunc   ;==>_MsgBoxMgt

;===================================================================================================================================================
;
; Function Name:    _InputBoxMgt($msg)
; Description:      InputBox Management
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  None
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;

Func _InputBoxMgt($MSG)
	Select
		Case $MSG = $btnPreview
			_Position($txtIWidth, $txtIHeight, $txtILeft, $txtITop, $iWidth, $iHeight, $iLeft, $iTop)
			InputBox(GUICtrlRead($txtITitle), GUICtrlRead($txtIPrompt), GUICtrlRead($txtIDefault), _PwdChr(), _
					$iWidth, $iHeight, $iLeft, $iTop, GUICtrlRead($txtITimeOut))

		Case $MSG = $btnCopy
			_Position($txtIWidth, $txtIHeight, $txtILeft, $txtITop, $iWidth, $iHeight, $iLeft, $iTop)
			_PwdChr() ;Set the password char field
			_TextConvert($txtIPrompt)
			_IComments() ;Comment string with InputBox features

			;Enclose Title in double-quotes/single-quotes
			$sTitle = GUICtrlRead($txtITitle)
			If StringInStr($sTitle, Chr(34)) <> 0 Then
				$sTitle = "'" & $sTitle & "'"
			Else
				$sTitle = Chr(34) & $sTitle & Chr(34)
			EndIf

			If GUICtrlRead($txtITimeOut) = "" Then
				$sInputBox = $sInputBox & "If Not IsDeclared(" & Chr(34) & "sInputBoxAnswer" & Chr(34) & ") Then Local $sInputBoxAnswer" & @CRLF & _
						"$sInputBoxAnswer = InputBox(" & $sTitle & "," & $sText & "," & Chr(34) & _
						GUICtrlRead($txtIDefault) & Chr(34) & "," & Chr(34) & $sIPwdChr & Chr(34) & "," & _
						Chr(34) & $iWidth & Chr(34) & "," & Chr(34) & $iHeight & Chr(34) & "," & Chr(34) & $iLeft & Chr(34) & "," _
						 & Chr(34) & $iTop & Chr(34) & ")" & @CRLF & _
						"Select" & @CRLF & _
						@TAB & "Case @Error = 0 ;OK - The string returned is valid" & @CRLF & @CRLF & _
						@TAB & "Case @Error = 1 ;The Cancel button was pushed" & @CRLF & @CRLF & _
						@TAB & "Case @Error = 3 ;The InputBox failed to open" & @CRLF & @CRLF & _
						"EndSelect"
			Else
				$sInputBox = $sInputBox & "If Not IsDeclared(" & Chr(34) & "sInputBoxAnswer" & Chr(34) & ") Then Local $sInputBoxAnswer" & @CRLF & _
						"$sInputBoxAnswer = InputBox(" & $sTitle & "," & $sText & "," & Chr(34) & _
						GUICtrlRead($txtIDefault) & Chr(34) & "," & Chr(34) & $sIPwdChr & Chr(34) & "," & _
						Chr(34) & $iWidth & Chr(34) & "," & Chr(34) & $iHeight & Chr(34) & "," & Chr(34) & $iLeft & Chr(34) & "," _
						 & Chr(34) & $iTop & Chr(34) & "," & Chr(34) & GUICtrlRead($txtITimeOut) & Chr(34) & ")" & @CRLF & _
						"Select" & @CRLF & _
						@TAB & "Case @Error = 0 ;OK - The string returned is valid" & @CRLF & @CRLF & _
						@TAB & "Case @Error = 1 ;The Cancel button was pushed" & @CRLF & @CRLF & _
						@TAB & "Case @Error = 2 ;The Timeout time was reached" & @CRLF & @CRLF & _
						@TAB & "Case @Error = 3 ;The InputBox failed to open" & @CRLF & @CRLF & _
						"EndSelect"
			EndIf

			$sInputBox = $sInputBox & @CRLF & "#EndRegion --- CodeWizard generated code End ---" & @CRLF

			_SendCode($sOutType, $sInputBox)
	EndSelect

EndFunc   ;==>_InputBoxMgt

;===================================================================================================================================================
;
; Function Name:    _ToolTipMgt($msg)
; Description:      ToolTip Management
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  None
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;

Func _ToolTipMgt($MSG)
	Select
		Case $MSG = $chkTWarning
			GUICtrlSetState($chkTCritical, $GUI_UNCHECKED)
			GUICtrlSetState($chkTInfo, $GUI_UNCHECKED)

		Case $MSG = $chkTCritical
			GUICtrlSetState($chkTWarning, $GUI_UNCHECKED)
			GUICtrlSetState($chkTInfo, $GUI_UNCHECKED)

		Case $MSG = $chkTInfo
			GUICtrlSetState($chkTWarning, $GUI_UNCHECKED)
			GUICtrlSetState($chkTCritical, $GUI_UNCHECKED)

		Case $MSG = $btnPreview
			_Coordinates($txtTX, $txtTY, $sX, $sY)

			;Set ESC hotkey to close splash screen
			HotKeySet("{ESC}", "_StopToolTip")
			; This will create a tooltip in the upper left of the screen
			TrayTip("CodeWizard", "Press ESC to close the ToolTip", 5, $TIP_ICONASTERISK)

			ToolTip(GUICtrlRead($txtTText), $sX, $sY, GUICtrlRead($txtTTitle), _ToolTipIcon(), _ToolTipOptions())

		Case $MSG = $btnCopy
			_Coordinates($txtTX, $txtTY, $sX, $sY)
			_TextConvert($txtTText)
			$iToolTipIcon = _ToolTipIcon()
			$iToolTipOptions = _ToolTipOptions()
			_TTComments() ;Comment string with ToolTip features

			;Enclose Title in double-quotes/single-quotes
			$sTitle = GUICtrlRead($txtTTitle)
			If StringInStr($sTitle, Chr(34)) <> 0 Then
				$sTitle = "'" & $sTitle & "'"
			Else
				$sTitle = Chr(34) & $sTitle & Chr(34)
			EndIf

			$sToolTip = $sToolTip & "If Not IsDeclared(" & Chr(34) & "sToolTipAnswer" & Chr(34) & ") Then Local $sToolTipAnswer" & @CRLF & _
					"$sToolTipAnswer = ToolTip(" & $sText & "," & $sX & "," & $sY & "," & $sTitle & _
					"," & $iToolTipIcon & "," & $iToolTipOptions & ")"

			$sToolTip = $sToolTip & @CRLF & "#EndRegion --- CodeWizard generated code End ---" & @CRLF

			_SendCode($sOutType, $sToolTip)

	EndSelect

EndFunc   ;==>_ToolTipMgt

;===================================================================================================================================================
;
; Function Name:    _SplashTextMgt($msg)
; Description:      SplashText Management
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  None
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;
Func _SplashTextMgt($MSG)
	Select
		;Title
		Case $MSG = $chkSTTitle
			If GUICtrlRead($chkSTTitle) = $GUI_CHECKED Then
				GUICtrlSetState($lblSTTitle, $GUI_ENABLE)
				GUICtrlSetState($txtSTTitle, $GUI_ENABLE)
				GUICtrlSetState($chkSTWinMove, $GUI_ENABLE)
			Else
				GUICtrlSetState($lblSTTitle, $GUI_DISABLE)
				GUICtrlSetState($txtSTTitle, $GUI_DISABLE)
				GUICtrlSetData($txtSTTitle, "")
				GUICtrlSetState($chkSTWinMove, $GUI_DISABLE)
				GUICtrlSetState($chkSTWinMove, $GUI_UNCHECKED)
			EndIf

			;Fonts
		Case $MSG = $btnSTFonts
			$asFonts = _ChooseFont()
			If (Not @error) Then
				GUICtrlSetData($txtSTFontName, $asFonts[2])
				GUICtrlSetData($txtSTFontSize, $asFonts[3])
				GUICtrlSetData($txtSTFontWeight, $asFonts[4])
			EndIf

		Case $MSG = $btnPreview
			_Position($txtSTWidth, $txtSTHeight, $txtSTLeft, $txtSTTop, $iWidth, $iHeight, $iLeft, $iTop)
			_SplashTextOpt($chkSTTitle, $chkSTOnTop, $chkSTVertical, $chkSTWinMove, $optJustCenter, $optJustLeft, $optJustRight)

			;Set ESC hotkey to close splash screen
			HotKeySet("{ESC}", "_StopSplash")
			; This will create a tooltip in the upper left of the screen
			TrayTip("CodeWizard", "Press ESC to close the Popup window", 5, $TIP_ICONASTERISK)

			SplashTextOn(GUICtrlRead($txtSTTitle), GUICtrlRead($txtSTText), $iWidth, $iHeight, $iLeft, $iTop, $iOpt, GUICtrlRead($txtSTFontName), _
					GUICtrlRead($txtSTFontSize), GUICtrlRead($txtSTFontWeight))

		Case $MSG = $btnCopy
			_Position($txtSTWidth, $txtSTHeight, $txtSTLeft, $txtSTTop, $iWidth, $iHeight, $iLeft, $iTop)
			_TextConvert($txtSTText)
			_STComments() ;Comment string with SplashText features

			;Enclose Title in double-quotes/single-quotes
			$sTitle = GUICtrlRead($txtSTTitle)
			If StringInStr($sTitle, Chr(34)) <> 0 Then
				$sTitle = "'" & $sTitle & "'"
			Else
				$sTitle = Chr(34) & $sTitle & Chr(34)
			EndIf

			$sSpashText = $sSpashText & _
					"SplashTextOn(" & $sTitle & "," & $sText & "," & Chr(34) & _
					$iWidth & Chr(34) & "," & Chr(34) & $iHeight & Chr(34) & "," & Chr(34) & $iLeft & Chr(34) & "," _
					 & Chr(34) & $iTop & Chr(34) & "," & _SplashTextOpt($chkSTTitle, $chkSTOnTop, $chkSTVertical, $chkSTWinMove, _
					$optJustCenter, $optJustLeft, $optJustRight) & "," & Chr(34) & _
					GUICtrlRead($txtSTFontName) & Chr(34) & "," & Chr(34) & GUICtrlRead($txtSTFontSize) & Chr(34) & "," _
					 & Chr(34) & GUICtrlRead($txtSTFontWeight) & Chr(34) & ")" _
					 & @CRLF & "#EndRegion --- CodeWizard generated code End ---" & @CRLF

			_SendCode($sOutType, $sSpashText)

	EndSelect

EndFunc   ;==>_SplashTextMgt

;===================================================================================================================================================
;
; Function Name:    _SplashImageMgt($msg)
; Description:      SplashText Management
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  None
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;
Func _SplashImageMgt($MSG)
	Select
		;Title
		Case $MSG = $chkSITitle
			If GUICtrlRead($chkSITitle) = $GUI_CHECKED Then
				GUICtrlSetState($lblSITitle, $GUI_ENABLE)
				GUICtrlSetState($txtSITitle, $GUI_ENABLE)
				GUICtrlSetState($chkSIWinMove, $GUI_ENABLE)
			Else
				GUICtrlSetState($lblSITitle, $GUI_DISABLE)
				GUICtrlSetState($txtSITitle, $GUI_DISABLE)
				GUICtrlSetData($txtSITitle, "")
				GUICtrlSetState($chkSIWinMove, $GUI_DISABLE)
				GUICtrlSetState($chkSIWinMove, $GUI_UNCHECKED)
			EndIf

			;Open File dialog box
		Case $MSG = $btnSIImage
			Local $sImage
			$sImage = FileOpenDialog("Choose image (BMP, GIF, or JPG)", @MyDocumentsDir, "Images (*.bmp;*.gif;*.jpg)", 3)
			If Not @error Then
				$sImageExt = StringLower(StringRight($sImage, 3))
				If $sImageExt <> "bmp" And $sImageExt <> "gif" And $sImageExt <> "jpg" Then
					;MsgBox features: Title=Yes, Text=Yes, Buttons=OK, Icon=Critical
					MsgBox($MB_ICONERROR, "CodeWizard", "The image should be a Bitmap, GIF or JPEG image")
				Else
					GUICtrlSetData($txtSIFile, $sImage)
				EndIf
			EndIf

		Case $MSG = $btnPreview ;Preview
			$sImageExt = StringLower(StringRight(GUICtrlRead($txtSIFile), 3))

			If $sImageExt <> "bmp" And $sImageExt <> "gif" And $sImageExt <> "jpg" Then
				;MsgBox features: Title=Yes, Text=Yes, Buttons=OK, Icon=Critical
				MsgBox($MB_ICONERROR, "CodeWizard", "The image should be a Bitmap, GIF or JPEG image")
			Else
				_Position($txtSIWidth, $txtSIHeight, $txtSILeft, $txtSITop, $iWidth, $iHeight, $iLeft, $iTop)
				_SplashImageOpt($chkSITitle, $chkSIOnTop, $chkSIWinMove)

				;Set ESC hotkey to close splash screen
				HotKeySet("{ESC}", "_StopSplash")
				; This will create a tooltip in the upper left of the screen
				TrayTip("CodeWizard", "Press ESC to close the Popup window", 5, $TIP_ICONASTERISK)

				SplashImageOn(GUICtrlRead($txtSITitle), GUICtrlRead($txtSIFile), $iWidth, $iHeight, $iLeft, $iTop, $iOpt)
			EndIf

		Case $MSG = $btnCopy ;Copy
			$sImageExt = StringLower(StringRight(GUICtrlRead($txtSIFile), 3))

			If $sImageExt <> "bmp" And $sImageExt <> "gif" And $sImageExt <> "jpg" Then
				;MsgBox features: Title=Yes, Text=Yes, Buttons=OK, Icon=Critical
				MsgBox($MB_ICONERROR, "CodeWizard", "The image should be a Bitmap, GIF or JPEG image")
			Else
				_Position($txtSIWidth, $txtSIHeight, $txtSILeft, $txtSITop, $iWidth, $iHeight, $iLeft, $iTop)
				_SIComments() ;Comment string with SplashImage features

				$sSpashImage = $sSpashImage & _
						"SplashImageOn(" & Chr(34) & GUICtrlRead($txtSITitle) & Chr(34) & "," & Chr(34) & GUICtrlRead($txtSIFile) _
						 & Chr(34) & "," & Chr(34) & $iWidth & Chr(34) & "," & Chr(34) & $iHeight & Chr(34) & "," & Chr(34) & $iLeft & Chr(34) & "," _
						 & Chr(34) & $iTop & Chr(34) & "," & _SplashImageOpt($chkSITitle, $chkSIOnTop, $chkSIWinMove) & ")" _
						 & @CRLF & "#EndRegion --- CodeWizard generated code End ---" & @CRLF

				_SendCode($sOutType, $sSpashImage)
			EndIf
	EndSelect

EndFunc   ;==>_SplashImageMgt

;===================================================================================================================================================
;
; Function Name:    _SetFlag()
; Description:      Set the flag that indicates the type of message box and the
;                   possible button combinations.
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  On Success - Returns the message box flag
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;
Func _SetFlag()
	Local $iMFlag, $sMFlag

	;Buttons
	$sMsgBox = $sMsgBox & " Buttons="

	Select
		Case GUICtrlRead($optMOKCancel) = $GUI_CHECKED ; Two push buttons: OK and Cancel
			$iMFlag = 1
			$sMFlag = "$MB_OKCANCEL"
			$sMsgBox = $sMsgBox & "OK and Cancel,"
		Case GUICtrlRead($optMYesNo) = $GUI_CHECKED ; Two push buttons: Yes and No
			$iMFlag = 4
			$sMFlag = "$MB_YESNO"
			$sMsgBox = $sMsgBox & "Yes and No,"
		Case GUICtrlRead($optMYesNoCancel) = $GUI_CHECKED ; Three push buttons: Yes, No, and Cancel
			$iMFlag = 3
			$sMFlag = "$MB_YESNOCANCEL"
			$sMsgBox = $sMsgBox & "Yes, No, and Cancel,"
		Case GUICtrlRead($optMAbortRetryIgnore) = $GUI_CHECKED ; Three push buttons: Abort, Retry, and Ignore
			$iMFlag = 2
			$sMFlag = "$MB_ABORTRETRYIGNORE"
			$sMsgBox = $sMsgBox & "Abort, Retry, and Ignore,"
		Case GUICtrlRead($optMRetryCancel) = $GUI_CHECKED ; Two push buttons: Retry and Cancel
			$iMFlag = 5
			$sMFlag = "$MB_RETRYCANCEL"
			$sMsgBox = $sMsgBox & "Retry and Cancel,"
		Case GUICtrlRead($optMCancelTryContinue) = $GUI_CHECKED ; Three push buttons: Cancel, Try Again, Continue
			$iMFlag = 6
			$sMFlag = "$MB_CANCELTRYCONTINUE"
			$sMsgBox = $sMsgBox & "Cancel, Try Again, Continue,"
		Case Else ; One push button: OK
			$iMFlag = 0
			$sMFlag = "$MB_OK"
			$sMsgBox = $sMsgBox & "OK,"
	EndSelect

	;Default Button
	Select
		Case GUICtrlRead($optMSecond) = $GUI_CHECKED ; The second button is the default button
			$iMFlag = $iMFlag + 256
			$sMFlag = $sMFlag & " + " & "$MB_DEFBUTTON2"
			$sMsgBox = $sMsgBox & " Default Button=Second,"
		Case GUICtrlRead($optMThird) = $GUI_CHECKED ; The third button is the default button
			$iMFlag = $iMFlag + 512
			$sMFlag = $sMFlag & " + " & "$MB_DEFBUTTON3"
			$sMsgBox = $sMsgBox & " Default Button=Third,"
		Case Else ; The first button is the default button
			If $sMFlag <> $MB_OK Then $sMsgBox = $sMsgBox & " Default Button=First,"
	EndSelect

	;Icons
	$sMsgBox = $sMsgBox & " Icon="

	Select
		Case GUICtrlRead($chkMWarning) = $GUI_CHECKED ; Exclamation-point icon
			$iMFlag = $iMFlag + 48
			$sMFlag = $sMFlag & " + " & "$MB_ICONEXCLAMATION"
			$sMsgBox = $sMsgBox & "Warning,"
		Case GUICtrlRead($chkMInfo) = $GUI_CHECKED ; Icon consisting of an 'i' in a circle
			$iMFlag = $iMFlag + 64
			$sMFlag = $sMFlag & " + " & "$MB_ICONASTERISK"
			$sMsgBox = $sMsgBox & "Info,"
		Case GUICtrlRead($chkMCritical) = $GUI_CHECKED ; Stop-sign icon
			$iMFlag = $iMFlag + 16
			$sMFlag = $sMFlag & " + " & "$MB_ICONHAND"
			$sMsgBox = $sMsgBox & "Critical,"
		Case GUICtrlRead($chkMQuestion) = $GUI_CHECKED ; Question-mark icon
			$iMFlag = $iMFlag + 32
			$sMFlag = $sMFlag & " + " & "$MB_ICONQUESTION"
			$sMsgBox = $sMsgBox & "Question,"
		Case Else ; None
			$sMsgBox = $sMsgBox & "None,"
	EndSelect

	;Modality
	Select
		Case GUICtrlRead($optMSysModal) = $GUI_CHECKED ; System modal
			$iMFlag = $iMFlag + 4096
			$sMFlag = $sMFlag & " + " & "$MB_SYSTEMMODAL"
			$sMsgBox = $sMsgBox & " Modality=System Modal,"
		Case GUICtrlRead($optMTaskModal) = $GUI_CHECKED ; Task modal
			$iMFlag = $iMFlag + 8192
			$sMFlag = $sMFlag & " + " & "$MB_TASKMODAL"
			$sMsgBox = $sMsgBox & " Modality=Task Modal,"
	EndSelect

	;Timeout
	If GUICtrlRead($txtMTimeout) <> "" Then $sMsgBox = $sMsgBox & " Timeout=" & GUICtrlRead($txtMTimeout) & " ss,"

	;Miscellaneous
	If GUICtrlRead($chkMTopMost) = $GUI_CHECKED Then ; MsgBox has top-most attribute set
		$iMFlag = $iMFlag + 262144
		$sMFlag = $sMFlag & " + " & "262144"
		$sMsgBox = $sMsgBox & " Miscellaneous=Top-most attribute,"
	EndIf

	If GUICtrlRead($chkMRightJust) = $GUI_CHECKED Then ; Title and text are right-justified
		$iMFlag = $iMFlag + 524288
		$sMFlag = $sMFlag & " + " & "524288"

		If GUICtrlRead($chkMTopMost) = $GUI_CHECKED Then
			$sMsgBox = StringTrimRight($sMsgBox, 1) & " and Title/text right-justified,"
		Else
			$sMsgBox = $sMsgBox & " Miscellaneous=Title/text right-justified,"
		EndIf
	EndIf

	$sMsgBox = StringTrimRight($sMsgBox, 1) ;Remove the last comma
	$sMsgBox = $sMsgBox & @CRLF

	If GUICtrlRead($chkMConstants) = $GUI_CHECKED And $MSG = $btnCopy Then
		Return $sMFlag
	Else
		Return $iMFlag
	EndIf
EndFunc   ;==>_SetFlag

;===================================================================================================================================================
;
; Function Name:    _ToolTipIcon()
; Description:      Set the optional Icon Number
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  On Success - Returns the _ToolTip Icon Number
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;

Func _ToolTipIcon()
	Local $iTFlag

	;Icons
;~ 	$sMsgBox = $sMsgBox & " Icon="

	Select
		Case GUICtrlRead($chkTWarning) = $GUI_CHECKED ; Exclamation-point icon
			$iTFlag = 2
;~ 			$sMFlag = $sMFlag & " + " & "$MB_ICONEXCLAMATION"
;~ 			$sMsgBox = $sMsgBox & "Warning,"
		Case GUICtrlRead($chkTInfo) = $GUI_CHECKED ; Icon consisting of an 'i' in a circle
			$iTFlag = 1
;~ 			$sMFlag = $sMFlag & " + " & "$MB_ICONASTERISK"
;~ 			$sMsgBox = $sMsgBox & "Info,"
		Case GUICtrlRead($chkTCritical) = $GUI_CHECKED ; Stop-sign icon
			$iTFlag = 3
;~ 			$sMFlag = $sMFlag & " + " & "$MB_ICONHAND"
;~ 			$sMsgBox = $sMsgBox & "Critical,"
		Case Else ; None
			$iTFlag = 0
;~ 			$sMsgBox = $sMsgBox & "None,"
	EndSelect

	Return $iTFlag
EndFunc   ;==>_ToolTipIcon

;===================================================================================================================================================
;
; Function Name:    _ToolTipOptions()
; Description:      Set the flag that indicates the type of message box and the
;                   possible button combinations.
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  On Success - Returns the _ToolTip Icon Number
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;

Func _ToolTipOptions()
	Local $iTOpt = 0

	;Icons
;~ 	$sMsgBox = $sMsgBox & " Icon="

	If GUICtrlRead($chkTBalloonTip) = $GUI_CHECKED Then ; Balloon Tip
		$iTOpt = $iTOpt + 1
;~ 			$sMFlag = $sMFlag & " + " & "$MB_ICONEXCLAMATION"
	EndIf

	If GUICtrlRead($chkTCenterTip) = $GUI_CHECKED Then ; Center the tip at the x,y coordinates
		$iTOpt = $iTOpt + 2
;~ 			$sMFlag = $sMFlag & " + " & "$MB_ICONASTERISK"
	EndIf

	Return $iTOpt
EndFunc   ;==>_ToolTipOptions

;===================================================================================================================================================
;
; Function Name:    _PwdChr()
; Description:      Set the password char field that indicates the type of input
;					box.
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  On Success - Returns the password char field
;                   None
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;

Func _PwdChr()
	If GUICtrlRead($txtIPwdChr) = "" Then
		$sIPwdChr = " "
	Else
		$sIPwdChr = GUICtrlRead($txtIPwdChr)
	EndIf

	If GUICtrlRead($chkIMandatory) = $GUI_CHECKED Then
		$sIPwdChr = $sIPwdChr & "M"
	EndIf

	$sIPwdChr = $sIPwdChr & GUICtrlRead($txtIChrLen)

	Return $sIPwdChr
EndFunc   ;==>_PwdChr

;===================================================================================================================================================
;
; Function Name:    _Position($txtWidth, $txtHeight, $txtLeft, $txtTop, ByRef $sWidth, ByRef $sHeight, ByRef $sLeft, ByRef $sTop)
; Description:      Set the flag that indicates the size and position of input
;					box and the possible button combinations.
; Parameter(s):     $txtWidth, $txtHeight, $txtLeft, $txtTop
; Requirement(s):   None
; Return Value(s):  On Success - Returns  Width
;										  Height
;										  Left
;										  Top
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;

Func _Position($txtWidth, $txtHeight, $txtLeft, $txtTop, ByRef $sWidth, ByRef $sHeight, ByRef $sLeft, ByRef $sTop)
	If GUICtrlRead($txtWidth) = "" Then
		$sWidth = "-1"
	Else
		$sWidth = GUICtrlRead($txtWidth)
	EndIf

	If GUICtrlRead($txtHeight) = "" Then
		$sHeight = "-1"
	Else
		$sHeight = GUICtrlRead($txtHeight)
	EndIf

	If GUICtrlRead($txtLeft) = "" Then
		$sLeft = "-1"
	Else
		$sLeft = GUICtrlRead($txtLeft)
	EndIf

	If GUICtrlRead($txtTop) = "" Then
		$sTop = "-1"
	Else
		$sTop = GUICtrlRead($txtTop)
	EndIf

EndFunc   ;==>_Position

;===================================================================================================================================================
;
; Function Name:    _Coordinates($txtX, $txtY, ByRef $sX, ByRef $sY)
; Description:      Set the X, Y coordinates
; Parameter(s):     $txtX, $txtY
; Requirement(s):   None
; Return Value(s):  On Success - Returns  X coordinate
;										  Y coordinate
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;

Func _Coordinates($txtX, $txtY, ByRef $sX, ByRef $sY)

	If GUICtrlRead($txtTX) = "" Then
		$sX = "Default"
	Else
		$sX = GUICtrlRead($txtTX)
	EndIf

	If GUICtrlRead($txtTY) = "" Then
		$sY = "Default"
	Else
		$sY = GUICtrlRead($txtTY)
	EndIf

EndFunc   ;==>_Coordinates

;===================================================================================================================================================
;
; Function Name:    _SplashTextOpt($txtWidth, $txtHeight, $txtLeft, $txtTop, ByRef $sWidth, ByRef $sHeight, ByRef $sLeft, ByRef $sTop)
; Description:      Set the flag that indicates the size and position of input
;					box and the possible button combinations.
; Parameter(s):     $chkSTTitle, $chkSTOnTop, $chkSTWinMove, $optJustCenter, $optJustLeft, $optJustRight
; Requirement(s):   None
; Return Value(s):  On Success - Returns  $iOpt/$sSTFlag
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;

Func _SplashTextOpt($chkSTTitle, $chkSTOnTop, $chkSTVertical, $chkSTWinMove, $optJustCenter, $optJustLeft, $optJustRight)
	$iOpt = 0
	$sOpt = ""

	If GUICtrlRead($chkSTTitle) = $GUI_UNCHECKED Then
		$iOpt = $iOpt + 1
		$sOpt = $sOpt & (($sOpt = "") ? "$DLG_NOTITLE" : " + $DLG_NOTITLE")
	EndIf

	If GUICtrlRead($chkSTOnTop) = $GUI_UNCHECKED Then
		$iOpt = $iOpt + 2
		$sOpt = $sOpt & (($sOpt = "") ? "$DLG_NOTONTOP" : " + $DLG_NOTONTOP")
	EndIf

	If GUICtrlRead($chkSTWinMove) = $GUI_CHECKED Then
		$iOpt = $iOpt + 16
		$sOpt = $sOpt & (($sOpt = "") ? "$DLG_MOVEABLE" : " + $DLG_MOVEABLE")
	EndIf

	If GUICtrlRead($chkSTVertical) = $GUI_CHECKED Then
		$iOpt = $iOpt + 32
		$sOpt = $sOpt & (($sOpt = "") ? "$DLG_TEXTVCENTER" : " + $DLG_TEXTVCENTER")
	EndIf

	Select
		Case GUICtrlRead($optJustLeft) = $GUI_CHECKED ; Left Justified
			$iOpt = $iOpt + 4
			$sOpt = $sOpt & (($sOpt = "") ? "$DLG_TEXTLEFT" : " + $DLG_TEXTLEFT")

		Case GUICtrlRead($optJustRight) = $GUI_CHECKED ; Right Justified
			$iOpt = $iOpt + 8
			$sOpt = $sOpt & (($sOpt = "") ? "$DLG_TEXTRIGHT" : " + $DLG_TEXTRIGHT")
	EndSelect

	If GUICtrlRead($chkSTConstants) = $GUI_CHECKED And $MSG = $btnCopy Then
		Return $sOpt
	Else
		Return $iOpt
	EndIf

EndFunc   ;==>_SplashTextOpt

;===================================================================================================================================================
;
; Function Name:    _SplashImageOpt($txtWidth, $txtHeight, $txtLeft, $txtTop, ByRef $sWidth, ByRef $sHeight, ByRef $sLeft, ByRef $sTop)
; Description:      Set the flag that indicates the size and position of input
;					box and the possible button combinations.
; Parameter(s):     $chkSTTitle, $chkSTOnTop, $chkSTWinMove, $optJustCenter, $optJustLeft, $optJustRight
; Requirement(s):   None
; Return Value(s):  On Success - Returns  $iOpt/$sSTFlag
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;

Func _SplashImageOpt($chkSITitle, $chkSIOnTop, $chkSIWinMove)
	$iOpt = 0
	$sOpt = ""

	If GUICtrlRead($chkSITitle) = $GUI_UNCHECKED Then
		$iOpt = $iOpt + 1
		$sOpt = $sOpt & (($sOpt = "") ? "$DLG_NOTITLE" : " + $DLG_NOTITLE")
	EndIf

	If GUICtrlRead($chkSIOnTop) = $GUI_UNCHECKED Then
		$iOpt = $iOpt + 2
		$sOpt = $sOpt & (($sOpt = "") ? "$DLG_NOTONTOP" : " + $DLG_NOTONTOP")
	EndIf

	If GUICtrlRead($chkSIWinMove) = $GUI_CHECKED Then
		$iOpt = $iOpt + 16
		$sOpt = $sOpt & (($sOpt = "") ? "16" : " + 16")
	EndIf

	If GUICtrlRead($chkSIConstants) = $GUI_CHECKED And $MSG = $btnCopy Then
		Return $sOpt
	Else
		Return $iOpt
	EndIf

EndFunc   ;==>_SplashImageOpt

;===================================================================================================================================================
;
; Function Name:    _MComments()
; Description:      Set the comment that indicates the features of message box
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  On Success - Returns $sMsgBox (Comment string)
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;

Func _MComments()
	$sMsgBox = "#Region --- CodeWizard generated code Start ---" & @CRLF

	If GUICtrlRead($chkMConstants) = $GUI_CHECKED Then
		$sMsgBox = $sMsgBox & "#include <Constants.au3>" & @CRLF & @CRLF
	EndIf

	If GUICtrlRead($txtMTitle) <> "" Then
		$sMsgBox = $sMsgBox & ";MsgBox features: Title=Yes,"
	Else
		$sMsgBox = $sMsgBox & ";MsgBox features: Title=No,"
	EndIf

	If $sText <> "" Then
		$sMsgBox = $sMsgBox & " Text=Yes,"
	Else
		$sMsgBox = $sMsgBox & " Text=No,"
	EndIf

	Return $sMsgBox
EndFunc   ;==>_MComments

;===================================================================================================================================================
;
; Function Name:    _IComments()
; Description:      Set the comment that indicates the features of input box
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  On Success - Returns $sInputBox (Comment string)
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;

Func _IComments()
	;Header of comment
	$sInputBox = "#Region --- CodeWizard generated code Start ---" & @CRLF & _
			";InputBox features:"

	If GUICtrlRead($txtITitle) <> "" Then
		$sInputBox = $sInputBox & " Title=Yes,"
	Else
		$sInputBox = $sInputBox & " Title=No,"
	EndIf

	If $sText <> "" Then
		$sInputBox = $sInputBox & " Prompt=Yes,"
	Else
		$sInputBox = $sInputBox & " Prompt=No,"
	EndIf

	If GUICtrlRead($txtIDefault) <> "" Then
		$sInputBox = $sInputBox & " Default Text=Yes,"
	Else
		$sInputBox = $sInputBox & " Default Text=No,"
	EndIf

	If GUICtrlRead($txtIChrLen) <> "" Then $sInputBox = $sInputBox & " Input Length=" & GUICtrlRead($txtIChrLen) & ","
	If GUICtrlRead($txtIPwdChr) <> "" Then $sInputBox = $sInputBox & " Pwd Char=" & GUICtrlRead($txtIPwdChr) & ","
	If GUICtrlRead($txtITimeOut) <> "" Then $sInputBox = $sInputBox & " TimeOut=" & GUICtrlRead($txtITimeOut) & " ss,"
	If GUICtrlRead($chkIMandatory) = $GUI_CHECKED Then $sInputBox = $sInputBox & " Mandatory,"
	If $iWidth <> "-1" Then $sInputBox = $sInputBox & " Width=" & $iWidth & ","
	If $iHeight <> "-1" Then $sInputBox = $sInputBox & " Height=" & $iHeight & ","
	If $iLeft <> "-1" Then $sInputBox = $sInputBox & " Left=" & $iLeft & ","
	If $iTop <> "-1" Then $sInputBox = $sInputBox & " Top=" & $iTop & ","

	$sInputBox = StringTrimRight($sInputBox, 1) ;Remove the last comma
	$sInputBox = $sInputBox & @CRLF

	Return $sInputBox
EndFunc   ;==>_IComments

;===================================================================================================================================================
;
; Function Name:    _TTComments()
; Description:      Set the comment that indicates the features of ToolTip
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  On Success - Returns $sToolTip (Comment string)
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;

Func _TTComments()
	;Header of comment
	$sToolTip = "#Region --- CodeWizard generated code Start ---" & @CRLF & _
			";ToolTip features:"

	If $sText <> "" Then
		$sToolTip = $sToolTip & " Text=Yes,"
	Else
		$sToolTip = $sToolTip & " Text=No,"
	EndIf

	If $sX <> "Default" Then
		$sToolTip = $sToolTip & " X Coordinate=Yes,"
	Else
		$sToolTip = $sToolTip & " X Coordinate=Default,"
	EndIf

	If $sY <> "Default" Then
		$sToolTip = $sToolTip & " Y Coordinate=Yes,"
	Else
		$sToolTip = $sToolTip & " Y Coordinate=Default,"
	EndIf

	If GUICtrlRead($txtTTitle) <> "" Then
		$sToolTip = $sToolTip & " Title=Yes,"
	Else
		$sToolTip = $sToolTip & " Title=No,"
	EndIf

	;Icon: 0 = No icon, 1 = Info icon, 2 = Warning icon, 3 = Error Icon
	Switch $iToolTipIcon
		Case 0
			$sToolTip = $sToolTip & " No icon,"
		Case 1
			$sToolTip = $sToolTip & " Info icon,"
		Case 2
			$sToolTip = $sToolTip & " Warning icon,"
		Case 3
			$sToolTip = $sToolTip & " Error icon,"
	EndSwitch

	;Options
	Switch $iToolTipOptions
		Case 1
			$sToolTip = $sToolTip & " Balloon Tip,"
		Case 2
			$sToolTip = $sToolTip & " Center the tip at the x,y coordinates,"
		Case 3
			$sToolTip = $sToolTip & " Balloon Tip/Center the tip at the x,y coordinates,"
	EndSwitch

	$sToolTip = StringTrimRight($sToolTip, 1) ;Remove the last comma
	$sToolTip = $sToolTip & @CRLF

	Return $sToolTip
EndFunc   ;==>_TTComments

;===================================================================================================================================================
;
; Function Name:    _STComments()
; Description:      Set the comment that indicates the features of Splash Text
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  On Success - Returns $sSpashText (Comment string)
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;

Func _STComments()
	;Header of comment
	$sSpashText = "#Region --- CodeWizard generated code Start ---" & @CRLF

	If GUICtrlRead($chkSTConstants) = $GUI_CHECKED Then
		$sSpashText = $sSpashText & "#include <Constants.au3>" & @CRLF & @CRLF
	EndIf

	$sSpashText = $sSpashText & ";SpashText features:"

	If GUICtrlRead($txtSTTitle) <> "" Then
		$sSpashText = $sSpashText & " Title=Yes,"
	Else
		$sSpashText = $sSpashText & " Title=No,"
	EndIf

	If $sText <> "" Then
		$sSpashText = $sSpashText & " Text=Yes,"
	Else
		$sSpashText = $sSpashText & " Text=No,"
	EndIf

	;Position
	If $iWidth <> "-1" Then $sSpashText = $sSpashText & " Width=" & $iWidth & ","
	If $iHeight <> "-1" Then $sSpashText = $sSpashText & " Height=" & $iHeight & ","
	If $iLeft <> "-1" Then $sSpashText = $sSpashText & " Left=" & $iLeft & ","
	If $iTop <> "-1" Then $sSpashText = $sSpashText & " Top=" & $iTop & ","

	;Options
	If GUICtrlRead($chkSTOnTop) = $GUI_CHECKED Then $sSpashText = $sSpashText & " Always On Top,"
	If GUICtrlRead($chkSTWinMove) = $GUI_CHECKED Then $sSpashText = $sSpashText & " Windows can be moved,"
	If GUICtrlRead($chkSTVertical) = $GUI_CHECKED Then $sSpashText = $sSpashText & " Centered vertically text,"
	Select
		Case GUICtrlRead($optJustCenter) = $GUI_CHECKED ; Center Justified
			$sSpashText = $sSpashText & " Center justified text,"
		Case GUICtrlRead($optJustLeft) = $GUI_CHECKED ; Left Justified
			$sSpashText = $sSpashText & " Left justified text,"
		Case GUICtrlRead($optJustRight) = $GUI_CHECKED ; Right Justified
			$sSpashText = $sSpashText & " Right justified text,"
	EndSelect

	;Font
	If GUICtrlRead($txtSTFontName) <> "" Then
		$sSpashText = $sSpashText & " Fontname=" & GUICtrlRead($txtSTFontName) & ","
	Else
		$sSpashText = $sSpashText & " OS default font,"
	EndIf
	If GUICtrlRead($txtSTFontSize) <> "" Then $sSpashText = $sSpashText & " Font size=" & GUICtrlRead($txtSTFontSize) & ","
	If GUICtrlRead($txtSTFontWeight) <> "" Then $sSpashText = $sSpashText & " Font weight=" & GUICtrlRead($txtSTFontWeight) & ","

	$sSpashText = StringTrimRight($sSpashText, 1) ;Remove the last comma
	$sSpashText = $sSpashText & @CRLF

	Return $sSpashText
EndFunc   ;==>_STComments

;===================================================================================================================================================
;
; Function Name:    _SIComments()
; Description:      Set the comment that indicates the features of Splash Image
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  On Success - Returns $sSpashImage (Comment string)
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================
;

Func _SIComments()
	;Header of comment
	$sSpashImage = "#Region --- CodeWizard generated code Start ---" & @CRLF

	If GUICtrlRead($chkSIConstants) = $GUI_CHECKED Then
		$sSpashImage = $sSpashImage & "#include <Constants.au3>" & @CRLF & @CRLF
	EndIf

	$sSpashImage = $sSpashImage & ";SpashImage features:"

	If GUICtrlRead($txtSITitle) <> "" Then
		$sSpashImage = $sSpashImage & " Title=Yes,"
	Else
		$sSpashImage = $sSpashImage & " Title=No,"
	EndIf

	;Position
	If $iWidth <> "-1" Then $sSpashImage = $sSpashImage & " Width=" & $iWidth & ","
	If $iHeight <> "-1" Then $sSpashImage = $sSpashImage & " Height=" & $iHeight & ","
	If $iLeft <> "-1" Then $sSpashImage = $sSpashImage & " Left=" & $iLeft & ","
	If $iTop <> "-1" Then $sSpashImage = $sSpashImage & " Top=" & $iTop & ","

	;Options
	If GUICtrlRead($chkSIOnTop) = $GUI_CHECKED Then $sSpashImage = $sSpashImage & " Always On Top,"
	If GUICtrlRead($chkSIWinMove) = $GUI_CHECKED Then $sSpashImage = $sSpashImage & " Windows can be moved,"

	$sSpashImage = StringTrimRight($sSpashImage, 1) ;Remove the last comma
	$sSpashImage = $sSpashImage & @CRLF

	Return $sSpashImage
EndFunc   ;==>_SIComments

;===================================================================================================================================================
;
; Function Name:    _StopToolTip()
; Description:      Stop ToolTip
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  None
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================

Func _StopToolTip()
	ToolTip("") ; Close ToolTip
	HotKeySet("{ESC}") ; Reset the ESC Key
	TrayTip("clears any tray tip", "", 0)
EndFunc   ;==>_StopToolTip

;===================================================================================================================================================
;
; Function Name:    _StopSplash()
; Description:      Stop Splash Screen
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s):  None
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================

Func _StopSplash()
	SplashOff() ; Close SplashScreen
	HotKeySet("{ESC}") ; Reset the ESC Key
	TrayTip("clears any tray tip", "", 0)
EndFunc   ;==>_StopSplash

;===================================================================================================================================================
;
; Function Name:    _TextConvert($txtText)
; Description:      Convert CRLF Chars of the Text entry field into a string with =>
;					@CRLF macro chars
; Parameter(s):     Text entry field
; Requirement(s):   None
; Return Value(s):  Formatted string for copy function
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================

Func _TextConvert($txtText)
	Local $asText
	$sText = ""

	$asText = StringSplit(GUICtrlRead($txtText), @CRLF, 1)

	If $asText[0] = 1 Then
		$sText = Chr(34) & GUICtrlRead($txtText) & Chr(34)
	Else
		If $asText[1] <> "" Then $sText = Chr(34) & $asText[1] & Chr(34)

		For $iCtr = 2 To $asText[0]
			$sText = $sText & (($asText[$iCtr] = "") ? " & @CRLF" : " & @CRLF & ") & Chr(34) & $asText[$iCtr] & Chr(34)
		Next

	EndIf

	;1st line is blank
	If StringLeft($sText, 3) = " & " Then $sText = StringTrimLeft($sText, 3)

	Return $sText
EndFunc   ;==>_TextConvert

;===================================================================================================================================================
;
; Function Name:    _GetScriptTitle()
; Description:      Find the probable script name
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s): 	Script name
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================

Func _GetScriptTitle()
	Opt("WinTitleMatchMode", $OPT_MATCHANY)
	Local $sTitle = "", $iPosInit, $iPosFin

	If WinExists(".au3") Then
		$sTitle = WinGetTitle(".au3", "")
		If $sTitle <> "0" Then
			$iPosInit = StringInStr($sTitle, "\", 0, -1) + 1
			$iPosFin = StringInStr($sTitle, ".au3", 0, -1)
			Return StringMid($sTitle, $iPosInit, $iPosFin - $iPosInit)
		Else
			Return ""
		EndIf
	Else
		;MsgBox features: Title=Yes, Text=Yes, Buttons=OK, Icon=Critical
		MsgBox($MB_OK + $MB_ICONHAND, "CodeWizard", "No Script Titles (*.au3) found")
		Return ""
	EndIf
EndFunc   ;==>_GetScriptTitle

;===================================================================================================================================================
;
; Function Name:    _EnableDisable($i_bool)
; Description:      -
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s): 	-
; Author(s):        Gary Frost <gary.frost@arnold.af.mil>
;
;===================================================================================================================================================

Func _EnableDisable($i_bool)
	If ($i_bool) Then
		GUICtrlSetState($btnTitle, $GUI_DISABLE)
		GUICtrlSetState($btnPreview, $GUI_DISABLE)
		GUICtrlSetState($btnCopy, $GUI_DISABLE)
		GUICtrlSetState($CTLID, $GUI_ENABLE)
		GUICtrlSetState($CTLID, $GUI_SHOW)
		GUICtrlSetState($CTL_INCLUDE_COMMENTS, $GUI_ENABLE)
		GUICtrlSetState($CTL_INCLUDE_COMMENTS, $GUI_SHOW)
		GUICtrlSetState($CTLTESTINPUT, $GUI_ENABLE)
		GUICtrlSetState($CTLTESTINPUT, $GUI_SHOW)
		GUICtrlSetState($LBL_CFC, $GUI_SHOW)
		GUICtrlSetState($TEST_LABEL, $GUI_SHOW)
		GUICtrlSetState($LV_FILELIST, $GUI_ENABLE)
		GUICtrlSetState($LV_FILELIST, $GUI_SHOW)
	Else
		GUICtrlSetState($btnTitle, $GUI_ENABLE)
		GUICtrlSetState($btnPreview, $GUI_ENABLE)
		GUICtrlSetState($btnCopy, $GUI_ENABLE)
		GUICtrlSetState($CTLID, $GUI_DISABLE)
		GUICtrlSetState($CTLID, $GUI_HIDE)
		GUICtrlSetState($CTL_INCLUDE_COMMENTS, $GUI_DISABLE)
		GUICtrlSetState($CTL_INCLUDE_COMMENTS, $GUI_HIDE)
		GUICtrlSetState($CTLTESTINPUT, $GUI_DISABLE)
		GUICtrlSetState($CTLTESTINPUT, $GUI_HIDE)
		GUICtrlSetState($LBL_CFC, $GUI_HIDE)
		GUICtrlSetState($TEST_LABEL, $GUI_HIDE)
		GUICtrlSetState($LV_FILELIST, $GUI_DISABLE)
		GUICtrlSetState($LV_FILELIST, $GUI_HIDE)
	EndIf
EndFunc   ;==>_EnableDisable

;===================================================================================================================================================
;
; Function Name:    _ContentsHelp()
; Description:      Run Help
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s): 	None
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================

Func _ContentsHelp()
	If ProcessExists("KeyHH.exe") Then ProcessClose("KeyHH.exe")

	;$sAutoItPath = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\AutoIt", "InstallDir")
	If FileExists(@ScriptDir & "\CodeWizard.chm") Then
		Run(@WindowsDir & "\HH.exe " & @ScriptDir & "\CodeWizard.chm::introduction.html")
	Else
		#Region --- CodeWizard generated code Start ---
		;MsgBox features: Title=Yes, Text=Yes, Buttons=OK, Icon=Critical
		MsgBox($MB_ICONERROR, "CodeWizard", "The HelpFile CodeWizard.chm doesn't exist in the directory " & @ScriptDir)
		#EndRegion --- CodeWizard generated code Start ---
	EndIf
EndFunc   ;==>_ContentsHelp

;===================================================================================================================================================
;
; Function Name:    _ContextualsHelp()
; Description:      Run Help
; Parameter(s):     None
; Requirement(s):   None
; Return Value(s): 	None
; Author(s):        Giuseppe Criaco <gcriaco@quipo.it>
;
;===================================================================================================================================================

Func _ContextualHelp()

	If FileExists(@ScriptDir & "\CodeWizard.chm") Then
		Select
			Case GUICtrlRead($TAB) = 0 ;MessageBox Wizard
				Run(@WindowsDir & "\HH.exe " & @ScriptDir & "\CodeWizard.chm::msgbox.html")

			Case GUICtrlRead($TAB) = 1 ;InputBox Wizard
				Run(@WindowsDir & "\HH.exe " & @ScriptDir & "\CodeWizard.chm::inputbox.html")

			Case GUICtrlRead($TAB) = 2 ;ToolTip Wizard
				Run(@WindowsDir & "\HH.exe " & @ScriptDir & "\CodeWizard.chm::tooltip.html")

			Case GUICtrlRead($TAB) = 3 ;SplashText Wizard
				Run(@WindowsDir & "\HH.exe " & @ScriptDir & "\CodeWizard.chm::splashtext.html")

			Case GUICtrlRead($TAB) = 4 ;SplashImage Wizard
				Run(@WindowsDir & "\HH.exe " & @ScriptDir & "\CodeWizard.chm::splashimage.html")

			Case GUICtrlRead($TAB) = 5 ;Colors Wizard
				Run(@WindowsDir & "\HH.exe " & @ScriptDir & "\CodeWizard.chm::colors.html")

			Case GUICtrlRead($TAB) = 6 ;Fonts/Cursors Wizard
				Run(@WindowsDir & "\HH.exe " & @ScriptDir & "\CodeWizard.chm::Fonts/Cursors.html")

		EndSelect
	Else
		#Region --- CodeWizard generated code Start ---
		;MsgBox features: Title=Yes, Text=Yes, Buttons=OK, Icon=Critical
		MsgBox($MB_ICONERROR, "CodeWizard", "The HelpFile CodeWizard.chm doesn't exist in the directory " & @ScriptDir)
		#EndRegion --- CodeWizard generated code Start ---
	EndIf
EndFunc   ;==>_ContextualHelp
#EndRegion Functions
