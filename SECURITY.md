# Security policy

## How do I report a vulnerability?

Privately, through GitHub: open the repository's [Security tab](https://github.com/rizonesoft/Resolute/security), choose **Report a vulnerability**, and describe what you found, how to reproduce it, and what it lets an attacker do. Please do not open a public issue for a vulnerability.

You will get an acknowledgement on the report itself. A fix is made in the open once it is ready, and the report is credited unless you ask otherwise.

## Which versions get fixes?

| Version | Fixes |
| --- | --- |
| The AutoIt suite, latest download from rizonesoft.com | Yes |
| Older AutoIt downloads | No; update to the latest |
| The C++ suite in this repository | Yes, on `main`; it has no release yet |

## Are the downloads signed?

Not yet. Nothing Resolute ships is code-signed today; signing is planned in `D06 T01 §3`, and this page will say so when it lands. Until then, download only from rizonesoft.com or from this repository.

## What is in scope?

Anything in this repository: the tools, the launcher, the shared libraries, the build and its scripts. The tools change a system (ownership, network settings, drive state, the registry), so a way to make one of them change something it should not, or to do it without the elevation it asks for, is in scope.
