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
    Subprocess.call(args)
  end
end