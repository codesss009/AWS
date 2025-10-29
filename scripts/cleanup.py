import boto3
from collections import defaultdict

PROFILE = "aifarm_dev"
REGION = "eu-west-1"
QUERY = "valohai*"

session = boto3.Session(profile_name=PROFILE, region_name=REGION)
rex = session.client("resource-explorer-2")

# --- Get default view ---
resp = rex.list_views()
first_view = resp["Views"]
view_arn = first_view["ViewArn"] if isinstance(first_view, dict) else first_view

# --- Search ---
response = rex.search(QueryString=QUERY, ViewArn=view_arn, MaxResults=1000)
resources = response.get("Resources", [])

print(f"\n🔍 Total valohai resources found: {len(resources)}\n")

# --- Classify by resource type ---
counts = defaultdict(int)

for r in resources:
    arn = r["Arn"]

    if ":rds:" in arn and ":snapshot:" in arn:
        counts["RDS Snapshots"] += 1
    elif ":rds:" in arn and ":db:" in arn:
        counts["RDS Instances"] += 1
    elif ":elasticache:" in arn and ":snapshot:" in arn:
        counts["ElastiCache Snapshots"] += 1
    elif ":elasticache:" in arn and ":cluster:" in arn:
        counts["ElastiCache Clusters"] += 1
    elif ":ec2:" in arn and ":image/" in arn:
        counts["EC2 AMIs"] += 1
    elif ":ec2:" in arn and ":security-group/" in arn:
        counts["EC2 Security Groups"] += 1
    elif ":ec2:" in arn and ":key-pair/" in arn:
        counts["EC2 Key Pairs"] += 1
    elif ":iam::" in arn and ":role/" in arn:
        counts["IAM Roles"] += 1
    elif ":iam::" in arn and ":policy/" in arn:
        counts["IAM Policies"] += 1
    elif ":iam::" in arn and ":user/" in arn:
        counts["IAM Users"] += 1
    elif ":iam::" in arn and ":instance-profile/" in arn:
        counts["IAM Instance Profiles"] += 1
    elif ":s3:::" in arn:
        counts["S3 Buckets"] += 1
    elif ":secretsmanager:" in arn and ":secret:" in arn:
        counts["Secrets Manager Secrets"] += 1
    elif ":ssm:" in arn and ":parameter/" in arn:
        counts["SSM Parameters"] += 1
    elif ":elasticloadbalancing:" in arn and ":targetgroup/" in arn:
        counts["ELB Target Groups"] += 1
    elif ":logs:" in arn and ":log-group:" in arn:
        counts["CloudWatch Log Groups"] += 1
    elif ":sns:" in arn:
        counts["SNS Topics"] += 1
    else:
        counts["Other"] += 1

# --- Print clear breakdown ---
print("📊 Breakdown by resource type:")
for k, v in counts.items():
    print(f"   {k}: {v}")
