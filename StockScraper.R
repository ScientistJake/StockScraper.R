get_stocklists <- function(exchange="NYSE"){
  if(exchange=="NASDAQ"){
    read.csv(file="http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nasdaq&render=download")
  } else if (exchange == "NYSE"){
    read.csv(file="http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download")
  } else if (exchange == "AMEX"){
    read.csv(file="http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=amex&render=download")
  } else {
    message("ERROR: a valid exchange wasn't specified.")
    message("Try 'NYSE', 'NASDQ', or 'AMEX'")
    message("usage: get_stocklists(exchange)")
  }
}

stockhistoricals <- function(stocklist="GOOG", start_date="1970-01-01", end_date=as.Date(Sys.time()), verbose=TRUE){
  
  ## Usage stockhistoricals(stocklist, start_date, end_date, verbose=TRUE)
  ##    stocklist : A vector of stock tickers. Default = GOOG. Can also pass "NYSE", "NASDAQ", or "AMEX" to get those lists.
  ##    start_date : start date in format Year-month-day. Default = "1970-01-01"
  ##    end_date : end date in format Year-month-day. Default = system date
  ##    verbost : Logical. if F, suppresses messages
  
  require(XML)
  require(RCurl)
  require(httr)
  require(readr)
  
  options(warn=-1)
  if(stocklist=="NASDAQ" | stocklist=="NYSE" | stocklist=="AMEX"){
    stocklist <- get_stocklists(stocklist)
    stocklist <- stocklist$Symbol
  }
  options(warn=0)
  
  #86400 is the conversion from days to minutes (how yahoo is counting time)
  #t=1 is 1970-01-01. So any is 86400 minutes per day from 1970-01-01
  start <- as.numeric(as.Date(start_date)-as.Date("1970-01-01"))* 86400
  end <- as.numeric(as.Date(end_date)-as.Date("1970-01-01"))* 86400
  
  #grab a cookie. Try 5 times because sometimes yahoo puts fucking escape characters in the crumb
  tries = 1
  status = 1
  while (tries < 5 && status !=200){
    url <- paste0("https://finance.yahoo.com/quote/GOOG/history")
    h <- handle(url)
    res <- GET(handle = h)
    response <- content(res, "text")
    cookie <- unlist(strsplit(unlist(res$headers[5]),';'))[1]
    
    #this gets a crumb pair to use. I hate regex
    crumbled = stringr::str_extract(response, '\"CrumbStore\\\":\\{\\\"crumb\\\":\\\"[[:graph:]]+?\\\"\\}')
    crumb <- unlist(strsplit(crumbled,split='"'))[6]
    
    #test them
    testurl <- paste0("https://query1.finance.yahoo.com/v7/finance/download/GOOG?period1=1451606400&period2=1483228800&interval=1d&events=history&crumb=",crumb)
    scraped <- GET(testurl, config(cookie= cookie))
    
    status <- status_code(scraped)
    tries = tries + 1
  }
  
  if (status != 200){
    message("ERROR: Couldn't access Yahoo after 5 tries")
  }
  if (status == 401){
    message("ERROR: The cookie/crumb scrape didn't work... Fucking yahoo...")
  }
  
  if (verbose == TRUE){
    message("Grabbing Stock data... This takes a while for long stocklists")
  }
  
  stocksdf<- lapply(stocklist,function(x){
    if (verbose == TRUE){
      message(paste0("Downloading ",x))
    }
    capture <- paste0("https://query1.finance.yahoo.com/v7/finance/download/",x,"?period1=",start,"&period2=",end,"&interval=1d&events=history&crumb=",crumb)
    scraped <- GET(capture, config(cookie= cookie))
    #the content() call is loud so I suppress messages for now
    suppressMessages(data.frame(content(scraped)))
  })
  names(stocksdf) <- stocklist
  return(stocksdf)
}
