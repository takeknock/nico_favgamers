#!/usr/local/rbenv/shims/ruby --

require 'rexml/document'
require 'open-uri'
require 'cgi'
require 'pstore'

#該当する動画IDを保存
@array = Array.new()
$idarr = Array.new()

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

$idarr=["sm24743359","sm24750817","sm24744551"]

#取得したIDを使って、繰り返し走査
def showvideoinfo
	idarr = Array.new()
	db = PStore.new("nicorank/pstore.db")
	db.transaction do
		idarr = db["id"]
	end
	if idarr=="" then
		#db.transaction do
		#	db["id"]= $idarr
		#end
		print "レトルト、ふぅ、つわはす、キヨの動画はゲームランキング100に入っていませんでした。\n"
	else
		#p idarr
		print "Content-type: text/html\n\n"
		print "<html>"
		print "<head>\n"
		print "<title>レトルト、ふぅ、つわはす、キヨ実況ランクイン動画一覧</title>\n"
		print "<link href=\"./stylesheets/screen.css\" media=\"screen, projection\" rel=\"stylesheet\" type=\"text/css\" />\n"
		print "</head>\n"
		print "<body>\n"
		print "<div id=\"header\">"
		print "<p>ゲーム実況者のレトルト、ふぅ、つわはす、キヨの24時間ランキングtop100入りしている動画をログインなしで視聴できます（１時間おき更新）</p>"
		print "</div>"
		print "<div id=\"main\">\n"

		idarr.each do |id|
			xml = open("http://ext.nicovideo.jp/api/getthumbinfo/"+id)
			#puts "http://ext.nicovideo.jp/api/getthumbinfo/"+id
			doc = REXML::Document.new(xml)	
			title = doc.elements['nicovideo_thumb_response/thumb/title'].text
			description = doc.elements['nicovideo_thumb_response/thumb/description'].text
			print "<div id = \"content\">\n"
			print "<h2>"+title+"</h2>\n"
			print "<p>"+description+"</p>"
			print "<div id = \"movie\">\n"
			print "<script type=\"text/javascript\" src=\"http://ext.nicovideo.jp/thumb_watch/"+id+"\"></script><noscript><a href=\"http://www.nicovideo.jp/watch/"+id+"\">"+title+"</a></noscript>\n"
			print "</div>\n"
			print "</div>\n"
		end
		print "</div>\n"
		print "</body>\n"
		print "</html>\n"
	end
end


setids()
showvideoinfo()
#puts doc2.elements['nicovideo_thumb_response/thumb/user_id'].text
#p doc.elements['nicovideo_thumb_response/thumb/description'].text
#doc.elements['nicovideo_thumb_response/thumb/tags'].elements.each do |tag|
#	puts tag.text
#	if tag.text=="レトルト"|| tag.text=="つわはす" || tag.text=="相対性理論（実況プレイヤー）" then
#		@array.push(doc.elements['nicovideo_thumb_response/thumb/video_id'].text)
#		break
#	end
#@array.push(tag.text)
#tag.elements.each do |elem|
#	puts elem.text
#end
#end

