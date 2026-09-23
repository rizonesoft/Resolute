;* Edgemin - Installer script (Template)
;* Copyright (C) 2025 Rizonesoft
;*
;* This template is processed by Distro.au3 (_GenerateInstallationScriptFromTemplate)
;* The following placeholders are substituted:
;*   %{COMPANY}        -> Environment["Company"]       (e.g., "Rizonesoft")
;*   %{APP_NAME}       -> Environment["Name"]          (e.g., "Edgemin")
;*   %{APP_SHORTNAME}  -> Environment["ShortName"]     (e.g., "Edgemin")
;*   %{DISTRO_NAME}    -> Environment["DistributionName"] (e.g., "Edgemin_8535")
;*
;* The generated script will be written to Distribution\<Build>\ and will reference
;* the distribution folder %{DISTRO_NAME} as a sibling directory.

; Requirements: Inno Setup 6.3.x or newer
; Inno Setup: https://jrsoftware.org/isdl.php

; Preprocessor related stuff
#if VER < EncodeVer(6,4,2)
	#error Update your Inno Setup version (6.4.2 or newer)
#endif

#define distrodir       "%{DISTRO_NAME}"
#define app_publisher   "%{COMPANY}"
#define app_name        "%{APP_NAME}"
#define app_shortname   "%{APP_SHORTNAME}"
#define app_copyright   "Copyright (C) 2025 %{COMPANY}"
#define app_inifile     "%{APP_SHORTNAME}.ini"

