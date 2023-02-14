docker build -t streamlit .
docker tag streamlit:latest $ACCOUNT_ID.dkr.ecr.eu-central-1.amazonaws.com/aws-deploy:streamlit
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.eu-central-1.amazonaws.com
docker push $ACCOUNT_ID.dkr.ecr.eu-central-1.amazonaws.com/aws-deploy:streamlit