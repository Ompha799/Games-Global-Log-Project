import boto3
import json
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.getenv('LOG_TABLE_NAME'))

def lambda_handler(event, context):
    response = table.scan()
    items = sorted(response['Items'], key=lambda x: x['DateTime'], reverse=True)[:100]
    
    return {
        'statusCode': 200,
        'body': json.dumps(items)
    }
