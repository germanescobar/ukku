class SetVarCommand < Command
  def execute(args)
    var_name = args['VAR_NAME']
    var_value = args['VAR_VALUE']

    app_info = load_app_info(args)

    conn = Connection.new(app_info)
    conn.execute("sudo mkdir -p /etc/ukku/vars && echo '#{var_value}' > /etc/ukku/vars/#{var_name}")
    begin
      conn.execute("launchapp")
    rescue Subprocess::NonZeroExit => e
    end
  end
end