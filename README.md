## grafana-box

### Introduction

Grafana Box is a collection of wrapper scripts for Terraform. You can use it to quickly test and troubleshoot platform-specific issues. 

Running `grafana-box.sh` will bootstrap an OSS or Enterprise Grafana instance on a GCP virtual machine.  With one command, you can run OSS/Enterprise Grafana from a native package manager or a standalone binary, or build Grafana from source in a fully-functioning developer environment (on any remote branch, with any version of NodeJS and any dummy (`devenv`) datasource). You can also run the official `verify-release` e2e test for Grafana (found in `/grafana/scripts`).

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

||DISTRO|WORKFLOW|ENTERPRISE?|AMD?|NODE?|DATA?|RELEASE?|MANUAL DEB/RPM?
|---|---|---|---|---|---|---|---|---|
|**FLAG**|`-d`|`-w`|`-e`|`-a`|`-n`|`-z`|`-r`|`-m`
|**REQUIRED**?|yes|yes|no|no|no|no|**only** with `e2e-binary`|no|
|**DEFAULT VALUE**|---|---|Grafana OSS|Intel CPUs|Node 14 LTS|---|---|latest|
|**USAGE**|`-d <distro>` |`-w <workflow>` |`-e`|`-a`|`-n <node-version>` |`-z <db>` |`-r <test-grafana-version>`|`-m <grafana-version>`
|**ARGS**|browse `distro` list |browse `workflow` list |no args |no args|browse `version` list |browse `db` list |use `x.x.x` binary pattern |use `x.x.x` binary pattern



## Interacting with Grafana-Box

Run a command like this:

```
./grafana-box.sh -e -d centos-7 -w e2e-binary-v8.2.x -r 8.2.0 -n 16.2.0
```

The script will validate your arguments and then kick off a terraform build. Terraform will deploy a virtual machine and then provision your environment with software. When Terraform finishes, Grafana Box will output relevant info like this:

```sh
Done in 55.90s.
google_compute_instance.instance_with_ip: Creation complete after 9m45s [id=projects/grafana-box/zones/us-central1-a/instances/instance-1633657736]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

instance_ip = "35.202.203.36"

current configuration:                        VALID

     gcp_machine_type:                           e2
     gcp_image_family:                 centos-cloud
    gcp_image_project:                     centos-7

             workflow:e2e-binary (enterprise-8.2.0)
               branch:                       v8.2.x
       NodeJS version:                       16.2.0

                  cpu:                        Intel
            cpu_count:                            8
                  ram:                         16gb
                 disk:                         25gb
            dummy DBs:

           ssh access:    ssh grafana@35.202.203.36
       browser access:    http://35.202.203.36:3001

  download e2e report:    scp "grafana@35.202.203.36:/home/grafana/grafana/packages/grafana-e2e/report.json" . && jq -r '.stats' < report.json
  ```

From here you can access the machine, visit the Grafana UI in any browser, or, in this case, download and parse your e2e test results.

## Accessing `grafana-server` on the VM

Grafana instances installed via the `package` workflow will be enabled and started with `systemd`. To check 

Grafana Box will launch standalone binaries and developer environments in detached `tmux` sessions. After using `ssh` to enter the VM, run this command to list all active tmux sessions:

```sh
tmux ls
```

For binaries, you will see an output like this:

```output
grafanaBinary: 1 windows (created Fri Oct  8 01:50:51 2021)
```

Developer Environments split the frontend and backend across two sessions:

```
grafanaBackend: 1 windows (created Fri Oct  8 02:25:16 2021)
grafanaFrontend: 1 windows (created Fri Oct  8 02:25:16 2021)
```

Access your detached session using the `tmux` `a` command:

```
tmux a -t grafanaBinary
```

You should now see the output from the `grafana-server`'s logs.

Use this key combination to detach the session and return to the main shell: 

Press `CTRL + b`. Let go and quickly press `d`. 

## Cleaning Up and Destroying Grafana-Box

from Grafana Box's root directory, run the following commnand:

```
./grafana-box destroy
```

This will auto-approve the destruction of all resources inside every timestamped subdirectory