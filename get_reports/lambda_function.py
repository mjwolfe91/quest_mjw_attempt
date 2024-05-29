import json
import numpy as np
import boto3

def lambda_handler(event, context):
    # Retrieve JSON data from S3
    s3_bucket = event['s3_bucket']
    s3_key = event['s3_key']
    json_data = get_json_from_s3(s3_bucket, s3_key)
    
    # Calculate mean and standard deviation
    mean, std = get_mean_and_std(json_data)
    
    # Return results
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
    # Load JSON data
    data = json.loads(json_data)
    
    # Extract population data for the years 2013 to 2018
    population_data = [entry['Population'] for entry in data['data'] if int(entry['Year']) >= 2013 and int(entry['Year']) <= 2018]
    
    # Calculate mean and standard deviation
    mean_population = np.mean(population_data)
    std_population = np.std(population_data)
    
    return mean_population, std_population
