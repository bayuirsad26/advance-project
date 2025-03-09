# Contributing to SummitEthic Ansible Project

Thank you for your interest in contributing to the SummitEthic Ansible project! This guide will help you understand our contribution process and how to effectively collaborate with the team.

## Code of Conduct

All contributors are expected to adhere to our Code of Conduct, which promotes a respectful and inclusive environment. Please review it before contributing.

## Getting Started

1. **Fork the Repository**: Create your own copy of the repository by forking it.
2. **Clone Your Fork**: Clone your fork to your local machine.
3. **Set Up Environment**: Follow the setup instructions in the README.md.
4. **Create a Branch**: Always work in a feature branch, not directly on main or develop.

## Development Process

### Branch Naming

Use a consistent branch naming convention:

- `feature/description` - For new features
- `fix/description` - For bug fixes
- `docs/description` - For documentation changes
- `refactor/description` - For code refactoring

### Pre-Commit Hooks

We use pre-commit hooks to maintain code quality. Install them with:

```bash
pip install pre-commit
pre-commit install
```

### Directory Structure Requirements

Each role must maintain a consistent structure:

```
roles/
└── role_name/
    ├── defaults/
    │   └── main.yml
    ├── tasks/
    │   ├── main.yml
    │   ├── security.yml      # Required for common role
    │   ├── monitoring.yml    # Required for roles that support monitoring
    │   └── ...
    ├── templates/
    ├── handlers/
    └── meta/
```

Task files referenced in main.yml must exist, even if they're minimal placeholders. This is important for both functionality and passing linting checks.

### Testing

- All roles should have Molecule tests
- Run tests before submitting a PR: `molecule test`
- Ensure linting passes: `ansible-lint` and `yamllint`

### Linting Standards

We enforce strict linting standards to maintain code quality:

- **Line Length**: Keep lines under 120 characters
- **YAML Formatting**: Follow standard YAML practices with proper indentation
- **Comment Spacing**: Ensure comments have proper spacing after the # symbol
- **File Organization**: Each role should have its expected task files (like monitoring.yml, security.yml)

Before submitting PRs, run:

```bash
ansible-lint
```

If you encounter linting errors:

- For missing files, create the expected task files in role directories
- For line length issues, use YAML's multi-line syntax (>- or |-)
- For module errors, use fully qualified collection names (FQCN)
- For Python dependencies, make sure they're listed in requirements.txt

### Commit Messages

Follow the conventional commits format:

- `feat: add new monitoring dashboard`
- `fix: correct typo in inventory file`
- `docs: update installation instructions`
- `refactor: simplify security role tasks`

## Pull Request Process

1. **Update Documentation**: Ensure documentation is updated to reflect your changes.
2. **Run Tests**: Verify all tests pass before submission.
3. **Create PR**: Submit a pull request to the develop branch.
4. **Review Process**: Address any feedback from code reviews promptly.
5. **Merge**: Once approved, a maintainer will merge your PR.

## Style Guide

### Ansible Practices

- Use YAML files with `.yml` extension
- Use 2-space indentation
- Keep task names descriptive and clear
- Use modules over shell/command when possible
- Include proper tags for all tasks
- Use handlers for service restarts
- Use fully qualified collection names (FQCN) for modules
- Ensure that file permissions are explicitly set for all file operations
- Avoid bare variables in conditionals (always use quotes or comparison operators)

### Documentation

- Keep README.md and other documentation up to date
- Document role variables and their default values
- Use Markdown for all documentation files
- Include examples where appropriate

## Questions?

If you have any questions or need help, feel free to:

- Open an issue with the "question" label
- Reach out to the team at [contact@summitethic.com](mailto:contact@summitethic.com)

Thank you for contributing to SummitEthic's infrastructure!
