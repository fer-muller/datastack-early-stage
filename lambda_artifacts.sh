echo "========== Starting Lambda artifacts creation =========="

echo "========== Entering lambda fake event generator directory"

cd infra/terraform/workingdir/modules/aws-data-pipeline/lambda_scripts/faker

echo "========== Creating fake event generator package"
mkdir python
cd python 
pip install --target=./ faker
cd ../
for file in *; do zip -r ${file%.*}.zip $file; done
mv python.zip faker.zip
rm -r python

echo "========== Fake event package creation completed!"

echo "========== Entering lambda worker directory"
cd ../
cd worker

echo "========== Ziping .py ETL files =========="
for file in *; do zip -r ${file%.*}.zip $file; done
echo "========== .zip creation completed =========="

echo "========== Lambda Artifacts creation completed =========="