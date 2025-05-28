//+------------------------------------------------------------------+
//|                                                  EADashboard.mqh |
//|                                Copyright 2025, Phumlani Mbabela. |
//|                                  https://www.phumlanimbabela.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Phumlani Mbabela."
#property link      "https://www.phumlanimbabela.com"
#property version   "1.00"

#include <Controls\Dialog.mqh>
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>

#include  "..\\MoneyTree-HS.mq5"

#include  <Controls\Defines.mqh>

input group "=== Panel Inputs ==="
static input int InpPanelWidth = 260;              // Width in pixel.
static input int InpPanelHeight = 760;             // Height in pixel.
static input int InpPanelFontSize = 10;            // Font size.
static input int InpPanelTxtColor = clrWhiteSmoke; // Text color.


#undef CONTROLS_FONT_NAME
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#define CONTROLS_FONT_NAME                "Consolas"
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   C'0x20,0x20,0x20'


class EADashboard : public CAppDialog {

private:
   CLabel m_lMagic;
   CLabel m_lBalance;
   CLabel m_lEquity;
   CLabel m_lProfit;
   CLabel m_lTrend;
   CLabel m_lWins;
   CLabel m_lLosses;
   CLabel m_lProfitToday;
   CLabel m_lAutoTrading;
   CLabel m_lRisk;
   CLabel m_lLot;
   CLabel m_lSL;
   CLabel m_lTP;
   CLabel m_lMAPeriod;
   CLabel m_lType;
   CLabel m_lPrice;
   CLabel m_lSlowMAPeriod;
   CLabel m_lFastMAPeriod;
   CLabel m_lTimeString;

