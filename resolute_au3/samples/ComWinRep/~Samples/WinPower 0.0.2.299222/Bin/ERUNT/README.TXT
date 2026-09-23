ERUNT - The Emergency Recovery Utility NT
=========================================

Registry Backup and Restore for Windows NT/2000/2003/XP

v1.1j, 10/20/2005, Freeware
Written by Lars Hederer
e-mail: lars.hederer@t-online.de

Look for the latest version here:
http://www.larshederer.homepage.t-online.de/erunt

To find out what's new in this version, please see the "Version
history" section later in this file.



Introduction
------------

With the invention of Windows 95 Microsoft made the wise decision to
organize all computer- and application-specific data which was spread
over countless INI files before in a centralized Windows database,
called the system "registry". The registry is one of the most
important parts in every Windows system today, without which the OS
would not even boot. And since the registry is quite sensitive to
corruption, it is very advisable to backup its according files from
time to time.

In MS-DOS based Windows versions (95, 98, Me) the registry consists of
the files SYSTEM.DAT and USER.DAT (and CLASSES.DAT in Windows Me). To
backup these files, one can easily go to the Windows folder in
Explorer and copy the files to a safe location, for example another
folder on the hard disk. Microsoft even supplies a utility called ERU
which can be used to backup these and a few other critical system
files to a safe location.

Also, Windows 9x/Me automatically create backups of the registry at
startup, with Windows 95 always backing up the registry from the
previous Windows session, and Windows 98/Me maintaining up to five
registry copies from the last five days where Windows was running.

Unfortunately, this is not the case with Windows versions based on the
NT kernel. In Windows NT and 2000, the registry is never backed up
automatically, and in XP it is backed up only as part of the bloated
and resource hogging System Restore program which cannot even be used
for a "restore" should a corrupted registry prevent Windows from
booting. It has also become impossible to copy the necessary files,
now called "hives" and usually named DEFAULT, SAM, SECURITY, SOFTWARE,
SYSTEM in the SYSTEM32\CONFIG folder, to another location because they
are all in use by the OS. And though the registry in an NT-based
Windows is less likely to become corrupted than in other versions, it
can still happen, and for these cases NT is simply missing an option
for easy registry backup and restore as there is in Windows 9x/Me, to
get the system up and running again in no time.

In 2001, as Windows XP began to come pre-installed on many new home
user PCs and was likely to become the new Windows standard over the
next years, I decided to write a program which offers the ease-of-use
of Windows 9x/Me ERU by Microsoft (hence the name ERUNT) to backup the
registry, as well as providing an auto-backup capability, for example
at Windows startup.

Or, before installing a new program for testing purposes one could
save the registry with ERUNT, install and test the program, uninstall
it and restore the registry to be 100% sure that no debris is left.

Note: The "Export registry" function in Regedit is USELESS (!) for
making a complete backup of the registry. Neither does it export the
whole registry (for example, no information from the "SECURITY" hive
is saved), nor can the exported file be used later to replace the
current registry with the old one. Instead, if you re-import the file,
it is merged with the current registry without deleting anything that
has been added since the export, leaving you with an absolute mess of
old and new entries.



Features
--------

- Backup the Windows NT/2000/2003/XP registry to a folder of your
  choice

- System and current user registries selectable

- Command line switches for automated registry backup and restoration

- Restore the registry in Windows 9x/Me/NT/2000/2003/XP and MS-DOS
  (all-in-one restore program) or the Windows Recovery Console

- Included in this package:
  NTREGOPT program for optimizing the registry

- All programs in this package are completely localizable
  (translate them into your language), German version included



Supported operating systems
---------------------------

- Windows NT 3.51
- Windows NT 4.0
- Windows 2000
- Windows 2003
- Windows XP
- most likely, all future Windows versions based on the NT kernel

Additionally supported by the ERDNT restore program:
- MS-DOS
- Windows 95
- Windows 98
- Windows Me



Installation
------------

Use the Setup program to install ERUNT on your computer.

Or, if you downloaded the zipped version: Unzip all files into a
folder of your choice, and if you want, create shortcuts on your
desktop to the ERUNT.EXE and NTREGOPT.EXE files.



Uninstallation
--------------

Use "Add/Remove Programs" in Windows' control panel to remove ERUNT
from your computer.

Or, if you downloaded the zipped version: Delete the ERUNT folder,
delete the appropriate desktop icons.

(You may also want to delete all restore folders you have previously
created with the program.)



