# Groot Merch Service

1. Create database in mysql with: `CREATE DATABASE groot_merch_service_dev`;
2. `cp config/database.yaml.template config/database.yaml`
3. `cp config/secrets.yaml.template config/secrets.yaml`


# Routes
```
:: GET ::
/merch/items/
/merch/items/:id
/merch/status
/merch/users
/merch/users/:netid

:: HEAD ::
/merch/items/
/merch/items/:id
/merch/status
/merch/users
/merch/users/:netid

:: OPTIONS ::
:splat

:: POST ::
/merch/items/
/merch/transactions/

:: PUT ::
/merch/items/:id
/merch/transactions/

:: DELETE ::
/merch/items/:id
```
