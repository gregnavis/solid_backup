# Solid Backup

## 0.2.2

- Don't call `SolidBackup` too early to avoid errors caused by Rails not being
  loaded in production.

## 0.2.1

- Require Active Support libraries to ensure `delegate` is defined.

## 0.2.0

- Support for per-environment backup configuration.

## 0.1.0

- Initial release.
