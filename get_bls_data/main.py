import boto3
import requests
from botocore.exceptions import NoCredentialsError, PartialCredentialsError
from datetime import datetime

S3_BUCKET_NAME = 'mjw-cloudquest-bls-data'
BASE_URL = 'https://download.bls.gov/pub/time.series/pr/'

USER_AGENT = 'mjwolfeBLSanalytics/1.0 (michael.j.wolfe91@gmail.com)'
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    try:
        files_to_update = get_files_to_update()
        for file_name in files_to_update:
            update_file_in_s3(file_name)
        return {
            'statusCode': 200,
            'body': 'Success'
        }
    except NoCredentialsError:
        return {
            'statusCode': 401,
            'body': 'Error: No AWS credentials found.'
        }
    except PartialCredentialsError:
        return {
            'statusCode': 401,
            'body': 'Error: Incomplete AWS credentials.'
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': f'Error: {str(e)}'
        }

def get_files_to_update():
    files_to_update = set()
    index_file_url = BASE_URL + 'pr.series'
    index_file_content = download_file(index_file_url)
    
    if index_file_content:
        lines = index_file_content.split('\n')
        for line in lines:
            parts = line.split()
            if parts:
                file_name = parts[0]
                if is_file_updated(file_name):
                    files_to_update.add(file_name)
    return files_to_update

def is_file_updated(file_name):
    try:
        s3_response = s3_client.head_object(Bucket=S3_BUCKET_NAME, Key=file_name)
        s3_last_modified = s3_response['LastModified']
        
        file_url = BASE_URL + file_name
        headers = {'User-Agent': USER_AGENT}
        file_response = requests.head(file_url, headers=headers)
        url_last_modified = file_response.headers.get('Last-Modified')

        if url_last_modified:
            url_last_modified = datetime.strptime(url_last_modified, '%a, %d %b %Y %H:%M:%S GMT')
            #return url_last_modified > s3_last_modified
            print(f"File {file_name} was last modified on {url_last_modified}")
        return True
    except s3_client.exceptions.NoSuchKey:
        return True
    except Exception as e:
        print(f'Error checking if file is updated: {e}')
        return False

def update_file_in_s3(file_name):
    file_url = BASE_URL + file_name
    file_content = download_file(file_url)
    
    if file_content:
        s3_client.put_object(Bucket=S3_BUCKET_NAME, Key=file_name, Body=file_content)

def download_file(url):
    headers = {'User-Agent': USER_AGENT}
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.text
    else:
        print(f'Failed to download {url}. Status code: {response.status_code}')
        return None
    
files_to_update = get_files_to_update()
print(files_to_update)