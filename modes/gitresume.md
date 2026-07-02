# Mode: gitresume — Set up GitResume integration

**This is the most important setup step.** [GitResume](https://gitresume.co) is what turns career-ops from a local tool into a full pipeline — every tailored resume gets version control, an auto-built PDF, and a shareable link.

Without GitResume, tailored resumes are just local YAML files. With GitResume, every `/career-ops pdf` pushes a branch, auto-builds a professional PDF, and gives you a link to download or share.

## Check current status

Read `config/profile.yml` and check for the `gitresume` section.

### If already configured

Show the current config:
```
GitResume integration: ✅ configured
  Repo: <gitresume.repo>
  Resume path: <gitresume.resume_path>
  Base branch: <gitresume.base_branch>
```

Ask if they want to update any of these values.

### If not configured

> "GitResume gives you version-controlled resumes with auto-built PDFs and shareable links. Each tailored resume gets its own branch — full history for every application.
>
> **A)** I already have a GitResume repo → tell me the repo name (e.g., `username/my-resume`)
> **B)** I want to set one up now (2 minutes)
> **C)** Cancel"

**Option A**: Ask for repo name. Then detect the resume filename — clone the repo (or list its files via `gh api repos/<repo>/contents`) and find the existing resume file (`gitresume.yaml`, `resume.yaml`, their `.yml` variants, or a custom path). Use what actually exists; the repo is the source of truth because GitResume only builds when the pushed file matches the project's configured path. If more than one candidate exists, do NOT guess — ask the user which one **Resume Path** in the project's **Settings** tab on gitresume.co points to. Add the `gitresume` section to `config/profile.yml`:
```yaml
gitresume:
  repo: "<their-repo>"
  resume_path: "<detected filename, e.g. gitresume.yaml>"
  base_branch: "main"
```

If the repo has no resume file yet, use `gitresume.yaml` and remind the user to check that **Resume Path** in the project's **Settings** tab on gitresume.co matches.

**Option B**: Walk the user through setup:

1. Create repo from template:
   > "Click this link to create your resume repo:
   > https://github.com/gitresume-co/resume-template/generate
   >
   > Choose a repo name (e.g., `my-resume`) and click 'Create repository'.
   > Once done, tell me the full repo name (e.g., `your-username/my-resume`)."

2. Clone, write initial `gitresume.yaml` from `cv.md`, and push:
   ```bash
   REPO="<user's repo>"
   TEMP_DIR="/tmp/gitresume-${REPO##*/}"
   git clone "https://github.com/$REPO.git" "$TEMP_DIR"
   cd "$TEMP_DIR"
   # (AI converts cv.md content to GitResume YAML format — see modes/pdf.md for schema)
   git add gitresume.yaml
   git commit -m "initial resume"
   git push origin main
   ```

3. Add `gitresume` section to `config/profile.yml`.

4. **IMPORTANT — Guide user to connect the repo before continuing.** Without this step, pushes won't trigger PDF builds:
   > "Resume pushed! One last step — connect the repo to GitResume so pushes trigger PDF builds:
   > 1. Go to https://gitresume.co/start
   > 2. Sign in and grant access to your `<repo>` repo
   >
   > ⚠️ This step is required. Without it, GitResume won't build your PDFs.
   > Let me know when you're done!"

   Wait for the user to confirm before proceeding.

5. After the project is created, ask the user to verify that **Resume Path** in
   the project's **Settings** tab matches the pushed filename (`gitresume.yaml`).
   If the project was created with a different default, either rename the file
   or update the setting — a mismatch means pushes silently never build.
