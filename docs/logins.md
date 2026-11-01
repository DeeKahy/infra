# Add a login

Run these on the server. Each person gets one line in `/etc/caddy/users.caddy`, with a username and a password hash. That file stays out of this repo.

Logins only apply outside the university network and the VPN. One login works for Stregsystem, Farcheology, `random` and phpMyAdmin.

## Add someone

1. Make a hash for the new password. It asks you to type the password twice:

   ```bash
   caddy hash-password
   ```

2. Back up the file, then open it:

   ```bash
   sudo cp -p /etc/caddy/users.caddy /etc/caddy/users.caddy.bak
   SUDO_EDITOR="$HOME/.local/bin/hx" sudoedit /etc/caddy/users.caddy
   ```

   `sudo hx` doesn't work, because `hx` is installed in your home folder and sudo doesn't look there. `sudoedit` runs your own `hx` on a temporary copy, then saves it back with the right owner and permissions. If you use a different editor, change the path.

3. Add a line with their username and the hash from step 1:

   ```
   newuser $2a$14$...their hash...
   ```

4. Check the config and reload. This doesn't interrupt anyone:

   ```bash
   sudo -u caddy env XDG_DATA_HOME=/var/lib/caddy XDG_CONFIG_HOME=/var/lib/caddy caddy validate --config /srv/infra/caddy/Caddyfile --adapter caddyfile
   sudo systemctl reload caddy
   ```

5. Log in once as the new user from outside the university network, for example on a phone on mobile data.

## Remove someone

Delete their line and reload Caddy.

## Good to know

- Nothing limits guessing attempts, so use a long random password. `openssl rand -base64 18` makes one.
- This login only gets someone past Caddy. Accounts in Stregsystem admin, Piwigo and phpMyAdmin are separate.
- **On Stregsystem, rooms don't ask who you are, so anyone with a login can buy on any member's account.** Only give logins to people you trust with that.
