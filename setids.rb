#!/usr/local/rbenv/shims/ruby --

require 'rexml/document'
require 'open-uri'
require 'cgi'
require 'pstore'

#ランキングから動画のID取得(スクレイピング)
#より柔軟に動画を取ってくるために、クローラ作る必要ある。

#動画・アニメ・絵ランキングから、該当タグを持つ動画を取得する
def getvideoids

	idarr = Array.new()
	#xml = open('http://ext.nicovideo.jp/api/getthumbinfo/sm24738921')
	#xml2 = open('http://ext.nicovideo.jp/api/getthumbinfo/sm24743135')
	#xml = open('http://www.nicovideo.jp/ranking/fav/daily/g_culture2?rss=atom')
	xml = open('http://www.nicovideo.jp/ranking/fav/daily/game?rss=atom')

	doc = REXML::Document.new(xml)
	#doc2 = REXML::Document.new(xml2)
	#Zp xml
	#puts doc

	doc.elements.each do |elem|
		#puts "----------------"
		elem.elements.each do |elem2|
			#puts elem2.text
			if elem2.name=="entry" then
				elem2.elements.each do |entry|
					if entry.name == "title" then
						#puts "----------------"
						#puts entry.text
					end
					if entry.name == "id" then
						#ここの動画id(sm...)を配列に
						idt = /sm+\d{1,}/.match(entry.text).to_s
						#puts idt
						if idt=="" then
							next
						end
						xmlt = open('http://ext.nicovideo.jp/api/getthumbinfo/'+idt)
						#puts 'http://ext.nicovideo.jp/api/getthumbinfo/'+idt
						doct = REXML::Document.new(xmlt)
						uidt = doct.elements['nicovideo_thumb_response/thumb/user_id'].text
						#レトルト、ふぅ、つわはす、キヨ
						if uidt == "14930070" || uidt == "36072280" || uidt == "13697131" || uidt == "14047911" then 
							idarr.push(idt)
						end
					end
				end
			end
		end
	end
	return idarr
end

def setids
	db = PStore.new("nicorank/pstore.db")
	idarr = Array.new()
	time = Time.new()
	db.transaction do
		time = db["time"]
	end
	#puts time
	#puts Time.now
	if time == nil then
		time = Time.now
		idarr = getvideoids()
		db.transaction do
			db["id"] = idarr
			db["time"] = Time.now
		end
	end
	ntime = Time.now
	margin = (ntime-time).divmod(60)
	if margin[0]>=60 then
		idarr = getvideoids()

		db.transaction do
			db["id"] = idarr
			db["time"] = Time.now
		end
	print "動画が更新されました。\n"
	else
		#60分以内にアクセスがあれば更新しない。
	end
end

