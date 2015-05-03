class SetVarCommand
  def execute(args)
    var_name = args['VAR_NAME']
    var_value = args['VAR_VALUE']

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

    conn = Connection.new(host, user, identity_file)
    conn.execute("sudo mkdir -p /etc/ukku/vars && echo '#{var_value}' > /etc/ukku/vars/#{var_name}")
    begin
      conn.execute("launchapp")
    rescue Subprocess::NonZeroExit => e
    end
  end
end