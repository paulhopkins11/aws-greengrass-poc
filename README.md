Covers how to set up a greengrass POC from Cloudformation

## Summary

At the end of this POC you will have a AWS Greengrass stack containing:

* 1 x Core
* 1 x Group
* 2 x Devices

You will have verified that you can send messages from one devices to another

## Assumptions

This assumes:

* You have a Greengrass core up and running

If you need to set one up you can use my AMI and run on EC2. Check it out here https://github.com/paulhopkins11/aws-greengrass-core-ami

## Steps

### 1. Generate some certificates

```zsh
export DEVICE1_CERTIFICATE_ARN=$(aws iot create-keys-and-certificate \
    --profile <YOUR_AWS_PROFILE> \
    --region <YOUR_AWS_REGION> \
    --set-as-active \
    --certificate-pem-outfile certs/device1.cert.pem \
    --public-key-outfile certs/device1.public.key \
    --private-key-outfile certs/device1.private.key | jq '.certificateArn' -r)
echo $DEVICE1_CERTIFICATE_ARN
export DEVICE2_CERTIFICATE_ARN=$(aws iot create-keys-and-certificate \
    --profile <YOUR_AWS_PROFILE> \
    --region <YOUR_AWS_REGION> \
    --set-as-active \
    --certificate-pem-outfile certs/device2.cert.pem \
    --public-key-outfile certs/device2.public.key \
    --private-key-outfile certs/device2.private.key | jq '.certificateArn' -r)
echo $DEVICE2_CERTIFICATE_ARN
```

### 2. Create the Greengrass Stack
TODO - CORE CONNECTIVITY SETTINGS (see NB below)

TODO - Core -> Settings -> Automatically detect and override connection information

TODO - Core -> Settings -> Local logs configuration

Create the stack using:
```zsh
aws cloudformation create-stack \
--stack-name greengrass-stack \
--template-body file://./greengrass_stack_cf.yaml \
--profile <YOUR_AWS_PROFILE> \
--region <YOUR_AWS_REGION> \
--capabilities CAPABILITY_NAMED_IAM \
--parameters \
ParameterKey=CoreCertificateArn,ParameterValue=<YOUR_CORE_CERTIFICATE_ARN> \
ParameterKey=Device1CertificateArn,ParameterValue=$DEVICE1_CERTIFICATE_ARN \
ParameterKey=Device2CertificateArn,ParameterValue=$DEVICE2_CERTIFICATE_ARN
```

Update the stack using:

```zsh
aws cloudformation update-stack \
--stack-name greengrass-stack \
--template-body file://./greengrass_stack_cf.yaml \
--profile <YOUR_AWS_PROFILE> \
--region <YOUR_AWS_REGION> \
--capabilities CAPABILITY_NAMED_IAM \
--parameters \
ParameterKey=CoreCertificateArn,ParameterValue=<YOUR_CORE_CERTIFICATE_ARN> \
ParameterKey=Device1CertificateArn,ParameterValue=$DEVICE1_CERTIFICATE_ARN \
ParameterKey=Device2CertificateArn,ParameterValue=$DEVICE2_CERTIFICATE_ARN
```

### 3. Deploy the Group

Navigate to the Group in the AWS Console and choose Deploy

NB. If running the Pub and Sub locally and the core on EC2 you need to manually add the public IP of your EC2 instance into the Connectivity settings:
* Navigate to TestCore1 in the AWS Console
* Choose Connectivity
* Edit the endpoints
* Add the public IP and port 8883

### 4. Setup the python environment

```zsh
python3 -m venv ~/virtualenv/greengrass
source ~/virtualenv/greengrass/bin/activate 
python3 -m pip install awsiotsdk
```

### 5. Download the sample code

```zsh
wget https://raw.githubusercontent.com/aws/aws-iot-device-sdk-python-v2/main/samples/basic_discovery.py -P src/
```

### 6. Run the Subscriber

```zsh
make sub -e region=<YOUR_AWS_REGION>
```

You should see this successfully discover

### 7. Run the Publisher

```zsh
make pub -e region=<YOUR_AWS_REGION>
```

You should now see the publisher send 10 messages. You should see these received by the subscriber
