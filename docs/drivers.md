# Driver plugin installation

Minikube uses Docker Machine to manage the Kubernetes VM so it benefits from the
driver plugin architecture that Docker Machine uses to provide a consistent way to
manage various VM providers. Minikube embeds VirtualBox and VMware Fusion drivers
so there are no additional steps to use them. However, other drivers require an
extra binary to be present in the host PATH.

The following drivers currently require driver plugin binaries to be present in
the host PATH:

* [KVM](#kvm-driver)
* [xhyve](#xhyve-driver)
* [HyperV](#HyperV-driver)

#### KVM driver

Minikube is currently tested against [`docker-machine-driver-kvm` v0.10.0](https://github.com/dhiltgen/docker-machine-kvm/releases).

After following the instructions on the KVM driver releases page, you need to make sure that have the necessary packages and permissions by following these instructions:
```

# Install libvirt and qemu-kvm on your system, e.g.
# Debian/Ubuntu
$ sudo apt install libvirt-bin qemu-kvm
# Fedora/CentOS/RHEL
$ sudo yum install libvirt-daemon-kvm kvm

# Add yourself to the libvirtd group (use libvirt group for rpm based distros) so you don't need to sudo
# Debian/Ubuntu (NOTE: For Ubuntu 17.04 change the group to `libvirt`)
$ sudo usermod -a -G libvirtd $(whoami)
# Fedora/CentOS/RHEL
$ sudo usermod -a -G libvirt $(whoami)

# Update your current session for the group change to take effect
# Debian/Ubuntu (NOTE: For Ubuntu 17.04 change the group to `libvirt`)
$ newgrp libvirtd
# Fedora/CentOS/RHEL
$ newgrp libvirt
```

#### xhyve driver

From https://github.com/zchee/docker-machine-driver-xhyve#install:

```
$ brew install docker-machine-driver-xhyve

# docker-machine-driver-xhyve need root owner and uid
$ sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
$ sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
```

#### HyperV driver

Hyper-v users may need to create a new external network switch as described [here](https://docs.docker.com/machine/drivers/hyper-v/). This step may prevent a problem in which `minikube start` hangs indefinitely, unable to ssh into the minikube virtual machine. In this add, add the `--hyperv-virtual-switch=switch-name` argument to the `minikube start` command.

On some machines, having **dynamic memory management** turned on for the minikube VM can cause problems of unexpected and random restrarts which manifests itself in simply losing the connetion to the cluster, after which `minikube status` would simply state `localkube stopped`. Machine restarts are caused due to following Hyper-V error: `The dynamic memory balancer could not add memory to the virtual machine 'minikube' because its configured maximum has been reached`. **Solution**: turned the dynamic memory management in hyper-v settings off (and allocate a fixed amount of memory to the machine).
