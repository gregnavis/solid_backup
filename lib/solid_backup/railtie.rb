require "rails"

module SolidBackup
  class Railtie < Rails::Railtie
    generators do
      require_relative "generators/install_generator"
    end

    config.after_initialize do
      SolidBackup.configuration&.validate!
    end
  end
end
