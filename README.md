# StockScraper.R
A function (soon to be package) to scrape Yahoo! finance historical stock data. 
This is compatible with their horrible API update that requires a cookie/crumb to access the historicals.

## Installation
    source("https://raw.githubusercontent.com/ScientistJake/StockScraper.R/master/StockScraper.R")

## Usage
    stockhistoricals(stocklist, start_date, end_date, verbose=TRUE) . 
## Arguments
stocklist : A vector of stock tickers. Can also pass "NYSE", "NASDAQ", or "AMEX" to get those lists. Default = GOOG.  
start_date : start date in format Year-month-day. Default = "1970-01-01" .  
end_date : end date in format Year-month-day. Default = system date .  
verbose : Logical. if FALSE, suppresses messages. Default = TRUE .  
## Value
Returns a list of dataframes containing the stock data . 
## Examples
    #get data for AMEX
    AMEX <- stockhistoricals("AMEX", start_date = "2016-09-10")
    
    #check out the first 10 names
    names(AMEX)[1:10]
        [1] "XXII"           "FAX"            "IAF"            "CH"             "ABE           "
        [6] "FCO"            "IF"             "ISL"            "ACU"            "ATNM"
        
    #check out data for FAX    
    head(AMEX$FAX)
        Date Open High  Low Close Adj.Close  Volume
      1 2016-09-12 5.25 5.25 5.13  5.16  4.738139  559300
      2 2016-09-13 5.14 5.14 4.99  5.01  4.600402 1149100
      3 2016-09-14 5.01 5.07 5.01  5.01  4.600402  716500
      4 2016-09-15 5.01 5.05 5.00  5.04  4.627948  706700
      5 2016-09-16 5.09 5.09 5.00  5.01  4.600402  342600
      6 2016-09-19 5.00 5.04 4.99  4.99  4.614273  641400
      
    #get average price for FAX
    mean(AMEX$FAX$Adj.Close)
        [1] 4.758571
    
