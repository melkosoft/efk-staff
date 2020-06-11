#!/bin/sh
DUMP_FILE_NAME="backupOn_`date +%Y-%m-%d-%H-%M`.tar"
echo "Creating dump: $DUMP_FILE_NAME" | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'

pg_dump -C -w -c --format=t --verbose --file=$DUMP_FILE_NAME 2>&1 | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'

if [ $? -ne 0 ]; then
  rm -v $DUMP_FILE_NAME | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
  echo "Back up not created, check db $PGHOST connection settings" | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
  exit 1
fi
echo 'Successfully Backed Up' | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
# Copy backup to s3
echo "Copying files to s3" | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
aws s3 cp $DUMP_FILE_NAME s3://$S3_BUCKET/$DUMP_FILE_NAME --debug 2>&1 | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
if [ $? -ne 0 ]; then
  rm -v $DUMP_FILE_NAME | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
  echo "Back up not copied to S3, check s3 bucket $S3_BUCKET settings" | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
  exit 1
fi
echo "Successfully Transferred to S3 bucket: $S3_BUCKET" | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
exit 0