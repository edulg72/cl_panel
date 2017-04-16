require 'pg'

if ARGV.size > 0
  passo = ARGV[0].to_f
else
  passo = 0.08
end

if ARGV.size > 1
  sigla = "and iso2 = '#{ARGV[1]}' "
else
  sigla = nil
end

puts "#!/bin/bash\n\necho \"Start: $(date '+%d/%m/%Y %H:%M:%S')\"\n\ncase \"$3\" in"

db = PG::Connection.new(:hostaddr => '127.0.0.1', :dbname => 'ch_panel', :user => 'waze', :password => 'waze')
db.prepare('box_pais','select id from states where (ST_Overlaps(geom,ST_SetSRID(ST_MakeBox2D(ST_Point($1,$2),ST_Point($3,$4)),4326)) or ST_Contains(geom,ST_SetSRID(ST_MakeBox2D(ST_Point($1,$2),ST_Point($3,$4)),4326)) or ST_Contains(ST_SetSRID(ST_MakeBox2D(ST_Point($1,$2),ST_Point($3,$4)),4326),geom))')

db.exec("select ST_Xmin(ST_Envelope(ST_Union(geom))) as longoeste, ST_Xmax(ST_Envelope(ST_Union(geom))), ST_Ymax(ST_Envelope(ST_Union(geom))) as latnorte, ST_Ymin(ST_Envelope(ST_Union(geom))) as latsul from states").each do |pais|
  latIni = (pais['latnorte'].to_f.round(2) + 0.01).round(8)
  while latIni > pais['latsul'].to_f
#    puts "Latitude: [#{latIni} #{(latIni - passo).round(8)}]"
    area = false
    out = ''
    lonIni = (pais['longoeste'].to_f.round(2) - 0.01).round(8)
    while lonIni < pais['longleste'].to_f
#      puts "  Longitude: [#{lonIni} #{(lonIni + passo).round(8)}] #{area}"
      if area
        if db.exec_prepared('box_pais',[lonIni, (latIni - passo).round(8), (lonIni + passo).round(8), latIni]).ntuples == 0
          area = false
          puts "#{out} #{lonIni} #{(latIni - passo).round(8)} #{passo}"
          out = ''
        end
      else
        if db.exec_prepared('box_pais',[lonIni, (latIni - passo).round(8), (lonIni + passo).round(8), latIni]).ntuples > 0
          area = true
          out = "    ruby scan_UR.rb $1 $2 #{lonIni} #{latIni}"
        end
      end
      lonIni = (lonIni + passo).round(8)
    end
    latIni = (latIni - passo).round(8)
  end
  puts "  ;;"
end
puts "  *)\n    echo \"Usage: scan_UR.sh <user> <password>\"\n    exit 1\nesac\n"
