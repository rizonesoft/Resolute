;* Firemin - Installer script
;* Copyright (C) 2025 Rizonesoft

; Requirements: Inno Setup 6.3.x or newer
; Inno Setup: https://jrsoftware.org/isdl.php

#pragma include __INCLUDE__ + ";" + ReadReg(HKLM, "Software\Mitrich Software\Inno Download Plugin", "InstallDir")
#include <idp.iss>
; Preprocessor related stuff
#if VER < EncodeVer(6,4,2)
	#error Update your Inno Setup version (6.4.2 or newer)
#endif

#define distrodir       "..\..\..\Resolute"
#define promodir        "..\..\..\promo"
#define outdir          "..\..\..\Distribution"
#define app_publisher   "Rizonesoft"
#define app_name        "Firemin"
#define app_shortname   "Firemin"
#define app_copyright   "Copyright (C) 2025 Rizonesoft"
#define app_inifile     "Firemin.ini"

; Define all INI values in one place
#define ini_PortableEdition_Normal "0"
#define ini_PortableEdition_Portable "1"
#define ini_FirstRun "1"
#define ini_BoostEnabled "1"
#define ini_Boost "1000"
#define ini_LimitEnabled "1"
#define ini_ReduceLimit "200"
#define ini_StartBrowser "0"
#define ini_EnableExtendedProcs "1"
#define ini_CheckForUpdates "4"
#define ini_ShowNotifications "1"
#define ini_ExtendedProcs "plugin-container.exe"
#define ini_ProcessPriority "2"
#define ini_SaveRealtime "0"
#define ini_ReduceMemory "0"
#define ini_ShowTrayIcon "1"
#define ini_CloseToTray "1"
#define ini_MinimizeToTray "1"
#define ini_StartMinimized "0"
#define ini_LaunchWithWindows "0"
#define ini_SystemMemoryEnabled "0"
#define ini_SystemMemoryLimit "20"
#define ini_DonateName ""
#define ini_DonateBuild "0"
#define ini_DefaultBrowserPath "C:\Program Files\Mozilla Firefox\firefox.exe"

#if Defined(UNICODE) && FileExists(distrodir + "\" + app_shortname + "_X64.exe")
  #define AppSourceFile distrodir + "\" + app_shortname + "_X64.exe"
#elif FileExists(distrodir + "\" + app_shortname + ".exe")
  #define AppSourceFile distrodir + "\" + app_shortname + ".exe"
#else
  #error Source file doesn't exist
#endif

; Get full version string first
#define app_version GetVersionNumbersString(AppSourceFile)

; Extract version components
#define VersionMajor
#define VersionMinor
#define VersionRevision 
#define VersionBuild
#expr GetVersionComponents(AppSourceFile, VersionMajor, VersionMinor, VersionRevision, VersionBuild)
#define app_build VersionBuild

