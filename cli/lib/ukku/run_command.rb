class RunCommand < Command
  def execute(args)
    command = args['COMMAND'].join(' ')

    app_info = load_app_info(args)

    puts "Running command '#{command}' on #{app_info[:host]} ..."
    conn = Connection.new(app_info)
    conn.execute("runcommand #{command}")
  end
end