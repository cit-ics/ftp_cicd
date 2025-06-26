### step 1: extract .deploy.zip on project root folder

### step 2: make executable onetime
```
chmod +x .deploy/activate.sh
```
Here is the full content for your `README.md` file, ready to be created in your project root:

---

### ✅ `README.md`

```markdown
# 🚀 Deployment Activation System

This project includes a Bash script `.deploy/activate_deployment.sh` that automates the setup of your development and deployment environment.

---

## 📂 What It Does

This activation script prepares your Laravel or Node.js-based project for deployment by:

1. Validating your configuration.
2. Creating useful ignore files.
3. Setting up a post-deploy shell script.
4. Making deploy-related scripts executable.
5. Updating your `package.json` with deploy commands.
6. Ensuring SSH access is configured.
7. Installing required system and npm tools.

---

## 🧭 Step-by-Step Breakdown

### ✅ 1. Validate Configuration

- Looks for `.deploy/config.json` in the project root.
- Parses the following required fields:
  - `vps.ip`
  - `vps.user`
  - `vps.email`
  - `vps.ssh`

🔴 If any of these are missing, the script exits.

---

### ✅ 2. Create Ignore Files

The following two files are created or updated:

- `.modify_track_ignore` – for tracking changes.
- `.zip_ignore` – for packaging deployment ZIPs.

Default entries added:

#### `.modify_track_ignore`
```

/storage
/vendor
/node\_modules
/bootstrap/cache
/.deploy

```

#### `.zip_ignore`
```

.deploy/
.git\*
node\_modules/\*
.env

````

---

### ✅ 3. Create `after_deploy_commands.sh`

A script is created at the root path that will run **after your project is deployed to the VPS**.

It does the following:
- Increments `APP_VERSION` in the `.env` file.
- Clears Laravel cache using:
  ```bash
  php artisan optimize:clear
````

This script will automatically be executed on the server post-deployment.

---

### ✅ 4. Make Deployment Scripts Executable

The script marks these files as executable:

* `.deploy/ftp/ftp_modified_upload.sh`
* `.deploy/ftp/ftp_zip_upload.sh`
* `.deploy/project_changes_tracker/tracker.sh`
* `.deploy/vps/deploy_modified_into_vps.sh`
* `.deploy/vps/deploy_zip_into_vps.sh`

---

### ✅ 5. Update `package.json` Scripts

The script updates your `package.json` by adding:

```json
"type": "module",
"scripts": {
  "track": "sh .deploy/project_changes_tracker/tracker.sh",
  "vps_modified_deploy": "sh .deploy/vps/deploy_modified_into_vps.sh",
  "vps_zip_deploy": "sh .deploy/vps/deploy_zip_into_vps.sh",
  "ftp_zip_deploy": "sh .deploy/ftp/ftp_zip_upload.sh",
  "ftp_modified_deploy": "sh .deploy/ftp/ftp_modified_upload.sh"
}
```

✅ You can now run deploy commands via:

```bash
npm run vps_modified_deploy
npm run ftp_zip_deploy
```

---

### ✅ 6. Setup SSH Keys

* Checks if the SSH key (defined in `config.json`) exists.
* If not, generates a new key using:

  ```bash
  ssh-keygen -t rsa -b 4096 -C "<email>"
  ```
* Uses `ssh-copy-id` to add the key to your VPS.

---

### ✅ 7. Install Required Tools

Installs these via `apt` and `npm`:

* `jq` (JSON processor)
* `inotify-tools` (for file change detection)
* `chokidar-cli` (Node.js file watcher)

---

## ⚙️ Configuration File Format

Create `.deploy/config.json` like this:

```json
{
  "ftp": {
    "host": "ftp.example.com",
    "user": "ftp_user",
    "pass": "ftp_password",
    "dir": "/"
  },
  "vps": {
    "ip": "123.45.67.89",
    "user": "root",
    "dir": "/var/www/project",
    "ssh": ".ssh/id_rsa",
    "email": "your_email@example.com"
  }
}
```

---

## ▶️ To Run the Script

```bash
sh .deploy/activate_deployment.sh
```

---

## 🧪 After Setup

You can now run these commands for deployment:

```bash
npm run track
npm run vps_modified_deploy
npm run vps_zip_deploy
npm run ftp_modified_deploy
npm run ftp_zip_deploy
```

---

## 🆘 Need Help?

Feel free to open an issue or reach out to the maintainer if you need assistance with configuration or deployment.

````

---

### ✅ To save it automatically from your shell script

You can include this in `activate_deployment.sh`:

```bash
cat > "$WORKSPACE_ROOT/README.md" <<'EOF'
# 🚀 Deployment Activation System
...
(full markdown from above)
...
EOF
````

