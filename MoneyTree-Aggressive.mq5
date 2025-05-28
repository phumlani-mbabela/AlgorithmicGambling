//+------------------------------------------------------------------+
//|                                                    MoneyTree.mq5 |
//|                                Copyright 2025, Phumlani Mbabela. |
//|                                  https://www.phumlanimbabela.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Phumlani Mbabela Inc"
#property link      "https://www.phumlanimbabela.co.za"
#property version   "1.23"
#include <Trade\Trade.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>
#include "CandleUtils\ThreeCandlestickPatterns.mqh"
#include "CandleUtils\TwoCandlestickPatterns.mqh"
#include "CandleUtils\OneCandlestickPatterns.mqh"

#include "Notification\Notification.mqh"

CTrade trade;

// INPUTS
input double RiskPercent     = 1.0;                // Risk per trade (%)
input double StopLossPips    = 100.0;              // SL in pips
input double TakeProfitPips  = 140.0;              // TP in pips
input int MAPeriod           = 28;                 // MA Period
input int MAShift            = 4;                  // MA Shift
input ENUM_MA_METHOD MAType  = MODE_EMA;           // MA Type
input ENUM_APPLIED_PRICE MAPrice = PRICE_TYPICAL;  // MA Price Type

input string SoundProfit     = "profit.wav";       // Sound for profitable trade
input string SoundLoss       = "loss.wav";         // Sound for losing trade
input ulong EAMagicNumber    = 70920035;           // EAMagicNumber
input bool IgnoreCandleStickPremonition = true;    // IgnoreCandleStickPremonition
input int SpreadMax = 13;                          // SpreadMax
input int MaxNumberOfTrades = 2;                   // MaxNumberOfTrades

// BUTTONS
string btnNames[5] = {"Buy", "Sell", "Close All", "Close Buy", "Close Sell"};
bool autoTradingEnabled = true;

// OBJECT NAMES
string lblInfo = "Panel_Info";
string btnPrefix = "btn_";

// GLOBALS
int winCount = 0, lossCount = 0;
double profitToday = 0.0;
double previousProfit = 0.0;
datetime lastResetTime = 0;

bool buyEntry=false, sellEntry=false;
int barsForCandlestickPattern =0;

int CurrentNumberOfTrades = 0;

Notification notification;

//+------------------------------------------------------------------+
//| Pattern detection algorithms.                                    |
//+------------------------------------------------------------------+
OneCandlestickPatterns     oneCandlestickPattern;
TwoCandlestickPatterns     twoCandlestickPattern;
ThreeCandlestickPatterns   threeCandlestickPattern;

enum MarketTrend {
   TREND_BULLISH,
   TREND_BEARISH,
   TREND_NEUTRAL
};

// INIT
int OnInit() {
   if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) {
      DrawPanel();
      EventSetTimer(5); // Every hour send summary information about the EA.
   }
   return INIT_SUCCEEDED;
}

