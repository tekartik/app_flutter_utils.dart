# tekartik_app_lints_flutter

**Deprecated**: use `tekartik_lints_flutter` from
[common_flutter.dart](https://github.com/tekartik/common_flutter.dart)
instead. This package is only kept for the projects that still list it as a
dependency; its `lib/recommended.yaml` is not maintained (it still names
options and lints removed from Dart 3) and should not be included.

## Getting started (the replacement)

```yaml
dev_dependencies:
  tekartik_lints_flutter:
    git:
      url: https://github.com/tekartik/common_flutter.dart
      path: packages/lints_flutter
```

In `analysis_options.yaml`:

```yaml
include: package:tekartik_lints_flutter/recommended.yaml
```

Moving from this package: replace the `tekartik_app_lints_flutter`
dependency by the one above, and the include line if it pointed to
`package:tekartik_app_lints_flutter/recommended.yaml`.
