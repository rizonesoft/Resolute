If you...

...run FontReg.exe without any command-line switches:

  * FontReg will remove any stale font registrations in the registry.
  * FontReg will repair any missing font registrations for fonts located in
    the C:\Windows\Fonts directory (this step will be skipped for .fon fonts if
    FontReg cannot determine which fonts should have "hidden" registrations).

...run FontReg.exe with the /copy or /move switch:

  * FontReg will install all files with a .fon, .ttf, .ttc, or .otf file
    extension located in the CURRENT DIRECTORY (which might not necessarily be
    the directory in which FontReg is located).  Installation will entail
    copying/moving the files to C:\Windows\Fonts and then registering the fonts.
  * FontReg will remove any stale font registrations in the registry.
  * FontReg will repair any missing font registrations for fonts located in
    the C:\Windows\Fonts directory (this step will be skipped for .fon fonts if
    FontReg cannot determine which fonts should have "hidden" registrations).

FontReg.exe is intended as a replacement for Microsoft's outdated fontinst.exe,
and like fontinst.exe, FontReg.exe is fully silent--it will not print messages,
pop up dialogs, etc.; the process exit code will be 0 if there was no error.
