ISBN-13における日本語での出版物に関するさまざまなデータ
=================

出版物に関するデータを収集し、csv形式と[Google Sheets上](https://docs.google.com/spreadsheets/d/1K0wVDUy4PMAHVdqh3S61VliXeZxwhWpfZLrmbJ4qZiU/edit?usp=sharing)で提供しています。
データの追加や修正を歓迎します。

[pins](https://github.com/rstudio/pins-r)を使ってR、Pythonで簡単に読み込むことができます。

## 出版社の一覧

- `houjin_bangou`: 法人番号
- `code`: 出版者記号(2~7桁)
- `name`: 出版者名（略称）
- `name_full`: 出版者名（社名・組織名）
- `url`: 出版者のURL

|houjin_bangou |code |name         |name_full            |url                            |
|:-------------|:----|:------------|:--------------------|:------------------------------|
|6010001010826 |00   |岩波書店     |株式会社岩波書店     |https://www.iwanami.co.jp      |
|5011101026036 |01   |旺文社       |株式会社旺文社       |https://www.obunsha.co.jp      |
|8010001115053 |02   |朝日新聞出版 |株式会社朝日新聞出版 |https://publications.asahi.com |
|1011101004375 |03   |偕成社       |株式会社偕成社       |https://www.kaiseisha.co.jp    |
|2010001163289 |04   |KADOKAWA     |株式会社KADOKAWA     |https://www.kadokawa.co.jp     |
|8011001034383 |04   |プレビジョン |株式会社プレビジョン |http://www.spoon01.com         |

### R

```r
pins::board_folder("data-raw") |> 
  pins::pin_read("isbn-group4-publisher")
```

### Python

```python
from pins import board_folder
board = board_folder("data-raw")
board.pin_read("isbn-group4-publisher")
```

## ライセンス

リポジトリ中のコードは[MITライセンス](https://opensource.org/licenses/MIT)の下に提供します。
csvデータは[クリエイティブ・コモンズ 表示 - 非営利 - 継承 4.0 国際 (CC BY-NC-SA 4.0) ライセンス](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.ja)の下に提供します。
