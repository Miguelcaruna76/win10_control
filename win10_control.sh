#!/bin/bash

# Function to ensure VirtualBox kernel module is loaded
ensure_vbox_kernel_module() {
    if ! lsmod | grep -q vboxdrv; then
        echo "VirtualBox kernel module is not loaded. Attempting to load it..."
        if ! sudo modprobe vboxdrv; then
            echo "Failed to load the VirtualBox kernel module."
            exit 1
        fi
    fi
}

# Function to install VirtualBox and dependencies
install_virtualbox() {
    sudo apt-get update
    sudo apt-get install virtualbox virtualbox-ext-pack -y
}

# Function to download Windows 10 ISO
download_windows_iso() {
    wget -O windows_10.iso "https://go.microsoft.com/fwlink/p/?LinkID=2195404&clcid=0x409&culture=en-us&country=US"
}

# Function to download ngrok and extract it
download_ngrok() {
    wget "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip"
    unzip ngrok-stable-linux-amd64.zip
}

# Function to install QEMU and its dependencies
install_qemu() {
    sudo apt-get update
    sudo apt-get install qemu-utils -y
}

# Function to configure ngrok with authtoken and start TCP forwarding
configure_ngrok() {
    echo "Enter your ngrok authtoken:"
    read authtoken
    ./ngrok authtoken $authtoken
    ./ngrok tcp 5900 &
}

# Function to convert the Windows 10 ISO to a qcow2 disk image file
convert_iso_to_qcow2() {
    qemu-img convert -f raw -O qcow2 windows_10.iso windows_10.qcow2
}

# Function to create VirtualBox virtual machine and attach disk and network adapter
create_virtualbox_vm() {
    # Define VM name and disk location
    vm_name="Windows 10 VM"

    # Import VM from disk image
    VBoxManage import windows_10.qcow2 --vsys 0 --vmname "$vm_name"

    # Add memory, VRAM, and CPUs
    VBoxManage modifyvm "$vm_name" --memory 2048 --vram 128 --cpus 2 --audio none

    # Attach network adapter with ngrok TCP address
    ngrok_url=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')
    VBoxManage modifyvm "$vm_name" --nic1 nat
    VBoxManage modifyvm "$vm_name" --natpf1 "tcp-port5900,tcp,,5900,,5900"
}

# Function to start the VirtualBox VM
start_vm() {
    ensure_vbox_kernel_module
    create_virtualbox_vm
    VBoxManage startvm "Windows 10 VM"
}

# Function to stop the VirtualBox VM
stop_vm() {
    VBoxManage controlvm "Windows 10 VM" poweroff
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
        "download_ngrok")
            download_ngrok
            ;;
        "install_qemu")
            install_qemu
            ;;
        "configure_ngrok")
            configure_ngrok
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
            echo "Usage: $0 {install_virtualbox|download_windows_iso|download_ngrok|install_qemu|configure_ngrok|convert_iso_to_qcow2|start_vm|stop_vm}"
            exit 1
            ;;
    esac
}

main "$@"
