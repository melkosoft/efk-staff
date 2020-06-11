DUMP_FILE_NAME="backupOn`date +%Y-%m-%d-%H-%M`.dump"
echo "Creating dump: $DUMP_FILE_NAME"

cd pg_backup

pg_dump -C -w --format=c --blobs > $DUMP_FILE_NAME

if [ $? -ne 0 ]; then
  rm $DUMP_FILE_NAME
  echo "Back up not created, check db $PGHOST connection settings"
  exit 1
fi
echo 'Successfully Backed Up'
# Copy backup to s3
echo "Copying files to s3"
aws s3 cp $DUMP_FILE_NAME s3://$S3_BUCKET/$DUMP_FILE_NAME
if [ $? -ne 0 ]; then
  rm $DUMP_FILE_NAME
  echo "Back up not copied to S3, check s3 bucket $S3_BUCKET settings"
  exit 1
fi
echo "Successfully Transferred to S3 bucket: $S3_BUCKET"
exit 0