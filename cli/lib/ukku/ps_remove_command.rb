class PsRemoveCommand
  def execute(args)
    type = args['TYPE']

    if !File.exist?(UKKU_FILE)
      raise NoApplicationError
    end

    data = YAML.load_file(UKKU_FILE)
    name, server = data.first
    if name.nil?
      raise NoApplicationError
    end

    if data.length > 1
      if args['--app'].empty?
        raise MultipleApplicationsError
      else
        name = args[--app]
        sever = data[name]
      end
    end

    host = server['host']
    user = server['user']
    identity_file = server['identity_file']

    puts "Removing process type '#{type}' on #{host} ..."
    conn = Connection.new(host, user, identity_file)
    conn.execute("sudo rm /etc/ukku/ps-types/#{type} && docker kill app-#{type} && docker rm app-#{type}")
    begin
      conn.execute("launchapp")
    rescue Subprocess::NonZeroExit => e
    end
  end
end