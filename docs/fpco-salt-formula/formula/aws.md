## AWS Formula

### `aws.cli.config`

The `aws.cli.config` formula automates management of one or more profiles in the
`~/.aws/config` and `~/.aws/credentials` files, for one or more users who wish
to use the AWS command line utilities on a linux host. All information is
sourced from the `aws_users` key in salt pillar, so the formula can be used with
the rest of one's own automation stack. The formula supports configuring the
`aws_access_key_id`, `aws_secret_access_key`, `region` and `output` parameters
within those two files.


#### Supported Pillar

```
aws_users:
  <username>:
    profiles:
      <profile_name>:
        access: AWS_ACCESS_KEY_ID
	secret: AWS_SECRET_ACCESS_KEY
	output: <text|json|table>
	region: AWS_REGION
```

In other words, the formula supports managing AWS credentials and config in
multiple profiles for multiple users, including the root user.

For example:

```
aws_users:
  root:
    profiles:
      default:
        access: FOO
	secret: FOOBAR
	output: json
	region: us-west-1
      profile2:
        access: FOO
	secret: FOOBAR
	output: json
	region: us-west-1
  foobar:
    profiles:
      my_profile:
        access: FOOBAR
	...
```


### `aws.cli.install`

Use the `pip.installed` salt state to install the `aws-cli` python package.


### `aws.ecs-agent`

Install and run the ECS linux host agent as a docker container. Note, this
formula could be documented in more detail.
