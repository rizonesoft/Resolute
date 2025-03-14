==================================================
%{COMPANY} %{RELEASE} CHANGES
==================================================

--------------------------------------------------
Version %{VERSION} (%{MONTH} %{DAY}, %{YEAR})
--------------------------------------------------

- Added: Option to only reduce memory when system free memory is below a specified percentage (5-90%)
- Added: System-wide memory monitoring with configurable threshold (default 20%)
- Enhanced: Memory reduction now considers both process-specific limits and system-wide memory state
- Fixed: Memory usage display showing incorrect 0 MB values
- Fixed: Memory threshold now checks total usage across all processes
- Fixed: Extended processes memory tracking and display
- Enhanced: Memory usage updates now occur every 1000ms for better performance
- Improved: Memory clearing logic to handle multiple processes more efficiently
- Added: Smarter memory threshold checks for better resource management
- Enhanced: Memory statistics display with color-coded status indicators
- Optimized: GUI update frequency for better performance

--------------------------------------------------
Version 11.8.3.8520 (DECEMBER 5, 2024)
--------------------------------------------------

- Improved: Made minor code enhancements for better performance and stability.
- Resolved issues affecting all language versions.
- Added more browser safe mode and incognito commands.

--------------------------------------------------
Version 11.8.3.8516 (NOVEMBER 30, 2024)
--------------------------------------------------

- Fixed: An issue where settings were not being saved correctly.
- Fixed: The 'Decline' option was missing on the installation promo screen.
- Enhanced: Streamlined the About pages by removing unnecessary content.
- Improved: Made minor code enhancements for better performance and stability.

--------------------------------------------------
Version 11.8.3.8509 (NOVEMBER 20, 2024)
--------------------------------------------------

- Optimized language loading system with caching mechanism
- Improved string replacement efficiency in localization
- Code refactoring and performance improvements

--------------------------------------------------
Version 11.8.3.8398 (OCTOBER 30, 2023)
--------------------------------------------------

- Upgraded Rizonesoft SDK to Version 11.
- Enhanced Social Media Link Integration in the 'About' Dialog.
- Optimized Memory Usage Indicator Stability in the 'About' Dialog.
- Rectified Icon Display in the 'Donate' Dialog.
- Codebase Optimization and Refactoring.

--------------------------------------------------
Version 9.8.3.8388 (SEPTEMBER 27, 2023)
--------------------------------------------------

- Update notification optimization.
- Minor bug fixes and enhancements.

--------------------------------------------------
Version 9.8.3.8365 (SEPTEMBER 16, 2023)
--------------------------------------------------

- Installer enahancements.
- Update notification enhancements.
- Minor bug fixes and enancements.

--------------------------------------------------
Version 9.8.3.8153 (AUGUST 26, 2023)
--------------------------------------------------

- Updated Japanese Translation.
- Updated links.
- Completed all translations.

--------------------------------------------------
Version 9.8.3.8112 (JULY 30, 2023)
--------------------------------------------------

- Extended Processes now optimizes all occurrences.
- Tweaked and optimized the memory management functions.
- Process Usage and Peak are now being displayed correctly.
- Fixed English language file.

--------------------------------------------------
Version 9.6.3.8086 (MAY 20, 2023)
--------------------------------------------------

- Updated Afrikaans translation.
- Updated Windows 11 compatibility.

--------------------------------------------------
Version 9.5.3.8055 (OCTOBER 31, 2022)
--------------------------------------------------

- Updated Slovenian Translation

--------------------------------------------------
Version 9.5.3.8028 (OCTOBER 02, 2022)
--------------------------------------------------

- Fixed extended processes usage display.
- Optimized memory statistics display.
- Cleaned code and optimized functions.
- Minor bug fixes and enhancements.
- This version requires a clean install.

--------------------------------------------------
Version 9.5.3.8008 (OCTOBER 01, 2022)
--------------------------------------------------