Backing up the registry with ERUNT
----------------------------------

Note: To ensure proper operation of ERUNT, you should be logged in as
a system administrator.

Start ERUNT, confirm the Welcome message.

Type in the name of a restore folder where the backed up registry
files should be saved, or click "..." to browse your computer's drives
and select a folder. You can also simply leave the default, which is a
folder named ERDNT inside your Windows folder, the advantage being
that you have access to this folder from the Windows Recovery Console
in case Windows does not boot anymore.

Note that in the folder edit field, ERUNT by default appends a folder
named the current date to the restore folder, which allows you to keep
as many registry backups as you wish in the same restore folder,
separated into the different creation dates. This feature, as well as
the appearance of the date string, can be configured via the ERUNT.INI
file, described later in this document. If you want the registry backup
to be created directly in the folder you select, you can also simply
remove the date from the folder edit field before clicking "OK".

Next, select the backup options:

- System registry: The current system registry, usually consisting of
  the files DEFAULT, SAM, SECURITY, SOFTWARE, and SYSTEM.

- Current user registy: The registry files for the currently logged-on
  user, usually NTUSER.DAT and USRCLASS.DAT.

- Other open user registries: Sometimes Windows has a few other user
  registries in memory. Examples for this are "generic" registries,
  e.g. for user "EVERYONE", or registries of other users if you use
  Fast Task Switching in Windows XP. Check this option to backup all
  these additional user registries (if found) as well.

Click "OK" and wait until the backup process is complete. (Note that
depending on your system configuration this may take some time, and
that the first bar is NOT a progress bar, just an indicator that the
program is still running.) The ERDNT program for later restoration of
the registry is automatically copied to the restore folder.

(Technical information: ERUNT saves only registry files which are in
use by the system. It obtains information about these files from
registry key HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\
hivelist. Registry hives not listed there, for example those
of other users of the computer, cannot be saved by ERUNT.)



ERUNT command line switches
---------------------------

ERUNT supports command line switches with which you can perform an
automated registry backup, without user interaction. The syntax for
the ERUNT command line is as follows:

ERUNT DestinationFolder [sysreg] [curuser] [otherusers]
[/noconfirmdelete] [/noprogresswindow]

DestinationFolder is required for command line operation of ERUNT,
all other switches are optional.

If you specify a destination folder on the command line, ERUNT
automatically runs in "silent" mode and with default backup options
(system and current user registry). No user interaction is required,
EXCEPT the confirmation of the restore folder deletion if it exists,
or any error messages. The confirmation question can be suppressed
by using /noconfirmdelete (see below).

Description of the command line switches:

DestinationFolder
  The name of the folder where the registry backup should be saved.
  Example: C:\WINDOWS\ERDNT
  You can use the strings #Date# and #Time# anywhere in the folder
  name to have ERUNT insert the current date/time at that position.
  Example: C:\WINDOWS\ERDNT\#Date#
  Windows' %SystemRoot% environment variable can be used on the
  command line as a substitute for the name of the Windows folder.
  Example: %SystemRoot%\ERDNT\#Date#

sysreg
  Backup the system registry

curuser
  Backup the current user registry

otherusers
  Backup other open user registries

(Note: If none of the three above options is given on the command
line, ERUNT automatically uses the default backup options, system
and current user registry.)

/noconfirmdelete
  Automatically deletes the contents of the destination folder if it
  exists, without asking the user. BE CAREFUL and only use this option
  if you are sure that the contents of that folder may really be
  deleted!

/noprogresswindow
  Hides the progress window during backup.

So, to backup the system registry to folder C:\ERDNT each day of the
week using subfolders with the name of the current day you could use
the integrated scheduler in Windows to schedule seven different ERUNT
calls for each day:

For Monday you would use the command line
  C:\ERUNT\ERUNT.EXE C:\ERDNT\Monday sysreg /noconfirmdelete

For Tuesday you would use the command line
  C:\ERUNT\ERUNT.EXE C:\ERDNT\Tuesday sysreg /noconfirmdelete

... well, you get the idea.

Or, to have ERUNT automatically backup the registry on each Windows
startup to a folder named "ERDNT" inside the Windows folder, including
a folder named the current date, you could place a shortcut like the
following in your Start Menu/Programs/Startup folder:

  C:\ERUNT\ERUNT.EXE %SystemRoot%\ERDNT\#Date# /noconfirmdelete

