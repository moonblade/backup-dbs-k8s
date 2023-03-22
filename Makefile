init-mysql:
	kubectl apply -f dbs/mysql.yaml

add-mysql-data:
	kubectl delete -f dbs/add-mysql-data.yaml && true
	kubectl apply -f dbs/add-mysql-data.yaml
	kubectl wait --for=condition=complete job/add-mysql-data
	kubectl logs jobs/add-mysql-data

clean:
	kubectl delete -f dbs/mysql.yaml

