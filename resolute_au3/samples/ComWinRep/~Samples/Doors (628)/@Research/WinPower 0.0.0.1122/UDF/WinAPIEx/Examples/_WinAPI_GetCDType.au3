#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Text, $Type, $Drive = DriveGetDrive('CDROM')

If IsArray($Drive) Then
	For $i = 1 To $Drive[0]
		$Text = 'Unknown'
		$Type = _WinAPI_GetCDType($Drive[$i])
		If Not @error Then
			Switch $Type
				Case 0x0000
					$Text = 'No media'
				Case 0x0008
					$Text = 'CD-ROM'
				Case 0x0009
					$Text = 'CD-R'
				Case 0x000A
					$Text = 'CD-RW'
				Case 0x0010
					$Text = 'DVD-ROM'
				Case 0x0011
					$Text = 'DVD-R SR'
				Case 0x0012
					$Text = 'DVD-RAM'
				Case 0x0013
					$Text = 'DVD-RW RO'
				Case 0x0014
					$Text = 'DVD-RW SR'
				Case 0x0015
					$Text = 'DVD-R DL'
				Case 0x0016
					$Text = 'DVD-R DL JR'
				Case 0x0017
					$Text = 'DVD-RW DL'
				Case 0x0018
					$Text = 'DVD-DDR'
				Case 0x001A
					$Text = 'DVD+RW'
				Case 0x001B
					$Text = 'DVD+R'
				Case 0x0040
					$Text = 'BD-ROM'
				Case 0x0041
					$Text = 'BD-R SRM'
				Case 0x0042
					$Text = 'BD-R RRM'
				Case 0x0043
					$Text = 'BD-RE'
				Case 0x0050
					$Text = 'HD DVD-ROM'
				Case 0x0051
					$Text = 'HD DVD-R'
				Case 0x0052
					$Text = 'HD DVD-RAM'
				Case 0x0053
					$Text = 'HD DVD-RW'
				Case 0x0058
					$Text = 'HD DVD-R DL'
				Case 0x005A
					$Text = 'HD DVD-RW DL'
			EndSwitch
		EndIf
		ConsoleWrite(StringUpper($Drive[$i]) & ' => ' & $Text & @CR)
	Next
EndIf
