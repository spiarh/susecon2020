resource "libvirt_network" "network" {
  name   = "${var.stack_name}-network"
  mode   = var.network_mode
  domain = var.dns_domain

  dns {
    enabled = true

    forwarders {
      address = "1.1.1.1"
    }

    forwarders {
      address = "1.0.0.1"
    }
  }

  addresses = [var.network_cidr]
}

