import argparse
import yaml

# Parse command-line arguments
parser = argparse.ArgumentParser(description='Convert a Kubernetes Job YAML to a CronJob YAML')
parser.add_argument('input_file', help='Path to the input YAML file')
parser.add_argument('output_file', help='Path to the output YAML file')
parser.add_argument('cron_string', help='Cron string for the CronJob schedule')
args = parser.parse_args()

# Load the Kubernetes YAML file(s)
with open(args.input_file, "r") as f:
    docs = yaml.safe_load_all(f)
    yaml_docs = list(docs)

# Process each YAML document
cronjob_docs = []
for doc in yaml_docs:
    if doc.get("kind") == "Job":
        # Extract the relevant information from the Job YAML
        job_name = doc["metadata"]["name"]
        job_spec = doc["spec"]["template"]["spec"]
        job_schedule = args.cron_string

        # Construct the CronJob YAML document
        cronjob_doc = {
            "apiVersion": "batch/v1",
            "kind": "CronJob",
            "metadata": {
                "name": job_name + "-cron"
            },
            "spec": {
                "schedule": job_schedule,
                "jobTemplate": {
                    "spec": {
                        "template": {
                            "spec" : job_spec
                        }
                    }
                }
            }
        }
        cronjob_docs.append(cronjob_doc)
    else:
        # Leave the non-Job YAML document untouched
        cronjob_docs.append(doc)

# Write the processed YAML documents to a file
with open(args.output_file, "w") as f:
    for doc in cronjob_docs:
        yaml.dump(doc, f)
        f.write('---\n')

