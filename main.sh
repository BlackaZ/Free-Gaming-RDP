#!/bin/bash
# Windows 11 RDP Setup with Persistent Disk (QEMU + Ngrok)

echo "🔐 30TfPEzj0c3e7OitYZoJpCByF4w_KKDdnpVF1GSguzgCmQ7Q:"
read NGROK_TOKEN

echo "🌐 Choose region (us, eu, ap, au, sa, jp, in):"
read REGION

# Update system
apt update -y && apt upgrade -y

# Install required packages
apt install qemu-kvm curl wget unzip -y

# Download Tiny11 ISO (lightweight Windows 11)
if [ ! -f "Tiny11.iso" ]; then
  wget -O Tiny11.iso https://archive.org/download/tiny11_202304/Tiny11.iso
fi

# Create persistent disk if not exists
if [ ! -f "win11disk.qcow2" ]; then
  echo "🧩 Creating 60GB Windows persistent disk..."
  qemu-img create -f qcow2 win11disk.qcow2 60G
else
  echo "💾 Existing persistent disk found. Reusing it..."
fi

# Install Ngrok
if [ ! -f "ngrok" ]; then
  wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
  unzip ngrok-stable-linux-amd64.zip
  chmod +x ngrok
fi

# Start Ngrok tunnel
./ngrok authtoken $NGROK_TOKEN
./ngrok tcp --region $REGION 3389 > ngrok.log &

# Wait for Ngrok to start
sleep 10
echo "🌍 Your RDP address:"
curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'tcp://.*'

# Start QEMU VM with persistent disk
qemu-system-x86_64 \
-enable-kvm \
-m 8G \
-cpu host \
-smp cores=4 \
-drive file=win11disk.qcow2,format=qcow2 \
-cdrom Tiny11.iso \
-boot once=d \
-net nic -net user,hostfwd=tcp::3389-:3389 \
-vga virtio \
-display none
