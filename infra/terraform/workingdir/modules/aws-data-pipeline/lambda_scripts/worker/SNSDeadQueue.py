from datetime import datetime
import boto3
from botocore.exceptions import ClientError
import os
import logging
import hashlib
import json
import ast

ORIGIN_APP = os.environ['ORIGIN_APP']
APP_EVENT = os.environ['APP_EVENT']
EVENT_TEMP_FOLDER = os.environ['EVENT_TEMP_FOLDER']
EVENT_S3_KEY = os.environ['EVENT_S3_KEY']
EVENT_BUCKET_NAME = os.environ['EVENT_BUCKET_NAME']
string_date_format = "%Y-%m-%dT%H:%M:%S"

logger = logging.getLogger()
logger.setLevel(logging.INFO)

#origin, application, temp_folder, s3_key, e bucket name são definidas em main.tf como variáveis de ambiente

def lambda_handler(event, context):

    date_now = datetime.now()
    string_date = date_now.strftime(string_date_format)

    records = event['Records']

    for i in records:
        event_str = json.dumps(i, ensure_ascii=False)
        event_dict = json.loads(event_str)
        corrected_dict = ast.literal_eval(event_dict['body'])
        data = json.loads(corrected_dict['Message'])

        data_md5 = hashlib.md5(data.encode()).hexdigest()
        logger.info(data)
        filename = f"{data_md5}-error-{string_date}"
        filename_path = os.path.join(EVENT_TEMP_FOLDER, filename+".json")
        s3_obj_path = f"{EVENT_S3_KEY}{filename}.json"
        
        with open(filename_path, 'w') as raw_file:
            raw_file.write(str(event))

        s3 = boto3.client("s3")

        try:
            response = s3.upload_file(filename_path, EVENT_BUCKET_NAME, s3_obj_path)

        except ClientError as e:
            logging.error(e)

        #Deleta arquivo temporário
        os.remove(filename_path)