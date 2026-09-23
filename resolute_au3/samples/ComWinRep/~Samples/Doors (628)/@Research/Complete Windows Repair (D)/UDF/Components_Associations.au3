#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Rizonesoft (Derick Payne)

 Script Function:
	File Type Association Functions

#ce ----------------------------------------------------------------------------


#include-once
#include <CoreWinRepair.au3>


Func _RestoreAniAssociations()

	_StartLogging("Restoring default .ani file associations, please wait...")
	Switch @OSVersion
		Case "WIN_7"
			RegDelete("HKEY_CLASSES_ROOT\.ani")
			RegWrite("HKEY_CLASSES_ROOT\.ani", "", "REG_SZ", "anifile")
			RegDelete("HKEY_CLASSES_ROOT\anifile")
			RegWrite("HKEY_CLASSES_ROOT\anifile", "", "REG_SZ", "Animated Cursor")
			RegWrite("HKEY_CLASSES_ROOT\anifile", "FriendlyTypeName","REG_EXPAND_SZ", "@%SystemRoot%\system32\main.cpl,-2000")
			RegWrite("HKEY_CLASSES_ROOT\anifile\DefaultIcon", "", "REG_SZ", "%1")
			RegDelete("HKEY_CLASSES_ROOT\SystemFileAssociations\.ani")
			RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ani")
			_BroadcastChange()
		Case Else
			_MemoLoggingWrite("Unsupported Operating System", 3)
			_EndLogging()
			Return
	EndSwitch
	_MemoLoggingWrite("Hope your computer still works.", 1)
	_EndLogging()

EndFunc


Func _RestoreAsfAssociations()

	_StartLogging("Restoring default .asf file associations, please wait...")
	Switch @OSVersion
		Case "WIN_7"
			RegWrite("HKEY_CLASSES_ROOT\.asf", "", "REG_SZ", "WMP11.AssocFile.ASF")
			RegWrite("HKEY_CLASSES_ROOT\.asf", "PerceivedType", "REG_SZ", "video")
			RegWrite("HKEY_CLASSES_ROOT\.asf", "Content Type", "REG_SZ", "video/x-ms-asf")
			RegWrite("HKEY_CLASSES_ROOT\.asf\OpenWithProgIds", "WMP11.AssocFile.ASF", "REG_BINARY", "")
			RegWrite("HKEY_CLASSES_ROOT\.asf\PersistentHandler", "", "REG_SZ", "{098f2470-bae0-11cd-b579-08002b30bfeb}")
			RegWrite("HKEY_CLASSES_ROOT\.asf\ShellEx\{BB2E617C-0920-11D1-9A0B-00C04FC2D6C1}", "", "REG_SZ", "{9DBD2C50-62AD-11D0-B806-00C04FD706EC}")
			RegWrite("HKEY_CLASSES_ROOT\.asf\ShellEx\{e357fccd-a995-4576-b01f-234630154e96}", "", "REG_SZ", "{9DBD2C50-62AD-11D0-B806-00C04FD706EC}")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASF", "", "REG_SZ", "Windows Media Audio/Video file")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASF", "EditFlags", "REG_BINARY", "00001100")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASF", "FriendlyTypeName", "REG_EXPAND_SZ", "@%SystemRoot%\system32\unregmp2.exe,-9909")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASF", "PreferExecuteOnMismatch", "REG_DWORD", 0x00000001)
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASF\DefaultIcon", "", "REG_EXPAND_SZ", "%SystemRoot%\system32\wmploc.dll,-730")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASF\Library")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASF\shell", "", "REG_SZ", "Play")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASF\shell\Enqueue", "", "REG_SZ", "&Add to Windows Media Player list")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASF\shell\Enqueue", "MUIVerb", "REG_EXPAND_SZ", "@%SystemRoot%\system32\unregmp2.exe,-9800")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASF\shell\Enqueue\command", "DelegateExecute", "REG_SZ", "{45597c98-80f6-4549-84ff-752cf55e2d29}")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASF\shellex\{8895b1c6-b41f-4c1c-a562-0d564250836f}", "", "REG_SZ", "{031EE060-67BC-460d-8847-E4A7C5E45A27}")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASF\VideoClipContainer", "", "REG_SZ", "{5CDCB131-A1A1-4FE9-9A10-80EFFE042AE0}")
			RegDelete("HKEY_CLASSES_ROOT\SystemFileAssociations\.asf")
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.asf", "InfoTip", "REG_SZ", "prop:System.ItemType;System.Size;System.Media.Duration;System.OfflineAvailability")
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.asf", "ExtendedTileInfo", "REG_SZ", "prop:System.ItemType;System.Size;System.Media.Duration;System.OfflineAvailability")
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.asf", "FullDetails", "REG_SZ", "prop:System.PropGroup.Description;System.Title;System.Media.SubTitle;System.Rating;System.Keywords;System.Comment;System.PropGroup.Video;System.Media.Duration;System.Video.FrameWidth;System.Video.FrameHeight;System.Video.EncodingBitrate;System.Video.TotalBitrate;System.Video.FrameRate;System.PropGroup.Audio;System.Audio.EncodingBitrate;System.Audio.ChannelCount;System.Audio.SampleRate;System.PropGroup.Media;System.Music.Artist;System.Media.Year;System.Music.Genre;System.PropGroup.Origin;System.Video.Director;System.Media.Producer;System.Media.Writer;System.Media.Publisher;System.Media.ContentDistributor;System.Media.DateEncoded;System.Media.EncodedBy;System.Media.AuthorUrl;System.Media.PromotionUrl;System.Copyright;System.PropGroup.Content;System.ParentalRating;System.ParentalRatingReason;System.Music.Composer;System.Music.Conductor;System.Music.Period;System.Music.Mood;System.Music.PartOfSet;System.Music.InitialKey;System.Music.BeatsPerMinute;System.DRM.IsProtected;System.PropGroup.FileSystem;System.ItemNameDisplay;System.ItemType;System.ItemFolderPathDisplay;System.Size;System.DateCreated;System.DateModified;System.FileAttributes;System.OfflineAvailability;System.OfflineStatus;System.SharedWith;System.FileOwner;System.ComputerName")
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.asf", "PreviewDetails", "REG_SZ", "prop:*System.Title;*System.Media.Duration;*System.Size;*System.Video.FrameWidth;*System.Video.FrameHeight;System.Rating;*System.Keywords;*System.Comment;*System.Music.Artist;*System.Music.Genre;*System.ParentalRating;*System.OfflineAvailability;*System.OfflineStatus;*System.DateModified;*System.DateCreated;*System.SharedWith;*System.Media.SubTitle;*System.Media.Year;*System.Video.FrameRate;*System.Video.EncodingBitrate;*System.Video.TotalBitrate")
			RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.asf")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.asf\OpenWithList", "a", "REG_SZ", "wmplayer.exe")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.asf\OpenWithList", "MRUList", "REG_SZ", "ba")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.asf\OpenWithList", "b", "REG_SZ", "DVDMaker.exe")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.asf\OpenWithProgids", "WMP11.AssocFile.ASF", "REG_BINARY", "")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.asf\UserChoice")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.asf\UserChoice", "Progid", "REG_SZ", "WMP11.AssocFile.ASF")
			_BroadcastChange()

		Case Else
			_MemoLoggingWrite("Unsupported Operating System", 3)
			_EndLogging()
			Return

	EndSwitch
	_MemoLoggingWrite("Hope your computer still works.", 1)
	_EndLogging()

