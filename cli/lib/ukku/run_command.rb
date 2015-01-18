class RunCommand
  def execute(args)
    if !File.exist?(UKKU_FILE)
      raise "No application configured. Run 'ukku configure HOST' first."
    end

    data = YAML.load_file(UKKU_FILE)
    name, server = data.first
    if name.nil?
      raise "No application configured. Run 'ukku configure <host>' first."
    end

    if data.length > 1
      if global_options[:app].nil? || global_options[:app].empty?
        raise "No app specified, use the --app APP option"
      else
        name = global_options[:app]
        sever = data[name]
      end
    end

    host = server['host']
    user = server['user']

    puts "Running command '#{command}' on #{host} ..."
    Subprocess.call(['ssh', '-t', "#{user}@#{host}", "./run.sh #{command}"])    
  end
end