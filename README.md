# OCI K3s Node Deployment with Terraform

This Terraform project provisions a single K3s (Lightweight Kubernetes) node on Oracle Cloud Infrastructure (OCI). It automates the setup of necessary OCI networking resources (VCN, Subnet, Internet Gateway, Route Table, Security List) and a compute instance. `cloud-init` is then used to install K3s on the instance.

## Features

*   **Automated Network Setup**: Creates a Virtual Cloud Network (VCN) and a public subnet.
*   **Internet Connectivity**: Configures an Internet Gateway and a default route table for outbound internet access for the K3s node.
*   **Secure Access**: Defines a custom Security List to allow SSH (from a specified CIDR) and K3s API server access (port 6443).
*   **Compute Instance**: Launches an OCI Compute instance (defaulting to ARM-based Ampere A1 Flex with Ubuntu 22.04).
*   **K3s Installation**: Uses `cloud-init` to automatically download and install K3s on the instance during its first boot.
*   **Outputs**: Provides the public IP address of the deployed K3s node for easy access.

## Prerequisites

Before you begin, ensure you have the following:

1.  **Oracle Cloud Infrastructure (OCI) Account**: An active OCI account with necessary permissions to create resources.
2.  **Terraform**: Terraform CLI installed (version 1.0.0 or later is recommended). You can download it from terraform.io.
3.  **OCI API Key Authentication**:
    *   An OCI API signing key pair (public and private keys).
    *   The public key uploaded to your OCI user account.
    *   Your Tenancy OCID, User OCID, API Key Fingerprint, and the local path to your private key file.
4.  **SSH Key Pair**: An SSH public/private key pair. The public key will be added to the OCI instance to allow SSH access.

## Configuration

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/AlexJelani/dsb-k8s-node-homelab.git
    cd dsb-k8s-node-homelab
    ```

2.  **Create `terraform.tfvars` File:**
    This project uses a `.gitignore` file to exclude `*.tfvars` files from version control, as they typically contain sensitive information.
    Create a file named `terraform.tfvars` in the root directory of the project. Populate it with your OCI credentials and any other variables you wish to override.

    **Example `terraform.tfvars`:**
    ```terraform
    tenancy_ocid     = "ocid1.tenancy.oc1..your_tenancy_ocid"
    user_ocid        = "ocid1.user.oc1..your_user_ocid"
    fingerprint      = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
    private_key_path = "~/.oci/your_oci_api_private_key.pem" # Ensure this path is correct
    region           = "ap-tokyo-1" # Or your desired OCI region
    compartment_ocid = "ocid1.compartment.oc1..your_compartment_ocid"
    ssh_public_key   = "ssh-rsa AAAA..." # Contents of your SSH public key (e.g., from ~/.ssh/id_rsa.pub)

    # Optional: Override default CIDR blocks or SSH source IP
    # vcn_cidr_block    = "10.0.0.0/16"
    # subnet_cidr_block = "10.0.1.0/24"
    # ssh_source_cidr   = "YOUR_PUBLIC_IP/32" # Highly recommended for security
    ```
    **Security Note**: For the `ssh_source_cidr` variable, it is strongly recommended to replace the default `"0.0.0.0/0"` with your specific public IP address (e.g., `"1.2.3.4/32"`) to restrict SSH access to your instance.

3.  **Review Variables (`variables.tf`):**
    This file lists all input variables for the project, along with their descriptions, types, and default values. You can customize these defaults in your `terraform.tfvars` file.

## Deployment

1.  **Initialize Terraform:**
    Navigate to the project's root directory in your terminal and run:
    ```bash
    terraform init
    ```
    This command initializes the Terraform working directory, downloading necessary provider plugins.

2.  **Plan Deployment:**
    Generate and review an execution plan. This shows you what resources Terraform will create, modify, or destroy.
    ```bash
    terraform plan
    ```

3.  **Apply Configuration:**
    Deploy the resources to OCI:
    ```bash
    terraform apply
    ```
    Terraform will display the plan again and ask for confirmation. Type `yes` and press Enter to proceed.

## Accessing the K3s Node

After `terraform apply` successfully completes, it will output the public IP address of the K3s node:

```
Outputs:

dsb_k8s_node_public_ip = "xxx.xxx.xxx.xxx"
```

You can SSH into the instance using the private key corresponding to the `ssh_public_key` you provided. The default username for the Canonical Ubuntu image used is `ubuntu`.

```bash
ssh ubuntu@<dsb_k8s_node_public_ip>
```

Once logged in, you can check the K3s status:
```bash
sudo kubectl get nodes
sudo systemctl status k3s
```
The K3s kubeconfig file is located at `/etc/rancher/k3s/k3s.yaml` on the node. You can copy this to your local machine to manage the cluster remotely with `kubectl`.

## Cleanup

To remove all resources created by this Terraform configuration from your OCI account:
```bash
terraform destroy
```
Terraform will show you the resources to be destroyed and ask for confirmation. Type `yes` and press Enter.

## Project File Structure

*   `main.tf`: Core Terraform script defining all OCI resources (VCN, subnet, instance, security list, etc.).
*   `variables.tf`: Declaration of all input variables used by the project.
*   `outputs.tf`: Definition of output values, such as the instance's public IP.
*   `data.tf`: Specifies data sources, like OCI image lookups and availability domains.
*   `cloud-init/k3s-node.yaml`: The cloud-init configuration script responsible for installing K3s on the compute instance.
*   `terraform.tfvars` (user-created): Stores your specific variable values (e.g., OCI credentials).
*   `.gitignore`: Specifies files and directories to be ignored by Git.
*   `README.md`: This file.

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to open an issue or submit a pull request.