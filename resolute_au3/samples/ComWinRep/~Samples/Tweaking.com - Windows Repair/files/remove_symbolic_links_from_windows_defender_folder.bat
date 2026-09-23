FOR /R "%ProgramFiles(x86)%\Windows Defender\" %%G in (.) DO (fsutil reparsepoint delete "%%G")

FOR /R "%ProgramFiles(x86)%\Windows Defender\" %%G in (*.*) DO (fsutil reparsepoint delete "%%G")

FOR /R "%ProgramFiles%\Windows Defender\" %%G in (.) DO (fsutil reparsepoint delete "%%G")

FOR /R "%ProgramFiles%\Windows Defender\" %%G in (*.*) DO (fsutil reparsepoint delete "%%G")
