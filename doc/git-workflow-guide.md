# Git/GitHub Project Management Guide

## Overview

This document outlines the Git/GitHub strategy for the sqr project, providing guidelines for branching, development workflow, issue management, and team collaboration.

## 1. Repository Structure & Branching Strategy

### Main Branches

```
main (production-ready code)
├── develop (integration branch)
├── staging (pre-production testing)
└── hotfix/* (emergency fixes)
```

### Feature Branches

```
feature/auth-system
feature/tenant-profiles
feature/property-management
feature/inspection-system
feature/payment-integration
feature/frontend-dashboard
```

### Branch Naming Convention

```
feature/issue-number-short-description
bugfix/issue-number-short-description
hotfix/critical-issue-description
release/version-number
```

**Examples:**
- `feature/15-tenant-profile-management`
- `feature/auth-password-reset`
- `bugfix/23-session-cache-invalidation`
- `hotfix/rate-limit-bypass`

## 2. Development Workflow

### Phase 1: Repository Setup

```bash
# Create main branches
git checkout -b develop
git checkout -b staging

# Push branches to remote
git push -u origin develop
git push -u origin staging
```

### Phase 2: Feature Development

```bash
# Start new feature
git checkout develop
git pull origin develop
git checkout -b feature/property-search-api

# Work on feature with regular commits
git add .
git commit -m "feat: add property search with filters"
git push -u origin feature/property-search-api

# Create PR to develop branch
# After review & approval, merge to develop
```

### Phase 3: Release Process

```bash
# Create release branch from develop
git checkout develop
git pull origin develop
git checkout -b release/v1.0.0

# Final testing and bug fixes only
git commit -m "fix: minor validation issue"

# Merge to main AND develop
git checkout main
git merge release/v1.0.0
git tag v1.0.0
git push origin main --tags

git checkout develop
git merge release/v1.0.0
git push origin develop
```

### Phase 4: Hotfix Process

```bash
# Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-security-fix

# Fix the issue
git commit -m "security: fix authentication bypass"

# Merge to both main and develop
git checkout main
git merge hotfix/critical-security-fix
git tag v1.0.1
git push origin main --tags

git checkout develop
git merge hotfix/critical-security-fix
git push origin develop
```

## 3. GitHub Repository Configuration

### Repository Settings

```yaml
Repository Name: sqr-rental-platform
Description: "Nigerian Property Rental Platform - Modern, secure, and user-friendly"
Topics: [nigeria, rental, property, vue, golang, grpc, redis, postgresql]
License: MIT (or proprietary if commercial)
Default Branch: main
```

### Branch Protection Rules

#### Main Branch Protection
```yaml
Branch: main
Settings:
  - ✅ Require pull request reviews (2 reviewers)
  - ✅ Dismiss stale reviews when new commits are pushed
  - ✅ Require review from code owners
  - ✅ Require status checks to pass
  - ✅ Require branches to be up to date before merging
  - ✅ Require conversation resolution before merging
  - ❌ Allow force pushes
  - ❌ Allow deletions
  - ✅ Restrict pushes that create files that have a path matching the pattern
```

#### Develop Branch Protection
```yaml
Branch: develop
Settings:
  - ✅ Require pull request reviews (1 reviewer)
  - ✅ Require status checks to pass
  - ✅ Require branches to be up to date before merging
  - ✅ Allow force pushes (for rebasing)
  - ❌ Allow deletions
```

## 4. Issue Management & Project Organization

### GitHub Issues Labels

#### Type Labels
```yaml
bug: "🐛 Something isn't working" (color: #d73a4a)
enhancement: "✨ New feature or request" (color: #a2eeef)
feature: "🚀 New feature implementation" (color: #0075ca)
documentation: "📝 Improvements or additions to documentation" (color: #0075ca)
security: "🔒 Security-related issue" (color: #8b5cf6)
performance: "⚡ Performance improvement" (color: #f97316)
refactor: "🔧 Code refactoring" (color: #6b7280)
testing: "🧪 Testing related" (color: #22c55e)
```

