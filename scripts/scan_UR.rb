#!/usr/bin/ruby
# encoding: utf-8
#
# scan_UR.rb
# Populates tables on a PostgreSQL database with data from an area.
# (c)2015 Eduardo Garcia <edulg72@gmail.com>
#
# Usage:
# scan_UR.rb <user> <password> <west longitude> <north latitude> <east longitude> <south latitude> <step*>
#
# * Defines the size in degrees (width and height) of the area to be analyzed. On very dense areas use small values to avoid server overload.
#
require 'mechanize'
require 'pg'
require 'json'

if ARGV.size < 7
  puts "Usage: ruby scan_UR.rb <user> <password> <west longitude> <north latitude> <east longitude> <south latitude> <step>"
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
db.prepare('update_user','update users set username = $2, rank = $3 where id = $1')
db.prepare('insert_mp','insert into mp (id,resolved_by,resolved_on,weight,position,resolution,type) values ($1,$2,$3,$4,ST_SetSRID(ST_Point($5, $6), 4326),$7,$8)')
db.prepare('insert_ur',"insert into ur (id,position,resolved_by,resolved_on,created_on,resolution,type) values ($1,ST_SetSRID(ST_Point($2, $3), 4326),$4,$5,$6,$7,$8)")
db.prepare('update_ur','update ur set comments = $1, last_comment = $2, last_comment_on = $3, last_comment_by = $4, first_comment_on = $5 where id = $6')

$users = {}
db.exec('select * from users').each {|u| $users[u['id']] = u['rank']}

def scan_UR(db,agent,longWest,latNorth,longEast,latSouth,step,exec)
  lonStart = longWest
  while lonStart < longEast do
    lonEnd = [((lonStart + step)*100000).to_int/100000.0 , longEast].min
    lonEnd = longEast if (longEast - lonEnd) < (step / 4)
    latStart = latNorth
    while latStart > latSouth do
      latEnd = [((latStart - step)*100000).to_int/100000.0, latSouth].max
      latEnd = latSouth if (latEnd - latSouth) < (step / 4)
      area = [lonStart, latStart, lonEnd, latEnd]

      begin
        agent.cookie_jar.clear!
        wme = agent.get "https://www.waze.com/row-Descartes-live/app/Features?mapUpdateRequestFilter=1&problemFilter=0&bbox=#{area.join('%2C')}&sandbox=true"

        json = JSON.parse(wme.body)

        # Stores users that edit on this area
        json['users']['objects'].each do |u|
          if $users.keys.include?(u['id'].to_s)
            if $users[u['id'].to_s] != (u['rank']+1)
              db.exec_prepared('update_user', [u['id'],u['userName'],u['rank']+1]) if $users[u['id'].to_s] != (u['rank']+1)
              $users[u['id'].to_s] = u['rank']+1
            end
          else
            db.exec_prepared('insert_user', [u['id'],u['userName'],u['rank']+1])
            $users[u['id'].to_s] = u['rank']+1
          end
        end

        # Stores MPs data from the area
        json['problems']['objects'].each do |m|
          begin
            db.exec_prepared('insert_mp',[m['id'][2..-1], m['resolvedBy'], (m['resolvedOn'].nil? ? nil : Time.at(m['resolvedOn']/1000)), m['weight'], m['geometry']['coordinates'][0], m['geometry']['coordinates'][1], m['resolution'], m['subType']]) if db.exec_params('select id from mp where id = $1',[m['id'][2..-1]]).count == 0
          rescue PG::UniqueViolation
            puts 'm'
          rescue PG::InvalidTextRepresentation
            puts "#{m}"
          end
        end

        urs_area = []
        # Search IDs from area  URs
        json['mapUpdateRequests']['objects'].each do |u|
          begin
            db.exec_prepared('insert_ur', [u['id'], u['geometry']['coordinates'][0], u['geometry']['coordinates'][1], u['resolvedBy'], (u['resolvedOn'].nil? ? nil : Time.at(u['resolvedOn']/1000)), Time.at(u['driveDate']/1000), u['resolution'], u['type'] ] ) if db.exec_params('select id from ur where id = $1',[u['id']]).count == 0
#            urs_area << u['id']
            # Enquanto a busca estiver em modo sandbox, nao ha como buscar os comentarios e a atualizacao sera aqui
            db.exec_prepared('update_ur', [(u.has_key?('updatedOn') ? (u['updatedOn'].nil? ? 0 : 1) : 0 ),(u.has_key?('updatedOn') ? '-' : nil), (u.has_key?('updatedOn') ? (u['updatedOn'].nil? ? nil : Time.at(u['updatedOn']/1000)) : nil), (u.has_key?('updatedBy') ? u['updatedBy'] : nil), (u.has_key?('updatedOn') ? (u['updatedOn'].nil? ? nil : Time.at(u['updatedOn']/1000)) : nil), u['id']] )
          rescue PG::UniqueViolation
            puts '.'
          end
        end

#        # Collect data from URs
#        if urs_area.size > 0
#          ur = JSON.parse(agent.get("https://www.waze.com/row-Descartes-live/app/MapProblems/UpdateRequests?ids=#{urs_area.join('%2C')}&sandbox=true").body)

#          ur['updateRequestSessions']['objects'].each do |u|
#            begin
#              db.exec_prepared('update_ur', [(u.has_key?('comments') and u['comments'].size > 0 ? u['comments'].size : 0 ),(u.has_key?('comments') and u['comments'].size > 0 ? u['comments'][-1]['text'].gsub('"',"'") : nil), (u.has_key?('comments') and u['comments'].size > 0 ? Time.at(u['comments'][-1]['createdOn']/1000) : nil), (u.has_key?('comments') and u['comments'].size > 0 ? u['comments'][-1]['userID'] : nil), (u.has_key?('comments') and u['comments'].size > 0 ? Time.at(u['comments'][0]['createdOn']/1000) : nil), u['id']] )
#            rescue NoMethodError
#              puts "#{u}"
#              exit
#            end
#          end
#        end

      # Trata eventuais erros de conexao
      rescue Mechanize::ResponseCodeError
        # Caso o problema tenha sido no tamanho do pacote de resposta, divide a area em 4 pedidos menores (limitado a 3 reducoes)
        if exec < 3
          scan_UR(db,agent,area[0],area[1],area[2],area[3],(step/2),(exec+1))
        else
          puts "[#{Time.now.strftime('%d/%m/%Y %H:%M:%S')}] - ResponseCodeError em #{area}"
        end
      rescue JSON::ParserError
        # Erro no corpo do pacote - precisa ser investigada a razao deste erro
        puts "Erro JSON em #{area}"
      end

      latStart = latEnd
    end
    lonStart = lonEnd
  end
end

scan_UR(db,agent,LongWest,LatNorth,LongEast,LatSouth,Step,1)
