import json
from datetime import datetime
import boto3
from botocore.exceptions import ClientError
import os
import pandas as pd
import logging
import ast
import hashlib

athena_date_format = "%Y-%m-%d %H:%M:%S"
string_date_format = "%Y-%m-%dT%H:%M:%S.%f"
app_date_format = "%Y-%m-%d %H:%M:%S"

ORIGIN_APP = os.environ['ORIGIN_APP']
APP_EVENT = os.environ['APP_EVENT']
EVENT_TEMP_FOLDER = os.environ['EVENT_TEMP_FOLDER']
EVENT_S3_RAW_KEY = os.environ['EVENT_S3_RAW_KEY']
EVENT_S3_STAGING_KEY = os.environ['EVENT_S3_STAGING_KEY']
EVENT_BUCKET_NAME = os.environ['EVENT_BUCKET_NAME']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):

    data_record_dict = []

    # Function to convert dates to best format for manipulation in athena
    # In this example, the origin date format already is athena best format
    def to_athena_date_format(date, mask):
        return datetime.strptime(date, mask).strftime(athena_date_format)

    date_now = datetime.now()
    athena_date = date_now.strftime(athena_date_format)
    string_date = date_now.strftime(string_date_format)
    def raw_injection(raw_event):
        records = event['Records']

        for i in records:
            event_str = json.dumps(i, ensure_ascii=False)
            event_dict = json.loads(event_str)
            corrected_dict = ast.literal_eval(event_dict['body'])
            data = json.loads(corrected_dict['Message'])

            #Anonimization for username
            data['user'] = hashlib.sha256(data['user'].encode()).hexdigest()
            logger.info(data)

            filename = f"{ORIGIN_APP}-{APP_EVENT}-{string_date}"
            filename_path = os.path.join(EVENT_TEMP_FOLDER, filename+".json")
            s3_obj_path = f"{EVENT_S3_RAW_KEY}{filename}.json"
            
            with open(filename_path, 'w') as raw_file:
                raw_file.write(str(data))

            s3 = boto3.client("s3")

            try:
                response = s3.upload_file(filename_path, EVENT_BUCKET_NAME, s3_obj_path)
            except ClientError as e:
                logging.error(e)

            #Deleta arquivo temporário
            os.remove(filename_path)

    def get_data(event):
        records = event['Records']

        for i in records:
            event_str = json.dumps(i, ensure_ascii=False)
            event_dict = json.loads(event_str)
            corrected_dict = ast.literal_eval(event_dict['body'])
            data = json.loads(corrected_dict['Message'])

            data_record_map = {}

            data_record_map['user_id'] = hashlib.sha256(data['user'].encode()).hexdigest()
            data_record_map['value'] = data['value']
            data_record_map['subscription'] = data['subscription']
            data_record_map['salesperson'] = data['salesperson']
            data_record_map['payment_date'] = data['date']
            data_record_map['extraction_date'] = athena_date

    def staging_injection(data_record_dict):

        df_records = pd.DataFrame(data_record_dict)
        records_filename = f"{ORIGIN_APP}-{APP_EVENT}-newPayment-{string_date}.parquet"
        records_filename_path = os.path.join(EVENT_TEMP_FOLDER, records_filename)

        df_records.to_parquet(f"{EVENT_TEMP_FOLDER}{records_filename}", index=False)
        records_s3_obj_path = f"{EVENT_S3_STAGING_KEY}newPayment/{records_filename}"

        s3 = boto3.client("s3")
        try:
            response = s3.upload_file(records_filename_path, EVENT_BUCKET_NAME, records_s3_obj_path)
        except ClientError as e:
            logging.error(e)
            return False

        os.remove(records_filename_path)
        return True

    raw_injection(event)
    get_data(event)
    staging_injection(data_record_dict)