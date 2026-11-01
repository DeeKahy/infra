# F-Klubben's Infrastructure

How the F-klubben server is set up. If you are new, start here.

This repo is public, so it must never contain passwords, keys or member data.

## How it runs

Every project is a systemd service, unless it needs software the OS can't provide. Then it runs in Docker with Compose.

```
Internet -> Caddy on 80/443 (TLS and certificates)
              -> a static folder, or a service on 127.0.0.1 or a unix socket
              -> Apache on 127.0.0.1:8888, only for Mailman
```

Apache only remains for Mailman 2's CGI scripts. It goes away once the lists have moved to Mailman 3.

On the server, this repo is cloned to `/srv/infra`. Update it with `sudo git -C /srv/infra pull`.

## What runs where

| Service                          | URL                                                                         | Runs as                                                                                                | Config                                                                            | Data                                 | Owner |
|----------------------------------|-----------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|--------------------------------------|-------|
| Caddy                            |                                                                             | systemd `caddy`                                                                                        | `caddy/Caddyfile`                                                                 |                                      | ?     |
| Static sites                     | `bread`, `docs`, `facking`, `fappen`, `messe`, `okboomer`, `static`, `test` | Served by Caddy                                                                                        | `caddy/Caddyfile`                                                                 | `/srv/static/<site>/`                | ?     |
| Coffee                           | `coffee.fklub.dk`                                                           | systemd `coffee`, pages served by Caddy                                                                | `host/systemd/coffee.service`, `caddy/Caddyfile`                                  | `/srv/coffee/`                       | ?     |
| Stregsystem API docs             | `api.stregsystem.fklub.dk`                                                  | Served by Caddy                                                                                        | `caddy/Caddyfile`                                                                 | `/data/stregsystem/openapi/out`      | ?     |
| Fiki (DokuWiki)                  | `fklub.dk`                                                                  | Docker `dokuwiki`, behind Caddy                                                                        | `projects/dokuwiki/compose.yml`, `caddy/Caddyfile`                                | `/srv/dokuwiki/`                     | ?     |
| Stregsystem                      | `stregsystem.fklub.dk`                                                      | systemd `stregsystem`, behind Caddy                                                                    | `host/systemd/stregsystem.service`, `caddy/Caddyfile`, allowlist in `/etc/caddy/` | `/data/stregsystem/`                 | ?     |
| Mailman 2                        | `lists.fklub.dk`                                                            | Host package, through Apache                                                                           | `/etc/mailman`, `/etc/apache2`                                                    | `/var/lib/mailman/`                  | ?     |
| Piwigo                           | `farcheology.fklub.dk`                                                      | Docker `piwigo`, behind Caddy                                                                          | `projects/piwigo/`, `caddy/Caddyfile`                                             | `/srv/piwigo/`, database `piwigo_16` | ?     |
| Random image                     | `random.fklub.dk`                                                           | Docker `random`, behind Caddy                                                                          | `projects/random/compose.yml`, `caddy/Caddyfile`, allowlist in `/etc/apache2`     | `/srv/random/`                       | ?     |
| MySQL                            | Local only                                                                  | Host package                                                                                           | `/etc/mysql`                                                                      |                                      | ?     |
| phpMyAdmin                       | `lists.fklub.dk/phpmyadmin/`                                                | Docker `phpmyadmin`, behind Caddy. [Lennart would like to shut it down](projects/phpmyadmin/README.md) | `projects/phpmyadmin/`, `caddy/Caddyfile`                                         |                                      | ?     |
| Mail (Postfix, amavis, OpenDKIM) |                                                                             | Host packages                                                                                          | `/etc/postfix`                                                                    | `/var/mail/`                         | ?     |

## Caddy

```sh
systemctl status caddy
journalctl -u caddy
caddy validate --config /srv/infra/caddy/Caddyfile --adapter caddyfile
sudo systemctl reload caddy
```

## Access from outside

Stregsystem, Farcheology, `random` and phpMyAdmin need no login on the university network or the VPN. Everyone else gets a login from `/etc/caddy/users.caddy`, which is outside this repo.

The wiki, the small static sites and Mailman are public.

Stregsystem also has an allowlist in `/etc/caddy/stregsystem-allowlist.caddy`, outside this repo because it lists people's homes. To skip the login for an address, uncomment or add its `client_ip` line, then run `sudo systemctl reload caddy`.

Closed rooms are listed in `stregsystem_site` in `caddy/Caddyfile`. To open one for an occasion, remove it from that list and reload Caddy.

## Add a static site

1. Put the files in `/srv/static/<site>/`.
2. Add a block to `caddy/Caddyfile` and commit it.
3. Point the hostname's DNS at the server. Caddy gets the certificate by itself.
4. On the server, pull this repo, then run `sudo systemctl reload caddy`.