If you want old restore folders created this way to be deleted
automatically from time to time, you can use AUTOBACK.EXE instead of
ERUNT.EXE. The AUTOBACK tool is described later in this document.
Also, ERUNT Setup offers the choice to add an AutoBackup shortcut to
the Startup folder automatically during the installation process.



The ERUNT.INI file
------------------

You can configure various ERUNT settings with this file, for example
change the default destination folder displayed in ERUNT's folder edit
field, or disable automatic appendation of the current date there.

Use Notepad to create a file named ERUNT.INI in your ERUNT folder, and
add the following line:

[ERUNT]

Below this line, enter one or more of the following configuration
options:

DefaultDestinationFolder
  The name of the default folder displayed in ERUNT's folder edit
  field. You may also use environment variables here, for example
  %SystemRoot% as a substitute for the name of the Windows folder.
  Default: %SystemRoot%\ERDNT
Example:
DefaultDestinationFolder=C:\ERDNT

AppendDateToFolderEditField
  Enable or disable automatic appendation of the current date to
  ERUNT's folder edit field.
  0=disable, 1=enable, default: 1
Example:
AppendDateToFolderEditField=0

AppendTimeToFolderEditField
  Enable or disable automatic appendation of the current time to
  ERUNT's folder edit field. This function can only be enabled in
  conjunction with AppendDateToFolderEditField also set to 1.
  0=disable, 1=enable, default: 0
Example:
AppendTimeToFolderEditField=1

DateFormat
DateSeparator
  These settings configure the appearance of the date string in
  ERUNT's folder edit field, or when #Date# is used on the command
  line. By default, ERUNT uses Windows' regional settings for the
  short date format. Note that only "." and "-" are allowed as date
  separators.
Example:
DateFormat=mm/dd/yyyy
DateSeparator=-

TimeFormat
TimeSeparator
  These settings configure the appearance of the time string in
  ERUNT's folder edit field, or when #Time# is used on the command
  line. By default, ERUNT uses Windows' regional settings for the
  short time format. Note that only "." and "-" are allowed as time
  separators.
Example:
TimeFormat=hh:mm:ss
TimeSeparator=.

DisableFastBackup
  On supported operating systems (including Windows XP and Server
  2003) ERUNT by default uses a very fast backup algorithm. If you
  experience any problems during registry backup, you can try to
  disable this function and revert back to the conventional (but slow)
  method. This setting has no effect on unsupported operating systems,
  where the conventional algorithm is always used.
  0=fast method, 1=conventional method, default: 0
Example:
DisableFastBackup=1



The AUTOBACK.EXE tool
---------------------

The command line tool AUTOBACK.EXE uses the same syntax as ERUNT but
performs the additional task of deleting old restore folders after the
new backup has been created.

For this to work properly, the name of the last folder in the command
line option DestinationFolder must begin with the current date, or the
#Date# string, respectively. If this is the case AUTOBACK
automatically searches the parent folder of the newly created backup
for folder names of the same date format and deletes all folders
except from the last 30 days where backups have been created.

The number of restore folders to keep can be changed using the /days:n
command line switch, e.g. /days:7 would only keep the folders from the
last 7 backup days.

By default AUTOBACK does not create a new backup if one already exists
for the current day. Use the /alwayscreate switch to change this
behavior and have the program always create a new backup.

AUTOBACK is dependent on ERUNT and therefore needs to be executed from
the same folder. It uses the same settings for the date format as
ERUNT does, so if you specified a new format in ERUNT.INI it will also
be used automatically by AUTOBACK.



Restoring the registry with ERDNT
---------------------------------

Situation: Windows is running normally.

To restore a previous registry backup, open Windows Explorer, navigate
to the folder where you saved the backup to, and double-click the
ERDNT.EXE file to start the restoration program. (Each restore folder
has its own copy of ERDNT.EXE in it.) Select which registry components
to restore, then click "OK" to start restoration. When the process is
complete, click "OK" to restart the computer and activate the restored
registry.

Note: If you experience any problems restoring the registry, please
read "ERDNT technical information" later in this document to learn
what ERDNT is actually doing during the process, or simply read on
through the following emergency scenarios for other ways of restoring
the registry.



What to do if Windows does not boot anymore?
--------------------------------------------

If Windows refuses to boot normally it can be for a variety of
reasons, not the least of which is that the registry is damaged, or
you installed a program or driver which is somewhat incompatible with
the system or buggy, in which case restoring a registry backup from a
point where everything was running smoothly should also help.

