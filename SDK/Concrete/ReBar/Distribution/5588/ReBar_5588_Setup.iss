;* ReBar Framework - Installer script
;* Copyright (C) 2025 Rizonesoft

; Requirements:
; Inno Setup: http://www.jrsoftware.org/isdl.php

; Preprocessor related stuff
#if VER < EncodeVer(5,5,9)
	#error Update your Inno Setup version (5.5.9 or newer)
#endif

#define distrodir "ReBar_5588"


#define app_version   "11.1.0.5588"
#define app_name      "ReBar Framework"
#define app_copyright "Copyright (C) 2025 Rizonesoft"
#define quick_launch  "{userappdata}\Microsoft\Internet Explorer\Quick Launch"

[Setup]
AppId={#app_name}
AppName={#app_name}
AppVersion={#app_version}
AppVerName={#app_name} {#app_version}
AppPublisher=Rizonesoft
AppPublisherURL=https://www.rizonesoft.com
AppSupportURL=https://www.rizonesoft.com/contact-us/
AppUpdatesURL=https://www.rizonesoft.com/downloads/resolute/update/
AppContact=https://www.rizonesoft.com/contact-us/
AppCopyright={#app_copyright}
UninstallDisplayIcon={app}\ReBar.exe
UninstallDisplayName={#app_name} {#app_version}
DefaultDirName={pf}\Rizonesoft\ReBar Framework
LicenseFile=ReBar_5588\Docs\ReBar\License.txt
OutputDir=.
OutputBaseFilename=ReBar_5588_Setup
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
SetupMutex="rebar_setup_mutex"

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
Source: {#distrodir}\ReBar_X64.exe; DestDir: {app}; DestName: ReBar.exe; Flags: ignoreversion; Check: Is64BitInstallMode()
Source: {#distrodir}\ReBar.exe; DestDir: {app}; Flags: ignoreversion; Check: not Is64BitInstallMode()
Source: {#distrodir}\ReBar.ini; DestDir: {userappdata}\Rizonesoft\ReBar; Flags: onlyifdoesntexist uninsneveruninstall
Source: {#distrodir}\ReBar.exe; DestDir: {app}; Flags: ignoreversion
Source: {#distrodir}\ReBar_X64.exe; DestDir: {app}; Flags: ignoreversion
Source: {#distrodir}\Docs\ReBar\Changes.txt; DestDir: {app}\Docs\ReBar; Flags: ignoreversion
Source: {#distrodir}\Docs\ReBar\License.txt; DestDir: {app}\Docs\ReBar; Flags: ignoreversion
Source: {#distrodir}\Docs\ReBar\Readme.txt; DestDir: {app}\Docs\ReBar; Flags: ignoreversion
Source: {#distrodir}\Language\ReBar\en.ini; DestDir: {app}\Language\ReBar; Flags: ignoreversion
Source: {#distrodir}\Processing\16\Process.ani; DestDir: {app}\Processing\16; Flags: ignoreversion
Source: {#distrodir}\Processing\32\Stroke.ani; DestDir: {app}\Processing\32; Flags: ignoreversion
Source: {#distrodir}\Processing\64\Stroke.ani; DestDir: {app}\Processing\64; Flags: ignoreversion
Source: {#distrodir}\Processing\64\Globe.ani; DestDir: {app}\Processing\64; Flags: ignoreversion
Source: {#distrodir}\Sounds\Complete.wav; DestDir: {app}\Sounds; Flags: ignoreversion
Source: {#distrodir}\Sounds\Welcome.wav; DestDir: {app}\Sounds; Flags: ignoreversion
Source: {#distrodir}\OfficePromoScreen.bmp; DestDir: {tmp}; Flags: dontcopy
Source: {#distrodir}\OfficePromoScreenBig.bmp; DestDir: {tmp}; Flags: dontcopy

[Dirs]

[Icons]
Name: {commondesktop}\{#app_name}; Filename: {app}\ReBar.exe; Tasks: desktopicon\common; Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: ReBar; IconFilename: {app}\ReBar.exe; IconIndex: 0
Name: {userdesktop}\{#app_name};   Filename: {app}\ReBar.exe; Tasks: desktopicon\user;   Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: ReBar; IconFilename: {app}\ReBar.exe; IconIndex: 0
Name: {userstartmenu}\{#app_name}; Filename: {app}\ReBar.exe; Tasks: startup_icon;       Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: ReBar; IconFilename: {app}\ReBar.exe; IconIndex: 0
Name: {#quick_launch}\{#app_name}; Filename: {app}\ReBar.exe; Tasks: quicklaunchicon;    Comment: {#app_name} {#app_version}; WorkingDir: {app};                        					IconFilename: {app}\ReBar.exe; IconIndex: 0

[INI]
Filename: {app}\ReBar.ini; Section: ReBar; Key: PortableEdition; String: 0
Filename: {userappdata}\Rizonesoft\ReBar\ReBar.ini; Section: ReBar; Key: PortableEdition; String: 0

[Run]
Filename: {app}\ReBar.exe; Description: {cm:LaunchProgram,{#app_name}}; WorkingDir: {app}; Flags: nowait postinstall shellexec skipifsilent unchecked

[InstallDelete]
Type: files;      Name: {userdesktop}\{#app_name}.lnk;   Check: not IsTaskSelected('desktopicon\user')   and IsUpgrade()
Type: files;      Name: {commondesktop}\{#app_name}.lnk; Check: not IsTaskSelected('desktopicon\common') and IsUpgrade()
Type: files;      Name: {userstartmenu}\{#app_name}.lnk; Check: not IsTaskSelected('startup_icon')       and IsUpgrade()
Type: files;      Name: {#quick_launch}\{#app_name}.lnk; Check: not IsTaskSelected('quicklaunchicon')    and IsUpgrade(); OnlyBelowVersion: 6.01
Type: files;      Name: {app}\ReBar.ini

[UninstallDelete]
Type: files;      Name: {app}\ReBar.ini
Type: dirifempty; Name: {app}

[Code]
var
	PromoPage: TWizardPage;
	PromoImage: TBitmapImage;
	DownloadButton: TButton;
	PromoLabel: TLabel;
	ErrCode: integer;
	SplashForm: TSetupForm;
	OpenWebpageButton: TNewButton;
const
	HWND_TOPMOST = -1;
	SWP_NOSIZE = $1;
	SWP_NOMOVE = $2;
	SWP_NOZORDER = $4;
	PromoURL = 'https://www.rizonesoft.com/downloads/rizonesoft-office/update/';
function SetWindowPos(hWnd: HWND; hWndInsertAfter: HWND; X, Y, cx, cy: Integer; uFlags: UINT): BOOL;
external 'SetWindowPos@user32.dll stdcall';
function IsUpgrade(): Boolean;
	var
	sPrevPath: String;
begin
	sPrevPath := WizardForm.PrevAppDir;
	Result := (sPrevPath <> '');
end;

// Check if ReBar Framework's settings exist.
function SettingsExistCheck(): Boolean;
begin
	if FileExists(ExpandConstant('{userappdata}\Rizonesoft\ReBar\ReBar.ini')) then begin
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
	DeleteFile(ExpandConstant('{userappdata}\Rizonesoft\ReBar\ReBar.ini'));
	RemoveDir(ExpandConstant('{userappdata}\Rizonesoft\ReBar'));
end;

procedure CurPageChanged(CurPageID: Integer);
begin
	if CurPageID = PromoPage.ID then
		WizardForm.NextButton.Caption := 'Continue'
	else if CurPageID = wpSelectTasks then
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
	// When uninstalling, ask the user to delete ReBar Framework's settings.
	if CurUninstallStep = usUninstall then begin
		if SettingsExistCheck() then begin
			if SuppressibleMsgBox(CustomMessage('msg_DeleteSettings'), mbConfirmation, MB_YESNO or MB_DEFBUTTON2, IDNO) = IDYES then
			CleanUpSettings();
		end;
	end;
end;

procedure DownloadButtonClick(Sender: TObject);
begin
	ShellExec('open', PromoURL, '', '', SW_SHOW, ewNoWait, ErrCode);
end;

procedure InitializeWizard();
begin
	WizardForm.SelectTasksLabel.Hide;
	WizardForm.TasksList.Top    := 0;
	WizardForm.TasksList.Height := PageFromID(wpSelectTasks).SurfaceHeight;

	ExtractTemporaryFile('OfficePromoScreen.bmp');
	PromoPage := CreateCustomPage(wpWelcome, 'ReBar Framework', 'Thank you for choosing ReBar Framework.');

	PromoImage := TBitmapImage.Create(PromoPage);
	PromoImage.Parent := PromoPage.Surface;
	PromoImage.Bitmap.LoadFromFile(ExpandConstant('{tmp}\OfficePromoScreen.bmp'));
	PromoImage.Left := 0;
	PromoImage.Top := 0;
	PromoImage.Width := PromoImage.Bitmap.Width;
	PromoImage.Height := PromoImage.Bitmap.Height;

	DownloadButton := TButton.Create(PromoPage);
	DownloadButton.Parent := PromoPage.Surface;
	DownloadButton.Width := 100;
	DownloadButton.Height := 30;
	DownloadButton.Left := PromoImage.Width - DownloadButton.Width - 10;
	DownloadButton.Top := PromoImage.Height - DownloadButton.Height - 10;
	DownloadButton.Caption := 'Read more';
	DownloadButton.OnClick := @DownloadButtonClick;

	PromoLabel := TLabel.Create(PromoPage);
	PromoLabel.Parent := PromoPage.Surface;
	PromoLabel.Left := 0;
	PromoLabel.Top := PromoImage.Height + 5;
	PromoLabel.Width := PromoPage.SurfaceWidth;
	PromoLabel.Caption := 'Free from adware, malware, and unwanted software.';
	PromoLabel.Font.Size := 10;
	PromoLabel.Alignment := taCenter;
end;

procedure CreateSplashForm();
var
	ImageControl: TBitmapImage;
begin
	SplashForm := CreateCustomForm();
	SplashForm.BorderStyle := bsDialog;
	SplashForm.ClientWidth := 600;
	SplashForm.ClientHeight := 550;
	SplashForm.Caption := 'Rizonesoft Office 2023 Promo';

	ExtractTemporaryFile('OfficePromoScreenBig.bmp');

	ImageControl := TBitmapImage.Create(SplashForm);
	ImageControl.Parent := SplashForm;
	ImageControl.Bitmap.LoadFromFile(ExpandConstant('{tmp}\OfficePromoScreenBig.bmp'));
	ImageControl.SetBounds(0, 0, 600, 500);

	OpenWebpageButton := TNewButton.Create(SplashForm);
	OpenWebpageButton.Parent := SplashForm;
	OpenWebpageButton.Width := 150;
	OpenWebpageButton.Height := 30;
	OpenWebpageButton.Left := SplashForm.ClientWidth - OpenWebpageButton.Width - 10;
	OpenWebpageButton.Top := ImageControl.Top + ImageControl.Height + 10;
	OpenWebpageButton.Caption := 'Go to Rizonesoft';
	OpenWebpageButton.OnClick := @DownloadButtonClick;
	SplashForm.Show();
	SetWindowPos(SplashForm.Handle, HWND_TOPMOST, 13, 13, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
	Result := True;
	if CurPageID = wpSelectTasks then
	begin
		CreateSplashForm();
	end;
end;
