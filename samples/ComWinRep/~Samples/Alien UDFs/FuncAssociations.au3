#include-once


#include "CoreFunctions.au3"


Func _RepairMediaAssociations()

	Switch @OSVersion

		Case "WIN_7", "WIN_8", "WIN_81"

			Local $3GPEditFlags

			Switch @OSVersion
				Case "WIN_7"
					$3GPEditFlags = "00001100"
				Case "WIN_8", "WIN_81"
					$3GPEditFlags = "00003100"
			EndSwitch

			_RegistryDelete("HKEY_CLASSES_ROOT\.3g2")
			_RegistryDelete("HKEY_CLASSES_ROOT\.3gp")
			_RegistryDelete("HKEY_CLASSES_ROOT\.3gp2")
			_RegistryDelete("HKEY_CLASSES_ROOT\.3gpp")

			RegWrite("HKEY_CLASSES_ROOT\.3g2", "", "REG_SZ", "WMP11.AssocFile.3G2")
			RegWrite("HKEY_CLASSES_ROOT\.3gp", "", "REG_SZ", "WMP11.AssocFile.3GP")
			RegWrite("HKEY_CLASSES_ROOT\.3gp2", "", "REG_SZ", "WMP11.AssocFile.3G2")
			RegWrite("HKEY_CLASSES_ROOT\.3gpp", "", "REG_SZ", "WMP11.AssocFile.3GP")

			RegWrite("HKEY_CLASSES_ROOT\.3g2", "Content Type", "REG_SZ", "video/3gpp2")
			RegWrite("HKEY_CLASSES_ROOT\.3gp", "Content Type", "REG_SZ", "video/3gpp")
			RegWrite("HKEY_CLASSES_ROOT\.3gp2", "Content Type", "REG_SZ", "video/3gpp2")
			RegWrite("HKEY_CLASSES_ROOT\.3gpp", "Content Type", "REG_SZ", "video/3gpp")

			RegWrite("HKEY_CLASSES_ROOT\.3g2", "PerceivedType", "REG_SZ", "video")
			RegWrite("HKEY_CLASSES_ROOT\.3gp", "PerceivedType", "REG_SZ", "video")
			RegWrite("HKEY_CLASSES_ROOT\.3gp2", "PerceivedType", "REG_SZ", "video")
			RegWrite("HKEY_CLASSES_ROOT\.3gpp", "PerceivedType", "REG_SZ", "video")

			RegWrite("HKEY_CLASSES_ROOT\.3g2\OpenWithProgIds", "WMP11.AssocFile.3GP", "REG_BINARY", "")
			RegWrite("HKEY_CLASSES_ROOT\.3gp\OpenWithProgIds", "WMP11.AssocFile.3GP", "REG_BINARY", "")
			RegWrite("HKEY_CLASSES_ROOT\.3gp2\OpenWithProgIds", "WMP11.AssocFile.3GP", "REG_BINARY", "")
			RegWrite("HKEY_CLASSES_ROOT\.3gpp\OpenWithProgIds", "WMP11.AssocFile.3GP", "REG_BINARY", "")
			Switch @OSVersion
				Case "WIN_8", "WIN_81"
					RegWrite("HKEY_CLASSES_ROOT\.3gp\OpenWithProgids", "AppX55e91fphzr8a583p8cbxv7jpr8bk6xb9", "REG_BINARY", "")
					RegWrite("HKEY_CLASSES_ROOT\.3gp\OpenWithProgids", "AppXhjhjmgrfm2d7rd026az898dy2p1pcsyt", "REG_BINARY", "")
			EndSwitch

			RegWrite("HKEY_CLASSES_ROOT\.3g2\ShellEx\{BB2E617C-0920-11D1-9A0B-00C04FC2D6C1}", "", "REG_SZ", "{9DBD2C50-62AD-11D0-B806-00C04FD706EC}")
			RegWrite("HKEY_CLASSES_ROOT\.3gp\ShellEx\{BB2E617C-0920-11D1-9A0B-00C04FC2D6C1}", "", "REG_SZ", "{9DBD2C50-62AD-11D0-B806-00C04FD706EC}")
			RegWrite("HKEY_CLASSES_ROOT\.3gp2\ShellEx\{BB2E617C-0920-11D1-9A0B-00C04FC2D6C1}", "", "REG_SZ", "{9DBD2C50-62AD-11D0-B806-00C04FD706EC}")
			RegWrite("HKEY_CLASSES_ROOT\.3gpp\ShellEx\{BB2E617C-0920-11D1-9A0B-00C04FC2D6C1}", "", "REG_SZ", "{9DBD2C50-62AD-11D0-B806-00C04FD706EC}")

			RegWrite("HKEY_CLASSES_ROOT\.3g2\ShellEx\{e357fccd-a995-4576-b01f-234630154e96}", "", "REG_SZ", "{9DBD2C50-62AD-11D0-B806-00C04FD706EC}")
			RegWrite("HKEY_CLASSES_ROOT\.3gp\ShellEx\{e357fccd-a995-4576-b01f-234630154e96}", "", "REG_SZ", "{9DBD2C50-62AD-11D0-B806-00C04FD706EC}")
			RegWrite("HKEY_CLASSES_ROOT\.3gp2\ShellEx\{e357fccd-a995-4576-b01f-234630154e96}", "", "REG_SZ", "{9DBD2C50-62AD-11D0-B806-00C04FD706EC}")
			RegWrite("HKEY_CLASSES_ROOT\.3gpp\ShellEx\{e357fccd-a995-4576-b01f-234630154e96}", "", "REG_SZ", "{9DBD2C50-62AD-11D0-B806-00C04FD706EC}")

			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3G2", "", "REG_SZ", "3GPP2 Audio/Video")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3G2", "EditFlags", "REG_BINARY", $3GPEditFlags)
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3G2", "FriendlyTypeName", "REG_EXPAND_SZ", "@%SystemRoot%\system32\unregmp2.exe,-9937")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3G2", "PreferExecuteOnMismatch", "REG_DWORD", 0x00000001)
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3G2\DefaultIcon", "", "REG_EXPAND_SZ" ,"%SystemRoot%\system32\wmploc.dll,-730")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3G2\shell", "", "REG_SZ", "Play")
 			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3G2\shell\Enqueue", "", "REG_SZ", "&Add to Windows Media Player list")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3G2\shell\Enqueue", "MUIVerb", "REG_EXPAND_SZ", "@%SystemRoot%\system32\unregmp2.exe,-9800")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3G2\shell\Enqueue\command", "DelegateExecute", "REG_SZ", "{45597c98-80f6-4549-84ff-752cf55e2d29}")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3G2\shellex\{8895b1c6-b41f-4c1c-a562-0d564250836f}", "", "REG_SZ", "{031EE060-67BC-460d-8847-E4A7C5E45A27}")

			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3GP", "", "REG_SZ", "3GPP2 Audio/Video")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3GP", "EditFlags", "REG_BINARY", $3GPEditFlags)
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3GP", "FriendlyTypeName", "REG_EXPAND_SZ", "@%SystemRoot%\system32\unregmp2.exe,-9937")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3GP", "PreferExecuteOnMismatch", "REG_DWORD", 0x00000001)
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3GP\DefaultIcon", "", "REG_EXPAND_SZ" ,"%SystemRoot%\system32\wmploc.dll,-730")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3GP\shell", "", "REG_SZ", "Play")
 			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3GP\shell\Enqueue", "", "REG_SZ", "&Add to Windows Media Player list")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3GP\shell\Enqueue", "MUIVerb", "REG_EXPAND_SZ", "@%SystemRoot%\system32\unregmp2.exe,-9800")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3GP\shell\Enqueue\command", "DelegateExecute", "REG_SZ", "{45597c98-80f6-4549-84ff-752cf55e2d29}")
			RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3GP\shellex\{8895b1c6-b41f-4c1c-a562-0d564250836f}", "", "REG_SZ", "{031EE060-67BC-460d-8847-E4A7C5E45A27}")
			Switch @OSVersion
				Case "WIN_7"
					RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3G2\shellex\ContextMenuHandlers\PlayTo", "", "REG_SZ", "{7AD84985-87B4-4a16-BE58-8B72A5B390F7}")
					RegWrite("HKEY_CLASSES_ROOT\WMP11.AssocFile.3GP\shellex\ContextMenuHandlers\PlayTo", "", "REG_SZ", "{7AD84985-87B4-4a16-BE58-8B72A5B390F7}")
			EndSwitch

			RegDelete("HKEY_CLASSES_ROOT\SystemFileAssociations\.3g2")
			RegDelete("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gp")
			RegDelete("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gp2")
			RegDelete("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gpp")

			Local Const $3GPInfoTip = "prop:System.ItemType;System.Size;System.Media.Duration;System.OfflineAvailability"
			Local Const $3GPFullDetails = "prop:System.PropGroup.Description;System.Title;System.Media.SubTitle;System.Rating;System.Keywords;" & _
				"System.Comment;System.PropGroup.Video;System.Media.Duration;System.Video.FrameWidth;System.Video.FrameHeight;" & _
				"System.Video.EncodingBitrate;System.Video.TotalBitrate;System.Video.FrameRate;System.PropGroup.Audio;" & _
				"System.Audio.EncodingBitrate;System.Audio.ChannelCount;System.Audio.SampleRate;System.PropGroup.Media;" & _
				"System.Music.Artist;System.Media.Year;System.Music.Genre;System.PropGroup.Origin;System.Video.Director;" & _
				"System.Media.Producer;System.Media.Writer;System.Media.Publisher;System.Media.ContentDistributor;" & _
				"System.Media.DateEncoded;System.Media.EncodedBy;System.Media.AuthorUrl;System.Media.PromotionUrl;" & _
				"System.Copyright;System.PropGroup.Content;System.ParentalRating;System.ParentalRatingReason;" & _
				"System.Music.Composer;System.Music.Conductor;System.Music.Period;System.Music.Mood;System.Music.PartOfSet;" & _
				"System.Music.InitialKey;System.Music.BeatsPerMinute;System.DRM.IsProtected;System.PropGroup.FileSystem;" & _
				"System.ItemNameDisplay;System.ItemType;System.ItemFolderPathDisplay;System.Size;System.DateCreated;" & _
				"System.DateModified;System.FileAttributes;System.OfflineAvailability;System.OfflineStatus;System.SharedWith;" & _
				"System.FileOwner;System.ComputerName"
			Local Const $3GPPreviewDetails = "prop:*System.Title;*System.Media.Duration;*System.Size;*System.Video.FrameWidth;*System.Video.FrameHeight;" & _
				"System.Rating;*System.Keywords;*System.Comment;*System.Music.Artist;*System.Music.Genre;*System.ParentalRating;" & _
				"*System.OfflineAvailability;*System.OfflineStatus;*System.DateModified;*System.DateCreated;*System.SharedWith;" & _
				"*System.Media.SubTitle;*System.Media.Year;*System.Video.FrameRate;*System.Video.EncodingBitrate;" & _
				"*System.Video.TotalBitrate"

			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3g2", "ExtendedTileInfo", "REG_SZ", $3GPInfoTip)
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gp", "ExtendedTileInfo", "REG_SZ", $3GPInfoTip)
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gp2", "ExtendedTileInfo", "REG_SZ", $3GPInfoTip)
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gpp", "ExtendedTileInfo", "REG_SZ", $3GPInfoTip)
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3g2", "FullDetails", "REG_SZ", $3GPFullDetails)
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gp", "FullDetails", "REG_SZ", $3GPFullDetails)
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gp2", "FullDetails", "REG_SZ", $3GPFullDetails)
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gpp", "FullDetails", "REG_SZ", $3GPFullDetails)
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3g2", "InfoTip", "REG_SZ", $3GPInfoTip)
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gp", "InfoTip", "REG_SZ", $3GPInfoTip)
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gp2", "InfoTip", "REG_SZ", $3GPInfoTip)
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gpp", "InfoTip", "REG_SZ", $3GPInfoTip)
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3g2", "PreviewDetails", "REG_SZ", $3GPPreviewDetails)
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gp", "PreviewDetails", "REG_SZ", $3GPPreviewDetails)
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gp2", "PreviewDetails", "REG_SZ", $3GPPreviewDetails)
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gpp", "PreviewDetails", "REG_SZ", $3GPPreviewDetails)

			Switch @OSVersion
				Case "WIN_8", "WIN_81"
					RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3g2\shellex\ContextMenuHandlers\PlayTo", "", "REG_SZ", "{7AD84985-87B4-4a16-BE58-8B72A5B390F7}")
					RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gp\shellex\ContextMenuHandlers\PlayTo", "", "REG_SZ", "{7AD84985-87B4-4a16-BE58-8B72A5B390F7}")
					RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gp2\shellex\ContextMenuHandlers\PlayTo", "", "REG_SZ", "{7AD84985-87B4-4a16-BE58-8B72A5B390F7}")
					RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.3gpp\shellex\ContextMenuHandlers\PlayTo", "", "REG_SZ", "{7AD84985-87B4-4a16-BE58-8B72A5B390F7}")
			EndSwitch

			_RegistryDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.3g2")
			_RegistryDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.3gp")
			_RegistryDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.3gp2")
			_RegistryDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.3gpp")

			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.3g2\OpenWithProgids", "WMP11.AssocFile.3G2", "REG_BINARY", "")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.3gp\OpenWithProgids", "WMP11.AssocFile.3GP", "REG_BINARY", "")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.3gp2\OpenWithProgids", "WMP11.AssocFile.3G2", "REG_BINARY", "")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.3gpp\OpenWithProgids", "WMP11.AssocFile.3GP", "REG_BINARY", "")

			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.3g2\UserChoice", "Progid", "REG_SZ", "WMP11.AssocFile.3G2")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.3gp\UserChoice", "Progid", "REG_SZ", "WMP11.AssocFile.3GP")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.3gp2\UserChoice", "Progid", "REG_SZ", "WMP11.AssocFile.3G2")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.3gpp\UserChoice", "Progid", "REG_SZ", "WMP11.AssocFile.3GP")

	EndSwitch

EndFunc


