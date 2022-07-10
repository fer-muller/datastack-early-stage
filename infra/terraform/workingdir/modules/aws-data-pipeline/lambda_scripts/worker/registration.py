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

    def ssn_anonimization(ssn_string):
        ssn_numbers = ssn_string.split('-')
        ssn_numbers1 = ("*"*len(ssn_numbers[0]))
        ssn_numbers2 = ("*"*len(ssn_numbers[1]))
        ssn_numbers3 = ("*"*(len(ssn_numbers[2])-2)+ssn_numbers[2][2:])
        new_ssn = ssn_numbers1+"-"+ssn_numbers2+"-"+ssn_numbers3
        return new_ssn

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

            #Anonimization for user and ssn
            data['user'] = hashlib.sha256(data['name'].encode()).hexdigest()
            data['ssn'] = ssn_anonimization(data['ssn'])

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

            data_record_map['user_id'] = hashlib.sha256(data['name'].encode()).hexdigest()
            data_record_map['username'] = data['username']
            data_record_map['email'] = data['mail']
            data_record_map['job'] = data['job']
            data_record_map['ssn'] = ssn_anonimization(data['ssn'])
            data_record_map['adress'] = data['adress']
            data_record_map['birthdate'] = to_athena_date_format(data['birthdate'], app_date_format)
            data_record_map['gender'] = data['sex']
            data_record_map['blood_group'] = data['blood_group']
            data_record_map['websites'] = data['website']
            data_record_map['extraction_date'] = athena_date

    def staging_injection(data_record_dict):

        df_records = pd.DataFrame(data_record_dict)
        records_filename = f"{ORIGIN_APP}-{APP_EVENT}-registration-{string_date}.parquet"
        records_filename_path = os.path.join(EVENT_TEMP_FOLDER, records_filename)

        df_records.to_parquet(f"{EVENT_TEMP_FOLDER}{records_filename}", index=False)
        records_s3_obj_path = f"{EVENT_S3_STAGING_KEY}registration/{records_filename}"

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