## Description

Provide a clear and concise description of the changes in this pull request. Explain the motivation and context.

Closes #(issue number)

## Type of Change

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Documentation update

## Checklist

Before submitting this pull request, confirm the following:

- [ ] I have run `terraform fmt -recursive` and all files are properly formatted.
- [ ] I have run `terraform validate` and the configuration is valid.
- [ ] I have run `tfsec` and there are no security issues.
- [ ] All existing tests pass and new tests have been added where appropriate.
- [ ] I have updated the documentation (READMEs, variable descriptions, output descriptions).
- [ ] No secrets, credentials, or sensitive values are committed in this PR.
- [ ] I have followed the branch naming conventions (`feat/`, `fix/`, `docs/`).
- [ ] I have followed the commit message conventions (Conventional Commits).
- [ ] Pre-commit hooks pass without errors.

## Testing

Describe the testing you have performed:

- [ ] `terraform plan` completes successfully.
- [ ] `terraform apply` completes successfully (if applicable).
- [ ] Module outputs are correct and as expected.
- [ ] Existing functionality is not broken.

## Screenshots / Output

If applicable, add screenshots or command output to demonstrate the changes.

## Additional Notes

Add any other information that reviewers should be aware of.