- Updated AutoIt to version 3.3.16.1 (19 Septemeber 2022). - https://www.autoitscript.com/autoit3/docs/history.htm
- Further Windows 11 compatibility improvements.
- Reworked optimization function for better accuracy.
- Implemented Firemin Server functionality. 
- Minor bug fixes and enhancements.

--------------------------------------------------
Version 9.0.3.5608 (SEPTEMBER 18, 2022)
--------------------------------------------------

- Updated AutoIt to version 3.3.16.1. - https://www.autoitscript.com/autoit3/docs/history.htm
- Improved Windows 11 compatibility.
- Fixed versioning.

--------------------------------------------------
Version 8.2.3.5338 (NOVEMBER 01, 2021)
--------------------------------------------------

- Updated AutoIt to version 3.3.15.4
- Improved Windows 11 compatibility.

--------------------------------------------------
Version 8.2.3.5332 (JUNE 12, 2021)
--------------------------------------------------

- Fixed: All executables are now signed.
- Updated: Inno Setup to version 6.2.0.

--------------------------------------------------
Version 8.1.3.5230 (MAY 25, 2021)
--------------------------------------------------

Updated: Japanese Translation.
Updated: Simplified Chinese Translation.
Removed: Uninstall Message.

--------------------------------------------------
Version 8.1.3.5133 (APRIL 07, 2021)
--------------------------------------------------

- Changed: Default startup position now set to the middle of the screen.
- Updated: Korean translation.
- Updated: Simplified Chinese translation.
- Added: Arabic translation.

--------------------------------------------------
Version 8.1.3.5128 (MARCH 26, 2021)
--------------------------------------------------

- Added: High resolution icon (256x256px).
- Updated: Japanese translation.
- Updated: Optimized browser Safe Mode detection.
- Fixed: Incorrect default values.
- Fixed: Main windows not being able to close.
- Fixed: Workarounds added to alleviate slow downs on Windows 10 1809 and later.

Language Changes:
- [Custom]: Label_Notice = %{Program.Name} is designed to run on a desktop computer or laptop.
			We created Firemin Server for server environments. Read more...

--------------------------------------------------
Version 8.1.3.5113 (MARCH 09, 2021)
--------------------------------------------------

- Updated: Korean translation.
- Fixed: License file variables.
- Fixed: Info Tip Display.
- Fixed: Second instance of the program closes all other instances.

Language Changes:
- [Donate]: Label_Heading = %{Program.Name} has been serving you for over %d hours. Now, how about a small donation?
- [Donate]: Label_Message = Click on the PayPal button below, choose an amount, and send us the donation. Your donation will be used to improve our software and keep everything free on Rizonesoft. A $20 donation will keep us going for at least a month.
- [Donate]: Label_Donate = Would you consider a small gift of $10 to help us improve %{Program.Name} and keep the lights on?

--------------------------------------------------
Version 6.3.1.5105 (MARCH 05, 2021)
--------------------------------------------------

- Fixed: translations encoding (Unicode (UTF-16) LE BOM).
- Updated: Korean translation.

--------------------------------------------------
Version 6.3.0.5099 (FEBRUARY 28, 2021)
--------------------------------------------------

- Critical Fix: All executables are now signed.
- Fixed: Generating documentation.
- Removed: Opening thank you page after installation.

--------------------------------------------------
Version 6.2.3.5085 (February 25, 2021)
--------------------------------------------------

- Updated Korean language.
- Updated Simplified Chinese language.
- Update initial values for processor usage optimization.

--------------------------------------------------
Version 6.2.3.5082 (September 01, 2020)
--------------------------------------------------

- Fixed: Corrupt language files.

--------------------------------------------------
Version 6.2.3.5069 (August 31, 2020)
--------------------------------------------------

