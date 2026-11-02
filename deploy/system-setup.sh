#!/bin/bash
# The root half of provisioning, run on the server by deploy/provision.
#
# The server is shared with other Nova Labs apps, so this only adds things:
# packages, the wautils user, and files named for wautils. It never removes
# or rewrites anything belonging to another app. Safe to re-run.

set -euo pipefail

APP_USER=wautils
APP_HOST=wautils.nova-labs.org
# Extra names to serve, e.g. a temporary one for testing before moving DNS.
APP_ALIASES=${APP_ALIASES:-}
ACME_ROOT=/var/www/wautils-acme
RUBY_INSTALL_VERSION=0.10.2
RUBY_INSTALL_SHA256=65836158b8026992b2e96ed344f3d888112b2b105d0166ecb08ba3b4a0d91bf6
CHRUBY_VERSION=0.3.9
CHRUBY_SHA256=7220a96e355b8a613929881c091ca85ec809153988d7d691299e0a16806b42fd

here=$(cd "$(dirname "$0")" && pwd)

echo "==> Installing packages"
export DEBIAN_FRONTEND=noninteractive
apt-get update -q
apt-get install -y -q --no-install-recommends \
  git curl ca-certificates sqlite3 \
  build-essential autoconf bison pkg-config \
  libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses-dev \
  libffi-dev libgdbm-dev libsqlite3-dev \
  apache2 certbot

# Checks for the docs ruby-install's Makefile installs, since `ruby-install
# --version` from the 0.10.2 release still says 0.10.1.
if [ ! -d "/usr/local/share/doc/ruby-install-$RUBY_INSTALL_VERSION" ]; then
  echo "==> Installing ruby-install $RUBY_INSTALL_VERSION"
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/ruby-install.tar.gz" \
    "https://github.com/postmodern/ruby-install/releases/download/v$RUBY_INSTALL_VERSION/ruby-install-$RUBY_INSTALL_VERSION.tar.gz"
  echo "$RUBY_INSTALL_SHA256  $tmp/ruby-install.tar.gz" | sha256sum -c --quiet
  tar -xzf "$tmp/ruby-install.tar.gz" -C "$tmp"
  make -s -C "$tmp/ruby-install-$RUBY_INSTALL_VERSION" install
  rm -rf "$tmp"
fi

# Not used by the app (it gets Ruby from .env), but wautils' ~/.profile loads
# it so interactive shells pick up the right Ruby, as on srv-b.
if [ ! -f /usr/local/share/chruby/chruby.sh ]; then
  echo "==> Installing chruby $CHRUBY_VERSION"
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/chruby.tar.gz" \
    "https://github.com/postmodern/chruby/releases/download/v$CHRUBY_VERSION/chruby-$CHRUBY_VERSION.tar.gz"
  echo "$CHRUBY_SHA256  $tmp/chruby.tar.gz" | sha256sum -c --quiet
  tar -xzf "$tmp/chruby.tar.gz" -C "$tmp"
  make -s -C "$tmp/chruby-$CHRUBY_VERSION" install
  rm -rf "$tmp"
fi

if ! id "$APP_USER" >/dev/null 2>&1; then
  echo "==> Creating $APP_USER user"
  adduser --disabled-password --gecos "" "$APP_USER"
fi

echo "==> Installing the $APP_USER systemd unit"
install -m 644 "$here/wautils.service" /etc/systemd/system/wautils.service
systemctl daemon-reload
# Enabled so it comes up on boot, but not started here: the first deploy has to
# put the app in place first.
systemctl enable wautils.service

echo "==> Configuring Apache for $APP_HOST${APP_ALIASES:+ $APP_ALIASES}"
a2enmod -q proxy proxy_http headers rewrite ssl
mkdir -p "$ACME_ROOT"
if [ -n "$APP_ALIASES" ]; then
  sed "s|@ALIASES@|$APP_ALIASES|" "$here/apache.conf"
else
  sed "/@ALIASES@/d" "$here/apache.conf"
fi > /etc/apache2/sites-available/wautils.conf
a2ensite -q wautils
# Other apps share this Apache, so don't leave a broken site enabled for their
# next reload to trip over.
if ! apache2ctl configtest; then
  a2dissite -q wautils
  echo "!! Apache rejected wautils.conf, so the site is disabled again." >&2
  exit 1
fi
systemctl reload apache2

# Let's Encrypt can only verify names whose DNS already points here, so the
# certificate covers those. Re-running after a DNS change adds the new names;
# with nothing changed, certbot keeps the current certificate.
my_ips=$(hostname -I)
names=()
for name in $APP_HOST $APP_ALIASES; do
  ip=$(getent ahostsv4 "$name" | awk '{print $1; exit}')
  if [ -n "$ip" ] && tr ' ' '\n' <<<"$my_ips" | grep -qxF "$ip"; then
    names+=(-d "$name")
  else
    echo "==> $name doesn't resolve to this server yet; leaving it off the certificate"
  fi
done

if [ ${#names[@]} -eq 0 ]; then
  echo "==> Skipping TLS. After pointing DNS here, re-run deploy/provision."
else
  echo "==> Getting a TLS certificate"
  if [ -n "${CERTBOT_EMAIL:-}" ]; then
    contact=(-m "$CERTBOT_EMAIL")
  else
    contact=(--register-unsafely-without-email)
  fi
  # A failure here (e.g. port 80 firewalled) shouldn't stop the rest of
  # provisioning; the site just stays on plain HTTP until a re-run succeeds.
  if certbot certonly --webroot -w "$ACME_ROOT" --cert-name wautils "${names[@]}" \
    --non-interactive --agree-tos --keep-until-expiring --expand "${contact[@]}" \
    --deploy-hook "systemctl reload apache2"; then
    # Picks up a first certificate (apache.conf only enables HTTPS once it exists).
    systemctl reload apache2
  else
    echo "!! Couldn't get a TLS certificate (see above). Fix that, then re-run deploy/provision." >&2
  fi
fi
