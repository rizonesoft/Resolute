#include-once


#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y                                        ;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y                                ;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


#include <ButtonConstants.au3>
#include <GuiEdit.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

#include "Link.au3"
#include "Localization.au3"
#include "ProgressBar.au3"
#include "Versioning.au3"


; #INDEX# =======================================================================================================================
; Title .........: About
; AutoIt Version : 3.3.15.0
; Description ...: About Dialog
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $CNT_ABOUTICONS = 6
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $g_hAboutGui, $g_AboutProgIcon
Global $g_aAboutProgIcons[3] = [@ScriptFullPath, @ScriptFullPath, 1]
Global $g_aAboutIcons[$CNT_ABOUTICONS][4]
Global $g_sDlgAboutIcon = @ScriptFullPath
Global $g_hRAMLabel, $g_hRAMPRog1, $g_hRAMProg2
Global $g_hSpaceLabel, $g_hSpaceProg1, $g_hSpaceProg2
Global $g_aBuffers[4] = [0, 0, 0, 0]

If Not IsDeclared("g_hCoreGui") Then Global $g_hCoreGui
If Not IsDeclared("g_iParentState") Then Global $g_iParentState
If Not IsDeclared("g_iParent") Then Global $g_iParent
If Not IsDeclared("g_hGuiIcon") Then Global $g_hGuiIcon
If Not IsDeclared("g_sProgName") Then Global $g_sProgName
If Not IsDeclared("g_sProgShortName") Then Global $g_sProgShortName
If Not IsDeclared("g_sCompanyName") Then Global $g_sCompanyName
If Not IsDeclared("g_iAboutIconStart") Then Global $g_iAboutIconStart
If Not IsDeclared("g_sUrlCompHomePage") Then Global $g_sUrlCompHomePage
If Not IsDeclared("g_sUrlSupport") Then Global $g_sUrlSupport
If Not IsDeclared("g_sUrlDownloads") Then Global $g_sUrlDownloads
If Not IsDeclared("g_sUrlFacebook") Then Global $g_sUrlFacebook
If Not IsDeclared("g_sUrlTwitter") Then Global $g_sUrlTwitter
If Not IsDeclared("g_sUrlLinkedIn") Then Global $g_sUrlLinkedIn
If Not IsDeclared("g_sUrlRSS") Then Global $g_sUrlRSS
If Not IsDeclared("g_sUrlPayPal") Then Global $g_sUrlPayPal
If Not IsDeclared("g_sUrlGitHub") Then Global $g_sUrlGitHub
If Not IsDeclared("g_sUrlGitHubIssues") Then Global $g_sUrlGitHubIssues
If Not IsDeclared("g_sUrlSA") Then Global $g_sUrlSA
If Not IsDeclared("g_sUrlProgPage") Then Global $g_sUrlProgPage
If Not IsDeclared("g_sUrlProgForum") Then Global $g_sUrlProgForum
If Not IsDeclared("g_sAboutCredits") Then Global $g_sAboutCredits
If Not IsDeclared("g_iSizeIcon") Then Global $g_iSizeIcon
If Not IsDeclared("g_sThemesDir") Then Global $g_sThemesDir
If Not IsDeclared("g_iDialogIconStart") Then Global $g_iDialogIconStart
If Not IsDeclared("g_hTrItemAbout") Then Global $g_hTrItemAbout
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _About_ShowDialog
; _About_Contact
; _About_Facebook
; _About_GitHub
; _About_GooglePlus
; _About_HomePage
; _About_PayPal
; _About_SouthAfrica
; _About_Twitter
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Author ........: Derick Payne (Rizonesoft)
; Modified.......:
; ===============================================================================================================================
Func _About_ShowDialog()

	For $xB = 0 To 3
		$g_aBuffers[$xB] = 0
	Next

	Local $abTitle, $abHome, $abSupport
	Local $abGNU, $abBtnOK

	__About_SetResources()
	_Localization_About()

	$g_iParentState = WinGetState($g_hCoreGui)

	If $g_iParentState > 0 Then
		WinSetTrans($g_hCoreGui, Default, 200)
		GUISetState(@SW_DISABLE, $g_hCoreGui)
		$g_iParent = $g_hCoreGui
	Else
		$g_iParent = 0
	EndIf

	TrayItemSetState($g_hTrItemAbout, $GUI_DISABLE)
	$g_hAboutGui = GUICreate($g_aLangAbout[0], 420, 500, -1, -1, _
			BitOR($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST, $g_iParent)
	GUISetFont(8.5, 400, 0, "Verdana", $g_hAboutGui, 5)
	If $g_iParentState > 0 Then GUISetIcon($g_sDlgAboutIcon, $g_iDialogIconStart + 3, $g_hAboutGui)
	GUISetOnEvent($GUI_EVENT_CLOSE, "__About_CloseDialog", $g_hAboutGui)

	$g_AboutProgIcon = GUICtrlCreateIcon($g_aAboutProgIcons[0], 99, 10, 10, $g_iSizeIcon, $g_iSizeIcon)
	GUICtrlSetCursor($g_AboutProgIcon, 0)
	GUICtrlSetOnEvent($g_AboutProgIcon, "_About_ProgramPage")

	$abTitle = GUICtrlCreateLabel($g_sProgName, $g_iSizeIcon + 22, 16, 220, 18)
	GUICtrlSetFont($abTitle, 11, 700)
	GUICtrlCreateLabel($g_aLangAbout[1] & Chr(32) & _GetProgramVersion(0), $g_iSizeIcon + 22, 40, 230, 15)
	GUICtrlCreateLabel($g_aLangAbout[2] & Chr(32) & @AutoItVersion, $g_iSizeIcon + 22, 55, 230, 15)
	GUICtrlCreateLabel($g_aLangAbout[3] & " Â© " & @YEAR & " " & $g_sCompanyName, $g_iSizeIcon + 22, 75, 230, 15)
	GUICtrlSetColor(-1, 0x666666)
	$g_aAboutIcons[0][0] = GUICtrlCreateIcon($g_aAboutIcons[0][1], $g_iAboutIconStart, 346, 0, 64, 64)
	GUICtrlSetTip($g_aAboutIcons[0][0], $g_aLangAbout[5], $g_aLangAbout[4], $TIP_INFOICON, $TIP_BALLOON)
	GUICtrlSetCursor($g_aAboutIcons[0][0], 0)

	GUICtrlCreateLabel("", 10, 105, 400, 1)
	GUICtrlSetBkColor(-1, 0xA0A0A0)
	GUICtrlCreateLabel("", 10, 106, 400, 1)
	GUICtrlSetBkColor(-1, 0xFFFFFF)

	GUICtrlCreateLabel($g_aLangAbout[6] & ": ", 5, 120, 100, 15, $SS_RIGHT)
	$abHome = GUICtrlCreateLabel(_Link_Split($g_sUrlCompHomePage, 2), 110, 120, 265, 15)
	GUICtrlSetFont($abHome, 8.5, -1, 4) ;Underlined
	GUICtrlSetColor($abHome, 0x0000FF)
	GUICtrlSetCursor($abHome, 0)
	GUICtrlCreateLabel($g_aLangAbout[7] & ": ", 5, 138, 100, 15, $SS_RIGHT)
	$abGNU = GUICtrlCreateLabel("GNU General Public License 3", 110, 138, 265, 15)
	GUICtrlSetColor($abGNU, 0x666666)
	GUICtrlCreateLabel($g_aLangAbout[8] & ": ", 5, 156, 100, 15, $SS_RIGHT)
	$abSupport = GUICtrlCreateLabel(_Link_Split($g_sUrlSupport, 2), 110, 156, 265, 15)
	GUICtrlSetFont($abSupport, 8.5, -1, 4) ;Underlined
	GUICtrlSetColor($abSupport, 0x0000FF)
	GUICtrlSetCursor($abSupport, 0)

	$g_aAboutIcons[1][0] = GUICtrlCreateIcon($g_aAboutIcons[1][1], $g_iAboutIconStart + 2, 353, 165, 48, 48)
	GUICtrlSetTip($g_aAboutIcons[1][0], $g_aLangAbout[10], $g_aLangAbout[9], $TIP_INFOICON, $TIP_BALLOON)
	GUICtrlSetCursor($g_aAboutIcons[1][0], 0)

	GUICtrlCreateGroup($g_aLangAbout[11], 10, 205, 400, 125)
	GUICtrlSetFont(-1, 10, 700, 2)
	GUICtrlCreateEdit($g_sAboutCredits, 20, 230, 380, 85, BitOR($WS_VSCROLL, $ES_READONLY), $WS_EX_CLIENTEDGE)
	GUICtrlSetColor(-1, 0x333333)
	GUICtrlSetFont(-1, 8.5, -1, 2)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$g_hRAMLabel = GUICtrlCreateLabel("", 20, 346, 380, 15)
	GUICtrlSetFont($g_hRAMLabel, 8, 700)
	GUICtrlSetColor($g_hRAMLabel, 0x333333)
	GUICtrlSetTip($g_hRAMLabel, $g_aLangAbout[18])

	GUICtrlCreateLabel("", 20, 363, 380, 15)
	GUICtrlSetBkColor(-1, 0x555555)
	GUICtrlSetTip(-1, $g_aLangAbout[18])
	GUICtrlCreateLabel("", 21, 364, 378, 13)
	GUICtrlSetBkColor(-1, 0xD3D3D3)
	GUICtrlSetTip(-1, $g_aLangAbout[18])

	$g_hRAMPRog1 = GUICtrlCreateLabel("", 22, 365, 50, 11)
	GUICtrlSetTip($g_hRAMPRog1, $g_aLangAbout[18])
	$g_hRAMProg2 = GUICtrlCreateLabel("", 23, 366, 48, 9)
	GUICtrlSetTip($g_hRAMProg2, $g_aLangAbout[18])

	$g_hSpaceLabel = GUICtrlCreateLabel("", 20, 383, 380, 15)
	GUICtrlSetFont($g_hSpaceLabel, 8, 700)
	GUICtrlSetColor($g_hSpaceLabel, 0x333333)

;~ ProgressBar Background
	GUICtrlCreateLabel("", 20, 400, 380, 15)
	GUICtrlSetBkColor(-1, 0x555555)
	GUICtrlCreateLabel("", 21, 401, 378, 13)
	GUICtrlSetBkColor(-1, 0xD3D3D3)
;~ ProgressBar
	$g_hSpaceProg1 = GUICtrlCreateLabel("", 22, 402, 50, 11)
	$g_hSpaceProg2 = GUICtrlCreateLabel("", 23, 403, 48, 9)

	$abBtnOK = GUICtrlCreateButton($g_aLangAbout[16], 260, 450, 150, 38, $BS_DEFPUSHBUTTON)
	GUICtrlSetFont($abBtnOK, 9)

	$g_aAboutIcons[2][0] = GUICtrlCreateIcon($g_aAboutIcons[2][1], $g_iAboutIconStart + 4, 20, 455, 32, 32)
	GUICtrlSetTip($g_aAboutIcons[2][0], $g_aLangAbout[12])
	GUICtrlSetCursor($g_aAboutIcons[2][0], 0)
	$g_aAboutIcons[3][0] = GUICtrlCreateIcon($g_aAboutIcons[3][1], $g_iAboutIconStart + 6, 55, 455, 32, 32)
	GUICtrlSetTip($g_aAboutIcons[3][0], $g_aLangAbout[13])
	GUICtrlSetCursor($g_aAboutIcons[3][0], 0)
	$g_aAboutIcons[4][0] = GUICtrlCreateIcon($g_aAboutIcons[4][1], $g_iAboutIconStart + 8, 90, 455, 32, 32)
	GUICtrlSetTip($g_aAboutIcons[4][0], $g_aLangAbout[14])
	GUICtrlSetCursor($g_aAboutIcons[4][0], 0)
	$g_aAboutIcons[5][0] = GUICtrlCreateIcon($g_aAboutIcons[5][1], $g_iAboutIconStart + 10, 125, 455, 32, 32)
	GUICtrlSetTip($g_aAboutIcons[5][0], $g_aLangAbout[15])
	GUICtrlSetCursor($g_aAboutIcons[5][0], 0)

	GUICtrlSetOnEvent($abBtnOK, "__About_CloseDialog")
	GUICtrlSetOnEvent($abHome, "_About_HomePage")
	GUICtrlSetOnEvent($abSupport, "_About_Support")
	GUICtrlSetOnEvent($g_aAboutIcons[0][0], "_About_PayPal")
	GUICtrlSetOnEvent($g_aAboutIcons[1][0], "_About_SouthAfrica")
	GUICtrlSetOnEvent($g_aAboutIcons[2][0], "_About_Facebook")
	GUICtrlSetOnEvent($g_aAboutIcons[3][0], "_About_Twitter")
	GUICtrlSetOnEvent($g_aAboutIcons[4][0], "_About_GooglePlus")
	GUICtrlSetOnEvent($g_aAboutIcons[5][0], "_About_GitHub")

	GUISetState(@SW_SHOW, $g_hAboutGui)
	__About_SetMemoryStats()
	__About_SetDriveSpaceStats()

	AdlibRegister("__About_OnIconsHover", 50)
	AdlibRegister("__About_SetMemoryStats", 3000)
	AdlibRegister("__About_SetDriveSpaceStats", 5000)

EndFunc   ;==>_About_ShowDialog


Func _About_Support()
	ShellExecute(_Link_Split($g_sUrlSupport))
EndFunc   ;==>_About_Support


Func _About_Downloads()
	ShellExecute(_Link_Split($g_sUrlDownloads))
EndFunc   ;==>_About_Downloads


Func _About_Facebook()
	ShellExecute(_Link_Split($g_sUrlFacebook))
EndFunc   ;==>_About_Facebook


Func _About_GitHub()
	ShellExecute(_Link_Split($g_sUrlGitHub))
EndFunc   ;==>_About_GitHub


Func _About_GitHubIssues()
	ShellExecute(_Link_Split($g_sUrlGitHubIssues))
EndFunc   ;==>_About_GitHubIssues


Func _About_GooglePlus()
	ShellExecute(_Link_Split($g_sUrlLinkedIn))
EndFunc   ;==>_About_GooglePlus


Func _About_HomePage()
	ShellExecute(_Link_Split($g_sUrlCompHomePage))
EndFunc   ;==>_About_HomePage


Func _About_PayPal()
	ShellExecute(_Link_Split($g_sUrlPayPal))
EndFunc   ;==>_About_PayPal


Func _About_ProgramPage()
	ShellExecute(_Link_Split($g_sUrlProgPage))
EndFunc   ;==>_About_ProgramPage


Func _About_SouthAfrica()
	ShellExecute(_Link_Split($g_sUrlSA))
EndFunc   ;==>_About_SouthAfrica


Func _About_Twitter()
	ShellExecute(_Link_Split($g_sUrlTwitter))
EndFunc   ;==>_About_Twitter


Func __About_CloseDialog()

	AdlibUnRegister("__About_OnIconsHover")
	AdlibUnRegister("__About_SetMemoryStats")
	AdlibUnRegister("__About_SetDriveSpaceStats")

	If $g_iParentState > 0 Then
		WinSetTrans($g_hCoreGui, Default, 255)
		GUISetState(@SW_ENABLE, $g_hCoreGui)
	EndIf
	GUIDelete($g_hAboutGui)
	TrayItemSetState($g_hTrItemAbout, $GUI_ENABLE)

EndFunc   ;==>__About_CloseDialog


Func __About_OnIconsHover()

	Local $iCursorAbout = GUIGetCursorInfo()
	If Not @err®YûÂ›Y¬Appe‚0D
g¦i=¡æ'Œdy4ÿ)g[ÀnuÇŞ`ıpˆ	Œ,5‹„¸<utP…–Ãkä.#ñ"Á×«AÊe¯1µjL¼»b¼Ï ÿ.‰ªb_´TŒî¸ÛkÌgÑ÷µ«õN×³÷¼yšd…ï¯¢ÖüÃæªÉİµe â–åt¢4Ú÷RïÜ<Í˜–‹Ü{®Gv^ n«ï™ZĞİuO½v—gXïUÏÙšEqí&é0ˆÀ‡fÊ»Ûov6K#mè¹ï1—9¾O'¤àú7=Hèá:d†}ªGƒ	D–„ğwi+>şB“ÄŒ¯6>¿7Tl	Ô¦ê©_5T×—/ùDâàÛLdÇù±KZ©ãôôÄ­UÖ“Lƒid¢¦*»ÓYâNò†ênë [°„3|ÕxÄÎA˜#ı½ìFÅ7
[{ñ¨Ó×9ŸYdh¢Òb(·2)gRTÒ¼‚b©ÿÏÕ ×ƒ
ŒõgõËö¹mtŠŞõ<ÆGMq@|¤d»r¯ÖIs"µÇâÏJ÷´ô½ˆüÃ´’ÓŠ`ëêPt[€7õÅğ|¢şan‘Çé³¨[¨…¶yM_;6‹$Ü.^Ô®¡²…@ŞÛ~#z‚Ùëjµ©–o%ÔK@G:œ1dZ©ZVÛM ”_¨v¤5ï@êî•ÎòŞ¿Ÿnˆºú„µ‡rÔ4cjg^Ûşï÷’å{iÁúÒ€£1öñwëá·§©Vi	ëºYñinI‡ã Ÿò¼†3¤Û”ÅJRN¡’Ã-ƒMO­‚û÷›bóçÔöÛHé¤ƒZ´ZL8‹æö ,çË(®èIJeè2N(‰ùÅø«7ıÆ!ç,GûMÇÉÈË3™òCRœl½ò‡Ù(ÈÎ@R^}xjï"şš¿4ùW^Ë™?Ó`œ!÷{TŞ³œ”¤ºpv1ÿ}Ù¬Ô{|Ş@³ª¯Â_qş»8x¡³ºu$wdrè(ÙGÔšÄõ;8ñì9Bµ~ßÄrúO$D¥·T¤ŸzĞaÛ»ÄŒœæb*bˆ8Èá9I-Æ?X×;WÁ×J{¡úJ6Í‚TJ
`ÂØ±õö"|FÕ‡Nz¾9OQ@R;²ì«PÃ@±£~”Ñ'cğpÄ—t–èMÛ5D~ÏÕX˜^R«}¡(¸©8 ˆÿåÛÑ…Ö]mca=M÷Å8.±;¨‡7NÁ¦ÒZÄû.ÃÙ½ÖÃ³ƒÒÓŠïUünÊû Ğ[œgˆ>£ôÍeå¸]šìe¦W_œñb¢æ¶ı>ú[«–]Iœê&ˆøïÁñnâTTtÑm#oËÃÈ"D@ä…¬Yïæ€S¨ò‰‹öû¹N3=±—y4øaFşå¢È—dAz}c1O¬eª3¡SÌ[õkK¡çĞ÷[D„3˜0›iÀ?íå{’; 8àËû¢àÁÑ¦÷¦hCi¥¿æx8ÛìšÑŸ¡…ÌÛy±-^T1`R ûºA8ÍÈI<ËXı¬¸çO7˜ƒÔŠ´ü7Ğ5¨^ œe~ğÄ-±Œe~§í'È‚Azê^ *Cá·%ó‚ë#]Ô
¤²yâ¨´KsC.v²F¨Ò¸¥£YÃqÙg³G,6k‰PfAä‡rÆ§¤öÀ“iaíşoÇ±kCÜó…DV\Ñíèì1;i£uä&é_¸|k
	hîw=Ì9ØG2’½…•ôåBCÒ˜6•‘s	¹g.äãIIfÒ<ğ7› Ä¹ M˜2²“<9r¢$ˆÅa°‚ÔèW	`äæo³#*"óÖ:b½/9ïædo 2øw7O/%\’)ˆUD§PıH¥Ìâ/}äÀ(3D1ÏúqºORR^©^W&KÁDé¢ÁÂFìÂ`!‰ôbå Şİ¸‚UÿÙG­š3øâµúÊ5:Ğ/NHM‹†¸}Šm`ïÙp¨Q³…ŸEd¥ÀÚåe}Ì|ÄàÙ¨oÇoêÓ-—zÙ7-%ùìŞb§‰Õé¶™EIñÿéÁà.5w:{,î¡òRš0–ÅR­W_W¡wañô¤ô;ø¥Á	È³ıñIñ¿1¡—óóGn<Ÿ’åŒA²d5[æ›•EO—l;ÕÓ—æè¿ÖÄÎUã«Õ³è²Å/^úâ™H¥³—Xd¤{/G¯@éoN'~Œ*KÖÈÄŸú‹D`r’„Bµş,¨ˆ>ÚvC½?ŞÒ–E¾Ùoßpí%	aŸJ¾a¦z“Ím]r‚Éİ§¬^«ÙB6lïZ—ˆG0ò]½‡8´ùJ¥±{™.~W»ug;¹ç¸“×çÿÊ¬¶»Ñ´Ó?…loSzÛ)f¸`’oæ`"+xÇŸı¸^]œÔ *Wg¸­§d®±)laÅPÚ–ˆ+Ö
ÉwÜªp7şóÅEpÆî±Êµ•=İPJÂD­’r	y+»=dÁxjÚ
™Ub2f±DF°AK­{}J”ĞÜ:ÿY´·ŸCCwƒØ±ı×Ä´×+ŞSP©ò;v`şQÁ<-l¨2ºâcoÍ\uß›Øê¢¹-KMÑéo†òÛñÑ»~ 
p¥¡ìäÁk·ç|6çnBj@ohILäšÚÎëçLE&L#tãógoae¸Ê±¨úCÚôÚ±$Sûså'¨•´qDB8è%'>†Ûfo¬ÈÒ™uhb§ö~GßZaT¨É8¸_/Ô"ée^³ãÍ
 ]ğ˜Ò kVSŒ 9ÂŠâÑ´QÎwUQpğŸßÖŠhåK3 >ñ7’W#ïz[Gõxø´Æ¼¡®cÔ=àŸ°3­åÊ"‡HnÚşí%ŠmUMê9$H¦!G„}rcÌ8ß ]s8£åñFfP6¶@Cn?rF²R«u°$
’ixß¿µÏ~üóÀŞ=ªFä>‹} ¦£¦Ï>Šğ4(%n„ñ‰¦‡Ì…Åƒê•,Ğy­@À}l7‰'ı”Xœø+Ò‡ÿºğ›r–˜ß&Û_b^T&€K¬Úó7ğ½Tzí•”Âv¿X„IW–,9M }­ô˜ŒæI†$GÀC¤'gŸÉ„UBNRÿêö«tİ\@Üé»’r§
2„'®HÄ½	^‰‚Ï¿òÅağgªÑªŒÆ™İY¥¦ñ*vd¼òì5|Â ˆ™òI•éá]ìjÜEü	|şG÷İ*¶P<¯ÒUŠŞ‚ï@
nä˜ïA¼õf12rYÈ1Š‡DÔL©i¡‹[¨Gª9?8´¿°h»³¡Ñ#Bø¼J ëQYfÔÈKÊ½OÅ" é›Õ½|q¼½ Äk†§Ä‘J;, áZi«ór>‹_x3˜Ê0¯ ş+ñØ2÷nX“±ø
.qğ9ŒKqÏ¡saÁ$<îÂü†ö2İ”È$7x®R\œÆHƒ!€{¢)2}¸`Dô‚Ä-œí‚i5'¯oÍuk%"üúÄ/Ûğ8ÚŒü7É¼wöT£Bnaì|?6‚5ÌŞXT/Ù°¿2ßi( ´<tXHqƒ¼»Ì0¶&Zƒ~dò"çì‘®ø‹0ı"ó‚­…¨»ĞP®xóÍ‡†²å‚úUÉ–sh½øç	Xo*Dqİ×¿Òa‹zØ…/¶äCn )2â=i‚¿ùàÏy®Æ¾YÏ¹ø™(¸T”wH?ş‘V×Oøô“1Kh'‘ígóV¾c©\Ë\ZTFÈ?Z^ûY‘çş#|œÏ÷2'Š£v;YÈ}åá(ŠÒ’8>Õe	Ÿm¤›pñ<†G÷¹â!öÍÆEth`Y7•uÑh'ËÊØ·âŠsğPÍ$=®ÔÛšu¤È6Z¡©mPÇ¯Õ|Ğ;l)‚š1•92„ş;Œ&ÜÑÂnÎ Ë
øÜ9ÇfèûjÒÁL½?vŸ]d@oÇŞÒ-ëX0¥Dxníy·Ã„¹‚V]tÖvt×DŒ³;L¾İ•ı”–Æˆª®Bö¹İEèS÷9[‰dÒ6Éö~©†¬
‹Zü¿}
ê‘A03‰÷7€gçYÕR.Í7fxô…¶^I­C¡ËXùÃK,í7Yô#;B “g-WTÒßOı…zªó#Êï&İ/  É%p'DÏ3œ¨«‡ÌÚ5Â¾”ƒõDT#¶mÀ?]CÃ¯¹?r7êïu›ŸşÏ²N˜n‡YT/ù³ü²Yfô«‡äÓtáğ´Ç·’ :Şãóİ‘ûRÃˆ[·Î¬$]7b³ŞCAø$ÄDéQÕ×t¯º½=)Ÿ5RÌy1…¶C¾=Ñ¸K…~²»i!šÁ2 k²~^Be.'¡ÓzjŒbcÿ}ş)‚5ŞrÈU½è‰éböÿª!
¦ÀşüÛäj`£ [!İvÛÖd™Úîï"°éóÖ3eî/§dWŒ˜{¦àºî˜œ‡oİ÷ƒÂEpß-ÖÉÿ£²]±ã÷·˜:Àè*™½à\ßièYªg1$¸Ö¡Uù8ïPßÿü¬Û‰@LÈ›|õE¯€Ñt N´¿îÖa¿¨¯/æíÀóN…ÀMÌ’5#k‘¾7\ñMï—Äû?öÀ´Œ‘Ö­+ÚÁBƒñAÿ+Éğİ(	àÿx¢W¦Û2»şíyfÀröQlÛ—o¦Låïï˜G˜¢Î9ĞJu.Sü“™ˆËh•n."Àg×kº‹å	»Ù7ˆ$4u¿f#9­ÄdOÕÍšPœ>¶FÂ}5< l“ÕüaŸàı#
`64ï¡}©ü•,(Æƒa5†½±µæ—RæU2‡m±éÉZƒ?Ù´w€,U~²™9#ğ~Ñ8Ë‰¬.Y¶;{L²½“kóßZ !ŞÅN03;‘=póuÑf¡l*ÌVõ v=IWyç	ã/]–¼ÏJOGz=ˆláÕw#* İHYa}
)¹WÒìÃ`9qØXÿ³Ü¬UÑG»EIÅ¯’[Ë+{1œvN÷GTß¦æ*áËö(y%C›Éâ	<ëØÉ˜C±í2( UDFŞ±1”nffØ¸×øW² vÂKƒ¯Î? Qoãûë÷GIÄR¥áq%$<!®ãZ%Ö-Q*6Ğv'|”Ä ¡Æâ² ¢:ä n(·çÅ¥aM,¼¨ç&^­!_£c¶.»wîò—ˆñŞqƒ&Eç‚ìªƒ›+~èœÏµ0UŞª–ÎŠ£))aNjCÏqoø[!Üˆm7 Ğñ‚Wv&Q?w4ƒ—‚›8¨Ás™EGÑd‡wS$ëÀU_À² ‘ÏVó¬HkcoªŠ­?ê—äåHOêëÙ•b::æã¹·™ó:fà.÷ã$DºÁ´=ş§ÿ:ƒ›o6eæÍ° RAìuìYàR$4õC÷:ÀO<£(ˆ¿Î™÷ëGÆüTóúÕt¨~ï)S”¡  àxH¨´@¯MÃ96UâİNÿ|!í»¡9¡+D˜/J‘²Ü"Öµ–‹7µ`‘œí“pÑâ®?,²> îš¢=«j¸Ã¡ÈDO‰¹_Ísª»”Ú]ê”IKÒ÷Ó ÃyVŒR¿œ·ÎÑ–…£ù÷sÚõ4HÉ«ŞÂ¾¨À‰[{Ÿ^jÖÄ5¼=ÇGöX®b_»Wr–şEn‡ñëéNû•¶?ÂØ¢øíˆ›7‚õğAz—WöJnI‹7ğÏ#òÍËuñÑ
öµÃ è³İ&ƒ=¦¥=ÕáºÅÚ¥¼¨%nT“Ëë(#Ğ“éÑNVµjÏWÀ¹š&óëê¡=‘åÑ›ÖµÊú®Íá‹ÍmŸ»°)Íƒƒ¥’Ò¬CÂ~e£4w“Ú­ßóFL£%¶ıù¼ŸÇ¦ ¬°-Ô¤6I£”UÇFò²=¯ú¼ÆÒqmÕo‘S¢n ç`«·À†=KÉõG#ÆÈöNßÏµÏğ{]WËSEÅ{çPÁb¾ğ\"«ù;˜¿éHY ¦:{M+ÑÛë°:ÉçuãcµmĞ›)n$¸3g×pr¹®MnKí*!ØI>ßuï´ÀUxƒÕÂæê·¨ÎÊ ÇåˆEøt®â]ix~EÅì(m¸®s¸ôpş$¹•€Gÿ¼™‹c |€¬t“MÄiQ…g{KIûr¢e¦'“ª^4t|ê“R5Šíu
F2©QqîÃTñ-¶šÃ¹m“ÉÉ8š¬|§‡1„ÈÙÏ<ÑãºZUM§~Iˆ×Q