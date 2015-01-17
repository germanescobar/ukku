class Connection
  def initialize(host, user, identity_file)
    @host = host
    @user = user
    @identity_file = identity_file
  end

  def execute(command)
    Subprocess.call(["ssh", "-t", "#{@user}@#{@host}", "#{command}"])
  end
end