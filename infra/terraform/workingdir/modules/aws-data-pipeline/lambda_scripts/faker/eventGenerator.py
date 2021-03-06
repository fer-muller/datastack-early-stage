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
EVENTS = os.environ['EVENTS']
logger.info(f"Events: {EVENTS}")
EVENTS = EVENTS.strip('][').split(",")

for i in EVENTS:
    i_index = EVENTS.index(i)
    i = i.split('"')[1]
    EVENTS[i_index] = i

logger.info(f"Events: {EVENTS}")
logger.info(f"SNS: {SNS_ARN}")

fake = Faker()
events = {}

def lambda_handler(event, context):
    chosen_event = randint(0, len(EVENTS)-1)
    chosen_event = EVENTS[chosen_event]
    logger.info(f"Chosen Event: {chosen_event}")

    def login():
        dispositives = ['ios', 'android', 'windows', 'macos', 'linux']
        chosen_dispositive = randint(0, len(dispositives)-1)
        events['user'] = fake.name()
        events['date'] = datetime.strftime(fake.date_between(start_date='-365d', end_date='today'), '%Y-%m-%d')
        events['dispositive'] = dispositives[chosen_dispositive]
        events['city'] = fake.city()
        events['country'] = fake.country()
        event_json = json.dumps(events)
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
        events['user'] = fake.name()
        events['value'] = randint(99, 549)
        events['date'] = datetime.strftime(fake.date_between(start_date='-365d', end_date='today'), '%Y-%m-%d')
        events['salesperson'] = fake.name()
        events['subscription'] = chosen_subscription
        events['billing_method'] = chosen_billing_method
        event_json = json.dumps(events)
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



