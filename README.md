# Installing VPS Server

1. Install zsh
2. Setup server connection
3. Install docker and docker-compose
4. Create deployer user
5. Security

Clone the project on your server

## Requirements

You have to have these program :

On your computer :

- SSH  (`ssh --version`)
- SSH COPY ID (`ssh-copy-id -h`)

On your server

- Make (`make --version`)
- SSH  (`ssh --version`)

## Setup VPS ssh authentication

Generate ssh key on your computer. If you have one go to next part

```shell
ssh-keygen -t rsa -b 4096 -o -a 100
```

Next, create a passphrase (Password) or press ENTER to not use it.

> **NOTE**: If you do not use a passphrase, you will be able to connect to the server without entering a password. It is advisable to use a passphrase, although not using one is always more secure than traditional password authentication.

This generates two files: id_rsa (private key), and id_rsa.pub (public key), in the folder . ssh of the current user directory. Remember that the **private key must not be shared**.

Copy your generated public key to server

```shell
ssh-copy-id ~/.ssh/id_rsa.pub <user>@<ip-address>
```

## Connect to your VPS

```shell
ssh <user>@<ip-address>
```

During the first connection, a confirmation message will appear to add the host fingerprint to the `~/. ssh/known_hosts` file

```shell
The authenticity of host 'vps... (192.89.11.121)' can't be established.
ECDSA key fingerprint is SHA256:*******************************************.
Are you sure you want to continue connecting (yes/no)? yes
```

Enter `yes` and press `ENTER` to log in.

## Secure server

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
adduser user
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
user    ALL=(ALL:ALL)ALL
```

Of course change `user` by your own user you created before

Commands requiring administrator rights will be preceded by the `sudo` keyword and the user’s password will then be requested.

Restart your server

```shell
shutdown -r now
```

## Use the SSH key to connect to the new user

Open a new terminal window and use `ssh-copy-id`.

```shell
ssh-copy-id <user>@<ip-address>
```

### SSH setup

```shell
nano /etc/ssh/sshd_config
```

### Change ssh default port

To see the ports used

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
/etc/init.d/ssh reload
```

or

```ssh
service ssh restart
```

Logout and login with new user

```shell
ssh <user>@<ip-address> -p <new-port>
```

From now on, commands requiring root rights will be preceded by the `sudo` keyword.

The user’s password will then be asked.

If you ever need to access the root user, use the command:

```shell
su root
```

```shell
su <user>
```

But you can use either root user or the new created user for the rest of the tutorial.

## Install Docker and DockerCompose

```shell
make install
```

## Firewall - Using UFW

## References

- [Hostinger](https://www.hostinger.com/tutorials/getting-started-with-vps-hosting)
- [Medium](https://medium.com/sebbossoutrot/installation-et-configuration-dun-vps-sur-ovh-avec-debian9-wordpress-et-ssl-810603968b71)
- [Install OVH on VPS](https://gist.github.com/tattali/58564a8c7233098fd207bcf42ed14821)
- [Grant administrator rights](https://www.liquidweb.com/kb/add-user-grant-root-privileges-ubuntu-18-04/)
