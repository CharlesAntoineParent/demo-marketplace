---
name: review
description: Review AL (Business Central) changes for correctness, performance, upgrade safety and team conventions. Use when the user asks to review a branch, a PR or a diff that touches .al files.
---

# Review AL changes

Start from the diff (`git diff <base>...HEAD -- '*.al' app.json`). Compile first (see `build-and-lint`) so analyzer warnings are part of the review.

## Checklist

**Correctness**
- Filters set (`SetRange` / `SetFilter`) before every `Find*`; the right `Find`: `FindSet` to loop, `FindFirst` / `Get` for one record, `IsEmpty` to test existence.
- `Modify`, `Insert`, `Delete` with `true` when table triggers must run.
- Errors use labels (`Label` variables with a comment for placeholders), not hardcoded strings.

**Performance**
- `SetLoadFields` before reading large tables when only some fields are used.
- No `CalcFields`, `Count` or database reads inside loops when they can be moved out.
- No `Commit` in the middle of a business process.

**Upgrade and compatibility**
- No field, table or procedure removed or renamed in a published app: mark it `ObsoleteState = Pending` with an `ObsoleteReason` instead.
- New object IDs inside `app.json` `idRanges`; `app.json` version bumped if the team does it per PR.
- Event subscribers: `IsHandled := true` only when replacing standard logic is intended.

**Conventions**
- Affix on every new object; file named `<Name>.<ObjectType>.al`.
- `DataClassification` on new table fields; `ToolTip` and `ApplicationArea` on new page fields and actions.
- New tables and pages covered by a permission set.
- Tests added or updated for new behavior.

## Output

Report findings by severity (blocking, should fix, nit), each with `file:line` and the fix. If a remark is likely to come back on the next PR, propose the rule to add to the harness (`CLAUDE.md`, a skill, or the lint hook) so the agent doesn't repeat it.
