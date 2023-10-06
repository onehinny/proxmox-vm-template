#!/bin/bash
# Creats a ubuntu Cloud-Init Ready VM Template in Proxmox

# See this link: https://registry.terraform.io/modules/sdhibit/cloud-init-vm/proxmox/latest/examples/ubuntu_single_vm

export IMAGENAME="ubuntu-22.04-minimal-cloudimg-amd64.img"
export IMAGEURL="https://cloud-images.ubuntu.com/minimal/releases/jammy/release/"
export STORAGE="local-lvm"
export VMNAME="ubuntu-2204-cloudinit-template"
export VMID=9000
export VMMEM=2048
export VMSETTINGS="--net0 virtio,bridge=vmbr10"

# Install libguestfs-tools on Proxmox server.
apt-get install libguestfs-tools -y

wget -O ${IMAGENAME} --continue ${IMAGEURL}/${IMAGENAME}
qm create ${VMID} --name ${VMNAME} --memory ${VMMEM} ${VMSETTINGS}
qm importdisk ${VMID} ${IMAGENAME} ${STORAGE}
qm set ${VMID} --scsihw virtio-scsi-pci --scsi0 ${STORAGE}:vm-${VMID}-disk-0
qm set ${VMID} --ide2 ${STORAGE}:cloudinit
qm set ${VMID} --boot c --bootdisk scsi0
qm set ${VMID} --serial0 socket --vga serial0
qm template ${VMID}
echo "TEMPLATE ${VMNAME} successfully created!"
echo "Now create a clone of VM with ID ${VMID} in the Webinterface.."
echo "Cleaning..."
rm ${IMAGENAME}