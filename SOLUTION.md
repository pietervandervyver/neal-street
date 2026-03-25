The solution consists of a VPN, public and private subnets in two AZs in the 
US East region.

The Terraform state is stored in an S3 bucket.

In the private subnet, EC2 instances running Linux with nginx serves the 
health API.

Github Actions authenticate to AWS through OIDC.

A centralized logs observibility pattern is used with AWS CloudWatch.

Only a dev environment has been provided but for an identical prod environment
little extra work is required.

I used AWS Kiro for my IDE with very good results.  I used its AI capabilities
to debug the project.

To test the system, the following can be excecuted from a terminal:

# Health check
curl http://$(cd terraform && terraform output -raw alb_dns_name)/health

# Default nginx page
curl http://$(cd terraform && terraform output -raw alb_dns_name)

# Verbose output with response headers
curl -v http://$(cd terraform && terraform output -raw alb_dns_name)


# Next steps

A production environment can be added by creating a prod.tfvars file containing
env                          = "prod"
instance_type                = "t3.small"
vpc_cidr                     = "10.1.0.0/16"
public_subnet_cidr           = "10.1.1.0/24"
public_subnet_cidr_secondary = "10.1.3.0/24"
private_subnet_cidr          = "10.1.2.0/24"

A domain name for ACM to issue a certificaten.

ACM certificate with DNS validation
HTTPS listener on port 443
HTTP → HTTPS redirect on port 80
Route53 alias record pointing to the ALB
