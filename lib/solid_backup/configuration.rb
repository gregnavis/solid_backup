module SolidBackup
  class Configuration
    attr_accessor :enabled
    attr_reader :algorithms

    def initialize
      self.enabled = nil
      self.algorithms = []
    end

    def backup(name, algorithm_class, **algorithm_arguments)
      name = name.to_s
      if algorithms.find { it.name == name }
        raise ArgumentError.new("#{name} has had backups configured already")
      end

      algorithms << algorithm_class.new(name:, **algorithm_arguments)
    end

    def validate!
      if [true, false].exclude?(enabled)
        raise TypeError.new("enabled is set to #{enabled.inspect}, but allowed values are true or false")
      end

      configured_database_names = algorithms.map(&:name)
      all_database_names = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).select do |db_config|
        db_config.adapter == "sqlite3"
      end.map(&:name)

      if (missing_databases = all_database_names - configured_database_names).present?
        raise "SQLite databases missing from backup configuration: #{missing_databases.join(", ")}"
      end
      if (unknown_databases = configured_database_names - all_database_names).present?
        raise "unknown SQLite databases present in backup configuration: #{unknown_databases.join(", ")}"
      end
    end

    def enabled?
      enabled
    end

    def disabled?
      !enabled?
    end

    private

    attr_writer :algorithms
  end
end
