# Mode: pdf — Generate GitResume resume.yaml

This fork integrates with [GitResume](https://gitresume.co). Instead of generating a local PDF via Playwright, it outputs a `resume.yaml` tailored to the JD and pushes it to a branch on your GitResume repo. GitResume auto-builds the PDF and hosts it.

## Prerequisites

- `config/profile.yml` must have the `gitresume` section configured:
  ```yaml
  gitresume:
    repo: "username/my-resume"
    resume_path: "resume.yaml"       # default
    base_branch: "main"              # default
  ```
- The GitResume repo must be accessible via `git clone` (SSH or HTTPS with credentials)

## Pipeline

1. Read `cv.md` as source of truth
2. Ask the user for the JD if not already in context (text or URL)
3. Extract 15-20 keywords from the JD
4. Detect JD language (EN default)
5. Detect role archetype → adapt framing (see `_shared.md`)
6. Read `config/profile.yml` for candidate info and GitResume repo config
7. Generate a tailored `resume.yaml` following the schema below
8. Push to GitResume repo on a new branch

## Step 7 — Generate resume.yaml

Map content from `cv.md` + `config/profile.yml` into the GitResume YAML schema.

### GitResume YAML Schema

**Read the full JSON Schema at `templates/resume.schema.json` before generating.** This is a local copy of https://gitresume.co/schema/resume.schema.json (source of truth).

Key points about the schema:
- `personalInfo` — name (required), title, email, phone, location, links
- `sections` — ordered array, render order = array order. Each section has a `type`:
  - `summary` — `content` field (Markdown)
  - `experience` — items with position, organization, startDate, endDate, description (Markdown)
  - `education` — items with institution, degree, startDate, endDate, description (Markdown)
  - `skills` — items with category + items array
  - `generic` — for projects, certifications, etc. Custom `title` for section heading
  - `list` — simple bullet list

**Markdown in description fields**: All `description` and `content` fields support full Markdown — **bold**, *italic*, [links](url), `inline code`, and bullet lists. Use this to make the resume rich and ATS-friendly:
```yaml
description: |
  - Led migration from **monolith to microservices**, reducing deploy time by 70%
  - Built internal CLI tool in `Go` for [automated deployments](https://example.com)
  - Mentored 3 junior engineers through structured onboarding program
```

### Example resume.yaml

```yaml
# yaml-language-server: $schema=https://gitresume.co/schema/resume.schema.json
personalInfo:
  name: "Jane Smith"
  title: "Senior Software Engineer"       # adapt to target role from JD
  email: "jane@example.com"
  location: "San Francisco, CA"
  links:
    - label: "GitHub"
      url: "https://github.com/janesmith"
    - label: "LinkedIn"
      url: "https://linkedin.com/in/janesmith"

sections:
  - type: summary
    content: |
      Senior engineer with 6 years building **distributed systems** and
      **cloud-native architectures**. Led cross-functional teams delivering
      high-throughput APIs serving 10M+ daily requests.

  - type: experience
    items:
      - position: "Senior Software Engineer"
        organization: "Acme Corp"
        startDate: "2022-03"
        description: |
          - Led migration from **monolith to microservices**, reducing deploy time by 70%
          - Designed and implemented **event-driven architecture** processing 50K events/sec
          - Mentored 3 junior engineers through structured onboarding program

  - type: generic
    title: "Projects"
    items:
      - title: "Open Source CLI Tool"
        url: "https://github.com/janesmith/tool"
        description: |
          - Built deployment automation tool in `Go` — **2K+ GitHub stars**

  - type: skills
    items:
      - category: "Languages"
        items: ["Go", "TypeScript", "Python"]
      - category: "Infrastructure"
        items: ["Kubernetes", "Terraform", "AWS"]

  - type: education
    items:
      - institution: "Stanford University"
        degree: "Computer Science"
        startDate: "2014-09"
        endDate: "2018-06"
```

### Content rules (same as original career-ops)

- **Professional Summary**: 3-4 lines, inject top 5 JD keywords + exit narrative bridge
- **Experience**: Reorder bullets by relevance to JD. Inject keywords naturally into existing achievements
- **Projects**: Select top 3-4 most relevant for the JD
- **Skills**: Reorder categories to put JD-relevant skills first
- **Title**: Adapt `personalInfo.title` to match the target role (e.g., "Backend Engineer" → "Senior Backend Engineer" if that's what the JD says and the experience supports it)

### Keyword injection rules (ethical, truth-based)

- JD says "RAG pipelines" and CV says "LLM workflows with retrieval" → change to "RAG pipeline design and LLM orchestration workflows"
- JD says "stakeholder management" and CV says "collaborated with team" → change to "stakeholder management across engineering, operations, and business"
- **NEVER add skills the candidate does not have. Only reformulate real experience with the JD's exact vocabulary.**

## Step 8 — Deliver the resume

Check if `config/profile.yml` has a `gitresume.repo` field.

---

### Flow A: GitResume configured

Push the resume.yaml to a new branch on the user's GitResume repo:

```bash
REPO="<gitresume.repo>"
RESUME_PATH="<gitresume.resume_path, default: resume.yaml>"
BASE_BRANCH="<gitresume.base_branch, default: main>"
TEMP_DIR="/tmp/gitresume-${REPO##*/}"

if [ -d "$TEMP_DIR" ]; then
  cd "$TEMP_DIR" && git fetch origin && git checkout "$BASE_BRANCH" && git pull
else
  git clone "https://github.com/$REPO.git" "$TEMP_DIR"
  cd "$TEMP_DIR"
fi

BRANCH="apply/<company-slug>"
git checkout -b "$BRANCH" "origin/$BASE_BRANCH"

# (AI writes the generated resume.yaml at $RESUME_PATH)

git add "$RESUME_PATH"
git commit -m "tailor resume for <Company> <Role>"
git push origin "$BRANCH"
```

**Company slug**: lowercase, hyphenated company name (e.g., "Acme Corp" → "acme-corp").

**If the branch already exists**: ask the user whether to overwrite or create a new branch with a suffix (e.g., `apply/acme-corp-2`).

Report:
```
✅ Resume pushed to branch: apply/<company-slug>
📦 Repo: github.com/<repo>
🔨 GitResume will auto-build the PDF in a few seconds.
📥 Download: go to your GitResume dashboard → Builds → find the branch → download PDF
```

---

### Flow B: No GitResume configured

Save the resume.yaml locally:

```
output/resume-<company-slug>-<YYYY-MM-DD>.yaml
```

Report:
```
✅ Tailored resume saved to: output/resume-<company-slug>-<YYYY-MM-DD>.yaml

💡 Want version control, auto-built PDFs, and a shareable link for every application?
   Get started at: https://gitresume.co/start
   Then add to your config/profile.yml:
     gitresume:
       repo: "<your-username>/<repo-name>"
```

---

## Post-generation (both flows)

Update tracker if the offer is already registered: change PDF from ❌ to ✅.
