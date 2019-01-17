# VPN

The system is prepared to work with vpnc client (Cisco Concentrator) and OpenVPN (NordVPN).

## Setup

### 1. Cisco Concentrator

Please install the package `net-vpn/vpnc`. Please find more information in the [Gentoo Wiki](https://wiki.gentoo.org/wiki/Vpnc).

### 2. NordVPN

For convenience, you should use the [openpyn-nordvpn](https://github.com/jotyGill/openpyn-nordvpn).

Install the tool with the following commands. This will install the application in the homer directory of `root` (most likely `/root`).

```bash
git clone https://github.com/jotyGill/openpyn-nordvpn.git
cd openpyn-nordvpn && sudo -H -i python3 -m pip install --upgrade .
sudo -H -i /root/.local/bin/openpyn --init --silent
```

Append the following line to the file `/root/.bashrc`

```bash
export PATH="/root/.local/bin:$PATH"
```

### 3. VPN Service

Copy the content of the file [vpn.openrc](../../scripts/vpn/vpn.openrc) into the file `/etc/init.d/vpn`.

Copy the file [network-changed.sh](../../scripts/vpn/network-changed.sh) to `/root/bin/network-changed.sh`.

Create the file `/etc/vpn.conf` with

```bash
PROFILE="ch"
```

### 4. Kill-Switch

A kill-switch blocks any traffic when the computer gets disconnected from the VPN service to prevent any leakage of information.

There are [iptable configuration files](../../.config/iptables) for enabled kill-switch and unrestricted network usage (default firewall rules for a workstation).

Enable the VPN kill-switch

```bash
sudo iptables-restore < ~/.config/iptables/vpn-kill.ipv4.rules
sudo iptables-restore < ~/.config/iptables/vpn-kill.ipv6rules
```

Revert to the default firewall rules

```bash
sudo iptables-restore < ~/.config/iptables/default.ipv4.rules
sudo iptables-restore < ~/.config/iptables/default.ipv6.rules
```

## Usage

### Specify VPN Profile

You can specify the profile to use for the VPN connection in `/etc/vpn.conf` with the variable `PROFILE`.

| Profile           | Description                                                 |
|-------------------|-------------------------------------------------------------|
| eth               | Connects to the VPN Service of ETH Zürich.                  |
| netflix           | Connects to best performing Netflix capable NordVPN server. |
| \<country-code>   | Connects to the fastest NordVPN server of the given country.|
| \<nordvpn-server> | Connects to a specific NordVPN server.                      |

### Start/restart/stop the VPN Service

Start the service

```bash
sudo /etc/init.d/vpn start
```

Restart the service

```bash
sudo /etc/init.d/vpn restart
```

Stop the service

```bash
sudo /etc/init.d/vpn stop
```

### Change Firewall Configuration

In the dotfiles configuration, there are aliasses specified to switch on/off the VPN kill-switch.

Enable the kill-switch with `network-vpn-only`

Disable the kill-switch with `network-unrestricted`
