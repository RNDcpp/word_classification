# coding: utf-8
require 'open-uri'
require 'nokogiri'
require './main'
module GetDocs
@bc = BayesianClassifier.new('word_class.db')
@nest = 0
@word_list = Array.new

  class << self
    def table_reset
      @bc.create_table
    end
    def list_set
      @word_list = Array.new
    end
    def get_doc_from_word_without_lean(word)
      @word_list<<word
      docs = Array.new
      begin
        html = open("https://ja.wikipedia.org/wiki/#{URI.escape(word)}") do |f|
          f.read
        end
        puts"start parse #{word}"
        doc = Nokogiri::HTML.parse(html,nil,'UTF-8')
        doc.xpath('//*[@id = "mw-content-text"]//p').each do |text|
          docs << text.content
        end
#        doc.xpath('//*[@id = "mw-content-text"]//p//a').each do |a|
#          if @nest < 1
#            @nest+=1 
#            get_doc_from_word(a.content,cat) unless @word_list.include?(a.content)
#            @nest-=1
#          end
#        end

      rescue => e
        puts e.message
      end

      return docs
    end
    def get_doc_from_word(word,cat)
      @word_list<<word
      docs = Array.new
      begin
        html = open("https://ja.wikipedia.org/wiki/#{URI.escape(word)}") do |f|
          f.read
        end
        puts"start parse #{word}"
        doc = Nokogiri::HTML.parse(html,nil,'UTF-8')
        doc.xpath('//*[@id = "mw-content-text"]//p | //*[@id = "mw-content-text"]//span | //*[@id = "mw-content-text"]//dl/dt/*').each do |text|
          puts "						text in doc:#{word}"
          @bc.train(cat,text.content)
        end
        doc.xpath('//*[@id = "mw-content-text"]//p//a').each do |a|
          if @nest < 1
            @nest+=1 
            get_doc_from_word(a.content,cat) unless @word_list.include?(a.content)
            @nest-=1
          end
        end

      rescue => e
        puts e.message
      end

      return docs
    end
    def lean_word(word,cat)
      docs = Array.new
      presumed_category = nil
      presumed_value = 0
      begin
        html = open("https://ja.wikipedia.org/wiki/#{URI.escape(word)}") do |f|
          f.read
        end
        puts"start parse #{word}"
        doc = Nokogiri::HTML.parse(html,nil,'UTF-8')
        elem = doc.xpath('//*[@id = "mw-content-text"]//p | //*[@id = "mw-content-text"]//span | //*[@id = "mw-content-text"]//dl/dt')
        elem.each do |text|
          puts "						text in doc:#{word}"
          puts text.content
          classplot = @bc.classification(text.content) 
          classplot.each do |key,val|
            puts"#{key}:#{val}"
            presumed_category = key
            presumed_value = val
            break
          end
          if (cat != presumed_category)
            if presumed_value >0.5
              puts "Reset:Train"
              @bc.reset(presumed_category,text.content)
            end
          end
          puts "Start:Train"
          @bc.train(cat,text.content)
        end

      rescue => e
        puts e.message
      end

      return docs
    end
    def get_posts(url)
      html = open(url) do |f|
        f.read
      end
      puts 'start parse'
      posts = Array.new
      doc = Nokogiri::HTML.parse(html,nil,'UTF-8')
      doc.xpath('//*[@class = "topicListArea"]//li[@class="cf"]//dl//dt//a//@href').each do |t|
        puts "Thread_URL:#{t.value}"
        url = t.value
        posts << get_posts_from_thread(url)
      end
      return posts
    end
    def get_posts_from_thread(url)
      posts = Array.new
      p_url = url
      while p_url!=nil
        html = open(p_url) do |f|
           f.read
        end
        doc = Nokogiri::HTML.parse(html,nil,'UTF-8')
        doc.xpath('//*[@class = "comText"]').each do |honbun|
          honbun.children.each do |text|
            puts "Content:#{text.content}"
            posts << text.content
          end
        end
        p_url=nil
        doc.xpath('//*[@class = "prev"]//a//@href').each do |link|
          puts "NextLink:#{link.value}"
          p_url=link.value
        end
      end
      return posts
    end
    def class_plot_word(word)
      docs = get_doc_from_word_without_lean(word)
      if docs
        docs.each do |doc|
          puts doc
          begin
            classplot = @bc.classification(doc) 
            classplot.each do |key,val|
              puts"#{key}:#{val}"
            end
            puts "Enter Category:: 1:IT 2:アニメ漫画 3:スポーツ　4:ゲーム 5:科学"
            case STDIN.gets.chomp
            when '1'
              @bc.train 'IT',doc  
            when '2'
              @bc.train 'アニメ漫画',doc
            when '3'
              @bc.train 'スポーツ',doc
            when '4'
              @bc.train 'ゲーム',doc
            when '5'
              @bc.train '科学',doc
            else
            end
          rescue =>e
            puts e.message
          end
        end
      end
    end
  end
end
#GetDocs.class_plot_word ARGV[0]
#docs = Array.new
#GetDocs.list_set
#docs.concat GetDocs.get_doc_from_word('数学','科学')
#GetDocs.list_set
#docs.concat GetDocs.get_doc_from_word('未解決事件','社会経済')
#GetDocs.list_set
#docs.concat GetDocs.get_doc_from_word('外交政策','社会経済')
#GetDocs.list_set
#docs.concat GetDocs.get_doc_from_word('外交','科学')
#GetDocs.list_set
#docs.concat GetDocs.get_doc_from_word('任天堂','ゲーム')
#GetDocs.list_set
#docs.concat GetDocs.get_doc_from_word('マリオシリーズ','ゲーム')
#GetDocs.list_set
#docs.concat GetDocs.get_doc_from_word('ソニック・ザ・ヘッジホッグ_(1991年のゲーム)','ゲーム')
#GetDocs.list_set
#docs.concat GetDocs.get_doc_from_word('スプラトゥーン','ゲーム')
#GetDocs.list_set
#docs.concat GetDocs.get_doc_from_word('ポケットモンスター','ゲーム')
#GetDocs.list_set
#docs.concat GetDocs.get_doc_from_word('ソフトウェア','IT')
#GetDocs.list_set
#docs.concat GetDocs.get_doc_from_word('スクリプト言語','IT')
#GetDocs.list_set
#docs.concat GetDocs.get_doc_from_word('スクリプト言語','IT')
#GetDocs.list_set
#docs.concat GetDocs.get_doc_from_word('野球','スポーツ')
#GetDocs.list_set
#docs.concat GetDocs.get_doc_from_word('サッカー','スポーツ')
#GetDocs.list_set
#docs.concat GetDocs.get_doc_from_word('卓球','スポーツ')
#docs.concat GetDocs.get_doc_from_word('C++')
#docs.concat GetDocs.get_doc_from_word('Ruby')
#docs.concat GetDocs.get_doc_from_word('Perl')

