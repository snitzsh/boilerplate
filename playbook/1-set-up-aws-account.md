# Set up AWS account in machine

User must be root to be able to create users created in the console.

## Root User

- Create an Access Key with cli access
- Copy the `ACCESS_KEY_ID` and `SECRET_ACCESS_KEY` manually in AWS.
- Copy/Paste those keys in `~/.aws/credentials`
- Set some aws configuration in `~/.aws/config`. Make sure you set the output as json.

## Root create user (in progress...)

- Run this command to create the user:

```bash
  bash main.sh create-aws-user
```

## New User (non-root)

- Check email and to set up account.
- Create an Access Key with cli access
- Copy/Paste those keys in `~/.aws/credentials`
- Set some aws configuration in `~/.aws/config`. Make sure you set the output as json.

## AWS user must have access to

- secretsnamanager [READ, LIST, CREATE]

## TODO

- Create a cmd to support the creation of the user (other than root) and aws set up keys in `~/.aws/*`
