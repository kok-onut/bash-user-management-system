# bash-user-management-system

A terminal-based multi-user management system written entirely in Bash. Users can register, log in, manage files in their personal home directory, generate reports, and receive confirmation emails upon registration. All data is stored in CSV files.

The project is split into a `code/` folder containing all scripts, a `desktop/` folder where user home directories are created, and a `security/` folder holding credentials and session data. Both are created automatically on first run.

## Video Demo
[![Demo](https://img.youtube.com/vi/VSF4fgrFnHU/0.jpg)](https://www.youtube.com/watch?v=VSF4fgrFnHU)

```
bash/
├── code/
│   ├── main.sh              entry point and main menu loop
│   ├── inregistrare.sh      registration
│   ├── login.sh             authentication
│   ├── meniu_user.sh        user dashboard
│   ├── gestiune_fisiere.sh  file and folder operations
│   ├── operatii_csv.sh      all CSV read/write functions
│   ├── raport.sh            report generator
│   ├── greeting.sh          time-aware greeting
│   └── email.sh             optional confirmation email (disabled by default)
├── desktop/                 user home directories
└── security/
    ├── users.csv
    ├── login_history.csv
    └── online.csv
```

## Features

- **Registration** — username/password validation, SHA-256 password hashing, email validation
- **Login** — 3-attempt limit, session tracking by PID, simultaneous multi-session support
- **File Management** — create, read, write, rename, and delete files and folders inside your personal home directory
- **Report Generation** — generates a `.txt` report with account info, file count, folder count, and disk usage
- **Activity Log** — every login, logout, failed attempt, and registration is logged with timestamp
- **Online Users** — see who's currently logged in and how many active sessions they have
- **Email Confirmation** — sends a confirmation email on successful registration (requires setup, see below)
- **System Reset** — wipe all users, sessions, and files from the main menu

## How It Works

Three CSV files handle all persistent data.

`users.csv` — stores registered accounts: `id, user, pass, email, data_crearii, last_login`. Passwords are hashed with SHA-256 before being written. IDs are randomly generated 6-digit numbers, collision-checked in a loop.

`login_history.csv` — append-only log: `timp, user, act, ip`. Tracked events: `INREGISTRARE`, `LOGIN`, `FAILED_LOGIN`, `BLOCKED_LOGIN`, `LOGOUT`, `ACCOUNT_DELETED`. IP defaults to `Confidential`, real logging is in the code but commented out.

`online.csv` — tracks active sessions: `user, timp, pid`. Each login writes the current shell's PID. On startup, stale rows are cleaned up by checking each PID with `kill -0`. Multiple simultaneous sessions per user are supported.

All CSV operations live in `operatii_csv.sh` and are sourced by every other script: `user_exists`, `extrage_camp`, `add_user`, `update_login`, `genereaza_id`, `set_online`, `set_offline`, `is_online`, `log_history`, `show_log`, `show_user_log`, `show_users_table`.

## User Interface

Everything is menu-driven with numbered options. The main menu shows the current date, online users, and a greeting from `@ko_bot`. After login, the dashboard is split into a file section and a system section.

File operations: view directory tree, create files (`.txt` added automatically if no extension), create folders (spaces become underscores), write with `nano`, read with `less -R`, rename, and delete (shows item count before confirming).

System operations: generate a report, view online users, view your activity log (last 30 entries), log out.

Reports are `.txt` files saved to the user's home directory — account info, file system stats (`du -sh`), and a generation timestamp. If the name is taken, the user can overwrite, rename, or cancel.

`@ko_bot` serves a different fun fact for morning, afternoon, evening, and night, picked with a `case` on the current hour.

## Prerequisites

### Required

| Tool | Purpose | Install |
|------|---------|---------|
| `bash` | run the scripts | pre-installed on Linux/macOS |
| `tree` | display file tree in user home | see below |
| `nano` | edit files from within the app | see below |
| `sha256sum` | password hashing | pre-installed on Linux |

### Optional

| Tool | Purpose |
|------|---------|
| `sendmail` / `msmtp` | registration confirmation emails |

## Installing Prerequisites

### tree

```bash
sudo apt install tree       # Debian / Ubuntu / Mint
```

On Git Bash (Windows) `tree` is usually already included. If not: `pacman -S tree` via MSYS2.

### nano

```bash
sudo apt install nano       # Debian / Ubuntu / Mint
```

### sendmail / msmtp (optional)

> It is strongly recommended to use a dedicated throwaway Gmail account — do not use your personal one.

**Step 1 — Install msmtp:**

```bash
sudo apt install msmtp msmtp-mta    # Debian / Ubuntu
```

**Step 2 — Gmail App Password + msmtp config:**

Go to [myaccount.google.com](https://myaccount.google.com) → Security → App Passwords, generate one, then add it to `~/.msmtprc`. A working config template is in `email.sh` — fill in your address and app password, then `chmod 600 ~/.msmtprc`.

**Step 3 — Enable it in the code:**

Uncomment the `source "$SCRIPT_DIR/email.sh"` line near the bottom of `inregistrare.sh`, then replace `your_mail@here.lol` in `email.sh` with your sender address.

## How to Run

**Linux / WSL**

```bash
git clone https://github.com/yourname/repo.git
cd repo
bash code/main.sh
```

**Git Bash (Windows)**

```bash
cd /c/Users/YourName/repo
bash code/main.sh
```

The script resolves all paths relative to its own location, so it works regardless of where you call it from. Always run from within `code/` or point directly to `main.sh` — do not run from inside `security/` or `desktop/`.

## Known Limitations

- `nano` opens inside the terminal 
- email sending requires manual `msmtp` setup
- No admin panel — system reset is available from the main menu and wipes all data
