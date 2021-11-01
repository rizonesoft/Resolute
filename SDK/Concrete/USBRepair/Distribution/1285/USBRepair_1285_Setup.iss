;* USB Repair - Installer script
;* Copyright (C) 2021 Rizonesoft

; Requirements:
; Inno Setup: http://www.jrsoftware.org/isdl.php

; Preprocessor related stuff
#if VER < EncodeVer(5,5,9)
	#error Update your Inno Setup version (5.5.9 or newer)
#endif

#define distrodir "USBRepair_1285"


#define app_version   "8.1.3.1285"
#define app_name      "USB Repair"
#define app_copyright "Copyright (C) 2021 Rizonesoft"
#define quick_launch  "{userappdata}\Microsoft\Internet Explorer\Quick Launch"

[Setup]
AppId={#app_name}
AppName={#app_name}
AppVersion={#app_version}
AppVerName={#app_name} {#app_version}
AppPublisher=Rizonesoft
AppPublisherURL=https://www.rizonesoft.com
AppSupportURL=https://github.com/rizonesoft/Resolute/issues
AppUpdatesURL=https://www.rizonesoft.com/downloads/update/?id=usbrepair
AppContact=https://www.rizonesoft.com/#contact
AppCopyright={#app_copyright}
UninstallDisplayIcon={app}\USBRepair.exe
UninstallDisplayName={#app_name} {#app_version}
DefaultDirName={pf}\Rizonesoft\USB Repair
LicenseFile=USBRepair_1285\Docs\USBRepair\License.txt
OutputDir=.
OutputBaseFilename=USBRepair_1285_Setup
Compression=lzma2/max
InternalCompressLevel=max
SolidCompression=yes
EnableDirDoesntExistWarning=no
AllowNoIcons=yes
ShowTasksTreeLines=yes
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableReadyPage=yes
DisableWelcomePage=yes
AllowCancelDuringInstall=no
MinVersion=6.0
ArchitecturesAllowed=x86 x64
ArchitecturesInstallIn64BitMode=x64
CloseApplications=force
SetupMutex="usbrepair_setup_mutex"

[Languages]
Name: en; MessagesFile: compiler:Default.isl

[Messages]
SetupAppTitle    =Setup - {#app_name}
SetupWindowTitle =Setup - {#app_name}

[CustomMessages]
en.msg_AppIsRunning          =Setup has detected that {#app_name} is currently running.%n%nPlease close all instances of it now, then click OK to continue, or Cancel to exit.
en.msg_AppIsRunningUninstall =Uninstall has detected that {#app_name} is currently running.%n%nPlease close all instances of it now, then click OK to continue, or Cancel to exit.
en.msg_DeleteSettings        =Do you also want to delete {#app_name}'s settings?%n%nIf you plan on installing {#app_name} again then you do not have to delete them.
en.tsk_AllUsers              =For all users
en.tsk_CurrentUser           =For the current user only
en.tsk_Other                 =Other tasks:
en.tsk_ResetSettings         =Reset {#app_name}'s settings
en.tsk_StartMenuIcon         =Create a Start Menu shortcut
en.tsk_LaunchWelcomePage     =Read Important Release Information!

[Tasks]
Name: desktopicon;        Description: {cm:CreateDesktopIcon};     GroupDescription: {cm:AdditionalIcons}; Flags: unchecked
Name: desktopicon\user;   Description: {cm:tsk_CurrentUser};       GroupDescription: {cm:AdditionalIcons}; Flags: unchecked exclusive
Name: desktopicon\common; Description: {cm:tsk_AllUsers};          GroupDescription: {cm:AdditionalIcons}; Flags: unchecked exclusive
Name: startup_icon;       Description: {cm:tsk_StartMenuIcon};     GroupDescription: {cm:AdditionalIcons}
Name: quicklaunchicon;    Description: {cm:CreateQuickLaunchIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked;             OnlyBelowVersion: 6.01
Name: reset_settings;     Description: {cm:tsk_ResetSettings};     GroupDescription: {cm:tsk_Other};       Flags: checkedonce unchecked; Check: SettingsExistCheck()

[Files]
Source: {#distrodir}\USBRepair_X64.exe; DestDir: {app}; DestName: USBRepair.exe; Flags: ignoreversion; Check: Is64BitInstallMode()
Source: {#distrodir}\USBRepair.exe; DestDir: {app}; Flags: ignoreversion; Check: not Is64BitInstallMode()
Source: {#distrodir}\USBRepair.ini; DestDir: {userappdata}\Rizonesoft\USBRepair; Flags: onlyifdoesntexist uninsneveruninstall
Source: {#distrodir}\USBRepair.exe; DestDir: {app}; Flags: ignoreversion
Source: {#distrodir}\USBRepair_X64.exe; DestDir: {app}; Flags: ignoreversion
Source: {#distrodir}\Docs\USBRepair\Changes.txt; DestDir: {app}\Docs\USBRepair; Flags: ignoreversion
Source: {#distrodir}\Docs\USBRepair\License.txt; DestDir: {app}\Docs\USBRepair; Flags: ignoreversion
Source: {#distrodir}\Docs\USBRepair\Readme.txt; DestDir: {app}\Docs\USBRepair; Flags: ignoreversion
Source: {#distrodir}\Language\USBRepair\ar.ini; DestDir: {app}\Language\USBRepair; Flags: ignoreversion
Source: {#distrodir}\Language\USBRepair\en.ini; DestDir: {app}\Language\USBRepair; Flags: ignoreversion
Source: {#distrodir}\Language\USBRepair\ko.ini; DestDir: {app}\Language\USBRepair; Flags: ignoreversion
Source: {#distrodir}\Processing\32\Stroke.ani; DestDir: {app}\Processing\32; Flags: ignoreversion
Source: {#distrodir}\Processing\64\Stroke.ani; DestDir: {app}\Processing\64; Flags: ignoreversion
Source: {#distrodir}\Processing\64\Globe.ani; DestDir: {app}\Processing\64; Flags: ignoreversion

[Dirs]

[Icons]
Name: {commondesktop}\{#app_name}; Filename: {app}\USBRepair.exe; Tasks: desktopicon\common; Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: USBRepair; IconFilename: {app}\USBRepair.exe; IconIndex: 0
Name: {userdesktop}\{#app_name};   Filename: {app}\USBRepair.exe; Tasks: desktopicon\user;   Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: USBRepair; IconFilename: {app}\USBRepair.exe; IconIndex: 0
Name: {userstartmenu}\{#app_name}; Filename: {app}\USBRepair.exe; Tasks: startup_icon;       Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: USBRepair; IconFilename: {app}\USBRepair.exe; IconIndex: 0
Name: {#quick_launch}\{#app_name}; Filename: {app}\USBRepair.exe; Tasks: quicklaunchicon;    Comment: {#app_name} {#app_version}; WorkingDir: {app};                        					IconFilename: {app}\USBRepair.exe; IconIndex: 0

[INI]
Filename: {app}\USBRepair.ini; Section: USBRepair; Key: PortableEdition; String: 0
Filename: {userappdata}\Rizonesoft\USBRepair\USBRepair.ini; Section: USBRepair; Key: PortableEdition; String: 0

[Run]
Filename: {app}\USBRepair.exe; Description: {cm:LaunchProgram,{#app_name}}; WorkingDir: {app}; Flags: nowait postinstall shellexec skipifsilent unchecked

[InstallDelete]
Type: files;      Name: {userdesktop}\{#app_name}.lnk;   Check: not IsTaskSelected('desktopicon\user')   and IsUpgrade()
Type: files;      Name: {commondesktop}\{#app_name}.lnk; Check: not IsTaskSelected('desktopicon\common') and IsUpgrade()
Type: files;      Name: {userstartmenu}\{#app_name}.lnk; Check: not IsTaskSelected('startup_icon')       and IsUpgrade()
Type: files;      Name: {#quick_launch}\{#app_name}.lnk; Check: not IsTaskSelected('quicklaunchicon')    and IsUpgrade(); OnlyBelowVersion: 6.01
Type: files;      Name: {app}\USBRepair.ini

[UninstallDelete]
Type: files;      Name: {app}\USBRepair.ini
Type: dirifempty; Name: {app}

[Code]
const
	UninstSiteURL = 'https://www.rizonesoft.com/uninstalled/';
function IsUpgrade(): Boolean;
	var
	sPrevPath: String;
begin
	sPrevPath := WizardForm.PrevAppDir;
	Result := (sPrevPath <> '');
end;

// Check if USB Repair's settings exist.
function SettingsExistCheck(): Boolean;
begin
	if FileExists(ExpandConstant('{userappdata}\Rizonesoft\USBRepair\USBRepair.ini')) then begin
	Log('Custom Code: Settings are present');
	Result := True;
	end
	else begin
		Log('Custom Code: Settings are NOT present');
		Result := False;
	end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
	// Hide the license page if IsUpgrade()
	if IsUpgrade() and (PageID = wpLicense) then
	Result := True;
end;

procedure CleanUpSettings();
begin
	DeleteFile(ExpandConstant('{userappdata}\Rizonesoft\USBRepair\USBRepair.ini'));
	RemoveDir(ExpandConstant('{userappdata}\Rizonesoft\USBRepair'));
end;

procedure CurPageChanged(CurPageID: Integer);
begin
	if CurPageID = wpSelectTasks then
		WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall)
	else if CurPageID = wpFinished then
		WizardForm.NextButton.Caption := SetupMessage(msgButtonFinish);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
	if CurStep = ssInstall then begin
	if IsTaskSelected('reset_settings') then
		CleanUpSettings();
	end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
	ErrorCode: Integer;
begin
	// When uninstalling, ask the user to delete USB Repair's settings.
	if CurUninstallStep = usUninstall then begin
		if SettingsExistCheck() then begin
			if SuppressibleMsgBox(CustomMessage('msg_DeleteSettings'), mbConfirmation, MB_YESNO or MB_DEFBUTTON2, IDNO) = IDYES then
			CleanUpSettings();
		end;
	end;
end;

procedure InitializeWizard();
begin
	WizardForm.SelectTasksLabel.Hide;
	WizardForm.TasksList.Top    := 0;
	WizardForm.TasksList.Height := PageFromID(wpSelectTasks).SurfaceHeight;
end;
