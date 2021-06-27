# Infrastructure As Code

### PROJECT DESCRIPTION

The purpose of infrastructure as code is to enable developers or operations teams to automatically manage, monitor and provision resources, rather than manually configure discrete hardware devices and operating systems.
Infrastructure as code is sometimes referred to as programmable or software-defined infrastructure.
This repository is to build the infrastructure required for hosting webapp [Bookstore](https://github.com/aelinadas/bookstore)

Using **Terraform**, AWS resources like VPC, Subnets, S3 bucket, RDS, EC2, Auto Scaling, Elastic Load Balancer, etc. are provisioned.

---

### INFRASTRUCTURE AS CODE

<img alt="IaaC" src="https://github.com/aelinadas/aws-infrastructure/blob/main/images/Infrastructure.png" />

---

### BUILD INFRASTRUCTURE

1. Clone this repository
2. Download terraform from the official site
3. Copy the terraform binary into your cloned folder or set it in your path
4. Open Terminal and enter `terraform plan`
5. Once the plan is verified, enter `terraform apply`
6. View your VPC on AWS VPC Console
7. Incase, you want tear down the infrastructure enter `terraform destroy`

---

### UPLOAD SSL

Following command uploads SSL certifcate of the website domain to AWS Certificate Manager (ACM)

```
sudo aws acm import-certificate --certificate fileb://prodcertificate.pem --certificate-chain fileb://prod_certificate_chain.pem --private-key fileb://privatekey.pem --profile prod
```