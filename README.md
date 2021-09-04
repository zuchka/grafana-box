## grafana-box

### introduction & tutorial

## Prerequisites

## Step One: Configuring Your Secrets 

## Step Two: Using grafana-box

### choosing a distro and a workflow

grafana-box generates scripts and terraform plans based on arguments that you pass from the command line. You must always supply the  chosen `<DISTRO>` after the `-d` flag, and the chosen `<WORKFLOW>' after the `-w` flag. All other flags are optional.

First, choose a distro from this list.

Second, choose one of the three following workflows:

1) package
2) binary
3) devenv

### running grafana-box

Here is the minimum acceptable pattern for running grafana-box:

```
./grafana-box -d <DISTRO> -w <WORKFLOW>
```

Consider the following command:

```
./grafana-box.sh -d ubuntu-2004-lts -w package
```

This will build a VM using GCP's official Ubuntu 20.04 LTS image. It will then provision Grafana using the `package` workflow, which installs Grafana from the native package manager (in this case, `APT`).

The same workflow works with `yum`:

```
./grafana-box.sh -d centos-7 -w package
```

You can pass the `-a` flag with no arguments. This flag is optional **but should appear last when used**. If passed, it will build your image on a VM using AMD processors (default=Intel). This command builds a developer environment on Rocky Linux 8 on AMD processors:

```
./grafana-box.sh -d rocky-linux-8 -devenv -a
```
