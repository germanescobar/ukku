class PsRestartCommand < Command
  def execute(args)
    app_info = load_app_info(args)

    puts "Restarting processes on #{app_info[:host]} ..."
    conn = Connection.new(app_info)
    begin
      conn.execute("launchapp")
    rescue Subprocess::NonZeroExit => e
    end
  end
end