provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

resource "oci_core_vcn" "dsb_vcn" {
  compartment_id = var.compartment_ocid
  display_name   = "dsb-vcn"
  cidr_block     = var.vcn_cidr_block
  dns_label      = "dsbvcn" # Add this line (must be unique in the region)
}

resource "oci_core_internet_gateway" "dsb_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.dsb_vcn.id
  display_name   = "dsb-igw"
}

resource "oci_core_default_route_table" "dsb_route_table" {
  manage_default_resource_id = oci_core_vcn.dsb_vcn.default_route_table_id
  display_name               = "dsb-default-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.dsb_igw.id
  }
}

resource "oci_core_security_list" "dsb_node_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.dsb_vcn.id
  display_name   = "dsb-node-security-list"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6" // TCP
    source   = var.ssh_source_cidr
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6" // TCP
    source   = "0.0.0.0/0" // Restrict if needed
    tcp_options {
      min = 6443 # K3s API Server
      max = 6443
    }
  }
}

resource "oci_core_subnet" "dsb_node_subnet" {
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.dsb_vcn.id
  cidr_block          = var.subnet_cidr_block
  display_name        = "dsb-node-subnet"
  dns_label           = "dsbnodesub" # This is fine
  security_list_ids   = [oci_core_security_list.dsb_node_sl.id]
  route_table_id      = oci_core_vcn.dsb_vcn.default_route_table_id
  dhcp_options_id     = oci_core_vcn.dsb_vcn.default_dhcp_options_id
}

resource "oci_core_instance" "dsb_k8s_node" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "dsb-k8s-node"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_image_arm.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.dsb_node_subnet.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub") # Path to your SSH public key
    user_data           = base64encode(file("${path.module}/cloud-init/k3s-node.yaml"))
  }
}
