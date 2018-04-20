# Usage: 
## Adding Users:
### Add a block containing each of the following to create a user:
#### name - Username.
#### fullName - Full name of your new user (may contain spaces).
#### passHash - Shadow file hash of the desired password.
#### sshPubKey - ssh public key string to add to ~/.ssh/authorized_keys
#### action - create/remove

default['simple_users']['users'] = [
	{
		'name' => 'username01',
		'fullName' => 'User Name1',
		'passHash' => '$1$xyz$ffjEtcHmdxDW9osDZvqPN0',
		'sshPubKey' => 'ssh-rsa SSHPublicKey',
		'myAction' => 'create',
		'sudo' => 'yes'
	},
	{
		'name' => 'username02',
		'fullName' => 'User Name2',
		'passHash' => 'ShadowFileHashString',
		'sshPubKey' => 'ssh-rsa SSHPublicKey',
		'myAction' => 'remove',
		'sudo' => 'no'
	},
]	
