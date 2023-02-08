#################################
# 出版者のウェブページ上での書誌情報の規則
# commit: 928ace119402a9efef0573675494a025d562c428
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
  filter(name == "山と溪谷社")

df_publisher <- 
  df_publisher |> 
  mutate(domain = case_match(
    name,
    "文藝春秋" ~ "https://books.bunshun.jp",
    "河出書房新社" ~ "https://www.kawade.co.jp",
    "学芸出版社" ~ "https://book.gakugei-pub.co.jp",
    .default = domain))

df_publisher <- 
  df_publisher |> 
  mutate(path = case_match(
    name,
    c("ダイヤモンド社", "日本実業出版社", "秀和システム") ~ "/book/",
    c("東洋経済新報社") ~ "/books/",
    c("山と溪谷社") ~ "/products/",
    c("サイエンス社") ~ "/search/?isbn=",
    c("学芸出版社") ~ "/gakugei-book/",
    c("河出書房新社") ~ "/np/isbn/",
    c("光文社") ~ "/shelf/book/isbn/",
    c("文藝春秋") ~ "/ud/book/num/"))

df_publisher <- 
  df_publisher |> 
  mutate(suffix = case_match(
    name,
    c("ダイヤモンド社", "秀和システム", "山と溪谷社") ~ ".html"
  ))

df_publisher <- 
  df_publisher |> 
  mutate(pattern = case_match(
    name,
    # 1... ハイフンなし
    c("光文社", "ダイヤモンド社",
      "文藝春秋", "東洋経済新報社", "日本実業出版社",
      "河出書房新社", "学芸出版社", "秀和システム",
      "山と溪谷社") ~ 1,
    # 2... ハイフンあり
    c("サイエンス社") ~ 2,
    # 99... パターン識別不可
    c("東京大学出版会", "皓星社", "原書房") ~ 99
  ))

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
