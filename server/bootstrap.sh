#!/bin/bash

set -e

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
apt-get -y install git make

wget -qO- https://get.docker.com/ | sh

wget https://raw.github.com/progrium/gitreceive/master/gitreceive
mv gitreceive /usr/bin/
cd /usr/bin
chmod 755 gitreceive
gitreceive init

usermod -aG docker git

# configure receiver script
receiver_path="/home/git/receiver"
cat > "$receiver_path" <<EOF
#!/usr/bin/env bash

cat | buildstep app
launchapp
EOF
chmod +x "$receiver_path"
chown git "$receiver_path"

# configure launch script
launch_path="/usr/bin/launchapp"
cat > "$launch_path" <<EOF
#!/usr/bin/env bash

if ! docker images app | grep "app" > /dev/null ; then exit 1 ; fi

vars=""
FILES=/etc/ukku/vars/*
for f in \$FILES
do
  vars="\$vars -e \${f##*/}=\$(<\$f)"
done

PS_TYPES=/etc/ukku/ps-types/*
for f in \$PS_TYPES
do
  type=\${f##*/}

  link=""
  if docker inspect postgres > /dev/null ; then link="--link postgres:postgres" ; fi

  docker kill app-\$type > /dev/null 2>&1
  docker rm app-\$type > /dev/null 2>&1
  if [[ \$type = "web" ]] ; then
    docker run -d --name app-web -p 80:3000 \$vars -e PORT=3000 \$link -v /var/run/docker.sock:/run/docker.sock -v $(which docker):/bin/docker -v /tmp/ukku:/tmp/ukku app /bin/bash -c "herokuish procfile start web"
  else
    docker run -d --name app-\$type \$vars \$link -v /var/run/docker.sock:/run/docker.sock -v $(which docker):/bin/docker -v /tmp/ukku:/tmp/ukku app /bin/bash -c "herokuish procfile start \$type"
  fi
done
EOF
chmod +x "$launch_path"
chown git "$launch_path"

# configure run command
run_path="/usr/bin/runcommand"
cat > "$run_path" <<EOF
#!/usr/bin/env bash

if ! docker images app | grep "app" > /dev/null ; then exit 1 ; fi

vars=""
FILES=/etc/ukku/vars/*
for f in \$FILES
do
  vars="\$vars -e \${f##*/}=\$(<\$f)"
done

link=""
if docker inspect postgres > /dev/null ; then link="--link postgres:postgres" ; fi

command="/exec \$@"
docker run -t -i \$vars \$link -v /var/run/docker.sock:/run/docker.sock -v $(which docker):/bin/docker -v /tmp/ukku:/tmp/ukku app /bin/bash -c "\$command"
EOF
chmod +x "$run_path"

# install authorized key
cd
key="$(cat .ssh/authorized_keys)"
install_authorized_key "$key" "default"

# install buildstep
git clone https://github.com/progrium/buildstep.git
cd buildstep
make build
cp buildstep /usr/bin/

# give the group docker to the git user
sudo usermod -a -G docker git

mkdir -p /etc/ukku/ps-types
touch /etc/ukku/ps-types/web

mkdir -p /etc/ukku/vars
if getopts ":p" opts ; then
  docker run --name postgres -e POSTGRES_USER=app -e POSTGRES_PASSWORD=5tgbnhy6 -v /home/git/volumes/data:/var/lib/postgresql/data -d postgres
  echo postgres://app:5tgbnhy6@postgres/app > /etc/ukku/vars/DATABASE_URL
fi