- Fixed: GUIOnEventMode and TrayOnEventMode options had unnecessary slow downs.
- Fixed: Workarounds added to alleviate slow downs on Windows 10 1809 and later (OS bug/design change).
- Fixed: About page Memory usage par display.
- Updated support URL on the About page.
- Improved Resolute Compatibility.
- Updated Japanese Translation.

--------------------------------------------------
Version 6.2.3.5065 (April 10, 2020)
--------------------------------------------------

- All executables now signed.

--------------------------------------------------
Version 6.2.3.5063 (April 02, 2020)
--------------------------------------------------

- Added support for Persian language.
- Added Persian translation.
- Important security updates!

--------------------------------------------------
Version 6.2.3.5058 (October 25, 2018)
--------------------------------------------------

- Added missing Korean translation.
- Added Persian translation.

--------------------------------------------------
Version 6.2.3.5058 (October 25, 2018)
--------------------------------------------------

- Updated Spanish translation.
- Added Hungarian translation.
- Added 5, 10, 20, and 50 increments to "Reduce memory if usage is over X".

--------------------------------------------------
Version 6.2.3.5055 (October 16, 2018)
--------------------------------------------------

- Increased increments for "Reduce memory if usage is over X".
- Fixed wrong Korean flag and added Korean translation.
- Updated Greek translation.
- Updated Russian translation.

--------------------------------------------------
Version 6.1.0.5035 (September 17, 2018)
--------------------------------------------------

- Updated to AutoIt version 3.3.14.5 (16 March, 2018)
- Fixed Afrikaans language code.
- Added Turkish Language.

--------------------------------------------------
Version 6.1.0.5030 (June 10, 2018)
--------------------------------------------------

- Removed shortened links to comply with GDPR.

--------------------------------------------------
Version 6.1.0.5025 (June 06, 2018)
--------------------------------------------------

- Updated Portuguese language file.
- Updated Slovenian language file.
- Fixed Traditional Chinese (Taiwan) flag icon.

--------------------------------------------------
Version 6.1.0.5020 (May 17, 2018)
--------------------------------------------------

- Remove redundent variables and functions.
- Fixed Automatically closing applications during update install.
- Optimized calling Terminate versus Exit functions.
- New process priority setting.
- New "Reduce Memory on low memory systems" feature.
- Fixed some language string variables.
- Added Afrikaans translation.
- Added support for Traditional Chinese (zh-TW).
- Added Traditional Chinese translation.
- Added [Preferences] Tab_Performance = Performance.
- Added [Preferences] Group_Notifications = Notifications.
- Added [Preferences] Group_Priority = Priority.
- Added [Preferences] Group_Memory = Memory.
- Added [Preferences] Label_SetPriority = Set process priority:
- Added [Preferences] Checkbox_SaveRealtime = Save priority above high (not recommended).
- Added [Preferences] Checkbox_ReduceMemory = Reduce memory on low memory systems.
- Renamed [Update] Button_Update = Download new version to Button_Update = Read more.

--------------------------------------------------
Version 6.1.0.4998 (May 09, 2018)
--------------------------------------------------

- Fix: Automatically closing applications produces an error during update install.
- Updated French translation.

--------------------------------------------------
Version 6.1.0.4988 (May 09, 2018)
--------------------------------------------------

- Added Portuguese Translation (pt).
- Added Support for Brazilian Portuguese (pt-BR).
- Changed current Portuguese Translation to Brazilian Portuguese.

--------------------------------------------------
Version 6.1.0.4986 (May 07, 2018)
--------------------------------------------------

- Optimize: Registry write error return.
- Fix: Double registry error return.
- Fix: Logging final message with error count.
- Fix: Windows 10 manifest compatibility. Detecting Windows 10 as Windows 8.1.
- Added Portuguese Translation
- Updated Greek TRanslation

--------------------------------------------------
Version 6.1.0.4982 (May 01, 2018)
--------------------------------------------------