EndFunc


Func _RestoreAspxAssociations()

	_StartLogging("Restoring default .aspx file associations, please wait...")
	Switch @OSVersion
		Case "WIN_7"
			RegDelete("HKEY_CLASSES_ROOT\.aspx")
			RegWrite("HKEY_CLASSES_ROOT\.aspx", "PerceivedType", "REG_SZ", "text")
			RegWrite("HKEY_CLASSES_ROOT\.aspx\PersistentHandler", "", "REG_SZ", "{eec97550-47a9-11cf-b952-00aa0051fe20}")
			RegDelete("HKEY_CLASSES_ROOT\SystemFileAssociations\.aspx")
			RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.aspx")
			_BroadcastChange()

		Case Else
			_MemoLoggingWrite("Unsupported Operating System", 3)
			_EndLogging()
			Return
	EndSwitch
	_MemoLoggingWrite("Hope your computer still works.", 1)
	_EndLogging()

EndFunc


Func _RestoreAsxAssociations()

	_StartLogging("Restoring default .asx file associations, please wait...")
	Switch @OSVersion
		Case "WIN_7"
			RegDelete("HKEY_CLASSES_ROOT\.asx")
			RegWrite("HKEY_CLASSES_ROOT\.asx", "PerceivedType", "REG_SZ", "video")
			RegWrite("HKEY_CLASSES_ROOT\.asx", "", "REG_SZ", "WMP11.AssocFile.ASX")
			RegWrite("HKEY_CLASSES_ROOT\.asx", "Content Type", "REG_SZ", "video/x-ms-asf")
			RegWrite("HKEY_CLASSES_ROOT\.asx\OpenWithList\ehshell.exe")
			RegWrite("HKEY_CLASSES_ROOT\.asx\OpenWithProgIds", "WMP11.AssocFile.ASX", "REG_BINARY", "")
			RegWrite("HKEY_CLASSES_ROOT\.asx\PersistentHandler", "", "REG_SZ", "{5e941d80-bf96-11cd-b579-08002b30bfeb}")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASX", "", "REG_SZ", "Windows Media Audio/Video playlist")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASX", "EditFlags", "REG_BINARY", "00001100")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASX", "FriendlyTypeName", "REG_EXPAND_SZ", "@%SystemRoot%\system32\unregmp2.exe,-9910")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASX", "PreferExecuteOnMismatch", "REG_DWORD", 0x00000001)
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASX\DefaultIcon", "", "REG_EXPAND_SZ", "%SystemRoot%\system32\wmploc.dll,-730")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASX\shell", "", "REG_SZ", "Play")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASX\shell\Enqueue", "", "REG_SZ", "&Add to Windows Media Player list")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASX\shell\Enqueue", "MUIVerb", "REG_EXPAND_SZ", "@%SystemRoot%\system32\unregmp2.exe,-9800")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.ASX\shell\Enqueue\command", "DelegateExecute", "REG_SZ", "{45597c98-80f6-4549-84ff-752cf55e2d29}")
			RegDelete("HKEY_CLASSES_ROOT\SystemFileAssociations\.asx")
			RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.asx")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.asx\OpenWithProgids", "WMP11.AssocFile.ASX", "REG_BINARY", "")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.asx\UserChoice","Progid","REG_SZ","WMP11.AssocFile.ASX")
			_BroadcastChange()

		Case Else
			_MemoLoggingWrite("Unsupported Operating System", 3)
			_EndLogging()
			Return
	EndSwitch
	_MemoLoggingWrite("Hope your computer still works.", 1)
	_EndLogging()

EndFunc