# Installing VPS Server

## Requirements

You have to have these program :

On your computer :

- SSH  (`ssh --version`)
- SSH COPY ID (`ssh-copy-id -h`)

On your server

- Make (`make --version`) (apt install make)
- SSH  (`ssh --version`)
- Git (`git --version`) (apt install git)

Clone the project on your server

## Install zsh (optional)

- Install `zsh`

```shell
apt install git-core zsh -y
```

- Install `oh-my-zsh`

```shell
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

- Change default to zsh

```shell
chsh -s $(which zsh)
```

- Install powerline font

```shell
apt install fonts-powerline -y
```

- Install Power10k

```shell
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>! ~/.zshrc
```

- Install productivity plugins

Zsh syntax hightlighting

```shell
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

Install Zsh syntax autosuggestions

```shell
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

Configuration previous installed plugins

```zshrc
plugins=(
   git
   zsh-autosuggestions
   zsh-syntax-highlighting
)
```

Install Fzf

```shell
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
```

[Reference](https://askubuntu.com/questions/521469/oh-my-zsh-for-the-root-and-for-all-user)

## Configure your server

### Change root user password

> When a distribution is installed, a password is automatically created for the administrator (root). It is highly recommended to modify it for security reasons.

```shell
passwd root
```

The system will then ask to enter a new password twice to validate it. As a security measure, it will not appear when writing. You will not be able to see the characters entered. It is very important to use a strong password.

> **NOTE**: A strong password is greater than 8 characters. It must combine lowercase, uppercase letters, numbers, special characters and/or accented letters. But also avoided using dictionary words, first/last names, company name, user name... The deliberate use of spelling errors is a good way to easily secure a password.

### Create deployment user

> **NOTE**: The root administrator is created by default on UNIX systems, it is the user who has the most rights on your system. It is not advisable, even dangerous to leave your VPS accessible only via this user, the latter being able to perform irreversible operations on your server.

We will therefore create a user with restricted access to perform current tasks.

```shell
adduser deployer
```

Enter a secure password and press `ENTER` for each question to pass and validate the information with `Y`.

Then give root rights to the new user.

```shell
visudo
```

The command below leads us to the `/etc/sudoers.tmp` file where we can view the following code

```shell
# User privilege specification
root    ALL=(ALL:ALL) ALL
```

After the root user line, you’ll add in your new user with the same format for us to grant admin privledges.

```shell
deployer    ALL=(ALL:ALL)ALL
```

Of course change `user` by your own user you created before

Commands requiring administrator rights will be preceded by the `sudo` keyword and the user’s password will then be requested.

If you want user to be not prompted for password, run this :

```shell
deployer    ALL=(ALL) NOPASSWD:ALL
```

Restart your server

```shell
shutdown -r now
```

or

```shell
sudo /sbin/reboot
```

### Setup VPS ssh authentication with new user

- Generate ssh key on your computer. If you already have one go to next part

```shell
ssh-keygen -t rsa -b 4096 -o -a 100
```

Next, create a passphrase (Password) or press ENTER to not use it.

> **NOTE**: If you do not use a passphrase, you will be able to connect to the server without entering a password. It is advisable to use a passphrase, although not using one is always more secure than traditional password authentication.

This generates two files: id_rsa (private key), and id_rsa.pub (public key), in the folder . ssh of the current user directory. Remember that the **private key must not be opt**.

- Copy your generated public key to server

```shell
ssh-copy-id -i ~/.ssh/id_rsa.pub <deployer>@<ip-address>
```

### Login new user

```shell
ssh <deployer>@<ip-address>
```

During the first connection, a confirmation message will appear to add the host fingerprint to the `~/. ssh/known_hosts` file

```shell
The authenticity of host 'vps... (192.89.11.121)' can't be established.
ECDSA key fingerprint is SHA256:*******************************************.
Are you sure you want to continue connecting (yes/no)? yes
```

Enter `yes` and press `ENTER` to log in.

## Security

### Use the SSH key to connect to the new user

Open a new terminal window and use `ssh-copy-id`.

```shell
ssh-copy-id <deployer>@<ip-address>
```

### SSH setup

```shell
vi /etc/ssh/sshd_config
```

### Change ssh default port

To see the ports used

```shell
sudo apt install net-tools
```

```shell
netstat -nat | grep LISTEN
```

Most of the attacks your server will receive will come from robots targeting the default SSH port (port 22). Changing the listening port will make it harder for them and make your server harder to reach.

```shell
Port <your-new-ssh-port>
```

> **NOTE**: Keep the port number below 1024 as these are privileged ports that can only be opened by the administrator or by processes running as an administrator.

### Cancel login as root

```sshd_config
PermitRootLogin no
```

### Restart ssh agent

```sshd_config
sudo /etc/init.d/ssh reload
```

or

```ssh
sudo service ssh restart
```

Logout and login with new user

```shell
ssh <deployer>@<ip-address> -p <new-port>
```

From now on, commands requiring root rights will be preceded by the `sudo` keyword.

The user’s password will then be asked.

If you ever need to access the root user, use the command:

```shell
su root
```

```shell
su <deployer>
```

But you can use either root user or the new created user for the rest of the tutorial.

## Install Docker and DockerCompose

- Create working directory where all user can access, ex.

```shell
mkdir -p /opt/setup
```

- Clone this repository then run

```shell
make install
```

If you would like to use Docker as a non-root user, you should now consider
adding your user to the "docker" group with something like

```shell
sudo usermod -aG docker <deployer>
```

## Firewall - Using UFW

### Installing UFW

```shell
sudo apt-get install ufw
```

### Configuring Security Policies

> Security policies applied by the firewall on your server depend on your needs and the applications you use.
> The most secure configuration is to block all traffic, inbound and outbound by default and to allow ports on a a case by case policy.
> In this tutorial a policy will be configured that blocks inbound packets and authorizes outbound traffic by default.

1 . Start by defining the policy, that refuses everything by default:

```shell
sudo ufw default deny
```

### Establishing rules

> To define rules, you have to know which services are running on the server and which are their associtated ports.
> In this example, a SSH server, HTTP(S) and a DNS server are running on the machine.
> Every known protocol uses an associated port from the [Well Known Ports list](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers).
> The services running on the machine, used in this example have need for the following ports:

- Port 22 / TCP for SSH
- Port 80 / TCP for HTTP
- Port 443 / TCP for HTTPS
- Port 53 / TCP & UDP for DNS

```shell
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
```

Change `22` by your `new ssh port`

Active the new rules

```shell
sudo ufw enable
```

Verify the configuration

```shell
sudo ufw status numbered
```

Note:
**If you've already set a custom number port for SSH connection do not forget to allow it, otherwise you will be not able to login 😅**

## Useful commands

List Hardware

```shell
sudo lshw -short
```

## References

- [ZSH power10k](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k)
- [Hostinger](https://www.hostinger.com/tutorials/getting-started-with-vps-hosting)
- [Medium](https://medium.com/sebbossoutrot/installation-et-configuration-dun-vps-sur-ovh-avec-debian9-wordpress-et-ssl-810603968b71)
- [Install OVH on VPS](https://gist.github.com/tattali/58564a8c7233098fd207bcf42ed14821)
- [Grant administrator rights](https://www.liquidweb.com/kb/add-user-grant-root-privileges-ubuntu-18-04/)
- [More productive with ZSH](https://medium.com/@ivanaugustobd/your-terminal-can-be-much-much-more-productive-5256424658e8)
- [Configure Firewall](https://www.scaleway.com/en/docs/configure-ufw-firewall-on-ubuntu-bionic-beaver/)
- [Linux sudo without password](https://www.cyberciti.biz/faq/linux-unix-running-sudo-command-without-a-password/)
