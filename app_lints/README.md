# tekartik_app_lints_flutter

**Deprecated**: Use tekartik_lints_flutter in https://github.com/tekartik/common_flutter.dart

## Getting Started

### Setup

```yaml
dependencies:
  tekartik_lints_flutter:
    git:
      url: https://github.com/tekartik/common_flutter.dart
      path: packages/lints_flutter
    version: '>=0.1.0'
```

## Usage

In `analysis_options.yaml`:

```yaml
# tekartik flutter recommended lints (extension over google lints and pedantic)
include: package:tekartik_lints_flutter/recommended.yaml
```
