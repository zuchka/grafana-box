## grafana-box

### Introduction

Grafana Box is a collection of wrapper scripts for Terraform. Use `grafana-box.sh` to bootstrap Grafana instances on GCP virtual machines. With one command, you can build Grafana from a native package manager, a standalone binary, or from source in a fully-functioning developer environment (on any remote branch, with any version of NodeJS). 

Additionaly, you may choose between eight different Linux distributions.

`test-grafana-box.sh` is a wrapper script for larger tests. It currently only tests package-manager related issues.

## Prerequisites

* a GCP account
* `gcloud` installed and configured
    * `gcloud auth application-default` enabled
        * run `gcloud auth application-default login`
* Terraform 1.0.7 installed
* An `ssh` key pair

## Quickstart

* clone this repo and move into the project's root directory
* export the path to a public ssh key as `GRAFANA_BOX_SSH`
    * `export GRAFANA_BOX_SSH=~/.ssh/your-public-ssh-key.pub`
* Build a `grafana-box`, choosing one value from each of the following columns: 

```
./grafana-box -d <DISTRO> -w <WORKFLOW>
```
|DISTRO (-d)|WORKFLOW (-w)|CPU (-a) (optional) (no args) (default=Intel)|NODE (-n)  (optional) (devenv only)|DATA (TK)  (optional) (devenv only)|
|---|---|---|---|---|
|`ubuntu-2004-lts `  |`package` (build from native package manager)  |`-a` (no args) = AMD   |use any valid `nvm` pattern. browse list here   |   |
|`ubuntu-1804-lts`   |`7.5.1` (use `x.x.x` pattern for binary)   |   |   |   |
|`debian-11`   |`devenv` (builds from `main`) |   |   |   |
|`debian-10`   |`devenv-foo/bar` (builds from remote branch `foo/bar`)      |   |   |   |
|`centos-8`   |   |   |   |   |
|`centos-stream-8`   |   |   |   |   |
|`centos-7`   |   |   |   |   |
|`rocky-linux-8`   |   |   |   |   |


Here are some example commands:

Build Grafana on Ubuntu 20.04 using `apt`:

`./grafana-box.sh -d ubuntu-2004-lts -w package`

Build a Grafana Developer Environment from `main` on Rocky Linux 8 using AMD processors:

`./grafana-box.sh -d rocky-linux-8 -w devenv -a`

Build a Grafana Developer Environment from remote branch `foo/bar` using NodeJS version `15.16.0` on Debian 10

`./grafana-box.sh -d debian-10 -w devenv-foo/bar -n 15.16.0` 

Build the official Grafana version `7.5.7` standalone binary on CentOS 7:

`./grafana-box.sh -d centos-7 -w 7.5.7 -a`

## accessing your `grafana-box`