class PsAddCommand
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

    puts "Adding process type '#{type}' on #{host} ..."
    conn = Connection.new(host, user, identity_file)
    conn.execute("sudo touch /etc/ukku/ps-types/#{type}")
    begin
      conn.execute("launchapp")
    rescue Subprocess::NonZeroExit => e
    end
  end
end