[Setup]
AppId={#app_shortname}_{#app_build}
AppName={#app_name}
AppVersion={#app_version}
AppVerName={#app_name} {#app_version}
AppPublisher={#app_publisher}
AppPublisherURL=https://rizonesoft.com
AppSupportURL=https://rizonesoft.com/documents
AppUpdatesURL=https://rizonesoft.com/downloads/resolute
AppContact=https://rizonesoft.com/contact-us
AppCopyright={#app_copyright}
UninstallDisplayIcon={app}\{#app_shortname}.exe
UninstallDisplayName={#app_name} {#app_version}
DefaultDirName={pf}\Rizonesoft\{#app_name}
LicenseFile={#distrodir}\Docs\{#app_shortname}\License.txt
OutputDir={#outdir}\Packages
OutputBaseFilename={#app_shortname}_{#app_build}_Setup
Compression=lzma2/max
InternalCompressLevel=max
SolidCompression=yes
EnableDirDoesntExistWarning=no
AllowNoIcons=yes
ShowTasksTreeLines=yes
DisableDirPage=no
DisableProgramGroupPage=yes
DisableReadyPage=no
DisableWelcomePage=no
SignedUninstaller=no
SignedUninstallerDir=.\Resources\Uninstaller
AllowCancelDuringInstall=no
MinVersion=6.1sp1
ArchitecturesAllowed=x86 x64
ArchitecturesInstallIn64BitMode=x64
CloseApplications=force
SetupMutex={#app_shortname}_{#app_build}_setup_mutex,Global\{#app_shortname}_{#app_build}_setup_mutex

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

; Opera Promotion
en.msg_Opera                  = Browse Smarter and Upgrade your Web Experience with Opera!
en.msg_BrowserForTech         = Unlock Aria, the AI that redefines web exploration.
en.msg_Accept                 = Accept
en.msg_Decline                = Decline

; Normal and Portable Install
en.msg_InstallationType      = Installation Type
en.msg_SelectInstallType     = Please select the type of installation:
en.msg_NormalInstall         = Normal Installation
en.msg_PortableInstall       = Portable Installation

[Tasks]
Name: "reset_settings"; Description: "{cm:tsk_ResetSettings}"; GroupDescription: "{cm:tsk_Other}"; Flags: checkedonce unchecked; Check: SettingsExistCheck() and not GetInstallationType
Name: "startup_icon"; Description: "{cm:tsk_StartMenuIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Check: not GetInstallationType
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; Check: not GetInstallationType
Name: "desktopicon\user"; Description: "{cm:tsk_CurrentUser}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked exclusive; Check: not GetInstallationType
Name: "desktopicon\common"; Description: "{cm:tsk_AllUsers}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked exclusive; Check: not GetInstallationType

[Files]
Source: {#distrodir}\{#app_shortname}_X64.exe; DestDir: {app}; DestName: Firemin.exe; Flags: ignoreversion; Check: Is64BitInstallMode()
Source: {#distrodir}\{#app_shortname}.exe; DestDir: {app}; Flags: ignoreversion; Check: not Is64BitInstallMode()

; Opera Promotion
Source: {#promodir}\en_PromoScreen.bmp; DestDir: {tmp}; Flags: dontcopy
Source: {#promodir}\en_PromoScreen_HiDPI.bmp; DestDir: {tmp}; Flags: dontcopy

[Dirs]

[Icons]
Name: "{commondesktop}\{#app_name}"; Filename: "{app}\{#app_shortname}.exe"; WorkingDir: "{app}"; AppUserModelID: "{#app_publisher}.{#app_name}"; IconFilename: "{app}\{#app_shortname}.exe"; Comment: "{#app_name} {#app_version}"; Tasks: desktopicon\common
Name: "{userdesktop}\{#app_name}"; Filename: "{app}\{#app_shortname}.exe"; WorkingDir: "{app}"; AppUserModelID: "{#app_publisher}.{#app_name}"; IconFilename: "{app}\{#app_shortname}.exe"; IconIndex: 0; Comment: "{#app_name} {#app_version}"; Tasks: desktopicon\user
Name: "{commonprograms}\{#app_name}"; Filename: "{app}\{#app_shortname}.exe"; WorkingDir: "{app}"; AppUserModelID: "{#app_publisher}.{#app_name}"; IconFilename: "{app}\{#app_shortname}.exe"; IconIndex: 0; Comment: "{#app_name} {#app_version}"; Tasks: startup_icon


[INI]
; For regular installations
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "PortableEdition"; String: "{#ini_PortableEdition_Normal}"; Check: not GetInstallationType() and not IsUpgrade()
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "FirstRun"; String: "{#ini_FirstRun}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "BrowserPath"; String: "{#ini_DefaultBrowserPath}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "BoostEnabled"; String: "{#ini_BoostEnabled}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "Boost"; String: "{#ini_Boost}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "LimitEnabled"; String: "{#ini_LimitEnabled}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested()) 
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "ReduceLimit"; String: "{#ini_ReduceLimit}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "StartBrowser"; String: "{#ini_StartBrowser}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "EnableExtendedProcs"; String: "{#ini_EnableExtendedProcs}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "CheckForUpdates"; String: "{#ini_CheckForUpdates}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "ShowNotifications"; String: "{#ini_ShowNotifications}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "ExtendedProcs"; String: "{#ini_ExtendedProcs}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "ProcessPriority"; String: "{#ini_ProcessPriority}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "SaveRealtime"; String: "{#ini_SaveRealtime}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "ReduceMemory"; String: "{#ini_ReduceMemory}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "ShowTrayIcon"; String: "{#ini_ShowTrayIcon}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "CloseToTray"; String: "{#ini_CloseToTray}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "MinimizeToTray"; String: "{#ini_MinimizeToTray}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "StartMinimized"; String: "{#ini_StartMinimized}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "LaunchWithWindows"; String: "{#ini_LaunchWithWindows}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "SystemMemoryEnabled"; String: "{#ini_SystemMemoryEnabled}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "SystemMemoryLimit"; String: "{#ini_SystemMemoryLimit}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "Donate"; Key: "DonateName"; String: "{#ini_DonateName}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}"; Section: "Donate"; Key: "DonateBuild"; String: "{#ini_DonateBuild}"; Check: not GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())

; For portable installations
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "PortableEdition"; String: "{#ini_PortableEdition_Portable}"; Check: GetInstallationType()
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "FirstRun"; String: "{#ini_FirstRun}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "BrowserPath"; String: "{#ini_DefaultBrowserPath}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "BoostEnabled"; String: "{#ini_BoostEnabled}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "Boost"; String: "{#ini_Boost}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "LimitEnabled"; String: "{#ini_LimitEnabled}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "ReduceLimit"; String: "{#ini_ReduceLimit}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "StartBrowser"; String: "{#ini_StartBrowser}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "EnableExtendedProcs"; String: "{#ini_EnableExtendedProcs}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "CheckForUpdates"; String: "{#ini_CheckForUpdates}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "ShowNotifications"; String: "{#ini_ShowNotifications}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "ExtendedProcs"; String: "{#ini_ExtendedProcs}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "ProcessPriority"; String: "{#ini_ProcessPriority}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "SaveRealtime"; String: "{#ini_SaveRealtime}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "ReduceMemory"; String: "{#ini_ReduceMemory}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "ShowTrayIcon"; String: "{#ini_ShowTrayIcon}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "CloseToTray"; String: "{#ini_CloseToTray}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "MinimizeToTray"; String: "{#ini_MinimizeToTray}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "StartMinimized"; String: "{#ini_StartMinimized}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "LaunchWithWindows"; String: "{#ini_LaunchWithWindows}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "SystemMemoryEnabled"; String: "{#ini_SystemMemoryEnabled}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "{#app_shortname}"; Key: "SystemMemoryLimit"; String: "{#ini_SystemMemoryLimit}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "Donate"; Key: "DonateName"; String: "{#ini_DonateName}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())
Filename: "{app}\{#app_inifile}"; Section: "Donate"; Key: "DonateBuild"; String: "{#ini_DonateBuild}"; Check: GetInstallationType() and (not IsUpgrade() or ResetSettingsRequested())

[Run]
Filename: {app}\Firemin.exe; Description: {cm:LaunchProgram,{#app_name}}; WorkingDir: {app}; Flags: nowait postinstall shellexec skipifsilent unchecked

[InstallDelete]
Type: files;      Name: {userdesktop}\{#app_name}.lnk;   Check: not IsTaskSelected('desktopicon\user')   and IsUpgrade()
Type: files;      Name: {commondesktop}\{#app_name}.lnk; Check: not IsTaskSelected('desktopicon\common') and IsUpgrade()
Type: files;      Name: {userstartmenu}\{#app_name}.lnk; Check: not IsTaskSelected('startup_icon')       and IsUpgrade()
Type: files;      Name: {app}\{#app_shortname}.ini

[UninstallDelete]
Type: files;      Name: {app}\{#app_shortname}.ini
Type: dirifempty; Name: {app}

[Code]
type
    // Declare HDC as an Integer
    HDC = Integer;
var
    PromoPage: TWizardPage;
    InstallTypePage: TWizardPage;
    NormalInstallRadio: TRadioButton;
    PortableInstallRadio: TRadioButton;
    PromoImage: TBitmapImage;
    AcceptRadioButton: TRadioButton;
    DeclineRadioButton: TRadioButton;
    OperaExecuted: Boolean;
    PromoImagePath: String;
    ScreenDC: HDC;
    DPI: Integer;
    ScaleFactor: Double;
    OriginalWidth, OriginalHeight: Integer;
    HighDPIThreshold: Integer;
    ErrCode: integer;
    IsPortableInstall: Boolean;
    BuildNumber: String;
    ResetSettingsOnUpgrade: Boolean;
    ResetSettings: Boolean;

const
    HWND_TOPMOST = -1;
    SWP_NOSIZE = $1;
    SWP_NOMOVE = $2;
    SWP_NOZORDER = $4;
    DownloadURL = 'https://net.geo.opera.com/opera/stable/windows?utm_source=RIZONE&utm_medium=pb&utm_campaign=NOTEPAD';
    // Constants for GetDeviceCaps function
    LOGPIXELSX = 88; // Horizontal DPI
    LOGPIXELSY = 90; // Vertical DPI (if needed)

// Forward declarations removed

function GetInstallationType(): Boolean;
begin
    if PortableInstallRadio <> nil then
        Result := PortableInstallRadio.Checked
    else
        Result := False;
end;

function ShouldCreateUninstaller: Boolean;
begin
    Result := not GetInstallationType;
end;

function SetWindowPos(hWnd: HWND; hWndInsertAfter: HWND; X, Y, cx, cy: Integer; uFlags: UINT): BOOL;
    external 'SetWindowPos@user32.dll stdcall';

function GetDC(hWnd: Integer): HDC;
    external 'GetDC@user32.dll stdcall';

function ReleaseDC(hWnd: Integer; hDC: HDC): Integer;
    external 'ReleaseDC@user32.dll stdcall';

function GetDeviceCaps(hdc: HDC; nIndex: Integer): Integer;
    external 'GetDeviceCaps@gdi32.dll stdcall';

function OperaKeyExistsCIS(): Boolean;
var
  SubkeyNames: TArrayOfString;
  I, J: Integer;
  RegistryPaths: array[0..3] of String;
begin
  Result := False;

  RegistryPaths[0] := 'Software\Microsoft\Windows\CurrentVersion\Uninstall';
  RegistryPaths[1] := 'Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall';
  RegistryPaths[2] := 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
  RegistryPaths[3] := 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall';

  for I := 0 to High(RegistryPaths) do
  begin
    if RegGetSubkeyNames(HKLM, RegistryPaths[I], SubkeyNames) or
       RegGetSubkeyNames(HKCU, RegistryPaths[I], SubkeyNames) then
    begin
      for J := 0 to GetArrayLength(SubkeyNames) - 1 do
      begin
        if Pos('Opera', SubkeyNames[J]) = 1 then
        begin
          Result := True;
          Exit;
        end;
      end;
    end;
  end;
end;

Var
  Upgrade: Boolean;

function IsUpgrade(): Boolean;
begin
    Result := Upgrade;
end;

function OperaKeyExists(): Boolean;
begin
  Result := False;

  // Check if Opera keys exist in the registry
  if RegKeyExists(HKCU, 'Software\Opera Software') or
     RegKeyExists(HKLM, 'SOFTWARE\Opera Software') or
     RegKeyExists(HKLM, 'SOFTWARE\Wow6432Node\Opera Software') then
  begin
    Result := True;
  end;
end;

function OperaDetected(): Boolean;
begin
    Result := False;
    if OperaKeyExistsCIS() or OperaKeyExists() then
    begin
        Result := True;
    end;
end;

// Check if Firemin's settings exist.
function SettingsExistCheck(): Boolean;
begin
	if FileExists(ExpandConstant('{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}')) then begin
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
    // Skip the license page if IsUpgrade()
    if PageID = wpLicense then
        if IsUpgrade() then
        begin
            Result := True;
            WizardForm.LicenseAcceptedRadio.Checked := Result;
        end;

    // Skip the promo page if Opera is detected
    if (PromoPage <> nil) and (PageID = PromoPage.ID) and OperaKeyExists() then
        Result := True;

    // Skip the tasks page for portable installations
    if (PageID = wpSelectTasks) and GetInstallationType() then
        Result := True;
end;

procedure CleanUpSettings();
begin
	DeleteFile(ExpandConstant('{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}'));
	RemoveDir(ExpandConstant('{userappdata}\{#app_publisher}\{#app_shortname}'));
end;

procedure UpdateNextButtonState();
begin
  // Enable Next button only if either Accept or Decline is selected
  WizardForm.NextButton.Enabled := AcceptRadioButton.Checked or DeclineRadioButton.Checked;
end;

// Ask user if they want to reset settings during upgrade
function AskResetSettingsOnUpgrade(): Boolean;
var
  ResultCode: Integer;
begin
  Result := False;
  if IsUpgrade() then
  begin
    ResultCode := MsgBox(
      'Would you like to reset {#app_name} settings to default values?' + #13#10#13#10 +
      'Choose Yes to reset all settings.' + #13#10 +
      'Choose No to keep your current settings.',
      mbConfirmation, MB_YESNO
    );
    Result := (ResultCode = IDYES);
  end;
end;

procedure PromoOptionClick(Sender: TObject);
var
  ResultCode: Integer;
begin
  UpdateNextButtonState();

  if DeclineRadioButton.Checked then
  begin
    ResultCode := MsgBox(
      'Are you sure you would like to miss out on an enhanced browsing and AI experience? ' +
      'Opera offers integrated AI features and a host of other powerful tools. ' +
      'Don''t miss this opportunity to transform how you browse!' + #13#10#13#10 +
      'Would you still like to decline?',
      mbConfirmation, MB_YESNO
    );

    if ResultCode = IDNO then
    begin
      AcceptRadioButton.Checked := True;
      DeclineRadioButton.Checked := False;
      UpdateNextButtonState();
    end;
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  // Only handle Opera logic if not silent
  if not WizardSilent then
  begin
    if (PromoPage <> nil) and (CurPageID = PromoPage.ID) then
      UpdateNextButtonState();

    if CurPageID = wpReady then
    begin
      // Download Opera if accepted
      if (PromoPage <> nil) and (AcceptRadioButton.Checked) and (not OperaDetected()) then
      begin
        idpAddFile(DownloadURL, ExpandConstant('{tmp}\\OperaSetup.exe'));
        idpDownloadAfter(wpReady);
      end;
    end;
  end;

  if CurPageID = wpFinished then
    WizardForm.NextButton.Caption := SetupMessage(msgButtonFinish);
end;

// Add a function to detect Firefox installation path
function GetFirefoxPath(): String;
var
  FirefoxPath: String;
begin
  FirefoxPath := '';
  // First try to get the Firefox path from the registry (64-bit)
  if RegQueryStringValue(HKLM64, 'SOFTWARE\Mozilla\Mozilla Firefox', 'PathToExe', FirefoxPath) then
  begin
    Result := FirefoxPath;
    Exit;
  end;
  
  // Try the 32-bit registry location
  if RegQueryStringValue(HKLM, 'SOFTWARE\Mozilla\Mozilla Firefox', 'PathToExe', FirefoxPath) then
  begin
    Result := FirefoxPath;
    Exit;
  end;
  
  // Check common installation locations
  if FileExists(ExpandConstant('{pf}\Mozilla Firefox\firefox.exe')) then
  begin
    Result := ExpandConstant('{pf}\Mozilla Firefox\firefox.exe');
    Exit;
  end;
  
  if FileExists(ExpandConstant('{pf32}\Mozilla Firefox\firefox.exe')) then
  begin
    Result := ExpandConstant('{pf32}\Mozilla Firefox\firefox.exe');
    Exit;
  end;
  
  // Default to standard Firefox path if nothing else works
  Result := 'C:\Program Files\Mozilla Firefox\firefox.exe';
end;

function ResetSettingsRequested(): Boolean;
begin
  Result := ResetSettings;
end;

// Function to write default INI settings
procedure WriteDefaultSettings(const IniFile: String);
var
  FirefoxPath: String;
begin
  // Get Firefox path
  FirefoxPath := GetFirefoxPath();
  
  // Write main settings
  SetIniString('{#app_shortname}', 'FirstRun', '{#ini_FirstRun}', IniFile);
  SetIniString('{#app_shortname}', 'BrowserPath', FirefoxPath, IniFile);
  SetIniString('{#app_shortname}', 'BoostEnabled', '{#ini_BoostEnabled}', IniFile);
  SetIniString('{#app_shortname}', 'Boost', '{#ini_Boost}', IniFile);
  SetIniString('{#app_shortname}', 'LimitEnabled', '{#ini_LimitEnabled}', IniFile);
  SetIniString('{#app_shortname}', 'ReduceLimit', '{#ini_ReduceLimit}', IniFile);
  SetIniString('{#app_shortname}', 'StartBrowser', '{#ini_StartBrowser}', IniFile);
  SetIniString('{#app_shortname}', 'EnableExtendedProcs', '{#ini_EnableExtendedProcs}', IniFile);
  SetIniString('{#app_shortname}', 'CheckForUpdates', '{#ini_CheckForUpdates}', IniFile);
  SetIniString('{#app_shortname}', 'ShowNotifications', '{#ini_ShowNotifications}', IniFile);
  SetIniString('{#app_shortname}', 'ExtendedProcs', '{#ini_ExtendedProcs}', IniFile);
  SetIniString('{#app_shortname}', 'ProcessPriority', '{#ini_ProcessPriority}', IniFile);
  SetIniString('{#app_shortname}', 'SaveRealtime', '{#ini_SaveRealtime}', IniFile);
  SetIniString('{#app_shortname}', 'ReduceMemory', '{#ini_ReduceMemory}', IniFile);
  SetIniString('{#app_shortname}', 'ShowTrayIcon', '{#ini_ShowTrayIcon}', IniFile);
  SetIniString('{#app_shortname}', 'CloseToTray', '{#ini_CloseToTray}', IniFile);
  SetIniString('{#app_shortname}', 'MinimizeToTray', '{#ini_MinimizeToTray}', IniFile);
  SetIniString('{#app_shortname}', 'StartMinimized', '{#ini_StartMinimized}', IniFile);
  SetIniString('{#app_shortname}', 'LaunchWithWindows', '{#ini_LaunchWithWindows}', IniFile);
  SetIniString('{#app_shortname}', 'SystemMemoryEnabled', '{#ini_SystemMemoryEnabled}', IniFile);
  SetIniString('{#app_shortname}', 'SystemMemoryLimit', '{#ini_SystemMemoryLimit}', IniFile);
  
  // Write Donate section
  SetIniString('Donate', 'DonateName', '{#ini_DonateName}', IniFile);
  SetIniString('Donate', 'DonateBuild', '{#ini_DonateBuild}', IniFile);
end;

procedure WriteFirefoxPath();
var
  FirefoxPath: String;
  IniFile: String;
begin
  FirefoxPath := GetFirefoxPath();
  
  if FirefoxPath <> '' then
  begin
    if GetInstallationType() then
      IniFile := ExpandConstant('{app}\{#app_inifile}')
    else
      IniFile := ExpandConstant('{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}');
      
    // Only write BrowserPath if we found Firefox or user wants to reset settings
    if (not IsUpgrade()) or ResetSettingsRequested() then
      SetIniString('{#app_shortname}', 'BrowserPath', FirefoxPath, IniFile);
  end;
end;

procedure CreateInstallTypePage();
begin
    InstallTypePage := CreateCustomPage(wpWelcome, CustomMessage('msg_InstallationType'), CustomMessage('msg_SelectInstallType'));

    NormalInstallRadio := TRadioButton.Create(InstallTypePage);
    NormalInstallRadio.Parent := InstallTypePage.Surface;
    NormalInstallRadio.Caption := CustomMessage('msg_NormalInstall');
    NormalInstallRadio.Left := 0;
    NormalInstallRadio.Top := 8;
    NormalInstallRadio.Width := InstallTypePage.SurfaceWidth;
    NormalInstallRadio.Height := ScaleY(17);
    NormalInstallRadio.Checked := True;

    PortableInstallRadio := TRadioButton.Create(InstallTypePage);
    PortableInstallRadio.Parent := InstallTypePage.Surface;
    PortableInstallRadio.Caption := CustomMessage('msg_PortableInstall');
    PortableInstallRadio.Left := 0;
    PortableInstallRadio.Top := NormalInstallRadio.Top + NormalInstallRadio.Height + ScaleY(8);
    PortableInstallRadio.Width := InstallTypePage.SurfaceWidth;
    PortableInstallRadio.Height := ScaleY(17);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    if IsUpgrade() then
    begin
      ResetSettings := AskResetSettingsOnUpgrade();
      if ResetSettings then
        CleanUpSettings();
    end;
  end
  else if CurStep = ssPostInstall then
  begin
    // Write the Firefox path to INI file
    WriteFirefoxPath();
    
    // For portable installation, clean up the uninstaller entries to make it truly portable
    if GetInstallationType() then
    begin
      DeleteFile(ExpandConstant('{app}\unins000.dat'));
      DeleteFile(ExpandConstant('{app}\unins000.exe'));
    end;
  end;
end;

procedure InitializeWizard();
begin
    // Set the build number directly from the preprocessor value
    BuildNumber := '{#app_build}';
    
    // Update the window title to show the build number
    WizardForm.Caption := Format('Setup - {#app_name} (Build %s)', [BuildNumber]);
    
    // Create installation type page
    CreateInstallTypePage();
    
    With WizardForm do
    begin
        Upgrade := FileExists(AddBackslash(WizardDirValue) + '{#app_name}.exe');
        SelectTasksLabel.Hide;
        With TasksList do
        begin
            Top := 0;
            Height := SelectTasksPage.ClientHeight;
        end;
    end;

    if WizardSilent then
        Exit;

    // Set the threshold DPI value (e.g., 144 for 150% scaling)
    HighDPIThreshold := 144;
    // Get the screen's device context
    ScreenDC := GetDC(0);
    // Retrieve the DPI (use LOGPIXELSX for horizontal DPI)
    DPI := GetDeviceCaps(ScreenDC, LOGPIXELSX);
    // Release the device context
    ReleaseDC(0, ScreenDC);
    // Calculate the scaling factor (assuming 96 DPI is standard)
    ScaleFactor := DPI / 96.0;

    if DPI >= HighDPIThreshold then
        begin
            // High-DPI screen
            PromoImagePath := ExpandConstant('{tmp}\en_PromoScreen_HiDPI.bmp');
            OriginalWidth := 802;  // Width of the high-DPI image
            OriginalHeight := 400; // Height of the high-DPI image
        end
    else
        begin
            // Normal DPI screen
            PromoImagePath := ExpandConstant('{tmp}\en_PromoScreen.bmp');
            OriginalWidth := 450;  // Width of the normal image
            OriginalHeight := 236; // Height of the normal image
    end;

    // Extract and load the appropriate promo image
    ExtractTemporaryFile(ExtractFileName(PromoImagePath));
    PromoPage := CreateCustomPage(wpWelcome, CustomMessage('msg_Opera'), CustomMessage('msg_BrowserForTech'));

    PromoImage := TBitmapImage.Create(PromoPage);
    PromoImage.Parent := PromoPage.Surface;
    PromoImage.Bitmap.LoadFromFile(PromoImagePath);
    PromoImage.Left := 0;
    PromoImage.Top := 0;
    PromoImage.Width := OriginalWidth;
    PromoImage.Height := OriginalHeight;

    // Create the "Accept" radio button
    AcceptRadioButton := TRadioButton.Create(PromoPage);
    AcceptRadioButton.Parent := PromoPage.Surface;
    AcceptRadioButton.Caption := CustomMessage('msg_Accept');
    AcceptRadioButton.Left := 0;
    AcceptRadioButton.Top := PromoImage.Height;
    AcceptRadioButton.Height := 30;
    AcceptRadioButton.OnClick := @PromoOptionClick;

    // Create the "Decline" radio button
    DeclineRadioButton := TRadioButton.Create(PromoPage);
    DeclineRadioButton.Parent := PromoPage.Surface;
    DeclineRadioButton.Caption := CustomMessage('msg_Decline');
    DeclineRadioButton.Left := AcceptRadioButton.Width + 10;
    DeclineRadioButton.Top := PromoImage.Height;
    DeclineRadioButton.Height := 30;
    DeclineRadioButton.OnClick := @PromoOptionClick;

    // Initially disable the Next button on the promo page
    // The Next button will be re-enabled once a radio button is selected
    if Assigned(WizardForm) then
    begin
        WizardForm.NextButton.Enabled := False;
    end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  AppDataPath: String;
begin
  Result := '';
  
  // Create necessary directories for INI files
  if not GetInstallationType() then
  begin
    AppDataPath := ExpandConstant('{userappdata}\{#app_publisher}\{#app_shortname}');
    if not DirExists(AppDataPath) then
      ForceDirectories(AppDataPath);
  end;
end;
