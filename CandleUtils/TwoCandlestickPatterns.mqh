#property copyright "Phumlani Mbabela"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "CandlestickPattern.mqh"

class TwoCandlestickPatterns : public CandlestickPattern{

private:
   datetime time ;
   
   double high1  ;
   double low1   ;
   double open1  ;
   double close1 ;
   
   double high2  ;
   double low2   ;
   double open2  ;
   double close2 ;

public:
   TwoCandlestickPatterns();
   ~TwoCandlestickPatterns();
   void ReInit();
   bool TwoShouldBuy();
   bool TwoShouldSell(); 
   bool IsBullishEngulfing_Downtrend_Uptrend();
   bool IsBearishEngulfing_Uptrend_Downtrend();
   bool IsTweezersTop_Uptrend_Downtrend();
   bool IsTweezersBottom_Downtrend_Uptrend() ;
   bool IsDarkCloudCover_Uptrend_Downtrend();
   bool IsPiercingPattern_Downtrend_Uptrend();
   bool IsBullishHarami_Downtrend_Uptrend();
   bool IsBearishHarami_Uptrend_Downtrend();

protected:

};

TwoCandlestickPatterns::TwoCandlestickPatterns(){}
TwoCandlestickPatterns::~TwoCandlestickPatterns(){}
void TwoCandlestickPatterns::ReInit(){
   time = iTime(_Symbol,PERIOD_CURRENT,1);
   
   high1  = iHigh(_Symbol, PERIOD_CURRENT, 1);
   low1   = iLow(_Symbol, PERIOD_CURRENT, 1);
   open1  = iOpen(_Symbol, PERIOD_CURRENT, 1);
   close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   
   high2  = iHigh(_Symbol, PERIOD_CURRENT, 2);
   low2   = iLow(_Symbol, PERIOD_CURRENT, 2);
   open2  = iOpen(_Symbol, PERIOD_CURRENT, 2);
   close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
}
   
bool TwoCandlestickPatterns::TwoShouldBuy(){
   ReInit();
   return ( IsBullishEngulfing_Downtrend_Uptrend() || IsTweezersBottom_Downtrend_Uptrend() || IsPiercingPattern_Downtrend_Uptrend() || IsBullishHarami_Downtrend_Uptrend() );
}

bool TwoCandlestickPatterns::TwoShouldSell(){
   ReInit();
   return ( IsBearishEngulfing_Uptrend_Downtrend() || IsTweezersTop_Uptrend_Downtrend() || IsDarkCloudCover_Uptrend_Downtrend() || IsBearishHarami_Uptrend_Downtrend() );
}   
   
   
// Function to detect Bullish Engulfing candlestick pattern
bool TwoCandlestickPatterns::IsBullishEngulfing_Downtrend_Uptrend() {

    // First candle should be a small bearish candle (close < open)
    bool firstCandleBearish = (close1 < open1);

    // Second candle should be a large bullish candle (close > open)
    bool secondCandleBullish = (close2 > open2);

    // The second candle should engulf the first candle's body
    bool secondCandleEngulfs = (open2 < close1) && (close2 > open1);

    // Confirm Bullish Engulfing pattern
    if (firstCandleBearish && secondCandleBullish && secondCandleEngulfs) {
        createObject(time,low1,217, 1, clrGreen, "Bullish Engulfing");
        return true;  // Bullish Engulfing pattern detected
    }

    return false;  // Not a Bullish Engulfing pattern
}

// Function to detect Bearish Engulfing candlestick pattern
bool TwoCandlestickPatterns::IsBearishEngulfing_Uptrend_Downtrend() {

    // First candle should be a small bullish candle (close > open)
    bool firstCandleBullish = (close1 > open1);

    // Second candle should be a large bearish candle (close < open)
    bool secondCandleBearish = (close2 < open2);

    // The second candle should engulf the first candle's body
    bool secondCandleEngulfs = (open2 > close1) && (close2 < open1);

    // Confirm Bearish Engulfing pattern
    if (firstCandleBullish && secondCandleBearish && secondCandleEngulfs) {
        createObject(time,high1,218, -1, clrRed, "Bearish Engulfing");
        return true;  // Bearish Engulfing pattern detected
    }

    return false;  // Not a Bearish Engulfing pattern
}

bool TwoCandlestickPatterns::IsTweezersTop_Uptrend_Downtrend() {

    // First candle should be a bullish candle (close > open)
    bool firstCandleBullish = (close1 > open1);

    // Second candle should be a bearish candle (close < open)
    bool secondCandleBearish = (close2 < open2);

    // The high of the second candle should be the same as the high of the first candle
    bool sameHigh = (high1 == high2);

    // Confirm Tweezers Top pattern
    if (firstCandleBullish && secondCandleBearish && sameHigh) {
        createObject(time,low1,217, -1, clrRed, "Tweezers Top");
        return true;  // Tweezers Top pattern detected
    }

    return false;  // Not a Tweezers Top pattern
}

