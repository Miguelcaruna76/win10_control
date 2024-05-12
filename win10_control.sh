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

# Function to start the VirtualBox VM
start_vm() {
    qemu-system-x86_64 -hda windows_10.qcow2 &
    echo "VirtualBox VM started."
}

# Function to stop the VirtualBox VM
stop_vm() {
    pkill qemu-system-x86_64
    echo "VirtualBox VM stopped."
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
