#!/usr/local/rbenv/shims/ruby --

require 'rexml/document'
require 'open-uri'
require 'cgi'
require 'pstore'
require './setids.rb'

#取得したIDを使って、繰り返し走査
def showvideoinfo
	idarr = Array.new()
	db = PStore.new("nicorank/pstore.db")
	db.transaction do
		idarr = db["id"]
		@time = db["time"]
	end
	#time = @time.year+"年"+@time.month+"月"+@time.day+"日"+@time.hour+"時"+@time.min+"分"+@time.sec+"秒"
	header = "ゲーム実況者のただてる、アブ、P-P、レトルト、ふぅ、つわはす、キヨの24時間ランキングtop100入りしている動画をログインなしで視聴できます（24時間おき更新: 前回の更新 "
	#time = @time.hour+"時"+@time.min+"分"+@time.sec+"秒"
	if idarr=="" then
		#db.transaction do
		#	db["id"]= $idarr
		#end
		print "ただてる、アブ、レトルト、ふぅ、つわはす、キヨの動画はゲームランキング100に入っていませんでした。\n"
	else
		#p idarr
		print "Content-type: text/html\n\n"
		print "<html>"
		print "<head>\n"
		print "<title>24時間ランキング</title>\n"
		print "<link href=\"./stylesheets/screen.css\" media=\"screen, projection\" rel=\"stylesheet\" type=\"text/css\" />\n"

		print "</head>\n"
		print "<body>\n"
		print "<div id=\"header\">"
		print "<p>"
		print header
		print @time
		print ")</p>"
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

