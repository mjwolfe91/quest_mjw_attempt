import json
import numpy as np
import boto3
import logging
import os

S3_BUCKET_NAME = os.environ["S3_BUCKET_NAME"]
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    for record in event['Records']: # looped due to structure of message, but should only receive 1
        # Extract the S3 event message
        message_body = json.loads(record['body'])
        s3_event = json.loads(message_body['Message'])
        
        # Extract bucket name and object key
        bucket_name = s3_event['Records'][0]['s3']['bucket']['name']
        object_key = s3_event['Records'][0]['s3']['object']['key']
        json_data = get_json_from_s3(bucket_name, object_key)
    
        mean, std = get_mean_and_std(json_data)

        logging.info(f"The mean from object {bucket_name}/{object_key} is {mean}")
        logging.info(f"The standard deviation from object {bucket_name}/{object_key} is {std}")
    
    return {
        'mean_population': mean,
        'std_population': std
    }

def get_json_from_s3(bucket, key):
    s3 = boto3.client('s3')
    response = s3.get_object(Bucket=bucket, Key=key)
    json_data = response['Body'].read().decode('utf-8')
    return json_data

def get_mean_and_std(json_data):
    data = json.loads(json_data)
    
    population_data = [entry['Population'] for entry in data['data'] if int(entry['Year']) >= 2013 and int(entry['Year']) <= 2018]
    
    mean_population = np.mean(population_data)
    std_population = np.std(population_data)
    
    return mean_population, std_population
