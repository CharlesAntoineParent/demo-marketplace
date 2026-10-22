---
name: build-and-lint
description: Compile an AL (Business Central) project and fix its compiler and analyzer diagnostics. Use when the user asks to build, compile, lint or "make it green" on an AL project, or after a batch of changes to .al files.
---

# Build and lint an AL project

Work from the AL project root (the folder that holds `app.json`).

## Steps

1. **Symbols.** If `.alpackages/` is missing or the compiler reports missing symbols (BaseApp, System, dependencies from `app.json`), download them first:
   - with the ALCops MCP server: `al_downloadsymbols`;
   - otherwise, ask the user: symbol download needs a BC environment and sign-in.
2. **Compile with analyzers.** Prefer the MCP tools: `al_compile`, then `al_getdiagnostics`. Without MCP, run:
   ```
   al compile /project:. /packagecachepath:./.alpackages /analyzer:<CodeCop dll> /analyzer:<UICop dll>
   ```
3. **Triage the diagnostics** in this order: errors (`AL....`), then analyzer warnings (`AA....` CodeCop, `AW....` UICop, `AS....` AppSourceCop, `PTE....` PerTenantExtensionCop, ALCops rules).
4. **Fix at the root.** For an analyzer rule you don't know, look it up with the ALCops `list_rules` tool before changing code. Use `get_fixes` / `apply_fix` when a code fix exists.
5. **Recompile** until there are no errors and no new warnings.

## Rules

- Never silence a rule with `#pragma warning disable` or by editing the ruleset to get a green build. If a rule truly does not apply, stop and explain why to the user; they decide.
- Don't touch files outside the scope of the task to fix pre-existing warnings. List them in the summary instead.
- End with a short summary: errors fixed, warnings fixed, warnings left and why.
