class UploadKeyCommand
  def execute(args)
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

    key_file = args['PUBLIC_KEY_FILE']

    conn = Connection.new(host, user, identity_file)

    puts "Uploading key '#{key_file}' ... "
    conn.execute("gitreceive upload-key ukku") do |p|
      p.communicate IO.read(File.expand_path(key_file))
    end
    puts "Done!"

    puts
    puts "*********************************************************************"
    puts "ATTENTION: Add the following to '~/.ssh/config' before deploying"
    puts "(create the file if necessary; erase any other entry with same host):"
    puts
    puts "Host #{host}"
    puts "    User git"
    puts "    IdentityFile #{key_file}"
    puts "*********************************************************************"
  end
end