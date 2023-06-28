# Connect to MySQL by running a shell inside MySQL's pod
kubectl exec -ti $(kubectl get pods -n mysql-test --selector=app.kubernetes.io/instance=mysql-release -o=jsonpath='{.items[0].metadata.name}') -n mysql-test -- bash

# From inside the shell, use the mysql CLI to insert some data into the test database
# Create "test" db

# Replace mysql-root-password with the password that you have set while installing MySQL
mysql --user=root --password=<mysql-root-password>

mysql> CREATE DATABASE test;
Query OK, 1 row affected (0.00 sec)

mysql> USE test;
Database changed

# Create "pets" table
mysql> CREATE TABLE pets (name VARCHAR(20), owner VARCHAR(20), species VARCHAR(20), sex CHAR(1), birth DATE, death DATE);
Query OK, 0 rows affected (0.02 sec)

# Insert row to the table
mysql> INSERT INTO pets VALUES ('Puffball','Diane','hamster','f','1999-03-30',NULL);
Query OK, 1 row affected (0.01 sec)

# View data in "pets" table
mysql> SELECT * FROM pets;
+----------+-------+---------+------+------------+-------+
| name     | owner | species | sex  | birth      | death |
+----------+-------+---------+------+------------+-------+
| Puffball | Diane | hamster | f    | 1999-03-30 | NULL  |
+----------+-------+---------+------+------------+-------+
1 row in set (0.00 sec)