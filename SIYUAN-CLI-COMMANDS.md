# SiYuan CLI Command Reference

This auxiliary file contains the complete SiYuan CLI 3.7.0 command quick reference used by `SIYUAN-CLI-SKILLS.md`. Consult it when command names, subcommands, or argument signatures are needed.

Live `siyuan <command> --help` output and observed command behavior remain authoritative. Regenerate or revise this file when the installed SiYuan CLI changes materially.

# SiYuan 3.7.0 command quick reference

This appendix is derived from the complete recursive `--help` output for SiYuan Kernel CLI 3.7.0. Live help takes precedence.

## Root command

- **`siyuan`** — SiYuan Kernel v3.7.0. Manage workspace data directly or start the HTTP server.  
  Usage: `siyuan [command]`

## `asset` commands

- **`siyuan asset`** — Manage assets  
  Usage: `siyuan asset [command]`
- **`siyuan asset clean`** — Clean unused assets  
  Usage: `siyuan asset clean [flags]`
- **`siyuan asset stat`** — Show asset file info  
  Usage: `siyuan asset stat --path <path> [flags]`
- **`siyuan asset unused`** — List unused assets  
  Usage: `siyuan asset unused [flags]`
- **`siyuan asset upload`** — Upload files to workspace assets  
  Usage: `siyuan asset upload --id <id> --file <path> [flags]`

## `attr` commands

- **`siyuan attr`** — Manage block attributes  
  Usage: `siyuan attr [command]`
- **`siyuan attr batch-get`** — Batch get block attributes  
  Usage: `siyuan attr batch-get --ids id1,id2,... [flags]`
- **`siyuan attr get`** — Get block attributes  
  Usage: `siyuan attr get --id <id> [flags]`
- **`siyuan attr set`** — Set custom attributes on a block.  
  Usage: `siyuan attr set --id <id> --attr name=value [flags]`

## `block` commands

- **`siyuan block`** — Block operations  
  Usage: `siyuan block [command]`
- **`siyuan block append`** — Append block  
  Usage: `siyuan block append --parent <id> [--data <markdown> \| --file <path>] [flags]`
- **`siyuan block batch-get`** — Batch get block info  
  Usage: `siyuan block batch-get --ids id1,id2,... [flags]`
- **`siyuan block batch-kramdown`** — Batch get block kramdown  
  Usage: `siyuan block batch-kramdown --ids id1,id2,... [flags]`
- **`siyuan block breadcrumb`** — Get block breadcrumb  
  Usage: `siyuan block breadcrumb --id <id> [flags]`
- **`siyuan block children`** — Get child blocks  
  Usage: `siyuan block children --id <id> [flags]`
- **`siyuan block delete`** — Delete block  
  Usage: `siyuan block delete --id <id> [flags]`
- **`siyuan block dom`** — Get block DOM  
  Usage: `siyuan block dom --id <id> [flags]`
- **`siyuan block get`** — Get block info  
  Usage: `siyuan block get --id <id> [flags]`
- **`siyuan block insert`** — Insert block  
  Usage: `siyuan block insert --parent <id> [--data <markdown> \| --file <path>] [flags]`
- **`siyuan block kramdown`** — Get block kramdown  
  Usage: `siyuan block kramdown --id <id> [flags]`
- **`siyuan block move`** — Move block  
  Usage: `siyuan block move --id <id> --parent <id> [flags]`
- **`siyuan block prepend`** — Prepend block  
  Usage: `siyuan block prepend --parent <id> [--data <markdown> \| --file <path>] [flags]`
- **`siyuan block stat`** — Get block content statistics  
  Usage: `siyuan block stat --id <id> [flags]`
- **`siyuan block update`** — Update block  
  Usage: `siyuan block update --id <id> [--data <markdown> \| --file <path>] [flags]`

## `bookmark` commands

- **`siyuan bookmark`** — Manage bookmarks  
  Usage: `siyuan bookmark [command]`
- **`siyuan bookmark labels`** — List bookmark labels  
  Usage: `siyuan bookmark labels [flags]`
- **`siyuan bookmark list`** — List bookmarks  
  Usage: `siyuan bookmark list [flags]`
- **`siyuan bookmark remove`** — Remove a bookmark  
  Usage: `siyuan bookmark remove --label <label> [flags]`
- **`siyuan bookmark rename`** — Rename a bookmark  
  Usage: `siyuan bookmark rename --old <old> --new <new> [flags]`

## `completion` commands

- **`siyuan completion`** — Generate the autocompletion script for siyuan for the specified shell.  
  Usage: `siyuan completion [command]`
- **`siyuan completion bash`** — Generate the autocompletion script for the bash shell.  
  Usage: `siyuan completion bash`
