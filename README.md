## grafana-box

### Introduction

Use `grafana-box.sh` to bootstrap Grafana on GCP Virtual Machines. With one command, you can build Grafana from a native package manager, a standalone binary, or from source in a fully-functioning developer environment (on any remote branch, with any version of NodeJS).

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
|DISTRO (-d)   |WORKFLOW (-w)   |CPU (-a) (optional) (no args) (default=Intel) |NODE (-n)  (optional) (devenv only)|DATA (TK)  (optional) (devenv only)|
|---|---|---|---|---|
|`ubuntu-2004-lts `  |`package`   |`-a` (no args) = AMD   |use any valid `nvm` pattern. browse list here   |   |
|`ubuntu-1804-lts`   |`7.5.1` (use `x.x.x` pattern for binary)   |default = Intel   |   |   |
|`debian-11`   |`devenv` (defaults to `main`. Add `-remote_branch` to build from specific branch)   |   |   |   |
|`debian-10`   |   |   |   |   |
|`centos-7`   |   |   |   |   |
|`centos-8`   |   |   |   |   |
|`centos-stream-8`   |   |   |   |   |
|`rocky-linux-8`   |   |   |   |   |

box table here

test table here


Here are some example workflows:

* `./grafana-box.sh -d ubuntu-2004-lts -w package`
* `./grafana-box.sh -d rocky-linux-8 -w devenv -a` # builds from default remote branch `main`
* `./grafana-box.sh -d rocky-linux-8 -w devenv-remote-branch-foo -a` # builds from specified remote branch `remote-branch-foo`
* `./grafana-box.sh -d centos-7 -w 7.5.7 -a`
