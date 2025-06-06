//+------------------------------------------------------------------+
//|                                                    MoneyTree.mq5 |
//|                                Copyright 2025, Phumlani Mbabela. |
//|                                  https://www.phumlanimbabela.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Phumlani Mbabela."
#property link      "https://www.phumlanimbabela.com"
#property version   "1.22"
#include <Trade\Trade.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>
#include "CandleUtils\ThreeCandlestickPatterns.mqh"
#include "CandleUtils\TwoCandlestickPatterns.mqh"
#include "CandleUtils\OneCandlestickPatterns.mqh"

#include "UI\EADashboard.mqh"

#include <ChartObjects\ChartObjectsTxtControls.mqh>
#include <ChartObjects\ChartObjectsShapes.mqh>

#include "Notification\Notification.mqh"

#include <Controls\Dialog.mqh>
#include <Controls\Label.mqh>
CAppDialog    myDialog;
CLabel        myLabel;

#include <Controls\Dialog.mqh>
#include <Controls\Panel.mqh>
#include <Controls\Label.mqh>
CAppDialog  mainDialog;
CPanel      background;
CLabel      labels[16]; // fixed to 16 lines

EADashboard dashboardPanel;

CTrade        trade;

// INPUTS
input group "=== Optimisation Inputs ==="
input double RiskPercent     = 1.0;            // Risk per trade (%)
input double StopLossPips    = 100.0;          // SL in pips
input double TakeProfitPips  = 140.0;          // TP in pips
input int MAPeriod           = 28;             // MA Period
input int MAShift            = 4;              // MA Shift
input int fastMAPeriod       = 4;              // Fast MA Period
input int slowMAPeriod       = 7;              // Slow MA Period
input ENUM_MA_METHOD MAType  = MODE_EMA;       // MA Type
input ENUM_APPLIED_PRICE MAPrice = PRICE_CLOSE;// MA Price Type

input group "=== No Optimisation ==="
input string SoundProfit     = "profit.wav";   // Sound for profitable trade
input string SoundLoss       = "loss.wav";     // Sound for losing trade
input ulong EAMagicNumber    = 7092551613335;  // EAMagicNumber
input bool IgnoreCandleStickPremonition = true;             // IgnoreCandleStickPremonition

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

Notification notification;

//+------------------------------------------------------------------+
//| Pattern detection algorithms.                                    |
//+------------------------------------------------------------------+
OneCandlestickPatterns     oneCandlestickPattern;
TwoCandlestickPatterns     twoCandlestickPattern;
ThreeCandlestickPatterns   threeCandlestickPattern;

// INIT
int OnInit() {
   if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) {
      DrawPanel();
      dashboardPanel.OnInit();
      EventSetTimer(5); // Every 5 seconds.
   }
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom Panel Creation Function                                   |
//+------------------------------------------------------------------+
void CreateInfoPanel(double balance1, double equity1, double profit1, string trend1,
                     int winCount1, int lossCount1, double profitToday1, string autoTradingStatus1) {
// Panel dimensions
   int panel_x      = 10;
   int panel_y      = 20;
   int panel_width  = 340;
   int panel_height = 200;

// Create or update background rectangle
   string rectName = "InfoPanel_Background";
   if (!ObjectFind(0, rectName)) {
      ObjectCreate(0, rectName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, rectName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, rectName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, rectName, OBJPROP_COLOR, clrDarkSlateGray);
      ObjectSetInteger(0, rectName, OBJPROP_BORDER_TYPE, BORDER_RAISED);
      ObjectSetInteger(0, rectName, OBJPROP_WIDTH, 2);
   }
   ObjectSetInteger(0, rectName, OBJPROP_XDISTANCE, panel_x);
   ObjectSetInteger(0, rectName, OBJPROP_YDISTANCE, panel_y);
   ObjectSetInteger(0, rectName, OBJPROP_XSIZE, panel_width);
   ObjectSetInteger(0, rectName, OBJPROP_YSIZE, panel_height);

// Format info string
   string info = StringFormat(
                    "Balance: %.2f\n" +
                    "Equity: %.2f\n" +
                    "Profit: %.2f\n" +
                    "Trend: %s\n" +
                    "Wins: %d | Losses: %d | Profit Today: %.2f\n" +
                    "AutoTrading: %s\n" +
                    "Risk%%: %.1f | SL: %.1f | TP: %.1f\n" +
                    "MA Period: %d | Type: %d | Price: %d\n" +
                    "Slow MA Period: %d | Fast MA Period: %d",
                    balance1, equity1, profit1, trend1,
                    winCount1, lossCount1, profitToday1,
                    autoTradingStatus1,
                    RiskPercent, StopLossPips, TakeProfitPips,
                    MAPeriod, MAType, MAPrice, slowMAPeriod, fastMAPeriod);

// Create or update label
   string labelName = "InfoPanel_Text";
   if (!ObjectFind(0, labelName)) {
      ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 10);
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrWhite);
   }
   ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, panel_x + 10);
   ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, panel_y + 10);
   ObjectSetString(0, labelName, OBJPROP_TEXT, info);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateMultilineText(string namePrefix, string &lines[], color &clrs[], int x, int y) {
   int lineHeight = 16; // Adjust for font size
   int lineCount = ArraySize(lines);
   int colorCount = ArraySize(clrs);

   for (int i = 0; i < lineCount; i++) {
      string objName = namePrefix + IntegerToString(i);

      // Create the label
      ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + i * lineHeight);
      ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 12);

      // Assign color from clrs[], or use white if not enough colors provided
      color lineColor = (i < colorCount) ? clrs[i] : clrWhite;
      ObjectSetInteger(0, objName, OBJPROP_COLOR, lineColor);

      // Set the text for this line
      ObjectSetString(0, objName, OBJPROP_TEXT, lines[i]);
   }
}


