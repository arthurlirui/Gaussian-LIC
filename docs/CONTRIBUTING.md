# Contributing Guide

Thank you for contributing to Gaussian-LIC2! This guide describes how to contribute code, documentation, and research artifacts to the project.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Code Contribution Workflow](#code-contribution-workflow)
- [Documentation Update Protocol](#documentation-update-protocol)
- [Version Bumping](#version-bumping)
- [Changelog Updates](#changelog-updates)
- [Commit Message Conventions](#commit-message-conventions)
- [Pull Request Checklist](#pull-request-checklist)

---

## Getting Started

1. **Fork and clone** the repository:
   ```bash
   git clone --recursive https://github.com/APRIL-ZJU/Gaussian-LIC.git
   ```

2. **Read the documentation:**
   - [Architecture Overview](architecture.md) — understand the system design
   - [Module Reference](modules/) — find the module you want to work on
   - [Versioning Policy](VERSIONING.md) — understand how versions work

3. **Set up your build environment** by following the [root README](../README.md) (for the ROS node) or [`win_lic/README`](../win_lic/README.md) (for the offline framework).

---

## Code Contribution Workflow

1. **Create a branch** from `master`:
   ```bash
   git checkout -b feat/your-feature-name
   ```

2. **Make your changes**, following the code style of the surrounding code.

3. **Update documentation** (see [Documentation Update Protocol](#documentation-update-protocol)).

4. **Test your changes:**
   - For `src/`: `cd ~/catkin_gaussian && catkin_make`
   - For `win_lic/`: `cd win_lic && mkdir build && cd build && cmake .. && make`
   - Run on a sample dataset to verify behavior

5. **Commit** with a conventional commit message (see below).

6. **Open a pull request** with a clear description of what changed and why.

---

## Documentation Update Protocol

**Every code change must be accompanied by a corresponding documentation update.** This is a hard requirement — pull requests without doc updates will be requested to add them.

### What triggers a doc update?

| Change type | Doc to update | Action |
|---|---|---|
| New file added to a module | `docs/modules/<module>.md` | Add the file to the file inventory table with a description |
| File removed or renamed | `docs/modules/<module>.md` | Remove or update the entry |
| Public API change (class, function signature) | `docs/modules/<module>.md` | Update the "Key Classes and Functions" section |
| New module/directory | `docs/README.md` + `docs/modules/<new>.md` | Create a new module doc and add it to the index |
| Config schema change | `docs/modules/config.md` | Update the schema documentation |
| Build system change | `docs/architecture.md` | Update the build system section |
| Architecture change | `docs/architecture.md` | Update the relevant architecture section |
| New paper or design doc | `docs/modules/latex.md` | Add to the directory structure listing |

### How to update

1. Open the relevant `docs/modules/*.md` file
2. Find the section that corresponds to your change
3. Update the description to match the new state of the code
4. If you added a new file, add a row to the file inventory table

### Example

If you add a new sensor source `realsense_source.cpp` to `win_lic/sensors/`:

1. Open `docs/modules/win_lic.md`
2. Find the `sensors/` section in the file inventory table
3. Add: `| realsense_source.h / .cpp | RealSenseSource — live Intel RealSense camera (compile-gated by USE_REALSENSE) |`
4. Update any relevant architecture description in `docs/architecture.md`

---

## Version Bumping

### When to bump

- **During development**: Do not bump the version for individual commits. The version is bumped at release time.
- **At release**: Follow the [release workflow in VERSIONING.md](VERSIONING.md#release-workflow).

### How to bump

```bash
# Update VERSION file
echo "1.1.0" > VERSION

# Add changelog entry (see below)
# Edit docs/CHANGELOG.md

# Commit and tag
git add VERSION docs/CHANGELOG.md
git commit -m "release: v1.1.0"
git tag -a v1.1.0 -m "v1.1.0"
```

---

## Changelog Updates

Every release must add an entry to [`docs/CHANGELOG.md`](CHANGELOG.md). During development, you may add entries to the `[Unreleased]` section.

### Format

```markdown
## [1.1.0] — YYYY-MM-DD

### Added
- Description of new feature

### Changed
- Description of changed behavior

### Fixed
- Description of bug fix

### Documentation
- Description of doc changes
```

See [VERSIONING.md](VERSIONING.md#changelog-format) for the full section guidelines.

---

## Commit Message Conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>
```

### Types

| Type | Use for |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code restructuring without behavior change |
| `build` | Build system changes |
| `ci` | CI configuration |
| `chore` | Maintenance tasks |
| `release` | Version release |

### Scopes

Common scopes: `core`, `winlic`, `ckpt`, `config`, `jetson`, `docs`, `latex`, `pdf`

### Examples

```
feat(winlic): add RealSense sensor source
fix(jetson): correct TensorRT library path on JetPack 5.1.3
docs(architecture): update data flow diagram for multi-modal fusion
build: update CMake CUDA arch detection for sm_89
release: v1.1.0
```

---

## Pull Request Checklist

Before opening a pull request, verify:

- [ ] Code compiles without warnings on the target platform
- [ ] Code has been tested on a sample dataset
- [ ] **Documentation has been updated** for all changed modules
- [ ] Commit messages follow the conventional commits format
- [ ] No secrets, API keys, or large binary files are committed
- [ ] The CHANGELOG.md `[Unreleased]` section has been updated (if applicable)
- [ ] New files are registered in the relevant `docs/modules/*.md` file
- [ ] New config keys are documented in `docs/modules/config.md`

---

## Questions?

- **Technical questions**: Open a GitHub issue
- **Collaboration inquiries**: Contact Xiaolei Lang (Jerry) at jerry_locker@zju.edu.cn
