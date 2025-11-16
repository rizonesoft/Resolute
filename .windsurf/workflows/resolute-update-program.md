---
description: Update a Resolute program (Firemin, BiosCodes, etc.) including version, docs, and templates
---

1. **Understand the current release context**
   - Program name (for example `Firemin`, `BiosCodes`, `DVDRepair`, `USBRepair`, `ReBar`, `Rescue`, or `Resolute`).
   - Treat the **version string and release date as values supplied by Distro** (via the solution INI and `g_aEnvironment`), not as things to hard-code in templates.
   - When editing templates, keep placeholders like `%{VERSION}`, `%{DAY}`, `%{MONTH}`, `%{YEAR}` intact and focus only on the change log / descriptive text.
   - Prepare a short, categorized list of changes (for example *Memory/Performance*, *Localization*, *User Interface*, *Bug Fixes*) to describe in `Changes.tpl` and, if needed, `Readme.tpl`.

2. **Locate the main program script**
   - Path pattern: `SDK/Concrete/<Program>/<Program>.au3`.
   - Confirm the script contains the AutoIt3Wrapper version directives:
     - `#AutoIt3Wrapper_Res_Fileversion=` (required).
     - `#AutoIt3Wrapper_Res_ProductVersion=` (optional).

3. **Verify AutoIt version metadata (do not edit)**
   - AutoIt / AutoIt3Wrapper manages the values of `#AutoIt3Wrapper_Res_Fileversion` (and, if present, `#AutoIt3Wrapper_Res_ProductVersion`) when building the executable.
   - Treat these directives as authoritative, read-only metadata and **do not modify them manually**, unless you are explicitly changing build configuration.
   - You may still search the script for hard-coded occurrences of the previous version string in UI text (for example window titles or About dialog text) and update those as needed.
     - Do **not** touch historical references in comments or documentation blocks unless requested.

4. **Identify and treat documentation templates as canonical**
   - For each program, documentation templates live under:
     - `SDK/Concrete/<Program>/Templates/`.
   - Typical files:
     - `Changes.tpl` – template for `Changes.txt` change log.
     - `Readme.tpl` – template for `Readme.txt`.
     - `License.tpl` – template for `License.txt` or license sections.
   - Treat these `.tpl` files as the single source of truth for program documentation.
   - Do **not** hand-edit generated documentation copies in:
     - `Resolute/Resolute/Docs/<Program>/...`
     - `SDK/Concrete/<Program>/Distribution/*/Docs/...`
     - `updates/...`
     unless you are explicitly fixing an already shipped package.

5. **Update `Changes.tpl` for the new release**
   - At the top of `Changes.tpl` there is a parameterized section that uses placeholders such as:
     - `%{COMPANY}`, `%{RELEASE}`, `%{VERSION}`, `%{DAY}`, `%{MONTH}`, `%{YEAR}`.
   - This top block should always describe the **current release being prepared**.
   - To add a new release:
     1. If the previous release is **not yet** represented as a static block below, copy its version heading and bullet list into the history section.
        - Use the concrete values from the last generated `Changes.txt`:
          - `Version X.Y.Z.BUILD (MONTH DAY, YEAR)`
          - followed by its bullet list.
     2. Update the bullet list in the parameterized top block so it accurately reflects the **new** release.
        - Keep the `Version %{VERSION} (%{MONTH} %{DAY}, %{YEAR})` line with placeholders.
        - Organize bullets by category (for example *Memory Management and Performance*, *Language and Localization*, *User Interface*, *Other*).
     3. Leave all older history blocks unchanged unless you are correcting a genuine error.

6. **Update `Readme.tpl`**
   - Keep the header values parameterized:
     - `Version: %{VERSION}`
     - `Release Date: %{DAY} %{MONTH}, %{YEAR}`
     - `Disk Space: %{INSTSIZE}`
   - Ensure the product name, company name, and URLs are correct:
     - `%{RELEASE}` should match the program name (for example `FIREMIN`).
     - `%{COMPANY}` / `%{COMPANYURL}` should match current branding (for example Rizonesoft / company site).
   - Update the descriptive paragraph(s) only when the product’s purpose or behaviour has changed or when you intentionally improve the copy.
   - Keep `System Requirements` aligned with the actual supported Windows versions.

7. **Update `License.tpl` when necessary**
   - Normally, only `%{YEAR}` and `%{RELEASE}` need to reflect the current year and program name.
   - The GPL and privacy text should remain stable. Change it only when you have explicit instructions or a legal update.
   - Make sure any company/legal contact details (addresses, emails, URLs) are still correct before reusing the template.

8. **Regenerate documentation from templates**
   - Use the existing Resolute build/distribution tooling or scripts (if present) to generate the concrete documentation files:
     - `Resolute/Resolute/Docs/<Program>/Changes.txt`
     - `Resolute/Resolute/Docs/<Program>/Readme.txt`
     - `Resolute/Resolute/Docs/<Program>/License.txt` (if this program ships one)
   - After generation, verify that:
     - The top entry in `Changes.txt` shows the **new** version and release date.
     - The history section is intact and still in chronological order.
     - `Readme.txt` header matches the new version and date.

9. **Check version consistency across the system**
   - Confirm the following all agree on the new version:
     - `#AutoIt3Wrapper_Res_Fileversion` in the main `.au3` script.
     - `Changes.txt` top entry.
     - `Readme.txt` header.
   - If there are update metadata files (for example `.ru` files or distribution config) inside the repository, update their version fields as well.
   - When resolving conflicts, treat `#AutoIt3Wrapper_Res_Fileversion` as the primary source of truth and update docs to match.

10. **Preserve historical artifacts unless explicitly asked**
    - Do not retroactively rewrite change logs or readmes inside historical distribution folders:
      - `SDK/Concrete/<Program>/Distribution/*/Docs/...`
      - `updates/...`
    - Only touch these when explicitly asked to fix a historical package. For normal development, operate on the source `.au3` script and the `Templates` directory.
