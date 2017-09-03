# Groot Merch Service

[![Build Status](https://travis-ci.org/acm-uiuc/groot-merch-service.svg?branch=master)](https://travis-ci.org/acm-uiuc/groot-merch-service)

[![Join the chat at https://acm-uiuc.slack.com/messages/C6XGZD212/](https://img.shields.io/badge/slack-groot-724D71.svg)](https://acm-uiuc.slack.com/messages/C6XGZD212/)


## Getting Started

1. Create database in mysql with: `CREATE DATABASE groot_merch_service_dev`;
2. `cp config/secrets.yaml.template config/secrets.yaml`
3. Fill in appropriate database credentials in `config/secrets.yaml`.

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
