# SiYuan CLI Workflows

Read `SKILL.md` first. This file contains only SiYuan-specific workflows, content conventions, and tested behaviors that are not reliably derived from ordinary command help.

Every command example is illustrative. Before execution, run the exact `siyuan <command> --help` and adapt to the installed version. Mutation examples inherit the main skill's discovery, task-ID confirmation, applicable snapshot, fail-stop, retry-budget, and verification rules.

## Content input and shell safety

Do not write hidden reasoning, planning traces, or provider-specific thinking tags into notes or titles unless the user explicitly requests them.

For multiline Markdown or text containing quotes, prefer a documented stdin/file input instead of embedding content in a shell argument. Use the input mode shown by the exact command's live help; input flags are not interchangeable between command families.

Illustrative POSIX pattern:

```bash
cat <<'EOF' | siyuan block append \
  --parent "$PARENT_ID" \
  --file - \
  --workspace "$SIYUAN_WORKSPACE"
## New section

Content generated for SiYuan.
EOF
```

Pass external values as separately quoted arguments. Never use `eval`, `sh -c`, or `bash -c` with note content, titles, IDs, paths, database values, or CLI output.

## Command selection patterns

| Intent | Workflow shape |
| --- | --- |
| Find content | search, then fetch the selected block or document |
| Explore structure | list/get document, then inspect children and breadcrumbs |
| Create content | create a document, then append/prepend/insert blocks |
| Replace one block | read structure, update one block, verify content and sibling order |
| Modify and add | update first, then append/prepend/insert separately |
| Organize | use document move/rename for documents and block move for content blocks |
| Work with attributes | inspect then set block attributes |
| Work with databases | inspect database, keys, view, item IDs, and value shape before mutation |
| Process inbox | list summaries, fetch full item, then separately confirm conversion |

Do not use ordinary document-block attributes to set notebook icons. In 3.7.3, the optional top-level notebook document is the exception because it shares the notebook ID and its icon is coupled to the notebook icon. Do not invoke an all-notebook randomization when only one notebook is intended.

In the tested CLI, semantic search is part of the search command rather than a standalone `semantic` command. Check current search help for its method value. Before using an external embedding provider, disclose whether the query or note-derived data leaves the local environment.

## Response and content conventions

- Reply in the user's language and refer to the product as **SiYuan**.
- Summarize large documents, logs, search results, and JSON.
- Link a verified document or block as `[title](siyuan://blocks/ACTUAL_ID)`.
- Never fabricate a block URI or claim an unsupported feature.
- Prefer ordinary Markdown when it expresses the requested style.

### SiYuan text marks

For text color, background color, or font size, SiYuan requires a text mark with `data-type="text"`:

```html
<span data-type="text" style="color: #ff0000;">red text</span>
<span data-type="text" style="background-color: #ffff00;">highlighted</span>
<span data-type="text" style="font-size: 18px;">larger text</span>
<span data-type="text strong" style="color: #ff0000;">bold red</span>
```

A bare `<span style="...">` may be escaped and displayed literally. Use native marks for underline, superscript, subscript, keyboard keys, and tags rather than imitating them with CSS:

```html
<span data-type="u">underlined</span>
x<span data-type="sup">2</span>
H<span data-type="sub">2</span>O
<span data-type="kbd">Ctrl</span>
<span data-type="tag">todo</span>
```

### Rendered HTML blocks

Use an HTML block only when the user wants rendered HTML rather than displayed source. SiYuan recognizes a block whose opening line starts with `<div`; wrap another root element in a `div`.

```html
<div>
<ruby>你<rt>ni</rt></ruby>
</div>
```

A fenced `html` block displays source code instead. Keep generated HTML inert: do not add scripts, event handlers, active URLs, forms, iframes, or remote resources.

## Built-in User Guide

When asked whether or how SiYuan supports a feature, search the built-in User Guide rather than inventing UI behavior. Known notebook IDs from the built-in agent are:

| Language | Notebook ID |
| --- | --- |
| Simplified Chinese | `20210808180117-czj9bvb` |
| Traditional Chinese | `20211226090932-5lcq56f` |
| Japanese | `20240530133126-axarxgx` |
| Other languages | `20210808180117-6v0mkxr` |

Verify that the guide notebook exists, open it if necessary, search within it, and read the relevant result. Treat these IDs as known defaults that may change. If the guide does not verify a feature, say so.

## Debugging and output limits

For a reported SiYuan error, inspect only a bounded relevant log excerpt and avoid sending credentials or unrelated private note text into model context. If safe redaction is not available, ask the user for a sanitized excerpt. Do not use generic file commands as a back door for editing SiYuan data.

Use pagination and narrow filters for search, history, repository, database, and file results. If a host tool truncates output, read only the relevant continuation rather than loading the entire capture.

## Common workflows

### Find and read

Choose document search when finding a document by title and full-text search when finding content or blocks. Fetch the selected object after search rather than answering from a summary row. Use structured get output for metadata and block Kramdown when the actual Markdown content is needed.

Do not assume that a global JSON flag makes raw-content commands return JSON. In CLI 3.7.3, block Kramdown is raw text.

### Process inbox items

Inbox list output is a summary. Fetch the full item before deciding where it belongs.

Conversion creates local documents and may remove cloud originals after success. Verify item IDs and the destination, explain the remote deletion consequence, obtain task-ID confirmation, and create the applicable local snapshot before conversion. A local snapshot cannot restore deleted cloud originals.

CLI 3.7.2 destination-path behavior does not reliably match the conversion help wording. Do not convert unless the installed version's destination behavior is independently known. Authentication or subscription failures are deterministic until account state changes; report them rather than retrying.

### Create or duplicate a document

For creation, discover the notebook and parent location, check live help for the command's actual path and content inputs, create the document, capture the observed result, then fetch the document and content to verify it.

CLI 3.7.3 document creation prints the new ID as plain text even when JSON format is requested.

For duplication, record the source's parent and candidate siblings before execution. CLI 3.7.3 prints the new duplicate ID as plain text even when JSON format is requested. Fetch that ID and verify the duplicate before using it in another step.

### Update one block

Read the target content, breadcrumb, and parent's child order. Use block update only to replace one existing block. To add content, use append, prepend, or insert instead.

CLI 3.7.3 does not reject update input containing several top-level blocks and may silently keep only the first; its dry-run returns before parsing the payload. Keep update input deliberately single-block. If the content may parse into several top-level blocks, use an insertion workflow or a trusted SiYuan-compatible parser. After update, re-read both content and sibling order.

### Insert below a heading

A heading is not a parent. Read the heading, breadcrumb, and actual parent's children. Find the last sibling in the heading's visual section, then insert under the real parent after that sibling. If the section is empty, insert after the heading itself. Verify the new sibling order.

### Use today's daily note

Use the daily-note command family, not ordinary document creation. Resolve or create today's note in the intended notebook, then append or prepend the requested content and verify it. If execution occurs around a date boundary, re-check which daily note is current rather than assuming the earlier target remains correct. If the target document changes, invalidate the current task ID and present the revised target under a new ID for confirmation.

### Attributes and icons

Read current attributes before changing them. Follow live help for the current attribute-input syntax. A title image uses SiYuan's CSS `background-image` form rather than a bare asset path.

Changing an ordinary document block's icon does not change a notebook icon. In 3.7.3, the optional top-level notebook document shares the notebook ID, and changing its icon also changes the notebook icon. Verify that an exact CLI document lookup resolves the notebook ID before treating it as this special document; otherwise use the notebook command family and keep randomization scoped to the intended notebook.

### Databases

Before changing a database, discover the attribute-view ID, view, key ID, item ID, and the exact JSON value shape expected by the current field. Do not infer schemas or key types from names, and read current live help rather than relying on a static enum list.

In CLI 3.7.2, adding a non-detached row requires a block ID even though help suggests the block can be generated. Use detached mode only when a detached row is intended. Verify changes through database rendering.

### Export