- Change: Help -> Contact to Help -> Get Support.
- Change: Contact links to Support page links.
- Added: Spanish Translation.
- Added: Missing Singleton = Another occurence of %{Program.Name} is already running.
- Fix: MsgBox_Language_Message language sting now retrieves correct program name. 
- Help_Contact = &Contact %{Company.Name} changed to Help_Support = &Get Support.
- Change: About -> Label_Support = Contact Us changed to Label_Support = Get Support.
- Added: Preferences -> Checkbox_Notifications = Show tray notifications language string.

--------------------------------------------------
Version 6.1.0.4963 (March 19, 2018)
--------------------------------------------------

- Fix: Firemin Window showing on each run.
- Fix: Firemin disables 'Show Window contents while dragging' Windows setting.
- Fix: Wrong Slovenian flag icon.
- Fix: Wrong 'settings updated' message.
- Added: Setting for disabling tray notifications.
- Clean: Removed redundant code.

--------------------------------------------------
Version 6.1.0.4935 (March 12, 2018)
--------------------------------------------------

- Added Simplified Chinese language.
- Fixed Run Browser menu translated strings.

--------------------------------------------------
Version 6.1.0.4933 (March 06, 2018)
--------------------------------------------------

- Firemin still running tray notice now only shown on first run.
- Unnecessary code cleanup.
- Fix: Language distribution to ensure language files are distributed.
- Added German language file.
- Added support for Hungarian language.
- Added support for Slovenian language.
- Added Slovenian language file.

--------------------------------------------------
Version 6.1.0.4920 (February 13, 2018)
--------------------------------------------------

- Fix: Not able to select language with installed version.
- Removed installer update check. (Could be the reason behind all the false malware detections)
- Update files are now downloaded to the Windows Temp directory.
- Removed the caching folder, including related functions. (Redundant)
- UPX Compressed. (was not causing the false malware detections)
- Added language name translations next to english name.
- Added instructions (comments) to help with translating in language files.
- Added Japanese Language.
- Added French Language.

--------------------------------------------------
Version 6.0.1.4898 (February 06, 2018)
--------------------------------------------------

- Fix: Tray icon now removed on program exit.
- New: Tray message informing the user about Firemin still running in the background.
- New: Single-Click on tray icon, now opens main interface.
- [Custom] Tip_Minimized_Title - Tray message title.
- [Custom] Tip_Minimized_Message - Tray message body.

--------------------------------------------------
Version 6.0.1.4856 (January 21, 2018)
--------------------------------------------------

- Fix: Inconsistent Resource strings (Executable Description).
- Change: Only one instance of Firemin allowed.
- Uncompressed (UPX) version to battle anti-virus false positives.
- Fix: Italian language file (it.ini) now distributed.

--------------------------------------------------
Version 6.0.0.4850 (January 05, 2018)
--------------------------------------------------

- Fix: Extended Processes button now works.
- Added Italian language

--------------------------------------------------
Version 6.0.0.4839 (January 01, 2018)
--------------------------------------------------

- Added Russian and Greek languages.
- Fix: Firemin 64bit now also updated.

--------------------------------------------------
Version 6.0.0.4833 (December 28, 2017)
--------------------------------------------------

- Added Polish Language.
- Fix: Uptime monitor now works.

--------------------------------------------------
Version 6.0.0.4830 (December 23, 2017)
--------------------------------------------------

- Fix: While Firemin is running, the Esc key will not work.

--------------------------------------------------
Version 6.0.0.4825 (December 22, 2017)
--------------------------------------------------

- Cleaner optimized code.
- Removed unsupported Win10 AutoIt directive.
- External resource dlls removed. Icons now embedded in exe.
- Improved update notification system with option to disable update checks.
- Added option to manually check for updates to the Help menu.
- Added update animation.
- Added customizable splash delay.
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
- Alt+F4 now closes the program and not Esc. (Safer!)
- Moved Documents to Docs folder.
- Show Settings on First Run.
- More Boost and Limit options.
- Extended Processes moved to Preferences dialog.
- Safe mode command database now working.
- Minor cosmetic changes.

