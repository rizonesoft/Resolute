================================
CodeWizard  ver 1.5.4.0 6/19/2016
================================

Generate code according to the user choices for the following functions:
- Message Box
- Input Box
- ToolTip
- SplashText
- SplashImage
- GUISetBkColor
- GUICtrlSetColor
- GUICtrlSetBkColor
- GUICtrlSetFont
- GUICtrlSetCursor

It merges the previous CodeWizard script (by Giuseppe Criaco) with the CFCCodeWizard (by Gary Frost).
 
 
Requirements:
- AutoIt v.3.3.14.2


How to install:
- Scite users: CodeWizard is included in the SciTe for AutoIt package. If you got a newer version extract the compressed files into the %Program Files%\AutoIt3\SciTe\CodeWizard folder.
- Non SciTe users: extract the compressed files wherever you want.


ChangeLog: 
1.5.4.0: 6/19/2016 (updated by Cyberyeye)
- Fix Icon Ressource Number for Messagebox Tab & ToolTip Tab
- Check/Fix missing includes using AutoIt3Wrapper_Add_Constants=y
- Added Opt("MustDeclareVars", 1) to fix undeclared variables
- Replaced msgbox() magic number by constant name
- Added GUISetIcon var (au3.ico)
- Removed unusefull old AutoIt3Wrapper directive

------------------------

1.3.5 beta 4/30/2005
- Changed: CFCCodeWizard Merged with CodeWizard

1.3.6 beta 5/3/2005
- Changed: No longer need external dll for setting fonts and colours.
- Changed: Misc UDFs now used

1.4 5/12/2005
- Added: Helpfile

1.5 19/12/2005
- Added: ToolTip function

1.5.1 15/1/2006
- Added: SplashText option 32 "Centered vertically text"

1.5.2 11/19/2006
- Changed: update the context help being keyhh.exe no longer installed with autoit
- Changed: Indentation of generated code with @Tab (previously 3 blank chars)
- Changed: "Dim" => "Local" in generated code

ChangeLog (CFCCodeWizard):
1.0 - 3/16/2005
- Initial release (HexCodeWizard)

1.1 - 3/17/2005
- Added: the GUICtrlSetFont (Gets the list of fonts from the registry (using regedit export), then weeds out other than ttf fonts)
- Added: dim statements to code generationg
- Fixed: font problem, created variable for font file
- Fixed: array size for greens color selection

1.1.1 - 3/18/2005
- Changed: the name of the script to CFCCodeWizard

1.2.0 - 3/20/2005
- Added: control id input box
- Added: comment blocks to code generation

1.2.1 - 3/23/2005
- Added: Tabs
- Added: 264 colors
- Added: About Box
- Fixed: comment block for GUICtrlSetCursor

1.2.2 - 3/24/2005
- Added: check box for comment block comment block by default is not included
- Fixed: comment blocks to work with SciTE
- Changed: declaration to see if already declared.
- Changed: Color schemes no longer hard coded, now reside in colors.ini (place ini file in same folder as script/exe)

1.3 - 3/25/2005
- Added: check for colors.ini exists at script dir location if not then msgbox pops up and script terminated
- Changed: registry export from regedit to reg
- Removed: variables no longer needed and code no longer needed (Clean-up)

1.3.1 - 3/26/2005
- Changed: the Hypyerlink to use the _INetMail Function from Inet.au3
- Changed: Shortened code for _SetCursorValue function from 34 lines of code to 4 lines of code
- Changed: Split Colors Tab to Control Colors Tab and GUI Colors Tab
- Removed: code to get fonts from registry
- Added: code from CodeWizard for font dialog

1.3.2 - 3/28/2005
- Fixed: sample text being changed when setting control colors

1.3.3 - 4/6/2005
- Added: grid lines to list view in extended styles, doing this took away the sunken look
- Added: border around list view in extended styles
- Added: drag and drop of headers in extended styles, now can switch which column is first/last
- Added: Just for fun picture filling in the portion of the window where the Exit button resides

1.3.4 beta 4/26/2005
- Added: Color Dialogs for controls and gui
- Changed: Replaced functions with <GuiListView.au3> function calls from 3.1.1.16


ChangeLog (old CodeWizard):
1.0 - 2/6/2005
- Initial release

1.1 - 2/8/2005
- Fixed: MsgBox right-justified attribute 5244288 => 524288
- Changed: "Miscellaneous" radio buttons => checkboxes (any combination of top-most/right-justified attributes are possible)
- Added: Resource Info (version, description,...) in the exe file
- Added: #Region....#EndRegion around the generated code lines

1.1.1 - 2/9/2005
- Fixed: "InputBox features:" => ";InputBox features:"
- Fixed: no more blank lines when copy text to console
- Changed: quit the script after copy to console

1.2 - 3/18/2005
- Added: SplashTextOn code generator

1.2.1 - 3/25/2005
- Added: Automatically detect the AutoIt Script Title by the "Title" button
- Fixed: "AU3xtra.dll missing" error when called by the SciTe editor

1.3 - 4/1/2005
- Added: SplashImageOn code generator
- Changed: MsgBox generated code:   Dim $iMsgBoxAnswer   => If Not IsDeclared("iMsgBoxAnswer") Then Dim $iMsgBoxAnswer (thanks to gafrost)
- Changed: InputBox generated code: Dim $sInputBoxAnswer => If Not IsDeclared("sInputBoxAnswer") Then Dim $sInputBoxAnswer (thanks to gafrost)

1.3.1 - 4/11/2005
- Fixed: If double quotes were used in Titles, code was generated incorrectly (thanks to gafrost) 
  Exceptions: *strange* use of double/single quotes - i.e. Title: "CodeWizard'. No corrections to Texts (too lazy ;-)
- Changed: no more blank lines in Text fields => empty string in the code (thanks to gafrost) - i.e.: 
  MsgBox(0,"CodeWizard","1st line" & @CRLF & "" & @CRLF & "3d line") => MsgBox(0,"CodeWizard","1st line" & @CRLF & @CRLF & "3d line")
- Added: MessageBox Constants "$IDTRYAGAIN" and "$IDCONTINUE" to the Copy function

------------------------------------------------------------------------------------------------------------------

Authors: Giuseppe Criaco <gcriaco@quipo.it>,Gary Frost <custompcs@charter.net>