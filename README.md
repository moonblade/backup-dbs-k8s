Next task: I would like you to create a way to backup MySQL / mariadb / PostgreSQL and MongoDB in a Kubernetes cluster and write the backup daily to an S3 storage....

# Backups

1. First create databases of mysql, mariadb, postres and mongo and add some dummy data to each of them

```
make dbs
```


2. Setup minio for backup

```
make minio
```


3. Backup

``` 
make backups
```

4. Test that the backups worked

```
make minio-port-forward
```

Login with admin, password. download each backup and verify the contents

4. Cleanup

```
make clean
```

5. Get cron instead of single jobs

```
make cron-jobs
```

