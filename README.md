## grafana-box

### Introduction

Grafana Box is a collection of wrapper scripts for Terraform. You can use it to quickly test and troubleshoot platform-specific issues. 

Running `grafana-box.sh` will bootstrap an OSS or Enterprise Grafana instance on a GCP virtual machine.  With one command, you can run OSS/Enterprise Grafana from a native package manager or a standalone binary, or build Grafana from source in a fully-functioning developer environment (on any remote branch, with any version of NodeJS and any dummy (`devenv`) datasource). You can also run the official `verify-release` e2e test for Grafana (found in `/grafana/scripts`).

Additionaly, you may build your Grafana Box using eight different Linux distributions.

>\* still working on enterprise + package manager workflow

## Prerequisites

* a GCP account
* `gcloud` installed and configured
* `gcloud auth application-default` enabled
    * to enable this feature, run `gcloud auth application-default login`
    * Visit [the gcloud docs](https://cloud.google.com/sdk/gcloud/reference/auth/application-default) for more details
* Terraform 1.0.7 installed
* An `ssh` key pair

## Quickstart

* clone this repo and move into the project's root directory
* export the path to a public ssh key as `GRAFANA_BOX_SSH`
    * `export GRAFANA_BOX_SSH=~/.ssh/your-public-ssh-key.pub`
    * for ease of use, consider adding this variable to your shell's `.*_profile` 
* Build a `grafana-box`. At a minimum, you must include the `-d` and `-w` flags, each with an argument like this: 

```
./grafana-box -d <DISTRO> -w <WORKFLOW>
```

* pass the `-e` flag to install Grafana Enterprise and not Grafana OSS

## Example Commands

* Run the standalone Grafana Enterprise `8.1.5` binary on Rocky Linux 8:

```
./grafana-box.sh -d rocky-linux-8 -w 8.1.5 -e
```

* Run the newest Grafana on Ubuntu 20.04 using `apt`:

```
./grafana-box.sh -d ubuntu-2004-lts -w package
```

* Run the newest Grafana on CentOS 7 using `yum`:

```
./grafana-box.sh -d centos-7 -w package
```

* Build a Grafana developer environment from `main` on CentOS Stream 8 using AMD processors:

```
./grafana-box.sh -a -d centos-stream-8 -w devenv -a
```

* Build a Grafana Developer Environment:
    * from remote branch `christmas-2020` 
    * using NodeJS version `14.10.0`
    * using AMD processors 
    * including the MySQL and Prometheus `devenv` dummy databases
    * on Debian 10 :

```
./grafana-box.sh -a -d debian-10 -w devenv-christmas-2020 -n 14.10.0 -z mysql,prometheus
```

* Run the E2E `verify-release` test for:
    * the Grafana Enterprise `8.2.0-beta2` binary
    * against remote branch `v8.2.x`
    * using NodeJS `16.1.0`
    * on Ubuntu 18.04:

```
./grafana-box.sh -e -d ubuntu-1804-lts -w e2e-binary-v8.2.x -r 8.2.0-beta2 -n 16.1.0
```

You can reference the table below a complete list of options and combinations.

## Full Option List

||DISTRO|WORKFLOW|ENTERPRISE?|AMD?|NODE?|DATA?|RELEASE?
|---|---|---|---|---|---|---|---|
|**FLAG**|`-d`|`-w`|`-e`|`-a`|`-n`|`-z`|`-r`|
|**REQUIRED**?|yes|yes|no|no|no|no|**only** with `e2e-binary`|
|**DEFAULT VALUE**|---|---|Grafana OSS|Intel CPUs|Node 14 LTS|---|---|
|**USAGE**|`-d <distro>` |`-w <workflow>` |`-e`|`-a`|`-n <version>` |`-z <db>` |`-r <test-binary>`
|**ARGS**|browse `distro` list |browse `workflow` list |no args |no args|browse `version` list |browse `db` list | use `x.x.x` binary pattern



## Interacting with Grafana-Box

## Cleaning Up and Destroying Grafana-Box

from Grafana Box's root directory, run the following commnand:

```
./grafana-box destroy
```

This will auto-approve the destruction of all resources inside every timestamped subdirectory