#!/usr/bin/ruby
# encoding: utf-8
#
# scan_PU.rb
# Populates tables on a PostgreSQL database with data from an area.
# (c)2015 Eduardo Garcia <edulg72@gmail.com>
#
# Use:
# scan_PU.rb <user> <password> <west longitude> <north latitude> <east longitude> <south latitude> <step*>
#
# * Defines the size in degrees (width and height) of the area to be analyzed. On very dense areas use small values to avoid server overload.
#
require 'mechanize'
require 'pg'
require 'json'

if ARGV.size < 7
  puts "Use: ruby scan_PU.rb <user> <password> <west longitude> <north latitude> <east longitude> <south latitude> <step>"
  exit
end

USER = ARGV[0]
PASS = ARGV[1]
LongWest = ARGV[2].to_f
LatNorth = ARGV[3].to_f
LongEast = ARGV[4].to_f
LatSouth = ARGV[5].to_f
Step = ARGV[6].to_f

agent = Mechanize.new
agent.user_agent_alias = 'Mac Safari'
#begin
#  page = agent.get "https://www.waze.com/row-Descartes-live/app/Session"
#rescue Mechanize::ResponseCodeError
#  csrf_token = agent.cookie_jar.jar['www.waze.com']['/']['_csrf_token'].value
#end
#login = agent.post('https://www.waze.com/login/create', {"user_id" => USER, "password" => PASS}, {"X-CSRF-Token" => csrf_token})

db = PG::Connection.new(:hostaddr => ENV['POSTGRESQL_DB_HOST'], :dbname => 'cl_panel', :user => ENV['POSTGRESQL_DB_USERNAME'], :password => ENV['POSTGRESQL_DB_PASSWORD'])
db.prepare('insert_user','insert into users (id, username, rank) values ($1,$2,$3)')
db.prepare('insert_pu','insert into pu (id, created_by, created_on, position, staff, type, subtype, place_id) values ($1,$2,$3,ST_SetSRID(ST_Point($4,$5),4326),$6,$7,$8,$9)')
db.prepare('insert_place','insert into places (id,name,street_id,created_on,created_by,updated_on,updated_by,position,lock,approved,residential,category,ad_locked) values ($1,$2,$3,$4,$5,$6,$7,ST_SetSRID(ST_Point($8,$9),4326),$10,$11,$12,$13,$14)')

def scan_UR(db,agent,longWest,latNorth,longEast,latSouth,step,exec)
  lonStart = longWest
  while lonStart < longEast do
    lonEnd = [((lonStart + step)*100000).to_int/100000.0 , longEast].min
    lonEnd = longEast if (longEast - lonEnd) < (step / 2)
    latStart = latNorth
    while latStart > latSouth do
      latEnd = [((latStart - step)*100000).to_int/100000.0, latSouth].max
      latEnd = latSouth if (latEnd - latSouth) < (step / 2)
      area = [lonStart, latStart, lonEnd, latEnd]

      begin
        ['venueLevel=1&venueFilter=1&venueUpdateRequests=true','venueLevel=1&venueFilter=1,1,3'].each do |par|
          agent.cookie_jar.clear!
          wme = agent.get "https://www.waze.com/row-Descartes-live/app/Features?#{par}&bbox=#{area.join('%2C')}&sandbox=true"

          json = JSON.parse(wme.body)

          # Stores users that edit on this area
          json['users']['objects'].each do |u|
            if db.exec_params('select * from users where id = $1',[u['id']]).ntuples == 0
              db.exec_prepared('insert_user', [u['id'],u['userName'],u['rank']+1])
            end
          end

          # Stores PUs data from the area
          json['venues']['objects'].each do |v|
            if db.exec_params('select id from places where id = $1',[v['id']]).ntuples == 0
              db.exec_prepared('insert_place',[v['id'], (v['name'].nil? ? v['name'] : v['name'][0..99]), v['streetID'], (v.has_key?('createdOn') ? Time.at(v['createdOn']/1000) : nil), v['createdBy'], (v.has_key?('updatedOn') ? Time.at(v['updatedOn']/1000) : nil), v['updatedBy'], (v['geometry']['type']=='Point'? v['geometry']['coordinates'][0] : v['geometry']['coordinates'][0][0][0]), (v['geometry']['type']=='Point'? v['geometry']['coordinates'][1] : v['geometry']['coordinates'][0][0][1]), v['lockRank'], v['approved'], (v.has_key?('residential') ? v['residential'] : false), v['categories'][0], (v.has_key?('adLocked') ? v['adLocked'] : false) ])
            end
            if v.has_key?('venueUpdateRequests')
              pu = {'dateAdded' => (Time.now.to_i * 1000)}
              if v.has_key?('adLocked') and v['adLocked']
                pu['id']= v['venueUpdateRequests'][0]['id']
                pu['createdBy']= v['venueUpdateRequests'][0]['createdBy']
                pu['dateAdded']= v['venueUpdateRequests'][0]['dateAdded']
                pu['longitude']= (v['geometry']['type']=='Point'? v['geometry']['coordinates'][0] : v['geometry']['coordinates'][0][0][0])
                pu['latitude']= (v['geometry']['type']=='Point'? v['geometry']['coordinates'][1] : v['geometry']['coordinates'][0][0][1])
                pu['adLocked']= true
                pu['placeID']= v['id']
                pu['type']= v['venueUpdateRequests'][0]['type']
                pu['subType']= v['venueUpdateRequests'][0]['subType']
              else
                v['venueUpdateRequests'].each do |vu|
                  if vu.has_key?('dateAdded') and vu['dateAdded'] < pu['dateAdded']
                    pu['id']= v['id']
                    pu['createdBy']= vu['createdBy']
                    pu['dateAdded']= vu['dateAdded']
                    pu['longitude']= (v['geometry']['type']=='Point'? v['geometry']['coordinates'][0] : v['geometry']['coordinates'][0][0][0])
                    pu['latitude']= (v['geometry']['type']=='Point'? v['geometry']['coordinates'][1] : v['geometry']['coordinates'][0][0][1])
                    pu['adLocked']= (v.has_key?('adLocked') ? v['adLocked'] : false)
                    pu['placeID']= v['id']
                    pu['type']= vu['type']
                    pu['subType']= vu['subType']
                  end
                end
              end
              if pu.has_key?('id')
                begin
                  db.exec_prepared('insert_pu',[pu['id'], pu['createdBy'], Time.at(pu['dateAdded']/1000), pu['longitude'], pu['latitude'], pu['adLocked'], pu['type'], pu['subType'], pu['placeID'] ])
                rescue PG::UniqueViolation
                  puts "#{pu['id']}"
                end
              end
            end
          end
        end
      rescue Mechanize::ResponseCodeError, Mechanize::ChunkedTerminationError
        # If we had errors with the response size, divides area in four smaller areas (only 3 times)
        if exec < 3
          scan_UR(db,agent,area[0],area[1],area[2],area[3],(step/2),(exec+1))
        else
          puts "[#{Time.now.strftime('%d/%m/%Y %H:%M:%S')}] - ResponseCodeError at #{area}"
        end
      rescue JSON::ParserError
        # Error on package body - to be investigated...
        puts "JSON error at #{area}"
      end

      latStart = latEnd
    end
    lonStart = lonEnd
  end
end

scan_UR(db,agent,LongWest,LatNorth,LongEast,LatSouth,Step,1)
