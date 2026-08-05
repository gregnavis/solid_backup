require "rails/generators"

module SolidBackup
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates a Solid Backup initializer"

      def copy_initializer
        backups = []

        ActiveRecord::Base.configurations.configs_for(env_name: "production").each do |db_config|
          backups << if yes?("Back up #{db_config.name} in production?")
            <<~CODE.chomp
              production.backup #{db_config.name.inspect},
                                SolidBackup::Backup::API,
                                destination: "storage/backups",
                                interval_in_minutes: 60,
                                expiration: SolidBackup::Expiration::Age.new(maximum: 24.hours),
                                step: 100,
                                wait: 0.1
            CODE
          else
            "production.backup #{db_config.name.inspect}, SolidBackup::Backup::None"
          end
        end

        initializer "solid_backup.rb", <<~CODE
          SolidBackup.configure do |config|
            # Enable or disable Solid Backup globally.
            config.enabled = Rails.env.production?

            # Backup configuration for each database.
            #
            # IMPORTANT: all databases must be explicitly configured, even if they're not
            # backed up, to avoid accidentally excluding new databases from backups.
            config.environment("production") do |production|
          #{backups.join("\n").indent(4)}
            end
          end
        CODE

        insert_into_file "config/puma.rb", <<~CODE

          # Run Solid Backup in the background.
          plugin :solid_backup
        CODE

        empty_directory "storage/backups"
        create_file "storage/backups/.keep"

        insert_into_file ".gitignore", "!/storage/backups/.keep\n", after: "!/storage/.keep\n"
      end
    end
  end
end
