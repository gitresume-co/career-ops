# Syncing with upstream (santifer/career-ops)

This fork (`gitresume-co/career-ops`) tracks `santifer/career-ops` as `upstream`. Periodically merge upstream into `feat/gitresume-integration` to absorb bug fixes and new features.

## One-time setup (per clone)

```bash
scripts/setup-dev.sh
```

This enables:
- `rerere` — remembers previously-resolved merge conflicts and replays them automatically
- `merge.ours` driver — used by `.gitattributes` for fork-owned files

Both are local `.git/config` settings; they don't travel with the repo. Run after every fresh clone.

## Sync workflow

```bash
git fetch upstream
git checkout feat/gitresume-integration
git merge upstream/main
```

### What `.gitattributes` handles automatically

These files are fork-owned. `merge=ours` keeps our version:
- `modes/pdf.md` — GitResume push flow (fork rewrote it)
- `README.md` — GitResume rebrand
- `docs/hero-banner.jpg` — GitResume social preview
- `README.es.md` — fork removed Spanish translation

### What `rerere` handles after the first sync

Once you resolve a conflict, rerere records it. Next time the same hunk reappears in an upstream merge, it auto-resolves. Currently learned files:
- `CLAUDE.md`, `AGENTS.md`
- `batch/batch-prompt.md`
- `config/profile.example.yml`
- `modes/_shared.md`, `modes/auto-pipeline.md`, `modes/pt/_shared.md`
- `update-system.mjs`

If the upstream change touches a different hunk than before, rerere falls through and you resolve manually — that new resolution then gets recorded for next time.

### What you still need to do every sync

Three special cases `.gitattributes`/`rerere` can't auto-resolve:

```bash
# 1. README.es.md — fork deleted, upstream sometimes modifies it
git rm -f README.es.md 2>/dev/null

# 2. docs/CODEX.md — upstream deleted, sometimes fork still has it
git rm -f docs/CODEX.md 2>/dev/null

# 3. .claude/skills/career-ops/SKILL.md — upstream made it a symlink
rm -f .claude/skills/career-ops/SKILL.md~HEAD
git checkout --theirs -- .claude/skills/career-ops/SKILL.md
git add .claude/skills/career-ops/SKILL.md
```

### Sanity checks before committing the merge

```bash
# No leftover conflict markers
! grep -rn "<<<<<<<\|=======\|>>>>>>>" --include="*.md" --include="*.mjs" --include="*.yml" --include="*.json"

# AGENTS.md still has GitResume Edition banner
grep -q "GitResume Edition" AGENTS.md

# modes/pdf.md still the GitResume version (not Playwright)
grep -q "Generate GitResume resume.yaml" modes/pdf.md

# config/profile.example.yml still has gitresume: section
grep -q "^gitresume:" config/profile.example.yml

# TSV format still 10 columns with branch
grep -q "10 tab-separated columns" AGENTS.md
```

If anything fails, the merge missed a fork invariant — re-apply the affected fork edits from the previous merge commit.

## Fork-specific invariants

These customizations distinguish the fork from upstream. **Any merge that loses any of these is broken** and must be re-applied:

1. **`modes/pdf.md`** — generates `resume.yaml` and pushes to GitResume repo, NOT Playwright PDF
2. **`modes/gitresume.md`** — new file, setup flow for GitResume integration
3. **`templates/resume.schema.json`** — GitResume YAML schema (source of truth at `https://gitresume.co/schema/resume.schema.json`)
4. **`AGENTS.md`** — title is "(GitResume Edition)", Step 3 is GitResume setup, tracker has Branch column, TSV is 10 cols
5. **`config/profile.example.yml`** — has `gitresume:` section, no `cv.output_format` / Canva
6. **`modes/_shared.md`** / **`modes/pt/_shared.md`** — Tools table mentions `resume.yaml` and Git operations, not `generate-pdf.mjs`
7. **`batch/batch-prompt.md`** — outputs resume.yaml, no HTML template placeholder table
8. **`update-system.mjs`** — SYSTEM_PATHS comment indicates `generate-pdf.mjs` removed
9. **README and hero banner** — GitResume rebrand (not santifer original)
10. **No `README.es.md`** — Spanish README removed
