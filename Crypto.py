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
    Tickers=["BTC-USD", "ETH-USD", "ADA-USD", "SOL-USD", "ALGO-USD", "LUNA-USD"]
    for str in Tickers:
        tickers = str
        print("INSERT INTO \'ETF\' (\'%s\', %s, %s, %s,\'%s\');"

                                                        %(
                                                            tickers,                                                                        # Stock name
                                                            clean(data.get_quote_yahoo(tickers)['marketCap'].to_string()),          # sharesOutstanding
                                                            clean(data.get_quote_yahoo(tickers)['marketCap'].to_string()),                   # marketCap
                                                            clean(data.get_quote_yahoo(tickers)['price'].to_string()),                       # value
                                                            clean(data.get_quote_yahoo(tickers)['price'].to_string())                   # Stock company name

                                                        ))

query()