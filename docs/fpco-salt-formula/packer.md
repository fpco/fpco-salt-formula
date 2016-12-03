## Install Packer

[Packer](https://www.packer.io/) is a tool for creating machine and container
images for multiple platforms and providers.


### `packer`

Install the release specified in pillar by unpacking the release archive into
`/usr/local/bin/packer-{{ version }}/` and setting up a symlink from
`/usr/local/bin/packer` to `/usr/local/bin/packer-{{ version }}/packer`. In
addition, mode `755` is recursed on all files and directories unpacked, which
ensures the path and binaries are both visiable and executable to all users on
the host. The checksum for the release archive is looked up in pillar, with the
map of checksums defined in `packer/checksum_map.jinja` as a default. The
`version` pillar key (the default is noted below) is used as a key to lookup
the checksum from that map.


#### Pillar Supported

Within the `packer` pillar key, the follow keys are supported:

| Pillar Key | Default                | Required | Notes                            |
| ---------- | ---------------------- |:--------:| -------------------------------- |
| `version`  | see `default_version`  | N | version of packer to install            |
| `checksum` | see `default_checksum` | N | the sha512 sum of the release archive   |
| `base_url` | see `default_base_url` | N | URL where the release archive is hosted |


#### Defaults

The following keys are hard-coded defaults used int he formula:

| Key                | Value                            | Notes                                               |
| ------------------ | -------------------------------- | --------------------------------------------------- |
| `default_version`  | `0.7.5`                          | Version of the release to install                   |
| `default_checksum` | `packer_checksum_map[version]`   | See `packer/checksum_map.jinja`                     |
| `default_base_url` | `https://releases.hashicorp.com` | Retrieve the release archive from this URL          |
| `app`              | `packer`                         | Used to construct the URLs and paths in the formula |
| `release_archive`  | `app ~ '_' ~ version ~ '_linux_amd64.zip'` |                                           |
| `release_url`      | `base_url ~ '/' ~ app ~ '/' ~ version ~ '/' ~ release_archive` |                       |
| `bin_path`         | `'/usr/local/bin/' ~ app`        |                                                     |

