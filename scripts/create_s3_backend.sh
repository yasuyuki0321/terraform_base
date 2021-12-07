# 変数の設定
bucket_name="tfstate-123456789012" # 必要に応じて変更
region="ap-northeast-1"

# バケット作成
aws s3api create-bucket --bucket ${bucket_name} --create-bucket-configuration LocationConstraint=${region}

# バージョニングの有効化
aws s3api put-bucket-versioning --bucket ${bucket_name} --versioning-configuration Status=Enabled

# バケットの暗号化
aws s3api put-bucket-encryption --bucket ${bucket_name} \
    --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

# ブロックパブリックアクセス
aws s3api put-public-access-block --bucket ${bucket_name} \
    --public-access-block-configuration '{
              "BlockPublicAcls"      : true,
              "IgnorePublicAcls"     : true,
              "BlockPublicPolicy"    : true,
              "RestrictPublicBuckets": true
            }'

# 古いバージョンのtfstateの削除
aws s3api put-bucket-lifecycle-configuration --bucket ${bucket_name} \
    --lifecycle-configuration '{
  "Rules": [
    {
      "ID": "tfstate-delete-old-versions",
      "Prefix": "",
      "Status": "Enabled",
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 10
      },
      "AbortIncompleteMultipartUpload": {
        "DaysAfterInitiation": 10
      }
    }
  ]
}'

# Terraform StateLock用 DyanmoDB Tableの作成
aws dynamodb create-table \
	--table-name TerraformStateLockTable \
	--attribute-definitions AttributeName=LockID,AttributeType=S \
	--key-schema AttributeName=LockID,KeyType=HASH \
	--provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
	--no-cli-pager
