from faker import Faker
from random import randint
from datetime import datetime
import json
import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

SNS_ARN = os.environ['SNS_ARN']
EVENTS = list(os.environ['EVENTS'])
logger.info(f"Events: {EVENTS}")
logger.info(f"SNS: {SNS_ARN}")

chosen_event = EVENTS[randint(0, len(EVENTS)-1)]
logger.info(f"Chosen Event: {chosen_event}")
event = {}
fake = Faker()

def lambda_handler(event, context):
    def login():
        dispositives = ['ios', 'android', 'windows', 'macos', 'linux']
        chosen_dispositive = randint(0, len(dispositives)-1)
        event['user'] = fake.name()
        event['date'] = datetime.strftime(fake.date_between(start_date='-1d', end_date='today'), '%Y-%m-%d')
        event['dispositive'] = dispositives[chosen_dispositive]
        event['city'] = fake.city()
        event['country'] = fake.country()
        event_json = json.dumps(event)
        sns = send_sns(event_json)
        return sns

    def registration():
        profile = fake.profile()
        #print(profile)
        profile.pop('current_location')
        profile['birthdate'] = datetime.strftime(profile['birthdate'], '%Y-%m-%d')
        event_json = json.dumps(profile)
        sns = send_sns(event_json)
        return sns

    def newPayment():
        subscription_list = ['tier1', 'tier2', 'tier3']
        chosen_subscription = subscription_list[randint(0, len(subscription_list)-1)]
        billing_method_list = ['credit_card', 'billet', 'debit_card']
        chosen_billing_method = billing_method_list[randint(0, len(billing_method_list)-1)]
        event['user'] = fake.name()
        event['value'] = randint(99, 549)
        event['date'] = datetime.strftime(fake.date_between(start_date='-1d', end_date='today'), '%Y-%m-%d')
        event['salesperson'] = fake.name()
        event['subscription'] = chosen_subscription
        event['billing_method'] = chosen_billing_method
        event_json = json.dumps(event)
        sns = send_sns(event_json)
        return sns

    def send_sns(event_json):
        client = boto3.client('sns')
        response = client.publish(
            TopicArn=SNS_ARN,
            Message=event_json,
            MessageAttributes={
                "event": {
                    "DataType": "String",
                    "StringValue": str(chosen_event)
                }
            }
        )
        return response

    def generate_data():
        if chosen_event == 'login':
            data = login()
        elif chosen_event == 'registration':
            data = registration()
        else:
            data = newPayment()
        
        logger.info(data)

    generate_data()



