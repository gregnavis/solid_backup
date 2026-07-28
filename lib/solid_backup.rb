require "solid_backup/backup"
require "solid_backup/backup/none"
require "solid_backup/backup/api"
require "solid_backup/backup/vacuum_into"
require "solid_backup/configuration"
require "solid_backup/version"
require "solid_backup/railtie"

module SolidBackup
  class << self
    delegate :enabled?, :disabled?, to: :configuration

    attr_reader :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    def tick
      configuration.algorithms.each(&:tick)
    end

    private

    attr_writer :configuration
  end
end
