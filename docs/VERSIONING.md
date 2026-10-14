# Versioning Policy

Gaussian-LIC2 follows [Semantic Versioning 2.0.0](https://semver.org/) with project-specific extensions for research software.

---

## Version Format

```
MAJOR.MINOR.PATCH
```

The current version is stored in the [`VERSION`](../VERSION) file at the repository root as a single line, e.g.:

```
1.0.0
```

### When to Bump

| Component | When to increment | Examples |
|---|---|---|
| **MAJOR** | Breaking changes to the public API, data format, or build system that require user action to upgrade | Renaming or removing a config key; changing the ROS topic interface; changing the PLY output format; dropping support for a platform |
| **MINOR** | New features, new modules, or significant enhancements that are backward-compatible | Adding a new sensor source; adding a new dataset config; adding a new optimization feature; porting to a new platform |
| **PATCH** | Bug fixes, documentation updates, minor refactors that don't change behavior | Fixing a crash; fixing a memory leak; updating docs; fixing a config typo |

### Pre-release Suffixes

For development versions, append a pre-release identifier:

```
1.1.0-alpha.1    # Early development
1.1.0-beta.1     # Feature-complete, testing
1.1.0-rc.1       # Release candidate
```

---

## Research Software Extensions

Research projects often add features that don't fit cleanly into SemVer. The following are treated as **MINOR** bumps even though they don't change the runtime API:

- New paper drafts or survey sections under `latex/`
- New reference paper PDFs under `pdf/` or `latex/papers/`
- New analysis notes
- New documentation pages under `docs/`

These are intellectual deliverables of the project and warrant version tracking.

---

## Release Workflow

### 1. Prepare the Release

```bash
# Ensure you're on the main branch and up to date
git checkout master
git pull

# Update the VERSION file
echo "1.1.0" > VERSION

# Add a CHANGELOG.md entry (see format below)
# Edit docs/CHANGELOG.md
```

### 2. Commit and Tag

```bash
git add VERSION docs/CHANGELOG.md
git commit -m "release: v1.1.0"
git tag -a v1.1.0 -m "v1.1.0 — <short description>"
```

### 3. Push

```bash
git push origin master
git push origin v1.1.0
```

---

## Changelog Format

`docs/CHANGELOG.md` follows the [Keep a Changelog](https://keepachangelog.com/) format. Each version has a heading with the version number and date, organized into sections:

```markdown
## [1.1.0] — 2026-10-20

### Added
- New feature description

### Changed
- Changed behavior description

### Fixed
- Bug fix description

### Removed
- Removed feature description

### Documentation
- Documentation-only changes
```

### Section Guidelines

| Section | Use for |
|---|---|
| **Added** | New features, new files, new capabilities |
| **Changed** | Changes to existing functionality (backward-compatible) |
| **Deprecated** | Features that will be removed in a future version |
| **Removed** | Features removed in this version |
| **Fixed** | Bug fixes |
| **Security** | Security-related fixes |
| **Documentation** | Documentation-only changes (new docs, updated docs) |

---

## Version History

| Version | Date | Summary |
|---|---|---|
| 1.0.0 | 2026-10-13 | Initial documentation release — comprehensive docs, versioning, and changelog infrastructure |

See [`CHANGELOG.md`](CHANGELOG.md) for the full history.
