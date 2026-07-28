require_relative "lib/solid_backup/version"

Gem::Specification.new do |spec|
  spec.name = "solid_backup"
  spec.version = SolidBackup::VERSION
  spec.authors = ["Greg Navis"]
  spec.email = ["contact@gregnavis.com"]
  spec.summary = "Solid Backup provides simple backups for SQLite databases in Ruby on Rails apps."
  spec.description = "Solid Backup makes it easy to backup SQLite databases using VACUUM INTO or the backup API."
  spec.homepage = "https://github.com/gregnavis/solid_backup"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["source_code_uri"] = "https://github.com/gregnavis/solid_backup"
  spec.metadata["bug_tracker_uri"] = "https://github.com/gregnavis/solid_backup/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["lib/**/*", "MIT-LICENSE.txt", "README.md"]
  end

  spec.require_paths = ["lib"]

  rails_versions = [">= 7.2", "< 8.2"]

  spec.add_dependency "activerecord", *rails_versions
  spec.add_dependency "railties", *rails_versions
  spec.add_dependency "sqlite3", ">= 1.4"

  spec.add_development_dependency "rake", "~> 13.4"
  spec.add_development_dependency "standard", "~> 1.56"
end
