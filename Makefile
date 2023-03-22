init-mysql:
	kubectl apply -f dbs/mysql.yaml

clean:
	kubectl delete -f dbs/mysql.yaml