// Timer Handler
void OnTimer() {
   dashboardPanel.UpdatePanel();
   ChartRedraw();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AppendLine(string &arr[], string newLine) {
   int newSize = ArraySize(arr) + 1;
   ArrayResize(arr, newSize);
   arr[newSize - 1] = newLine;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AppendColor(color &arr[], color newColor) {
   int newSize = ArraySize(arr) + 1;
   ArrayResize(arr, newSize);
   arr[newSize - 1] = newColor;
}




// Function to draw the panel and text
void DrawTextPanel16(string &arr[], color &clrs[], int x = 20, int y = 20)
{
   int lineHeight   = 20;
   int padding      = 10;
   int panelWidth   = 360;
   int panelHeight  = lineHeight * 16 + padding * 2;

   if(!mainDialog.IsVisible())
      mainDialog.Create(0, "Text Panel Dialog", 0, x, y, panelWidth + 40, panelHeight + 40);

   // Create the background panel
   background.Create(0, "TextBackground", 0, x, y, panelWidth, panelHeight);
   background.ColorBackground(clrBlack);       // Background color
   background.ColorBorder(clrGray);            // Optional border color (works in most builds)
   mainDialog.Add(background);

   // Fill up to 16 lines of labels
   int arrSize  = ArraySize(arr);
   int clrSize  = ArraySize(clrs);
   int maxLines = MathMin(16, arrSize);

   for(int i = 0; i < 16; i++)
   {
      string labelName = "Label" + IntegerToString(i);
      int labelX = x + padding;
      int labelY = y + padding + i * lineHeight;

      labels[i].Create(0, labelName, 0, labelX, labelY, panelWidth - 2 * padding, lineHeight);
      labels[i].FontSize(12);

      if(i < maxLines)
      {
         labels[i].Text(arr[i]);
         labels[i].Color(i < clrSize ? clrs[i] : clrWhite);
      }
      else
      {
         labels[i].Text(""); // Empty unused lines
         labels[i].Color(clrWhite);
      }

      mainDialog.Add(labels[i]);
   }

   mainDialog.Run();
}



//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   EventKillTimer();
   DeleteMultilineText("namePrefix", 8);
   
   dashboardPanel.Destroy(reason);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteMultilineText(string namePrefix, int count) {
   for (int i = 0; i < count; i++)
      ObjectDelete(0, namePrefix + IntegerToString(i));
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
      updateCandlesticks();
   }

   if(!autoTradingEnabled) return;

   string trend = CheckTrend();
   if( (trend == "UP") && buyEntry ) TryBuy();
   else if( (trend == "DOWN") && sellEntry ) TrySell();
   
   //UpdatePanelAccountInfo();
}

// Returns true if the current spread is acceptable for scalping
bool IsSpreadSafe(string symbol = NULL, int maxSpreadPoints = 15)
{
   if(symbol == NULL || symbol == "")
      symbol = _Symbol;

   long spread;
   if(!SymbolInfoInteger(symbol, SYMBOL_SPREAD, spread))
   {
      if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) Print("Failed to get spread for ", symbol);
      return false; // Consider unsafe if we can't retrieve it
   }

   // Optional: print the spread in pips
   double spreadPips = spread / 10.0;
   if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) Print("Current spread for ", symbol, ": ", spreadPips, " pips (", spread, " points)");

   return (spread <= maxSpreadPoints);
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
   int handleFast = iMA(_Symbol, PERIOD_M1, fastMAPeriod, 0, MAType, MAPrice);
   int handleSlow = iMA(_Symbol, PERIOD_M1, slowMAPeriod, 0, MAType, MAPrice);

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
      ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, 200 + (i * 70));
      ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(0, objName, OBJPROP_WIDTH, 65);
      //ObjectSetInteger(0, objName, OBJPROP_HEIGHT, 20);
      ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, objName, OBJPROP_TEXT, btnNames[i]);
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
                    "MA Period: %d | Type: %d | Price: %d" +
                    "Slow MA Period: %d | Fast MA Period: %d",
                    balance, equity, profit, trend, winCount, lossCount, profitToday,
                    (autoTradingEnabled ? "ON" : "OFF"),
                    RiskPercent, StopLossPips, TakeProfitPips, MAPeriod, MAType, MAPrice, slowMAPeriod,fastMAPeriod);

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
   
   dashboardPanel.PanelChartEvent(id,lparam,dparam,sparam);
   
   //if(StringFind(sparam, btnPrefix) != 0) return;
   
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
