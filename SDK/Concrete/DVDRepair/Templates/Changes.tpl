==================================================
%{:COMPANY:} %{:RELEASE:} CHANGES
==================================================

--------------------------------------------------
Version %{VERSION} (%{MONTH} %{DAY}, %{YEAR})
--------------------------------------------------

- Fixed: GUIOnEventMode and TrayOnEventMode options had unnecessary slow downs.
- Fixed: Workarounds added to alleviate slow downs on Windows 10 1809 and later (OS bug/design change).
- Improved Resolute compatibility.

--------------------------------------------------
Version 2.0.3.1113 (May 28, 2020)
--------------------------------------------------

- Optimized Functions.
- Cleaner Code.
- Resolute Compatibility.

--------------------------------------------------
Version 2.0.3.1108 (April 10, 2020)
--------------------------------------------------

- All executables now signed.

--------------------------------------------------
Version 2.0.3.1105 (April 02, 2020)
--------------------------------------------------

- Fixed incorrect language flag icons.
- Removed Google Plus from the About page and replaced it with LinkedIn. 
- Aligned Uncompiled icons.

--------------------------------------------------
Version 2.0.3.1100 (September 19, 2018)
--------------------------------------------------

- Updated to AutoIt version 3.3.14.5 (16 March, 2018)
- Fixed Welcome Message String Format Bug.
- Fixed Welcome Message wrong color after update check.

--------------------------------------------------
Version 2.0.0.1090 (June 10, 2018)
--------------------------------------------------

- Removed shortened links to comply with GDPR.
- Added Traditional Chinese language.
- Fixed Traditional Chinese (Taiwan) flag icon.
- Fixed Automatically closing applications during update install.
- Optimized calling Terminate versus Exit functions.

--------------------------------------------------
Version 2.0.0.1080 (May 17, 2018)
--------------------------------------------------

- New process priority setting.
- New "Reduce Memory on low memory systems" feature.
- Fixed "Logging Cleared" displaying wrong message.
- Fixed some language string variables.
- Added support for Traditional Chinese (zh-TW).
- Added [Preferences] Tab_Performance = Performance.
- Added [Preferences] Group_Priority = Priority.
- Added [Preferences] Group_Memory = Memory.
- Added [Preferences] Label_SetPriority = Set process priority:
- Added [Preferences] Checkbox_SaveRealtime = Save priority above high (not recommended).
- Added [Preferences] Checkbox_ReduceMemory = Reduce memory on low memory systems.
- Renamed [Preferences] Group_General = General to Group_Logging = Logging.
- Renamed [Update] Button_Update = Download new version to Button_Update = Read more.

--------------------------------------------------
Version 2.0.0.1058 (May 09, 2018)
--------------------------------------------------

- Fix: Automatically closing applications produces an error during update install.
- New Processing animation. 
- Added Support for Brazilian Portuguese (pt-BR).
- Fixed Brazilian Portuguese language file encoding.
- Changed current Portuguese Translation to Brazilian Portuguese.

--------------------------------------------------
Version 2.0.0.1053 (May 07, 2018)
--------------------------------------------------

- Optimize: Registry write error return.
- Fix: Double registry error return.
- Fix: Logging final message with error count.
- Fix: Windows 10 manifest compatibility. Detecting Windows 10 as Windows 8.1.
- Added Portuguese Translation

--------------------------------------------------
Version 2.0.0.1050 (April 30, 2018)
--------------------------------------------------

- Fix: Preferences dialog control positioning.
- Change: Help -> Contact to Help -> Get Support
- Change: Contact links to Support page links
- Added Spanish Translation.
- Removed Cache Language strings.
- Removed Group_Logging language string.
- Added: Group_General = General language string.
- Help_Contact = &Contact %{Company.Name} changed to Help_Support = &Get Support
- Change: About -> Label_Support = Contact Us changed to Label_Support = Get Support

--------------------------------------------------
Version 2.0.0.1025 (March 12, 2018)
--------------------------------------------------

- Fix: Not able to select language with installed version.
- Removed installer update check. (Could be the reason behind all the false malware detections)
- Update files are now downloaded to the Windows Temp directory.
- Removed the caching folder, including related functions. (Redundant)
- No UPX Compression.
- Added language name translations next to english name.
- Added instructions (comments) to help with translating in language files.
- Added support for Hungarian language.
- Added support for Slovenian language.

--------------------------------------------------
Version 2.0.0.1016 (January 05, 2018)
--------------------------------------------------

