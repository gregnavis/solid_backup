module SolidBackup
  class Configuration
    attr_accessor :enabled
    attr_reader :environments

    def initialize
      self.enabled = nil
      self.environments = []
    end

    def environment(name, &)
      name = name.to_s
      if environments.any? { it.name == name }
        raise ArgumentError.new("environment #{name} has already been configured")
      end

      environments << SolidBackup::Configuration::Environment.new(name, &)
    end

    def tick(env_name)
      env_name = env_name.to_s
      environments.find { it.name == env_name }&.tick
    end

    def validate!
      if [true, false].exclude?(enabled)
        raise TypeError.new("enabled is set to #{enabled.inspect}, but allowed values are true or false")
      end

      environments.each(&:validate!)
    end

    def enabled?
      enabled
    end

    def disabled?
      !enabled?
    end

    private

    attr_writer :environments
  end
end
