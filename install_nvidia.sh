#!/usr/bin/env bash

# ==============================================================================
# Proxmox Host NVIDIA Driver Installation Script
# This automates the installation of the NVIDIA 550.100 driver on Proxmox 8+
# ==============================================================================

set -e # Exit immediately if a command exits with a non-zero status

echo "======================================================="
echo " 🚀 Starting Automated NVIDIA Host Driver Installation"
echo "======================================================="

# Step 1: Update APT and install the native Proxmox NVIDIA helper
echo -e "\n[1/4] Installing Proxmox NVIDIA vGPU Helper..."
apt-get update -y
apt-get install pve-nvidia-vgpu-helper -y

# Step 2: Run the setup tool to install kernel headers and block 'nouveau'
echo -e "\n[2/4] Configuring Kernel Headers & Blacklisting default drivers..."
# We pipe 'yes' into the command to automatically answer (y/N) prompts
yes | pve-nvidia-vgpu-helper setup

# Step 3: Install compiler dependencies for DKMS
echo -e "\n[3/4] Installing Build Dependencies (DKMS, build-essential)..."
apt-get install build-essential dkms -y

# Step 4: Download and install the official NVIDIA .run file
echo -e "\n[4/4] Downloading NVIDIA 550.100 Driver..."
# Download to the /tmp folder to keep your root directory clean
wget -q --show-progress https://download.nvidia.com/XFree86/Linux-x86_64/550.100/NVIDIA-Linux-x86_64-550.100.run -O /tmp/nvidia_installer.run

echo -e "\nCompiling the NVIDIA Driver into the kernel (This will take a few minutes)..."
chmod +x /tmp/nvidia_installer.run
/tmp/nvidia_installer.run -s --dkms

# Cleanup
rm /tmp/nvidia_installer.run

echo "======================================================="
echo " ✅ Installation Complete!"
echo " Please reboot your Proxmox server to apply the changes."
echo " After rebooting, run 'nvidia-smi' to verify your GPU."
echo "======================================================="
