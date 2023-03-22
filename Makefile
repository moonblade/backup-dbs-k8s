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

dbs: mysql mariadb postgresql

clean-mysql:
	helm uninstall mysql

clean-mariadb:
	helm uninstall mariadb

clean-postgresql:
	helm uninstall postgresql

clean: clean-mariadb clean-mysql clean-postgresql
	

