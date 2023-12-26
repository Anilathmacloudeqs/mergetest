import requests
import base64
import os

def push_file_to_branch(username, repository, source_branch, destination_branch, file_path, commit_message):
    # GitHub API URLs
    source_api_url = f'https://api.github.com/repos/{username}/{repository}/contents/{file_path}?ref={source_branch}'
    destination_api_url = f'https://api.github.com/repos/{username}/{repository}/contents/{file_path}?ref={destination_branch}'

    # GitHub Personal Access Token (PAT)
    access_token = os.environ['PAT_TOKEN']
    headers = {'Authorization': f'token {access_token}'}

    # Check if the file exists in the destination branch
    destination_file_response = requests.get(destination_api_url, headers=headers)
    
    if destination_file_response.status_code == 200:
        # File exists, delete the existing file
        destination_file_content = destination_file_response.json()
        destination_commit_sha = destination_file_content['sha']
        delete_payload = {
            'message': f'Delete {file_path}',
            'branch': destination_branch,
            'sha': destination_commit_sha
        }
        delete_response = requests.delete(destination_api_url, headers=headers, json=delete_payload)

        if delete_response.status_code != 200:
            print(f"Error: Unable to delete existing file. Status code: {delete_response.status_code}")
            print(delete_response.json())
            return

    # Fetch the source file content
    source_file_response = requests.get(source_api_url, headers=headers)

    if source_file_response.status_code == 200:
        source_file_content = source_file_response.json()
        source_commit_sha = source_file_content['sha']

        decoded_content = base64.b64decode(source_file_content['content']).decode()

        # Push the new file to the destination branch
        push_payload = {
            'message': commit_message,
            'content': base64.b64encode(decoded_content.encode()).decode(),
            'branch': destination_branch,
            'sha': source_commit_sha
        }

        push_response = requests.put(destination_api_url, headers=headers, json=push_payload)

        if push_response.status_code == 201 or push_response.status_code == 200:
            print(f"File '{file_path}' successfully pushed to the '{destination_branch}' branch.")
        else:
            print(f"Error: Unable to push file. Status code: {push_response.status_code}")
            print(push_response.json())
    else:
        print(f"Error: Unable to fetch source file. Status code: {source_file_response.status_code}")

# Example usage
push_file_to_branch(
    'Anilathmacloudeqs',
    'mergetest',
    'main',
    'release',
    'hello.py',
    'Commit message'
)
