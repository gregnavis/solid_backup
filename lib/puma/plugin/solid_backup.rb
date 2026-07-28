require "puma/plugin"
require "solid_backup"

Puma::Plugin.create do
  def start(launcher)
    return if SolidBackup.disabled?

    in_background do
      loop do
        sleep(1)
        SolidBackup.tick
      end
    end
  end
end
