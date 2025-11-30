#include-once

; #INDEX# =======================================================================================================================
; Title .........: Complete Windows Repair Core Constants
; AutoIt Version : 3.3.12.0
; Language ......: English
; Description ...: Constants to be included in 'Complete Windows Repair' AutoIt scripts.
; Author(s) .....: Derick Payne
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================

; Design time configuration constants
Global Const $CONF_DEBUG = 1
Global Const $CONF_MSGTIMEOUT = 20
Global Const $CONF_LINESPACING = 20
Global Const $CONF_LOGGINGSTORAGE = 5242880 ; Bytes

; Application constants
Global Const $PROG_NAME = "Doors"

; Directory constants
Global Const $DIR_BIN = @ScriptDir & "\Doors\Bin"
Global Const $DIR_DATA = @ScriptDir & "\Doors\Data\Doors"
Global Const $DIR_LOGGING = @ScriptDir & "\Doors\Logging\Doors"
Global Const $DIR_TEMP = @ScriptDir & "\Doors\Temp"
Global Const $DIR_THEMES = @ScriptDir & "\Doors\Data\Doors"

; File constants
Global Const $FILE_LOGGING = $DIR_LOGGING & "\Doors.log"
Global Const $FILE_PROGANI = $DIR_THEMES & "\Stroke.ani"

; Logging constants
Global Const $LOGSYS_NAME = "Rizonesoft Doors Logging System"
Global Const $LOGSYS_VERSION = "1.2"

; ===============================================================================================================================