// Timer Handler
void OnTimer() {
   datetime currentTime = TimeCurrent(); // Gets the current server time
   string timeString = TimeToString(currentTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS);
   string summary = getEASummary();
   summary += "Previous Profit:" + DoubleToString(previousProfit) + "\n";
   //notification.SendEmailNotification("EA Summary@"+timeString, summary);
   previousProfit = getProfit() ;

   double balance  = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity   = AccountInfoDouble(ACCOUNT_EQUITY);
   double profit   = AccountInfoDouble(ACCOUNT_PROFIT);
   string trend    = CheckTrend();

   winCount = 0;
   lossCount = 0;
   profitToday = 0.0;
   int total = HistoryDealsTotal();
   MqlDateTime dtNow;
   TimeToStruct(TimeCurrent(), dtNow);

   for(int i = 0; i < total; i++) {
      ulong ticket = HistoryDealGetTicket(i);
      if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;

      long magic = (long)HistoryDealGetInteger(ticket, DEAL_MAGIC);
      if (EAMagicNumber ==magic) {
         datetime dt = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         MqlDateTime dtDeal;
         TimeToStruct(dt, dtDeal);
         if(dtDeal.day != dtNow.day || dtDeal.mon != dtNow.mon || dtDeal.year != dtNow.year) continue;

         double p = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         profitToday += p;
         if(p > 0) winCount++;
         else lossCount++;
      }
   }
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   EventKillTimer();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void updateCandlesticks() {
   int bars = iBars(_Symbol, PERIOD_CURRENT);
   if(barsForCandlestickPattern != bars) {
      barsForCandlestickPattern = bars;
      // Evaluate the candle sticks, 3 pattern, 2 pattern and 1 pattern
      int buy1 = oneCandlestickPattern.OneShouldBuy();
      int buy2 = twoCandlestickPattern.TwoShouldBuy();
      int buy3 = threeCandlestickPattern.ThreeShouldBuy(1, PERIOD_CURRENT);
      int sell1 = oneCandlestickPattern.OneShouldSell();
      int sell2 = twoCandlestickPattern.TwoShouldSell();
      int sell3 = threeCandlestickPattern.ThreeShouldSell();

      buyEntry  = (buy1  || buy2  || buy3 || IgnoreCandleStickPremonition );
      sellEntry = (sell1 || sell2 || sell3 || IgnoreCandleStickPremonition );
   }
}

// TICK HANDLER
void OnTick() {
   static datetime lastCheck = 0;
   if(TimeCurrent() == lastCheck) return;
   lastCheck = TimeCurrent();

   ResetDailyCounters();

   if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) {
      UpdateInfoPanel();
      updateCandlesticks();
   }

   if(!autoTradingEnabled) return;

   MarketTrend dir = GetCandleDirection(_Symbol, PERIOD_CURRENT, 0); // 0 = current candle
   MarketTrend marketTrend = GetMarketTrend(_Symbol, PERIOD_CURRENT, 3);
   
   double spreadPoints = GetSpread(_Symbol, false);
   double spreadPips   = GetSpread(_Symbol, true);
   
   CurrentNumberOfTrades = GetCurrentNumberOfTradesByMagic(EAMagicNumber);

   string trend = CheckTrend();
   if(      (trend == "UP" || trend == "FLAT" )   && buyEntry  && (marketTrend==TREND_BULLISH) && (dir==TREND_BULLISH) && (spreadPoints<=SpreadMax) && (CurrentNumberOfTrades<=MaxNumberOfTrades) ) TryBuy()  ;
   else if( (trend == "DOWN" || trend == "FLAT" ) && sellEntry && (marketTrend==TREND_BEARISH) && (dir==TREND_BEARISH) && (spreadPoints<=SpreadMax) && (CurrentNumberOfTrades<=MaxNumberOfTrades) ) TrySell() ;
}


int GetCurrentNumberOfTradesByMagic(ulong magicNumber)
{
    int count = 0;
    int total = PositionsTotal();

    for (int i = 0; i < total; i++)
    {
        if (PositionGetTicket(i) > 0 && PositionSelectByTicket(PositionGetTicket(i)))
        {
            if (PositionGetInteger(POSITION_MAGIC) == magicNumber)
            {
                count++;
            }
        }
    }

    return count;
}


// RESET DAILY COUNTERS
void ResetDailyCounters() {
   datetime now = TimeCurrent();
   MqlDateTime dtNow;
   TimeToStruct(now, dtNow);

   MqlDateTime dtLast;
   TimeToStruct(lastResetTime, dtLast);

   if(dtNow.day != dtLast.day || dtNow.mon != dtLast.mon || dtNow.year != dtLast.year) {
      lastResetTime = now;
   }
}

// LOT SIZE
double CalculateLotSize() {
   double balance     = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount  = balance * RiskPercent / 100.0;
   double tickValue   = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize    = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double pipValue    = tickValue / tickSize * _Point;
   double lot         = riskAmount / (pipValue * StopLossPips);
   lot = NormalizeDouble(lot, 2);
   return MathMax(lot, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN));
}

// TREND CHECKER
string CheckTrend() {
   double maM5Val[], maM10Val[], maFast[], maSlow[];

   int handleM5  = iMA(_Symbol, PERIOD_M5, MAPeriod, MAShift, MAType, MAPrice);
   int handleM10 = iMA(_Symbol, PERIOD_M10, MAPeriod, MAShift, MAType, MAPrice);
// TODO - verify that the 4 and 7 dont need to be parameterised.
   int handleFast = iMA(_Symbol, PERIOD_M1, 4, 0, MAType, MAPrice);
   int handleSlow = iMA(_Symbol, PERIOD_M1, 7, 0, MAType, MAPrice);

   if(handleM5 == INVALID_HANDLE || handleM10 == INVALID_HANDLE || handleFast == INVALID_HANDLE || handleSlow == INVALID_HANDLE)
      return "UNKNOWN";

   if(CopyBuffer(handleM5, 0, 0, 1, maM5Val)  <= 0 || CopyBuffer(handleM10, 0, 0, 1, maM10Val) <= 0 ||
         CopyBuffer(handleFast, 0, 1, 2, maFast) <= 0 || CopyBuffer(handleSlow, 0, 1, 2, maSlow)  <= 0)
      return "UNKNOWN";

   if(maFast[1] < maSlow[1] && maFast[0] > maSlow[0] && maM5Val[0] > maM10Val[0])
      return "UP";
   else if(maFast[1] > maSlow[1] && maFast[0] < maSlow[0] && maM5Val[0] < maM10Val[0])
      return "DOWN";
   else
      return "FLAT";
}

