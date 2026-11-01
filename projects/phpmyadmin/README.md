# phpMyAdmin

Web page for looking at and editing the MySQL databases, at `https://lists.fklub.dk/phpmyadmin/`. It is only reachable from the university network and the VPN.

**Lennart doesn't know why we still run this, and would like to just shut it down if we don't use it.** The logs showed some use from `10.27.x`, but he doesn't know who that is. Everything it does also works over SSH with `sudo mysql --defaults-file=/etc/mysql/debian.cnf`. To turn it off with `sudo docker compose down` here, and remove its block from the Caddyfile and the proxy lines from `mailman-le-ssl.conf`.

## How it works

- It runs the official image in Docker, and needs a pinned version with patched PHP. Check `php -v` in the image before updating.
- It reaches MySQL through the socket at `/var/run/mysqld/mysqld.sock`. There are no stored database passwords. You log in with your own MySQL account.
- Apache sends `/phpmyadmin` to Caddy, which checks the address and sends it to port `8091`.
- The old `phpmyadmin` database is from the 4.x version and isn't connected. It has 2 bookmarks and 2 user settings.

## Update

Change the image version in `compose.yml`, then run `sudo docker compose up -d` here.
