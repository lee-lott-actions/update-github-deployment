# GitHub Action

Description of what the GitHub Action does.

## Features
- Feature #1
- Feature #2
- Feature #3

## Inputs
| Name          | Description                                           | Required | Default |
|---------------|-------------------------------------------------------|----------|---------|
| `input-1`     | Description of input-1.                               | Yes      | N/A     |
| `input-2`     | Description of input-2.                               | Yes      | N/A     |
| `input-3`     | Description of input-3.                               | Yes      | N/A    |

## Outputs
| Name           | Description                                                   |
|----------------|---------------------------------------------------------------|
| `result`       | Result of the action ("success" or "failure").                |
| `error-message`| Error message if the action fails.                            |

## Usage
1. **Add the Action to Your Workflow**:
   Create or update a workflow file (e.g., `.github/workflows/your-action.yml`) in your repository.

2. **Reference the Action**:
   Use the action by referencing the repository and version (e.g., `v1`).

3. **Example Workflow**:
   ```yaml
   name: Your Action
   on:
     issues:
       types: [labeled]
   jobs:
     open-issue:
       runs-on: ubuntu-latest
       steps:
         - name: Run Action
           id: open
           uses: lee-lott-actions/your-action@v1
           with:
             input-1: '1'
             input-2: '2'
             input-3: '3'
         - name: Print Result
           run: |
             if [[ "${{ steps.open.outputs.result }}" == "success" ]]; then
               echo "Issue #${{ github.event.issue.number }} successfully opened."
             else
               echo "Error: ${{ steps.open.outputs.error-message }}"
               exit 1
             fi
## To Do After Cloning
- Update the Readme.  Please include the title, description, a brief list of features at a minimum, Inputs, Outputs and Uasage.
- Add the correct inputs and outputs to the `action.yml` file and call your function found in the `action.ps1`.
- Update the `action.ps1` with your PowerShell code.
- Update the `integration-tests` step in `./.github/workflows/build-check.yml` to provide the correct inputs to your action.
- Configure the `./tests/Start-MockServer.ps1` to include any additonal API calls that are needed.
- Configure the `./tests/action.Tests.ps1` to include any unit tests