// TRADES
void TryBuy() {
   if(PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) return;
   double lot = CalculateLotSize();
   double sl  = StopLossPips * _Point;
   double tp  = TakeProfitPips * _Point;

   double ask;
   SymbolInfoDouble(_Symbol, SYMBOL_ASK, ask);
   if(trade.Buy(lot, _Symbol, ask, ask - sl, ask + tp)) {
      PlaySound(SoundProfit);
   } else {
      PlaySound(SoundLoss);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrySell() {
   if(PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) return;
   double lot = CalculateLotSize();
   double sl  = StopLossPips * _Point;
   double tp  = TakeProfitPips * _Point;

   double bid;
   SymbolInfoDouble(_Symbol, SYMBOL_BID, bid);
   if(trade.Sell(lot, _Symbol, bid, bid + sl, bid - tp)) {
      PlaySound(SoundProfit);
   } else {
      PlaySound(SoundLoss);
   }
}

// GUI
void DrawPanel() {
   for(int i = 0; i < 5; i++) {
      string objName = btnPrefix + btnNames[i];
      ObjectCreate(0, objName, OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, 10 + (i * 70));
      ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, 100);
      ObjectSetInteger(0, objName, OBJPROP_WIDTH, 65);
      //ObjectSetInteger(0, objName, OBJPROP_HEIGHT, 20);
      ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, objName, OBJPROP_TEXT, btnNames[i]);
   }

   ObjectCreate(0, lblInfo, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, lblInfo, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, lblInfo, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, lblInfo, OBJPROP_YDISTANCE, 10);
   ObjectSetInteger(0, lblInfo, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, lblInfo, OBJPROP_COLOR, clrWhite);
}

// UPDATE INFO
void UpdateInfoPanel() {
   double balance  = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity   = AccountInfoDouble(ACCOUNT_EQUITY);
   double profit   = AccountInfoDouble(ACCOUNT_PROFIT);
   string trend    = CheckTrend();

   winCount = 0;
   lossCount = 0;
   profitToday = 0.0;
   int total = HistoryDealsTotal();
   MqlDateTime dtNow;
   TimeToStruct(TimeCurrent(), dtNow);

   for(int i = 0; i < total; i++) {
      ulong ticket = HistoryDealGetTicket(i);
      if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;

      long magic = (long)HistoryDealGetInteger(ticket, DEAL_MAGIC);
      if (EAMagicNumber ==magic) {
         datetime dt = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         MqlDateTime dtDeal;
         TimeToStruct(dt, dtDeal);
         if(dtDeal.day != dtNow.day || dtDeal.mon != dtNow.mon || dtDeal.year != dtNow.year) continue;

         double p = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         profitToday += p;
         if(p > 0) winCount++;
         else lossCount++;
      }

      string info = StringFormat(
                       "Balance: %.2f\n" +
                       "Equity: %.2f\n" +
                       "Profit: %.2f\n" +
                       "Trend: %s\n" +
                       "Wins: %d | Losses: %d | Profit Today: %.2f\n" +
                       "AutoTrading: %s\n" +
                       "Risk%%: %.1f | SL: %.1f | TP: %.1f\n" +
                       "MA Period: %d | Type: %d | Price: %d",
                       balance, equity, profit, trend, winCount, lossCount, profitToday,
                       (autoTradingEnabled ? "ON" : "OFF"),
                       RiskPercent, StopLossPips, TakeProfitPips, MAPeriod, MAType, MAPrice);

      ObjectSetString(0, lblInfo, OBJPROP_TEXT, info);
   }
}

// UPDATE INFO
string getEASummary() {
   double balance  = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity   = AccountInfoDouble(ACCOUNT_EQUITY);
   double profit   = AccountInfoDouble(ACCOUNT_PROFIT);
   string trend    = CheckTrend();

   winCount = 0;
   lossCount = 0;
   profitToday = 0.0;
   int total = HistoryDealsTotal();
   MqlDateTime dtNow;
   TimeToStruct(TimeCurrent(), dtNow);

   for(int i = 0; i < total; i++) {
      ulong ticket = HistoryDealGetTicket(i);
      if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;

      long magic = (long)HistoryDealGetInteger(ticket, DEAL_MAGIC);
      if (EAMagicNumber ==magic) {
         datetime dt = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         MqlDateTime dtDeal;
         TimeToStruct(dt, dtDeal);
         if(dtDeal.day != dtNow.day || dtDeal.mon != dtNow.mon || dtDeal.year != dtNow.year) continue;

         double p = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         profitToday += p;
         if(p > 0) winCount++;
         else lossCount++;
      }
   }

   string info = StringFormat(
                    "Balance: %.2f\n" +
                    "Equity: %.2f\n" +
                    "Profit: %.2f\n" +
                    "Trend: %s\n" +
                    "Wins: %d | Losses: %d | Profit Today: %.2f\n" +
                    "AutoTrading: %s\n" +
                    "Risk%%: %.1f | SL: %.1f | TP: %.1f\n" +
                    "MA Period: %d | Type: %d | Price: %d",
                    balance, equity, profit, trend, winCount, lossCount, profitToday,
                    (autoTradingEnabled ? "ON" : "OFF"),
                    RiskPercent, StopLossPips, TakeProfitPips, MAPeriod, MAType, MAPrice);

   return info;
}


