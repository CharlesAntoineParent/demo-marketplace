---
name: event-subscriber
description: Change standard Business Central behavior by subscribing to an existing event instead of copying or modifying base code. Use when the user wants to hook into posting, validation, release or any other standard BaseApp process.
---

# Hook into standard behavior with an event subscriber

## 1. Find the right event

- Search with the MCP tool `al_symbolsearch` for the publisher codeunit or table and its `OnBefore...` / `OnAfter...` events (for example `"Sales-Post"`, `OnBeforePostSalesDoc`).
- Read the event's parameters before choosing it: an `OnBefore` event with `var IsHandled: Boolean` lets you replace the standard logic; an `OnAfter` event only adds to it.
- Prefer the most specific event that fires as late as possible. If no event fits, stop and tell the user. Don't copy standard code.

## 2. Write the subscriber

Put subscribers in a codeunit dedicated to the area, for example `SalesPostSubscribers.Codeunit.al`, with `SingleInstance` only if state must survive between calls.

```al
[EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
local procedure CheckRatingOnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
begin
    // Keep the subscriber thin: call a procedure in a business-logic codeunit.
end;
```

- Copy the parameter list from the publisher exactly; you can drop parameters you don't use, but not change their types or `var`.
- Name the procedure after what it does, not after the event.
- Setting `IsHandled := true` skips the standard code: only do it when the user asked to replace that logic, and say so in the summary.

## 3. Check

Compile and add or update a test that proves the subscriber fires (see `test-codeunit`).
