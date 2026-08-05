# Solid Backup

Solid Backup provides simple backups for SQLite databases in Ruby on Rails apps.

## Installation

In order to install Solid Backup run:

1. `bundle add solid_backup`.
2. `bin/rails generate solid_backup:install`.

The generator will go over all production SQLite databases and ask you whether
you want to back up each one of them. By default, it uses the `API` mode. It'll
also create `storage/backups` and install the Puma plugin.

That's it! Read the following section to learn how to customize the backup
process.

## Configuration

Solid Backup **REQUIRES** each SQLite production database to have a backup mode set,
with the goal of ensuring all databases were taken into consideration and none
will lack backups due to omission. There are three database backup modes:

- `SolidBackup::Backup::None` - don't back up.
- `SolidBackup::Backup::API` - use [the SQLite3 backup API].
- `SolidBackup::Backup::VacuumInto` - use [`VACUUM INTO`].

Modes other than `SolidBackup::Backup::None` take the following parameters:

- `destination` - the directory where backup files will be held; it must already
                  exist and be writeable.
- `interval_in_minutes` - the number of minutes to the beginning of the next
                          backup after the previous one finished.
- `expiration` - backup expiration policy; expired backups are automatically
                 removed.

Additionally, `SolidBackup::Backup::API` takes the following parameters:

- `step` - the number of database pages to back up in one step.
- `wait` - how many seconds to wait in case the backup process run into a lock.

The following example configuration file demonstrates how to use each backup
mode in practice:

```ruby
SolidBackup.configure do |config|
  config.enabled = true

  # Configure backups for all production databases. Other environments can have
  # backups configured for them via additional config.environment blocks.
  config.environment("production") do |production|
    # Back up the primary database using the SQLite backup API.
    production.backup "primary",
                      SolidBackup::Backup::API,
                      destination: "storage/backups",

                      # Start the next backup 15 minutes after the previous one.
                      interval_in_minutes: 15,

                      # Back up in 100-page increments.
                      step: 100,

                      # Wait 0.1 seconds if a lock interrupts a backup step.
                      wait: 0.1,

                      # Remove backups older than 30 days.
                      expiration: SolidBackup::Expiration::Age.new(maximum: 30.days)

    # Don't back up the cache database.
    production.backup "cache", SolidBackup::Backup::None

    # Back up the queue database using VACUUM INTO.
    production.backup "queue",
                      SolidBackup::Backup::VacuumInto,
                      destination: "storage/backups",

                      # Start the next backup 60 minutes after the previous one.
                      interval_in_minutes: 60,

                      # Remove backups older than 12 hours.
                      expiration: SolidBackup::Expiration::Age.new(maximum: 12.hours)
  end
end
```

## Puma plugin

Solid Backup ships with a Puma plugin that runs the backup process in the
background on schedule. The install generator installs it automatically, but if
you need to install it manually you can add the following line to `puma.rb`:

```ruby
plugin "solid_backup"
```

## Ruby and Rails Compatibility Policy

Solid Backup supports Rails versions supported by the Rails Core Team and Ruby
versions supported by all supported Rails versions.

## Author

This gem was created and is maintained by [Greg Navis].

[Greg Navis]: https://www.gregnavis.com/
[the SQLite3 backup API]: https://sqlite.org/c3ref/backup_finish.html
[`VACUUM INTO`]: https://sqlite.org/lang_vacuum.html#vacuuminto
