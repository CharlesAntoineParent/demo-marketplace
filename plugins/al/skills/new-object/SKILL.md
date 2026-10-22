---
name: new-object
description: Create a new AL object (table, table extension, page, page extension, codeunit, enum, report, query, permission set) with a free object ID, the project's affix and the team's file naming. Use when the user asks to add or scaffold any AL object.
argument-hint: "[object type] [name]"
---

# Create a new AL object

## 1. Read the project rules first

- `app.json` → `idRanges`: the allowed object IDs.
- `AppSourceCop.json` → `mandatoryAffixes`: the prefix or suffix every object name must carry. If the file is missing, look at existing object names and reuse their affix. If there is none, ask the user.
- Existing files in `src/`: follow the folder layout already in place.

## 2. Get a free ID

Use the MCP tool `al_getnextobjectid` with the object type. It doesn't reserve the ID: create and save the file before asking for another one. Without MCP, scan existing objects of that type and take the next free number inside `idRanges`. Never use an ID outside `idRanges`.

## 3. Name the file

`<ObjectNameWithoutAffix>.<ObjectType>.al`, for example `CustomerRating.Table.al`, `CustomerCard.PageExt.al`, `SalesPostSubscribers.Codeunit.al`.
Object types: `Table`, `TableExt`, `Page`, `PageExt`, `Codeunit`, `Enum`, `EnumExt`, `Report`, `ReportExt`, `Query`, `XmlPort`, `PermissionSet`, `Interface`.

## 4. Write the object

- Tables: `DataClassification` on every field, a `Caption` on the table and fields, a primary key.
- Pages: `ApplicationArea` and a `ToolTip` on every field and action; `UsageCategory` only if the page must appear in search.
- Prefer extending a standard object (`tableextension`, `pageextension`) over copying it.
- New tables and pages need permissions: add them to the project's permission set, or create one if none exists.

## 5. Check

Compile (see the `build-and-lint` skill) and fix every diagnostic on the new file.
