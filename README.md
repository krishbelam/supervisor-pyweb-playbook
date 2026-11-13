# supervisor-pyweb-playbook

Run a Python web stack under **Supervisor** on a plain Linux server: **nginx → Gunicorn (Django, Flask or FastAPI) → optional React frontend**. Includes ready-to-edit configs, an interactive guide, and a safe uninstall script.

Supervisor keeps any long-running command alive, so nothing here is tied to one framework.

## What's inside

| Path | Purpose |
|---|---|
| `docs/index.html` | Interactive playbook: setup steps, annotated configs, command cheat sheet, deploy and uninstall guides |
| `conf.d/nginx.conf` | nginx in the foreground under supervisor |
| `conf.d/gunicorn-wsgi.conf` | Django or Flask (WSGI) |
| `conf.d/gunicorn-asgi.conf` | FastAPI (ASGI) via Gunicorn + Uvicorn workers |
| `conf.d/react.conf` | Optional: serve a built React app |
| `examples/nginx-site.conf` | nginx site proxying to the Gunicorn socket and `serve` |
| `scripts/uninstall.sh` | Stop and remove the programs (optionally supervisor itself) |

## Quick start

```bash
sudo apt update && sudo apt install supervisor -y

# stop the systemd nginx so supervisor can own port 80
sudo systemctl stop nginx && sudo systemctl disable nginx

# copy only what you need, then edit the CHANGE lines
# (use gunicorn-wsgi.conf OR gunicorn-asgi.conf, saved as gunicorn.conf)
sudo cp conf.d/nginx.conf /etc/supervisor/conf.d/nginx.conf
sudo cp conf.d/gunicorn-wsgi.conf /etc/supervisor/conf.d/gunicorn.conf
sudo cp conf.d/react.conf /etc/supervisor/conf.d/react.conf   # optional

sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl status
```

## Which Gunicorn config?

| Framework | Type | Config | App module example |
|---|---|---|---|
| Django | WSGI | `gunicorn-wsgi.conf` | `myproject.wsgi:application` |
| Flask | WSGI | `gunicorn-wsgi.conf` | `app:app` |
| FastAPI | ASGI | `gunicorn-asgi.conf` (`pip install gunicorn uvicorn`) | `main:app` |

## Daily commands

```bash
sudo supervisorctl status
sudo supervisorctl restart gunicorn:*      # after code changes (needed with --preload)
sudo nginx -t && sudo supervisorctl signal HUP nginx:*   # reload nginx config
sudo supervisorctl tail -f gunicorn:* stderr
sudo supervisorctl reread && sudo supervisorctl update   # after editing a .conf
```

## Good to know

- `process_name` with `%(process_num)02d` makes processes named like `gunicorn:gunicorn_00`. Use `group:*` to be safe.
- `numprocs` is how many copies supervisor runs. It is unrelated to nginx worker processes.
- With `--preload`, a HUP reload does not load new code. Restart instead.
- Supervisor has a minimal `PATH`: use full paths in `command` (for example the output of `which serve`).
- Editing a `.conf` needs `reread` and `update`. `restart` alone does not re-read it.

## Uninstall

```bash
sudo ./scripts/uninstall.sh                      # remove this project's programs
sudo ./scripts/uninstall.sh --purge-supervisor   # also remove supervisor (affects ALL projects)
```

The script leaves logs, sockets, nginx and your code alone. The playbook's Uninstall tab covers those.

## Interactive guide

Open `docs/index.html` in a browser, or enable **GitHub Pages** (Settings → Pages → deploy from `main`, folder `/docs`).

## License

MIT
