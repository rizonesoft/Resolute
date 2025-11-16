;* Firemin - Installer script (Template)
;* Copyright (C) 2025 Rizonesoft
;*
;* This template is processed by Distro.au3 (_GenerateInstallationScriptFromTemplate)
;* The following placeholders are substituted:
;*   Rizonesoft        -> Environment["Company"]       (e.g., "Rizonesoft")
;*   Firemin       -> Environment["Name"]          (e.g., "Firemin")
;*   Firemin  -> Environment["ShortName"]     (e.g., "Firemin")
;*   Firemin_9558    -> Environment["DistributionName"] (e.g., "Firemin_9558")
;*
;* The generated script will be written to Distribution\<Build>\ and will reference
;* the distribution folder Firemin_9558 as a sibling directory.

; Requirements: Inno Setup 6.3.x or newer
; Inno Setup: https://jrsoftware.org/isdl.php

#pragma include __INCLUDE__ + ";" + ReadReg(HKLM, "Software\Mitrich Software\Inno Download Plugin", "InstallDir")
#include <idp.iss>
; Preprocessor related stuff
#if VER < EncodeVer(6,4,2)
	#error Update your Inno Setup version (6.4.2 or newer)
#endif

#define distrodir       "Firemin_9558"
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
Source: {#distrodir}\\Firemin.ini; DestDir: {app}; Flags: ignoreversion
Source: {#distrodir}\\Docs\Firemin\Changes.txt; DestDir: {app}\\Docs\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Docs\Firemin\License.txt; DestDir: {app}\\Docs\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Docs\Firemin\Readme.txt; DestDir: {app}\\Docs\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\af.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\ar.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\bg.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\cs.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\da.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\de.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\el.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\en.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\es.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\fa.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\fr.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\hi.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\hr.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\hu.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\id.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\is.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\it.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\iw.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\ja.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\ko.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\nl.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\no.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\pl.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\pt-BR.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\pt.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\ro.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\ru.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\sk.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\sl.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\sv.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\th.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\tr.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\vi.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\zh-CN.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Language\Firemin\zh-TW.lng; DestDir: {app}\\Language\\Firemin; Flags: ignoreversion
Source: {#distrodir}\\Processing\32\Stroke.ani; DestDir: {app}\\Processing\\32; Flags: ignoreversion
Source: {#distrodir}\\Processing\64\Globe.ani; DestDir: {app}\\Processing\\64; Flags: ignoreversion


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
Type: files;      Name: {app}\{#app_shortname}.ini
Type: dirifempty; Name: {app}

[Code]
var
    InstallTypePage: TWizardPage;
    NormalInstallRadio: TRadioButton;
    PortableInstallRadio: TRadioButton;
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

procedure CurPageChanged(CurPageID: Integer);
begin
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
  if FileExists(ExpandConstant('{commonpf}\Mozilla Firefox\firefox.exe')) then
  begin
    Result := ExpandConstant('{commonpf}\Mozilla Firefox\firefox.exe');
    Exit;
  end;
  
  if FileExists(ExpandConstant('{commonpf32}\Mozilla Firefox\firefox.exe')) then
  begin
    Result := ExpandConstant('{commonpf32}\Mozilla Firefox\firefox.exe');
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
