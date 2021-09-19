# tekartik_app_lints_flutter

Tekartik flutter lints

## Getting Started

### Setup

```yaml
dependencies:
  tekartik_app_lints_flutter:
    git:
      url: git://github.com/tekartik/app_flutter_utils.dart
      ref: null_safety
      path: app_lints
    version: '>=0.1.0'
```

## Usage

In `analysis_options.yaml`:

```yaml
# tekartik flutter recommended lints (extension over google lints and pedantic)
include: package:tekartik_app_lints_flutter/recommended.yaml
```