import boto3
import uuid
from datetime import datetime
import json
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.getenv('LOG_TABLE_NAME'))

def lambda_handler(event, context):
    print("Incoming event:", event)

    try:
        body_raw = event.get('body')
        if not body_raw:
            raise ValueError("Missing body in request")

        body = json.loads(body_raw)

        if 'severity' not in body or 'message' not in body:
            raise ValueError("Missing 'severity' or 'message' field")

        log_entry = {
            'ID': str(uuid.uuid4()),
            'DateTime': datetime.utcnow().isoformat(),
            'Severity': body['severity'],
            'Message': body['message']
        }

        table.put_item(Item=log_entry)

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Log entry saved successfully.', 'log_entry': log_entry})
        }

    except Exception as e:
        print("Error:", str(e))
        return {
            'statusCode': 400,
            'body': json.dumps({'error': str(e)})
        }
