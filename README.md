[中文](README_CN.md) | English

# SIYUAN-CLI-SKILLS — SiYuan Note AI Agent Operation Guide

![Image 1](assets/screenshot_en.png)

## 1. What It Is and What It Does

**SIYUAN-CLI-SKILLS.md** is an AI Agent operating manual for the SiYuan CLI. Place it and its companion documents in a directory accessible to any AI assistant that can read files (Claude Code, Cursor, CodeBuddy, etc.), and that AI will be able to **search, read, create, edit, organize, import/export, snapshot-protect, and sync-manage** your SiYuan note workspace via the `siyuan` command-line tool.

In short: it serves as a translator between SiYuan Note and external AI, teaching the AI how to safely operate your notes.

## 2. It Comes from the Official agent.go — "Adapted", Not Reinvented

SiYuan 3.7.0's kernel includes a built-in AI agent (source [`agent.go`](https://github.com/siyuan-note/siyuan/blob/master/kernel/agent/agent.go)), which defines a complete paradigm: the block domain model (container blocks/leaf blocks), the heading non-container pitfall, the `safeActions` read/write whitelist, doom loop detection, one-time automatic snapshots, the `[tool_output]` untrusted data marker... However, these designs serve the **built-in agent + GUI dialog confirmation** flow.

This document **externalizes** that entire paradigm:

- agent.go uses GUI dialogs for user confirmation of each write operation → this document instead lists an operation plan and waits for textual user confirmation
- agent.go has a `safeActions` whitelist that auto-approves read-only operations → this document classifies operations into Safety Levels 1/2/3
- agent.go uses a `snapshotCreated` flag to ensure only one snapshot per session → this document incorporates snapshots into the operation plan and executes them after confirmation
- agent.go uses a `doomLoopTracker` to detect duplicate signatures and terminate loops → this document mandates switching methods after 3 consecutive failures of the same command, and aborting that method after 5 failures

**It is not a direct translation of agent.go, but rather preserves its security philosophy and operation boundaries, implementing each mechanism as an executable equivalent in the CLI context.**

## 3. Safety Design Overview

Because the `siyuan` CLI directly manipulates kernel data, has no GUI confirmation dialogs, and offers no undo functionality, an external agent is significantly more dangerous than the built-in one. This document mitigates risk with a four-layer safety mechanism:

**Layer 1: Snapshot safety net.** After the user confirms the operation plan, the first execution step is to create a data snapshot. If something goes wrong, you can roll back with `repo checkout`. The snapshot ID is explicitly communicated to the user.

**Layer 2: User confirmation.** After the discovery phase gathers all information, a complete operation checklist (each command, target ID, expected result) is presented. The agent waits for the user to say "confirm" before proceeding. No silent writes.

**Layer 3: Step-by-step verification.** After each execution step, the agent immediately uses read commands to verify the result, rather than relying on "zero exit code = success".

**Layer 4: Failure circuit breaker.** The agent automatically switches methods after 3 consecutive failures of the same command, and terminates that approach after 5 failures, preventing infinite loops.

**Additional defense line:** Rules are hardcoded to "never fabricate IDs, paths, or block types" — all identifiers must be discovered from the actual workspace, eliminating AI hallucination risks. All content returned by SiYuan is treated as untrusted data to prevent prompt injection.

## 4. How to Use

Usage varies slightly across different AI tools, but the core operation is equally simple:

> **Have the AI read this document.**

Place these files in the same directory accessible to your AI:

| File                      | Purpose                                                                                                                                  |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `SIYUAN-CLI-SKILLS.md`    | Main entry: mandatory rules, safety boundaries, domain model, SOP, error handling, report format                                         |
| `SIYUAN-CLI-WORKFLOWS.md` | On-demand reference: common workflows, content input, debugging, SQL, sync, import/export, assets, databases, and other scenario details |

Then say in the conversation: "Please read `SIYUAN-CLI-SKILLS.md` first, then help me search/create/manage SiYuan notes. When specific workflows are needed, refer to `SIYUAN-CLI-WORKFLOWS.md` as guided by the main document. For specific command parameters, always check real-time `siyuan <command> --help`."

For first-time use, you can guide the AI like this:

```
Please read /path/to/SIYUAN-CLI-SKILLS.md, then check the siyuan CLI
version on my machine, list registered workspaces, and give me an overall
introduction. When specific workflows or scenario examples are needed,
refer to SIYUAN-CLI-WORKFLOWS.md in the same directory.
For specific command parameters, always run siyuan <command> --help in real time.
```

The main document is self-explanatory — after reading it, the AI knows which safety rules to follow, how to organize multi-step operations, and when to consult the companion files.

### Real-time CLI Help First

This skill prominently notes throughout: **specific command names, parameters, flags, input methods, and path semantics should be verified against the currently installed version's real-time help**:

```bash
siyuan <command> --help
```

This explicitly guides the AI agent to prioritize obtaining the most accurate command usage patterns for the current version, reducing the risk of the AI inferring parameters from similar commands. `siyuan-cli-help-export.sh` is retained as an optional maintenance/audit tool for batch-exporting the current CLI's complete help information for manual inspection or temporary reference.

## 5. Dependencies

### Required Dependency: SiYuan CLI

