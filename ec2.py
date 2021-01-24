import boto3
import csv


ec2 = boto3.resource('ec2')
s3 = boto3.resource('s3')
sns = boto3.client("sns")

def lambda_handler(event, context):
    
    try:
        # create filter for instances in running state
        running_filters = [
            {
                'Name': 'instance-state-name', 
                'Values': ['running']
            }
        ]
                
        instances = ec2.instances.filter(Filters=running_filters)
        tagfilter = [
            {
                'Name': 'tag:Service',
                'Values': ["Data","Processing","Web"]
            }
        ]

        tagged_instances = instances.filter(Filters=tagfilter)
        result = []
        
        if tagged_instances:
            sns.publish(TopicArn=topic_arn,Message="Instances without tags")
        
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
        
        file_name = "/tmp/ec2-export.csv"
                
        curent_report = s3.get_object(Bucket='bucket_name', Key='instance_report.csv')
        appended_data = current_report + new_data
        s3.put_object(Body=appended_data, Bucket='bucket_name', Key=file_name)

    except:
        print("Error occurred")