class PsAddCommand < Command
  def execute(args)
    type = args['TYPE']

    app_info = load_app_info(args)

    puts "Adding process type '#{type}' on #{app_info[:host]} ..."
    conn = Connection.new(app_info)
    conn.execute("sudo touch /etc/ukku/ps-types/#{type}")
    begin
      conn.execute("launchapp")
    rescue Subprocess::NonZeroExit => e
    end
  end
end