; Define all INI values in one place
#define ini_PortableEdition_Normal "0"
#define ini_PortableEdition_Portable "1"
#define ini_FirstRun "1"
#define ini_BoostEnabled "1"
#define ini_Boost "500"
#define ini_LimitEnabled "1"
#define ini_ReduceLimit "100"
#define ini_StartBrowser "1"
#define ini_EnableExtendedProcs "1"
#define ini_CheckForUpdates "4"
#define ini_ShowNotifications "1"
#define ini_ExtendedProcs "plugin-container.exe"
#define ini_ProcessPriority "4"
#define ini_SaveRealtime "0"
#define ini_ReduceMemory "1"
#define ini_ShowTrayIcon "1"
#define ini_CloseToTray "1"
#define ini_MinimizeToTray "1"
#define ini_StartMinimized "0"
#define ini_LaunchWithWindows "0"
#define ini_SystemMemoryEnabled "0"
#define ini_SystemMemoryLimit "20"
#define ini_DonateName ""
#define ini_DonateBuild "0"
#define ini_DefaultBrowserPath "C:\Program Files\Google\Edge\Application\chrome.exe"

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
DefaultDirName={autopf}\{#app_publisher}\{#app_name}
LicenseFile={#distrodir}\Docs\{#app_shortname}\License.txt
OutputDir=.
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
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x86compatible x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
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
; Normal installation: Install only the appropriate architecture
Source: {#distrodir}\{#app_shortname}_X64.exe; DestDir: {app}; DestName: {#app_shortname}.exe; Flags: ignoreversion; Check: not GetInstallationType() and Is64BitInstallMode()
Source: {#distrodir}\{#app_shortname}.exe; DestDir: {app}; DestName: {#app_shortname}.exe; Flags: ignoreversion; Check: not GetInstallationType() and not Is64BitInstallMode()
; Portable installation: Include both x64 and x86 versions with distinct names
Source: {#distrodir}\{#app_shortname}_X64.exe; DestDir: {app}; DestName: {#app_shortname}_X64.exe; Flags: ignoreversion; Check: GetInstallationType()
Source: {#distrodir}\{#app_shortname}.exe; DestDir: {app}; DestName: {#app_shortname}.exe; Flags: ignoreversion; Check: GetInstallationType()
%{FILES_SECTION}
%{LANGUAGE_FILES_SECTION}
Source: ..\..\..\..\Resources\Setup\Donate.bmp; Flags: dontcopy

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
Filename: {app}\{#app_shortname}.exe; Description: {cm:LaunchProgram,{#app_name}}; WorkingDir: {app}; Flags: nowait postinstall shellexec skipifsilent unchecked

[InstallDelete]
Type: files;      Name: {userdesktop}\{#app_name}.lnk;   Check: not WizardIsTaskSelected('desktopicon\user')   and IsUpgrade()
Type: files;      Name: {commondesktop}\{#app_name}.lnk; Check: not WizardIsTaskSelected('desktopicon\common') and IsUpgrade()
Type: files;      Name: {userstartmenu}\{#app_name}.lnk; Check: not WizardIsTaskSelected('startup_icon')       and IsUpgrade()
Type: files;      Name: {app}\{#app_shortname}.ini

[UninstallDelete]
Type: dirifempty; Name: {app}

[Code]
var
    InstallTypePage: TWizardPage;
    DonatePage: TWizardPage;
    NormalInstallRadio: TRadioButton;
    PortableInstallRadio: TRadioButton;
    PayPalButton: TBitmapImage;
    CreateDesktopIconCheck: TNewCheckBox;
    BuildNumber: String;
    ResetSettings: Boolean;

// Forward declarations removed
function GetInstallationType(): Boolean;
begin
    if PortableInstallRadio <> nil then
        Result := PortableInstallRadio.Checked
    else
        Result := False;
end;

procedure UpdatePortableDesktopIconOption();
begin
  if CreateDesktopIconCheck = nil then
    Exit;

  if GetInstallationType() and not WizardSilent then
  begin
    CreateDesktopIconCheck.Visible := True;
    CreateDesktopIconCheck.Checked := True;
  end
  else
  begin
    CreateDesktopIconCheck.Visible := False;
  end;
end;

procedure CreatePortableDesktopIcon();
var
  IconPath: String;
begin
  IconPath := ExpandConstant('{userdesktop}\{#app_name}.lnk');
  if FileExists(IconPath) then
    DeleteFile(IconPath);

  CreateShellLink(
    IconPath,
    '',
    ExpandConstant('{app}\{#app_shortname}.exe'),
    '',
    ExpandConstant('{app}'),
    0,
    ExpandConstant('{app}\{#app_shortname}.exe')
  );
end;

function ShouldCreateUninstaller: Boolean;
begin
    Result := not GetInstallationType;
end;

Var
  Upgrade: Boolean;

function IsUpgrade(): Boolean;
begin
    Result := Upgrade;
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

    // Skip the tasks page for portable installations
    if (PageID = wpSelectTasks) and GetInstallationType() then
        Result := True;
end;

procedure CleanUpSettings();
begin
	DeleteFile(ExpandConstant('{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}'));
	RemoveDir(ExpandConstant('{userappdata}\{#app_publisher}\{#app_shortname}'));
end;

// Ask user if they want to reset settings during upgrade
function AskResetSettingsOnUpgrade(): Boolean;
var
  ResultCode: Integer;
begin
  Result := False;
  if IsUpgrade() and not GetInstallationType() then
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

procedure CurPageChanged(CurPageID: Integer);
begin
  // When leaving the install type page, set the appropriate default directory
  if (CurPageID = wpSelectDir) and (InstallTypePage <> nil) then
  begin
    if GetInstallationType() then
    begin
      // Portable installation: Default to root of system drive (e.g., C:\Edgemin)
      WizardForm.DirEdit.Text := ExpandConstant('{sd}\{#app_shortname}');
    end
    else
    begin
      // Normal installation: Default to Program Files
      WizardForm.DirEdit.Text := ExpandConstant('{autopf}\{#app_publisher}\{#app_name}');
    end;
  end;
  
  if CurPageID = wpSelectDir then
    UpdatePortableDesktopIconOption();

  if CurPageID = wpFinished then
  begin
    UpdatePortableDesktopIconOption();
    WizardForm.NextButton.Caption := SetupMessage(msgButtonFinish);
  end;
end;

// Add a function to detect Edge installation path
function GetEdgePath(): String;
var
  EdgePath: String;
begin
  EdgePath := '';
  // First try to get the Edge path from the registry (64-bit)
  if RegQueryStringValue(HKLM64, 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe', '', EdgePath) then
  begin
    Result := EdgePath;
    Exit;
  end;
  
  // Try the 32-bit registry location
  if RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe', '', EdgePath) then
  begin
    Result := EdgePath;
    Exit;
  end;
  
  // Check common installation locations
  if FileExists(ExpandConstant('{commonpf}\Google\Edge\Application\chrome.exe')) then
  begin
    Result := ExpandConstant('{commonpf}\Google\Edge\Application\chrome.exe');
    Exit;
  end;
  
  if FileExists(ExpandConstant('{commonpf32}\Google\Edge\Application\chrome.exe')) then
  begin
    Result := ExpandConstant('{commonpf32}\Google\Edge\Application\chrome.exe');
    Exit;
  end;
  
  // Default to standard Edge path if nothing else works
  Result := 'C:\Program Files\Google\Edge\Application\chrome.exe';
end;

function ResetSettingsRequested(): Boolean;
begin
  Result := ResetSettings;
end;

// Function to write default INI settings
procedure WriteDefaultSettings(const IniFile: String);
var
  EdgePath: String;
begin
  // Get Edge path
  EdgePath := GetEdgePath();
  
  // Write main settings
  SetIniString('{#app_shortname}', 'FirstRun', '{#ini_FirstRun}', IniFile);
  SetIniString('{#app_shortname}', 'BrowserPath', EdgePath, IniFile);
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

procedure WriteEdgePath();
var
  EdgePath: String;
  IniFile: String;
begin
  EdgePath := GetEdgePath();
  
  if EdgePath <> '' then
  begin
    if GetInstallationType() then
      IniFile := ExpandConstant('{app}\{#app_inifile}')
    else
      IniFile := ExpandConstant('{userappdata}\{#app_publisher}\{#app_shortname}\{#app_inifile}');
      
    // Only write BrowserPath if we found Edge or user wants to reset settings
    if (not IsUpgrade()) or ResetSettingsRequested() then
      SetIniString('{#app_shortname}', 'BrowserPath', EdgePath, IniFile);
  end;
end;

procedure PayPalButtonClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExec('', 'https://www.paypal.com/donate/?hosted_button_id=7UGGCSDUZJPFE', '', '', SW_SHOW, ewNoWait, ErrorCode);
end;

procedure CreateDonatePage();
var
  DonateLabel1: TNewStaticText;
  DonateLabel2: TNewStaticText;
  DonateLabel3: TNewStaticText;
begin
  DonatePage := CreateCustomPage(wpInfoAfter, 'Support Free Software', 'Help Keep Rizonesoft Tools Free Forever');

  // Main message
  DonateLabel1 := TNewStaticText.Create(DonatePage);
  DonateLabel1.Parent := DonatePage.Surface;
  DonateLabel1.Caption := 
    'This software is completely FREE with no ads, no tracking, and no premium versions.' + #13#10 +
    'If you find it useful, please consider supporting our work.';
  DonateLabel1.Left := 0;
  DonateLabel1.Top := ScaleY(8);
  DonateLabel1.Width := DonatePage.SurfaceWidth;
  DonateLabel1.Height := ScaleY(32);
  DonateLabel1.Font.Size := 9;
  DonateLabel1.WordWrap := True;
  DonateLabel1.AutoSize := True;

  // Support impact paragraph
  DonateLabel2 := TNewStaticText.Create(DonatePage);
  DonateLabel2.Parent := DonatePage.Surface;
  DonateLabel2.Caption := 
    'Your support helps us keep all Rizonesoft tools free forever, add new features ' +
    'and improvements, provide timely updates and support, and develop more amazing ' +
    'free tools for everyone.';
  DonateLabel2.Left := 0;
  DonateLabel2.Top := DonateLabel1.Top + DonateLabel1.Height + ScaleY(12);
  DonateLabel2.Width := DonatePage.SurfaceWidth;
  DonateLabel2.Font.Size := 9;
  DonateLabel2.WordWrap := True;
  DonateLabel2.AutoSize := True;

  // Call to action
  DonateLabel3 := TNewStaticText.Create(DonatePage);
  DonateLabel3.Parent := DonatePage.Surface;
  DonateLabel3.Caption := 
    'Even a small donation makes a difference. Click below to support development:';
  DonateLabel3.Left := 0;
  DonateLabel3.Top := DonateLabel2.Top + DonateLabel2.Height + ScaleY(12);
  DonateLabel3.Width := DonatePage.SurfaceWidth;
  DonateLabel3.Font.Size := 9;
  DonateLabel3.Font.Style := [fsBold];
  DonateLabel3.WordWrap := True;
  DonateLabel3.AutoSize := True;

  // PayPal donation button
  PayPalButton := TBitmapImage.Create(DonatePage);
  PayPalButton.Parent := DonatePage.Surface;
  PayPalButton.Cursor := crHand;
  PayPalButton.OnClick := @PayPalButtonClick;
  
  // Extract and load the Donate button image
  ExtractTemporaryFile('Donate.bmp');
  PayPalButton.Bitmap.LoadFromFile(ExpandConstant('{tmp}\Donate.bmp'));
  
  // Use AutoSize for best quality across all DPI settings
  PayPalButton.AutoSize := True;
  PayPalButton.Stretch := False;
  
  // Center the button after AutoSize sets its dimensions
  PayPalButton.Top := DonateLabel3.Top + DonateLabel3.Height + ScaleY(16);
  PayPalButton.Left := (DonatePage.SurfaceWidth - PayPalButton.Width) div 2;
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
    // Write the Edge path to INI file
    WriteEdgePath();
    
    // For portable installation, clean up the uninstaller entries to make it truly portable
    if GetInstallationType() then
    begin
      DeleteFile(ExpandConstant('{app}\unins000.dat'));
      DeleteFile(ExpandConstant('{app}\unins000.exe'));

      if (CreateDesktopIconCheck <> nil) and CreateDesktopIconCheck.Checked then
        CreatePortableDesktopIcon();
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
    
    // Create donation page
    CreateDonatePage();

    // Create portable desktop icon option (finished page)
    CreateDesktopIconCheck := TNewCheckBox.Create(WizardForm);
    CreateDesktopIconCheck.Parent := WizardForm.FinishedPage.Surface;
    CreateDesktopIconCheck.Caption := SetupMessage(msgCreateDesktopIcon);
    CreateDesktopIconCheck.Checked := True;
    CreateDesktopIconCheck.Left := WizardForm.RunList.Left;
    CreateDesktopIconCheck.Top := WizardForm.RunList.Top + WizardForm.RunList.Height + ScaleY(8);
    CreateDesktopIconCheck.Width := WizardForm.RunList.Width;
    CreateDesktopIconCheck.Visible := False;
    
    With WizardForm do
    begin
        Upgrade := FileExists(AddBackslash(WizardDirValue) + '{#app_shortname}.exe');
        SelectTasksLabel.Hide;
        With TasksList do
        begin
            Top := 0;
            Height := SelectTasksPage.ClientHeight;
        end;
    end;

    if WizardSilent then
        Exit;

    UpdatePortableDesktopIconOption();
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
