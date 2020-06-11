#!/bin/sh
S3_BUCKET=auth-dev-backup
echo "List db backups from AWS S3 bucket" | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
OUTPUT=$(aws s3 ls s3://$S3_BUCKET | grep ".tar")

if [ $? -ne 0 ]; then
  echo "Failed to list files for $S3_BUCKET bucket" | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
  exit 0
fi
if [ "$OUTPUT" == "" ]; then
  echo "No backups found in $S3_BUCKET S3 bucket" | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
  exit 0
fi
cnt=1
for i in $OUTPUT; do
  word=$(( cnt % 4 ))
  if [ $word == 0 ]; then
     FILENAMES="$FILENAMES $i"
  fi
  cnt=$(( $cnt + 1 ))
done
echo "List of backups: $FILENAMES" | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
DUMP_FILE_NAME=$(echo $FILENAMES | tr ' ' '\n' | sort -r | tr '\n' ' ' | cut -d' ' -f1)
echo " Downloading file $DUMP_FILE_NAME from S3 bucket" | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
aws s3 cp s3://$S3_BUCKET/$DUMP_FILE_NAME $DUMP_FILE_NAME --debug 2>&1 | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
if [ $? -ne 0 ]; then
  rm -v $DUMP_FILE_NAME 2>&1 | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
  echo "Failed copy $DUMP_FILE_NAME from S3, check s3 bucket $S3_BUCKET settings" | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
  exit 0
fi
# ls -l .
pg_restore --verbose -c -d $PGDATABASE $DUMP_FILE_NAME 2>&1 | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
if [ $? -ne 0 ]; then
  rm -v $DUMP_FILE_NAME 2>&1 | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
  echo "Failed to restore database from file $DUMP_FILE_NAME" | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
  exit 0
fi
echo 'Successfully Restored DB' | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
rm -v $DUMP_FILE_NAME 2>&1 | ts -s '(%H:%M:%.S)]' | ts '[%Y-%m-%d %H:%M:%S'
exit 0