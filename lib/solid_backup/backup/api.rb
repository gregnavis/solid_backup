class SolidBackup::Backup::API < SolidBackup::Backup
  def initialize(step:, wait:, **)
    super(**)

    self.step = Integer(step)
    self.wait = Float(wait)
  end

  private

  attr_accessor :step, :wait

  def do_perform(backup_path)
    with_connection do |connection|
      source = connection.raw_connection
      destination = SQLite3::Database.new(backup_path)

      backup = SQLite3::Backup.new(destination, "main", source, "main")

      loop do
        result = backup.step(step)
        case result
        when SQLite3::Constants::ErrorCode::DONE
          break
        when SQLite3::Constants::ErrorCode::OK
          next
        when SQLite3::Constants::ErrorCode::BUSY, SQLite3::Constants::ErrorCode::LOCKED
          sleep(wait)
        else
          raise "SQLite backup failed with #{result.inspect}"
        end
      end

      backup.finish
      destination.close
    end
  end
end
