init-mysql:
	kubectl apply -f dbs/mysql.yaml

add-mysql-data: init-mysql
	kubectl delete --ignore-not-found=true -f dbs/add-mysql-data.yaml && true
	kubectl apply -f dbs/add-mysql-data.yaml
	kubectl wait --for=condition=complete job/add-mysql-data
	kubectl logs jobs/add-mysql-data

mysql: add-mysql-data

dbs: mysql mariadb

init-mariadb:
	kubectl apply -f dbs/mariadb.yaml

add-mariadb-data: init-mariadb
	kubectl delete --ignore-not-found=true -f dbs/add-mariadb-data.yaml
	kubectl apply -f dbs/add-mariadb-data.yaml
	kubectl wait --for=condition=complete job/add-mariadb-data
	kubectl logs jobs/add-mariadb-data

mariadb: add-mariadb-data

clean:
	kubectl delete -f dbs/mysql.yaml
	kubectl delete -f dbs/add-mysql-data.yaml
	kubectl delete -f dbs/mariadb.yaml
	kubectl delete -f dbs/add-mysql-data.yaml