- **`siyuan completion fish`** — Generate the autocompletion script for the fish shell.  
  Usage: `siyuan completion fish [flags]`
- **`siyuan completion powershell`** — Generate the autocompletion script for powershell.  
  Usage: `siyuan completion powershell [flags]`
- **`siyuan completion zsh`** — Generate the autocompletion script for the zsh shell.  
  Usage: `siyuan completion zsh [flags]`

## `dailynote` commands

- **`siyuan dailynote`** — Daily note (dailynote) operations  
  Usage: `siyuan dailynote [command]`
- **`siyuan dailynote append`** — Append block to today's daily note  
  Usage: `siyuan dailynote append --notebook <id> [--data <markdown> \| --file <path>] [flags]`
- **`siyuan dailynote create`** — Create today's daily note  
  Usage: `siyuan dailynote create --notebook <id> [flags]`
- **`siyuan dailynote prepend`** — Prepend block to today's daily note  
  Usage: `siyuan dailynote prepend --notebook <id> [--data <markdown> \| --file <path>] [flags]`

## `database` commands

- **`siyuan database`** — Manage databases (attribute views)  
  Usage: `siyuan database [command]`
- **`siyuan database clean`** — Clean unused databases  
  Usage: `siyuan database clean [flags]`
- **`siyuan database get`** — Get database content  
  Usage: `siyuan database get --av <avID> [flags]`
- **`siyuan database item`** — Manage database rows (items)  
  Usage: `siyuan database item [command]`
- **`siyuan database item add`** — Add a row to database  
  Usage: `siyuan database item add --av <avID> [flags]`
- **`siyuan database item remove`** — Remove rows from database  
  Usage: `siyuan database item remove --av <avID> --ids <id1,id2,...> [flags]`
- **`siyuan database item update`** — Update a cell value  
  Usage: `siyuan database item update --av <avID> --key <keyID> --item <itemID> --value <json> [flags]`
- **`siyuan database key`** — Manage database keys (fields)  
  Usage: `siyuan database key [command]`
- **`siyuan database key add`** — Add a key (field) to database  
  Usage: `siyuan database key add --av <avID> --name <name> --type <type> [flags]`
- **`siyuan database key remove`** — Remove a key (field) from database  
  Usage: `siyuan database key remove --av <avID> --key <keyID> [flags]`
- **`siyuan database keys`** — List database keys (fields)  
  Usage: `siyuan database keys --av <avID> [flags]`
- **`siyuan database render`** — Render database data  
  Usage: `siyuan database render --av <avID> [flags]`
- **`siyuan database search`** — Search databases by name  
  Usage: `siyuan database search <keyword> [flags]`
- **`siyuan database unused`** — List unused databases  
  Usage: `siyuan database unused [flags]`

## `document` commands

- **`siyuan document`** — Manage documents  
  Usage: `siyuan document [command]`
- **`siyuan document create`** — Create a document  
  Usage: `siyuan document create --notebook <id> --title <title> [flags]`
- **`siyuan document duplicate`** — Duplicate a document  
  Usage: `siyuan document duplicate --id <id> [flags]`
- **`siyuan document get`** — Get document info  
  Usage: `siyuan document get --id <id> [flags]`
- **`siyuan document info`** — Get document info  
  Usage: `siyuan document info --id <id> [flags]`
- **`siyuan document list`** — List documents in a notebook  
  Usage: `siyuan document list --notebook <id> [flags]`
- **`siyuan document move`** — Move a document to another notebook  
  Usage: `siyuan document move --id <id> --notebook <id> [flags]`
- **`siyuan document remove`** — Remove a document  
  Usage: `siyuan document remove --id <id> [flags]`
- **`siyuan document rename`** — Rename a document  
  Usage: `siyuan document rename --id <id> --title <title> [flags]`
- **`siyuan document search`** — Search documents by keyword  
  Usage: `siyuan document search <keyword> [flags]`

## `export` commands

- **`siyuan export`** — Export documents  
  Usage: `siyuan export [command]`
- **`siyuan export data`** — Export full workspace data backup  
  Usage: `siyuan export data [--output <file>] [flags]`
- **`siyuan export docx`** — Export as Word (.docx)  
  Usage: `siyuan export docx --id <id> --output <file> [flags]`
- **`siyuan export html`** — Export as HTML  
  Usage: `siyuan export html --id <id> [flags]`
- **`siyuan export md`** — Export as Markdown  
  Usage: `siyuan export md --id <id> [flags]`
- **`siyuan export md-zip`** — Export as Markdown zip  
  Usage: `siyuan export md-zip --id <id> [--output <file>] [flags]`
