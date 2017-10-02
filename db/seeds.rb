# == アクション ==
# ドロー： あなたのアクティブな最も高いカードの値と同じ時代から１枚引く。
#          [10]より高い時代から引くことになった場合、ゲームは終了する。
# プレイ： 手札を１枚、あなたの領域の同じ色の山の上に置く。
# 制覇  ： 時代を制覇するには、影響ポイントが制覇しようとする時代の値の５倍以上で、かつ、
#          あなたのアクティブなカードの値のいずれかが、その時代以上でなければならない。
#          勝利条件： ２人ゲーム = ６枚制覇、３人 = ５枚、４人 = ４枚。
# 発動  ： あなたのアクティブなカードを１枚選び、書かれている順に教義を実行する。
#          優越型教義： 必要リソースの数があなたより少ないプレイヤーに効果を発揮。
#          協力型教義： 必要リソースがあなた以上のプレイヤーにも効果を発揮。
#                       あなたの左側から近い順に実行し、最後にあなたが実行する。
#                       他のプレイヤーが恩恵を得た場合、最後に追加のドローを１回行う。
# == ゲームの効果 ==
# 保存する： カードを領域の同じ色の山の底に置く。その色がない場合は１枚の山となる。
# 再生する： カードを裏向きに、その時代の山札の底に戻す。
# 引いて何々する： 引いたそのカードを使用しなければならない。

STDOUT.puts

STDOUT.puts "Seeding Age's..."
%w[
  先史時代 古代 中世 ルネッサンス 大航海時代 啓蒙時代 産業革命 近代 宇宙時代 情報時代
].each.with_index(1) do |name, level|
  Age.create!(level: level, name: name)
end

