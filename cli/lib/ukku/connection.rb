class Connection
  def initialize(host, user, identity_file)
    @host = host
    @user = user
    @identity_file = identity_file
  end
  
  def execute(command)
    Subprocess.call(["ssh", "-t", "#{user}@#{root}", "/exec #{command}"])
  end
end