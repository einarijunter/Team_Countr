from requests import api
import RPi.GPIO as GPIO
import time
import uuid
import requests
import random
from datetime import datetime
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
PIR_PIN = 14 #assign GPIO14
GPIO.setup(PIR_PIN, GPIO.IN) #setup GPIO pin PIR as input

def rand_binary(weight):
    r = random.uniform(0, 1)
    if r >= weight:
        return 1
    else:
        return 0

def pir(pin):
    api_url = 'http://192.168.28.15:5000/records/'
    genders = ['male', 'female']
    location = 'Detention Center Libya'

    new_uuid = uuid.uuid1()
    new_timestamp = datetime.now()
    new_gender = random.choice(genders)
    new_child = rand_binary(0.9)
    if new_gender == "female" and new_child == 0:
        new_pregnant = rand_binary(0.9)
    else:
        new_pregnant = 0

    body = { 
        'location': location,
        'uuid': str(new_uuid),
        'timestamp': str(new_timestamp),
        'gender': str(new_gender),
        'child': int(new_child),
        'pregnantWoman': int(new_pregnant)
    }

    r = requests.post(api_url, json=body)

    print('{0} uuid added to database at time {1}'.format(new_uuid, new_timestamp))

    return True


GPIO.add_event_detect(14, GPIO.FALLING, callback=pir, bouncetime=100)
print("Welcome to Counter by Counter.IO!")
try:
        while True:
            time.sleep(0.001)
except KeyboardInterrupt:
    print('\nThank you for working with counter.io')
finally:
        GPIO.cleanup()