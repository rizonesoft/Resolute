;* Firemin Server - Installer script
;* Copyright (C) 2021 Rizonesoft

; Requirements:
; Inno Setup: http://www.jrsoftware.org/isdl.php

; Preprocessor related stuff
#if VER < EncodeVer(5,5,9)
	#error Update your Inno Setup version (5.5.9 or newer)
#endif

#define distrodir "FireminPro_5393"


#define app_version   "8.2.3.5393"
#define app_name      "Firemin Server"
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
AppUpdatesURL=https://www.rizonesoft.com/downloads/update/?id=fireminpro
AppContact=https://www.rizonesoft.com/#contact
AppCopyright={#app_copyright}
UninstallDisplayIcon={app}\FireminPro.exe
UninstallDisplayName={#app_name} {#app_version}
DefaultDirName={pf}\Rizonesoft\Firemin Server
LicenseFile=FireminPro_5393\Docs\FireminPro\License.txt
OutputDir=.
OutputBaseFilename=FireminPro_5393_Setup
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
SetupMutex="fireminpro_setup_mutex"

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
Source: {#distrodir}\FireminPro_X64.exe; DestDir: {app}; DestName: FireminPro.exe; Flags: ignoreversion; Check: Is64BitInstallMode()
Source: {#distrodir}\FireminPro.exe; DestDir: {app}; Flags: ignoreversion; Check: not Is64BitInstallMode()
Source: {#distrodir}\FireminPro.ini; DestDir: {userappdata}\Rizonesoft\FireminPro; Flags: onlyifdoesntexist uninsneveruninstall
Source: {#distrodir}\FireminPro.exe; DestDir: {app}; Flags: ignoreversion
Source: {#distrodir}\FireminPro_X64.exe; DestDir: {app}; Flags: ignoreversion
Source: {#distrodir}\Docs\FireminPro\Changes.txt; DestDir: {app}\Docs\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Docs\FireminPro\License.txt; DestDir: {app}\Docs\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Docs\FireminPro\Readme.txt; DestDir: {app}\Docs\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\af.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\ar.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\de.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\el.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\en.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\es.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\fa.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\fr.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\hu.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\it.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\ja.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\ko.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\pl.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\pt.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\pt-BR.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\ru.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\sl.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\tr.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\zh-CN.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Language\FireminPro\zh-TW.ini; DestDir: {app}\Language\FireminPro; Flags: ignoreversion
Source: {#distrodir}\Processing\32\Stroke.ani; DestDir: {app}\Processing\32; Flags: ignoreversion
Source: {#distrodir}\Processing\64\Globe.ani; DestDir: {app}\Processing\64; Flags: ignoreversion

[Dirs]

[Icons]
Name: {commondesktop}\{#app_name}; Filename: {app}\FireminPro.exe; Tasks: desktopicon\common; Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: FireminPro; IconFilename: {app}\FireminPro.exe; IconIndex: 0
Name: {userdesktop}\{#app_name};   Filename: {app}\FireminPro.exe; Tasks: desktopicon\user;   Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: FireminPro; IconFilename: {app}\FireminPro.exe; IconIndex: 0
Name: {userstartmenu}\{#app_name}; Filename: {app}\FireminPro.exe; Tasks: startup_icon;       Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: FireminPro; IconFilename: {app}\FireminPro.exe; IconIndex: 0
Name: {#quick_launch}\{#app_name}; Filename: {app}\FireminPro.exe; Tasks: quicklaunchicon;    Comment: {#app_name} {#app_version}; WorkingDir: {app};                        					IconFilename: {app}\FireminPro.exe; IconIndex: 0

[INI]
Filename: {app}\FireminPro.ini; Section: FireminPro; Key: PortableEdition; String: 0
Filename: {userappdata}\Rizonesoft\FireminPro\FireminPro.ini; Section: FireminPro; Key: PortableEdition; String: 0

[Run]
Filename: {app}\FireminPro.exe; Description: {cm:LaunchProgram,{#app_name}}; WorkingDir: {app}; Flags: nowait postinstall shellexec skipifsilent unchecked

[InstallDelete]
Type: files;      Name: {userdesktop}\{#app_name}.lnk;   Check: not IsTaskSelected('desktopicon\user')   and IsUpgrade()
Type: files;      Name: {commondesktop}\{#app_name}.lnk; Check: not IsTaskSelected('desktopicon\common') and IsUpgrade()
Type: files;      Name: {userstartmenu}\{#app_name}.lnk; Check: not IsTaskSelected('startup_icon')       and IsUpgrade()
Type: files;      Name: {#quick_launch}\{#app_name}.lnk; Check: not IsTaskSelected('quicklaunchicon')    and IsUpgrade(); OnlyBelowVersion: 6.01
Type: files;      Name: {app}\FireminPro.ini

[UninstallDelete]
Type: files;      Name: {app}\FireminPro.ini
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

// Check if Firemin Server's settings exist.
function SettingsExistCheck(): Boolean;
begin
	if FileExists(ExpandConstant('{userappdata}\Rizonesoft\FireminPro\FireminPro.ini')) then begin
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
	DeleteFile(ExpandConstant('{userappdata}\Rizonesoft\FireminPro\FireminPro.ini'));
	RemoveDir(ExpandConstant('{userappdata}\Rizonesoft\FireminPro'));
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
	// When uninstalling, ask the user to delete Firemin Server's settings.
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
