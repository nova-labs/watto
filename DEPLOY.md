
# Deploy

This describes the deploy process for Nova Labs. It is a bit manual of a deploy
solution, but wanted to document it for future reference.

## Installing on Ubuntu

##### 1. Create limited user

We used user `wautils`

##### 2. Install Ruby

Gonna build a ruby and store it in the wautils users home dir, so the app stays
isolated(ish) from the system.

Build dependencies:

```
sudo apt install git curl libssl-dev libreadline-dev \
         zlib1g-dev autoconf bison build-essential \
         libyaml-dev libreadline-dev libncurses5-dev \
         libffi-dev libgdbm-dev libsqlite3-dev
```

Install `ruby-install` per it's [README](https://github.com/postmodern/ruby-install)

Install Ruby as the limited user.

```
sudo su - wautils
ruby-install --no-install-deps ruby 3.0.3
```

##### 3. Setup the Rails app

Clone this repo to `~/src`

Install the `.env` file. This file will include variables for PATH and
RUBY_HOME so that the correct Ruby and Gems are loaded when running the app.
This is done in lieu of a Ruby Version Manager to keep things simple. See
[`.env-example`](.env-example) for the options.

Create the DB, run migrations, and precompile assets:

```
sudo su - wautils
source ./bin/load-env
bundle exec bin/setup
```

Install the systemd unit:

```
sudo ln -s /home/wautils/src/watto/etc/watto.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start watto
```

To see logs:

```
sudo journalctl -u watto
```

##### 3. Setup deploy repo

1.  Create a bare repo at `~/git/watto`
2. Configure authroized hosts to use key pair autentication for the user.
3. Add the `post-receive` hook below

To deploy to this branch you will need to configure the development machine.

1. Add production remote `git remote add production wautils@srv-b.nova-labs.org:git/watto`
2. Push to the main branch `git push produciton main`

###### Post Recieve Hook for Deploying via Git

```
#!/bin/bash

set -e

GIT_DIR=/home/wautils/git/watto
WORK_TREE=/home/wautils/srv/watto

export RAILS_ENV=production

while read oldrev newrev ref
do
    if [[ $ref =~ .*/main$ ]];
    then
        echo "Main ref received.  Deploying main branch to production..."
        mkdir -p $WORK_TREE
        git --work-tree=$WORK_TREE --git-dir=$GIT_DIR checkout -f

        # start deploy tasks
        cd $WORK_TREE
	export $(cat .env | sed 's/#.*//g' | xargs)

        ./bin/bundle install
        ./bin/rails db:prepare
        ./bin/rails assets:precompile
        ./bin/rails restart
        # end deploy tasks
        echo "Git hooks deploy complete"
    else
        echo "Ref $ref successfully received.  Doing nothing: only the main branch may be deployed on this server."
    fi
done
```