The first thing to try is to reboot and press the F8 key immediately
before the first Windows screen appears, then select the "Last Known
Good" option from the menu and see if Windows boots up with this
option. If it does, you're all set.

If it does not, reboot again with F8, and select the option "Safe
Mode". If Windows boots up in safe mode, you can restore a registry
backup just as you would in normal mode, as described above.

If safe mode also fails, read on...



Restoring the registry with ERDNT - Emergency Scenario I
--------------------------------------------------------

Situation: Windows fails to boot up in normal and safe mode, but you
have a DOS boot disk or another (working) operating system installed
on your PC which is supported by the ERDNT restoration program, and
from which you have full access to the drive(s) containing the corrupt
Windows installation and the registry backup.

Boot up to the working OS, and open the folder containing the registry
backup you want to restore.

If the drive letters are different to as they were in the Windows
where you created the registry backup, you need to edit the ERDNT.INF
file now to reflect the new drive letters, before trying to restore
the registry backup. For example, if the drive with the corrupt
Windows installation is now available as D: instead of C:, then you
would change all C:\... references in the INF file to D:\... . Editing
the file can be done in Windows with the Notepad program, and in DOS
with the EDIT command.

Now run the ERDNT.EXE file to start the restoration program. Select
which registry components to restore (just the system registry will do
in most cases), then start restoration. When the process is complete,
reboot the computer and check if the other Windows installation is
repaired now.



Restoring the registry with ERDNT - Emergency Scenario II
---------------------------------------------------------

Situation: Windows fails to boot up in normal and safe mode, and you
have no other working operating system installed on your PC.

The following two rescue methods require that your PC is configured so
that it can boot from CD. See your BIOS documentation for more
information.

1. Bart's PE Builder
Use another computer with Internet access and CD burning capabilities
to download this free program from the Internet (do a Google search
for it), which will create a bootable Windows CD with full access to
all drives (including NTFS). Boot from this CD, open the File
Management Utility and follow the directions in "Emergency Scenario I"
to run ERDNT and restore the registry.

2. The Windows Recovery Console (Windows 2000 and higher)
Note that you can use this method only if you saved the registry
backup inside the Windows folder, and that using this procedure only
the system registry is restored. This should however get you back into
Windows, from where you can run the ERDNT program to restore user
registries, if necessary.
- Boot your system from the Windows 2000/2003/XP CD-ROM.
- At the welcome screen, press "R" (Windows 2000: "R" then "C").
- Type in the number of the Windows installation you want to repair
  (usually 1), then press ENTER.
- Type in the Administrator password (leave blank if you are unsure
  what it is) and press ENTER.
- At the command prompt type
    cd erdnt
  or whatever you named your restore folder, then press ENTER.
- If you enabled automatic registry backup on system boot during ERUNT
  installation and want to restore one of these backups, type
    cd autobackup <ENTER>
- If you created subfolders for different registry backups (for
  example, with the different creation dates), type
    dir <ENTER>
  to see a list of available folders, then type
    cd foldername <ENTER>
  where foldername is the name of a folder listed by the dir command,
  to open that folder.
- Now type
    batch erdnt.con <ENTER>
  to restore the system registry from that folder.
- Type
    exit <ENTER>
  and remove the CD from the CD-ROM drive. The system will now reboot
  with the restored registry.



ERDNT technical information
---------------------------

ERDNT knows two restoration modes. The right mode is usually auto-
detected each time ERDNT is run, but read on if you are experiencing
problems restoring the registry.

"NT" mode is used if you run the ERDNT program from within the same
system where you made the backup. This is determined by looking at the
[SystemRoot] entry in the ERDNT.INF file and comparing it to the
actual %SystemRoot% environment variable. Using "NT" mode is the only
way to successfully restore the active registry of the currently
running OS.

"File copy" mode is used if the currently running OS is NOT NT-based,
or if the [SystemRoot] entry does not match the %SystemRoot%
environment variable. In this mode the backed up registry files are
simply copied back to their original location.

MS-DOS based ERDNT only supports "File copy" mode.

Note: In restoration mode "NT" backups of the current registry files
are automatically created, so that option is grayed out. In
restoration mode "File copy" all saved user registries are
automatically restored, so you cannot choose between "current user"
and "other user" registries.

The backups of the current registry files are placed in the same
location as the original and are given the extension ".bak".

Experienced users don't even need to use the ERDNT program in other
operating systems to restore a registry backup. Given access to the
appropriate files and folders, the backed up files can simply be
copied back to their original location, as that is all ERDNT does
in "File copy" mode anyway. Have a look at the ERDNT.INF file to
find out what the original file locations are.



