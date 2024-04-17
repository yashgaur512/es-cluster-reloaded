from python_terraform import *
import boto3
import re
import os
import uuid

from state_manager import StateManager

from credentials import AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN

os.environ['AWS_ACCESS_KEY_ID'] = AWS_ACCESS_KEY_ID
os.environ['AWS_SECRET_ACCESS_KEY'] = AWS_SECRET_ACCESS_KEY
os.environ['AWS_SESSION_TOKEN'] = AWS_SESSION_TOKEN

# class MyCode:
#     def __init__(self):
#         pass

#     def _write_backend_file(self, file_path, old_word, new_word):
#         try:
#             # Read the content of the file
#             with open(f"{file_path}/backend.tf", 'r') as file:
#                 file_content = file.read()

#             # Use regular expression to replace the word
#             new_content = re.sub(r'\b' + re.escape(old_word) + r'\b', new_word, file_content)

#             # Write the modified content back to the file
#             with open(f"{file_path}/backend.tf", 'w') as file:
#                 file.write(new_content)

#             command = f"rm -rf {file_path}/.terraform {file_path}/.terraform.lock.hcl"
#             os.system(command)
#             print("Word replaced successfully and removed state files!")
#         except Exception as e:
#             print(f"An error occurred: {e}")

#     def _init(self, file_path, old, new):
#         try:
#             if new != '':
#                 self._write_backend_file(file_path, old, new)
#                 self._destroy(file_path, old, new)
#                 response = self._update_state({
#                 "uuid": {"S": "ClusterFetchRecord"},
#                 "active": {"S": old},
#                 "new": {"S": ""}
#                 })
#             new = str(uuid.uuid4()) + '.tf'

#             if old == '':
#                 self._write_backend_file(file_path, 'dummy.tf', new)
#             else:
#                 self._write_backend_file(file_path, old, new)

#             return new
#         except Exception as e:
#             print(f"An error occurred: {e}")

#     def _destroy(self, file_path):
#         try:
#             tf = Terraform(working_dir=file_path)
#             tf.init(reconfigure=IsNotFlagged)
#             return_code, stderr = tf.destroy(force=IsNotFlagged, _auto_approve=IsFlagged)

#             curr_state = self._fetch_state()

#             if return_code == 0:
#                 print("Terraform destroy successful 1!")
#                 response = self._update_state({
#                 "uuid": {"S": "ClusterFetchRecord"},
#                 "active": {"S": curr_state['new']},
#                 "new": {"S": ""}
#                 })
#             else:
#                 print("Terraform destroy failed 1. See error message:")
#                 print(stderr)
#         except Exception as e:
#             print(f"An error occurred: {e}")
    
#     def _apply(self, file_path, old, new):
#         try: 
#             new = self._init(file_path, old, new)
#             tf = Terraform(working_dir=file_path)
#             tf.init(reconfigure=IsNotFlagged)
#             return_code, stderr = tf.apply(skip_plan=True)

#             if return_code == 0:
#                 print("Terraform Apply successful 1!")
#                 return new
#             else:
#                 print("Terraform Apply failed 1. See error message:")
#                 print(stderr)
#         except Exception as e:
#             print(f"An error occurred: {e}")
        
#     def cluster_create(self, file_path):
#         try:
#             curr_state = self._fetch_state()
#             active = curr_state['active']
#             new = curr_state['new']

#             self._init(file_path, active, new)
#             new = self._apply(file_path)

#             self._update_state({
#                 "uuid": {"S": "ClusterFetchRecord"},
#                 "active": {"S": curr_state['active']},
#                 "new": {"S": new}
#                 })

#         except Exception as e:
#             print(f"An error occurred: {e}")
    
#     def cluster_swap(self, file_path):
#         curr_state = self._fetch_state()
#         new = curr_state['new']
#         active = curr_state['active']
#         try:
#             if new == '':
#                 print("No new cluster found")
#                 return
#             else:
#                 self._write_backend_file(file_path, new, active)
#                 self._destroy(file_path)
#                 self._update_state({
#                     "uuid": {"S": "ClusterFetchRecord"},
#                     "active": {"S": new},
#                     "new": {"S": ""}
#                     })

