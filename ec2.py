import boto3
import csv


ec2 = boto3.resource('ec2')
s3 = boto3.resource('s3')

def lambda_handler(event, context):
    # create filter for instances in running state
    filters = [
        {
            'Name': 'instance-state-name', 
            'Values': ['running']
        }
    ]
    
    # filter the instances based on filters() above
    instances = ec2.instances.filter(Filters=filters)
    result = []

    for instance in instances:
    for tag in instance.tags:
        if 'Name'in tag['Key']:
            name = tag['Value']
    
    # Add instance info to a dictionary         
    for i in instances:
        result.append({
            'Name': name,
            'InstanceType': i.instance_type,
            'Image': i.image_id
        })

    # Write to csv file.
    headers = ['Name', 'InstanceType', 'Image']
    with open('/tmp/ec2-export.csv', 'w') as file:
        writer = csv.DictWriter(file, fieldnames=headers)
        writer.writeheader()
        writer.writerows(result)

    s3.Bucket('mybucket').upload_file('/tmp/ec2-export.csv', 'ec2-export.csv')