#### Priority Labels
```yaml
"priority: critical": "🔥 Needs immediate attention" (color: #b91c1c)
"priority: high": "📍 High priority" (color: #dc2626)
"priority: medium": "📋 Medium priority" (color: #eab308)
"priority: low": "📌 Low priority" (color: #22c55e)
```

#### Component Labels
```yaml
backend: "🔧 Backend/API related" (color: #6b7280)
frontend: "💻 Frontend/UI related" (color: #3b82f6)
database: "🗄️ Database related" (color: #92400e)
auth: "🔐 Authentication/Authorization" (color: #8b5cf6)
api: "🌐 API related" (color: #06b6d4)
devops: "⚙️ DevOps/Infrastructure" (color: #374151)
mobile: "📱 Mobile app related" (color: #f59e0b)
```

#### Status Labels
```yaml
"status: needs review": "👀 Needs code review" (color: #fbbf24)
"status: in progress": "🚧 Currently being worked on" (color: #3b82f6)
"status: blocked": "🚫 Blocked by dependency" (color: #ef4444)
"status: ready": "✅ Ready for development" (color: #22c55e)
```

### Project Board Structure

#### SQR Development Board
```
Columns:
├── 📋 Backlog (All planned features and bugs)
├── 🎯 Sprint Planning (Items for current sprint)
├── 🚧 In Progress (Active development)
├── 👀 In Review (PRs under review)
├── 🧪 Testing (QA/Testing phase)
├── 🚀 Ready for Release (Tested and approved)
└── ✅ Done (Completed and released)
```

#### Issue Templates

Create these in `.github/ISSUE_TEMPLATE/`:

**Bug Report Template:**
```yaml
name: Bug Report
about: Create a report to help us improve
title: '[BUG] '
labels: ['bug']
assignees: ''
```

**Feature Request Template:**
```yaml
name: Feature Request
about: Suggest an idea for this project
title: '[FEATURE] '
labels: ['feature', 'enhancement']
assignees: ''
```

## 5. Commit Message Convention

### Conventional Commits Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Commit Types

```
feat: A new feature
fix: A bug fix
docs: Documentation only changes
style: Changes that do not affect the meaning of the code
refactor: A code change that neither fixes a bug nor adds a feature
perf: A code change that improves performance
test: Adding missing tests or correcting existing tests
chore: Changes to the build process or auxiliary tools
ci: Changes to CI configuration files and scripts
security: Security improvements
revert: Reverts a previous commit
```

### Scope Examples

```
auth: Authentication related
api: API endpoints
db: Database changes
ui: User interface
config: Configuration files
docs: Documentation
test: Testing
```

### Commit Message Examples

```bash
feat(auth): implement password reset functionality
fix(cache): resolve session invalidation issue
docs(api): add property search endpoint documentation
test(gapi): add comprehensive tests for logout endpoint
refactor(db): optimize tenant profile queries
security(rate): implement rate limiting for auth endpoints
chore(deps): update Go modules to latest versions
ci(github): add automated testing workflow
style(frontend): format Vue components consistently
perf(db): add indexes for property search queries
```

## 6. Pull Request Guidelines

### Pull Request Template

Create `.github/pull_request_template.md`:

```markdown
## Description
Brief description of what this PR does and why.

## Type of Change
- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📝 Documentation update
- [ ] 🔧 Refactoring
- [ ] ⚡ Performance improvement
- [ ] 🧪 Test addition or improvement

## How Has This Been Tested?
Describe the tests that you ran to verify your changes.

- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing
- [ ] End-to-end tests

## Testing Details
- **Test Configuration**: 
- **Test Coverage**: 

## Checklist
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published in downstream modules

## Database Changes
- [ ] No database changes
- [ ] Database migration included
- [ ] Migration tested on development environment
- [ ] Migration rollback tested

## Security Considerations
- [ ] No security implications
- [ ] Security review completed
- [ ] Authentication/authorization changes reviewed
- [ ] Input validation implemented
- [ ] SQL injection prevention verified

## Screenshots (if applicable)
Add screenshots to help explain your changes.

## Breaking Changes
List any breaking changes and migration steps required.

## Related Issues
- Closes #[issue-number]
- Fixes #[issue-number]
- Related to #[issue-number]

## Additional Notes
Any additional information that reviewers should know.
```