// Function to detect Tweezers Bottom candlestick pattern
bool TwoCandlestickPatterns::IsTweezersBottom_Downtrend_Uptrend() {

    // First candle should be a bearish candle (close < open)
    bool firstCandleBearish = (close1 < open1);

    // Second candle should be a bullish candle (close > open)
    bool secondCandleBullish = (close2 > open2);

    // The low of the second candle should be the same as the low of the first candle
    bool sameLow = (low1 == low2);

    // Confirm Tweezers Bottom pattern
    if (firstCandleBearish && secondCandleBullish && sameLow) {
    createObject(time,low1,217, 1, clrGreen, "Tweezers Bottom");
        return true;  // Tweezers Bottom pattern detected
    }

    return false;  // Not a Tweezers Bottom pattern
}

// Function to detect Dark Cloud Cover candlestick pattern
bool TwoCandlestickPatterns::IsDarkCloudCover_Uptrend_Downtrend() {

    // First candle should be a bullish candle (close > open)
    bool firstCandleBullish = (close1 > open1);

    // Second candle should be a bearish candle (close < open)
    bool secondCandleBearish = (close2 < open2);

    // The open of the second candle should be above the high of the first candle
    bool secondOpenAboveFirstHigh = (open2 > high1);

    // The close of the second candle should be below the midpoint of the first candle
    double firstCandleMidpoint = (open1 + close1) / 2;
    bool secondCloseBelowMidpoint = (close2 < firstCandleMidpoint);

    // Confirm Dark Cloud Cover pattern
    if (firstCandleBullish && secondCandleBearish && secondOpenAboveFirstHigh && secondCloseBelowMidpoint) {
        createObject(time,low1,217, -1, clrRed, "Dark Cloud Cover");
        return true;  // Dark Cloud Cover pattern detected
    }

    return false;  // Not a Dark Cloud Cover pattern
}

// Function to detect Piercing Pattern candlestick pattern
bool TwoCandlestickPatterns::IsPiercingPattern_Downtrend_Uptrend() {

    // First candle should be a bearish candle (close < open)
    bool firstCandleBearish = (close1 < open1);

    // Second candle should be a bullish candle (close > open)
    bool secondCandleBullish = (close2 > open2);

    // The open of the second candle should be below the low of the first candle
    bool secondOpenBelowFirstLow = (open2 < low1);

    // The close of the second candle should be above the midpoint of the first candle
    double firstCandleMidpoint = (open1 + close1) / 2;
    bool secondCloseAboveMidpoint = (close2 > firstCandleMidpoint);

    // Confirm Piercing Pattern
    if (firstCandleBearish && secondCandleBullish && secondOpenBelowFirstLow && secondCloseAboveMidpoint) {
        createObject(time,low1,217, 1, clrGreen, "Piercing Pattern");
        return true;  // Piercing Pattern detected
    }

    return false;  // Not a Piercing Pattern
}

// Function to detect Bullish Harami candlestick pattern
bool TwoCandlestickPatterns::IsBullishHarami_Downtrend_Uptrend() {

    // First candle should be a bearish candle (close < open)
    bool firstCandleBearish = (close1 < open1);

    // Second candle should be a bullish candle (close > open)
    bool secondCandleBullish = (close2 > open2);

    // The second candle should be completely inside the first candle's body
    bool secondInsideFirst = (low2 > low1 && high2 < high1);

    // Confirm Bullish Harami pattern
    if (firstCandleBearish && secondCandleBullish && secondInsideFirst) {
        createObject(time,low1,217, 1, clrGreen, "Bullish Harami");
        return true;  // Bullish Harami pattern detected
    }

    return false;  // Not a Bullish Harami pattern
}

// Function to detect Bearish Harami candlestick pattern
bool TwoCandlestickPatterns::IsBearishHarami_Uptrend_Downtrend() {

    // First candle should be a bullish candle (close > open)
    bool firstCandleBullish = (close1 > open1);

    // Second candle should be a bearish candle (close < open)
    bool secondCandleBearish = (close2 < open2);

    // The second candle should be completely inside the first candle's body
    bool secondInsideFirst = (low2 > low1 && high2 < high1);

    // Confirm Bearish Harami pattern
    if (firstCandleBullish && secondCandleBearish && secondInsideFirst) {
        createObject(time,low1,217, -1, clrRed, "Bearish Harami");
        return true;  // Bearish Harami pattern detected
    }

    return false;  // Not a Bearish Harami pattern
}
 