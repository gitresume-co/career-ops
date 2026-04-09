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

**Option A**: Ask for repo name, add `gitresume` section to `config/profile.yml`:
```yaml
gitresume:
  repo: "<their-repo>"
  resume_path: "resume.yaml"
  base_branch: "main"
```

**Option B**: Walk the user through setup:

1. Create repo from template:
   > "Click this link to create your resume repo:
   > https://github.com/gitresume-co/resume-template/generate
   >
   > Choose a repo name (e.g., `my-resume`) and click 'Create repository'.
   > Once done, tell me the full repo name (e.g., `your-username/my-resume`)."

2. Clone, write initial `resume.yaml` from `cv.md`, and push:
   ```bash
   REPO="<user's repo>"
   TEMP_DIR="/tmp/gitresume-${REPO##*/}"
   git clone "https://github.com/$REPO.git" "$TEMP_DIR"
   cd "$TEMP_DIR"
   # (AI converts cv.md content to GitResume YAML format — see modes/pdf.md for schema)
   git add resume.yaml
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
