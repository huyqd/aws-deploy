zenml step-operator register sagemaker \
    --flavor=sagemaker \
    --role="arn:aws:iam::611215368770:role/DataSciencePlayground" \
    --bucket="playground.datascience"

zenml container-registry register aws \
    --flavor=aws \
    --uri=611215368770.dkr.ecr.eu-central-1.amazonaws.com

zenml image-builder register local \
    --flavor=local

zenml artifact-store register aws --flavor=s3 --path=s3://playground.datascience

zenml stack register sagemaker -o default -a aws -s sagemaker -c aws -i local
zenml stack set sagemaker