- **`siyuan export preview`** — Export as preview HTML  
  Usage: `siyuan export preview --id <id> [flags]`
- **`siyuan export sy`** — Export as .sy.zip  
  Usage: `siyuan export sy --id <id> [--output <dir>] [flags]`

## `file` commands

- **`siyuan file`** — Workspace file operations  
  Usage: `siyuan file [command]`
- **`siyuan file copy`** — Copy file or directory  
  Usage: `siyuan file copy <src> <dst> [flags]`
- **`siyuan file delete`** — Delete file or directory  
  Usage: `siyuan file delete <path> [flags]`
- **`siyuan file find`** — Find files under a path  
  Usage: `siyuan file find <path> [flags]`
- **`siyuan file grep`** — Search file contents with regex  
  Usage: `siyuan file grep --pattern <regex> --path <path> [flags]`
- **`siyuan file list`** — List directory contents  
  Usage: `siyuan file list <path> [flags]`
- **`siyuan file read`** — Read file content  
  Usage: `siyuan file read <path> [flags]`
- **`siyuan file rename`** — Rename or move file  
  Usage: `siyuan file rename <old> <new> [flags]`
- **`siyuan file stat`** — Show file or directory info  
  Usage: `siyuan file stat <path> [flags]`
- **`siyuan file write`** — Write file content (stdin or --file)  
  Usage: `siyuan file write <path> [flags]`

## `help` commands

- **`siyuan help`** — Help provides help for any command in the application.  
  Usage: `siyuan help [command] [flags]`

## `history` commands

- **`siyuan history`** — Data history  
  Usage: `siyuan history [command]`
- **`siyuan history clear`** — Clear all history  
  Usage: `siyuan history clear [flags]`
- **`siyuan history get`** — Get historical file content  
  Usage: `siyuan history get --path <path> [flags]`
- **`siyuan history list`** — List all history  
  Usage: `siyuan history list [flags]`
- **`siyuan history rollback`** — Rollback a document to historical version  
  Usage: `siyuan history rollback --path <path> [flags]`
- **`siyuan history search`** — Search history  
  Usage: `siyuan history search <query> [flags]`

## `import` commands

- **`siyuan import`** — Import files  
  Usage: `siyuan import [command]`
- **`siyuan import data`** — Import data backup  
  Usage: `siyuan import data --file <path> [flags]`
- **`siyuan import md`** — Import Markdown file or directory  
  Usage: `siyuan import md --file <path> --notebook <id> [flags]`
- **`siyuan import sy`** — Import .sy.zip archive  
  Usage: `siyuan import sy --file <path> --notebook <id> [flags]`

## `notebook` commands

- **`siyuan notebook`** — Manage notebooks  
  Usage: `siyuan notebook [command]`
- **`siyuan notebook close`** — Close a notebook  
  Usage: `siyuan notebook close --id <id> [flags]`
- **`siyuan notebook create`** — Create a notebook  
  Usage: `siyuan notebook create --name <name> [flags]`
- **`siyuan notebook list`** — List all notebooks  
  Usage: `siyuan notebook list [flags]`
- **`siyuan notebook open`** — Open a notebook  
  Usage: `siyuan notebook open --id <id> [flags]`
- **`siyuan notebook random-icon`** — Randomly set notebook icon(s) from built-in emojis  
  Usage: `siyuan notebook random-icon [--id <id>] [flags]`
- **`siyuan notebook remove`** — Remove a notebook  
  Usage: `siyuan notebook remove --id <id> [flags]`
- **`siyuan notebook rename`** — Rename a notebook  
  Usage: `siyuan notebook rename --id <id> --name <name> [flags]`
- **`siyuan notebook set-icon`** — Set a notebook icon  
  Usage: `siyuan notebook set-icon --id <id> --icon <icon> [flags]`

## `outline` commands

- **`siyuan outline`** — Document outline (heading tree)  
  Usage: `siyuan outline [command]`
- **`siyuan outline get`** — Get document outline  
  Usage: `siyuan outline get --id <id> [flags]`

## `ref` commands

- **`siyuan ref`** — Backlinks and references  
  Usage: `siyuan ref [command]`
- **`siyuan ref backlinks`** — Get backlinks for a block  
  Usage: `siyuan ref backlinks --id <id> [flags]`
- **`siyuan ref mentions`** — Get mentions for a block  
  Usage: `siyuan ref mentions --id <id> [flags]`
- **`siyuan ref refresh`** — Refresh backlinks for a block  
  Usage: `siyuan ref refresh --id <id> [flags]`

## `repo` commands

- **`siyuan repo`** — Data snapshots  
  Usage: `siyuan repo [command]`
- **`siyuan repo checkout`** — Checkout (rollback to) a snapshot  
  Usage: `siyuan repo checkout --id <id> [flags]`
