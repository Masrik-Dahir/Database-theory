CREATE TABLE Users (
    TIN NUMERIC(9,0),
    investor_name VARCHAR(40) NOT NULL,
    email_address VARCHAR(40) NOT NULL UNIQUE,
    street_address VARCHAR(50) NOT NULL,
    city VARCHAR(20) NOT NULL,
    state_abbr CHAR(2),
    zip_code NUMERIC(5, 0),
    date_of_birth DATE NOT NULL,
    user_type CHAR(2) NOT NULL,
    PRIMARY KEY (TIN)
);

CREATE TABLE Users_Phone (
    TIN NUMERIC(9,0),
    phone_number NUMERIC(10,0) UNIQUE,
    PRIMARY KEY (TIN, phone_number),
    FOREIGN KEY (TIN) REFERENCES Users(TIN)
);

CREATE TABLE Users_Bank_Account (
    TIN NUMERIC(9,0),
    Bank_Account_Number NUMERIC(12,0),
    Routing_Number NUMERIC(9,0),
    PRIMARY KEY (TIN, bank_account_number, routing_number),
    FOREIGN KEY (TIN) REFERENCES Users(TIN)
);

CREATE TABLE Users_Transaction (
    TIN NUMERIC(9,0),
    Transaction_Number NUMERIC(12, 0),
    asset_type VARCHAR(15) NOT NULL,
    PRIMARY KEY (TIN, Transaction_Number),
    FOREIGN KEY (TIN) REFERENCES Users(TIN)
);

CREATE TABLE Individual_Investor (
    SSN NUMERIC(9,0),
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    email_address VARCHAR(40) NOT NULL UNIQUE,
    street_address VARCHAR(20) NOT NULL,
    city VARCHAR(20) NOT NULL,
    state_abbr CHAR(2) NOT NULL,
    zip_code NUMERIC(5, 0),
    date_of_birth DATE NOT NULL,
    PRIMARY KEY (SSN)
);

CREATE TABLE Brokerage (
    EIN NUMERIC(9,0),
    commission FLOAT,
    license VARCHAR(20),
    leverage_trading BIT NOT NULL,
    PRIMARY KEY (EIN),
    FOREIGN KEY (EIN) REFERENCES Users(TIN)
);

CREATE TABLE Brokerage_Account (
    SSN NUMERIC(9,0),
    TIN NUMERIC(9,0),
    Account_Number NUMERIC(12,0),
    Account_Routing_Number NUMERIC(9,0),
    PRIMARY KEY (SSN, TIN, Account_Number, Account_Routing_Number),
    FOREIGN KEY (SSN) REFERENCES Individual_Investor(SSN),
    FOREIGN KEY (TIN) REFERENCES Brokerage(EIN)
);

CREATE INDEX Brokerage_Account_Info ON Brokerage_Account(Account_Number, Account_Routing_Number);

CREATE TABLE Bank_Relation (
    Brokerage_Account_Number NUMERIC(12,0),
    Brokerage_Account_Routing_Number NUMERIC (9,0),
    II_Bank_Account_Number NUMERIC(12,0),
    II_Bank_Account_Routing_Number NUMERIC(9,0),
    PRIMARY KEY (Brokerage_Account_Number, Brokerage_Account_Routing_Number, II_Bank_Account_Number, II_Bank_Account_Routing_Number),
    FOREIGN KEY (Brokerage_Account_Number, Brokerage_Account_Routing_Number) REFERENCES Brokerage_Account(Account_Number, Account_Routing_Number)
);

CREATE TABLE Individual_Investor_Phone (
    SSN NUMERIC(9,0),
    phone_number NUMERIC(10,0) UNIQUE,
    PRIMARY KEY (SSN, phone_number)
);

CREATE TABLE Direct_Investor (
    TIN NUMERIC(9,0),
    public_trading BIT NOT NULL,
    PRIMARY KEY (TIN),
    FOREIGN KEY (TIN) REFERENCES Users(TIN)
);

CREATE TABLE Exchange (
    Market_Identifier_Code VARCHAR(10),
    CEO VARCHAR(40),
    currency VARCHAR(10) NOT NULL,
    number_of_securities INT NOT NULL,
    market_cap INT NOT NULL,
    website VARCHAR(40),
    date_founded DATE NOT NULL,
    PRIMARY KEY (Market_Identifier_Code)
);

CREATE TABLE Exchange_Index (
    Market_Identifier_Code CHAR(10),
    Market_Index VARCHAR(10),
    PRIMARY KEY (Market_Identifier_Code, Market_Index),
    FOREIGN KEY (Market_Identifier_Code) REFERENCES Exchange(Market_Identifier_Code)
);

CREATE TABLE ETF (
    ETF_Symbol VARCHAR(5),
    dividend FLOAT NOT NULL,
    company VARCHAR(255) NOT NULL,
    unit_price FLOAT NOT NULL,
    number_of_shares INT NOT NULL,
    market_cap INT NOT NULL,
    PRIMARY KEY (ETF_Symbol)
);

