class PsCommand < Command
  def execute(args)
    type = args['TYPE']

    app_info = load_app_info(args)

    conn = Connection.new(app_info)
    conn.execute("ls /etc/ukku/ps-types")
  end
end