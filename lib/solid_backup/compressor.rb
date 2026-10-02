module SolidBackup::Compressor
  module Gzip
    def self.compress(source_path)
      target_path = "#{source_path}.gz"
      source_path = Pathname(source_path)

      Zlib::GzipWriter.open(target_path) do |gzip|
        gzip.mtime = source_path.mtime
        gzip.orig_name = source_path.basename.to_s
        gzip.write(source_path.binread)
      end
    end
  end
end
