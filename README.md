# Set Deployment Status GitHub Action

This GitHub Action updates the status of an existing GitHub deployment using the GitHub REST API.

## Features
- Updates the status for an existing deployment.
- Uses the GitHub REST API (no dependencies on the CLI or local git).
- Fully supports GitHub Organizations and user-owned repositories.
- Outputs the deployment status id and state for use in subsequent workflow steps.

## Inputs
| Name          | Description                                              | Required | Default |
|---------------|----------------------------------------------------------|----------|---------|
| `deployment-id` | The id of the deployment to update                    | Yes      | N/A     |
| `state`       | The state of the deployment status (`queued`, `in_progress`, `success`, `failure`, `error`, `pending`, `inactive`) | Yes | N/A |
| `description` | A short description of the deployment status            | Yes      | N/A     |
| `org-name`    | The name of the GitHub Organization                     | Yes      | N/A     |
| `repo-name`   | The name of the repository                              | Yes      | N/A     |
| `token`       | GitHub token with access to update a deployment status  | Yes      | N/A     |

## Outputs
| Name                      | Description                                         |
|---------------------------|-----------------------------------------------------|
| `result`                  | Result of the action ("success" or "failure")      |
| `error-message`           | Error message if the action fails                  |
| `deployment-status-id`    | The id of the deployment status                    |
| `deployment-status-state` | The state of the deployment status                 |

## Usage
1. **Add the Action to Your Workflow**:  
   Create or update a workflow file (e.g., `.github/workflows/set-deployment-status.yml`) in your repository.  
   **Ensure you pass all required inputs and use a valid token with deployments write access.**

2. **Reference the Action**:  
   Use the action by referencing the repository and version (e.g., `v1`).

3. **Example Workflow**:
   ```yaml
   name: Set Deployment Status
   on:
     workflow_dispatch:

   jobs:
     set-deployment-status:
       runs-on: ubuntu-latest
       steps:
         - name: Set Deployment Status
           id: set-deployment-status
           uses: la-actions/set-deployment-status@v1
           with:
             deployment-id: '123456789'
             state: 'success'
             description: 'Deployment completed successfully.'
             org-name: ${{ github.repository_owner }}
             repo-name: ${{ github.event.repository.name }}
             token: ${{ secrets.GITHUB_TOKEN }}

         - name: Print Result
           run: |
             if [[ "${{ steps.set-deployment-status.outputs.result }}" == "success" ]]; then
               echo "Deployment status updated successfully."
               echo "Status ID: ${{ steps.set-deployment-status.outputs.deployment-status-id }}"
               echo "State: ${{ steps.set-deployment-status.outputs.deployment-status-state }}"
             else
               echo "Error: ${{ steps.set-deployment-status.outputs.error-message }}"
               exit 1
             fi
   ```
