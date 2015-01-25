class Connection
  def initialize(host, user, identity_file)
    @host = host
    @user = user
    @identity_file = identity_file
  end

  def execute(command, &blk)
    args = ["ssh", "-t"]
    if @identity_file
      args += ["-i", @identity_file ]
    end
    args += ["#{@user}@#{@host}", "#{command}"]
    if &blk
      Subprocess.check_call(args, stdin: Subprocess::PIPE, &blk)
    else
      Subprocess.check_call(args)
    end
  end
end