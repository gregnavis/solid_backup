module SolidBackup::Expiration
  class None
    def select_expired(pathnames)
      []
    end
  end

  class Age
    def initialize(maximum:)
      self.maximum = maximum
    end

    def select_expired(pathnames)
      threshold = maximum.ago.utc
      pathnames.select do |pathname|
        timestamp = yield(pathname)
        timestamp && timestamp < threshold
      end
    end

    private

    attr_accessor :maximum
  end
end
