#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Bus, $Text, $Drive = DriveGetDrive('ALL')

For $i = 1 To $Drive[0]
	$Bus = _WinAPI_GetDriveBusType($Drive[$i])
	Switch $Bus
		Case $DRIVE_BUS_TYPE_UNKNOWN
			$Text = 'UNKNOWN'
		Case $DRIVE_BUS_TYPE_SCSI
			$Text = 'SCSI'
		Case $DRIVE_BUS_TYPE_ATAPI
			$Text = 'ATAPI'
		Case $DRIVE_BUS_TYPE_ATA
			$Text = 'ATA'
		Case $DRIVE_BUS_TYPE_1394
			$Text = '1394'
		Case $DRIVE_BUS_TYPE_SSA
			$Text = 'SSA'
		Case $DRIVE_BUS_TYPE_FIBRE
			$Text = 'FIBRE'
		Case $DRIVE_BUS_TYPE_USB
			$Text = 'USB'
		Case $DRIVE_BUS_TYPE_RAID
			$Text = 'RAID'
		Case $DRIVE_BUS_TYPE_ISCSI
			$Text = 'ISCSI'
		Case $DRIVE_BUS_TYPE_SAS
			$Text = 'SAS'
		Case $DRIVE_BUS_TYPE_SATA
			$Text = 'SATA'
		Case $DRIVE_BUS_TYPE_SD
			$Text = 'SD'
		Case $DRIVE_BUS_TYPE_MMC
			$Text = 'MMC'
	EndSwitch
	ConsoleWrite(StringUpper($Drive[$i]) & ' => ' & $Text & @CR)
Next
