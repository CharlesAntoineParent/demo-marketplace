---
name: test-codeunit
description: Write or update AL test codeunits for Business Central code, in Given/When/Then form with Library Assert. Use when the user asks for tests, when a bug fix needs a regression test, or after adding business logic.
---

# Write AL tests

## Where

Tests live in the test app of the workspace (a separate project whose `app.json` depends on the main app and on the test libraries). Find it before writing; if there is none, ask the user before creating one.

## Shape

```al
codeunit 50150 "Customer Rating Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        LibrarySales: Codeunit "Library - Sales";

    [Test]
    procedure PostingBlockedWhenRatingTooLow()
    var
        Customer: Record Customer;
    begin
        // [GIVEN] A customer with a low rating
        LibrarySales.CreateCustomer(Customer);
        // [WHEN] An order is posted
        // [THEN] Posting fails with the rating error
        Assert.ExpectedError('...');
    end;
}
```

## Rules

- One behavior per test, named after the behavior.
- Create test data with the standard `Library - *` codeunits instead of relying on demo data.
- Every confirm, message or page that opens during the test needs a `[ConfirmHandler]`, `[MessageHandler]` or `[ModalPageHandler]` listed in `[HandlerFunctions(...)]`.
- For a bug fix: write the test first, show it fails, then fix.
- Run the tests (`al runtests`, or the team's pipeline) and report the result. If you can't run them here, say so plainly instead of claiming they pass.
