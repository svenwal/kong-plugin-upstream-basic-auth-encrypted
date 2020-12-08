# Kong Plugin for Basic Auth to the upstream with encrypted storage of password

This [Kong](https://konghq.com) provides the ability to connect to a backend which needs some basic auth credentials to be accessed being sent.

The basix use case can be achieved also with the request transformer plugins but the downside of that approach is the password being stored in clear text (or base64 which is not better at all) so any database admin can read out it and get access to the backend system.

This plugin instead encrypts the password in the database and only decrypts it on the fly when sending the request upstream.

## Prerequesites

Next to [Kong](https://konghq.com) (surprise) you **must** to have a secret in a file called `/etc/kong/basic_auth_secret.txt` on **every Kong node** in your cluster with a consistent content. If the file is not their or the secret is not consistent on different nodes this plugin will fail to encrypt or decrypt.

## Configuration parameters

|FORM PARAMETER|DEFAULT|DESCRIPTION|
|:----|:------:|------:|
|config.username||The username to be sent upstream as basic auth|
|config.password||The password to be sent upstream as basic auth|
|config.encrypt_password|true|Parameter if the password shall be encrypted|

## Implementation details

Each password is encryted using SHA512 with a random salt per plugin instance.

Automated tests for use with [Kong Pongo](https://github.com/Kong/kong-pongo) have been added - try `pongo run` in the main folder.



