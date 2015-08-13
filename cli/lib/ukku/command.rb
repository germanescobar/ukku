class Command
  def load_app_info(args)
    raise NoApplicationError if !File.exist?(UKKU_FILE)

    data = YAML.load_file(UKKU_FILE)
    raise NoApplicationError if data.length == 0

    if data.length > 1
      if args['--app'].nil? || args['--app'] !~ /[^[:space:]]/
        raise MultipleApplicationsError
      else
        name = args['--app']
        app_info = data[name]
      end
    else
      app_info = data.values.first
    end

    app_info.each_with_object({}) { |(k,v), h| h[k.to_sym] = v }
  end
end