import yfinance as yahooFinance
from pandas_datareader import data
import re

def list_to_str(li):
    a = ""
    for i in li:
        a += i
    return a if a != "" else "0"

def clean(i):
    return re.sub("^\w*\s+", "", i)

def query():
    Tickers=["AAC" ]
    for str in Tickers:
        tickers = str
        print("INSERT INTO \'ETF\' (\'%s\', %s, \'%s\', %s, %s, %s);"

                                                        %(
                                                            tickers,                                                                        # Stock name
                                                            list_to_str(re.findall("\d+\.\d+", re.sub( "^\d*-\d*-\d*\s+\w*\s+","",
                                                            data.DataReader(tickers, 'yahoo-actions').to_string().split("\n")[1]))),        # Stock dividend
                                                            clean(data.get_quote_yahoo(tickers)['longName'].to_string()),                   # Stock company name
                                                            clean(data.get_quote_yahoo(tickers)['price'].to_string()),                      # value
                                                            clean(data.get_quote_yahoo(tickers)['sharesOutstanding'].to_string()),          # sharesOutstanding
                                                            clean(data.get_quote_yahoo(tickers)['marketCap'].to_string())                   # marketCap

                                                        ))

query()