echo "========== Starting Lambda artifacts creation =========="

echo "========== Entering lambda worker directory"
cd infra/terraform/workingdir/modules/sqs_lambda_s3/lambda_scripts/worker

echo "========== Ziping .py files =========="
for file in *; do zip -r ${file%.*}.zip $file; done
echo "========== .zip creation completed =========="

echo "========== Lambda Artifacts creation completed =========="