<a id="org0733c3e"></a>

# なんこれ

mikutterで、COVID-19（新型コロナウィルス）の感染者数などの最新情報を取得するプラグインです。


<a id="orgb56a32d"></a>

# インストール方法

Ruby 2.7で利用してください。それ以前のバージョンでは起動しません。

```sh
mkdir -p ~/.mikutter/plugin && git clone https://github.com/toshia/covid19.git ~/.mikutter/plugin/covid19
```

<a id="orge1ce896"></a>

# 使い方

<img src="https://github.com/toshia/covid19/blob/img/01.png?raw=true" />

初めて起動すると、赤い球のアイコンが表示されます。そのタブを開くと、以下の情報が時系列に混在しています。

-   新型コロナコールセンター相談件数
-   罹患者
-   陽性患者数

それぞれの情報は抽出タブデータソースとして提供されており、このタブには全て表示されています。必要な情報のみを選択して、君だけの最強の新型コロナウィルスを作ろう！


<a id="orgdae5028"></a>

# ありがとう

このプラグインが表示する情報は、 [東京都 新型コロナウイルス対策サイト - covid19](https://stopcovid19.metro.tokyo.lg.jp/)で提供されているものです。


<a id="orgdbd0ab8"></a>

# ライセンス

Copyright (c) 2020 Toshiaki Asai

Released under the MIT license

<https://opensource.org/licenses/mit-license.php>

ただし、skin/ディレクトリ以下の画像は、[いらすとや](https://www.irasutoya.com/)様の配布している素材ですので、そちらのライセンスに従います。