// UPDATE INFO
double getProfit() {

   string trend    = CheckTrend();
   profitToday = 0.0;
   int total = HistoryDealsTotal();
   MqlDateTime dtNow;
   TimeToStruct(TimeCurrent(), dtNow);

   for(int i = 0; i < total; i++) {
      ulong ticket = HistoryDealGetTicket(i);
      if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;

      long magic = (long)HistoryDealGetInteger(ticket, DEAL_MAGIC);
      if (EAMagicNumber ==magic) {
         datetime dt = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         MqlDateTime dtDeal;
         TimeToStruct(dt, dtDeal);
         if(dtDeal.day != dtNow.day || dtDeal.mon != dtNow.mon || dtDeal.year != dtNow.year) continue;
         double p = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         profitToday += p;
      }
   }
   return profitToday;
}

// BUTTON EVENTS
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   if(StringFind(sparam, btnPrefix) != 0) return;
   string btn = StringSubstr(sparam, StringLen(btnPrefix));

   if(btn == "Buy")         TryBuy();
   else if(btn == "Sell")   TrySell();
   else if(btn == "Close All") CloseAll();
   else if(btn == "Close Buy") CloseType(POSITION_TYPE_BUY);
   else if(btn == "Close Sell") CloseType(POSITION_TYPE_SELL);
}

// CLOSE UTILS
void CloseAll() {
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket)) {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol) {
            long magic = (long)HistoryDealGetInteger(ticket, DEAL_MAGIC);
            if (EAMagicNumber ==magic) {
               trade.PositionClose(ticket);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseType(int type) {
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket)) {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_TYPE) == type) {
            long magic = (long)HistoryDealGetInteger(ticket, DEAL_MAGIC);
            if (EAMagicNumber ==magic) {
               trade.PositionClose(ticket);
            }
         }
      }
   }
}
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MarketTrend GetMarketTrend(string symbol, ENUM_TIMEFRAMES timeframe, int nCandles) {
   double bullishScore = 0.0;
   double bearishScore = 0.0;

   for (int i = 1; i <= nCandles; i++) { // skip current forming candle
      double open  = iOpen(symbol, timeframe, i);
      double close = iClose(symbol, timeframe, i);
      double body  = MathAbs(close - open);

      if (close > open)
         bullishScore += body;
      else if (close < open)
         bearishScore += body;
      // if close == open, do nothing (neutral candle)
   }

   if (bullishScore > bearishScore)
      return TREND_BULLISH;
   else if (bearishScore > bullishScore)
      return TREND_BEARISH;
   else
      return TREND_NEUTRAL;
}


//+------------------------------------------------------------------+
//| Detect if a candle is bullish, bearish, or neutral               |
//| index = 0 for current candle, 1 for previous, etc.               |
//+------------------------------------------------------------------+
MarketTrend GetCandleDirection(string symbol, ENUM_TIMEFRAMES timeframe, int index = 0) {
   double open  = iOpen(symbol, timeframe, index);
   double close = iClose(symbol, timeframe, index);

   if (close > open)
      return TREND_BULLISH;
   else if (close < open)
      return TREND_BEARISH;
   else
      return TREND_NEUTRAL;
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Get current spread in points (or pips)                           |
//+------------------------------------------------------------------+
double GetSpread(string symbol = "EURUSD", bool inPips = false)
{
   double spreadPoints = (SymbolInfoDouble(symbol, SYMBOL_ASK) - SymbolInfoDouble(symbol, SYMBOL_BID)) / SymbolInfoDouble(symbol, SYMBOL_POINT);
   if (inPips)
   {
      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      return (digits == 5 || digits == 3) ? spreadPoints / 10.0 : spreadPoints; // 5-digit symbols (e.g., EURUSD = 1.12345)
   }
   return spreadPoints;
}