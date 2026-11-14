# How this wiki is kept

The wiki follows the pattern Andrej Karpathy described for LLM-maintained wikis: the source material stays untouched, an agent writes and maintains a set of linked markdown pages that summarise it, and a short schema (this page) says how.

## Three layers

1. **Source:** the code and the author's documents. The wiki never replaces them and never edits them.
2. **Wiki:** the pages in `wiki/`. Agents own these.
3. **Schema:** this page.

## Rules for pages

- One topic per page. Add a page when a topic outgrows a section; add its row to [index](index.md) in the same change.
- Every claim about behaviour cites where it comes from, as `File.swift:line` plus the function name. Line numbers drift, so the function name is what a reader searches for.
- Say how you know. Behaviour read from code but never run is marked "read from code, not run". Nobody has built or run this app while writing the wiki; there is no Xcode on the machine that wrote it.
- Describe what the code does now. Put history in [log](log.md), and bugs and traps in [gotchas](gotchas.md).
- Link pages with relative markdown links. Use the same term for the same thing everywhere; the vocabulary is in [overview](overview.md#vocabulary).
- Keep pages short enough to read in one pass. Prefer a table to a paragraph when listing fields, keys or files.

## When you change the code

1. Update every page that mentions what you changed. Search the wiki for the function, model or key name.
2. If you fixed something listed in [gotchas](gotchas.md), remove the entry.
3. Add one line to [log](log.md): date, what changed in the code, which pages you updated.
4. Update the commit named at the top of [index](index.md) if you re-checked the whole wiki against a newer commit.

## When you only read

If you find a page that is wrong, fix it and log it. If you learn something the next agent would need and no page says it, add it to the page where they would look first.

## Checking the wiki

- Every page in `wiki/` has a row in [index](index.md).
- Every relative link resolves.
- Spot-check five `File.swift:line` references against the code.
