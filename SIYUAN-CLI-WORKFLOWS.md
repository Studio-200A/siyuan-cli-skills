# SiYuan CLI Workflows

This auxiliary file contains task-specific workflows and examples for `SIYUAN-CLI-SKILLS.md`. Read the main skill file first; all non-negotiable rules, safety levels, confirmation requirements, snapshot rules, and `.sy` file restrictions from the main skill remain mandatory.

Consult this file only when a task needs a matching workflow, concrete command pattern, content-input pattern, debugging procedure, SQL guidance, sync/serve handling, or response/content convention.

Command examples in this file illustrate workflow shape and safety sequencing. They are not authoritative syntax references. Before executing a command for the first time in the current session, and whenever syntax, flags, input mode, path semantics, or scope matter, check live `siyuan <command> --help` for the exact installed CLI behavior. Do not transfer input flags such as `--file` or `--markdown` between command families unless live help documents them for the exact command.

Mutation examples in this file do not repeat the full safety sequence every time. The main skill's confirmation and snapshot rules still apply: after user confirmation, include the automatic `repo create` snapshot as the first execution step unless the user explicitly opts out.

## Content input and shell safety

Do not write model reasoning traces, hidden chain-of-thought, planning notes, or provider-specific thinking tags such as `<think>...</think>` into SiYuan content or generated titles unless the user explicitly asks for them.

For multiline Markdown, generated text, or content containing quotes, prefer `--file -` with standard input instead of `--data` only for commands whose live help documents `--file`.

```bash
cat <<'EOF' | siyuan block append \
  --parent "$PARENT_ID" \
  --file - \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
## New section

Content generated for SiYuan.
EOF
```

The same pattern is supported by block insertion/update commands and template creation commands that document `--file <path>` with `-` for stdin.

For reusable or auditable content, write a temporary Markdown file first:

```bash
tmp_file="$(mktemp --suffix=.md)"
trap 'rm -f "$tmp_file"' EXIT
cat >"$tmp_file" <<'EOF'
# Draft

Content here.
EOF

siyuan block update \
  --id "$BLOCK_ID" \
  --file "$tmp_file" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

If the host agent provides a dedicated file-writing tool, prefer that over shell redirection for creating temporary input files. The shell pattern above is for ordinary terminal use.

Do not interpolate untrusted user text into shell command strings. Pass values as separately quoted arguments or through files/stdin.

## Tool and command selection patterns

Translate user intent into CLI commands using these patterns:

| Intent                         | Preferred CLI sequence                                                                                 |
| ------------------------------ | ------------------------------------------------------------------------------------------------------ |
| Find content                   | `search` → `block get` or `block kramdown`                                                             |
| Find a document by title       | `document search` → `document get`                                                                     |
| Explore structure              | `document list` → `document get` → `block children` → `block get`; use `block breadcrumb` for location |
| Create ordinary content        | `document create` → `block append`, `prepend`, or `insert`                                             |
| Modify one existing block      | `block update` only; it replaces one block and does not append new blocks                              |
| Modify and add content         | `block update` first, then a separate `append`, `prepend`, or `insert` call                            |
| Move a whole document          | `document move`                                                                                        |
| Rename a document              | `document rename`                                                                                      |
| Move one content block         | `block move`                                                                                           |
| Work with block attributes     | `attr get` / `attr set`                                                                                |
| Work with database rows/fields | `database item ...`, `database key ...`, `database render`                                             |
| Change a document-block icon   | `attr set --attr icon=...`                                                                             |
| Change a notebook icon         | `notebook set-icon` or narrowly scoped `notebook random-icon --id ...`                                 |

Do not use `attr set` to change a notebook icon. Do not run `notebook random-icon` without `--id` unless the user explicitly asks to randomize **all** notebook icons.

SiYuan's built-in agent may expose semantic-search tools that are not present in the tested CLI. SiYuan CLI 3.7.0 provides keyword, query-syntax, SQL, regex, and fuzzy search methods through `siyuan search`; do not invent a semantic-search CLI command.

## Response and SiYuan content conventions

- Reply in the user's language unless they request another language.

- Refer to the product as **SiYuan**, not “SiYuan Note.”

- Summarize large results rather than copying entire documents, logs, or JSON payloads.

- When presenting a specific document or block that the user can open, use:
  
  ```markdown
  [Readable title](siyuan://blocks/ACTUAL_BLOCK_ID)
  ```
  
  Only use a block ID returned by the CLI during the task. Never fabricate a URI.

- Use fenced code blocks with an explicit language.

- Prefer standard Markdown marks where sufficient: `**bold**`, `*italic*`, `~~strikethrough~~`, `==mark==`, and backticks for code.

### SiYuan text marks for styles Markdown cannot express

For text color, background color, or font size, use a SiYuan text mark with a leading `data-type="text"` attribute:

```html
<span data-type="text" style="color: #ff0000;">red text</span>
<span data-type="text" style="background-color: #ffff00;">highlighted</span>
<span data-type="text" style="font-size: 18px;">larger text</span>
<span data-type="text" style="color: #ff0000; font-size: 18px;">red and large</span>
```

To combine style with bold or italic marks:

```html
<span data-type="text strong" style="color: #ff0000;">bold red</span>
<span data-type="text em" style="background-color: #ffff00;">italic highlighted</span>
```

Never emit a bare `<span style="...">` for SiYuan content; without `data-type`, it may be escaped and displayed literally. Prefer ordinary Markdown when color, background, or size is not required.

## Built-in SiYuan User Guide lookup

When the user asks whether SiYuan supports a feature or how a SiYuan feature works, prefer the built-in User Guide over speculation about UI behavior.

Known guide notebook IDs from the built-in agent implementation:

| Language            | Notebook ID              |
| ------------------- | ------------------------ |
| Simplified Chinese  | `20210808180117-czj9bvb` |
| Traditional Chinese | `20211226090932-5lcq56f` |
| Japanese            | `20240530133126-axarxgx` |
| Other languages     | `20210808180117-6v0mkxr` |

Procedure:

1. Run `notebook list` and verify that the expected guide notebook exists.
2. If it exists but is closed and access requires it, use `notebook open --id <guide-id>`.
3. Search within the guide notebook using `siyuan search` with the notebook filter.
4. Read the most relevant result before answering.
5. Link cited guide blocks with `siyuan://blocks/<actual-id>` where useful.
6. If nothing authoritative is found, say that the guide search did not verify the feature. Do not invent a feature or UI workflow.

Example:

```bash
GUIDE_NOTEBOOK_ID="20210808180117-czj9bvb"

siyuan search "keyword" \
  --notebook "$GUIDE_NOTEBOOK_ID" \
  --method 0 \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Treat the fixed IDs as known defaults, not permission to skip verification: localized builds or future versions may differ.

## Debugging SiYuan errors

When the user reports a SiYuan error, crash, failed operation, or unexpected kernel behavior:

1. Resolve the workspace.
2. Read the last approximately 200 lines of `temp/siyuan.log` (general log) and `temp/siyuan-cli.log` (cli log) before guessing at a fix.
3. Summarize the relevant errors, timestamps, and affected subsystem.
4. Correlate them with the failed CLI command or user action.
5. Only then propose or execute a repair.

When direct filesystem access is available:

```bash
tail -n 200 "$SIYUAN_WORKSPACE/temp/siyuan.log"
```

and/or:

```bash
tail -n 200 "$SIYUAN_WORKSPACE/temp/siyuan-cli.log"
```

When only the CLI should be used for reading, note that `siyuan file read` in 3.7.0 has no offset or limit flags. Avoid dumping the full log into the final response; capture it, inspect the tail locally, and summarize only relevant lines:

```bash
log_output="$(siyuan file read "temp/siyuan.log" \
  --workspace "$SIYUAN_WORKSPACE")"

printf '%s\n' "$log_output" | tail -n 200
```

and/or:

```bash
cli_log_output="$(siyuan file read "temp/siyuan-cli.log" \
  --workspace "$SIYUAN_WORKSPACE")"
printf '%s\n' "$cli_log_output" | tail -n 200
```

Do not paste the full log by default. Redact secrets and unrelated private content. The `file` command family is appropriate for logs and explicit workspace-file tasks, but not as a back door for editing structured SiYuan data.

## Output-size discipline

- Use pagination for search, history, repository, and database results.
- Respect the default `--limit 200` behavior of `file find` and `file grep`, changing it only when needed.
- Narrow queries or use CLI pagination/limit flags before raising result sizes.
- If output is truncated, captured, or redirected to a file by the host agent, retrieve only the relevant next segment or slice rather than loading everything blindly.

## Common workflows

### 1. Find and read a document

```bash
SIYUAN_WORKSPACE="/absolute/path/to/workspace"

siyuan document search "meeting notes" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json

siyuan document get \
  --id "$DOCUMENT_ID" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json

siyuan block kramdown \
  --id "$DOCUMENT_ID" \
  --mode md \
  --workspace "$SIYUAN_WORKSPACE"
```

Use `document list --notebook <id>` when the notebook and location are already known. Use full-text `search` when looking for blocks or content across documents.

### 2. Search the knowledge base

Basic keyword search:

```bash
siyuan search "release plan" \
  --method 0 \
  --order-by 7 \
  --page 1 \
  --page-size 32 \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Useful search method values:

```text
0 = keyword
1 = query syntax
2 = SQL
3 = regex
4 = fuzzy
```

Useful grouping:

```text
0 = no grouping
1 = group by document
```

Filters can be repeated for notebook IDs, paths, block types, and subtypes. Use only documented values from `siyuan search --help`.

### 3. Create a document

Discover the notebook first:

```bash
siyuan notebook list \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Present the plan and obtain user confirmation. After creating the automatic snapshot required by the main skill, execute:

```bash
siyuan document create \
  --notebook "$NOTEBOOK_ID" \
  --path "/" \
  --title "New document" \
  --markdown "Initial content" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

After execution, capture the returned document ID and verify it with `document get` and `block kramdown`.

Do not pipe multiline content into `document create --file -` unless live help explicitly documents `--file` for `document create`. In the tested CLI, `document create` uses `--markdown` for initial content. For substantial content, create the document first, then append or update content through a block command using `--file -` or a temporary Markdown file where supported.

### 4. Safely update a block

Read and preserve the current content:

```bash
siyuan block kramdown \
  --id "$BLOCK_ID" \
  --mode md \
  --workspace "$SIYUAN_WORKSPACE"
```

Include the task's one automatic snapshot as the first item in the operation plan. After the user confirms, create the snapshot before updating the block:

```bash
siyuan repo create \
  --memo "External AI agent auto snapshot: update block $BLOCK_ID" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

After the snapshot succeeds, execute the confirmed block update:

```bash
siyuan block update \
  --id "$BLOCK_ID" \
  --file "/path/to/replacement.md" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Read the Kramdown again and compare the raw output with the intended content.

`block update` replaces the target block content. Do not use it when append, prepend, or insertion is the actual intent.

### 4A. Insert content below a heading safely

A heading cannot be used as `--parent`. Inspect the structure first:

```bash
siyuan block get \
  --id "$HEADING_ID" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json

siyuan block breadcrumb \
  --id "$HEADING_ID" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json

siyuan block children \
  --id "$ACTUAL_PARENT_ID" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Determine the last sibling in that heading's section, present the plan, and obtain user confirmation. After creating the automatic snapshot required by the main skill, execute:

```bash
cat <<'EOF' | siyuan block insert \
  --parent "$ACTUAL_PARENT_ID" \
  --previous "$LAST_BLOCK_IN_SECTION_ID" \
  --file - \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
New content below the heading.
EOF
```

After execution, read the parent's children again to verify ordering. If the heading currently has no section content, use the heading ID as `--previous` and its actual container as `--parent`.

### 5. Append to today's daily note

For any diary, journal, daily log, or today's-note request, use this command family rather than `document create`. For appending or prepending content, present the plan and obtain user confirmation; after creating the automatic snapshot required by the main skill, execute the write commands shown below.

`dailynote create` is a get-or-create operation for today's daily note; use the returned document/block ID for subsequent append or prepend operations.

```bash
siyuan dailynote create \
  --notebook "$NOTEBOOK_ID" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json

cat <<'EOF' | siyuan dailynote append \
  --notebook "$NOTEBOOK_ID" \
  --file - \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
## Agent log

- Completed the requested task.
EOF
```

Use `prepend` only when content must appear at the beginning of the daily note.

### 6. Work with block attributes

Read first:

```bash
siyuan attr get \
  --id "$BLOCK_ID" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Present the plan and obtain user confirmation. After creating the automatic snapshot required by the main skill, execute:

```bash
siyuan attr set \
  --id "$BLOCK_ID" \
  --attr 'tags=project,review' \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Attributes may be repeated with multiple `--attr name=value` arguments. Follow live help for special formats such as `icon` and `title-img`. A title image requires CSS `background-image` syntax rather than a bare asset path.

`attr set` changes attributes on a block, including a document block. It does not set notebook icons. Use `notebook set-icon --id ...` for a specific notebook, and never omit `--id` from `notebook random-icon` unless changing every notebook is intentional.

### 7. Inspect and update a database

Discover databases:

```bash
siyuan database search "Tasks" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Inspect structure and data:

```bash
siyuan database get \
  --av "$AV_ID" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json

siyuan database keys \
  --av "$AV_ID" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json

siyuan database render \
  --av "$AV_ID" \
  --page 1 \
  --size 50 \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Before updating a cell, discover the exact attribute-view ID, key ID, item ID, and required JSON value shape. Do not infer the value schema from the field name alone. Present the plan and obtain user confirmation. After creating the automatic snapshot required by the main skill, execute:

```bash
siyuan database item update \
  --av "$AV_ID" \
  --key "$KEY_ID" \
  --item "$ITEM_ID" \
  --value "$CELL_VALUE_JSON" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Database key types documented in 3.7.0 are:

```text
block text number date select mSelect url email phone mAsset template
created updated checkbox relation rollup lineNumber
```

Use the exact type spelling shown by live help.

### 8. Export a document

Markdown to stdout:

```bash
siyuan export md \
  --id "$DOCUMENT_ID" \
  --workspace "$SIYUAN_WORKSPACE"
```

Markdown to a file:

```bash
siyuan export md \
  --id "$DOCUMENT_ID" \
  --output "/absolute/path/document.md" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Other supported export targets include HTML, preview HTML, DOCX, Markdown ZIP, `.sy.zip`, and a full workspace data backup. Do not overwrite an existing user file without approval.

### 9. Import Markdown

Inspect the destination notebook and path first, then present the plan with the source path, target notebook, and destination hpath. Obtain explicit user confirmation; after creating the automatic snapshot required by the main skill, execute:

```bash
siyuan import md \
  --file "/absolute/path/source" \
  --notebook "$NOTEBOOK_ID" \
  --hpath "/Imported" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Importing a directory or backup can create many documents. Treat broad imports as high impact — flag them prominently in the plan.

### 10. Inspect references

```bash
siyuan ref backlinks \
  --id "$BLOCK_ID" \
  --sort 0 \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json

siyuan ref mentions \
  --id "$BLOCK_ID" \
  --sort 0 \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Use `ref refresh` only when the user asks to refresh references or when a verified workflow requires it. It requires clear user intent, but it does not require an automatic snapshot.

### 11. Inspect history and recover content

Search history first:

```bash
siyuan history search "keyword" \
  --page 1 \
  --type 1 \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Read a historical file:

```bash
siyuan history get \
  --path "$HISTORY_PATH" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Do not run `history rollback` until the exact historical path and target have been verified and the user has approved the rollback.

### 12. Use snapshots for protection and recovery

In a mutation task, include one automatic snapshot as the first planned execution step. After the user confirms the plan, create it and retain its returned ID:

```bash
siyuan repo create \
  --memo "External AI agent auto snapshot: batch edit" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

List and compare snapshots:

```bash
siyuan repo list \
  --page 1 \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json

siyuan repo diff \
  --left "$LEFT_SNAPSHOT_ID" \
  --right "$RIGHT_SNAPSHOT_ID" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

`repo checkout`, `repo purge`, and `repo file rollback` are destructive recovery operations. Require explicit confirmation. If the automatic snapshot cannot be created, stop planned writes by default rather than continuing unprotected.

### 13. Inspect unused assets safely

```bash
siyuan asset unused \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json

siyuan asset stat \
  --path "$ASSET_PATH" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Only after confirming a specific asset is unused, present the plan and obtain explicit user confirmation. After creating the automatic snapshot required by the main skill, execute:

```bash
siyuan asset clean \
  --path "$ASSET_PATH" \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Never interpret “list unused assets” as authorization to delete them.

### 14. Use workspace file commands carefully

Read-only examples:

```bash
siyuan file find "data/templates" \
  --include '*.md' \
  --limit 200 \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json

siyuan file grep \
  --pattern 'TODO|FIXME' \
  --path "data/templates" \
  --include '*.md' \
  --context 2 \
  --limit 200 \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Default to file commands for logs, debugging, and explicitly requested workspace-file operations. Use file writes, renames, copies, and deletions only for clearly identified non-internal files and explicit user intent. Never use them for documents, blocks, attributes, databases, notebooks, indexes, or `.sy` data.

### 15. Execute SQL conservatively

Use SQL only when higher-level commands cannot answer the question efficiently.

```bash
siyuan sql \
  "SELECT id, content, type FROM blocks WHERE content LIKE '%keyword%' LIMIT 20" \
  --limit 100 \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Agent policy:

- Default to `SELECT` only.
- Include an explicit `LIMIT` in the statement and use `--limit`.
- Do not use `INSERT`, `UPDATE`, `DELETE`, `REPLACE`, `DROP`, `ALTER`, `CREATE`, `PRAGMA`, or other write/schema statements unless the user explicitly requests a database-level operation and accepts the risk.
- Prefer `search`, `document`, `block`, `database`, and `attr` commands for normal operations.
- Never assume table or column names; inspect known documentation or a verified schema first.

### 16. Synchronization

Inspect status freely:

```bash
siyuan sync status \
  --workspace "$SIYUAN_WORKSPACE" \
  --format json
```

Treat pull and push as high impact because they interact with remote state. Present the plan, include the automatic safety snapshot as the first execution step after confirmation unless the user explicitly opts out, and obtain explicit user confirmation before executing:

```bash
siyuan sync pull --workspace "$SIYUAN_WORKSPACE" --format json
siyuan sync push --workspace "$SIYUAN_WORKSPACE" --format json
```

Do not choose pull versus push on the user's behalf when the intended direction is ambiguous.

### 17. Start the HTTP server only when requested

```bash
siyuan serve \
  --workspace "$SIYUAN_WORKSPACE" \
  --port "6806" \
  --mode prod \
  --readonly true \
  --accessAuthCode "$AUTH_CODE"
```

Before starting the server:

- Confirm that a server is actually needed; direct CLI commands do not require it for normal CLI workflows.
- Prefer read-only mode when writes are unnecessary.
- Use an access authentication code when the server may be reachable outside a trusted local environment.
- Consider `--ssl` when appropriate.
- Do not expose secrets in logs or command summaries.
- Do not use `--attach-ui` unless integrating with the desktop UI lifecycle.

## Command selection guide

| User intent                            | Preferred command family                                          |
| -------------------------------------- | ----------------------------------------------------------------- |
| Find text or blocks                    | `search`, then `block`                                            |
| Find a document by title               | `document search`                                                 |
| Inspect a document                     | `document get` / `document info`, `block kramdown`, `outline get` |
| Create or organize documents           | `document`                                                        |
| Read or change block content           | `block`                                                           |
| Read or change custom attributes       | `attr`                                                            |
| Work with daily notes                  | `dailynote`                                                       |
| Work with attribute-view databases     | `database`                                                        |
| Read backlinks or mentions             | `ref`                                                             |
| Work with notebooks                    | `notebook`                                                        |
| Work with templates                    | `template`                                                        |
| Import/export data                     | `import`, `export`                                                |
| Inspect or clean assets                | `asset`                                                           |
| Read workspace files                   | `file`                                                            |
| Search or restore history              | `history`                                                         |
| Create, inspect, or restore snapshots  | `repo`                                                            |
| Inspect tags or bookmarks              | `tag`, `bookmark`                                                 |
| Check or run cloud synchronization     | `sync`                                                            |
| Run a precise read-only database query | `sql`                                                             |
| Start the kernel HTTP service          | `serve`                                                           |
