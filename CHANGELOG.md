# Solid Backup

## 0.4.0

- Add backup compression support via the `compressor:` option; currently
  `SolidBackup::Compressor::Gzip` is the only supported value.

## 0.3.0

- `destination` is the directory where backup files will be placed, not a
  %-encoded template.
- New `expiration:` option can be set to determine backup expiration policy;
  currently only `SolidBackup::Expiration::Age.new(maximum: ...)` and
  `SolidBackup::Expiration::None.new` are supported.

## 0.2.2

- Don't call `SolidBackup` too early to avoid errors caused by Rails not being
  loaded in production.

## 0.2.1

- Require Active Support libraries to ensure `delegate` is defined.

## 0.2.0

- Support for per-environment backup configuration.

## 0.1.0

- Initial release.
