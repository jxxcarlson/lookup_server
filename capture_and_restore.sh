# Capture and download backup. Then upload it to local database

heroku pg:backups capture
heroku pg:backups download
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U carlson -d lookup_repo latest.dump
