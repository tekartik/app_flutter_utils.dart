# app_roboto

Roboto fonts

## Setup

pubspec.yaml:

```yaml
dependencies:
  tekartik_app_roboto:
    git:
      url: git://github.com/tekartik/app_flutter_utils.dart
      ref: null_safety
      path: app_roboto
      version: '>=0.1.0'
```
## Getting Started

Only include the one you need.

One:

```yaml
flutter:
  fonts:
    - family: Roboto
      fonts:
        - asset: packages/tekartik_app_roboto/fonts/Roboto/Roboto-Regular.ttf
```

All:

```yaml
flutter:
  fonts:
    - family: Roboto
      fonts:
        - asset: packages/tekartik_app_roboto/fonts/Roboto/Roboto-Thin.ttf
          weight: 100
        - asset: packages/tekartik_app_roboto/fonts/Roboto/Roboto-Light.ttf
          weight: 300
        - asset: packages/tekartik_app_roboto/fonts/Roboto/Roboto-Regular.ttf
          weight: 400
        - asset: packages/tekartik_app_roboto/fonts/Roboto/Roboto-Medium.ttf
          weight: 500
        - asset: packages/tekartik_app_roboto/fonts/Roboto/Roboto-Bold.ttf
          weight: 700
        - asset: packages/tekartik_app_roboto/fonts/Roboto/Roboto-Black.ttf
          weight: 900
```