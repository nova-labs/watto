
# Deploy

This describes the deploy process for Nova Labs. It is a bit manual of a deploy
solution, but wanted to document it for future reference.

## How it runs

- The app runs as the `wautils` user from `~/srv/watto`, under the `wautils`
  systemd unit ([`deploy/wautils.service`](deploy/wautils.service)), with Puma
  on `127.0.0.1:$PORT`.
- Apache proxies `wautils.nova-labs.org` to it
  ([`deploy/apache.conf`](deploy/apache.conf), the whole HTTP and HTTPS
  config). certbot only fetches the Let's Encrypt certificate (`certonly
  --webroot`, cert name `wautils`) and reloads Apache when it renews.
- Ruby is built with `ruby-install` into `~wautils/.rubies` by
  [`bin/install-ruby`](bin/install-ruby), and `.env` sets `PATH`, `GEM_HOME`
  etc. to point at it (see [`.env-example`](.env-example)) instead of using a
  Ruby version manager. chruby is installed only so interactive `wautils`
  shells get the right Ruby.
- Deploys are a `git push` to the bare repo at `~wautils/git/watto`. Its
  [`post-receive`](deploy/post-receive) hook checks out `main`, bundles,
  migrates, precompiles assets, and touches `tmp/restart.txt` so Puma restarts
  itself. The hook only reads `.env` up to the `# STOP` comment.

The server is shared with other Nova Labs apps. Watto only owns the `wautils`
user, the `wautils` unit and the `wautils` Apache site.

## Deploying

```
git remote add production wautils@srv-b.nova-labs.org:git/watto
git push production main
```

Logs: `sudo journalctl -u wautils`

Puma's `tmp/restart.txt` restart keeps the environment systemd started it
with, so a deploy that needs a changed `.env` (a new Ruby, a new secret) also
needs `sudo systemctl restart wautils`.

### Upgrading Ruby

1. Update `.ruby-version` and the `ruby` line in the `Gemfile`, and get the
   specs passing.
2. On the server, as `wautils`, build it before deploying. From your checkout:
   ```
   COPYFILE_DISABLE=1 tar --no-xattrs -c bin/install-ruby .ruby-version Gemfile.lock | ssh wautils@HOST 'd=$(mktemp -d) && tar -x -C "$d" && "$d/bin/install-ruby" ~/srv/watto/.env; rm -rf "$d"'
   ```
3. Put the Ruby lines it prints into `.env`, push `main`, then
   `sudo systemctl restart wautils`. Deploy right after editing `.env`: until
   then any deploy of the old code would run on the new Ruby.

The old Ruby stays in `~/.rubies`, so rolling back is restoring the old `.env`
lines, pushing the previous commit, and restarting.

## Provisioning a server

[`deploy/provision`](deploy/provision) sets up a fresh Ubuntu server: build
packages, Apache and certbot, `ruby-install` and chruby, the `wautils` user
and unit, the Apache site, Ruby (the version in `.ruby-version`, via
`bin/install-ruby`), and the deploy repo.
Run it from your own checkout with an account that has sudo on the server. It
is safe to re-run:

```
deploy/provision srv-c.nova-labs.org
```

It never touches `.env` or the databases. Those are copied over by hand.

To also serve other names, like a temporary one for testing a new server
before DNS moves, pass them in `APP_ALIASES`. The certificate covers each name
whose DNS already points at the server:

```
APP_ALIASES=xwautils.nova-labs.org deploy/provision srv-c.nova-labs.org
```

Keep passing the same `APP_ALIASES` on later runs, or the name is dropped from
Apache (and certbot will be asked to drop it from the certificate).

### Moving to a new server

1. Point a temporary name (e.g. `xwautils.nova-labs.org`) at the new server and
   run `APP_ALIASES=<temp name> deploy/provision NEW_HOST`.
2. Copy `~wautils/srv/watto/.env` from the old server, and update the Ruby
   paths if the Ruby version changed. Add your SSH key to
   `~wautils/.ssh/authorized_keys`.
3. `git push NEW_HOST main` to deploy, then `sudo systemctl restart wautils`.
   The hook only restarts a running app, so the first start is manual. Check
   it at `https://<temp name>`. Signing in there only works if the Wild
   Apricot app allows that redirect domain.
4. Cut over: `sudo systemctl stop wautils` on the old server, copy both
   databases from `~wautils/srv/watto/db/` (the telemetry one can't be rebuilt,
   see below), and `sudo systemctl restart wautils` on the new one.
5. Point DNS for `wautils.nova-labs.org` at the new server, then re-run
   provisioning (with the same `APP_ALIASES`) to add it to the certificate.
6. Update the `production` git remote.

## Databases

Watto uses two SQLite databases (see `config/database.yml`):

- **primary**: `db/<WA_ACCOUNT>-<env>.sqlite3`, a cache of Wild Apricot. It's fine to throw away and resync.
- **telemetry**: `db/telemetry-<env>.sqlite3`, the readings reported by on-site agents (dust collector
  level). It is **not** recreated from Wild Apricot, so keep it and back it up.

`db:prepare` and `db:migrate` handle both. The unscoped `db:drop`, `db:reset` and `db:schema:load` act
on **both** databases, so to wipe only the WA cache use the scoped tasks:

```
bin/rails db:reset:primary
bin/rails db:drop:primary
```

Telemetry migrations live in `db/telemetry_migrate/`. Generate them with `--database telemetry`.

## Dust collector agent

The dust collector page (`/dust_collector`) shows readings that the on-site
[dc-level-app](https://github.com/sklosky-nl/dc-level-app) poller POSTs to `/api/dust_collector` once a
minute. The agent authenticates with a shared bearer token:

1. Generate a token (`openssl rand -hex 32`) and set `DUST_COLLECTOR_TOKEN` in Watto's `.env`.
2. On the agent host, set `WATTO_URL=https://<watto host>/api/dust_collector` and `WATTO_TOKEN` to the same value.

If `DUST_COLLECTOR_TOKEN` isn't set, every POST is rejected with 401.
