# Circleci Context Example

This example shows how to provision GCP Workload Identity Federation for CircleCI oidc authentication.

It uses [mrolla/circleci provider](https://registry.terraform.io/providers/mrolla/circleci/latest) to create a CircleCI context
with variables required for circleci job to authenticate to GCP.

Example circleci job:

```yaml
version: "2.1"

orbs:
  gcp-cli: circleci/gcp-cli@3.0.1

commands:
  gcp-oidc-generate-cred-config-file:
    description: "Authenticate with GCP using a CircleCI OIDC token."
    parameters:
      project_id:
        type: env_var_name
        default: GCP_PROJECT_ID
      project_number:
        type: env_var_name
        default: GCP_PROJECT_NUMBER
      workload_identity_pool_id:
        type: env_var_name
        default: GCP_WIP_ID
      workload_identity_pool_provider_id:
        type: env_var_name
        default: GCP_WIP_PROVIDER_ID
      service_account_email:
        type: env_var_name
        default: GCP_SERVICE_ACCOUNT_EMAIL
      gcp_cred_config_file_path:
        type: string
        default: /home/circleci/gcp_cred_config.json
      oidc_token_file_path:
        type: string
        default: /home/circleci/oidc_token.json
    steps:
      - run:
          command: |
            # Store OIDC token in temp file
            echo $CIRCLE_OIDC_TOKEN > << parameters.oidc_token_file_path >>
            # Create a credential configuration for the generated OIDC ID Token
            gcloud iam workload-identity-pools create-cred-config \
                "projects/${<< parameters.project_number >>}/locations/global/workloadIdentityPools/${<< parameters.workload_identity_pool_id >>}/providers/${<< parameters.workload_identity_pool_provider_id >>}"\
                --output-file="<< parameters.gcp_cred_config_file_path >>" \
                --service-account="${<< parameters.service_account_email >>}" \
                --credential-source-file=<< parameters.oidc_token_file_path >>
  gcp-oidc-authenticate:
    description: "Authenticate with GCP using a GCP credentials file."
    parameters:
      gcp_cred_config_file_path:
        type: string
        default: /home/circleci/gcp_cred_config.json
    steps:
      - run:
          command: |
            # Configure gcloud to leverage the generated credential configuration
            gcloud auth login --brief --cred-file "<< parameters.gcp_cred_config_file_path >>"
            # Configure ADC
            echo "export GOOGLE_APPLICATION_CREDENTIALS='<< parameters.gcp_cred_config_file_path >>'" | tee -a $BASH_ENV
jobs:
  gcp-oidc-defaults:
    executor: gcp-cli/default
    steps:
      - gcp-cli/install
      - gcp-oidc-generate-cred-config-file
      - gcp-oidc-authenticate
      - run:
          name: Verify that gcloud is authenticated
          command: gcloud iam service-accounts list --project $GCP_PROJECT_ID
      - run:
          name: Verify that ADC works
          command: |
            ACCESS_TOKEN=$(gcloud auth application-default print-access-token)
            curl -f -i -H "Content-Type: application/x-www-form-urlencoded" -d "access_token=${ACCESS_TOKEN}" https://www.googleapis.com/oauth2/v1/tokeninfo

workflows:
  main:
    jobs:
      - gcp-oidc-defaults:
          name: Generate Creds File and Authenticate
          context:
            - gcp-oidc
```
