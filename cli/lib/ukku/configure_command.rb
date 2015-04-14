class ConfigureCommand
  def execute(args)
    host = args['HOST']
    name = args['NAME'] || "production"
    user = args['--user'] || "root"
    no_pg = args['--no-pg']
    identity_file = args['-i']

    entry = { "host" => host, "user" => user } # the entry to add to UKKU_FILE
    entry["identity_file"] = identity_file if identity_file

    # check if the entry exists in UKKU_FILE (with different info)
    entry_in_file = load_entry_from_file(name)
    if entry_in_file && !entries_match?(entry_in_file, entry)
      raise "Name '#{name}' already exists, choose a different one"
    end

    conn = Connection.new(host, user, identity_file)
    server_ready = is_server_ready?(conn)
    
    if server_ready
      puts "The server is already configured ... skipping"
    else
      configure_server(conn, no_pg)
    end

    repo = fetch_repo
    configure_remote(repo, name, "git@#{host}:#{name}")
    
    append_entry_to_ukku_file(name, entry) if !entry_in_file

    append_ukku_file_to_gitignore

    print_ssh_config if identity_file

    puts
    puts "Your server is configured! Deploy your application using 'git push #{name} master'"
  end

  private
    def load_entry_from_file(name)
      if File.exist?(UKKU_FILE)
        data = YAML.load_file(UKKU_FILE)
        data[name]
      end
    end

    def entries_match?(h1, h2)
      h1.size == h2.size && (h1.keys - h2.keys).empty?
    end

    def is_server_ready?(conn)
      begin
        conn.execute("test -e /usr/bin/gitreceive")
        true
      rescue Subprocess::NonZeroExit
        false
      end
    end

    def configure_server(conn, no_pg)
      wget1_command = "wget https://raw.githubusercontent.com/germanescobar/ukku/master/server/bootstrap.sh"
      chmod_command = "chmod 755 bootstrap.sh"
      run_command = "./bootstrap.sh"
      run_command += " -p" unless no_pg
      conn.execute "#{wget1_command} && #{chmod_command} && #{run_command}"
    end

    def fetch_repo
      begin
        Rugged::Repository.new('.')
      rescue Rugged::RepositoryError
        Rugged::Repository.init_at('.')
      end
    end

    def configure_remote(repo, name, remote_url)
      if repo.remotes[name]
        if repo.remotes[name].url != remote_url
          raise "A remote with name '#{name}' already exists"
        end
        puts "Git remote already configured ... skipping"
      else
        print "Configuring remote repository ... "
        repo.remotes.create(name, remote_url)
        puts "done"
      end
    end

    def append_entry_to_ukku_file(name, params)
      data = { name => params }
      File.open(UKKU_FILE, 'a') { |f| f.write data.to_yaml }
    end

    def append_ukku_file_to_gitignore
      if File.read('.gitignore').scan(/.ukku.yml/).length == 0
        print "Adding '#{UKKU_FILE}' to .gitignore ... "
        File.open('.gitignore', 'a') { |f| f.write UKKU_FILE }
        puts "done"
      else
        print "'#{UKKU_FILE}' already in .gitignore ... skipping"
      end
    end

    def print_ssh_config
      puts "*********************************************************************"
      puts "ATTENTION: Add the following to '~/.ssh/config' before deploying"
      puts "(create the file if necessary; erase any other entry with same host):"
      puts
      puts "Host #{host}"
      puts "    User git"
      puts "    IdentityFile #{identity_file}"
      puts "*********************************************************************"
    end

end