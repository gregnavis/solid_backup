class SolidBackup::Configuration::Environment
  attr_reader :name, :backups

  def initialize(name)
    self.name = name
    self.backups = []

    yield(self)
  end

  def tick
    backups.each(&:tick)
  end

  def backup(database, algorithm_class, **algorithm_arguments)
    database = database.to_s
    if backups.any? { it.database == database }
      raise ArgumentError.new("backups for #{database} in #{name} have already been configured")
    end

    backups << algorithm_class.new(database:, **algorithm_arguments)
  end

  def validate!
    configured_databases = backups.map(&:database)
    all_databases = ActiveRecord::Base.configurations.configs_for(env_name: name).select do |db_config|
      db_config.adapter == "sqlite3"
    end.map(&:name)

    if (missing_databases = all_databases - configured_databases).present?
      raise "SQLite databases missing from backup configuration for #{name}: #{missing_databases.join(", ")}"
    end
    if (unknown_databases = configured_databases - all_databases).present?
      raise "unknown SQLite databases present in backup configuration for #{name}: #{unknown_databases.join(", ")}"
    end
  end

  private

  attr_writer :name, :backups
end
