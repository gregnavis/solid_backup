# None is a special case: all other backup methods need a destination and
# interval, but it doesn't make sense to pass them to None. That's why it
# overrides:
#
# - tick - to avoid the countdown
# - perform - to avoid creating lock files and emitting instrumentation events
# - destination and interval_in_minutes - to allow nil values
class SolidBackup::Backup::None < SolidBackup::Backup
  def initialize(name:)
    super(name:, destination: nil, interval_in_minutes: 0)
  end

  def tick
  end

  def perform
  end

  private

  attr_writer :destination, :interval_in_minutes

  def do_perform(backup_path)
  end
end
