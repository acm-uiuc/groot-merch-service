# Groot Merch Service

Groot core development:

[![Join the chat at https://gitter.im/acm-uiuc/groot-development](https://badges.gitter.im/acm-uiuc/groot-development.svg)](https://gitter.im/acm-uiuc/groot-development?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Questions on how to add your app to Groot or use the Groot API:

[![Join the chat at https://gitter.im/acm-uiuc/groot-users](https://badges.gitter.im/acm-uiuc/groot-users.svg)](https://gitter.im/acm-uiuc/groot-users?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Getting Started

1. Create database in mysql with: `CREATE DATABASE groot_merch_service_dev`;
2. `cp config/database.yaml.template config/database.yaml`
3. `cp config/secrets.yaml.template config/secrets.yaml`


# Routes
```
:: GET ::
/merch/items
/merch/items/:id
/merch/status
/merch/users
/merch/users/:netid
/merch/users/pins/:pin

:: POST ::
/merch/items
/merch/transactions

:: PUT ::
/merch/items/:id
/merch/transactions

:: DELETE ::
/merch/items/:id
```
