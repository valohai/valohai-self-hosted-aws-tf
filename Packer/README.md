# Packer images

This repository contains a Packer scripts to build custom AWS AMIs for Valohai Roi and Peon.

## Prerequisites

* [Install Packer](https://developer.hashicorp.com/packer/downloads)
* [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* Configure a new AWS profile with your credentials by running `aws configure --profile myname` on your workstation

## Running the Packer scripts

Before you can build a new image with Packer, you'll need to update the `variables.pkrvars.hcl` file and input your details there.

* `aws_profile` will determine which AWS account will host this custom AMI
* `region` determines which region you want to deploy the new AMI to

Build a new Roi image with:
```bash
cd roi
packer build -var-file="variables.pkrvars.hcl" roi.pkr.hcl  
```
