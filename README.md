
Build docker image and push to ECR

```
cd ~/Projects/fastapi-demo
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 806152608109.dkr.ecr.us-east-1.amazonaws.com
```

Bootstrap a terraform backend on AWS:
```
cd infra/tf_backend
```
Make sure top section of code is commented out.
```
terraform init
terraform apply
```
Now uncomment the top section and run `terraform init` again to move the backend to S3.

Create the ECR repo:
```
cd infra/ecr
terraform init
terraform apply
```

Push the image to ECR:
```
cd ~/Projects/fastapi-demo 
docker build --platform=linux/amd64 -t fastapi-app:latest .
docker tag fastapi-app:latest 806152608109.dkr.ecr.us-east-1.amazonaws.com/my-fastapi-app:latest
docker push 806152608109.dkr.ecr.us-east-1.amazonaws.com/my-fastapi-app:latest
```

Deploy the app:
```
cd infra/web
terraform init
terraform plan
terraform apply
```



