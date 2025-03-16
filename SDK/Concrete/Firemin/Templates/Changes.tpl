==================================================
%{COMPANY} %{RELEASE} CHANGES
==================================================

--------------------------------------------------
Version %{VERSION} (%{MONTH} %{DAY}, %{YEAR})
--------------------------------------------------

Language and Localization:
- Changed: Language file extensions from .ini to .lng for better compatibility
- Added: Fifteen additional language files with complete translations:
  * Bulgarian (bg)
  * Czech (cs)
  * Danish (da)
  * Dutch (nl)
  * Hindi (hi)
  * Croatian (hr)
  * Indonesian (id)
  * Icelandic (is)
  * Hebrew (iw)
  * Norwegian (no)
  * Romanian (ro)
  * Slovak (sk)
  * Swedish (sv)
  * Thai (th)
  * Vietnamese (vi)
- Enhanced: Language file consistency and formatting across all translations
- Enhanced: Localization system with improved string handling and caching
- Enhanced: Format string consistency across all language files
- Enhanced: Translation system performance and reliability
- Fixed: Line break handling in language files (\rn replaced with \r\n)
- Fixed: Unicode encoding consistency (UTF-16 LE BOM) in all language files
- Fixed: Unicode handling in RTL language files
- Fixed: Arabic text direction markers and percentage signs
- Improved: RTL support for Arabic and other right-to-left languages
- Improved: Escape sequence handling in translations
- Improved: Multi-line message formatting in all languages
- Added: Automatic language file formatting script
- Added: Consistent line breaks in notification messages
- Updated: Language selection menu with new supported languages
- Updated: Arabic and English language files with proper formatting
- Optimized: Memory usage in localization system with caching

Memory Management and Performance:
- Added: System-wide memory monitoring with configurable threshold (default 20%)
- Added: Option to only reduce memory when system free memory is below a specified percentage (5-90%)
- Added: Smarter memory threshold checks for better resource management
- Enhanced: Memory reduction now considers both process-specific limits and system-wide memory state
- Enhanced: Memory usage updates now occur every 1000ms for better performance
- Enhanced: Resource usage thresholds with warning and critical states
- Fixed: Memory usage display showing incorrect 0 MB values
- Fixed: Memory threshold now checks total usage across all processes
- Fixed: Extended processes memory tracking and display
- Improved: Memory clearing logic to handle multiple processes more efficiently
- Optimized: GUI update frequency for better performance

User Interface Improvements:
- Added: Color-coded progress bars for memory and disk space usage
- Enhanced: About dialog window handling and transparency
- Enhanced: About dialog window state management
- Enhanced: Memory statistics display with color-coded status indicators
- Fixed: About dialog window parenting when main window is minimized
- Fixed: Memory statistics display in About dialog
- Fixed: Memory statistics display in About dialog when main window is in tray
- Fixed: Tray notification icons for Windows 11 compatibility
- Improved: About dialog window handling and transparency
- Optimized: Memory and disk space monitoring in About dialog