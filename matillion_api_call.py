# import time
import requests
import json
import sys

user = ""
password = ""
project_env = ""
group = ""
version = ""
instance = ""
repo_username = ""
reps_password = ""
commitid = ""

arglength = len(sys.argv)
print("Arguments passed")
print(sys.argv)
print(arglength)

if arglength > 0:
    user = sys.argv[1]
    password = sys.argv[2]
    project = sys.argv[3]
    group = sys.argv[4]
    version = sys.argv[5]
    instance = sys.argv[6]
    repo_username = sys.argv[7]
    reps_password = sys.argv[8]
    commitid = sys.argv[9]


# code to pull the latest job code from Azure repos to matillion

azrepopull_url = '{0}/rest/v1/group/name/{1}/project/name/{2}/scm/fetch'.format(instance, group, project)
body = {
    "auth": {
        "authType": "HTTPS",
        "username": repo_username,
        "password": reps_password
    },
    "fetchOptions": {
        "removeDeletedRefs": "true",
        "thinFetch": "true"
    }
}
res_azrepo = requests.post(azrepopull_url, json=body, auth=(str(user), str(password)), verify=False)

azrepo_status = json.loads(res_azrepo.text)
print(azrepo_status)

if (azrepo_status['success']):
    # code to get the latest commitID
    url_switch = '{0}/rest/v1/group/name/{1}/project/name/{2}/version/name/default/scm/switchCommit'.format(
            instance, group, project)
    body_commit = {
            "commitID": commitid
        }
    print("CommitId:-",commitid)
    
    x = requests.post(url_switch, json=body_commit, auth=(str(user), str(password)), verify=False)
    print("switch")
    res = json.loads(x.text)
    print(res)
    if (res['success']):
        print("switched sucessfully")
        exit(0)
    else:
        print("switched failed")
        exit(1)
    #exit(0)
    """
    x = requests.post(url_switch, json=body_commit, auth=(str(user), str(password)), verify=False)
    print("switch")
    res = json.loads(x.text)
    print(res)
    if (res['success']):
        exit(0)
    else:
        exit(1)
    
    matillion_url = '{0}/rest/v1/group/name/{1}/project/name/{2}/scm/getState'.format(instance, group, project)
    x = requests.get(matillion_url, auth=(str(user), str(password)), verify=False)
    res_commits = json.loads(x.text)
    if len(res_commits) > 0:
        commitID = res_commits['result']['commits'][0]['referenceID']
        # code to switch the job to the latest version
        url_switch = '{0}/rest/v1/group/name/{1}/project/name/{2}/version/name/default/scm/switchCommit'.format(
            instance, group, project)

        body_commit = {
            "commitID": commitid
        }
        x = requests.post(url_switch, json=body_commit, auth=(str(user), str(password)), verify=False)
        print("switch")
        res = json.loads(x.text)
        print(res)
        if (res['success']):
            exit(0)
        else:
            exit(1)
    """
else:
    exit(1)