# Contributing to Terraform Multi-Cloud Hybrid

Thank you for your interest in contributing to this project. This guide outlines the process and expectations for contributing.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Branch Naming Conventions](#branch-naming-conventions)
- [Commit Conventions](#commit-conventions)
- [Pre-Commit Hooks](#pre-commit-hooks)
- [Pull Request Process](#pull-request-process)
- [Code Review Expectations](#code-review-expectations)

## Getting Started

1. **Fork the repository** to your own GitHub account.
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/<your-username>/terraform-multi-cloud-hybrid.git
   cd terraform-multi-cloud-hybrid
   ```
3. **Add the upstream remote**:
   ```bash
   git remote add upstream https://github.com/GiulioSavini/terraform-multi-cloud-hybrid.git
   ```
4. **Keep your fork in sync**:
   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```

## Development Setup

Ensure you have the following tools installed:

- Terraform >= 1.5.0
- TFLint
- tfsec
- pre-commit
- Go (for running tests)

Install pre-commit hooks after cloning:

```bash
pre-commit install
```

## Branch Naming Conventions

All branches must follow these naming conventions:

| Prefix   | Purpose                          | Example                          |
|----------|----------------------------------|----------------------------------|
| `feat/`  | New features or enhancements     | `feat/add-gcp-cloud-sql-module`  |
| `fix/`   | Bug fixes                        | `fix/aws-vpc-cidr-validation`    |
| `docs/`  | Documentation changes only       | `docs/update-azure-readme`       |

Additional accepted prefixes:

- `refactor/` - Code refactoring without functional changes
- `test/` - Adding or updating tests
- `chore/` - Maintenance tasks (CI, dependencies, tooling)

Branch names should be lowercase, use hyphens as separators, and be descriptive.

## Commit Conventions

This project follows the [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat` - A new feature
- `fix` - A bug fix
- `docs` - Documentation changes
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks
- `ci` - CI/CD changes

### Scope

Use the module path as scope when applicable:

```
feat(aws/network): add support for transit gateway
fix(azure/compute): correct VM size validation
docs(gcp/security): update IAM examples
```

### Rules

- Use the imperative mood in the description ("add feature" not "added feature").
- Do not end the description with a period.
- Keep the first line under 72 characters.
- Reference issue numbers in the footer: `Closes #123`.

## Pre-Commit Hooks

Pre-commit hooks are **required** for all contributors. The following hooks run automatically on each commit:

- `terraform fmt` - Formats all Terraform files.
- `terraform validate` - Validates Terraform configuration.
- `tflint` - Lints Terraform code against best practices.
- `tfsec` - Scans for security issues.
- `detect-secrets` - Prevents committing secrets or credentials.
- Trailing whitespace and end-of-file fixes.

Install hooks:

```bash
pre-commit install
```

Run hooks manually against all files:

```bash
pre-commit run --all-files
```

Do not bypass hooks with `--no-verify`. If a hook fails, fix the issue before committing.

## Pull Request Process

1. **Create a branch** from `main` following the naming conventions above.
2. **Make your changes** in focused, atomic commits.
3. **Run all checks locally** before pushing:
   ```bash
   terraform fmt -recursive
   terraform validate
   tflint
   tfsec .
   pre-commit run --all-files
   ```
4. **Push your branch** to your fork:
   ```bash
   git push origin feat/your-feature-name
   ```
5. **Open a Pull Request** against the `main` branch of the upstream repository.
6. **Fill out the PR template** completely, including:
   - A clear description of the changes.
   - The type of change (bug fix, feature, breaking change, etc.).
   - Confirmation that all checklist items are satisfied.
7. **Link related issues** in the PR description.
8. **Wait for CI checks** to pass before requesting review.
9. **Address review feedback** promptly. Push new commits rather than force-pushing.

## Code Review Expectations

### For Authors

- Keep PRs focused and reasonably sized. Large PRs are harder to review and more likely to introduce issues.
- Provide context in the PR description explaining *why* the change is being made, not just *what* changed.
- Respond to review comments within 48 hours.
- Be open to feedback and alternative approaches.

### For Reviewers

- Review PRs within 48 hours of being requested.
- Be constructive and specific in feedback. Explain *why* a change is suggested.
- Distinguish between blocking concerns and non-blocking suggestions.
- Approve the PR once all blocking concerns are addressed.

### Review Criteria

All PRs will be evaluated against the following:

- **Correctness** - Does the code work as intended?
- **Security** - Are there any security concerns? Are secrets properly handled?
- **Style** - Does the code follow project conventions (naming, formatting, structure)?
- **Documentation** - Are variables, outputs, and modules documented?
- **Testing** - Are changes covered by tests where applicable?
- **Backwards Compatibility** - Does the change break existing configurations?

## Questions?

If you have questions about contributing, open a discussion or reach out to the maintainers.

Thank you for contributing.
