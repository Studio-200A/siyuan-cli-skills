# Upstream Sync Checklist

## Principle

After each SiYuan release, discover what changed and synchronize only the **domain model, safety principles, user-visible CLI semantics, and externally relevant design changes**.

Do not reproduce SiYuan's Go runtime in natural language. This file defines how to find and classify changes; it must not become a version-specific update list or a duplicate catalog of current skill content.

Use one decision test:

> Does this change alter what an external Agent should understand, disclose, confirm, execute, verify, or refuse when operating SiYuan through the official Kernel CLI?

If not, do not add it to the skill.

## Sources and Evidence

Read the current truth from:

- The installed released CLI and live help.
- `SIYUAN-CLI-SKILLS.md`, `SIYUAN-CLI-WORKFLOWS.md`, and both READMEs.
- The old and new upstream release tags.
- `kernel/agent/agent.go`, changed CLI call paths, release notes, and changed upstream `docs/` files.

Do not copy their current details into this checklist; re-read them during every synchronization.

| Evidence         | Meaning                                                      | Allowed claim            |
| ---------------- | ------------------------------------------------------------ | ------------------------ |
| Runtime-tested   | Verified with the installed release against a real workspace | Tested behavior          |
| Source-confirmed | Confirmed from the matching tag but not run locally          | Source-reviewed behavior |
| Unverified       | Suggested by beta code, notes, or an indirect call path      | Maintenance note only    |

Never update `tested_with` from source review alone.

## 1. Establish the Baseline and Inventory

Before any source review or document update, verify that the local CLI is current:

- [ ] Run `siyuan --version` and parse the local version.
- [ ] Query `https://api.github.com/repos/siyuan-note/siyuan/releases/latest` and read its `tag_name` as the latest stable release.
- [ ] Normalize an optional leading `v` and compare the versions with semantic-version rules, not lexical string ordering.
- [ ] If the local version is lower, stop the entire synchronization workflow. Report both versions and ask the user to update the local CLI before restarting.
- [ ] If either version cannot be retrieved or parsed, stop because the current-release prerequisite cannot be verified.

Only after this gate passes:

- [ ] Use the latest stable release tag as the target release and record its exact commit.
- [ ] Identify the previous tested release and its exact commit.
- [ ] Record relevant test context, such as new versus upgraded workspace and optional feature state.
- [ ] Keep beta findings separate from final-release claims.

Find current version-bound statements dynamically:

```bash
rg -n 'tested_with|compatibility|CLI [0-9]|SiYuan [0-9]' \
  SIYUAN-CLI-SKILLS.md SIYUAN-CLI-WORKFLOWS.md README.md README_CN.md
```

- [ ] Review each result and extract current caveats directly from the core documents.
- [ ] Change `compatibility` only if the minimum supported version changes.
- [ ] Change `tested_with` only after runtime testing.
- [ ] Never replace a version number without verifying its associated claim.

## 2. Compare the Installed CLI

- [ ] Compare root version/help output with the previous tested release.
- [ ] Export and diff the recursive command tree with `siyuan-cli-help-export.sh`.
- [ ] Discover changes to commands, flags, defaults, aliases, and input modes from that diff.
- [ ] Re-run every behavior currently documented as a caveat in the skill.
- [ ] Check observable output and exit status where the skill depends on discovery, chaining, mutation, or verification.
- [ ] Assign an evidence level to every retained or changed claim.

Live help remains the syntax authority; do not copy it into a static command catalog.

## 3. Compare Upstream Source and Documentation

Start from the release diff rather than a preselected feature list:

```bash
git diff --name-status "$OLD_TAG".."$NEW_TAG"
git diff "$OLD_TAG".."$NEW_TAG" -- kernel/agent/agent.go
git diff --name-only "$OLD_TAG".."$NEW_TAG" -- kernel/cli kernel/model kernel/util docs
```

- [ ] In `agent.go`, review changes to the system prompt, domain concepts, tool guidance, safety intent, privacy, and capability boundaries.
- [ ] Add an Agent feature only if the CLI exposes an equivalent operation or its principle changes decisions for existing CLI commands.
- [ ] In CLI-related code, follow only changed call paths that can alter observable behavior, including changes below the handler.
- [ ] Stop following a call path when it no longer affects an external Agent's decision or result.
- [ ] In release notes and `docs/`, extract only concepts relevant to external CLI operation.
- [ ] Exclude API catalogs, direct `.sy` editing guidance, internal schemas, storage algorithms, and runtime implementation details.

## 4. Classify and Route Changes

| Change type                         | Action                                                         |
| ----------------------------------- | -------------------------------------------------------------- |
| Domain or safety design             | Update the Agent's mental model or decision rules if necessary |
| Observable CLI behavior             | Runtime-test and update the appropriate core document          |
| Important behavior hidden from help | Add a concise, evidence-labeled caveat                         |
| Capability boundary                 | Add a clear stop or redirect rule                              |
| Runtime-only implementation         | Do not synchronize                                             |
| Documentation clarification         | Add only if it changes an external CLI decision                |
| Unverified beta behavior            | Keep out of stable skill policy                                |

Reject additions that duplicate live help, enumerate drifting schemas, describe internal state machines, or implement host/runtime controls in prose.
If a finding is correct but belongs to source research rather than external-Agent behavior, keep it out of the core skill; record it in the synchronization report only when it remains useful, otherwise discard it.

| Update target                | Scope                                                                          |
| ---------------------------- | ------------------------------------------------------------------------------ |
| `SIYUAN-CLI-SKILLS.md`       | Stable domain, safety, version, path, recovery, or capability rules            |
| `SIYUAN-CLI-WORKFLOWS.md`    | Non-obvious workflows and confirmed caveats                                    |
| `README.md` / `README_CN.md` | Compatibility, setup, architecture, dependencies, and user-facing capabilities |
| This checklist               | Synchronization method changes only                                            |

## 5. Validate

- [ ] Run `git diff --check` and `bash -n siyuan-cli-help-export.sh`.
- [ ] Search again for stale version numbers and removed command names.
- [ ] Check consistency across both core documents and both READMEs.
- [ ] Confirm English and Chinese README policies remain equivalent.
- [ ] Confirm no guidance encourages direct `.sy` or unsupported filesystem mutation.
- [ ] Confirm no Go runtime implementation was recreated as a prose protocol.
- [ ] If the update substantially increases document size or complexity, justify each addition by the external Agent behavior it changes.
- [ ] Review the final diff for unrelated or duplicated content.
- [ ] Produce a concise synchronization report covering versions and test context, changed claims and their evidence levels, useful findings kept out of policy, and files changed.

Synchronization is complete when the released CLI and current caveats have been tested, relevant design and observable behavior changes are reflected in the correct documents, version claims match their evidence, and runtime-only changes have not expanded the skill.
