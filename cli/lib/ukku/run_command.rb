class RunCommand
  def execute(args)
    command = args['COMMAND'].join(' ')

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

    puts "Running command '#{command}' on #{host} ..."
    conn = Connection.new(host, user, identity_file)
    conn.execute("runcommand #{command}")
  end
end