Confirm the source, format, and destination before writing an external file. Avoid silently overwriting an existing file; a repository snapshot cannot restore it.

CLI 3.7.2 file exports may produce no stdout, and some paths may suppress an underlying error. Verify the resulting regular file and its expected format/content.

In CLI 3.7.3 testing, `export sy` without `--output` returned an HTTP-style `/export/...` path, while `--output` attempted to read that path as a local absolute path and failed. The temporary flat archive contained only rendered text and omitted its database definition; separately, `import sy` rejected its layout as invalid because it lacked the required top-level directory. Do not rely on this CLI path for native backup or transfer; report the limitation instead of recovering the temporary file through generic file operations.

### Import

Verify the source and exact destination before import. For a non-root destination, resolve the existing destination document and hPath first. CLI 3.7.2 can silently fall back to notebook root when an hPath is unresolved and does not create a missing destination folder.

For an explicitly intended notebook-root import, use the root path form documented by current live help rather than relying on fallback. Treat directory, archive, and full-backup imports as broad mutations and call out their scope before confirmation.

### References

Use backlinks and mentions as reads. In CLI 3.7.3, their JSON output appends a human-readable count, so the complete stdout is not valid JSON. Use table output or handle the observed mixed format. Refresh references only when explicitly requested or required by a verified workflow.

### History and recovery

Search or list history before reading an entry. In CLI 3.7.2, JSON listing omits individual history paths, so use observed human-readable output to discover the path. History content is raw rather than JSON.

Rollback requires verification of the exact history entry and current target, an applicable snapshot of current local state, task-ID confirmation, and post-rollback verification. Stop concurrent writes or sync that could invalidate the recovery target.

### Repository snapshots

For covered workspace mutations, create one snapshot after approval and before the first write. CLI 3.7.3 reports `created snapshot <id>` as plain text; verify that the snapshot exists before relying on it.

Repository checkout, purge, and file rollback are high impact. A snapshot cannot protect repository data from purge, and local recovery does not automatically reconcile remote sync state.

### Assets

Listing unused assets does not authorize deletion. Before cleaning an asset, verify its exact path and current unused status, explain the deletion, obtain approval, create the applicable snapshot, then re-check unused status and verify removal.

Prefer one explicitly identified asset over broad cleanup.

### Workspace file commands

Use generic file commands for logs, debugging, and explicitly requested non-internal files. Never use them to modify documents, blocks, notebooks, databases, indexes, references, or `.sy` data. Do not assume every workspace file is covered by repository snapshots.

### SQL

Use SQL only when higher-level read commands cannot answer the question efficiently. Execute one clearly read-only query with a bounded result. Never attempt write or schema statements, even with user approval; use domain commands for mutations.

CLI 3.7.3 accepts one `SELECT` or `WITH` query and rejects other forms such as `PRAGMA`, `ATTACH`, `DETACH`, and transaction-control statements even when they appear read-only.

The CLI has no parameter-binding interface. Do not interpolate untrusted text into SQL literals. Prefer search or a domain command for dynamic user-provided values, and verify schema names instead of guessing them.

### Synchronization

Status inspection is read-only. Pull and push affect remote state, so confirm the intended direction rather than choosing it for the user. Before pull, create an applicable snapshot of current local state; a local snapshot cannot undo a push.

CLI 3.7.2 may print `ok` without propagating the actual transfer result. Compare sync status and verify expected local effects after pull. If remote success remains uncertain, report the ambiguity and stop dependent writes.

### Serve

Start the HTTP server only when explicitly requested; ordinary CLI work does not require it. Check current live help and use read-only mode when writes are unnecessary. Prefer the source-supported `SIYUAN_ACCESS_AUTH_CODE` environment variable, supplied through the host's secret environment mechanism, instead of placing the access code in command arguments, generated scripts, plans, logs, or agent-visible output.

CLI 3.7.2 ignores dry-run for `serve` and starts the server. Confirm the intended lifetime and stop the process when the task ends. Keep access local unless the user has explicitly arranged appropriate authenticated network exposure.
