class Connection
  def initialize(opts)
    options = opts.each_with_object({}) { |(k,v), h| h[k.to_sym] = v }

    @host = options[:host]
    @user = options[:user]
    @identity_file = options[:identity_file]
  end

  def execute(command, &blk)
    args = ["ssh"]
    args << "-t" if blk.nil?
    if @identity_file
      args += ["-i", @identity_file ]
    end
    args += ["#{@user}@#{@host}", "#{command}"]
    if blk
      Subprocess.check_call(args, stdin: Subprocess::PIPE, &blk)
    else
      Subprocess.check_call(args)
    end
  end
end