class UploadKeyCommand < Command
  def execute(args)
    app_info = load_app_info(args)
    conn = Connection.new(app_info)

    key_file = args['PUBLIC_KEY_FILE']

    puts "Uploading key '#{key_file}' ... "
    conn.execute("gitreceive upload-key ukku") do |p|
      p.communicate IO.read(File.expand_path(key_file))
    end
    puts "Done!"

    puts
    puts "*********************************************************************"
    puts "ATTENTION: Add the following to '~/.ssh/config' before deploying"
    puts "(create the file if necessary; erase any other entry with same host):"
    puts
    puts "Host #{app_info[:host]}"
    puts "    User git"
    puts "    IdentityFile #{key_file}"
    puts "*********************************************************************"
  end
end
