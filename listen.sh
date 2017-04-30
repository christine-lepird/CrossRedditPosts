#!/bin/bash

# Watches the data grow as the webscraper does its work

watch 'psql -h <<SECRET>> -U postgres -d postgres -c "select count(*) from posts;"'