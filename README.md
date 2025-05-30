# Azure Load Balanced Web Servers with Terraform

This Terraform configuration deploys a load-balanced web server infrastructure on Microsoft Azure. The setup includes virtual machines, networking components, and a public load balancer.

## Components

- **Virtual Machines**: Linux-based VMs with NGINX
- **Networking**: Virtual network, subnets, and network security groups
- **Load Balancer**: Public-facing load balancer for distributing traffic

## Notes
- Backend pool is configured with individual VM private IPs and associated with the VNet (not at the address level, only assign at the network interface level)