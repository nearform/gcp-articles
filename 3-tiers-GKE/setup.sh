#!/bin/bash
echo "Enabling required services on GCP"
gcloud config set project $TF_VAR_project_id
gcloud services enable redis.googleapis.com vpcaccess.googleapis.com servicenetworking.googleapis.com container.googleapis.com artifactregistry.googleapis.com
