import yfinance as yahooFinance
from pandas_datareader import data
import re

def list_to_str(li):
    a = ""
    for i in li:
        a += i
    return a

Tickers=["AAPL","GOOG","RY","HPQ", "FB", "T"]

for str in Tickers:
    tickers = str
    print("INSERT INTO \'ETF\' (\'%s\', %d, \'%s\');" %(tickers, data.get_quote_yahoo(tickers)["trailingAnnualDividendRate"], re.sub("^\w*\s+", "", data.get_quote_yahoo(tickers)['longName'].to_string())))


# a = float(re.sub( "^\d*-\d*-\d*\s+\w*\s+","", data.DataReader('FB', 'yahoo-actions').to_string().split("\n")[1]))
# print(a)
print(list_to_str(re.findall("\d+\.\d+", "12.34")))

