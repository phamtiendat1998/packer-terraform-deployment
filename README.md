# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
You can customize the deployments using the variables in variables.tf file: 
 - "prefix": The prefix of resouce name
 - "location": Azure region
 - "commonTagName": Tag name in order to attached to resouces
 - "virtualMachineCount": The number of virtual machines will be deployed

After input the variables:
1. Run packer in command line: <code>packer build "server.json"</code>.
2. Run terraform in command line: <code>teraform init</code>.
3. Run terraform in command line: <code>teraform plan -out solution.plan</code>.
4. Run terraform in command line: <code>teraform apply "solution.plan"</code>.

### Output
Expect should be like that in the command line after done:
<code>Apply complete! Resources: n added, 0 changed, 0 destroyed.</code>

