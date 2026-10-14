# Module Reference: `third_party/` — Third-Party Submodules

The `third_party/` directory contains Git submodules for external dependencies that are integrated directly into the project rather than installed system-wide.

---

## Submodules

### MetalSplatter

| Field | Value |
|---|---|
| **Path** | `third_party/MetalSplatter` |
| **URL** | https://github.com/scier/MetalSplatter.git |
| **Purpose** | Metal-based 3D Gaussian Splatting viewer for macOS/iOS |

MetalSplatter is an Apple-platform (macOS, iOS, visionOS) viewer for 3D Gaussian Splatting scenes, built on Apple's Metal framework. It provides a native, high-performance rendering path for viewing `.ply` Gaussian maps exported by Gaussian-LIC2 on Apple devices.

**Configuration** (`.gitmodules`):
```ini
[submodule "third_party/MetalSplatter"]
    path = third_party/MetalSplatter
    url = https://github.com/scier/MetalSplatter.git
```

---

## Managing Submodules

### Initial Clone with Submodules

```bash
git clone --recursive <repo-url>
```

### Updating Submodules After Pull

```bash
git submodule update --init --recursive
```

### Adding a New Submodule

```bash
git submodule add <url> third_party/<name>
git commit -m "build: add <name> submodule (third_party/<name>)"
```

When adding a new submodule, update this document and [`README.md`](../README.md) to register it.
