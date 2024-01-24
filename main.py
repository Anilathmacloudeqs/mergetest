print("starting main.py")
username = 'Anilathmacloudeqs'
repository = 'mergetest'
source_branch = 'main'
destination_branch = 'release'
file_path = 'hello.py'
github_token = "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"
headers = {'Authorization': f'token {github_token}'}

source_api_url = f'https://api.github.com/repos/{username}/{repository}/contents/{file_path}?ref={source_branch}'
    destination_api_url = f'https://api.github.com/repos/{username}/{repository}/contents/{file_path}?ref={destination_branch}'
    destination_sha_url = f'https://api.github.com/repos/{username}/{repository}/git/refs/heads/{destination_branch}'

    source_file_response = requests.get(source_api_url, headers=headers)

    if source_file_response.status_code == 200:
        source_file_content = source_file_response.json()
        source_commit_sha = source_file_content['sha']

        destination_sha_response = requests.get(destination_sha_url, headers=headers)

        if destination_sha_response.status_code != 200:
            print(f"Error: Unable to get destination commit SHA. Status code: {destination_sha_response.status_code}", file=sys.stderr)
            codepipeline.put_job_failure_result(
                jobId=event['CodePipeline.job']['id'],
                failureDetails={
                    'type': 'JobFailed',
                    'message': f'Unable to get destination commit SHA. Status code: {destination_sha_response.status_code}'
                }
            )
            return

        destination_commit_sha = destination_sha_response.json()['object']['sha']

        if source_commit_sha == destination_commit_sha:
            print(f"File '{file_path}' is already up to date in the '{destination_branch}' branch.")
            codepipeline.put_job_success_result(jobId=event['CodePipeline.job']['id'])
        else:
            destination_file_response = requests.get(destination_api_url, headers=headers)

            if destination_file_response.status_code == 200:
                existing_file_content = destination_file_response.json()
                existing_file_sha = existing_file_content['sha']

                new_decoded_content = base64.b64decode(source_file_content['content']).decode()
                encoded_content = base64.b64encode(new_decoded_content.encode()).decode()

                update_payload = {
                    'message': 'Update existing file',
                    'content': encoded_content,
                    'sha': existing_file_sha,
                    'branch': destination_branch
                }

                update_url = f'https://api.github.com/repos/{username}/{repository}/contents/{file_path}'
                update_response = requests.put(update_url, headers=headers, json=update_payload)

                if update_response.status_code == 200:
                    print(f"File '{file_path}' successfully updated in the '{destination_branch}' branch.")
                    codepipeline.put_job_success_result(jobId=event['CodePipeline.job']['id'])
                else:
                    print(f"Error: Unable to update file. Status code: {update_response.status_code}", file=sys.stderr)
                    print(update_response.json(), file=sys.stderr)
                    
            else:
                new_decoded_content = base64.b64decode(source_file_content['content']).decode()
                encoded_content = base64.b64encode(new_decoded_content.encode()).decode()

                create_payload = {
                    'message': 'Create new file',
                    'content': encoded_content,
                    'branch': destination_branch
                }

                create_url = f'https://api.github.com/repos/{username}/{repository}/contents/{file_path}'
                create_response = requests.put(create_url, headers=headers, json=create_payload)

                if create_response.status_code == 200 or create_response.status_code == 201:
                    print(f"File '{file_path}' successfully pushed to the '{destination_branch}' branch.")
                    codepipeline.put_job_success_result(jobId=event['CodePipeline.job']['id'])
                else:
                    print(f"Error: Unable to push file. Status code: {create_response.status_code}", file=sys.stderr)
                    print(create_response.json(), file=sys.stderr)
                    
    else:
        print(f"Error: Unable to fetch source file. Status code: {source_file_response.status_code}", file=sys.stderr)