This skill depends on the kernel CLI provided by SiYuan 3.7.0 and above. See the official CLI documentation in the [Command-line Interface section](https://github.com/siyuan-note/siyuan#%EF%B8%8F-command-line-interface).

According to the official documentation, the CLI binary is:

```text
<install>/resources/kernel/SiYuan-Kernel
```

The Windows installer automatically adds it to `PATH`. macOS/Linux require manually creating a `siyuan` symlink:

```bash
# macOS
ln -s /Applications/SiYuan.app/Contents/Resources/kernel/SiYuan-Kernel /usr/local/bin/siyuan

# Linux
ln -s /path/to/SiYuan/resources/kernel/SiYuan-Kernel /usr/local/bin/siyuan
```

Verify with:

```bash
siyuan --version
```

If you get `command not found`, make sure SiYuan 3.7.0+ is installed and follow the official instructions to create a symlink or configure `PATH`. If you prefer not to configure `PATH`, you can also provide the full path when talking to the AI, for example:

```text
My SiYuan CLI path is: /path/to/SiYuan/resources/kernel/SiYuan-Kernel
```

### Recommended Dependency: `jq`

`jq` is a command-line JSON processing tool. SiYuan CLI's `--format json` produces a lot of output. When the AI agent extracts notebook IDs, block IDs, snapshot IDs, database fields, search results, etc., using `jq` is more stable than manually parsing large blocks of JSON.

Strictly speaking, `jq` is not a hard dependency of the SiYuan CLI; however, it is strongly recommended for more reliable operation of this skill.

#### Windows

If using WinGet:

```powershell
winget install jqlang.jq
```

If using Chocolatey:

```powershell
choco install jq
```

If using Scoop:

```powershell
scoop install jq
```

After installation, reopen your terminal and verify:

```powershell
jq --version
```

#### macOS

If using Homebrew:

```bash
brew install jq
```

Verify:

```bash
jq --version
```

#### Linux

Debian / Ubuntu:

```bash
sudo apt update
sudo apt install jq
```

Fedora:

```bash
sudo dnf install jq
```

Arch Linux:

```bash
sudo pacman -S jq
```

Verify:

```bash
jq --version
```

## 6. Customization

All content in these documents can be freely modified to suit your usage habits. Common customization scenarios:

- **Don't want to wait for confirmation every time**: Remove SOP step 11 (present plan and wait for confirmation) and the related requirements in Rule 11. The AI will execute immediately after discovery.
- **Don't want snapshots**: Remove Rule 10 and SOP step 12. The AI will skip snapshots and operate directly.
- **Read-only AI access**: Remove all Safety Level 2 and Level 3 commands. The AI will only perform queries.
- **Add custom workflows**: Append your own fixed operation patterns to the Common Workflows section in `SIYUAN-CLI-WORKFLOWS.md`.

All documents are Markdown files and can be edited with any editor. Save your changes and the AI will read your customized version next time.

## 7. Cross-Platform Usage Notes

The command examples in `SIYUAN-CLI-SKILLS.md` default to POSIX shell syntax, i.e., the bash/zsh conventions common on Linux/macOS. In other words, **the SiYuan CLI itself is cross-platform, but the shell examples in this skill document are POSIX-first, not a complete cross-platform command reference set**.

The SiYuan CLI can be used on Windows, macOS, and Linux; however, shell syntax varies across systems. Windows + PowerShell users are advised not to copy bash examples from the document directly, but instead ask the AI to rewrite commands for the current environment before execution.

Recommended prompt:

> Please read `SIYUAN-CLI-SKILLS.md` first. The command examples in this document default to Linux/macOS bash syntax. My environment is Windows + PowerShell. Before executing any commands, please rewrite them in PowerShell syntax, including variables, line continuations, pipelines, standard input, temporary files, paths, and error handling. Do not run bash syntax directly.

Common areas requiring rewriting:

| POSIX bash/zsh        | Windows PowerShell                             |
| --------------------- | ---------------------------------------------- |
| `$SIYUAN_WORKSPACE`   | `$env:SIYUAN_WORKSPACE` or `$SIYUAN_WORKSPACE` |
| `\` line continuation | Backtick `` ` `` line continuation             |
| `cat <<'EOF' ... EOF` | PowerShell here-string: `@' ... '@`            |
| `mktemp`              | `[System.IO.Path]::GetTempFileName()`          |
| `tail -n 200 file`    | `Get-Content file -Tail 200`                   |
| `rm -f file`          | `Remove-Item -Force file`                      |
| `$?` / `$status`      | `$LASTEXITCODE`                                |
| `/absolute/path/...`  | `C:\...` or PowerShell-recognized path         |

If you use Git Bash, WSL, MSYS2, or other Unix-like shells on Windows, you can continue to reference the bash examples in the document, but you should still confirm that `siyuan` is in that shell's `PATH`.

For CLI binary names and `jq` installation methods, see the Dependencies section above. If `siyuan --version` fails, verify your SiYuan version, CLI binary name, and `PATH` configuration before continuing with the AI.

## 8. Disclaimer

This document is provided **AS IS**, without warranty of any kind. Use it at your own risk, and review all AI-generated operation plans carefully before allowing changes to your SiYuan workspace.

## 9. License

This project is licensed under the [MIT License](LICENSE).
