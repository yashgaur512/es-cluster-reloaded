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
    file_path = "/Users/yash.gaur/synaptic_workspace/cluster_rotator/route53-indexing"
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
    file_path = "/Users/yash.gaur/synaptic_workspace/cluster_rotator/route53-read"
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
    file_path = "/Users/yash.gaur/synaptic_workspace/cluster_rotator/tech-dev"
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

# write_backend_file('/Users/yash.gaur/synaptic_workspace/cluster_rotator/tech-dev', 'dummy.tfstate', '277447f3-c4ba-4071-974e-a9d641277bc4.tfstate')


# new = state_manager.get_new_state()
# active = state_manager.get_active_state()
# put_obj = build_object('statefile', 'node0_ip',  'node1_ip',  'node2_ip',  'nlb_dns_name') 

# state_manager.update_state(put_obj, put_obj)