- **`siyuan repo create`** — Create a snapshot  
  Usage: `siyuan repo create [flags]`
- **`siyuan repo diff`** — Diff two snapshots  
  Usage: `siyuan repo diff --left <id> --right <id> [flags]`
- **`siyuan repo file`** — File-level snapshot operations  
  Usage: `siyuan repo file [command]`
- **`siyuan repo file export`** — Export file from snapshot to temp file  
  Usage: `siyuan repo file export --id <fileID> [flags]`
- **`siyuan repo file get`** — Get file content from snapshot  
  Usage: `siyuan repo file get --id <fileID> [flags]`
- **`siyuan repo file open`** — Preview file content from snapshot  
  Usage: `siyuan repo file open --id <fileID> [flags]`
- **`siyuan repo file rollback`** — Rollback a single file from snapshot  
  Usage: `siyuan repo file rollback --id <fileID> [flags]`
- **`siyuan repo list`** — List snapshots  
  Usage: `siyuan repo list [flags]`
- **`siyuan repo purge`** — Purge old snapshots  
  Usage: `siyuan repo purge [flags]`
- **`siyuan repo search`** — Search files in snapshots  
  Usage: `siyuan repo search <keyword> [flags]`
- **`siyuan repo tag`** — Tag a snapshot  
  Usage: `siyuan repo tag --id <id> --name <name> [flags]`
- **`siyuan repo untag`** — Remove a tag  
  Usage: `siyuan repo untag --name <name> [flags]`

## `search` commands

- **`siyuan search`** — Full-text search  
  Usage: `siyuan search <query> [flags]`

## `serve` commands

- **`siyuan serve`** — Start kernel HTTP server. All serving-related options below are passed to the kernel boot.  
  Usage: `siyuan serve [flags]`

## `sql` commands

- **`siyuan sql`** — Execute SQL query  
  Usage: `siyuan sql <statement> [flags]`

## `sync` commands

- **`siyuan sync`** — Sync data with cloud  
  Usage: `siyuan sync [flags] / siyuan sync [command]`
- **`siyuan sync pull`** — Download from cloud  
  Usage: `siyuan sync pull [flags]`
- **`siyuan sync push`** — Upload to cloud  
  Usage: `siyuan sync push [flags]`
- **`siyuan sync status`** — Show sync status  
  Usage: `siyuan sync status [flags]`

## `system` commands

- **`siyuan system`** — System information  
  Usage: `siyuan system [command]`
- **`siyuan system current-time`** — Show current server time  
  Usage: `siyuan system current-time [flags]`

## `tag` commands

- **`siyuan tag`** — Manage tags  
  Usage: `siyuan tag [command]`
- **`siyuan tag list`** — List tags  
  Usage: `siyuan tag list [flags]`
- **`siyuan tag remove`** — Remove a tag  
  Usage: `siyuan tag remove --label <label> [flags]`
- **`siyuan tag rename`** — Rename a tag  
  Usage: `siyuan tag rename --old <old-label> --new <new-label> [flags]`

## `template` commands

- **`siyuan template`** — Manage templates  
  Usage: `siyuan template [command]`
- **`siyuan template create`** — Create a template from markdown content  
  Usage: `siyuan template create --name <name> [--data <markdown> \| --file <path>] [flags]`
- **`siyuan template get`** — Read template content  
  Usage: `siyuan template get --path <path> [flags]`
- **`siyuan template remove`** — Remove a template  
  Usage: `siyuan template remove --path <path> [flags]`
- **`siyuan template render`** — Render a template against a block (preview)  
  Usage: `siyuan template render --path <path> --id <id> [flags]`
- **`siyuan template save-as`** — Save a document as a template  
  Usage: `siyuan template save-as --id <id> --name <name> [flags]`
- **`siyuan template search`** — Search templates (empty keyword lists all)  
  Usage: `siyuan template search [keyword] [flags]`

## `workspace` commands

- **`siyuan workspace`** — Manage SiYuan workspaces  
  Usage: `siyuan workspace [command]`
- **`siyuan workspace info`** — Show current workspace info  
  Usage: `siyuan workspace info [flags]`
- **`siyuan workspace list`** — List registered workspaces  
  Usage: `siyuan workspace list [flags]`

## Maintenance note

Regenerate or revise this skill when the installed SiYuan CLI changes materially. At minimum, compare:

```bash
siyuan --version
siyuan --help
siyuan <top-level-command> --help
```

The authoritative CLI behavior is always the installed CLI's live help and observed output. Re-check SiYuan's built-in agent conventions when its implementation changes materially, but translate internal tool names and parameter semantics rather than copying them blindly into CLI instructions.
