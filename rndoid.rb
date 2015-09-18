require 'twitter'
require './main'
require './get_doc'

$bc = BayesianClassifier.new('./word_class.db')
CONSUMER_KEY = 'D1PzTqeHWFJdWxzOOi6ZNdX63'
CONSUMER_SECRET = 'y1UnYqu0elVyhG8LYU17Wd7X80Zp7pi5G02m5YCHeZBecoDNTS'
ACCESS_TOKEN = '1732293392-YjUK0mP8OQqspYOug3caPgSYDQwwo8ZcS8XXaBx'
ACCESS_TOKEN_SECRET = 'XYph4sAETzOXoMtOYjBUs2QXxPoRmJQJEp3V7myAmmbab'

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = CONSUMER_KEY
  config.consumer_secret     = CONSUMER_SECRET
  config.access_token        = ACCESS_TOKEN
  config.access_token_secret = ACCESS_TOKEN_SECRET
end
rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONSUMER_KEY
  config.consumer_secret     = CONSUMER_SECRET
  config.access_token        = ACCESS_TOKEN
  config.access_token_secret = ACCESS_TOKEN_SECRET
end
begin
#client.user
client.user do |obj|
  if obj.is_a?(Twitter::Tweet)
    puts "\n\n"
    puts obj.user.screen_name+':'+obj.text #tweet本文が流れます
    str = obj.text
    puts 'parse'
    begin
      cls = $bc.classification(str)
      cat = nil
      result = ""
      cls.each do |key,val|
        cat = key
        p result << "カテゴリ：#{cat}(#{sprintf("%.1f",val*100)}%)\n"
        break
      end
      puts "Enter Category:: 0:生活 1:IT 2:アニメ漫画 3:スポーツ　4:ゲーム 5:科学 6:社会経済 7:グルメ"
      puts value = STDIN.gets.chomp.to_i
      case value.to_s
      when '1'
        $bc.train('IT',str)
        next if cat == 'IT'
        cls.each do |key,val|
          if val*10.to_i > 0 and key != 'IT'
            $bc.reset_wg(key,str,val*10.to_i)
          end
        end
      when '2'
        $bc.train('アニメ漫画',str)
        next if cat == 'アニメ漫画'
        cls.each do |key,val|
          if val*10.to_i > 0 and key != 'アニメ漫画'
            $bc.reset_wg(key,str,val*10.to_i)
          end
        end
      when '3'
        $bc.train('スポーツ',str)
        next if cat == 'スポーツ'
        cls.each do |key,val|
          if val*10.to_i > 0 and key != 'スポーツ'
            $bc.reset_wg(key,str,val*10.to_i)
          end
        end
      when '4'
        $bc.train('ゲーム',str)
        next if cat == 'ゲーム'
        cls.each do |key,val|
          if val*10.to_i > 0 and key != 'ゲーム'
            $bc.reset_wg(key,str,val*10.to_i)
          end
        end
      when '5'
        $bc.train('科学',str)
        next if cat == '科学'
        cls.each do |key,val|
          if val*10.to_i > 0 and key != '科学'
            $bc.reset_wg(key,str,val*10.to_i)
          end
        end
      when '6'
        $bc.train('社会経済',str)
        next if cat == '社会経済'
        cls.each do |key,val|
          if val*10.to_i > 0 and key != '社会経済'
            $bc.reset_wg(key,str,val*10.to_i)
          end
        end
      when '7'
        $bc.train('グルメ',str)
        next if cat == 'グルメ'
        cls.each do |key,val|
          if val*10.to_i > 0 and key != 'グルメ'
            $bc.reset_wg(key,str,val*10.to_i)
          end
        end
      when '0'
        $bc.train('生活',str)
        next if cat == '生活'
        cls.each do |key,val|
          if val*10.to_i > 0 and key != '生活'
            $bc.reset_wg(key,str,val*10.to_i)
          end
        end
      else
      end
    rescue => e
      puts e.message 
    end 
  end
end
rescue => e
puts e.message
retry
end
