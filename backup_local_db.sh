pg_dump -Fc --no-acl --no-owner -h localhost -U carlson lookup_repo > mydb.dump
echo
echo "  Copy mydb.dump copy http://psurl.s3.amazonaws.com/aaa/mydb.dump"
echo "  Make it public, then run 'upload_db_to_heroku.sh'"
echo "  Finally, delete mydb.db on S3"
echo