### Pull Request Review Guidelines

#### For Authors
1. **Self-review first** - Review your own PR before requesting review
2. **Keep PRs small** - Aim for <500 lines of code changes
3. **Write clear descriptions** - Explain what, why, and how
4. **Add tests** - Include unit/integration tests for new features
5. **Update documentation** - Keep docs in sync with code changes
6. **Respond promptly** - Address review feedback within 24 hours

#### For Reviewers
1. **Review within 24 hours** - Don't block other developers
2. **Be constructive** - Suggest improvements, don't just criticize
3. **Test locally** - Pull and test complex changes
4. **Check for security** - Look for potential security issues
5. **Verify tests** - Ensure adequate test coverage
6. **Approve or request changes** - Don't leave PRs hanging

## 7. Release Management

### Semantic Versioning

```
MAJOR.MINOR.PATCH

v1.0.0 - Initial production release
v1.1.0 - Minor feature additions
v1.1.1 - Patch/bug fixes
v2.0.0 - Major breaking changes
```

### Version Increment Guidelines

#### MAJOR (v2.0.0)
- Breaking API changes
- Major architectural changes
- Incompatible changes

#### MINOR (v1.1.0)
- New features (backward compatible)
- New API endpoints
- Feature enhancements

#### PATCH (v1.0.1)
- Bug fixes
- Security patches
- Performance improvements

### Release Process

#### 1. Pre-release Checklist
```bash
# Ensure all features are merged to develop
git checkout develop
git pull origin develop

# Run all tests
make test

# Update version numbers
# Update CHANGELOG.md
# Update README.md if needed
```

#### 2. Create Release Branch
```bash
git checkout -b release/v1.2.0
```

#### 3. Final Testing & Bug Fixes
```bash
# Only bug fixes allowed on release branch
git commit -m "fix: minor validation issue"
```

#### 4. Merge to Main
```bash
git checkout main
git merge release/v1.2.0
git tag -a v1.2.0 -m "Release version 1.2.0: Property Search & Filters"
git push origin main --tags
```

#### 5. Merge Back to Develop
```bash
git checkout develop
git merge release/v1.2.0
git push origin develop
```

#### 6. Create GitHub Release
Go to GitHub Releases and create a new release with:

```markdown
## Release v1.2.0 - Property Search & Filters

### 🚀 New Features
- Advanced property search with multiple filters
- Map-based property discovery
- Saved property favorites
- Property recommendation engine

### 🐛 Bug Fixes
- Fixed session timeout issues (#45)
- Resolved cache invalidation problems (#52)

### 🔧 Technical Improvements
- Improved database query performance
- Enhanced error handling
- Updated rate limiting rules

### 📚 Documentation
- Added API documentation for search endpoints
- Updated deployment guide

### ⚠️ Breaking Changes
None

### 🔄 Migration Notes
No migration required for this release.

**Full Changelog**: https://github.com/username/sqr-rental-platform/compare/v1.1.0...v1.2.0
```

## 8. CI/CD Integration

### GitHub Actions Workflow

Create `.github/workflows/ci.yml`:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  GO_VERSION: '1.21'
  NODE_VERSION: '18'

