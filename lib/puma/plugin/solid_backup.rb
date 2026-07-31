require "puma/plugin"
require "solid_backup"

Puma::Plugin.create do
  def start(launcher)
    in_background do
      next if !defined?(Rails) || !Rails.application&.initialized?
      next if SolidBackup.disabled?

      loop do
        sleep(1)
        SolidBackup.tick
      end
    end
  end
end
