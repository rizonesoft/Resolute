;* Firemin - Installer script
;* Copyright (C) 2021 Rizonesoft

; Requirements:
; Inno Setup: http://www.jrsoftware.org/isdl.php

; Preprocessor related stuff
#if VER < EncodeVer(5,5,9)
	#error Update your Inno Setup version (5.5.9 or newer)
#endif

#define distrodir "Firemin_5085"


#define app_version   "6.2.3.5085"
#define app_name      "Firemin"
#define app_copyright "Copyright (C) 2021 Rizonesoft"
#define quick_launch  "{userappdata}\Microsoft\Internet Explorer\Quick Launch"

[Setup]
AppId={#app_name}
AppName={#app_name}
AppVersion={#app_version}
AppVerName={#app_name} {#app_version}
AppPublisher=Rizonesoft
AppPublisherURL=https://www.rizonesoft.com
AppSupportURL=https://www.rizonesoft.com/support/
AppUpdatesURL=https://www.rizonesoft.com/downloads/firemin/
AppContact=https://www.rizonesoft.com/contact
AppCopyright={#app_copyright}
UninstallDisplayIcon={app}\Firemin.exe
UninstallDisplayName={#app_name} {#app_version}
DefaultDirName={pf}\Rizonesoft\Firemin
LicenseFile=Firemin_5085\Docs\License.txt
OutputDir=.
OutputBaseFilename=Firemin_5085_Setup
WizardImageFile=compiler:WizModernImage-IS.bmp
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
SetupMutex="firemin_setup_mutex"

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
Source: {#distrodir}\Firemin_X64.exe; DestDir: {app}; DestName: Firemin.exe; Flags: ignoreversion; Check: Is64BitInstallMode()
Source: {#distrodir}\Firemin.exe; DestDir: {app}; Flags: ignoreversion; Check: not Is64BitInstallMode()
Source: {#distrodir}\Firemin.ini; DestDir: {userappdata}\Rizonesoft\Firemin; Flags: onlyifdoesntexist uninsneveruninstall
Source: {#distrodir}\Firemin.exe; DestDir: {app}; Flags: ignoreversion
Source: {#distrodir}\Firemin_X64.exe; DestDir: {app}; Flags: ignoreversion
Source: {#distrodir}\Firemin.ini; DestDir: {app}; Flags: ignoreversion
Source: {#distrodir}\Docs\Changes.txt; DestDir: {app}\Docs; Flags: ignoreversion
Source: {#distrodir}\Docs\License.txt; DestDir: {app}\Docs; Flags: ignoreversion
Source: {#distrodir}\Docs\Readme.txt; DestDir: {app}\Docs; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\af.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\de.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\el.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\en.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\es.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\fa.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\fr.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\hu.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\it.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\ja.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\ko.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\pl.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\pt.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\pt-BR.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\ru.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\sl.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\tr.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\zh-CN.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Language\Firemin\zh-TW.ini; DestDir: {app}\Language\Firemin; Flags: ignoreversion
Source: {#distrodir}\Processing\32\Stroke.ani; DestDir: {app}\Processing\32; Flags: ignoreversion
Source: {#distrodir}\Processing\64\Globe.ani; DestDir: {app}\Processing\64; Flags: ignoreversion

[Dirs]

[Icons]
Name: {commondesktop}\{#app_name}; Filename: {app}\Firemin.exe; Tasks: desktopicon\common; Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: Firemin; IconFilename: {app}\Firemin.exe; IconIndex: 0
Name: {userdesktop}\{#app_name};   Filename: {app}\Firemin.exe; Tasks: desktopicon\user;   Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: Firemin; IconFilename: {app}\Firemin.exe; IconIndex: 0
Name: {userstartmenu}\{#app_name}; Filename: {app}\Firemin.exe; Tasks: startup_icon;       Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: Firemin; IconFilename: {app}\Firemin.exe; IconIndex: 0
Name: {#quick_launch}\{#app_name}; Filename: {app}\Firemin.exe; Tasks: quicklaunchicon;    Comment: {#app_name} {#app_version}; WorkingDir: {app};                        					IconFilename: {app}\Firemin.exe; IconIndex: 0

[INI]
Filename: {app}\Firemin.ini; Section: Firemin; Key: PortableEdition; String: 0
Filename: {userappdata}\Rizonesoft\Firemin\Firemin.ini; Section: Firemin; Key: PortableEdition; String: 0

[Run]
Filename: {app}\Firemin.exe; Description: {cm:LaunchProgram,{#app_name}}; WorkingDir: {app}; Flags: nowait postinstall shellexec skipifsilent unchecked
Filename: "https://www.rizonesoft.com/thank-you/"; Flags: shellexec runasoriginaluser nowait

[InstallDelete]
Type: files;      Name: {userdesktop}\{#app_name}.lnk;   Check: not IsTaskSelected('desktopicon\user')   and IsUpgrade()
Type: files;      Name: {commondesktop}\{#app_name}.lnk; Check: not IsTaskSelected('desktopicon\common') and IsUpgrade()
Type: files;      Name: {userstartmenu}\{#app_name}.lnk; Check: not IsTaskSelected('startup_icon')       and IsUpgrade()
Type: files;      Name: {#quick_launch}\{#app_name}.lnk; Check: not IsTaskSelected('quicklaunchicon')    and IsUpgrade(); OnlyBelowVersion: 6.01
Type: files;      Name: {app}\Firemin.ini

[UninstallDelete]
Type: files;      Name: {app}\Firemin.ini
Type: dirifempty; Name: {app}

[Code]
function IsUpgrade(): Boolean;
	var
	sPrevPath: String;
begin
	sPrevPath := WizardForm.PrevAppDir;
	Result := (sPrevPath <> '');
end;

// Check if Firemin's settings exist.
function SettingsExistCheck(): Boolean;
begin
	if FileExists(ExpandConstant('{userappdata}\Rizonesoft\Firemin\Firemin.ini')) then begin
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
	DeleteFile(ExpandConstant('{userappdata}\Rizonesoft\Firemin\Firemin.ini'));
	RemoveDir(ExpandConstant('{userappdata}\Rizonesoft\Firemin'));
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
begin
	// When uninstalling, ask the user to delete Firemin's settings.
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
