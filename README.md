# F-Klubben's Infrastructure

How the F-klubben server is set up. If you are new, start here.

This repo is public, so it must never contain passwords, keys or member data.

## How it runs

Every project is a systemd service, unless it needs software the OS can't provide. Then it runs in Docker with Compose.

```
Internet -> Apache on 80/443 (TLS and certificates)
              -> Caddy on 127.0.0.1:8080, for everything already migrated
              -> the older services directly, until they move behind Caddy
```

Apache stays in front on purpose, because that lets us move services to Caddy slowly, one at a time. Once nothing depends on Apache anymore, Caddy takes over 80/443 and Apache is removed.

On the server, this repo is cloned to `/srv/infra`. Update it with `sudo git -C /srv/infra pull`.

## What runs where

| Service                          | URL                                                                         | Runs as                         | Config                                             | Data                            | Owner |
|----------------------------------|-----------------------------------------------------------------------------|---------------------------------|----------------------------------------------------|---------------------------------|-------|
| Caddy                            |                                                                             | systemd `caddy`                 | `caddy/Caddyfile`                                  |                                 | ?     |
| Static sites                     | `bread`, `docs`, `facking`, `fappen`, `messe`, `okboomer`, `static`, `test` | Served by Caddy                 | `caddy/Caddyfile`                                  | `/srv/static/<site>/`           | ?     |
| Coffee                           | `coffee.fklub.dk`                                                           | systemd `coffee`                | `/etc/systemd/system/coffee.service`               | `/home/coffee/jvm`              | ?     |
| Stregsystem API docs             | `api.stregsystem.fklub.dk`                                                  | Served by Caddy                 | `caddy/Caddyfile`                                  | `/data/stregsystem/openapi/out` | ?     |
| Fiki (DokuWiki)                  | `fklub.dk`                                                                  | Docker `dokuwiki`, behind Caddy | `projects/dokuwiki/compose.yml`, `caddy/Caddyfile` | `/srv/dokuwiki/`                | ?     |
| Stregsystem                      | `stregsystem.fklub.dk`                                                      | systemd `stregsystem`           | Not in this repo yet                               | `/data/stregsystem/`            | ?     |
| Mailman 2                        | `lists.fklub.dk`                                                            | Host package, through Apache    | `/etc/mailman`, `/etc/apache2`                     | `/var/lib/mailman/`             | ?     |
| Piwigo                           | `farcheology.fklub.dk`                                                      | Apache and PHP                  | `/etc/apache2`                                     | `/var/www/piwigo/`              | ?     |
| Random image                     | `random.fklub.dk`                                                           | Apache and PHP                  | `/etc/apache2`                                     | `/var/www/random/`              | ?     |
| MySQL                            | Local only                                                                  | Host package                    | `/etc/mysql`                                       |                                 | ?     |
| Mail (Postfix, amavis, OpenDKIM) |                                                                             | Host packages                   | `/etc/postfix`                                     | `/var/mail/`                    | ?     |

## Caddy

```sh
systemctl status caddy
journalctl -u caddy
caddy validate --config /srv/infra/caddy/Caddyfile --adapter caddyfile
sudo systemctl reload caddy
```

## Add a static site

1. Put the files in `/srv/static/<site>/`.
2. Add a block to `caddy/Caddyfile` and commit it.
3. On the server, pull this repo, then run `sudo systemctl reload caddy`.
4. Add the hostname to `ServerAlias` in Apache's `staging.conf`, add it to the certificate, and reload Apache.
