==================================================
%{COMPANY} %{RELEASE} CHANGES
==================================================

--------------------------------------------------
Version %{VERSION} (%{MONTH} %{DAY}, %{YEAR})
--------------------------------------------------

Platform and Toolchain:
- Updated: AutoIt to version 3.3.18.0 – https://www.autoitscript.com/autoit3/docs/history.htm

SDK Framework:
- Migrated: To use Resolute SDK 11 shared includes structure
- Enhanced: Integration with SDK shared subsystems (About, Donate, Logging, Update, etc.)
- Added: ProgressBar.au3 include for visual feedback

UI/UX:
- Redesigned: Button layout with Optimize, Preferences, and Close buttons (standard Windows buttons)
- Added: Close button that minimizes to system tray
- Added: Force behave checkbox on main interface for quick access
- Added: Countdown timer display showing automatic optimization status (OFF/AUTO/seconds)
- Added: Complete system tray icon integration with dynamic memory indicators
- Added: Tray menu with Show/Hide, Optimize, and Exit options
- Fixed: Main window now non-resizable (removed WS_SIZEBOX)
- Fixed: Flickering completely eliminated with GUISetBkColor background
- Improved: Visual feedback during memory optimization process
- Optimized: Memory stats update frequency (2 seconds) to reduce flickering
- Changed: Removed custom colored buttons, using standard Windows button style

Core Features - Memory Optimization:
- Implemented: Complete memory optimization engine
- Added: Three optimization modes (Intelligent, Timer-based, Manual)
- Added: Intelligent mode automatically optimizes when memory exceeds 90%
- Added: Timer-based mode with configurable intervals (5-120 seconds)
- Changed: Default mode is now automatic optimization every 60 seconds
- Added: Countdown timer display with real-time updates
- Added: Process working set clearing for all system processes
- Added: Real-time progress tracking during optimization
- Added: Automatic timer reset after optimization completion
- Optimized: Performance with minimal CPU impact during optimization

System Tray Integration:
- Added: Complete system tray icon with dynamic memory usage indicators (12 icon states)
- Added: Tray icon updates every 5 seconds reflecting current memory usage
- Added: Tray tooltip showing program name and current memory percentage
- Added: Tray menu with Show/Hide toggle, Optimize Now, and Exit options
- Added: Minimize to tray functionality via Close button
- Added: Double-click tray icon to show/hide main window

Core Features - Force Behave:
- Added: "Force malicious processes to behave" functionality
- Implemented: Automatic priority reduction for high-priority processes
- Added: Process priority checking and normalization during optimization

Preferences and Configuration:
- Added: Complete Optimization tab in Preferences dialog
- Added: Memory optimization mode selection (Intelligent/Timer/Manual)
- Added: Configurable automatic optimization interval (5-120 seconds)
- Changed: Default is now Timer mode with 60 second intervals (not Manual)
- Added: "Force malicious processes to behave" checkbox (main GUI and preferences)
- Added: "Start Memory Booster when Windows starts" checkbox
- Added: "Show Memory Booster always on top" checkbox
- Added: "Show program notifications" checkbox
- Added: "Play sounds on program events" checkbox
- Added: "Play warning sounds" with configurable intervals (1-120 seconds)
- Added: Configurable warning memory load threshold (50-95%)
- Fixed: Preferences warning line layout now properly fits on two lines
- Fixed: Save button now ALWAYS enables when ANY setting is changed
- Fixed: INI default values now properly set to Timer mode (2) and 60 seconds
- Fixed: All combo boxes trigger preference change detection
- Implemented: Real-time "Always on Top" toggle
- Implemented: Force behave checkbox on main interface saves immediately
- Enhanced: All settings persist and load correctly with proper defaults

Language System:
- Added: Localization support for optimization UI strings
- Enhanced: Custom localization with status messages
- Fixed: Language file encoding and consistency

Memory Management and Performance:
- Fixed: Info Tip Display
- Fixed: Second instance of the program closes all other instances
- Added: Korean Translation
- Fixed: Show Windows Content while dragging not resetting on Exit

Language Changes:
- [Donate]: Label_Heading = %{Program.Name} has been serving you for over %d hours. Now, how about a small donation?
- [Donate]: Label_Message = Click on the PayPal button below, choose an amount, and send us the donation. Your donation will be used to improve our software and keep everything free on Rizonesoft. A $20 donation will keep us going for at least a month.
- [Donate]: Label_Donate = Would you consider a small gift of $10 to help us improve %{Program.Name} and keep the lights on?

--------------------------------------------------
Version 6.0.2.5522 (MARCH 07, 2021)
--------------------------------------------------

- Cleaner optimized code.
- Main Window is now Resizable.
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
- Added Afrikaans language file.
- Alt+F4 now closes the program and not Esc. (Safer!)
- New Global error count for the logging subsystem.
- Moved Documents to Docs folder.
- New Help (chm) file.
- Now more customizable.
- Minor cosmetic changes.

--------------------------------------------------
Version 1.0.0.815
--------------------------------------------------

No history recorded.

==================================================