- Fix: Changelog not displaying proper date.
- Added French and Creek languages.

--------------------------------------------------
Version 2.0.0.1015 (December 28, 2017)
--------------------------------------------------

- Removed unnecessary _Localization_Messages() call. 
- Fix: Dialog Parent set when Parent not active.
- Fix: Wrong Preferences dialog icon at runtime when not compiled.
- Changed DPI Awareness Mode to Unaware for now.

--------------------------------------------------
Version 2.0.0.1006 (December 10, 2017)
--------------------------------------------------

- Improved language file loading.

--------------------------------------------------
Version 2.0.0.1003 (December 07, 2017)
--------------------------------------------------

- Cleaner optimized code.
- Removed unsupported Win10 AutoIt directive.
- New menus design with icons.
- Resources now embedded in main Executable. No more external resource Dlls.
- Improved update notification system with option to disable update checks.
- Added update animation.
- Added GitHub link to the Help menu to quickly create an issue.
- Added GitHub link on the About Dialog.
- Added Downloads, Contact and Donate links to the Help menu.
- New PayPal.me donation link (PayPal.me/rizonesoft).
- New none-intrusive Donate prompt after a set time. (120 Hours Default)
  The Donate prompt will only be shown once.
- Improved custom Progress Bar. 
- Improved About Dialog (New Mouse Hover Effects for Image Buttons).
- Improved Splash Screen (New custom Progress Bar).
- Added Localization (Translations).
- Added Afrikaans language file.
- Alt+F4 now closes the program and not Esc. (Safer)
- New Global error count for the logging subsystem.
- Moved Documents to Documents folder.
- Mouse over event now not firing on disabled Options.
- Errors now indicated on progress display.
- Improved reboot messages.
- New Icon and Minor Interface Tweaks and enhancements.

--------------------------------------------------
Version 1.0.2.852 (January 08, 2017)
--------------------------------------------------

- New Link to Fix DVD Drive missing from Windows guide.
- New Windows Hardware Troubleshooter.
- New Device Manager Shortcut.
- Now also tries Restoring the ATAPI disk interface.

--------------------------------------------------
Version 1.0.2.828 (December 14, 2016)
--------------------------------------------------

- Critical Update Notification Fix.

--------------------------------------------------
Version 1.0.2.823 (November 27, 2016)
--------------------------------------------------

- Disable Extras, now called Just Repair. Makes more sense.
- Cleaner interface. Moved About and Close into the menus.
- New options for managing Logging and Cache.
- Moved System Restore and Firmware update to Tools menu.
- Removed Reboot Message Box.
- Minor bug fixes.
- Minor cosmetic changes.

--------------------------------------------------
Version 1.0.2.686 (November 06, 2016)
--------------------------------------------------

- Updated the ReBar Framework.
- New Option to disable Autorun reset and Protection.
- Now saves options on exit.
- Cut about 1MB from the total size.
- Minor bug fixes.
- Minor cosmetic changes.

--------------------------------------------------
Version 1.0.2.638 (October 22, 2016)
--------------------------------------------------

- Updated Fugue.dll
- Fixed program freezing on Exit.
- Optimized the Update Notification System.
- Small bug fixes and Enhancements.
- New Registry based Method for configuring Services.

--------------------------------------------------
Version 1.0.2.616 (October 09, 2016)
--------------------------------------------------

- Fixed a critical error that stopped the 32-bit version from running.
- Updated DoorsShell.dll.
- Updated the Update Notification System.

--------------------------------------------------
Version 1.0.2.553 (September 25, 2016)
--------------------------------------------------

- Added support for Windows 10.
- Rewrote code from scratch.
- New logging system.
- New update notification system.

--------------------------------------------------
Version 0.4.3.430 (August 31, 2014)
--------------------------------------------------

- Now Open Source (GNU General Public License version 3)

--------------------------------------------------
Version 0.4.2.423 (May 22, 2014)
--------------------------------------------------

- Name changed from CD-DVD Icon repair to DVD Drive Repair
- New interface design with new Icons
- Updated links and about information
- Fixed some minor bugs
- Added a 64Bit version (Better support for 64Bit Windows)
- Added support for Windows 8 and Windows 8.1
- Updated Documentation

--------------------------------------------------
Version 0.2.8.280 (September 18, 2013)
--------------------------------------------------

- Cleaned the code a little
- Some minor bug fixes

--------------------------------------------------
Version 0.2.6.263 (September 18, 2013)
--------------------------------------------------

No recorded history

==================================================