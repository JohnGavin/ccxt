
# https://biolitika.si/working-with-notion-api-from-r.html

library(httr)
library(jsonlite)

NOTION_KEY = Sys.getenv('NOTION_SO') 

ask <- GET(
  url = "https://api.notion.com/v1/databases/",
  add_headers("Authorization" = paste("Bearer", NOTION_KEY),
    "Notion-Version" = "2021-05-13"))
stop_for_status(ask)
fromJSON(rawToChar(ask$content))


# databases endpoint ----
# https://www.notion.so/2bb21e2065864297a9281c1eef69d68a?v=4ba5e0a5aaa84bbeb009c5c34b9a91a3
NOTION_DATABASE_ID = Sys.getenv('NOTION_DATABASE_ID')

pb <- list(
  # every curly braces and array need to be a list(). This worked (notice the extra list() calls compared to the original):
  parent = list(database_id = NOTION_DATABASE_ID),
  properties = list(
    Name = list(
      title = list(
        list(text = list(content = "4"))
      )
    ),
    Genus = list(
      rich_text = list(
        list(text = list(content = "Neki"))
      )
    ),
    Species = list(
      rich_text = list(
        list(text = list(content = "noviga"))
      )
    )
  )
)
pb

send.row <- POST(
  url = "https://api.notion.com/v1/pages",
  add_headers("Authorization" = paste("Bearer", NOTION_KEY),
    "Notion-Version" = "2021-05-13"),
  body = pb,
  encode = "json"
)
send.row