#         except Exception as e:
#             print(f"An error occurred: {e}")

def has_status_key(obj):
    return isinstance(obj, dict) and 'status' in obj.keys()

def write_backend_file(file_path, old_word, new_word):
    try:
        # Read the content of the file
        with open(f"{file_path}/backend.tf", 'r') as file:
            file_content = file.read()

        # Use regular expression to replace the word
        new_content = re.sub(r'\b' + re.escape(old_word) + r'\b', new_word, file_content)

        # Write the modified content back to the file
        with open(f"{file_path}/backend.tf", 'w') as file:
            file.write(new_content)

        command = f"rm -rf {file_path}/.terraform {file_path}/.terraform.lock.hcl"
        os.system(command)
        print("Word replaced successfully and removed state files!")
    except Exception as e:
        print(f"An error occurred: {e}")


def build_object(statefile, node0_ip, node1_ip, node2_ip, nlb_dns_name):
    return {
        'statefile':{
            'S': statefile
        },
        'node1_ip': {
            'S': node1_ip
        },
        'node2_ip': {
            'S': node2_ip
        },
        'node0_ip': {
            'S': node0_ip
        },
        'nlb_dns_name': {
            'S': nlb_dns_name
        }
    }


state_manager = StateManager()

def create_es_infra():
    file_path = "/Users/yash.gaur/Synaptic Workspace/cluster_rotator/tech-dev"
    os.environ['AWS_ACCESS_KEY_ID'] = AWS_ACCESS_KEY_ID
    os.environ['AWS_SECRET_ACCESS_KEY'] = AWS_SECRET_ACCESS_KEY
    os.environ['AWS_SESSION_TOKEN'] = AWS_SESSION_TOKEN

    # Read state 
    new = state_manager.get_new_state()
    active = state_manager.get_active_state()

    if has_status_key(new):
        print('Couldn"t fetch new state')
        return
    
    if has_status_key(active):
        print('Couldn"t fetch active state')
        return

    print(new)

    if not new:
        statefile = state_manager.generate_state_pattern()
        write_backend_file(file_path, 'dummy.tfstate', statefile)

        tf = Terraform(working_dir=file_path)
        tf.init(reconfigure=IsNotFlagged)
        return_code, stdout, stderr = tf.apply(skip_plan=True)

        if return_code == 0:
            print("Terraform Apply successful!")
            result = tf.output()
            new_obj = build_object(statefile, result['es_node_0_private_ip']['value'], result['es_node_1_private_ip']['value'], result['es_node_2_private_ip']['value'], result['es_nlb_dns_name']['value'])
            active_obj = {}

            if active:
                active_obj = build_object(active['statefile'], active['node0_ip'], active['node1_ip'], active['node2_ip'], active['nlb_dns_name']) ## outputs
            res = state_manager.update_state(active_obj, new_obj)

            if res['ResponseMetadata']['HTTPStatusCode'] != 200:
                print('Couldn"t put object to DynamoDB, Initiating destruction of es Infra')
                return_code, stdout, stderr = tf.destroy(force=IsNotFlagged, _auto_approve=IsFlagged)
            print(res)
        else:
            print("Terraform Apply failed. See error message:")
            print(stderr)     

def update_route53_indexing():
    file_path = "/Users/yash.gaur/Synaptic Workspace/cluster_rotator/route53-indexing"
    os.environ['AWS_ACCESS_KEY_ID'] = AWS_ACCESS_KEY_ID
    os.environ['AWS_SECRET_ACCESS_KEY'] = AWS_SECRET_ACCESS_KEY
    os.environ['AWS_SESSION_TOKEN'] = AWS_SESSION_TOKEN

    # Read state 
    new = state_manager.get_new_state()

    if has_status_key(new):
        print('Couldn"t fetch new state')
        return

    print(new)

    tf = Terraform(working_dir=file_path)
    tf.init(reconfigure=IsNotFlagged)

    return_code, stdout, stderr = tf.apply(skip_plan=True,  var={'es_node_0_private_ip':new['node0_ip'], 
        'es_node_1_private_ip':new['node1_ip'],
        'es_node_2_private_ip':new['node2_ip'],
        'nlb_dns_name':new['nlb_dns_name']
        })
    
    if return_code == 0:
        print("Terraform indexing route53 applied successfully")
    else:
        print("Couldn't Apply indexing route53 completely. Destroy initiated! {stderr}")
        return_code, stdout, stderr = tf.destroy(force=IsNotFlagged, _auto_approve=IsFlagged)