ERDNT command line switches
---------------------------

The ERDNT program also supports command line switches for "silent"
operation. The syntax for the ERDNT command line is:

ERDNT silent [sysreg] [curuser] [otherusers]
[/mode:nt|filecopy] [/nobackup] [/noprogresswindow] [/reboot]

(Switches in brackets are optional.)

Description of the command line switches:

silent
  Puts ERDNT into "silent" mode and enables all other switches.

sysreg
  Restore the system registry

curuser *
  Restore the current user registry
  (This option is ignored in "File copy" restoration mode.)

otherusers
  Restore other saved user registries

(Note: If none of the three above options is given on the command
line, ERDNT automatically uses the default restoration options, system
and current user registry.)

/mode:nt or /mode:filecopy *
  Disables automatic detection of the correct restoration mode and
  uses mode "NT" or "File copy" instead.

/nobackup
  Don't make backups of the current registry files during restoration.
  (This switch is ignored in "NT" restoration mode.)

/noprogresswindow
  Hides the progress window during restoration.

/reboot *
  Automatically reboots the computer when restoration of the registry
  is complete.

* = Not supported in the DOS version of ERDNT.



Optimizing the registry with NTREGOPT
-------------------------------------

Similar to Windows 9x/Me, the registry files in an NT-based system
can become fragmented over time, occupying more space on your hard
disk than necessary and decreasing overall performance. You should
use the NTREGOPT utility regularly, but especially after installing
or uninstalling a program, to minimize the size of the registry files
and optimize registry access.

The program works by recreating each registry hive "from scratch",
thus removing any slack space that may be left from previously
modified or deleted keys.

Note that the program does NOT change the contents of the registry in
any way, nor does it physically defrag the registry files on the drive
(as the PageDefrag program from SysInternals does). The optimization
done by NTREGOPT is simply compacting the registry hives to the
minimum size possible.

To optimize your registry, simply run NTREGOPT, click "OK", and when
the process is complete click "OK" to reboot the computer. You should
do so immediately because any changes made to the registry after
NTREGOPT has been run are lost after the reboot.



NTREGOPT command line switches
------------------------------

The syntax for the NTREGOPT command line is:

NTREGOPT silent [/noprogresswindow] [/reboot]

(Switches in brackets are optional.)

Description of the command line switches:

silent
  Puts NTREGOPT into "silent" mode and enables the other switches.

/noprogresswindow
  Hides the progress window during optimization.

/reboot
  Automatically reboots the computer when optimization of the registry
  is complete.



Known problems
--------------

