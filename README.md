## grafana-box

### Introduction

Grafana Box is a collection of wrapper scripts for Terraform. Use `grafana-box.sh` to bootstrap Grafana instances on GCP virtual machines. It was designed to quickly test and troubleshoot platform-specific issues. With one command, you can run Grafana from a native package manager or a standalone binary, or build Grafana from source in a fully-functioning developer environment (on any remote branch, with any version of NodeJS and any dummy (`devenv`) datasource). You can also run the official `verify-release` e2e tests for Grafana.

Additionaly, you may build your Grafana Box using eight different Linux distributions.

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

## Example Commands

* Run Grafana on Ubuntu 20.04 using `apt`:

```
./grafana-box.sh -d ubuntu-2004-lts -w package
```

* Run Grafana on CentOS 7 using `yum`:

```
./grafana-box.sh -d centos-7 -w package
```

* Run the standalone Grafana `8.1.5` binary on Rocky Linux 8:

```
./grafana-box.sh -d rocky-linux-8 -w 8.1.5
```

* Build a Grafana developer environment from `main` on Debian 10 using AMD processors:

```
./grafana-box.sh -d centos-stream-8 -w devenv -a
```

* Build a Grafana Developer Environment:
    * from remote branch `foo/bar` 
    * using NodeJS version `14.10.0` 
    * including the MySQL and Prometheus `devenv` dummy databases
    * on Debian 10 :

```
./grafana-box.sh -d debian-10 -w devenv-foo/bar -n 14.10.0 -z mysql,prometheus
```

* Run the E2E release tests for the `8.2.0-beta2` binary. Test on Ubuntu 18.04 against remote branch `v8.2.x`: 

```
./grafana-box.sh -d ubuntu-1804-lts -w e2e-binary-v8.2.x -r 8.2.0-beta2
```

## Full Option List

|DISTRO (-d)|WORKFLOW (-w)|CPU (-a) (optional) (no args) (default=Intel)|NODE (-n)  (optional) (devenv only)|DATA (-z)  (optional) (devenv only)| RELEASE (-r) (required) (e2e-binary only)
|---|---|---|---|---|---|
|`ubuntu-2004-lts `  |`package`  |`-a` (no args) = AMD   |use any valid `nvm` pattern. browse list here   |any `devenv` dummy datasource. browse list here   |the official binary to test for release. required when using `e2e-binary` workflow
|`ubuntu-1804-lts`   |`8.1.5` : use `x.x.x` pattern for standalone binary |   |   |   |use `x.x.x` pattern to specify binary
|`debian-11`|`devenv` (build dev environment from `main`) | | |
|`debian-10`|`devenv-foo/bar` (build dev environment from remote branch `foo/bar`) | | |
|`centos-stream-8`|`e2e-binary-v8.2.x` (builds from remote release branch `v8.2.x`) | | |
|`centos-8`| | | |
|`centos-7`| | | |
|`rocky-linux-8`| | | |
