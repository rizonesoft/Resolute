## What does this change?

One or two sentences, and the plan section it builds (`DNN TNN §N`).

## What proves it works?

Quote the proof from a real run, at least one of the five in [`CONTRIBUTING.md`](../CONTRIBUTING.md#what-proof-does-a-change-owe):

- [ ] Builds clean, warnings as errors
- [ ] `clang-tidy` reports nothing new
- [ ] A Catch2 test, shown failing without this change
- [ ] A driven run: a log line, a read-back, or a capture with its provenance file
- [ ] Parity with the AutoIt original on the same fixture (a ported tool)

```text
paste the output here
```

## What did you check?

- [ ] The checks that cover this change ran locally, and their output is quoted above. The `gates` workflow runs every gate on this pull request; a full local `pwsh scripts/check-all.ps1` is welcome and not required
- [ ] A frozen tool's effect is unchanged, or this pull request touches none
- [ ] No em dashes, one line per paragraph
