from python_terraform import *
import boto3
import uuid
from credentials import AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN

class StateManager:
    def __init__(self):
        self.db_client = boto3.client('dynamodb')
        self.db_name = 'Cluster_rotation_test'

    def get_active_state(self):
        os.environ['AWS_ACCESS_KEY_ID'] = AWS_ACCESS_KEY_ID
        os.environ['AWS_SECRET_ACCESS_KEY'] = AWS_SECRET_ACCESS_KEY
        os.environ['AWS_SESSION_TOKEN'] = AWS_SESSION_TOKEN
        try:
            response = self.db_client.get_item(TableName=self.db_name, Key={
                'key': {
                    'S': 'active'
                }
            })
            obj = response['Item']['data']['M']
            if not obj:
                return obj
            else:
                return {
                    'statefile': obj['statefile']['S'],
                    'node0_ip': obj['node0_ip']['S'],
                    'node1_ip': obj['node1_ip']['S'],
                    'node2_ip': obj['node2_ip']['S'],
                    'nlb_dns_name': obj['nlb_dns_name']['S']
                }
        except Exception as e:
            print(f"An error ocurred: {e}")
            return {'status':'failed'}

    def get_new_state(self):
        os.environ['AWS_ACCESS_KEY_ID'] = AWS_ACCESS_KEY_ID
        os.environ['AWS_SECRET_ACCESS_KEY'] = AWS_SECRET_ACCESS_KEY
        os.environ['AWS_SESSION_TOKEN'] = AWS_SESSION_TOKEN
        try:
            response = self.db_client.get_item(TableName=self.db_name, Key={
                'key': {
                    'S': 'new'
                }
            })
            obj = response['Item']['data']['M']
            if not obj:
                return obj
            else:
                return {
                    'statefile': obj['statefile']['S'],
                    'node0_ip': obj['node0_ip']['S'],
                    'node1_ip': obj['node1_ip']['S'],
                    'node2_ip': obj['node2_ip']['S'],
                    'nlb_dns_name': obj['nlb_dns_name']['S']
                }
        except Exception as e:
            print(f"An error ocurred: {e}")
            return {'status':'failed'}

    def update_state(self, active_object, new_object):
        os.environ['AWS_ACCESS_KEY_ID'] = AWS_ACCESS_KEY_ID
        os.environ['AWS_SECRET_ACCESS_KEY'] = AWS_SECRET_ACCESS_KEY
        os.environ['AWS_SESSION_TOKEN'] = AWS_SESSION_TOKEN
        try:
            response = self.db_client.batch_write_item(RequestItems={
                self.db_name:[
                    {
                        'PutRequest':{
                            'Item':{
                                'key': {
                                    'S': 'active',
                                },
                                'data': {
                                    'M': active_object
                                }
                            }
                        }
                    },
                    {
                        'PutRequest':{
                            'Item':{
                                'key': {
                                    'S': 'new',
                                },
                                'data': {
                                    'M': new_object
                                }
                            }
                        }
                    }
                ]
            })
            return response
        except Exception as e:
            print(f"An error ocurred: {e}")

    def generate_state_pattern(self):
        return str(uuid.uuid4()) + '.tfstate'
