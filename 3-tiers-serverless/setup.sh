#!/bin/bash
echo "Enabling required services on GCP"
PROJECT_ID=bench-serverless-3-tiers-app
gcloud config set project $PROJECT_ID
gcloud services enable redis.googleapis.com vpcaccess.googleapis.com servicenetworking.googleapis.com cloudfunctions.googleapis.com
