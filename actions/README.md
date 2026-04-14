# HelmKit Actions

GitHub Actions to run Helm and Helmfile commands using HelmKit.

## Available Actions

| Action | Description |
|--------|-------------|
| [HelmKit Helm](#helmkit-helm-action) | Run Helm commands |
| [HelmKit Helmfile](#helmkit-helmfile-action) | Run Helmfile commands |

## Shared Dockerfile

Both actions use a shared Dockerfile at `actions/Dockerfile` based on `ghcr.io/docked-titan-foundation/helmkit:latest`.

---

## HelmKit Helm Action

Runs Helm commands using HelmKit. The action prepends `helm` to any arguments you provide.

### Usage

```yaml
name: Helm Version Check

on: [push, pull_request]

jobs:
  helm-version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Helm Version
        uses: ./actions/helm
        with:
          args: "version --short"
```

### Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `args` | No | `""` | Arguments passed to helm command (subcommand + flags) |

### Outputs

| Output | Description |
|--------|-------------|
| `exit-code` | Exit code from helm command |
| `output` | Output from helm command |

### Examples

#### Check Helm Version

```yaml
- name: Helm Version
  uses: ./actions/helm
  with:
    args: "version --short"
```

#### Lint Helm Charts

```yaml
- name: Helm Lint
  uses: ./actions/helm
  with:
    args: "lint ./charts/myapp"
```

#### Template Validation

```yaml
- name: Helm Template
  uses: ./actions/helm
  with:
    args: "template my-release ./charts/myapp"
```

#### Dry-Run Install

```yaml
- name: Helm Dry-Run
  uses: ./actions/helm
  with:
    args: "install my-release ./charts/myapp --dry-run --debug"
```

---

## HelmKit Helmfile Action

Runs Helmfile commands using HelmKit. The action prepends `helmfile` to any arguments you provide.

### Usage

```yaml
name: Helmfile Version Check

on: [push, pull_request]

jobs:
  helmfile-version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Helmfile Version
        uses: ./actions/helmfile
        with:
          args: "version"
```

### Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `args` | No | `""` | Arguments passed to helmfile command (subcommand + flags) |

### Outputs

| Output | Description |
|--------|-------------|
| `exit-code` | Exit code from helmfile command |
| `output` | Output from helmfile command |

### Examples

#### Check Helmfile Version

```yaml
- name: Helmfile Version
  uses: ./actions/helmfile
  with:
    args: "version"
```

#### Lint Helmfiles

```yaml
- name: Helmfile Lint
  uses: ./actions/helmfile
  with:
    args: "lint -f ./helmfile.yaml"
```

#### Template Dry-Run

```yaml
- name: Helmfile Template
  uses: ./actions/helmfile
  with:
    args: "template -f ./helmfile.yaml"
```

#### Diff Check

```yaml
- name: Helmfile Diff
  uses: ./actions/helmfile
  with:
    args: "diff -f ./helmfile.yaml"
```

---

## Local Testing

### Build the Action Image

```bash
docker build -t helmkit-actions actions/
```

### Test Helm Action

```bash
# Check helm version
docker run --rm -v $(pwd):/workspace helmkit-actions helm version --short

# Lint a chart
docker run --rm -v $(pwd):/workspace helmkit-actions helm lint ./charts/myapp

# Template a chart
docker run --rm -v $(pwd):/workspace helmkit-actions helm template my-release ./charts/myapp
```

### Test Helmfile Action

```bash
# Check helmfile version
docker run --rm -v $(pwd):/workspace helmkit-actions helmfile version

# Lint a helmfile
docker run --rm -v $(pwd):/workspace helmkit-actions helmfile lint -f ./helmfile.yaml

# Diff helmfile
docker run --rm -v $(pwd):/workspace helmkit-actions helmfile diff -f ./helmfile.yaml
```

---

## License

GNU General Public License v3.0 - see the [LICENSE](../LICENSE) file for details.