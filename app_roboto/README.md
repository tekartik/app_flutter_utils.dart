# app_roboto

Roboto fonts

## Setup

pubspec.yaml:

```yaml
dependencies:
  tekartik_app_roboto:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
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
        - asset: packages/tekartik_app_roboto/fonts/RobotoCondensed/RobotoCondensed-Regular.ttf
```

```yaml
flutter:
  fonts:
    - family: RobotoMono
      fonts:
        - asset: packages/tekartik_app_roboto/fonts/RobotoMono/RobotoMono-Regular.ttf
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
    - family: RobotoMono
      fonts:
        - asset: packages/tekartik_app_roboto/fonts/RobotoMono/RobotoMono-Regular.ttf
        - asset: packages/tekartik_app_roboto/fonts/RobotoMono/RobotoMono-Bold.ttf
          weight: 700
    - family: RobotoCondensed
      fonts:
        # missing
        # - asset: packages/tekartik_app_roboto/fonts/RobotoCondensed/RobotoCondensed-Thin.ttf
        #  weight: 100
        - asset: packages/tekartik_app_roboto/fonts/RobotoCondensed/RobotoCondensed-Light.ttf
          weight: 300
        - asset: packages/tekartik_app_roboto/fonts/RobotoCondensed/RobotoCondensed-Regular.ttf
          weight: 400
        # missing
        # - asset: packages/tekartik_app_roboto/fonts/RobotoCondensed/RobotoCondensed-Medium.ttf
        #   weight: 500
        # - asset: packages/tekartik_app_roboto/fonts/RobotoCondensed/RobotoCondensed-Bold.ttf
        #   weight: 700
        - asset: packages/tekartik_app_roboto/fonts/RobotoCondensed/RobotoCondensed-Black.ttf
          weight: 900
```
