#include-once


#include <FileConstants.au3>
#include "ReBar_AutoIt3Script.au3"


Global $g_ReBarProgName = FileGetVersion(@ScriptFullPath, $FV_PRODUCTNAME)
Global $g_ReBarShortName = _AutoIt3Script_GetFilename(@ScriptFullPath)
Global $g_ReBarCompName = FileGetVersion(@ScriptFullPath, $FV_COMPANYNAME)
Global $g_ReBarExitCode = 0
Global $g_ReBarDebug = 1

;===============================================================================================================
; Title Options
;===============================================================================================================
Global $g_ReBarTitleShowAdmin = 1
Global $g_ReBarTitleShowAutoIt = 1
Global $g_ReBarTitleShowArch = 1
Global $g_ReBarTitleShowVersion = 1
Global $g_ReBarTitleShowBuild = 1

;===============================================================================================================
; Runtime Options (When not Compiled)
;===============================================================================================================
Global $g_ReBarRunCompName = "Rizonesoft"
Global $g_ReBarRunProgName = "ReBar Framework"
Global $g_ReBarRunIcon = @ScriptDir & "\Themes\Icons\ReBar.ico"
Global $g_ReBarRunIconHover = @ScriptDir & "\Themes\Icons\ReBarH.ico"
Global $g_ReBarRunVersion = 0

;===============================================================================================================
; Path Options
;===============================================================================================================
Global $g_ReBarWorkingDir = @ScriptDir
Global $g_ReBarIniFileName = $g_ReBarShortName & ".ini"
Global $g_ReBarPathIni = $g_ReBarWorkingDir & "\" & $g_ReBarIniFileName
Global $g_ReBarAppDataParent = @AppDataDir & "\" & $g_ReBarCompName
Global $g_ReBarAppDataPath = $g_ReBarAppDataParent & "\" & $g_ReBarShortName

;===============================================================================================================
; Caching Options
;===============================================================================================================
Global $g_ReBarCacheEnabled = 1
Global $g_ReBarCacheBase = $g_ReBarWorkingDir & "\Cache"
Global $g_ReBarCachePath = $g_ReBarCacheBase & "\" & $g_ReBarShortName

;===============================================================================================================
; Update Options
;===============================================================================================================
Global $g_ReBarUpdateURL
Global $g_ReBarUpdateGUI
Global $g_ReBarUpdateURLBase = "http://www.rizonesoft.com/update/"
Global $g_ReBarUpdateRemote = $g_ReBarUpdateURLBase & $g_ReBarShortName & ".ru"
Global $g_ReBarUpdateLocal = $g_ReBarCachePath & "\" & $g_ReBarShortName & ".ru"

;===============================================================================================================
; Logging Options
;===============================================================================================================
Global Const $g_ReBarLogName = $g_ReBarCompName & " " & $g_ReBarProgName & " Logging System"
Global Const $g_ReBarLogVersion = "1.2"

Global $g_ReBarLogFileWrite = 0
Global $g_ReBarLogEnabled = 1														;~ Enable/Disable ReBar logging subsystem.
Global $g_ReBarLogStorage = 5242880 ; Bytes
Global $g_ReBarLogFilename = $g_ReBarShortName & ".log"
Global $g_ReBarLogBase = $g_ReBarWorkingDir & "\Logging"
Global $g_ReBarLogPath = $g_ReBarLogBase & "\" & $g_ReBarLogFilename

;===============================================================================================================
; Interface Options
;===============================================================================================================
Global $g_ReBarCoreGui
Global $g_ReBarGuiTitle = "ReBar Framework 0"
Global $g_ReBarSingleton = True														;~ Only one instance of the program may be running.
Global $g_ReBarGuiIcon
Global $g_ReBarIcon = @ScriptFullPath
Global $g_ReBarIconHover = @ScriptFullPath
Global $g_ReBarIcoHovering = 0
Global $g_ReBarFormWidth = 750
Global $g_ReBarFormHeight = 530
Global $g_ReBarFontName = "Verdana"													;~ Main GUI Font
Global $g_ReBarFontSize = 8.5														;~ Main GUI Font Size
Global $g_ReBarMsgTimeout = 60														;~ Time in seconds a message should be shown before closing.
Global $g_ReBarGuiMinWidth = 300
Global $g_ReBarGuiMinHeight = 300

;===============================================================================================================
; Splash Options
;===============================================================================================================
Global $g_ReBarSplashEnable = True													;~ Enable/Disable splash page on program load.
Global $g_ReBarSplashAni = @ScriptDir & "\Themes\Processing\32\Stroke.ani"

;===============================================================================================================
; Resource Options
;===============================================================================================================
Global $g_ReBarResFugue = @ScriptDir & "\Fugue.dll"
Global $g_ReBarResDoors = @ScriptDir & "\DoorsShell.dll"

;===============================================================================================================
; About Dialog Options
;===============================================================================================================
;Global Const $REBAR_ABOUT_LINK = "https://www.rizonesoft.com"

Global $g_ReBarAboutGui																;~ About Dialog
Global $g_ReBarAboutMenu															;~ About Dialog Menu Item
Global $g_ReBarAboutButton
Global $g_ReBarAboutHome = "http://www.rizonesoft.com"
Global $g_ReBarAboutCredits =	"Derick Payne (Rizonesoft), Brian J Christy (Beege), " & _
								"G Sandler (MrCreatoR), Holger Kotsch, KaFu, LarsJ, nickston, ProgAndy, Yashied"
Global $g_ReBarAboutDonate = "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7UGGCSDUZJPFE"
Global $g_ReBarAboutCountry = "http://www.rizonesoft.com"
Global $g_ReBarAboutFacebook = "https://www.facebook.com/rizonesoft"
Global $g_ReBarAboutTwitter = "https://twitter.com/rizonesoft"
Global $g_ReBarAboutGoogle = "https://plus.google.com/+Rizonesoftsa/posts"
Global $g_ReBarAboutLinkedIn = "https://www.linkedin.com/in/rizonesoft"
Global $g_ReBarAboutRSS = "http://www.rizonesoft.com/feed/"
Global $g_ReBarAboutSupport = "http://www.rizonesoft.com"