ERUNT and NTREGOPT sometimes fail with error 1450 - "Insufficient
system resources exist to complete the requested service" - when
trying to save a registry hive. I have not yet been able to reproduce
this error on any PC, and reports from affected users indicate that it
also pops up when trying to back up the critical hive using
Microsoft's REGBACK program. This makes it unlikely that there is
anything I can do on my (the programmer's) side. Some users reported
however that they were able to work around the problem by running
ERUNT/NTREGOPT in Windows' safe mode, and in one case uninstalling a
Symantec software suite solved it permanently. One user reported that
increasing the "IRPStackSize" value as described in Microsoft
Knowledge Base article 177078 fixed the problem on his system.

When the system is rebooted after a restoration of the registry with
ERDNT or optimization with NTREGOPT, Windows Server 2003 will by
default display the shutdown event tracker during logon asking why the
system has been shut down unexpectedly. This is because the info that
the shutdown was in fact an expected one is written to the "old"
registry during shutdown of the system which is replaced by the
restored/optimized registry next time the system is booted, and
therefore the shutdown info is discarded and shutdown event tracker
thinks the system crashed. You may want to disable the tracker to
avoid this message in the future (see the Windows help for information
on how to do this).

If you experience any other problems, please email me at
lars.hederer@t-online.de with a detailed description and I will see if
I can help you.



Localization
------------

You can translate all programs from this package into your language by
editing the appropriate .LOC file.

Keep in mind that the LOC files of the three Windows programs (ERUNT,
ERDNTWIN, NTREGOPT) should be edited using a Windows based editor
(Notepad), and ERDNTDOS.LOC using an MS-DOS based editor (EDIT.COM).
This is to ensure that any OEM characters are displayed correctly in
the program.

If your language is not yet present on my homepage and you want your
localization to be available to the general public, you are welcome to
send the four translated files to me. I will then make them available
for download, with credits of course.

I have included a German language pack. If you want to use the program
in German, simply unzip LOC_GER.ZIP into your ERUNT folder.



Version history
---------------

v1.1j, 10/20/2005
- Fixed compatibility issues with 64-bit Windows (many thanks to
  Ian Smith and Hajo for all testing)
- Enhanced error messages
- AutoBackup now supports all date formats
- ERUNT.INI: "TimeSeparator" fixed; "DefaultDestinationFolder" now
  supports all environment variables (previously only %SystemRoot%
  could be used)
- ERDNT now displays the source Windows folder in addition to the
  backup's creation date

v1.1i, 08/17/2005
- AutoBackup: Improved support for complex date formats
- NTREGOPT: Optimization results are now calculated correctly when
  optimization failed on one or more hives

v1.1h, 03/06/2005
- Updated homepage address
- New ERUNT.INI option: AppendTimeToFolderEditField
- Fixed a problem where the current user registry could not be
  identified on some systems
- Changed behavior of AutoBackup's /days:n switch

v1.1g, 11/02/2004
- ERUNT is now MUCH faster on Windows XP and Server 2003
- Added time string support on the command line
- AutoBackup now by default skips creating a backup for the current
  day if one already exists

v1.1f, 08/26/2004
- Added AUTOBACK.EXE command line tool for automated registry backup
  and deletion of old restore folders created prior to a specific
  number of days
- Window position is now screen center instead of desktop center,
  fixing display problem when using multiple monitors (thanks John :)

v1.1e, 07/31/2004
- Appearance of the date string can be configured via ERUNT.INI
- NTREGOPT: Optimization results: use thousand separator

v1.1d, 07/07/2004
- Optimized error handling
- Combined DOS and Windows ERDNT into a single Win32 executable,
  fixing problems with the previous 16-bit exe stub on some systems
  and with BartPE
- Added Windows Recovery Console support with ERDNT batch file
- Default destination folder can now be configured via file ERUNT.INI,
  replacing #DestinationFolder command line option
- Changed the default destination folder to be inside the Windows
  folder, for easy recovery console access
- New folder named the current date is automatically appended to
  destination folder (can be disabled in ERUNT.INI)
- Rewrote major parts of the documentation

v1.1c, 05/10/2004
- Fixed problems with dynamic disks
- Added browse function for destination folder, as well as the option
  to change the default name (use #DestinationFolder on the command
  line)
- Re-added support for Windows NT 3.51 (got lost with v1.1) except
  browse function

v1.1b, 04/23/2004
- ERUNT and NTREGOPT are now compatible with Windows Server 2003 and
  Windows XP Service Pack 2
- Fixed a problem where the registry hives could not be
  saved/restored/optimized on some systems
- Changed naming convention for user subfolders in the ERDNT folder

v1.1a, 10/03/2002
- Fixed a problem where the registry hives could not be
  saved/restored/optimized on some systems

v1.1, 09/25/2002
- Fixed "Invalid pointer operation" message which occurred on some
  systems (many thanks to Russ Cordner for his assistance in isolating
  the problem)
- Fixed "Error opening localization file" message when ERUNT.EXE was
  called from outside the ERUNT folder
- Fixed some problems with UNC path names
- Added command line support for ERDNT and NTREGOPT
- NTREGOPT: show optimization results (initial and new registry size)

v1.0, 11/24/2001
- Initial release



Distribution
------------

The ERUNT package (including the programs ERUNT, AUTOBACK, ERDNT and
NTREGOPT) is freeware. Please pass it to anyone who you think may find
it useful.

I explicitly allow this package to be included in any file archive,
CD-ROM or other media collection as well as usage in your own programs
provided that all files are kept and remain unchanged. A quick note
via e-mail where my program has been included is appreciated.



Donations
---------

Though I chose to make my programs freeware so that no one is required
to pay for using them, I accept and appreciate donations. So, if you
find my programs helpful and want to support further development,
simply visit my homepage and click one of the "PayPal" buttons, or
donate directly to my e-mail address via PayPal. Thanks in advance!

If you live in Germany and want to make a donation, you may also
transfer money directly to my bank account. Contact me for more
information.



Disclaimer
----------

Use this software at your own risk. I do not take responsibility for
anything that might happen to you or the PC upon use of my programs,
including but not limited to: registry destruction, hard disk crash,
heart attack...

Comments and suggestions via e-mail, however, are always welcome!
