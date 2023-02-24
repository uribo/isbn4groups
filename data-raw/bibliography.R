#################################
# 出版者のウェブページ上での書誌情報の規則
# commit: 928ace119402a9efef0573675494a025d562c428
# Issue... レーベルの差異をどう扱う
# 例えば角川書店、講談社、講談社サイエンティフィク --> skip
#################################
library(dplyr)
pins_resources_local <- 
  pins::board_folder(here::here("data-raw"))
pins::pin_meta(pins_resources_local, 
               name = "isbn-group4-publisher")
df_publisher_raw <- 
  pins::pin_read(pins_resources_local,
               name = "isbn-group4-publisher",
               hash = "752bf4c251c799ee")

df_publisher <- 
  df_publisher_raw |> 
  dplyr::select(name, domain = url) |> 
  distinct() |> 
  tibble::as_tibble()

df_publisher |> 
  slice(101:110)

df_publisher |> 
  filter(stringr::str_detect(name, "朝日新聞出版"))

df_publisher <- 
  df_publisher |> 
  mutate(toc = case_match(
    name,
    c("東京大学出版会", "ダイヤモンド社", "河出書房新社", "光文社",
      "東洋経済新報社", "山と溪谷社", "サイエンス社", "皓星社",
      "秀和システム", "学芸出版社", "丸善出版", "日本評論社",
      "コロナ社", "技術評論社", "岩波書店",
      "旺文社", "明治図書出版", "朝倉書店",
      "朝日出版社", "平凡社", "オーム社",
      "医学出版", "インプレス",
      "クロスメディア・パブリッシング",
      "笠間書院", "共立出版", "勁草書房",
      "PHP研究所", "WAVE出版",
      "世界思想社",
      "研究社", "晶文社") ~ TRUE,
    c("原書房", "文藝春秋", "日本実業出版社",
      "朝日新聞出版", "偕成社", "プレビジョン",
      "星海社", "中央公論新社", "NHK出版",
      "早川書房", "徳間書店", "あかね書房",
      "秋田書店", "日経BP", "白水社") ~ FALSE
  ))

df_publisher <- 
  df_publisher |> 
  mutate(domain = case_match(
    name,
    "文藝春秋" ~ "https://books.bunshun.jp",
    "河出書房新社" ~ "https://www.kawade.co.jp",
    "学芸出版社" ~ "https://book.gakugei-pub.co.jp",
    "日経BP" ~ "https://bookplus.nikkei.com",
    "笠間書院" ~ "http://shop.kasamashoin.jp",
    "研究社" ~ "https://books.kenkyusha.co.jp",
    .default = domain))

df_publisher <- 
  df_publisher |> 
  mutate(path = case_match(
    name,
    c("クロスメディア・パブリッシング") ~ "",
    c("ダイヤモンド社", "日本実業出版社", "秀和システム",
      "オーム社", "研究社") ~ "/book/",
    c("東洋経済新報社", "偕成社", "WAVE出版") ~ "/books/",
    c("朝日出版社") ~ "/bookdetail_norm/",
    c("明治図書出版") ~ "/detail/",
    c("笠間書院") ~ "/bd/isbn/",
    c("NHK出版") ~ "/detail/{00000}",
    c("技術評論社") ~ "/book/{year}/",
    c("PHP研究所") ~ "/books/detail.php?isbn=",
    c("山と溪谷社") ~ "/products/",
    c("サイエンス社") ~ "/search/?isbn=",
    c("あかね書房") ~ "/search/info.php?isbn=",
    c("学芸出版社") ~ "/gakugei-book/",
    c("河出書房新社", "コロナ社") ~ "/np/isbn/",
    c("光文社") ~ "/shelf/book/isbn/",
    c("文藝春秋") ~ "/ud/book/num/",
    c("中央公論新社") ~ "/{type}/{year}/{month}/"))

df_publisher <- 
  df_publisher |> 
  mutate(suffix = case_match(
    name,
    c("ダイヤモンド社", "秀和システム", "山と溪谷社",
      "中央公論新社", "研究社") ~ ".html",
    c("NHK出版") ~ "{year}.html"
  ))

df_publisher <- 
  df_publisher |> 
  mutate(pattern = case_match(
    name,
    # 1... ハイフンなし
    c("光文社", "ダイヤモンド社",
      "文藝春秋", "東洋経済新報社", "日本実業出版社",
      "河出書房新社", "学芸出版社", "秀和システム",
      "山と溪谷社", "コロナ社", "偕成社",
      "NHK出版", "あかね書房", "朝日出版社",
      "オーム社", "晶文社", "クロスメディア・パブリッシング",
      "笠間書院", "WAVE出版") ~ 1,
    # 2... ハイフンあり
    c("サイエンス社", "技術評論社", "研究社", "PHP研究所") ~ 2,
    # 3... ハイフンあり 978なし
    c("明治図書出版") ~ 3,
    # 4... 書名記号のみ
    c("中央公論新社") ~ 4,
    # 98 .... ISBNっぽいが違う
    c("秋田書店") ~ 98,
    # 99... パターン識別不可
    c("東京大学出版会", "皓星社", "原書房", "丸善出版",
      "日本評論社", "岩波書店", "旺文社",
      "朝日新聞出版", "プレビジョン", "星海社",
      "早川書房", "徳間書店", "朝倉書店",
      "平凡社", "晶文社", "医学出版",
      "インプレス", "日経BP", "白水社",
      "共立出版", "勁草書房", "世界思想社") ~ 99
  ))

df_publisher |> 
  filter(!is.na(pattern), is.na(toc))

df_publisher |> 
  filter(name == "山と溪谷社") |> 
  tidyr::replace_na(list(suffix = "")) |> 
  mutate(isbn = "2822049430") |> 
  mutate(isbs = if_else(pattern == 1,
                        stringr::str_remove_all(isbn, "-"),
                        isbn)) |> 
  transmute(bibliography_url = stringr::str_glue("{domain}{path}{isbn}{suffix}"))

# stringr::str_glue_data("{url}{path}{isbn}{suffix}",
#                        isbn = "9784334036195",
#                        .na = "")  
