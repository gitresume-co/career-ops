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

Map content from `cv.md` + `config/profile.yml` into the GitResume YAML schema:

### GitResume YAML Schema

```yaml
# yaml-language-server: $schema=https://gitresume.co/schema/resume.schema.json
personalInfo:
  name: "Full Name"                    # from profile.yml candidate.full_name
  title: "Job Title"                   # adapt to target role from JD
  email: "email@example.com"           # from profile.yml candidate.email
  phone: "+1-555-0123"                 # from profile.yml candidate.phone (optional)
  location: "City, Country"            # from profile.yml location.city + country
  links:
    - label: "GitHub"
      url: "https://github.com/username"
    - label: "LinkedIn"
      url: "https://linkedin.com/in/username"

sections:                              # array order = render order on the resume

  - type: summary
    content: |                         # Markdown supported
      3-4 lines, keyword-dense professional summary.
      Inject top JD keywords + exit narrative bridge.

  - type: experience
    items:
      - position: "Senior Software Engineer"
        organization: "Company Name"
        startDate: "2022-03"           # YYYY-MM format
        endDate: null                  # null = present
        description: |                 # Markdown supported
          - Bullet points reordered by relevance to JD
          - Keywords injected naturally into existing achievements
          - NEVER invent experience — only reformulate with JD vocabulary

  - type: generic                      # Use for Projects, Certifications, etc.
    title: "Projects"                  # Section heading
    items:
      - title: "Project Name"
        url: "https://example.com"     # optional
        startDate: "2024-01"           # optional
        description: |
          - Top 3-4 most relevant projects for this JD

  - type: skills
    items:
      - category: "Languages"
        items: ["Go", "TypeScript", "Python"]
      - category: "Infrastructure"
        items: ["Kubernetes", "Terraform", "AWS"]

  - type: education
    items:
      - institution: "University Name"
        degree: "Computer Science"
        startDate: "2016-09"
        endDate: "2020-06"
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
