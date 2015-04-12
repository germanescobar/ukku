class PsAddCommand
  def execute(args)
    type = args['TYPE']

    if !File.exist?(UKKU_FILE)
      raise "No application configured. Run 'ukku configure HOST' first."
    end

    data = YAML.load_file(UKKU_FILE)
    name, server = data.first
    if name.nil?
      raise "No application configured. Run 'ukku configure <host>' first."
    end

    if data.length > 1
      if args['--app'].empty?
        raise "No app specified, use the --app NAME option"
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
    conn.execute("touch /etc/ukku/ps-types/#{type}")
    begin
      conn.execute("launchapp")
    rescue Subprocess::NonZeroExit => e
    end
  end
end