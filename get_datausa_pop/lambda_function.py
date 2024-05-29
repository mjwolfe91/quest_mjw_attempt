import json
import urllib3
import boto3
import os
import logging
from datetime import datetime, timezone
logger = logging.getLogger()
logger.setLevel(logging.INFO)

API_URL = os.environ['API_URL']
S3_BUCKET = os.environ['S3_BUCKET']
s3 = boto3.client('s3')

def lambda_handler(event, context):
    http = urllib3.PoolManager()
    response = http.request('GET', API_URL)
    if response.status != 200:
        raise Exception(f"Request to {API_URL} failed with status code {response.status}")
    
    data = json.loads(response.data.decode('utf-8'))
    timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H-%M-%SZ') # Get partition timestamp in UTC
    logging.info(f'New data partition will be set at {timestamp}')
    file_path = f'pop_data/{timestamp}/data.json'
    s3.put_object(Bucket=S3_BUCKET, Key=file_path, Body=json.dumps(data))
    
    return {
        'statusCode': 200,
        'body': f"Data successfully saved to {file_path}"
    }
