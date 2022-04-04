import string
import random
import time

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
    Tickers=["CCL", "AAPL","GOOG","RY","HPQ", "FB", "T", "AA", "TSLA", "SM", "CAG", "STOR", "TSM", "EMBK", "SPCE", "AMZN", "USB", "RY", "VEON" ]
    for str in Tickers:
        tickers = str
        print("INSERT INTO \'Options\' (\'%s\', %s, \'%s\', %s, %s, %s);"

                                                        %(
                                                            random_id(),                                                                        # Option Symbol
                                                            random_date,                                                                        # Expiration Date
                                                            clean(data.get_quote_yahoo(tickers)['longName'].to_string()),                       # Stock company name
                                                            clean(data.get_quote_yahoo(tickers)['price'].to_string()),                          # value
                                                            clean(data.get_quote_yahoo(tickers)['sharesOutstanding'].to_string()),              # sharesOutstanding
                                                            clean(data.get_quote_yahoo(tickers)['marketCap'].to_string())                       # marketCap

                                                        ))


def random_id():
    return ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(8))


def str_time_prop(start, end, time_format, prop):
    """Get a time at a proportion of a range of two formatted times.

    start and end should be strings specifying times formatted in the
    given format (strftime-style), giving an interval [start, end].
    prop specifies how a proportion of the interval to be taken after
    start.  The returned time will be in the specified format.
    """

    stime = time.mktime(time.strptime(start, time_format))
    etime = time.mktime(time.strptime(end, time_format))

    ptime = stime + prop * (etime - stime)

    return time.strftime(time_format, time.localtime(ptime))


def random_date(start, end, prop):
    return str(str_time_prop(start, end, '%m/%d/%Y %I:%M %p', prop))


# print(random_date("1/1/2008 9:30 PM", "1/1/2009 5:00 AM", random.random()))

# print(random_id())
