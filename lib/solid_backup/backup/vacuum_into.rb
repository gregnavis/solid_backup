class SolidBackup::Backup::VacuumInto < SolidBackup::Backup
  private

  def do_perform(backup_path)
    with_connection do |connection|
      connection.exec_query("VACUUM INTO ?", "Solid Backup", [backup_path.to_s])
    end
  end
end
