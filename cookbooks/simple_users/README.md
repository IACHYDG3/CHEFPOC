# Simple_Users cookbook
# Scope:
 Chef cookbook to manage users.
## Supported Platforms:

- Ubuntu 16.04 (tested with Kitchen)
- Ubuntu 14.04 was **not tested** however no ubuntu 16.04-specific commands are used here so it will probably work.
- CentOS 7 (tested with Kitchen)
- Redhat 7 (tested with Kitchen)

# USAGE:
- Set 'simple_users' as one of your dependencies
- Include simple_users::default in any of your recipes, roles or environments.

## Add Users:
Add a block to the default attribute containing each of the following to create a user:
-  name - Username.
-  fullName - Full name of your new user (may contain spaces).
-  passHash - Shadow-file hash of the desired password. The hash can be generated with the following commands: 

```bash
openssl passwd -1 -salt xyz  yourpass
```
```bash
makepasswd --clearfrom=- --crypt-md5 <<< YourPass
```
-  sshPubKey - ssh public key string to add to ~/.ssh/authorized_keys
-  action - create
-  sudo - yes/no. Adding/removing the user from the sudoers file.

### Example of the default attribute file:
```ruby
default['simple_users']['users'] = [
	{
		'name' => 'usernam01',
		'fullName' => 'User01 Name',
		'passHash' => 'A_Long_HASH_String...',
		'sshPubKey' => 'ssh-rsa YourSSHPublicKey...',
		'myAction' => 'create',
		'sudo' => 'yes'
	},
	{
		'name' => 'usernam02',
		'fullName' => 'User02 Name',
		'passHash' => 'A_Long_HASH_String...',
		'sshPubKey' => 'ssh-rsa YourSSHPublicKey...',
		'myAction' => 'create',
		'sudo' => 'no'
	}
]
```

## Remove Users:
 Add all the entries as mentioned above but put "remove" as the value of  **myAction**.
```ruby
	{
		'name' => 'usernam03',
		'fullName' => 'User03 Name',
		'passHash' => 'A_Long_HASH_String...',
		'sshPubKey' => 'ssh-rsa YourSSHPublicKey...',
		'myAction' => 'remove'
	}
```
## Removing Users from Sudoers
  Put 'no' in the 'sudo' section of your user.

Note that the above **must be** a part of the same  ``` default['simple_users']['users'] ``` array.
