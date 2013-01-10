#!/bin/sh
puppet module build . && cp -rfv pkg/akumria-postgresql-1.1.1/* ~/git/puppet-sandbox/modules/postgresql/
echo Done!
