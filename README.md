# NixOs Configuration flake

## Desktop Components (Yubikey-centric)

**Desktop:** [sway](https://github.com/swaywm/sway)
**Terminal:** [kitty](https://github.com/kovidgoyal/kitty)
**Shell:** [fish](https://github.com/fish-shell/fish-shell)
**Filesystem:** [btrfs](https://github.com/kdave/btrfs-devel)
**Firewall:** [opensnitch](https://github.com/evilsocket/opensnitch)
**Secret-Management:** [gopass](https://github.com/gopasspw/gopass)
**Features:**

- passwordless u2f_pam auth with yubikey [NixOs Wiki - Yubikey](https://nixos.wiki/wiki/Yubikey)
- luks fido2 encrypted with yubikey (passphrase as fallback)
- secrets managed at runtime with gopass (also backed by yubikey)

## Server Components

**Shell:** [fish](https://github.com/fish-shell/fish-shell)
**Filesystem:** [bcachefs](https://bcachefs.org/)
**Firewall:** [opensnitch](https://github.com/evilsocket/opensnitch)
**Secret-Management:** [sops-nix](https://github.com/Mic92/sops-nix)

## Basic Desktop Keybindings

### Sway

**Modifier:** `Meta/Windows Key`

```
mod+d           --> App Launcher
mod+Enter       --> Terminal
mod+w           --> Tab layout
mod+Shift+Space --> Toggle floating

# Window navigation
mod+up    --> move up
mod+down  --> move down
mod+left  --> move left
mod+right --> move right
```

### Kitty

**Modifier:** `Ctrl+Shift`

```
mod+Enter --> new split pane
mod+t     --> new tab

# Window navigation
mod+up    --> move up
mod+down  --> move down
mod+left  --> move left
mod+right --> move right

# Tab navigation
mod+page_up    --> next tab
mod+page_down  --> previous tab
```

### NeoVim

**Modifier:** `Ctrl / Alt`

> Try it out with `NIXPKGS_ALLOW_UNFREE=1 nix run 'git+https:
//gitlab.n0de.biz/daniel/nix?ref=main#nvim' --impure`

```
Space + f + f --> fuzzy find files
Space + /     --> fuzzy find text
Space + e     --> open file-tree

# Window navigation
Ctrl+up    --> move up
Ctrl+down  --> move down
Ctrl+left  --> move left
Ctrl+right --> move right

# Buffer navigation
Alt+right --> next buffer
Alt+left  --> previous buffer
```

## Setup of a new desktop host

1. Grab the latest ISO and boot it on your target machine
2. Identify installation drive '/dev/sda' if just one is present
3. Run `install-system generic`
   - You will be asked which disk to use for installation
   - You will be asked to provide a password for luks
   - You will be asked if you want to add a fido2 key to luks
4. Reboot into new system and login using yubikey
5. Run `sync-repos` to initialize password keystore and nix repo
6. Navigate to `~/dev/nix` and copy template files for the new host
   - `cp -r hosts/generic hosts/<NEW_HOST>`
   - `cp home/_mixins/users/ion/hosts/generic.nix home/_mixins/users/ion/hosts/<NEW_HOST>.nix`
7. Modify `hosts/<NEW_HOST>/default.nix` according to your needs
   - Make sure to replace `CHANGE_ME` with your target disks WWN-ID
8. Commit and push
9. Run `install-system <NEW_HOST>`

## Setup a new server

1. Navigate to `~/dev/nix` and copy template files for the new host
   - `cp -r hosts/generic hosts/<NEW_HOST>`
   - `cp home/_mixins/users/ion/hosts/generic.nix home/_mixins/users/ion/hosts/<NEW_HOST>.nix`
2. Modify copied files and `flake.nix` according to your needs
   - Make sure to replace `os_disk` with your target disks WWN-ID in `flake.nix`
3. Commit and push
4. Grab latest installer ISO and boot it
5. Run `install-system <NEW_HOST>`

## Add new User

1. Navigate to `~/dev/nix` and copy template files for the new host
   - `cp -r hosts/_mixins/users/ion hosts/_mixins/users/<NEW_USER>`
   - `cp -r home/_mixins/users/ion home/_mixins/users/<NEW_USER>`
2. Modify copied files and `flake.nix` according to your needs

---

## Things to consider when forking or copying stuff

1. Change referenced ssh-keys in (grep for `cardno:13 338 635`):
   > Used for SSH auth and sudo
   - hosts/\_mixins/users/ion/default.nix
   - hosts/\_mixins/users/root/default.nix
   - home/\_mixins/users/ion/id_rsa_priv_yubikey.pub
   - hosts/\_mixins/users/nixos/default.nix
2. Update `home/_mixins/users/ion/u2f_keys`
   > Used by PAM for login and sudo
   - Get yours with `nix-shell -p pam_u2f --run 'pamu2fcfg -o "pam://$TARGET_HOST"'`
3. Add another Yubikey as backup (See below)
   > So you wont get locked out when losing a yubikey
   - luks: just enroll another yubikey with: `systemd-cryptenroll --fido2-device=auto <device>`
   - pam auth: add another yubikey to the `u2f_keys` file, `\n` seperated
   - ssh auth: add another ssh publickey to the `*.nix` files listed in step 1, also `\n` seperated

### (Backup) Yubikey Setup

- Enroll luks on all desktops with `systemd-cryptenroll --fido2-device=auto <device>`
- Generate u2f_keys with `nix-shell -p pam_u2f --run 'pamu2fcfg -o "pam://$TARGET_HOST" -n'`
- Generate ssh key with `ssh-keygen -t ed25519-sk`

## Screenshots

![Main screen](screenshots/screen.png)
![Main screen 2](screenshots/screen2.png)

**Inspired by:**

- <https://christine.website/blog/paranoid-nixos-2021-07-18/>
- <https://github.com/sdobz/nix-config>
- <https://github.com/dmadisetti/.dots>
- <https://github.com/Mic92/dotfiles>
