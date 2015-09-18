# coding: utf-8
require 'sqlite3'
require 'natto'
class WordDB
  def initialize(db_file)
    @db=SQLite3::Database.new(db_file)
  end
  def create_table
    @db.execute('drop table if exists word ')
    @db.execute('create table word(id integer primary key,name text unique,cnt integer)')
  end
  def add(word)
    if get_from_name(word) ==nil
      @db.execute('insert into word(name,cnt) values(?,0)',word)
    end
  end
  def cnt_add(word,cnt)
    @db.execute('update word set cnt=cnt+(?) where name==(?)',[cnt,word])
  end
  def get_from_name(word)
    @db.execute('select * from word where name == (?)',word).first
  end
  def get_from_id(id)
    @db.execute('select * from word where id == (?)',id).first
  end
  def get_prob_word(word)
    wd=get_from_name(word)
    if wd == nil
      cnt=1
    else
      cnt=wd[2]
    end
      p all=@db.execute('select sum(cnt) from word').first
      return cnt/all.to_f
  end
end
class CategoryDB
  def initialize(db_file)
    @db=SQLite3::Database.new(db_file)
  end
  def create_table
    @db.execute('drop table if exists category ')
    @db.execute('create table category(id integer primary key,name text unique,cnt integer)')
  end
  def add(cat)
    if get_from_name(cat)==nil
      @db.execute('insert into category(name,cnt) values(?,0)',cat)
    end
  end
  def cnt_add(cat,cnt)
    @db.execute('update category set cnt=cnt+(?) where name==(?)',[cnt,cat])
  end
  def get_from_name(cat)
    @db.execute('select * from category where name == (?)',cat).first
  end
  def get_from_id(id)
    @db.execute('select * from category where id == (?)',id).first
  end
  def get_all
    @db.execute("select * from category")
  end
  def get_prob_cat(cat)
    ct=get_from_name(cat)
    if ct == nil
      cnt=1
    else
      cnt=ct[2]
    end
      all=@db.execute('select sum(cnt) from category').first
      return cnt/all[0].to_f
  end
end
class WordCategoryDB
  attr_accessor :word_db,:cat_db
  def initialize(db_file)
    @db=SQLite3::Database.new(db_file)
    @word_db=WordDB.new(db_file)
    @cat_db=CategoryDB.new(db_file)
  end
  def create_table
    @word_db.create_table
    @cat_db.create_table
    @db.execute('drop table if exists relation')
    @db.execute("create table relation(id integer primary key,word_id integer forign key,cat_id integer forign key,cnt integer)")
  end
  def set_association(word,cat,value)
    wid=@word_db.get_from_name(word)[0]
    cid=@cat_db.get_from_name(cat)[0]
    if get_association(word,cat)==nil
      @db.execute('insert into relation(word_id,cat_id,cnt) values(?,?,0)',[wid,cid])
    end
      @db.execute('update relation set cnt=cnt+(?) where word_id==(?) and cat_id==(?)',[value,wid,cid])
  end
  def get_association(word,cat)
    @db.execute('select cnt from relation where word_id==(?) and cat_id==(?)',[@word_db.get_from_name(word)[0],@cat_db.get_from_name(cat)[0]]).first
  end
end
class BayesianClassifier
  def initialize(db_file)
    @@nat=Natto::MeCab.new
    @db=WordCategoryDB.new(db_file)
  end
  def create_table
    @db.create_table
  end
  def train(category,doc)
    @db.cat_db.add(category)
    @db.cat_db.cnt_add(category,8)
    @@nat.parse(doc) do |n|
      if n.surface.length > 1 and n.feature =~ /(名詞|形容詞)/
        wd = n.feature.split(",")[6].to_s
        wd = n.surface if wd == '*'
        puts wd
        @db.word_db.add(wd)
        @db.word_db.cnt_add(wd,8)
        @db.set_association(wd,category,8)
      end
    end
  end
  def reset(category,doc)
    puts "reset:::::::::::"
    @db.cat_db.add(category)
    @db.cat_db.cnt_add(category,-1)
    @@nat.parse(doc) do |n|
      if n.surface.length > 1 and n.feature =~ /(名詞|形容詞)/
        wd = n.feature.split(",")[6].to_s
        wd = n.surface if wd == '*'
        puts wd
        @db.word_db.add(wd)
        if get_association(wd,category) 
          if get_association(wd,category)[0] > 0
            puts "reset<<"
            @db.word_db.cnt_add(wd,-1)
            @db.set_association(wd,category,-1)
          end
        end
      end
    end
  end
  def reset_wg(category,doc,waight=1)
    puts "reset:::::::::::"
    @db.cat_db.add(category)
    @db.cat_db.cnt_add(category,-waight)
    @@nat.parse(doc) do |n|
      if n.surface.length > 1 and n.feature =~ /(名詞|形容詞)/
        wd = n.feature.split(",")[6].to_s
        wd = n.surface if wd == '*'
        puts wd
        @db.word_db.add(wd)
        if get_association(wd,category) 
          if get_association(wd,category)[0] > waight
            puts "reset<<"
            @db.word_db.cnt_add(wd,-waight)
            @db.set_association(wd,category,-waight)
          end
        end
      end
    end
  end
  def get_association(word,cat)
    @db.get_association(word,cat)
  end
  def classification(doc)
    prob_cat_wd = Hash.new
    prob_cat_tmp = Hash.new
    pcat = Hash.new
    categories = @db.cat_db.get_all
    categories.each do |cat|
      pcat[cat[1]] = Math.log(@db.cat_db.get_prob_cat(cat[1]))
      prob_cat_wd[cat[1]] = 0
    end
    @@nat.parse(doc) do |n|
      if n.surface.length > 1 and n.feature =~ /(名詞|形容詞)/
         wd = n.feature.split(",")[6].to_s
         wd = n.surface if wd == '*'
         word = @db.word_db.get_from_name(wd)
        if word == nil
          categories.each do |cat|
            prob_cat_wd[cat[1]] += Math.log(0.4)
          end
        else
          pword = Math.log(word[2])
          categories.each do |cat|
            cnt_as=get_association(word[1],cat[1])
            cnt_as = [word[2]*0.4*Math.exp(pcat[cat[1]])] unless cnt_as
            cnt_as = cnt_as[0]
#          puts "出現率 #{cat[1]}:#{(cnt_as/((Math.exp(pcat[cat[1]])*word[2])))} :出現数　#{cnt_as}"
            if (((cnt_as/((Math.exp(pcat[cat[1]])*word[2])))<0.5)||(cnt_as/(Math.exp(pcat[cat[1]])*word[2])>1.5)) 
              prob_cat_wd[cat[1]] += Math.log(cnt_as)-pword-pcat[cat[1]]
            else
              prob_cat_wd[cat[1]] += Math.log(0.5)
            end
          end
        end
      end
    end
     bottom_cat_wd = prob_cat_wd.min { |a, b| a[1] <=> b[1] }
     bottom_cat_wd = bottom_cat_wd.to_a[1] 
    cat_sum = prob_cat_wd.inject(0){|sum,(key,val)|sum+=Math.exp(val)}
#    puts "cat_sum:#{ cat_sum}"
    d_cat = Hash.new
    sum = 0
    categories.each do |cat|
      d_cat[cat[1]] = (Math.exp(prob_cat_wd[cat[1]]))/cat_sum
      sum += d_cat[cat[1]]
    end
    sum
    d_cat.each do |key,value|
      d_cat[key]=value/sum
    end
    result = d_cat.sort{|(k1,v1),(k2,v2)|v2 <=> v1}
    result
  end
end
