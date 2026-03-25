# neal-street

To run manually from anywhere:

Go to https://github.com/pietervandervyver/neal-street/actions
Click "Terraform" → "Run workflow"
To shell into the EC2 from anywhere with AWS CLI configured:

aws ssm start-session --target $(cd terraform && terraform output -raw ec2_instance_id)
That's it — no VPN, no bastion, works from any machine with AWS credentials.
