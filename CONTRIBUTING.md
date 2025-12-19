# Contributing Guide

## Welcome!

Thank you for considering contributing to the Bare-Metal Kubernetes Platform Foundation!

## How to Contribute

### Reporting Bugs

1. Check if the issue already exists
2. Use the bug report template
3. Include:
   - Hardware specifications
   - Terraform version
   - Error messages and logs
   - Steps to reproduce

### Suggesting Features

1. Check if the feature is already planned (see [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md))
2. Use the feature request template
3. Include:
   - Use case description
   - Expected behavior
   - Implementation ideas (optional)

### Contributing Code

#### Setup Development Environment

```bash
# Fork the repository
git clone https://github.com/your-username/platform-foundation.git
cd platform-foundation

# Create a feature branch
git checkout -b feature/my-feature

# Make your changes
# ...

# Test your changes
cd terraform/inventories/production
terraform init
terraform validate
terraform plan

# Commit and push
git add .
git commit -m "Add: description of changes"
git push origin feature/my-feature
```

#### Coding Standards

Follow the Terraform conventions in [.github/instructions/terraform.instructions.md](.github/instructions/terraform.instructions.md):

1. **Style**:
   - Use `terraform fmt` before committing
   - 2-space indentation
   - Alphabetize resources within files

2. **Documentation**:
   - Add descriptions to all variables
   - Include README.md for new modules
   - Update relevant documentation

3. **Security**:
   - Mark sensitive variables as `sensitive = true`
   - Never commit credentials
   - Use data sources instead of hardcoded values

4. **Testing**:
   - Run `terraform validate`
   - Test with `terraform plan`
   - Include test scenarios

#### Pull Request Process

1. Update documentation
2. Add yourself to CONTRIBUTORS.md
3. Ensure CI passes (when available)
4. Request review from maintainers
5. Address feedback
6. Squash commits if requested

### Module Development Guidelines

When creating new modules:

1. **Structure**:
   ```
   modules/my-module/
   ├── README.md        # Module documentation
   ├── main.tf          # Main resources
   ├── variables.tf     # Input variables
   ├── outputs.tf       # Output values
   ├── versions.tf      # Provider versions (if needed)
   └── examples/        # Usage examples
   ```

2. **Variables**:
   ```hcl
   variable "cluster_name" {
     description = "Name of the cluster"
     type        = string
   }
   ```

3. **Outputs**:
   ```hcl
   output "resource_id" {
     description = "Resource identifier"
     value       = resource.example.id
   }
   ```

4. **Documentation**:
   - Clear README with usage examples
   - Document all variables and outputs
   - Include prerequisites

### Documentation Contributions

Documentation improvements are always welcome!

1. Fix typos and grammar
2. Add examples
3. Improve clarity
4. Add diagrams
5. Translate to other languages

### Testing

#### Manual Testing

```bash
# Validate syntax
terraform fmt -check
terraform validate

# Plan without applying
terraform plan

# Test discovery module
terraform apply -target=module.discovery
```

#### Integration Testing (Future)

```bash
# Run test suite
make test

# Run specific test
make test TEST=discovery
```

## Code Review Process

1. **Automated Checks**:
   - Terraform format
   - Terraform validate
   - tflint
   - Security scanning

2. **Manual Review**:
   - Code quality
   - Documentation
   - Test coverage
   - Security considerations

3. **Approval**:
   - At least one maintainer approval
   - All discussions resolved
   - CI passing

## Development Workflow

### Branching Strategy

- `main` - Stable releases
- `develop` - Development branch
- `feature/*` - Feature branches
- `fix/*` - Bug fix branches
- `docs/*` - Documentation updates

### Commit Messages

Follow conventional commits:

```
type(scope): subject

body (optional)

footer (optional)
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Tests
- `chore`: Maintenance

Examples:
```
feat(discovery): add redfish API support
fix(pxe): correct DHCP configuration template
docs(readme): update installation steps
```

## Community

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Wiki**: Detailed guides and tutorials

### Code of Conduct

Be respectful, inclusive, and professional:

1. Use welcoming language
2. Respect differing viewpoints
3. Accept constructive criticism
4. Focus on what's best for the community
5. Show empathy towards others

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Thanked in project announcements

## Getting Help

- Read the documentation in [docs/](docs/)
- Check existing issues
- Ask in GitHub Discussions
- Review [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

## Priority Areas

Current priorities (see [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)):

1. **High Priority**:
   - Kubernetes installation automation
   - Storage module implementation
   - Monitoring stack integration

2. **Medium Priority**:
   - GPU support
   - Advanced networking features
   - Firmware management

3. **Nice to Have**:
   - Web UI
   - CI/CD integration
   - Multi-cluster management

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for helping make bare-metal Kubernetes accessible to everyone!
