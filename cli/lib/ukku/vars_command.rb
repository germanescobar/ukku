class VarsCommand
  def execute(args)
    data = YAML.load_file(UKKU_FILE)
    name, server = data.first
    if name.nil?
      raise NoApplicationError
    end

    puts "Data length: #{data.length}"
    if data.length > 1
      if args['--app'].nil? || args['--app'] !~ /[^[:space:]]/
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
    conn.execute("sudo mkdir -p /etc/ukku/vars && FILES=/etc/ukku/vars/*; for f in $FILES; do echo \"${f##*/}=$(<$f)\"; done")
  end
end