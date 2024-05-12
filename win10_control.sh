#!/bin/bash

# Function to install VirtualBox and dependencies
install_virtualbox() {
    sudo apt-get update
    sudo apt-get install virtualbox virtualbox-ext-pack -y
}

# Function to download Windows 10 ISO
download_windows_iso() {
    wget -O windows_10.iso "https://go.microsoft.com/fwlink/p/?LinkID=2195404&clcid=0x409&culture=en-us&country=US"
}

# Function to create VirtualBox virtual machine and attach ISO
create_virtualbox_vm() {
    # Define VM name and disk location
    vm_name="Windows10VM"
    disk_path="win10.vdi"
    iso_path="windows_10.iso"

    # Create VM
    VBoxManage createvm --name "$vm_name" --ostype "Windows10_64" --register

    # Add memory and CPU
    VBoxManage modifyvm "$vm_name" --memory 4096 --vram 128 --cpus 2

    # Create and attach disk
    VBoxManage createhd --filename "$disk_path" --size 20000
    VBoxManage storagectl "$vm_name" --name "SATA Controller" --add sata --controller IntelAhci
    VBoxManage storageattach "$vm_name" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$disk_path"

    # Attach ISO
    VBoxManage storageattach "$vm_name" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium "$iso_path"

    # Enable EFI boot
    VBoxManage modifyvm "$vm_name" --firmware efi

    # Start VM
    VBoxManage startvm "$vm_name"
}

# Function to download ngrok and extract it
download_ngrok() {
    wget "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip"
    unzip ngrok-stable-linux-amd64.zip
}

# Function to configure ngrok with authtoken and start TCP forwarding
configure_ngrok() {
    echo "Enter your ngrok authtoken:"
    read authtoken
    ./ngrok authtoken $authtoken
    ./ngrok tcp 5900 &
}

# Function to install QEMU and its dependencies
install_qemu() {
    sudo apt-get update
    sudo apt-get install qemu qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon virt-manager -y
}

# Function to convert the Windows 10 ISO to a disk image file
convert_iso_to_qcow2() {
    qemu-img convert -f raw -O qcow2 windows_10.iso windows_10.qcow2
}

# Function to start the virtual machine
start_vm() {
    qemu-system-x86_64 -hda windows_10.qcow2
}

# Function to stop the virtual machine
stop_vm() {
    # Assuming the virtual machine is running as a background process
    pkill qemu-system-x86_64
}

# Main function
main() {
    case "$1" in
        "install_virtualbox")
            install_virtualbox
            ;;
        "download_windows_iso")
            download_windows_iso
            ;;
        "create_virtualbox_vm")
            create_virtualbox_vm
            ;;
        "download_ngrok")
            download_ngrok
            ;;
        "configure_ngrok")
            configure_ngrok
            ;;
        "install_qemu")
            install_qemu
            ;;
        "convert_iso_to_qcow2")
            convert_iso_to_qcow2
            ;;
        "start_vm")
            start_vm
            ;;
        "stop_vm")
            stop_vm
            ;;
        *)
            echo "Usage: $0 {install_virtualbox|download_windows_iso|create_virtualbox_vm|download_ngrok|configure_ngrok|install_qemu|convert_iso_to_qcow2|start_vm|stop_vm}"
            exit 1
            ;;
    esac
}

main "$@"
