class VarsCommand < Command
  def execute(args)
    app_info = load_app_info(args)

    conn = Connection.new(app_info)
    conn.execute("sudo mkdir -p /etc/ukku/vars && FILES=/etc/ukku/vars/*; for f in $FILES; do echo \"${f##*/}=$(<$f)\"; done")
  end
end