import boto3
import logging
import sys

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

# Initialize S3 client
s3_client = boto3.client('s3')

# S3 Bucket Name and File to Upload
bucket_name = "example-bucket"  # Ensure this matches your Terraform setup
file_path = "file/path/file.txt"  # Path of the file on your local machine that you want to upload to s3 bucket

def upload_file():
    try:
        s3_client.upload_file(file_path, bucket_name, "uploaded_file.txt") # we have changed the file.txt(local_machine) name to uploaded_file.txt(S3)
        logger.info(f"Successfully uploaded {file_path} to {bucket_name}.")
    except Exception as e:
        logger.error(f"Failed to upload {file_path} to {bucket_name}: {str(e)}")

if __name__ == "__main__":
    upload_file()
