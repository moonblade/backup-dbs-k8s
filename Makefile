init:
	helm repo add bitnami https://charts.bitnami.com/bitnami

mysql:
	helm upgrade --install mysql bitnami/mysql --set auth.rootPassword=password --set primary.persistence.enabled=false
	kubectl wait --for=condition=ready --timeout=5m pod mysql-0 
	kubectl exec -it mysql-0 -- bash -c "mysql -u root -ppassword -h mysql -e \"DROP DATABASE IF EXISTS db;CREATE DATABASE db; USE db; CREATE TABLE dummy (dummy varchar(255), date datetime); INSERT INTO dummy VALUES ('mysqldata', curdate()); SELECT * from dummy;\";"

mariadb:
	helm install mariadb bitnami/mariadb --set auth.rootPassword=password --set primary.persistence.enabled=false
	kubectl wait --for=condition=ready --timeout=5m pod mariadb-0 
	kubectl exec -it mariadb-0 -- bash -c "mariadb -u root -ppassword -h mariadb -e \"DROP DATABASE IF EXISTS db;CREATE DATABASE db; USE db; CREATE TABLE dummy (dummy varchar(255), date datetime); INSERT INTO dummy VALUES ('mariadbdata', curdate()); SELECT * from dummy;\";"

postgresql:
	helm install postgresql bitnami/postgresql --set auth.postgresPassword=password --set primary.persistence.enabled=false
	kubectl wait --for=condition=ready --timeout=5m pod postgresql-0 
	kubectl exec -it postgresql-0 -- bash -c "export PGPASSWORD=password; psql -U postgres -c \"CREATE TABLE public.dummy(dummy character varying, date timestamp); INSERT INTO public.dummy VALUES ('asdf',CURRENT_TIMESTAMP::timestamp); SELECT * from public.dummy;\""

mongodb:
	helm install mongodb bitnami/mongodb --set auth.rootPassword=password --set persistence.enabled=false
	kubectl wait --for=condition=ready --timeout=5m pod -l app.kubernetes.io/instance=mongodb
	kubectl exec -it $$(kubectl get pod -l app.kubernetes.io/instance=mongodb -o custom-columns=":metadata.name" | tail -n1) -- bash -c "mongosh mongodb://localhost:27017 -u root -p password --eval 'db.dummy.insertOne({name:\"mongocontent\"}); db.dummy.find({})'"

minio:
	helm install minio bitnami/minio --set auth.rootPassword=password
	kubectl wait --for=condition=ready --timeout=5m pod -l app.kubernetes.io/name=minio

mongo-backup:
	-kubectl delete jobs mongodump
	kubectl apply -f resources/mongo.yaml
	kubectl wait --for=condition=complete job/mongodump
	kubectl logs jobs/mongodump
	kubectl logs jobs/mongodump -c mc
	@echo mongo backup done

mariadb-backup:
	-kubectl delete jobs mariadb-backup
	kubectl apply -f resources/mariadb.yaml
	kubectl wait --for=condition=complete job/mariadb-backup
	kubectl logs jobs/mariadb-backup
	kubectl logs jobs/mariadb-backup -c mc
	@echo mariadb backup done

mysql-backup:
	-kubectl delete jobs mysql-backup
	kubectl apply -f resources/mysql.yaml
	kubectl wait --for=condition=complete job/mysql-backup
	kubectl logs jobs/mysql-backup
	kubectl logs jobs/mysql-backup -c mc
	@echo mysql backup done

postgresql-backup:
	-kubectl delete jobs postgresql-backup
	kubectl apply -f resources/postgresql.yaml
	kubectl wait --for=condition=complete job/postgresql-backup
	kubectl logs jobs/postgresql-backup
	kubectl logs jobs/postgresql-backup -c mc
	@echo postgresql backup done

clean-jobs:
	-kubectl delete -f resources/mongo.yaml
	-kubectl delete -f resources/mysql.yaml
	-kubectl delete -f resources/postgresql.yaml
	-kubectl delete -f resources/mariadb.yaml

resources/mongo-cron.yaml:
	python resources/jobToCron.py "resources/mongo.yaml" "resources/mongo-cron.yaml" "0 0 * * *"

resources/mariadb-cron.yaml:
	python resources/jobToCron.py "resources/mariadb.yaml" "resources/mariadb-cron.yaml" "0 0 * * *"

resources/mysql-cron.yaml:
	python resources/jobToCron.py "resources/mysql.yaml" "resources/mysql-cron.yaml" "0 0 * * *"

resources/postgresql-cron.yaml:
	python resources/jobToCron.py "resources/postgresql.yaml" "resources/postgresql-cron.yaml" "0 0 * * *"

clean-cron:
	rm resources/*-cron.yaml

cron-jobs: resources/mongo-cron.yaml resources/mysql-cron.yaml resources/mariadb-cron.yaml resources/postgresql-cron.yaml

dbs: mysql mariadb postgresql mongodb

clean-mysql:
	-helm uninstall mysql

clean-mariadb:
	-helm uninstall mariadb

clean-postgresql:
	-helm uninstall postgresql

clean-mongodb:
	-helm uninstall mongodb

clean-minio:
	-helm uninstall minio

clean: clean-mariadb clean-mysql clean-postgresql clean-mongodb clean-minio
