import boto3
import requests
import os
import logging
from bs4 import BeautifulSoup
from botocore.exceptions import NoCredentialsError, PartialCredentialsError
from datetime import datetime

S3_BUCKET_NAME = os.environ['S3_BUCKET_NAME']
BASE_URL = os.environ['BLS_URL']
dir_url = f'{BASE_URL}/pub/time.series/pr/'
USER_AGENT = 'mjwolfeBLSanalytics/1.0 (michael.j.wolfe91@gmail.com)'
headers = {'User-Agent': USER_AGENT}

s3_client = boto3.client('s3')

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        files_to_update = get_files_to_update()
        for source_file, s3_key in files_to_update.items():
            update_file_in_s3(source_file, s3_key)
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
    files_to_update = {}
    source_file_info = get_file_info(dir_url)
    for file, ts in source_file_info.items():
        s3_key = file.split('/')[-1].replace('.','_')
        update_file = is_file_updated(s3_key, file, ts)
        if update_file:
            files_to_update[file] = s3_key
    return files_to_update

def is_file_updated(s3_key, source_file_name, source_ts): #check if file is current, so that we don't upload the same file twice
    try:
        s3_response = s3_client.head_object(Bucket=S3_BUCKET_NAME, Key=s3_key)
    except s3_client.exceptions.ClientError as e:
        if e.response['Error']['Code'] == '404':
            logging.info("New file identified. It will be downloaded.")
            return True
        else:
            logging.error(f'Error checking if file is updated: {e}')
            return False
    s3_last_modified = datetime.strptime(s3_response['LastModified'], '%a, %d %b %Y %H:%M:%S %Z')
    logging.info(f"File {source_file_name} was last modified on {source_ts}")
    return source_ts > s3_last_modified

def update_file_in_s3(source_file, s3_key):
    file_url = f'{BASE_URL}{source_file}'
    file_content = download_file(file_url)
    
    if file_content:
        s3_client.put_object(Bucket=S3_BUCKET_NAME, Key=s3_key, Body=file_content)

def download_file(url):
    headers = {'User-Agent': USER_AGENT}
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.text
    else:
        logging.error(f'Failed to download {url}. Status code: {response.status_code}')
        return None

def get_file_info(url):
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        soup = BeautifulSoup(response.text, 'html.parser')
        file_links = soup.find_all('a', href=True) # get anchors
        file_info = {} # Dictionary to store file name and last updated date
        
        for link in file_links[1:]: # Extract filename and last updated date from each anchor tag
            file_name = link['href']
            last_updated = get_last_modified(f'{BASE_URL}{file_name}')
            file_info[file_name] = last_updated
        
        return file_info
    else:
        logging.error("Failed to fetch data from the URL. Status code:", response.status_code)
        return None

def get_last_modified(url):
    response = requests.head(url, headers=headers) # check file metadata since HTML is a mess

    if response.status_code == 200 and 'Last-Modified' in response.headers:
        last_modified_str = response.headers['Last-Modified']
        last_modified = datetime.strptime(last_modified_str, '%a, %d %b %Y %H:%M:%S %Z')
        return last_modified
    else:
        logging.error("Failed to retrieve Last-Modified header for URL:", url)
        return None