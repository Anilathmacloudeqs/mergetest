print("started")

# Read values from command-line arguments
if len(sys.argv) != 8:
    print("Usage: main.py <github_token> <username> <repository> <source_branch> <destination_branch> <file_path> <commit_message>")
    sys.exit(1)

github_token, username, repository, source_branch, destination_branch, file_path_main, commit_message = sys.argv[1:]

source_api_url = f'https://api.github.com/repos/{username}/{repository}/contents/{file_path_main}?ref={source_branch}'
print(f"Source API URL: {source_api_url}")

destination_api_url = f'https://api.github.com/repos/{username}/{repository}/contents/{file_path_main}?ref={destination_branch}'
print(f"Destination API URL: {destination_api_url}")

github_headers = {"Authorization": f"token {github_token}"}
print("url set")

source_file_response = requests.get(source_api_url, headers=github_headers)

if source_file_response.status_code == 200:
    source_file_content = source_file_response.json()
    source_commit_sha = source_file_content['sha']

    decoded_content = base64.b64decode(source_file_content['content']).decode()

    payload = {
        'message': commit_message,
        'content': base64.b64encode(decoded_content.encode()).decode(),
        'branch': destination_branch,
        'sha': source_commit_sha
    }

    response = requests.put(destination_api_url, headers=github_headers, json=payload)

    if response.status_code == 201 or response.status_code == 200:
        print(f"File '{file_path_main}' successfully pushed to the '{destination_branch}' branch.")
    else:
        print(f"Error: Unable to push file. Status code: {response.status_code}", file=sys.stderr)
        print(response.json(), file=sys.stderr)
else:
    print(f"Error: Unable to fetch source file. Status code: {source_file_response.status_code}", file=sys.stderr)
