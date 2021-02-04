# General Key Operations

Here you can find some general operations you can use for your keys.

## Create temporary GnuPG Directory

```shell
export GNUPGHOME=$(mktemp -d)
```

## Import a Key

The command is the same for both public and private keys.

```shell
gpg --import keyfile.key
```

## Export a Key

Use the option `-a` for ASCII format. Otherwise, the file will be in the binary key format.

Replace `<key-id>` with one of the key's email addresses or the key fingerprint.

### Public Key

```shell
gpg --export -a <key-id> > public.key
```

### Private Key

```shell
gpg --export-secret-key -a <key-id> > private.key
```

## Delete a Key

```shell
gpg --delete-key <key-id>
```

If you want to delete your own key, the private key has to be deleted first.

```shell
gpg --delete-secret-key <key-id>
```
