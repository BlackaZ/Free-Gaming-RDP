#@title ⚡ Persistent Windows 11 RDP (Ngrok + QEMU)
!apt update -y && apt install -y qemu-kvm curl wget unzip

# Ngrok setup
NGROK_AUTH_TOKEN = "30TfPEzj0c3e7OitYZoJpCByF4w_KKDdnpVF1GSguzgCmQ7Q"  #@param {type:"string"}
REGION = "us"  #@param ["us", "eu", "ap", "au", "sa", "jp", "in"]

# Download Windows ISO
if not os.path.exists("Tiny11.iso"):
  !wget -O Tiny11.iso https://archive.org/download/tiny11_202304/Tiny11.iso

# Create disk if not exists
if not os.path.exists("win11disk.qcow2"):
  !qemu-img create -f qcow2 win11disk.qcow2 60G

# Ngrok install
if not os.path.exists("ngrok"):
  !wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
  !unzip ngrok-stable-linux-amd64.zip
  !chmod +x ngrok

# Start ngrok tunnel
get_ipython().system_raw(f'./ngrok authtoken {NGROK_AUTH_TOKEN} && ./ngrok tcp --region {REGION} 3389 &')
import time, requests
time.sleep(8)
tunnel = requests.get('http://localhost:4040/api/tunnels').json()['tunnels'][0]['public_url']
print("✅ RDP Address:", tunnel.replace("tcp://", ""))

# Boot Windows 11 with persistent disk
!qemu-system-x86_64 \
-enable-kvm -m 8G -cpu host -smp 4 \
-drive file=win11disk.qcow2,format=qcow2 \
-cdrom Tiny11.iso -boot once=d \
-net nic -net user,hostfwd=tcp::3389-:3389 \
-vga virtio -display none
