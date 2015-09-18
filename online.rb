require './get_doc'
word_hash = Hash.new
word_hash['エルトゥールル号遭難事件']=6
word_hash['山陽本線特急列車脱線事故']=6
word_hash['西成線列車脱線火災事故']=6

word_hash['二又トンネル爆発事故']=6
word_hash['近鉄奈良線列車暴走追突事故']=6
word_hash['桜木町事故']=6
word_hash['もく星号墜落事故']=6
word_hash['洞爺丸事故']=6
word_hash['紫雲丸事故']=6
word_hash['弥彦神社将棋倒し事故']=6
word_hash['六軒事故']=6
word_hash['第五北川丸沈没事故']=6
word_hash['南海丸遭難事故']=6
word_hash['三河島事故']=6
word_hash['アシアナ航空162便着陸失敗事故']=6
word_hash['イデオロギー']=6

word_hash['アメリカ']=6
word_hash['EU']=6
word_hash['東京']=6
word_hash['大阪']=6
word_hash['自由民主党']=6
word_hash['民主党']=6
word_hash['公明党']=6
word_hash['日本維新の会']=6
word_hash['環太平洋戦略的経済連携協定']=6

word_hash['めふん']=7
word_hash['切り込み']=7
word_hash['氷頭なます']=7
word_hash['膾']=7
word_hash['食肉']=7
word_hash['鶏肉']=7
word_hash['豆腐']=7
word_hash['カレー']=7
word_hash['鍋料理']=7
word_hash['懐石']=7
word_hash['鉄板焼き']=7
word_hash['ファーストフード']=7
word_hash['弁当']=7
word_hash['カラストンビ']=7
word_hash['くさや']=7
word_hash['しもつかれ']=7
word_hash['へしこ']=7
word_hash['お茶漬け']=7
word_hash['鮒寿司']=7
word_hash['醤油']=7
word_hash['味噌']=7
word_hash['豚汁']=7
word_hash['ゆべし']=7
word_hash['広島菜']=7
word_hash['辛子明太子']=7
word_hash['辛子蓮根']=7
word_hash['カラスミ']=7
word_hash['がん漬']=7
word_hash['ミミガー']=7
word_hash['イラブー汁']=7
word_hash['松前漬け']=7
word_hash['寿司']=7
word_hash['鮭とば']=7
word_hash['惣菜']=7
word_hash['肴']=7
word_hash['揚げる']=7
word_hash['豚カツ']=7

word_hash['牛カツ']=7
word_hash['チキンカツ']=7
word_hash['串カツ']=7
word_hash['焼く(調理)']=7
word_hash['茹でる']=7
word_hash['蒸す']=7
word_hash['煮る']=7

word_hash['化学']=5
word_hash['生物学']=5
word_hash['地球科学']=5
word_hash['天文学']=5
word_hash['形式科学']=5
word_hash['統計学']=5
word_hash['医学']=5
word_hash['薬学']=5
word_hash['工学']=5
word_hash['情報技術']=1
word_hash['デスマーチ']=1
word_hash['プログラマ']=1
word_hash['ハッカー']=1
word_hash['インターネット・プロトコル・スイート']=1
word_hash['Linux']=1
word_hash['GNU']=1
word_hash['IPv4']=1
word_hash['IPv6']=1


word_hash['脆弱性情報データベース']=1
word_hash['セキュリティホール']=1
word_hash['ネットワーク・セキュリティ']=1


word_hash['格闘技']=3
word_hash['弓道']=3
word_hash['剣道']=3

word_hash['バレーボール']=3
word_hash['バドミントン']=3
word_hash['テニス']=3
word_hash['ラグビー']=3
word_hash['クリケット']=3
word_hash['リレー走']=3
word_hash['短距離走']=3
word_hash['中距離走']=3
word_hash['長距離走']=3
word_hash['ハンマー投']=3
word_hash['新体操']=3
word_hash['ボクシング']=3
word_hash['アーチェリー']=3
word_hash['ゴルフ']=3
word_hash['スキー']=3

word_hash['PCゲーム']=4
word_hash['日本ファルコム']=4
word_hash['MOD']=4
word_hash['Left_4_Dead']=4
word_hash['FPS']=4
word_hash['オンラインゲーム']=4
word_hash['バーチャルリアリティ']=1
word_hash['CG']=1

word_hash.each do |key,value|
  puts "Input:Word:#{key}"
  word = key
  puts "Enter Category:: 1:IT 2:アニメ漫画 3:スポーツ　4:ゲーム 5:科学 6:社会経済 7:グルメ"
  puts value
  case value.to_s
  when '1'
    GetDocs.lean_word word,'IT'
  when '2'
    GetDocs.lean_word word,'アニメ漫画'
  when '3'
    GetDocs.lean_word word,'スポーツ'
  when '4'
    GetDocs.lean_word word,'ゲーム'
  when '5'
    GetDocs.lean_word word,'科学'
  when '6'
    GetDocs.lean_word word,'社会経済'
  when '7'
    GetDocs.lean_word word,'グルメ'
  else
  end
end