STDOUT.puts "Seeding Color's..."
[
  %w[赤 red    #FF0000],
  %w[緑 green  #00FF00],
  %w[青 blue   #0000FF],
  %w[黄 yellow #FFFF00],
  %w[紫 purple #800080],
  %w[灰 gray   #808080],
].each do |name, name_eng, rgb|
  Color.create!(name: name, name_eng: name_eng, rgb: rgb)
end

STDOUT.puts "Seeding Resource's..."
[
  %w[石   Stone       灰],
  %w[木   Woods       緑],
  %w[金属 Metal       黄],
  %w[電気 Electricity 紫],
  %w[製造 Manufacture 赤],
  %w[時間 Time        青],
].each do |name, name_eng, color_name|
  color = Color.find_by(name: color_name)
  Resource.create!(name: name, name_eng: name_eng, color: color)
end

ResourcePosition.create!(name: '左上', abbr: 'LT', is_left: true , is_right: false, is_bottom: false)
ResourcePosition.create!(name: '左下', abbr: 'LB', is_left: true , is_right: false, is_bottom: true )
ResourcePosition.create!(name: '下'  , abbr: 'CB', is_left: false, is_right: false, is_bottom: true )
ResourcePosition.create!(name: '右下', abbr: 'RB', is_left: false, is_right: true , is_bottom: true )

STDOUT.puts "Seeding Category's..."
[
  %w[文化 Culture あなたの領域に５つの色があり、それらがすべて右か上に展開されている場合、ただちにこの分野を制覇する。 ルネッサンス（４）の「発明」により制覇することもできる。],
  %w[技術 Technology あなたが１ターンの間に保存または得点したカードが合わせて６枚以上になった場合、ただちにこの分野を制覇する。（他のプレイヤーから譲渡されたカードや、あなたの手札や影響から交換されたカードは、この数に含まない。） 先史時代（１）の「石工」により制覇することもできる。],
  %w[外交 Diplomacy あなたが資源「時間」を１２以上生み出している場合、ただちにこの分野を制覇する。 中世（３）の「翻訳」により制覇することもできる。],
  %w[軍事 Military あなたが資源６種類のそれぞれを３つ以上生み出している場合、ただちにこの分野を制覇する。 古代（２）の「建築」により制覇することもできる。],
  %w[科学 Science あなたの５つのアクティブなカードの値がすべて[8]以上である場合、ただちにこの分野を制覇する。 大航海時代（５）の「天文学」により制覇することもできる。],
].each do |name, name_eng, condition, note|
  Category.create!(name: name, name_eng: name_eng, condition: condition, note: note)
end

DATA_CARDS = [
  [1, '緑', '車輪', [
    %w[石 true [1]を２枚引く。],
  ], %w[nil 石 石 石]],
  [1, '黄', '牧畜', [
    %w[石 true あなたの手札の最も低い値のカードを１枚場に出す。[1]を１枚引く。],
  ], %w[石 金属 nil 石]],
  [1, '黄', '石工', [
    %w[石 true あなたの手札にある「石」を生み出すカードを望む枚数場に出してよい。これにより４枚以上のカードを場に出した場合、「技術」の分野を制覇する。],
  ], %w[石 nil 石 石]],
  [1, '赤', '弓矢', [
    %w[石 false 要求する。[1]を一枚引け。その後、お前の手札の最も高いカードを１枚、我が手札に譲渡せよ。],
  ], %w[石 電気 nil 石]],
  [1, '青', '筆記', [
    %w[電気 true [2]を１枚引く。],
  ], %w[nil 電気 電気 金属]],
  [1, '青', '陶器', [
    %w[木 true あなたの手札を３枚まで再生してよい。そうした場合、再生したカードの枚数に等しい値のカードを１枚引いて得点する。],
    %w[木 true [1]を１枚引く。],
  ], %w[nil 木 木 木]],
  [1, '青', '道具', [
    %w[電気 true あなたの手札を３枚再生してよい。そうした場合、[3]を１枚引いて場に出す。],
    %w[電気 true あなたの手札の[3]を１枚再生してよい。そうした場合、[1]を３枚引く。],
  ], %w[nil 電気 電気 石]],
  [1, '紫', '神秘主義', [
    %w[石 true [1]を１枚引いて公開する。それがあなたの領域のいずれかのカードと同じ色の場合、それを場に出し、[1]を１枚引く。そうでない場合、それをあなたの手札に加える。],
  ], %w[nil 石 石 石]],
  [1, '緑', '衣服', [
    %w[木 true あなたの手札の、あなたの領域にあるどのカードとも異なる色のカードを１枚場に出す。],
    %w[木 true あなたの領域にあり他のプレイヤーの領域にない色１色につき、[1]を１枚引いて得点する。],
  ], %w[nil 金属 木 木]],
  [1, '緑', '帆走', [
    %w[金属 true [1]を１枚引いて場に出す。],
  ], %w[金属 金属 nil 木]],
  [1, '紫', '都市国家', [
    %w[金属 false 要求する。お前が「石」を４以上生み出している場合、「石」を生み出すアクティブなカードを１枚我が領域に譲渡せよ。そうした場合、[1]を１枚引け。],
  ], %w[nil 金属 金属 石]],
  [1, '赤', '金属加工', [
    %w[石 true [1]を１枚引いて公開する。それが「石」を生み出す場合、それを得点し、この教義を繰り返す。そうでない場合、それをあなたの手札に加える。],
  ], %w[石 石 nil 石]],
  [1, '赤', '櫂', [
    %w[石 false 要求する。お前の手札の「金属」を生み出すカードを１枚、我が影響に譲渡せよ。そうした場合、[1]を１枚引け。],
    %w[石 true 上記の優越型教義によりカードが譲渡されなかった場合、[1]を１枚引く。],
  ], %w[石 金属 nil 石]],
  [1, '紫', '法典', [
    %w[金属 true あなたの手札の、あなたの領域にあるいずれかのカードと同じ色のカードを１枚保存してよい。そうした場合、その色を左に展開してよい。],
  ], %w[nil 金属 金属 木]],
  [1, '黄', '農業', [
    %w[木 true あなたの手札を１枚再生してよい。そうした場合、再生したカードの値より１大きい値のカードを１枚引いて得点する。],
  ], %w[nil 木 木 木]],
  [2, '紫', '哲学', [
    %w[電気 true あなたの色の山を１つ、左に展開してよい。],
    %w[電気 true あなたの手札を１枚得点してよい。],
  ], %w[nil 電気 電気 電気]],
  [2, '緑', '地図作成', [
    %w[金属 false 要求する。お前の影響の[1]を１枚、我が影響に譲渡せよ。],
    %w[金属 true 上記の優越型教義によりカードが譲渡された場合、[1]を１枚引いて得点する。],
  ], %w[nil 金属 金属 石]],
  [2, '青', '数学', [
    %w[電気 true あなたの手札を１枚再生してよい。そうした場合、再生したカードの値より１大きい値のカードを１枚引いて場に出す。],
  ], %w[nil 電気 金属 電気]],
  [2, '青', '暦', [
    %w[木 true あなたの影響のカードの枚数があなたの手札よりも多い場合、[3]を２枚引く。],
  ], %w[nil 木 木 電気]],
  [2, '紫', '一神論', [
    %w[石 false 要求する。我が領域のどのカードとも異なる色のアクティブなカードを１枚、我が影響に譲渡せよ。そうした場合、[1]を１枚引いて保存せよ。],
    %w[石 true [1]を１枚引いて保存する],
  ], %w[nil 石 石 石]],
  [2, '赤', '道路建設', [
    %w[石 true あなたの手札を１枚か２枚場に出す。カードを２枚場に出した場合、あなたの赤のアクティブなカードを他のプレイヤーの領域に譲渡してよい。そうした場合、そのプレイヤーの緑のアクティブなカードをあなたの領域に譲渡する。],
  ], %w[石 石 nil 石]],
  [2, '緑', '貨幣', [
    %w[金属 true あなたの手札を１枚再生してよい。そうした場合、再生したカードの異なる値１つにつき、[2]を１枚引いて得点する。],
  ], %w[木 金属 nil 金属]],
  [2, '赤', '建築', [
    %w[石 false 要求する。お前の手札を２枚、我が手札に譲渡せよ。[2]を１枚引け。],
    %w[石 true あなたが自分の領域に５つの色がある唯一のプレイヤーである場合、「軍事」の分野を制覇する。],
  ], %w[石 nil 石 石]],
  [2, '黄', '運河建設', [
    %w[金属 true あなたの手札にある最も高いすべてのカードを、あなたの影響にある最も高いすべてのカードと交換してよい。],
  ], %w[nil 金属 木 金属]],
  [2, '黄', '発酵', [
    %w[木 true あなたが生み出す「木」２つにつき[2]を１枚引く。],
  ], %w[木 木 nil 石]],
  [3, '黄', '医術', [
    %w[木 false 要求する。お前の影響の最も高いカードを１枚、我が影響の最も低いカード１枚と交換せよ。],
  ], %w[金属 木 木 nil]],
  [3, '黄', '機械', [
    %w[木 false 要求する。お前の手札のすべてを、我が手札の最も高いすべてのカードと交換せよ。],
    %w[木 true あなたの手札の「石」を生み出すカードを１枚得点する。あなたの赤のカードを左に展開してよい。],
  ], %w[木 木 nil 石]],
  [3, '紫', '封建主義', [
    %w[石 false 要求する。お前の手札の「石」を生み出すカードを１枚、我が影響に譲渡せよ。],
    %w[石 true あなたの黄か紫のカードを左に展開してよい。],
  ], %w[nil 石 木 石]],
  [3, '緑', '方位磁石', [
    %w[金属 false 要求する。「木」を生み出すお前の緑でないアクティブなカードを１枚、我が領域に譲渡せよ。その後、「木」を生み出さない我がアクティブなカードを１枚、お前の領域に譲渡する。],
  ], %w[nil 金属 金属 木]],
  [3, '赤', '光学', [
    %w[金属 true [3]を１枚引いて場に出す。それが「金属」を生み出す場合、[4]を１枚引いて得点する。そうでない場合、あなたの影響のカードを１枚、あなたより影響の点数の低いいずれかの対戦相手の影響に譲渡する。],
  ], %w[金属 金属 金属 nil]],
  [3, '赤', '工学', [
    %w[石 false 要求する。「石」を生み出すお前のアクティブなカードをすべて、我が影響に譲渡せよ。],
    %w[石 true あなたの赤のカードを左に展開してよい。],
  ], %w[石 nil 電気 石]],
  [3, '紫', '教育', [
    %w[電気 true あなたの影響の最も高いカードを１枚再生してよい。そうした場合、あなたの影響に残っている最も高いカードよりも値が２高いカードを１枚引く。],
  ], %w[電気 電気 電気 nil]],
  [3, '青', '錬金術', [
    %w[石 true あなたが生み出す「石」３つにつき、[4]を１枚引いて公開する。そのいずれかのカードが赤である場合、引いたカードとあなたの手札のカードすべてを再生する。そうでない場合、それらをあなたの手札に加える。],
    %w[石 true あなたの手札を１枚場に出し、その後あなたの手札を１枚得点する。],
  ], %w[nil 木 石 石]],
  [3, '青', '翻訳', [
    %w[金属 true あなたの影響のカードをすべて場に出してよい。],
    %w[金属 true あなたのアクティブなカードがすべて「金属」を生み出す場合、「外交」の分野を制覇する。],
  ], %w[nil 金属 金属 金属]],
  [3, '緑', '紙', [
    %w[電気 true あなたの青か緑のカードを左に展開してよい。],
    %w[電気 true あなたの左に展開している色１つにつき、[4]を１枚引く。],
  ], %w[nil 電気 電気 金属]],
  [4, '紫', '事業', [
    %w[金属 false 要求する。「金属」を生み出す紫でないアクティブなカードを１枚、我が領域に譲渡せよ。そうした場合、[4]を１枚引いて場に出せ。],
    %w[金属 true あなたの緑のカードを右に展開してよい。],
  ], %w[nil 金属 金属 金属]],
  [4, '緑', '航海術', [
    %w[金属 false 要求する。お前の影響の[2]か[3]を１枚、我が影響に譲渡せよ。],
  ], %w[nil 金属 金属 金属]],
  [4, '青', '印刷機', [
    %w[電気 true あなたの影響のカードを１枚再生してよい。そうした場合、あなたの紫のアクティブなカードよりも値が２高いカードを１枚引く。],
    %w[電気 true あなたの青のカードを右に展開してよい。],
  ], %w[nil 電気 電気 金属]],
  [4, '緑', '発明', [
    %w[電気 true あなたの色のうち、現在左に展開されているものを１つ、右に展開してよい。そうした場合、[4]を１枚引いて得点する。],
    %w[電気 true あなたの５つの色がすべて展開されている場合、「文化」の分野を制覇する。],
  ], %w[nil 電気 電気 製造]],
  [4, '黄', '遠近法', [
    %w[電気 true あなたの手札を１枚再生してよい。そうした場合、あなたが生み出す「電気」２つにつき、手札を１枚得点してよい。],
  ], %w[nil 電気 電気 木]],
  [4, '黄', '解剖学', [
    %w[木 false 要求する。お前の影響のカードを１枚再生せよ。そうした場合、そのカードと同じ値のアクティブなカードがあるなら、そのうち１枚を再生せよ。],
  ], %w[木 木 木 nil]],
  [4, '紫', '改革', [
    %w[木 true あなたが生み出す「木」２つにつき、あなたの手札を１枚保存してよい。],
    %w[木 true あなたの黄か紫のカードを右に展開してよい。],
  ], %w[木 木 nil 木]],
  [4, '赤', '火薬', [
    %w[製造 false 要求する。「石」を生み出すアクティブなカードを１枚、我が影響に譲渡せよ。],
    %w[製造 true 上記の優越型教義により１枚以上のカードが譲渡された場合、[2]を１枚引いて得点する。],
  ], %w[nil 製造 金属 製造]],
  [4, '赤', '植民地主義', [
    %w[製造 true [3]を１枚引いて保存する。それが「金属」を生み出す場合、この教義を繰り返す。],
  ], %w[nil 製造 電気 製造]],
  [4, '青', '実験', [
    %w[電気 true [5]を１枚引いて場に出す。],
  ], %w[nil 電気 電気 電気]],
  [5, '黄', '蒸気機関', [
    %w[製造 true [4]を２枚引いて保存し、その後、あなたの黄の底のカードを得点する。],
  ], %w[nil 製造 金属 製造]],
  [5, '青', '化学', [
    %w[製造 true あなたの青のカードを右に展開してよい。],
    %w[製造 true あなたの最も高いアクティブなカードより値が１高いカードを１枚引いて得点し、その後、あなたの影響のカードを１枚再生する。],
  ], %w[製造 電気 製造 nil]],
  [5, '紫', '社交界', [
    %w[金属 false 要求する。「電気」を生み出す紫でないアクティブなカードを１枚、我が領域に譲渡せよ。そうした場合、[5]を１枚引け。],
  ], %w[金属 nil 電気 金属]],
  [5, '青', '物理学', [
    %w[電気 true [6]を３枚引いて公開する。引いたカードのうち２枚以上が同じ色の場合、引いたカードとあなたの手札のすべてを再生する。そうでない場合、それらをあなたの手札に加える。],
  ], %w[製造 電気 電気 nil]],
  [5, '緑', '銀行', [
    %w[金属 false 要求する。「製造」を生み出す緑でないアクティブなカードを１枚、我が領域に譲渡せよ。そうした場合、[5]を１枚引いて得点せよ。],
  ], %w[製造 金属 nil 金属]],
  [5, '緑', '計測', [
    %w[電気 true あなたの手札を１枚再生してよい。そうした場合、あなたの色のうち１つを右に展開し、あなたの領域にあるその色のカードの枚数に等しい値のカードを１枚引く。],
  ], %w[電気 木 電気 nil]],
  [5, '赤', '石炭', [
    %w[製造 true [5]を１枚引いて保存する。],
    %w[製造 true あなたの赤のカードを右に展開してよい。],
    %w[製造 true あなたのアクティブなカードを１枚得点してよい。そうした場合、そのすぐ下のカードも得点する。],
  ], %w[製造 製造 製造 nil]],
  [5, '紫', '天文学', [
    %w[電気 true [6]を１枚引いて公開する。それが緑か青の場合、それを場に出し、この教義を繰り返す。そうでない場合、それをあなたの手札に加える。],
    %w[電気 true あなたの紫でないすべてのアクティブなカードの値が[6]以上である場合、「科学」の分野を制覇する。],
  ], %w[金属 電気 電気 nil]],
  [5, '赤', '海賊典範', [
    %w[金属 false 要求する。お前の影響の[4]以下のカードを２枚、我が影響に譲渡せよ。],
    %w[金属 true 上記の優越型教義により１枚以上のカードが譲渡された場合、「金属」を生み出すあなたの最も低いアクティブなカードを１枚得点する。],
  ], %w[金属 製造 金属 nil]],
  [5, '黄', '統計', [
    %w[木 false お前の影響の最も高いカードを１枚、お前の手札に戻せ。そうした場合、お前の手札が１枚しかないなら、この教義を繰り返せ。],
    %w[木 true あなたの黄のカードを右に展開してよい。],
  ], %w[木 電気 木 nil]],
  [6, '黄', '予防接種', [
    %w[木 false 要求する。お前の影響の最も低いすべてのカードを再生せよ。そうした場合、[6]を１枚引いて場に出せ。],
    %w[木 true 上記の優越型教義によりカードが再生された場合、[7]を１枚引いて場に出す。],
  ], %w[木 製造 木 nil]],
  [6, '紫', '民主主義', [
    %w[電気 true あなたの手札のカードを望む枚数再生してよい。このフェイズ中、あなたが「民主主義」により、この時点までの他のプレイヤーよりも多くのカードを再生した場合、[8]を１枚引いて得点する。],
  ], %w[金属 電気 電気 nil]],
  [6, '緑', 'メートル法', [
    %w[金属 true あなたの緑のカードが右に展開されている場合、あなたの他の色のカードを１つ右に展開してよい。],
    %w[金属 true あなたの緑のカードを右に展開してよい。],
  ], %w[nil 製造 金属 金属]],
  [6, '青', '百科事典', [
    %w[金属 true あなたの影響の最も高いすべてのカードを場に出してよい。],
  ], %w[nil 金属 金属 金属]],
  [6, '黄', '缶詰', [
    %w[製造 true [6]を１枚引いて保存してよい。そうした場合、「製造」を生み出さないあなたのアクティブなすべてのカードを得点する。],
    %w[製造 true あなたの黄のカードを右に展開してよい。],
  ], %w[nil 製造 木 製造]],
  [6, '赤', '産業化', [
    %w[製造 true あなたが生み出す「製造」２つにつき、[6]を１枚引いて保存する。],
    %w[製造 true あなたの赤か紫のカードを右に展開してよい。],
  ], %w[金属 製造 製造 nil]],
  [6, '赤', '工作機械', [
    %w[製造 true あなたの影響の最も高いカードに等しい値のカードを１枚引いて得点する。],
  ], %w[製造 製造 nil 製造]],
  [6, '青', '原理理論', [
    %w[電気 true あなたの青のカードを右に展開してよい。],
    %w[電気 true [7]を１枚引いて場に出す。],
  ], %w[電気 電気 電気 nil]],
  [6, '紫', '奴隷解放', [
    %w[製造 false 要求する。お前の手札を１枚、我が影響に譲渡せよ。そうした場合、[6]を１枚引け。],
    %w[製造 true あなたの赤か紫のカードを右に展開してよい。],
  ], %w[製造 電気 製造 nil]],
  [6, '緑', '分類', [
    %w[電気 true あなたの手札を１枚公開する。他のすべてのプレイヤーは、そのプレイヤーの手札のそのカードの色と同じ色のすべてのカードをあなたの手札に譲渡する。その後、あなたの手札のその色のカードをすべて場に出す。],
  ], %w[電気 電気 電気 nil ]],
  [7, '黄', '冷蔵', [
    %w[木 false 要求する。お前の手札を、その枚数の半分（端数切り捨て）再生せよ。],
    %w[木 true あなたの手札を１枚得点してよい。],
  ], %w[nil 木 木 金属]],
  [7, '青', '進化論', [
    %w[電気 true 「[8]を１枚引いて得点し、その後あなたの影響のカードを１枚再生する」か「あなたの影響の最も高いカードの値よりも１高い値のカードを１枚引く」を選んで実行してよい。],
  ], %w[電気 電気 電気 nil]],
  [7, '青', '出版', [
    %w[電気 true あなたの色の山のうち１つの順番を並べ替えてよい。],
    %w[電気 true あなたの黄か青のカードを上に展開してよい。],
  ], %w[nil 電気 時間 電気]],
  [7, '緑', '自転車', [
    %w[金属 true あなたの手札のすべてを、あなたの影響にあるすべてのカードと交換してよい。],
  ], %w[金属 金属 時間 nil]],
  [7, '黄', '公衆衛生', [
    %w[木 false 要求する。お前の手札の最も高いカードを２枚、我が手札の最も低いカード１枚と交換せよ。],
  ], %w[木 木 nil 木]],
  [7, '紫', '鉄道', [
    %w[時間 true あなたの手札をすべて再生し、その後[6]を３枚引く。],
    %w[時間 true あなたの色のうち、現在右に展開されているものを１つ、上に展開してよい。],
  ], %w[時間 製造 時間 nil]],
  [7, '赤', '内燃機関', [
    %w[金属 false 要求する。お前の影響のカードを２枚、我が影響に譲渡せよ。],
  ], %w[金属 金属 製造 nil]],
  [7, '赤', '爆薬', [
    %w[製造 false 要求する。お前の手札の最も高いカードを３枚、我が手札に譲渡せよ。これにより少なくとも１枚譲渡し、その後、お前の手札にカードがない場合、[7]を１枚引け。],
  ], %w[nil 製造 製造 製造]],
  [7, '紫', '街灯', [
    %w[木 true あなたの手札を３枚まで保存してよい。そうした場合、保存したカードの異なる値１つにつき、[7]を１枚引いて得点する。],
  ], %w[nil 木 時間 木]],
  [7, '緑', '電気', [
    %w[製造 true 「製造」を生み出さないあなたのアクティブなすべてのカードを再生し、その後、再生したカード１枚につき[8]を１枚引く。],
  ], %w[電気 製造 nil 製造]],
  [8, '緑', '企業', [
    %w[製造 false 要求する。「製造」を生み出すお前の緑でないアクティブなカードを１枚、我が影響に譲渡せよ。そうした場合、[8]を１枚引いて場に出せ。],
    %w[製造 true [8]を１枚引いて場に出す。],
  ], %w[nil 製造 製造 金属]],
  [8, '青', '量子論', [
    %w[時間 true あなたの手札を２枚まで再生してよい。２枚再生した場合、[10]を１枚引き、その後[10]を１枚引いて得点する。],
  ], %w[時間 時間 時間 nil]],
  [8, '青', 'ロケット工学', [
    %w[時間 true あなたが生み出す「時間」２つにつき、いずれかの対戦相手の影響のカードを１枚再生する。各カード毎に、異なる対戦相手を選んでよい。],
  ], %w[時間 時間 時間 nil]],
  [8, '赤', '飛行機', [
    %w[金属 true あなたの赤のカードが上に展開されている場合、あなたの他の色のカードを１つ上に展開してよい。],
    %w[金属 true あなたの赤のカードを上に展開してよい],
  ], %w[金属 nil 時間 金属]],
  [8, '紫', '経験論', [
    %w[電気 true 色を２つ選び、その後[9]を１枚引いて公開する。それが選んだいずれかの色である場合、それを場に出す。その色を上に展開してもよい。そうでない場合、それをあなたの手札に加える。],
    %w[電気 true あなたが「電気」を２０以上生み出す場合、あなたは勝利する。],
  ], %w[電気 電気 電気 nil]],
  [8, '黄', '摩天楼', [
    %w[金属 false 要求する。「時間」を生み出すお前の黄でないアクティブなカードを１枚、我が領域に譲渡せよ。そうした場合、そのすぐ下のカードを得点し、その山の他のすべてのカードを再生せよ。],
  ], %w[nil 製造 金属 金属]],
  [8, '紫', '共産主義', [
    %w[木 true あなたの手札のすべてを保存してよい。紫のカードを少なくとも１枚保存した場合、すべての対戦相手は自分の手札にある最も低いすべてのカードをあなたの手札に譲渡する。],
  ], %w[木 nil 木 木]],
  [8, '黄', '抗生物質', [
    %w[木 true あなたの手札を３枚まで再生してよい。再生したカードの異なる値１つにつき[8]を２枚引く。],
  ], %w[木 木 木 nil]],
  [8, '赤', '交通', [
    %w[製造 false 要求する。「製造」を生み出さないお前の赤でないアクティブな最も高いカードを２枚、我が影響に譲渡せよ。お前がいずれかのカードを譲渡した場合、[8]を１枚引け。],
  ], %w[nil 製造 時間 製造]],
  [8, '緑', 'マスメディア', [
    %w[電気 true あなたの手札を１枚再生してよい。そうした場合、値を１つ選び、（自分も含む）すべてのプレイヤーは、そのプレイヤーの影響のその値のすべてのカードを再生する。],
    %w[電気 true あなたの紫のカードを上に展開してよい。]
  ], %w[電気 nil 時間 電気]],
  [9, '緑', '提携', [
    %w[金属 false 要求する。[9]を２枚引いて公開せよ。そのうち我が選んだカードを我が領域に譲渡し、もう一方のカードをお前の領域の場に出せ。],
    %w[金属 true あなたの領域に緑のカードが１０枚以上ある場合、あなたは勝利する。],
  ], %w[nil 金属 時間 金属]],
  [9, '赤', '複合材料', [
    %w[製造 false 要求する。お前の手札を、１枚を残してすべて我が手札に譲渡せよ。さらに、お前の影響の最も高いカードを１枚、我が影響に譲渡せよ。],
  ], %w[製造 製造 nil 製造]],
  [9, '紫', 'サービス業', [
    %w[木 false 要求する。お前の影響の最も高いすべてのカードを、我が手札に譲渡せよ。そうした場合、「木」を生み出さない我がアクティブなカードを１枚、お前の手札に譲渡する。],
  ], %w[nil 木 木 木]],
  [9, '赤', '核分裂', [
    %w[時間 false 要求する。[10]を１枚引け。それが赤である場合、（お前を含む）すべてのプレイヤーの手札と領域と影響を破棄せよ。],
    %w[時間 true いずれかのプレイヤーの「核分裂」以外のアクティブなカードを１枚再生する。],
  ], %w[nil 電気 電気 電気]],
  [9, '青', 'コンピューター', [
    %w[時間 true あなたの赤か緑のカードを上に展開してよい。],
    %w[時間 true [10]を１枚引いて場に出し、その後それのすべての協力型教義を、自分のみが発動する。],
  ], %w[時間 nil 時間 製造]],
  [9, '青', '遺伝子工学', [
    %w[電気 true [10]を１枚引いて場に出す。その下にあるすべてのカードを得点する。],
  ], %w[電気 電気 電気 nil]],
  [9, '緑', '人工衛星', [
    %w[時間 true あなたの手札をすべて再生し、その後[8]を３枚引く。],
    %w[時間 true あなたの紫のカードを上に展開してよい。],
    %w[時間 true あなたの手札を１枚場に出し、その後それのすべての協力型教義を、自分のみが発動する。],
  ], %w[nil 時間 時間 時間]],
  [9, '紫', '専門化', [
    %w[製造 true あなたの手札を１枚公開する。すべての対戦相手のその色のアクティブなカードを、あなたの手札に譲渡する。],
    %w[製造 true あなたの黄か青のカードを上に展開してよい。],
  ], %w[nil 製造 木 製造]],
  [9, '黄', '住宅地', [
    %w[木 true あなたの手札のカードを望む枚数保存してよい。保存したカード１枚につき、[1]を１枚引いて得点する。],
  ], %w[nil 金属 木 木]],
  [9, '黄', 'エコロジー', [
    %w[電気 true あなたの手札を１枚再生してよい。そうした場合、あなたの手札のカードを１枚得点し、[10]を２枚引く。],
  ], %w[木 電気 電気 nil]],
  [10, '赤', '小型化', [
    %w[電気 true あなたの手札を１枚再生してよい。[10]のカードを再生した場合、あなたの影響の異なる値１つにつき[10]を１枚引く。],
  ], %w[nil 電気 時間 電気]],
  [10, '赤', 'ロボット工学', [
    %w[製造 true あなたのアクティブな緑のカードを得点する。[10]を１枚引いて場に出し、その後それのすべての協力型教義を、自分のみが発動する。],
  ], %w[nil 製造 時間 製造]],
  [10, '紫', '人工知能', [
    %w[電気 true [10]を１枚引いて得点する。],
    %w[電気 true 「ロボット工学」と「ソフトウェア」がいずれかの領域でアクティブなカードである場合、影響が単独で最も低いプレイヤーが勝利する。],
  ], %w[電気 電気 時間 nil]],
  [10, '紫', 'インターネット', [
    %w[時間 true あなたの緑のカードを上に展開してよい。],
    %w[時間 true [10]を１枚引いて得点する。],
    %w[時間 true あなたが生み出す「時間」２つにつき、[10]を１枚引いて場に出す。],
  ], %w[nil 時間 時間 電気]],
  [10, '緑', 'データベース', [
    %w[時間 false 要求する。お前の影響のカードを、その枚数の半分（端数切り上げ）再生せよ。],
  ], %w[nil 時間 時間 時間]],
  [10, '黄', 'グローバル化', [
    %w[製造 false 要求する。「木」を生み出すお前のアクティブなカードを１枚再生せよ。],
    %w[製造 true [6]を１枚引いて得点する。「製造」より多くの「木」を生み出すプレイヤーがいない場合、単独で最も影響ポイントの高いプレイヤーが勝利する。],
  ], %w[nil 製造 製造 製造]],
  [10, '青', 'ソフトウェア', [
    %w[時間 true [10]を１枚引いて得点する。],
    %w[時間 true [10]を２枚引いて順に場に出し、２枚目のカードのすべての協力型教義を、自分のみが発動する。],
  ], %w[時間 時間 時間 nil]],
  [10, '緑', 'ホームオートメーション', [
    %w[金属 true あなたのアクティブな他のカード１枚のすべての協力型教義を、自分のみが発動する。],
    %w[金属 true あなたの制覇が他のどのプレイヤーよりも多い場合、あなたは勝利する。],
  ], %w[nil 金属 金属 金属]],
  [10, '青', '生物工学', [
    %w[時間 true 「木」を生み出す他のプレイヤーのアクティブなカード１枚を、あなたの影響に譲渡する。],
    %w[時間 true いずれかのプレイヤーが「木」を３つ以下しか生み出さない場合、単独で最も多くの「木」を生み出すプレイヤーが勝利する。],
  ], %w[電気 時間 時間 nil]],
  [10, '黄', '幹細胞', [
    %w[木 true あなたの手札をすべて得点してよい。],
  ], %w[nil 木 木 木]],
]
size = DATA_CARDS.size
DATA_CARDS.each.with_index(1) do |(age_level, color_name, title, effects, resource_names), index|
  STDOUT.print "Seeding Card #{index}/#{size}...\r"
  age = Age.find_by(level: Integer(age_level))
  raise "Unknown Age '#{age_level}' for Card '#{title}'" unless age
  color = Color.find_by(name: color_name)
  raise "Unknown Color '#{color_name}' for Card '#{title}'" unless color
  card = Card.create!(age: age, color: color, title: title)
  effects.each do |resource_name, is_for_all, content|
    resource = Resource.find_by(name: resource_name)
    raise "Unknown Resource '#{resource_name}' for Card '#{title}'" unless resource
    raise "Illegal boolean '#{is_for_all}' for Card '#{title}'" unless %w[true false].include?(is_for_all)
    card.effects.create!(resource: resource, is_for_all: is_for_all == 'true', content: content)
  end
  resource_names.zip(%w[LT LB CB RB]) do |resource_name, position_abbr|
    next if resource_name == 'nil'
    resource = Resource.find_by(name: resource_name)
    raise "Unknown Resource '#{resource_name}' for Card '#{title}'" unless resource
    position = ResourcePosition.find_by(abbr: position_abbr)
    card.card_resources.create!(resource: resource, position: position)
  end
end
STDOUT.puts

[
  ['Hmn', false],
  ['Cm1', true ],
  ['Cm2', true ],
  ['Cm3', true ],
  ['Cm4', true ],
].each do |name, is_computer|
  Player.create!(name: name, is_computer: is_computer)
end