def update_route53_read():
    file_path = "/Users/yash.gaur/Synaptic Workspace/cluster_rotator/route53-read"
    os.environ['AWS_ACCESS_KEY_ID'] = AWS_ACCESS_KEY_ID
    os.environ['AWS_SECRET_ACCESS_KEY'] = AWS_SECRET_ACCESS_KEY
    os.environ['AWS_SESSION_TOKEN'] = AWS_SESSION_TOKEN

    # Read state 
    new = state_manager.get_new_state()

    if has_status_key(new):
        print('Couldn"t fetch new state')
        return

    print(new)

    tf = Terraform(working_dir=file_path)
    tf.init(reconfigure=IsNotFlagged)

    return_code, stdout, stderr = tf.apply(skip_plan=True,  var={'es_node_0_private_ip':new['node0_ip'], 
        'es_node_1_private_ip':new['node1_ip'],
        'es_node_2_private_ip':new['node2_ip'],
        'nlb_dns_name':new['nlb_dns_name']
        })
    
    if return_code == 0:
        print("Terraform read route53 applied successfully")
    else:
        print("Couldn't Apply read route53 completely. Destroy initiated! {stderr}")
        return_code, stdout, stderr = tf.destroy(force=IsNotFlagged, _auto_approve=IsFlagged)

def destroy():
    file_path = "/Users/yash.gaur/Synaptic Workspace/cluster_rotator/tech-dev"
    os.environ['AWS_ACCESS_KEY_ID'] = AWS_ACCESS_KEY_ID
    os.environ['AWS_SECRET_ACCESS_KEY'] = AWS_SECRET_ACCESS_KEY
    os.environ['AWS_SESSION_TOKEN'] = AWS_SESSION_TOKEN

    # Read state 
    new = state_manager.get_new_state()
    active = state_manager.get_active_state()


    if has_status_key(new):
        print('Couldn"t fetch new state')
        return
    
    if has_status_key(active):
        print('Couldn"t fetch new state')
        return

    if active:
        statefile = active['statefile']
        
        write_backend_file(file_path, 'dummy.tfstate', statefile)

        tf = Terraform(working_dir=file_path)
        tf.init(reconfigure=IsNotFlagged)
        return_code, stdout, stderr = tf.destroy(force=IsNotFlagged, _auto_approve=IsFlagged)

        if return_code == 0:
            print("Terraform Destroy successful!")
            active_obj = build_object(new['statefile'], new['node0_ip'],  new['node1_ip'],  new['node2_ip'],  new['nlb_dns_name'])
            res = state_manager.update_state(active_obj, {})

            if res['ResponseMetadata']['HTTPStatusCode'] != 200:
                print('Couldn"t put object to DynamoDB.')
            print(res)
        else:
            print("Terraform Apply failed. See error message:")
            print(stderr) 
    else:
        print("No old cluster to Destroy!")
        new_obj = build_object(new['statefile'], new['node0_ip'],  new['node1_ip'],  new['node2_ip'],  new['nlb_dns_name'])
        res = state_manager.update_state(new_obj, {})

        if res['ResponseMetadata']['HTTPStatusCode'] != 200:
            print('Couldn"t put object to DynamoDB.')
        print(res)      


# create_es_infra() 

# update_route53_indexing()

# update_route53_read()

# destroy()


# new = state_manager.get_new_state()
# active = state_manager.get_active_state()
# put_obj = build_object(new['statefile'], new['node0_ip'],  new['node1_ip'],  new['node2_ip'],  new['nlb_dns_name']) 

# state_manager.update_state(put_obj, active)