# URL of the image to use
# EXAMPLE:
# image_uri = "SLE-15-SP1-JeOS-GMC"
image_uri = "/root/SLES15-SP1-JeOS.x86_64-15.1-OpenStack-Cloud-Build36.3.1_kd.qcow2"

# Identifier to make all your resources unique and avoid clashes with other users of this terraform project
stack_name = "susecon"

# CIDR of the network
network_cidr = "10.17.0.0/22"

# Number of master nodes
masters = 1
master_vcpu = 2
master_memory = 4096

# Number of worker nodes
workers = 1
worker_vcpu = 2
worker_memory = 4096

# Name of DNS domain
dns_domain = "susecon.lab"

# Username for the cluster nodes
# EXAMPLE:
username = "sles"

# Password for the cluster nodes
# EXAMPLE:
password = "linux"

# define the repositories to use
# EXAMPLE:
# repositories = {
#   repository1 = "http://example.my.repo.com/repository1/"
#   repository2 = "http://example.my.repo.com/repository2/"
# }
repositories = {}

# Minimum required packages. Do not remove them.
# Feel free to add more packages
packages = [
  "kernel-default",
  "-kernel-default-base"
]

# ssh keys to inject into all the nodes
# EXAMPLE:
# authorized_keys = [
#  "ssh-rsa <key-content>"
# ]
authorized_keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHUkbmn1u0EPaf1Nqnx8KSn9sfcgLxsaDSyPy+xmHJ1 lcavajani@suse.com"
]

# IMPORTANT: Replace these ntp servers with ones from your infrastructure
ntp_servers = ["0.novell.pool.ntp.org", "1.novell.pool.ntp.org", "2.novell.pool.ntp.org", "3.novell.pool.ntp.org"]
