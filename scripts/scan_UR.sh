#!/bin/bash

LOG_FILE=/home/rails/cl_scan_PU.log

cd /home/rails/cl_panel/scripts

echo "Start: $(date '+%d/%m/%Y %H:%M:%S')"

psql -h $POSTGRESQL_DB_HOST -d cl_panel -U $POSTGRESQL_DB_USERNAME -c 'delete from ur; delete from mp;'

ruby scan_UR.rb $1 $2 -70.46 -17.5 -68.46 -18.5 1.0
ruby scan_UR.rb $1 $2 -70.46 -18.5 -67.46 -19.5 1.0
ruby scan_UR.rb $1 $2 -70.46 -19.5 -68.46 -20.5 1.0
ruby scan_UR.rb $1 $2 -70.46 -20.5 -67.46 -21.5 1.0
ruby scan_UR.rb $1 $2 -70.46 -21.5 -67.46 -22.5 1.0
ruby scan_UR.rb $1 $2 -71.46 -22.5 -66.46 -23.5 1.0
ruby scan_UR.rb $1 $2 -71.46 -23.5 -66.46 -24.5 1.0
ruby scan_UR.rb $1 $2 -71.46 -24.5 -67.46 -25.5 1.0
ruby scan_UR.rb $1 $2 -105.46 -25.5 -104.46 -26.5 1.0
ruby scan_UR.rb $1 $2 -80.46 -25.5 -79.46 -26.5 1.0
ruby scan_UR.rb $1 $2 -71.46 -25.5 -67.46 -26.5 1.0
ruby scan_UR.rb $1 $2 -109.46 -26.5 -108.46 -27.5 1.0
ruby scan_UR.rb $1 $2 -71.46 -26.5 -67.46 -27.5 1.0
ruby scan_UR.rb $1 $2 -71.46 -27.5 -68.46 -28.5 1.0
ruby scan_UR.rb $1 $2 -72.46 -28.5 -69.46 -29.5 1.0
ruby scan_UR.rb $1 $2 -72.46 -29.5 -69.46 -30.5 1.0
ruby scan_UR.rb $1 $2 -72.46 -30.5 -69.46 -31.5 1.0
ruby scan_UR.rb $1 $2 -72.46 -31.5 -69.46 -32.5 1.0
ruby scan_UR.rb $1 $2 -72.46 -32.5 -69.46 -33.5 1.0
ruby scan_UR.rb $1 $2 -81.46 -33.5 -80.46 -34.5 1.0
ruby scan_UR.rb $1 $2 -79.46 -33.5 -78.46 -34.5 1.0
ruby scan_UR.rb $1 $2 -72.46 -33.5 -69.46 -34.5 1.0
ruby scan_UR.rb $1 $2 -73.46 -34.5 -69.46 -35.5 1.0
ruby scan_UR.rb $1 $2 -73.46 -35.5 -69.46 -36.5 1.0
ruby scan_UR.rb $1 $2 -74.46 -36.5 -70.46 -37.5 1.0
ruby scan_UR.rb $1 $2 -74.46 -37.5 -70.46 -38.5 1.0
ruby scan_UR.rb $1 $2 -74.46 -38.5 -70.46 -39.5 1.0
ruby scan_UR.rb $1 $2 -74.46 -39.5 -71.46 -40.5 1.0
ruby scan_UR.rb $1 $2 -74.46 -40.5 -71.46 -41.5 1.0
ruby scan_UR.rb $1 $2 -74.46 -41.5 -71.46 -42.5 1.0
ruby scan_UR.rb $1 $2 -74.46 -42.5 -71.46 -43.5 1.0
ruby scan_UR.rb $1 $2 -75.46 -43.5 -70.46 -44.5 1.0
ruby scan_UR.rb $1 $2 -75.46 -44.5 -70.46 -45.5 1.0
ruby scan_UR.rb $1 $2 -75.46 -45.5 -71.46 -46.5 1.0
ruby scan_UR.rb $1 $2 -76.46 -46.5 -71.46 -47.5 1.0
ruby scan_UR.rb $1 $2 -76.46 -47.5 -71.46 -48.5 1.0
ruby scan_UR.rb $1 $2 -76.46 -48.5 -72.46 -49.5 1.0
ruby scan_UR.rb $1 $2 -76.46 -49.5 -72.46 -50.5 1.0
ruby scan_UR.rb $1 $2 -76.46 -50.5 -71.46 -51.5 1.0
ruby scan_UR.rb $1 $2 -75.46 -51.5 -67.46 -52.5 1.0
ruby scan_UR.rb $1 $2 -75.46 -52.5 -68.46 -53.5 1.0
ruby scan_UR.rb $1 $2 -74.46 -53.5 -68.46 -54.5 1.0
ruby scan_UR.rb $1 $2 -73.46 -54.5 -65.46 -55.5 1.0
ruby scan_UR.rb $1 $2 -70.46 -55.5 -66.46 -56.5 1.0

psql -h $POSTGRESQL_DB_HOST -d cl_panel -U $POSTGRESQL_DB_USERNAME -c 'update ur set city_id = (select id from cities where ST_Contains(geom, ur.position) limit 1) where city_id is null;'
psql -h $POSTGRESQL_DB_HOST -d cl_panel -U $POSTGRESQL_DB_USERNAME -c 'update mp set city_id = (select id from cities where ST_Contains(geom, mp.position) limit 1) where city_id is null;'
psql -h $POSTGRESQL_DB_HOST -d cl_panel -U $POSTGRESQL_DB_USERNAME -c 'update ur set comments = 0 where comments is null;'
psql -h $POSTGRESQL_DB_HOST -d cl_panel -U $POSTGRESQL_DB_USERNAME -c 'update mp set weight = 0 where weight is null;'
psql -h $POSTGRESQL_DB_HOST -d cl_panel -U $POSTGRESQL_DB_USERNAME -c 'refresh materialized view vw_ur;'
psql -h $POSTGRESQL_DB_HOST -d cl_panel -U $POSTGRESQL_DB_USERNAME -c 'refresh materialized view vw_mp;'
psql -h $POSTGRESQL_DB_HOST -d cl_panel -U $POSTGRESQL_DB_USERNAME -c "update updates set updated_at = current_timestamp where object = 'ur';"
psql -h $POSTGRESQL_DB_HOST -d cl_panel -U $POSTGRESQL_DB_USERNAME -c 'vacuum analyze;'

echo "End: $(date '+%d/%m/%Y %H:%M:%S')"
