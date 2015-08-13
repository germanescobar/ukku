class PsRemoveCommand < Command
  def execute(args)
    type = args['TYPE']

    app_info = load_app_info(args)

    puts "Removing process type '#{type}' on #{app_info[:host]} ..."
    conn = Connection.new(app_info)
    begin
      conn.execute("sudo rm /etc/ukku/ps-types/#{type} && docker kill app-#{type} && docker rm app-#{type}")
      conn.execute("launchapp")
    rescue Subprocess::NonZeroExit => e
    end
  end
end