jobs:
  test-backend:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: secret
          POSTGRES_DB: sqr_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
      
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: ${{ env.GO_VERSION }}

      - name: Cache Go modules
        uses: actions/cache@v3
        with:
          path: ~/go/pkg/mod
          key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
          restore-keys: |
            ${{ runner.os }}-go-

      - name: Install dependencies
        run: go mod download

      - name: Run linter
        uses: golangci/golangci-lint-action@v3
        with:
          version: latest

      - name: Run tests
        run: |
          make test
        env:
          DATABASE_URL: postgres://postgres:secret@localhost:5432/sqr_test?sslmode=disable
          REDIS_URL: redis://localhost:6379

      - name: Build application
        run: make build

      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.out

  test-frontend:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json

      - name: Install dependencies
        working-directory: ./frontend
        run: npm ci

      - name: Run linter
        working-directory: ./frontend
        run: npm run lint

      - name: Run tests
        working-directory: ./frontend
        run: npm run test:unit

      - name: Build frontend
        working-directory: ./frontend
        run: npm run build

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'

  deploy-staging:
    if: github.ref == 'refs/heads/develop'
    needs: [test-backend, test-frontend, security-scan]
    runs-on: ubuntu-latest
    
    steps:
      - name: Deploy to staging
        run: |
          echo "Deploying to staging environment"
          # Add your deployment script here

  deploy-production:
    if: github.ref == 'refs/heads/main'
    needs: [test-backend, test-frontend, security-scan]
    runs-on: ubuntu-latest
    
    steps:
      - name: Deploy to production
        run: |
          echo "Deploying to production environment"
          # Add your production deployment script here
```

### Additional Workflows

Create `.github/workflows/release.yml`:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Generate changelog
        id: changelog
        run: |
          # Generate changelog from commits
          echo "changelog<<EOF" >> $GITHUB_OUTPUT
          git log --pretty=format:"- %s" $(git describe --tags --abbrev=0 HEAD^)..HEAD >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          body: |
            ## Changes
            ${{ steps.changelog.outputs.changelog }}
          draft: false
          prerelease: false
```

## 9. Daily Development Workflow

### Morning Routine

```bash
# Sync with latest changes
git checkout develop
git pull origin develop

# Start new feature or continue existing
git checkout feature/your-feature-branch
git rebase develop  # Keep feature branch up to date

# Check for any conflicts and resolve
```

### During Development

```bash
# Regular commits with conventional commit messages
git add .
git commit -m "feat(auth): add password strength validation"

# Push regularly to backup work
git push origin feature/your-feature-branch
```

### End of Day

```bash
# Final commit and push
git add .
git commit -m "wip: partial implementation of property filters"
git push origin feature/your-feature-branch

# Create PR if feature is complete
# Or update existing PR with new commits
```

### Before Creating PR

```bash
# Rebase on latest develop
git checkout develop
git pull origin develop
git checkout feature/your-feature-branch
git rebase develop

# Squash commits if needed (optional)
git rebase -i HEAD~n

# Final push
git push origin feature/your-feature-branch --force-with-lease
```

## 10. Team Collaboration Guidelines

### Code Review Standards

#### What to Look For
1. **Functionality** - Does the code do what it's supposed to do?
2. **Security** - Are there any security vulnerabilities?
3. **Performance** - Are there any performance issues?
4. **Maintainability** - Is the code easy to understand and modify?
5. **Testing** - Is there adequate test coverage?
6. **Documentation** - Is the code properly documented?

#### Review Response Times
- **Critical/Security fixes**: 2 hours
- **Regular features**: 24 hours
- **Documentation**: 48 hours

### Communication Channels

1. **GitHub Issues** - Feature requests, bugs, discussions
2. **GitHub Discussions** - Architectural decisions, RFC
3. **PR Comments** - Code-specific feedback
4. **Project Board** - Progress tracking
5. **Slack/Discord** - Quick questions, coordination

### Conflict Resolution

#### Merge Conflicts
```bash
# When conflicts occur during PR
git checkout feature/your-branch
git fetch origin
git rebase origin/develop

# Resolve conflicts in your editor
# After resolving each file:
git add resolved-file.go
git rebase --continue

# Force push the rebased branch
git push origin feature/your-branch --force-with-lease
```

