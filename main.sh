#!/bin/bash
# Windows 11 RDP Setup for Gaming (QEMU + Ngrok)

echo "🔐 30TfPEzj0c3e7OitYZoJpCByF4w_KKDdnpVF1GSguzgCmQ7Q:"
read NGROK_TOKEN

echo "🌐 Choose region (us, eu, ap, au, sa, jp, in):"
read REGION

# Update packages
apt update -y && apt upgrade -y

# Install dependencies
apt install qemu-kvm curl wget unzip -y

# Download Windows image (Tiny11 for performance)
wget -O win11lite.img https://archive.org/download/tiny11_202304/Tiny11.iso

# Create virtual hard disk
qemu-img create -f qcow2 win11disk.qcow2 4TB

# Install Ngrok
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
chmod +x ngrok
./ngrok authtoken $NGROK_TOKEN

# Start Ngrok tunnel
./ngrok tcp --region $REGION 3389 > ngrok.log &

# Wait for Ngrok to connect
sleep 10
echo "🌍 Your RDP address:"
curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'tcp://.*'

# Start QEMU Windows 11 VM
qemu-system-x86_64 \
-enable-kvm \
-m 8G \
-cpu host \
-smp cores=4 \
-drive file=win11disk.qcow2,format=qcow2 \
-cdrom win11lite.img \
-boot d \
-net nic -net user,hostfwd=tcp::3389-:3389 \
-vga virtio \
-display none
