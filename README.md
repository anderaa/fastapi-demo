
# Build docker image and push to ECR
```
cd ~/Projects/terraform-demo
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 806152608109.dkr.ecr.us-east-1.amazonaws.com

cd infra/web
terraform apply -auto-approve

cd ../..
docker build --platform=linux/amd64 -t fastapi-app:latest .
docker tag fastapi-app:latest 806152608109.dkr.ecr.us-east-1.amazonaws.com/my-fastapi-app:latest
docker push 806152608109.dkr.ecr.us-east-1.amazonaws.com/my-fastapi-app:latest
```