--------------------------------------------------
Version 4.0.2.4615 (December 14, 2016)
--------------------------------------------------

- Critical Update Notification Fix.
- More optimization timing options.

--------------------------------------------------
Version 4.0.2.4612 (December 04, 2016)
--------------------------------------------------

- Now shows the Firemin icon if exe not found.
- 64 Bit version included.
- Smoother process statistics display.
- Minor Interface tweeks.
- Minor Bug Fixes.

--------------------------------------------------
Version 4.0.2.4600 (November 06, 2016)
--------------------------------------------------

- Exes are now signed.
- New installation utility.
- Now built on the ReBar Framework.
- New Update Notification System.
- Resources moved to external Dll files.
- Added support for Windows 10.
- New Interface.
- New Logging System.
- Cleaner Optimized Code.
- Removed Profiles (Now detects process from selected executable).
- Now shows process usage on main Firemin window.
- New Extended Processes feature.

--------------------------------------------------
Version 3.9.7.3971 (January 9th, 2015)
--------------------------------------------------

- Options are being saved now.
- Traymenu text now updates on profile change.
- Fixed the Save profile button (it updates correctly now).
- Fixed the Limit Clean function.
- Palemoon Profile Fixed (Safe Mode Command).
- Completed the Waterfox profile.
- Added a Cyberfox profile.
- Added a Comodo IceDragon profile.
- Karma system implemented.

--------------------------------------------------
Version 3.9.0.3905 (January 3rd, 2015)
--------------------------------------------------

- Everything redesigned from scratch.
- New Options Dialog.
- New Select, Create and Edit Profiles.
- New Firefox Profile.
- New Palemoon Profile.

--------------------------------------------------
Version 2.0.8.2086 (August 31st, 2014)
--------------------------------------------------

- Now Open Source (GNU General Public License version 3)

--------------------------------------------------
Version 2.0.8.2083 (May 22nd, 2014)
--------------------------------------------------

- Some minor bug fixes
- Some minor cosmetic changes

--------------------------------------------------
Version 2.0.5.2055 (January 10th, 2014)
--------------------------------------------------

- Now compatible with Windows 8.1.
- The About page can now be opened without an error
- Some minor cosmetic changes on the Options and About windows.
- Updated the documentation and About pages
- Some minor bug fixes and compatibility changes

--------------------------------------------------
Version 2.0.1.11 (February 15th, 2013)
--------------------------------------------------

- Windows 8 and 64Bit compatibility.
- Sarcasm added.
- A few cosmetic changes.
- Some minor bug fixes.

--------------------------------------------------
Version 0.3.6.369 (May 27th, 2012)
--------------------------------------------------

Removed the update option because our server was getting a little overloaded.

--------------------------------------------------
Version 0.3.6.365 (May 25th, 2012)
--------------------------------------------------

Some link Updates

--------------------------------------------------
Version 0.3.6.360 (May 15th, 2012)
--------------------------------------------------

New Update Option

--------------------------------------------------
Version 0.3.5.351 (May 15th, 2012)
--------------------------------------------------

Now detects Firemin folder access permissions and writes settings to INI file and Registry respectively.

--------------------------------------------------
Version 0.1.9.195 (July 5th, 2011)
--------------------------------------------------

- New Options dialog
- New About dialog
- Now you can change memory minimization rate
- Launch Firefox (Safe Mode) when Firemin starts
- Firefox Optimization function (uses SQLite vacuum for databases)

--------------------------------------------------
Version 0.0.1.19 (June 7th, 2011)
--------------------------------------------------

New Configuration file for tweaking it a little.

--------------------------------------------------
Version 0.0.1.12 (June 3rd, 2011)
--------------------------------------------------

No history recorded.

==================================================