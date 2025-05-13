//+------------------------------------------------------------------+
//|                                           CandlestickPattern.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Phumlani Mbabela"
#property link      "https://www.mql5.com"
#property version   "1.00"
class CandlestickPattern {
private:

public:
   CandlestickPattern();
   ~CandlestickPattern();
   void createObject(datetime time, double price, int arrowCode,int direction, color clr, string txt);
   void createObject(datetime time, double price, int arrowCode,int direction, string txt);

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CandlestickPattern::CandlestickPattern() {
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CandlestickPattern::~CandlestickPattern() {
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CandlestickPattern::createObject(datetime time, double price, int arrowCode,int direction, color clr, string txt) {
   if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) {
      string objName = "";
      StringConcatenate(objName,"Signal@",time,"at",DoubleToString(price,_Digits),"(", arrowCode,")");
      if(ObjectCreate(0,objName,OBJ_ARROW,0,time,price)) {
         ObjectSetInteger(0,objName,OBJPROP_ARROWCODE,arrowCode);
         ObjectSetInteger(0,objName,OBJPROP_COLOR,clr);
         ObjectSetInteger(0,objName, OBJPROP_FONTSIZE, 6);  // Set font size
         if(direction > 0)
            ObjectSetInteger(0,objName, OBJPROP_ANCHOR, ANCHOR_TOP);
         if(direction < 0)
            ObjectSetInteger(0,objName, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
      }
      string objNameDesc = objName+txt;
      if(ObjectCreate(0,objNameDesc,OBJ_TEXT,0,time,price)) {
         ObjectSetString(0,objNameDesc,OBJPROP_TEXT," "+txt);
         ObjectSetInteger(0,objNameDesc,OBJPROP_COLOR,clr);
         ObjectSetInteger(0,objNameDesc, OBJPROP_FONTSIZE, 6);  // Set font size
      }

      PrintFormat(__FUNCTION__,"-",__LINE__," Spotted a %s candlestick pattern.",txt);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CandlestickPattern::createObject(datetime time, double price, int arrowCode,int direction, string txt) {
   if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) {
      string objName = "";
      StringConcatenate(objName,"Signal@",time,"at",DoubleToString(price,_Digits),"(", arrowCode,")");
      if(ObjectCreate(0,objName,OBJ_ARROW,0,time,price)) {
         ObjectSetInteger(0,objName,OBJPROP_ARROWCODE,arrowCode);
         ObjectSetInteger(0,objName,OBJPROP_COLOR,clrPurple);
         ObjectSetInteger(0,objName, OBJPROP_FONTSIZE, 6);  // Set font size
         if(direction > 0)
            ObjectSetInteger(0,objName, OBJPROP_ANCHOR, ANCHOR_TOP);
         if(direction < 0)
            ObjectSetInteger(0,objName, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
      }
      string objNameDesc = objName+txt;
      if(ObjectCreate(0,objNameDesc,OBJ_TEXT,0,time,price)) {
         ObjectSetString(0,objNameDesc,OBJPROP_TEXT," "+txt);
         ObjectSetInteger(0,objNameDesc,OBJPROP_COLOR,clrPurple);
         ObjectSetInteger(0,objNameDesc, OBJPROP_FONTSIZE, 6);  // Set font size
      }
      PrintFormat(__FUNCTION__,"-",__LINE__," Spotted a %s candlestick pattern.",txt);
   }
}
//+------------------------------------------------------------------+
