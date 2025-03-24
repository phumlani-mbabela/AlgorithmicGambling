//+------------------------------------------------------------------+
//|                                              ErrorManagement.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

class ErrorManagement
  {
private:

public:
   ErrorManagement(){};
   ~ErrorManagement(){};
   string ErrorDescription(int error_code);
   
};

string ErrorManagement::ErrorDescription(int error_code)
{
    switch (error_code)
    {
        //case ERR_NO_ERROR: return "No error";
        //case ERR_TRADE_TIMEOUT: return "Trade request timeout";
        //case ERR_INVALID_STOPS: return "Invalid stop loss or take profit";
        //case ERR_NO_MONEY: return "Not enough money";
        //case ERR_MARKET_CLOSED: return "Market is closed";
        case 0: return "No error";
        case 130: return "Invalid stop loss or take profit";
        case 4109: return "Trade context is busy";
        case 4066: return "Market is closed";
        case 10006: return "Not enough funds";
        default: return "Unknown error";
    }
}