#### Code Review Disagreements
1. Discuss in PR comments first
2. Schedule a quick call if needed
3. Involve team lead for final decision
4. Document decision for future reference

## 11. Quality Gates

### Pre-commit Hooks

Install pre-commit hooks to ensure code quality:

```bash
# Install pre-commit
pip install pre-commit

# Set up hooks
pre-commit install
```

Create `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/golangci/golangci-lint
    rev: v1.54.0
    hooks:
      - id: golangci-lint

  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: v8.44.0
    hooks:
      - id: eslint
        files: \.(js|ts|vue)$
        additional_dependencies:
          - eslint@8.44.0
```

### Definition of Done

A feature is considered "Done" when:

- [ ] Code is written and reviewed
- [ ] Unit tests written and passing
- [ ] Integration tests passing
- [ ] Documentation updated
- [ ] Security review completed (for sensitive features)
- [ ] Performance impact assessed
- [ ] Accessibility requirements met (frontend)
- [ ] Cross-browser testing completed (frontend)
- [ ] Database migrations tested
- [ ] Feature flag implemented (if applicable)
- [ ] Monitoring/logging added
- [ ] Deployed to staging and tested
- [ ] Product owner approval received

## 12. Monitoring & Maintenance

### Repository Health Metrics

Monitor these metrics regularly:

1. **PR Merge Time** - Average time from PR creation to merge
2. **Review Response Time** - Time to first review
3. **Build Success Rate** - Percentage of successful CI builds
4. **Test Coverage** - Code coverage percentage
5. **Security Vulnerabilities** - Number of open security issues
6. **Technical Debt** - Code quality metrics

### Regular Maintenance Tasks

#### Weekly
- Review open PRs and issues
- Clean up merged feature branches
- Update dependencies
- Review CI/CD performance

#### Monthly
- Archive completed projects
- Update documentation
- Review and update labels
- Security audit
- Performance review

#### Quarterly
- Review branching strategy effectiveness
- Update development guidelines
- Team retrospective on Git workflow
- Tool evaluation and updates

## 13. Troubleshooting Common Issues

### Large File Issues

```bash
# If you accidentally committed large files
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/large/file" \
  --prune-empty --tag-name-filter cat -- --all

# Or use BFG Repo-Cleaner for better performance
java -jar bfg.jar --delete-files large-file.zip
git reflog expire --expire=now --all && git gc --prune=now --aggressive
```

### Rewriting Git History

```bash
# To squash last 3 commits
git rebase -i HEAD~3

# To change commit message
git commit --amend

# To split a commit
git rebase -i HEAD~1
# Mark commit as 'edit'
git reset HEAD^
# Make separate commits
git add file1
git commit -m "first part"
git add file2
git commit -m "second part"
git rebase --continue
```

### Recovering Lost Work

```bash
# Find lost commits
git reflog

# Recover lost commit
git checkout -b recovery-branch <commit-hash>

# Recover deleted branch
git checkout -b recovered-branch <last-commit-hash>
```

---

## Quick Reference Commands

### Daily Commands
```bash
# Sync with develop
git checkout develop && git pull origin develop

# Create feature branch
git checkout -b feature/new-feature

# Commit changes
git add . && git commit -m "feat: add new feature"

# Push branch
git push -u origin feature/new-feature

# Rebase on develop
git rebase develop

# Force push after rebase
git push --force-with-lease origin feature/new-feature
```

### Release Commands
```bash
# Create release branch
git checkout develop && git checkout -b release/v1.2.0

# Tag release
git tag -a v1.2.0 -m "Release v1.2.0"

# Push tag
git push origin v1.2.0
```

### Cleanup Commands
```bash
# Delete merged branches
git branch --merged | grep -v "\*\|main\|develop" | xargs -n 1 git branch -d

# Prune remote branches
git remote prune origin

# Clean untracked files
git clean -fd
```

---

This guide provides a comprehensive framework for managing the SQR rental platform project using Git and GitHub. Adjust the specific settings and processes based on your team size and requirements.