   bool CreatePanel();
   bool CheckInputs();
public:
   EADashboard();
   ~EADashboard();
   bool OnInit();
   void PanelChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
      bool UpdatePanel();

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EADashboard::EADashboard() {
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EADashboard::~EADashboard() {
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EADashboard::CreatePanel() {

   if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) return true;

   this.Create(NULL,"Money Tree - HS",0,0,0,InpPanelWidth, InpPanelHeight);

   datetime currentTime = TimeCurrent(); // Gets the current server time
   string timeString = TimeToString(currentTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS);
   string summary = getEASummary();
   summary += "Previous Profit:" + DoubleToString(previousProfit) + "\n";
//notification.SendEmailNotification("EA Summary@"+timeString, summary);
   previousProfit = getProfit() ;

   string currency = AccountInfoString(ACCOUNT_CURRENCY);
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

   m_lMagic.Create(NULL,"lMagicNumber",0,20,10,1,1);
   m_lMagic.Text(StringFormat("Magic Number: %d", EAMagicNumber));
   m_lMagic.Color(clrNavy);
   m_lMagic.FontSize(InpPanelFontSize);
   this.Add(m_lMagic);

   m_lBalance.Create(NULL,"lBalance",0,20,30,1,1);
   m_lBalance.Text(StringFormat("Balance:       %0.2f %s", balance, currency));
   m_lBalance.Color(clrNavy);
   m_lBalance.FontSize(InpPanelFontSize);
   this.Add(m_lBalance);

   m_lEquity.Create(NULL,"lEquity",0,20,50,1,1);
   m_lEquity.Text(StringFormat("Equity:       %0.2f %s", equity, currency));
   m_lEquity.Color(clrNavy);
   m_lEquity.FontSize(InpPanelFontSize);
   this.Add(m_lEquity);

   m_lProfit.Create(NULL,"lProfit",0,20,70,1,1);
   m_lProfit.Text(StringFormat("Profit:       %0.2f %s", profitToday, currency));
   if( profitToday<=0 ) {
      m_lProfit.Color(clrRed);
   } else {
      m_lProfit.Color(clrGreen);
   }
   m_lProfit.FontSize(InpPanelFontSize);
   this.Add(m_lProfit);

   m_lTrend.Create(NULL,"lTrend",0,20,90,1,1);
   if( StringCompare(trend,"DOWN") ) {
      m_lTrend.Color(clrRed);
   } else if( StringCompare(trend,"UP") ) {
      m_lTrend.Color(clrGreen);
   } else {
      m_lTrend.Color(clrNavy);
   }
   m_lTrend.Text(StringFormat("Trend:       %s", trend));
   m_lTrend.FontSize(InpPanelFontSize);
   this.Add(m_lTrend);

   m_lWins.Create(NULL,"lWins",0,20,110,1,1);
   m_lWins.Text(StringFormat("Wins:     %d", winCount));
   if( winCount<=0 ) {
      m_lWins.Color(clrRed);
   } else {
      m_lWins.Color(clrGreen);
   }
   m_lWins.FontSize(InpPanelFontSize);
   this.Add(m_lWins);

   m_lLosses.Create(NULL,"lLosses",0,20,130,1,1);
   m_lLosses.Text(StringFormat("Losses:    %d", lossCount));
   if( lossCount<=0 ) {
      m_lLosses.Color(clrRed);
   } else {
      m_lLosses.Color(clrGreen);
   }
   m_lLosses.FontSize(InpPanelFontSize);
   this.Add(m_lLosses);

   m_lAutoTrading.Create(NULL,"lAutoTrading",0,20,170,1,1);
   m_lAutoTrading.Text(StringFormat("Auto Trading:       %s", autoTradingEnabled?"ON":"OFF"));
   m_lAutoTrading.Color(clrNavy);
   m_lAutoTrading.FontSize(InpPanelFontSize);
   this.Add(m_lAutoTrading);

   m_lRisk.Create(NULL,"lRisk",0,20,190,1,1);
   m_lRisk.Text(StringFormat("Risk:       %0.2f", RiskPercent));
   m_lRisk.Color(clrNavy);
   m_lRisk.FontSize(InpPanelFontSize);
   this.Add(m_lRisk);
   
   m_lLot.Create(NULL,"lLot",0,20,210,1,1);
   m_lLot.Text(StringFormat("Lot:       %0.2f", RiskPercent));
   m_lLot.Color(clrNavy);
   m_lLot.FontSize(InpPanelFontSize);
   this.Add(m_lLot);

   m_lSL.Create(NULL,"lSL",0,20,230,1,1);
   m_lSL.Text(StringFormat("SL:       %d", StopLossPips));
   m_lSL.Color(clrNavy);
   m_lSL.FontSize(InpPanelFontSize);
   this.Add(m_lSL);

   m_lTP.Create(NULL,"lTP",0,20,250,1,1);
   m_lTP.Text(StringFormat("TP:       %d", TakeProfitPips));
   m_lTP.Color(clrNavy);
   m_lTP.FontSize(InpPanelFontSize);
   this.Add(m_lTP);

   m_lMAPeriod.Create(NULL,"lMAPeriod",0,20,270,1,1);
   m_lMAPeriod.Text(StringFormat("MA Period:       %d", MAPeriod));
   m_lMAPeriod.Color(clrNavy);
   m_lMAPeriod.FontSize(InpPanelFontSize);
   this.Add(m_lMAPeriod);

   m_lType.Create(NULL,"lType",0,20,290,1,1);
   m_lType.Text(StringFormat("Type:       %d", MAType));
   m_lType.Color(clrNavy);
   m_lType.FontSize(InpPanelFontSize);
   this.Add(m_lType);

   m_lPrice.Create(NULL,"lPrice",0,20,310,1,1);
   m_lPrice.Text(StringFormat("Price:       %0.2f", MAPrice));
   m_lPrice.Color(clrNavy);
   m_lPrice.FontSize(InpPanelFontSize);
   this.Add(m_lPrice);

   m_lSlowMAPeriod.Create(NULL,"lSlowMAPeriod",0,20,330,1,1);
   m_lSlowMAPeriod.Text(StringFormat("Slow MA Period:       %d", slowMAPeriod));
   m_lSlowMAPeriod.Color(clrNavy);
   m_lSlowMAPeriod.FontSize(InpPanelFontSize);
   this.Add(m_lSlowMAPeriod);

   m_lFastMAPeriod.Create(NULL,"lFastMAPeriod",0,20,350,1,1);
   m_lFastMAPeriod.Text(StringFormat("Fast MA Period:       %d", fastMAPeriod));
   m_lFastMAPeriod.Color(clrNavy);
   m_lFastMAPeriod.FontSize(InpPanelFontSize);
   this.Add(m_lFastMAPeriod);

   m_lTimeString.Create(NULL,"lTimeString",0,20,370,1,1);
   m_lTimeString.Text(StringFormat("Time:       %s", timeString));
   m_lTimeString.Color(clrNavy);
   m_lTimeString.FontSize(InpPanelFontSize);
   this.Add(m_lTimeString);




   if( !Run() ) {
      if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) Print("Failed to run panel.");
      return false;
   }

   ChartRedraw();

   return true;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EADashboard::UpdatePanel() {
   this.Create(NULL,"Money Tree - HS",0,0,0,InpPanelWidth, InpPanelHeight);

   datetime currentTime = TimeCurrent(); // Gets the current server time
   string timeString = TimeToString(currentTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS);
   string summary = getEASummary();
   summary += "Previous Profit:" + DoubleToString(previousProfit) + "\n";
//notification.SendEmailNotification("EA Summary@"+timeString, summary);
   previousProfit = getProfit() ;

   string currency = AccountInfoString(ACCOUNT_CURRENCY);
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

   m_lMagic.Text(StringFormat("Magic Number: %d", EAMagicNumber));
   m_lBalance.Text(StringFormat("Balance:       %0.2f %s", balance, currency));
   m_lEquity.Text(StringFormat("Equity:       %0.2f %s", equity, currency));
   m_lProfit.Text(StringFormat("Profit:       %0.2f %s", profitToday, currency));
   if( profitToday<=0 ) {
      m_lProfit.Color(clrRed);
   } else {
      m_lProfit.Color(clrGreen);
   }

   if( StringCompare(trend,"DOWN") ) {
      m_lTrend.Color(clrRed);
   } else if( StringCompare(trend,"UP") ) {
      m_lTrend.Color(clrGreen);
   } else {
      m_lTrend.Color(clrNavy);
   }
   m_lTrend.Text(StringFormat("Trend:       %s", trend));


   m_lWins.Text(StringFormat("Wins:     %d", winCount));
   if( winCount<=0 ) {
      m_lWins.Color(clrRed);
   } else {
      m_lWins.Color(clrGreen);
   }
   this.Add(m_lWins);

   m_lLosses.Text(StringFormat("Losses:    %d", lossCount));
   if( lossCount<=0 ) {
      m_lLosses.Color(clrRed);
   } else {
      m_lLosses.Color(clrGreen);
   }

   m_lAutoTrading.Text(StringFormat("Auto Trading:       %s", autoTradingEnabled?"ON":"OFF"));
   
   
   double riskAmount  = balance * RiskPercent / 100.0;
   double tickValue   = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize    = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double pipValue    = tickValue / tickSize * _Point;
   double lot         = riskAmount / (pipValue * StopLossPips);
   lot = NormalizeDouble(lot, 2);
   m_lRisk.Text(StringFormat("Risk:       %0.2f", riskAmount));
   m_lLot.Text(StringFormat("Lot:       %0.2f", lot));
   
   m_lSL.Text(StringFormat("SL:       %d", StopLossPips));
   m_lTP.Text(StringFormat("TP:       %d", TakeProfitPips));
   m_lMAPeriod.Text(StringFormat("MA Period:       %d", MAPeriod));
   m_lType.Text(StringFormat("Type:       %d", MAType));
   m_lPrice.Text(StringFormat("Price:       %0.2f", MAPrice));
   m_lSlowMAPeriod.Text(StringFormat("Slow MA Period:       %d", slowMAPeriod));
   m_lFastMAPeriod.Text(StringFormat("Fast MA Period:       %d", fastMAPeriod));
   m_lTimeString.Text(StringFormat("Time:       %s", timeString));

   if( !Run() ) {
      if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) Print("Failed to run panel.");
      return false;
   }

   ChartRedraw();

   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EADashboard::OnInit() {
   if(!this.CreatePanel()) return false;
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EADashboard::PanelChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   ChartEvent(id, lparam, dparam, sparam);
}

//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EADashboard::CheckInputs () {
   if( InpPanelWidth <=0) {
      if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) Print("Panel width <= 0");
      return false;
   }
   if( InpPanelHeight <=0) {
      if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) Print("Panel height <= 0");
      return false;
   }
   if( InpPanelFontSize <=0) {
      if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) Print("Font size <= 0");
      return false;
   }
   return true;
}
//+------------------------------------------------------------------+
