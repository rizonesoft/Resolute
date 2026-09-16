;* Notepad3 - Installer script
;*
;* (c) Rizonesoft 2008-2020

; Requirements:
; Inno Setup: http://www.jrsoftware.org/isdl.php

; Preprocessor related stuff
#if VER < EncodeVer(5,5,9)
  #error Update your Inno Setup version (5.5.9 or newer)
#endif


#ifnexist "Resolute.exe"
  #error Compile Resolute x86 first
#endif

#ifnexist "Resolute_X64.exe"
  #error Compile Resolute x64 first
#endif

#define app_name      "Resolute"
#define app_publisher "Rizonesoft"
#define app_version   GetFileVersion("Resolute.exe")
#define app_copyright "(c) Rizonesoft 2008-2020"
#define quick_launch  "{userappdata}\Microsoft\Internet Explorer\Quick Launch"


[Setup]
AppId={#app_name}
AppName={#app_name}
AppVersion={#app_version}
AppVerName={#app_name} {#app_version}
AppPublisher={#app_publisher}
AppPublisherURL=https://rizonesoft.com
AppSupportURL=https://rizonesoft.com
AppUpdatesURL=https://rizonesoft.com
AppContact=https://rizonesoft.com
AppCopyright={#app_copyright}
DefaultDirName=Resolute
;LicenseFile="..\License.txt"
OutputDir=Packages
OutputBaseFilename={#app_name}_{#app_version}_Setup
WizardStyle=modern
WizardSmallImageFile=SDK\Resources\Setup\WizardSmallImageFile.bmp
Compression=lzma2/max
InternalCompressLevel=max
SolidCompression=yes
Uninstallable = no
EnableDirDoesntExistWarning=no
AllowNoIcons=yes
ShowTasksTreeLines=yes
DisableProgramGroupPage=yes
DisableReadyPage=yes
DisableWelcomePage=no
AllowCancelDuringInstall=yes
MinVersion=6.0
;ArchitecturesAllowed=x86 x64
;ArchitecturesInstallIn64BitMode=x64
;#ifexist "..\signinfo_notepad3.txt"
;SignTool=MySignTool
;#endif
CloseApplications=true
SetupMutex='{#app_name}' + '_setup_mutex'


[Languages]
Name: en; MessagesFile: compiler:Default.isl


[Messages]
SelectDirBrowseLabel =To continue, click Next.
SetupAppTitle        =Setup - {#app_name}
SetupWindowTitle     =Setup - {#app_name}


[CustomMessages]


[Tasks]

[Files]
; Main executables and text files
Source: "Resolute.exe";      DestDir: "{app}"; Flags: ignoreversion;
Source: "Resolute_X64.exe";  DestDir: "{app}"; Flags: ignoreversion;
Source: "Commands.txt";      DestDir: "{app}"; Flags: ignoreversion;
Source: "Stock.txt";         DestDir: "{app}"; Flags: ignoreversion;

; Resolute directory files
; Excludes configuration and certain sub-directories for security and customization
Source: "Resolute\*"; DestDir: "{app}\Resolute"; Flags: ignoreversion recursesubdirs; Excludes: "BiosCodes.ini, ComIntRep.ini, Distro.ini, DVDRepair.ini, Firemin.ini, Ownership.ini, PixRepair.ini, ReBar.ini, Resolute.ini, USBRepair.ini, Rescue\Database\*, Rescue\Quarantine\*, Rescue\ClamAV\*";

; SDK directory files
; Excludes Distribution directory as it's not needed in the installation
Source: "SDK\*"; DestDir: "{app}\SDK"; Flags: ignoreversion recursesubdirs; Excludes: "Distribution\*";

[Dirs]
;Name: "{app}\Resolute\Bin\x86\cstatus\Configs"
;Name: "{app}\Resolute\Bin\x86\cstatus\History_Logs"

[Icons]


[INI]


[Run]
;Filename: {app}\Notepad3.exe; Description: {cm:LaunchProgram,{#app_name}}; WorkingDir: {app}; Flags: nowait postinstall skipifsilent unchecked
;Filename: https://www.rizonesoft.com/downloads/notepad3/update/; Description: {cm:tsk_LaunchWelcomePage}; Flags: nowait postinstall shellexec skipifsilent unchecked


[InstallDelete]


[UninstallDelete]


[Code]

#ifdef UNICODE
  #define AW "W"
#else
  #define AW "A"
#endif
type
  TDriveType = (
    dtUnknown,
    dtNoRootDir,
    dtRemovable,
    dtFixed,
    dtRemote,
    dtCDROM,
    dtRAMDisk
  );
  TDriveTypes = set of TDriveType;

function GetDriveType(lpRootPathName: string): UINT;
  external 'GetDriveType{#AW}@kernel32.dll stdcall';
function GetLogicalDriveStrings(nBufferLength: DWORD; lpBuffer: string): DWORD;
  external 'GetLogicalDriveStrings{#AW}@kernel32.dll stdcall';

var
  DirCombo: TNewComboBox;

#ifndef UNICODE
function IntToDriveType(Value: UINT): TDriveType;
begin
  Result := dtUnknown;
  case Value of
    1: Result := dtNoRootDir;
    2: Result := dtRemovable;
    3: Result := dtFixed;
    4: Result := dtRemote;
    5: Result := dtCDROM;
    6: Result := dtRAMDisk;
  end;
end;
#endif

function GetLogicalDrives(Filter: TDriveTypes; Drives: TStrings): Integer;
var
  S: string;
  I: Integer;
  DriveRoot: string;
begin
  Result := 0;

  I := GetLogicalDriveStrings(0, #0);
  if I > 0 then
  begin
    SetLength(S, I);
    if GetLogicalDriveStrings(Length(S), S) > 0 then
    begin
      S := TrimRight(S) + #0;
      I := Pos(#0, S);
      while I > 0 do
      begin
        DriveRoot := Copy(S, 1, I - 1);
        #ifdef UNICODE
        if (Filter = []) or
          (TDriveType(GetDriveType(DriveRoot)) in Filter) then
        #else
        if (Filter = []) or
          (IntToDriveType(GetDriveType(DriveRoot)) in Filter) then
        #endif
        begin
          Drives.Add(DriveRoot);
        end;
        Delete(S, 1, I);
        I := Pos(#0, S);
      end;
      Result := Drives.Count;
    end;
  end;
end;

procedure DriveComboChange(Sender: TObject);
begin
  WizardForm.DirEdit.Text := DirCombo.Text;
end;

procedure InitializeWizard;
var
  I: Integer;
  StringList: TStringList;
begin
  StringList := TStringList.Create;
  try
    if GetLogicalDrives([dtFixed], StringList) > 0 then
    begin
      WizardForm.DirEdit.Visible := False;
      WizardForm.DirBrowseButton.Visible := False;

      DirCombo := TNewComboBox.Create(WizardForm);
      DirCombo.Parent := WizardForm.DirEdit.Parent;
      DirCombo.SetBounds(WizardForm.DirEdit.Left, WizardForm.DirEdit.Top,
        WizardForm.DirBrowseButton.Left + WizardForm.DirBrowseButton.Width -
        WizardForm.DirEdit.Left, WizardForm.DirEdit.Height);
      DirCombo.Style := csDropDownList;
      DirCombo.OnChange := @DriveComboChange;

      for I := 0 to StringList.Count - 1 do
        DirCombo.Items.Add(StringList[I] + '{#SetupSetting('DefaultDirName')}');

      DirCombo.ItemIndex := 0;
      DirCombo.OnChange(nil);
    end;
  finally
    StringList.Free;
  end;
 end;