docker build -t streamlit .
docker tag streamlit:latest $ACCOUNT_ID.dkr.ecr.eu-central-1.amazonaws.com/aws-deploy:streamlit
docker push $ACCOUNT_ID.dkr.ecr.eu-central-1.amazonaws.com/aws-deploy:streamlit