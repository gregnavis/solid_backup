require "active_support/core_ext/module/delegation"

module SolidBackup
  class Backup
    attr_reader :database

    def initialize(database:, destination:, interval_in_minutes:)
      self.database = database
      self.destination = destination
      self.interval_in_minutes = interval_in_minutes

      reset_countdown
    end

    def tick
      if countdown > 0
        self.countdown -= 1
      end

      if countdown <= 0
        perform
        reset_countdown
      end
    end

    def perform
      ActiveSupport::Notifications.instrument("backup.solid_backup", database:) do
        lock do
          do_perform(Time.now.utc.strftime(destination.to_s))
        end
      end
    end

    private

    attr_accessor :countdown
    attr_writer :database
    attr_reader :destination, :interval_in_minutes

    def interval_in_minutes=(value)
      if !value.is_a?(Integer) || value <= 0
        raise TypeError.new(<<~ERROR)
          invalid backup configuration for #{database}: interval_in_minutes is set to #{value.inspect}, but should be set to a positive integer
        ERROR
      end

      @interval_in_minutes = value
    end

    def destination=(value)
      value = Pathname(value)
      directory = value.dirname

      if !directory.directory?
        raise "invalid backup configuration for #{database}: destination directory #{directory} must exist"
      end

      test_path = directory / "solid_backup.txt"
      begin
        test_path.write("Solid Backup Test")
      rescue Errno::EACCES
        raise "invalid backup configuration for #{database}: destination directory #{directory} must be writeable"
      ensure
        test_path.unlink
      end

      @destination = value
    end

    def reset_countdown
      self.countdown = 60 * interval_in_minutes
    end

    def do_perform(backup_path)
      raise "must be implemented by a subclass"
    end

    def connection_pool
      ActiveRecord::Base.connection_handler.establish_connection(database.to_sym)
    end

    delegate :with_connection, to: :connection_pool

    def lock
      path = destination.dirname / ".solid_backup.#{database}.lock"

      File.open(path, File::RDWR | File::CREAT) do |f|
        if f.flock(File::LOCK_EX | File::LOCK_NB)
          begin
            yield
          ensure
            f.flock(File::LOCK_UN)
          end
        end
      end

      begin
        File.unlink(path)
      rescue Errno::ENOENT
      end
    end
  end
end
