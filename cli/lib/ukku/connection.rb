class Connection
  def initialize(host, user, identity_file)
    @host = host
    @user = user
    @identity_file = identity_file
  end

  def execute(command)
    args = ["ssh", "-t"]
    if @identity_file
      args += ["-i", @identity_file ]
    end
    args += ["#{@user}@#{@host}", "#{command}"]
    Subprocess.check_call(args)
  end
end