CREATE TABLE ETF_Transaction (
    TIN NUMERIC(9,0),
    Transaction_Number NUMERIC(12,0),
    ETF_Symbol VARCHAR(5) NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (TIN, Transaction_Number),
    FOREIGN KEY (TIN, Transaction_Number) REFERENCES Users_Transaction(TIN, Transaction_Number),
    FOREIGN KEY (ETF_Symbol) REFERENCES ETF(ETF_Symbol)
);

CREATE TABLE Exchange_ETFs (
    Market_Identifier_Code VARCHAR(10),
    ETF_Symbol VARCHAR(5),
    PRIMARY KEY (Market_Identifier_Code, ETF_Symbol),
    FOREIGN KEY (Market_Identifier_Code) REFERENCES Exchange(Market_Identifier_Code),
    FOREIGN KEY (ETF_Symbol) REFERENCES ETF(ETF_Symbol)
);

CREATE TABLE Cryptocurrency (
    Cryptocurrency_Symbol VARCHAR(10),
    total_supply INT NOT NULL,
    market_cap FLOAT NOT NULL,
    unit_price FLOAT NOT NULL,
    cryptocurrency_name VARCHAR(255) NOT NULL,
    PRIMARY KEY (Cryptocurrency_Symbol)
);

CREATE TABLE Cryptocurrency_Transaction (
    TIN NUMERIC(9,0),
    Transaction_Number NUMERIC(12,0),
    Cryptocurrency_Symbol VARCHAR(10) NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (TIN, Transaction_Number),
    FOREIGN KEY (TIN, Transaction_Number) REFERENCES Users_Transaction(TIN, Transaction_Number),
    FOREIGN KEY (Cryptocurrency_Symbol) REFERENCES Cryptocurrency(Cryptocurrency_Symbol)
);

CREATE TABLE Exchange_Cryptocurrencies (
    Market_Identifier_Code VARCHAR(10),
    Cryptocurrency_Symbol VARCHAR(10),
    PRIMARY KEY (Market_Identifier_Code, Cryptocurrency_Symbol),
    FOREIGN KEY (Market_Identifier_Code) REFERENCES Exchange(Market_Identifier_Code),
    FOREIGN KEY (Cryptocurrency_Symbol) REFERENCES Cryptocurrency(Cryptocurrency_Symbol)
);

CREATE TABLE Mutual_Fund (
    Mutual_Fund_Symbol VARCHAR(5),
    dividend FLOAT NOT NULL,
    unit_price FLOAT NOT NULL,
    asset_class VARCHAR(255) NOT NULL,
    fund_name VARCHAR(255) NOT NULL,
    net_asset_value INT NOT NULL,
    PRIMARY KEY (Mutual_Fund_Symbol)
);

CREATE TABLE Mutual_Fund_Transaction (
    TIN NUMERIC(9,0),
    Transaction_Number NUMERIC(12,0),
    Mutual_Fund_Symbol VARCHAR(5) NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (TIN, Transaction_Number),
    FOREIGN KEY (TIN, Transaction_Number) REFERENCES Users_Transaction(TIN, Transaction_Number),
    FOREIGN KEY (Mutual_Fund_Symbol) REFERENCES Mutual_Fund(Mutual_Fund_Symbol)
);

CREATE TABLE Exchange_Mutual_Funds (
    Market_Identifier_Code VARCHAR(10),
    Mutual_Fund_Symbol VARCHAR(5),
    PRIMARY KEY (Market_Identifier_Code, Mutual_Fund_Symbol),
    FOREIGN KEY (Market_Identifier_Code) REFERENCES Exchange(Market_Identifier_Code),
    FOREIGN KEY (Mutual_Fund_Symbol) REFERENCES Mutual_Fund(Mutual_Fund_Symbol)
);


CREATE TABLE Options (
    Option_Symbol VARCHAR(8),
    expiration_date DATE NOT NULL,
    strike_price FLOAT NOT NULL,
    asset_class VARCHAR(255) NOT NULL,
    stock_symbol VARCHAR(5) NOT NULL,
    PRIMARY KEY (Option_Symbol)
);

CREATE TABLE Options_Transaction (
    TIN NUMERIC(9,0),
    Transaction_Number NUMERIC(12,0),
    Option_Symbol VARCHAR(8) NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (TIN, Transaction_Number),
    FOREIGN KEY (TIN, Transaction_Number) REFERENCES Users_Transaction(TIN, Transaction_Number),
    FOREIGN KEY (Option_Symbol) REFERENCES Options(Option_Symbol)
);

CREATE TABLE Exchange_Options (
    Market_Identifier_Code VARCHAR(10),
    Option_Symbol VARCHAR(8),
    PRIMARY KEY (Market_Identifier_Code, Option_Symbol),
    FOREIGN KEY (Market_Identifier_Code) REFERENCES Exchange(Market_Identifier_Code),
    FOREIGN KEY (Option_Symbol) REFERENCES Options(Option_Symbol)
);



