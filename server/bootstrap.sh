#!/usr/bin/env bash

# Generate a shorter, but still unique, version of the public key associated with the user doing `git push'
generate_fingerprint() {
  awk '{print $2}' | base64 -d | md5sum | awk '{print $1}' | sed -e 's/../:&/2g'
}

install_authorized_key() {
  declare key="$1" name="$2" home_dir="/home/git" git_user="git" self="/usr/bin/gitreceive"
  local fingerprint="$(echo "$key" | generate_fingerprint)"
  local forced_command="GITUSER=$git_user $self run $name $fingerprint"
  local key_options="command=\"$forced_command\",no-agent-forwarding,no-pty,no-user-rc,no-X11-forwarding,no-port-forwarding"
  echo "$key_options $key" >> "$home_dir/.ssh/authorized_keys"
}

apt-get -qqy update
apt-get -y install git make docker.io

wget https://raw.github.com/progrium/gitreceive/master/gitreceive
mv gitreceive /usr/bin/
cd /usr/bin
chmod 755 gitreceive
gitreceive init

receiver_path="/home/git/receiver"
cat > "$receiver_path" <<EOF
#!/usr/bin/env bash

cat | buildstep app
docker kill app
docker rm app
docker run -d --name app -p 80:3000 -e DATABASE_URL="postgres://app:5tgbnhy6@postgres/app" -e PORT=3000 --link postgres:postgres app /bin/bash -c "/start web"
EOF
chmod +x "$receiver_path"
chown git "$receiver_path"

cd
key="$(cat .ssh/authorized_keys)"
install_authorized_key "$key" "default"
git clone https://github.com/progrium/buildstep.git
cd buildstep
make build
cp buildstep /usr/bin/

sudo usermod -a -G docker git

docker run --name postgres -e POSTGRES_USER=app -e POSTGRES_PASSWORD=5tgbnhy6 -v /home/git/volumes/data:/var/lib/postgresql/data -d postgres