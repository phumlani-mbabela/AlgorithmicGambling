#property copyright "Phumlani Mbabela"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "CandlestickPattern.mqh"

class ThreeCandlestickPatterns : public CandlestickPattern{

private:

   datetime time;

   double high1 ;
   double low1  ;
   double open1 ;
   double close1;

   double high2  ;
   double low2   ;
   double open2  ;
   double close2 ;

   double high3  ;
   double low3   ;
   double open3  ;
   double close3 ;
   
   double high4  ;
   double low4   ;
   double open4  ;
   double close4 ;
   
   double high5  ;
   double low5   ;
   double open5  ;
   double close5 ;

   double size1  ;
   double size2  ;
   double size3  ;

public:
   ThreeCandlestickPatterns();
   ~ThreeCandlestickPatterns();
   void ReInit();
   bool ThreeShouldBuy();
   bool ThreeShouldBuy(int index, ENUM_TIMEFRAMES SESSION_PERIOD);
   bool ThreeShouldSell();
   bool IsMasterCandle_Uptrend_Continuation(int index = 1, ENUM_TIMEFRAMES SESSION_PERIOD = PERIOD_H1);
   bool IsFallingThreeMethods_Downtrend_Uptrend();
   bool IsRisingThreeMethods_Uptrend_Downtrend();
   bool IsMorningStar_Downtrend_Uptrend();
   bool IsEveningStar_Uptrend_Downtrend();

protected:

};

   ThreeCandlestickPatterns::ThreeCandlestickPatterns(){}
   
   ThreeCandlestickPatterns::~ThreeCandlestickPatterns(){}
   
   void ThreeCandlestickPatterns::ReInit(){
      time = iTime(_Symbol,PERIOD_CURRENT,1);

      high1  = iHigh(_Symbol, PERIOD_CURRENT, 1);
      low1   = iLow(_Symbol, PERIOD_CURRENT, 1);
      open1  = iOpen(_Symbol, PERIOD_CURRENT, 1);
      close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   
      high2  = iHigh(_Symbol, PERIOD_CURRENT, 2);
      low2   = iLow(_Symbol, PERIOD_CURRENT, 2);
      open2  = iOpen(_Symbol, PERIOD_CURRENT, 2);
      close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
   
      high3  = iHigh(_Symbol, PERIOD_CURRENT, 3);
      low3   = iLow(_Symbol, PERIOD_CURRENT, 3);
      open3  = iOpen(_Symbol, PERIOD_CURRENT, 3);
      close3 = iClose(_Symbol, PERIOD_CURRENT, 3);
      
      high4  = iHigh(_Symbol, PERIOD_CURRENT, 4);
      low4   = iLow(_Symbol, PERIOD_CURRENT, 4);
      open4  = iOpen(_Symbol, PERIOD_CURRENT, 4);
      close4 = iClose(_Symbol, PERIOD_CURRENT, 4);
      
      high5  = iHigh(_Symbol, PERIOD_CURRENT, 5);
      low5   = iLow(_Symbol, PERIOD_CURRENT, 5);
      open5  = iOpen(_Symbol, PERIOD_CURRENT, 5);
      close5 = iClose(_Symbol, PERIOD_CURRENT, 5);
   
      size1  = high1-low1;
      size2  = high2-low2;
      size3  = high3-low3;
   }


bool ThreeCandlestickPatterns::ThreeShouldBuy(){
   ReInit();
   return ( IsMasterCandle_Uptrend_Continuation() || IsFallingThreeMethods_Downtrend_Uptrend() || IsMorningStar_Downtrend_Uptrend() );
}

bool ThreeCandlestickPatterns::ThreeShouldBuy(int index, ENUM_TIMEFRAMES SESSION_PERIOD){
   ReInit();
   return ( IsMasterCandle_Uptrend_Continuation(index, SESSION_PERIOD) || IsFallingThreeMethods_Downtrend_Uptrend() || IsMorningStar_Downtrend_Uptrend() );
}

bool ThreeCandlestickPatterns::ThreeShouldSell(){
   ReInit();
   return ( IsRisingThreeMethods_Uptrend_Downtrend() || IsEveningStar_Uptrend_Downtrend() );
}

// TODO: Please study this code. 
// Function to detect Master Candle pattern
bool ThreeCandlestickPatterns::IsMasterCandle_Uptrend_Continuation(int index = 1, ENUM_TIMEFRAMES SESSION_PERIOD = PERIOD_H1) {
    // Get the OHLC prices for the Master Candle and the next 5 candles
    double openMaster  = iOpen(_Symbol, SESSION_PERIOD, index + 6);  // Open of Master Candle (first stage)
    double closeMaster = iClose(_Symbol, SESSION_PERIOD, index + 6); // Close of Master Candle
    double highMaster  = iHigh(_Symbol, SESSION_PERIOD, index + 6);  // High of Master Candle
    double lowMaster   = iLow(_Symbol, SESSION_PERIOD, index + 6);   // Low of Master Candle

    // Calculate the range of the Master Candle
    double masterCandleRange = highMaster - lowMaster;

    // Check if the 5 subsequent candles are contained within the range of the Master Candle
    bool isContained = true;
    for (int i = 0; i < 5; i++) {
        double openCandle  = iOpen(_Symbol, SESSION_PERIOD, index + i);  // Open of each candle in second stage
        double closeCandle = iClose(_Symbol, SESSION_PERIOD, index + i); // Close of each candle
        double highCandle  = iHigh(_Symbol, SESSION_PERIOD, index + i);  // High of each candle
        double lowCandle   = iLow(_Symbol, SESSION_PERIOD, index + i);   // Low of each candle

        // Ensure the current candle is contained within the Master Candle range
        if (highCandle > highMaster || lowCandle < lowMaster) {
            isContained = false;
            break;  // Exit loop if one of the candles is out of range
        }
    }

    // Ensure that the Master Candle has the largest range compared to previous candles (optional, based on preference)
    bool isLargestCandle = true;
    for (int i = 1; i <= 6; i++) {
        double prevHigh = iHigh(_Symbol, SESSION_PERIOD, index + 6 - i); // High of previous candles
        double prevLow  = iLow(_Symbol, SESSION_PERIOD, index + 6 - i);  // Low of previous candles
        double prevRange = prevHigh - prevLow;

        if (prevRange > masterCandleRange) {
            isLargestCandle = false;
            break;
        }
    }

    // Confirm the Master Candle pattern (second stage should have 5 candles within the range of the Master Candle)
    if (isContained && isLargestCandle) {
        createObject(time,low1,217, 1, clrGreen, "Master Candle");
        return true;  // Master Candle pattern detected
    }

    return false;  // Not a Master Candle pattern
}

// TODO: Please write a test case of this code, it could be BS(Bad Science) code, in all likelihood.
// Function to detect Falling Three Methods candlestick pattern
bool ThreeCandlestickPatterns::IsFallingThreeMethods_Downtrend_Uptrend() {

    // First candle is a long bullish candle (close > open)
    bool firstCandleBullish = (close1 > open1);

    // Last candle is a long bearish candle (close < open)
    bool lastCandleBearish = (close5 < open5);

    // The second, third, and fourth candles should be small and within the range of the first candle
    bool smallCandles = (MathAbs(close2 - open2) < 0.5 * (high1 - low1)) &&
                        (MathAbs(close3 - open3) < 0.5 * (high1 - low1)) &&
                        (MathAbs(close4 - open4) < 0.5 * (high1 - low1));

    // Ensure that the second, third, and fourth candles are within the first candle's range
    bool candlesWithinFirstCandle = (low2 >= low1 && high2 <= high1) &&
                                    (low3 >= low1 && high3 <= high1) &&
                                    (low4 >= low1 && high4 <= high1);

    // Confirm the Falling Three Methods pattern
    if (firstCandleBullish && lastCandleBearish && smallCandles && candlesWithinFirstCandle) {
        createObject(time,low1,217, 1, clrGreen, "Falling Three Methods");
        return true;  // Falling Three Methods detected
    }
    
    return false;  // Not a Falling Three Methods
}

// TODO: Please write a test case of this code, it could be BS(Bad Science) code, in all likelihood.
// Function to detect Rising Three Methods candlestick pattern
bool ThreeCandlestickPatterns::IsRisingThreeMethods_Uptrend_Downtrend() {

    // First candle is a long bearish candle (open > close)
    bool firstCandleBearish = (open1 > close1);

    // Last candle is a long bullish candle (close > open)
    bool lastCandleBullish = (close5 > open5);

    // The second, third, and fourth candles should be small and within the range of the first candle
    bool smallCandles = (MathAbs(close2 - open2) < 0.5 * (high1 - low1)) &&
                        (MathAbs(close3 - open3) < 0.5 * (high1 - low1)) &&
                        (MathAbs(close4 - open4) < 0.5 * (high1 - low1));

    // Ensure that the second, third, and fourth candles are within the first candle's range
    bool candlesWithinFirstCandle = (low2 >= low1 && high2 <= high1) &&
                                    (low3 >= low1 && high3 <= high1) &&
                                    (low4 >= low1 && high4 <= high1);

    // Confirm the Rising Three Methods pattern
    if (firstCandleBearish && lastCandleBullish && smallCandles && candlesWithinFirstCandle) {
        createObject(time,low1,217, -1, clrRed, "Rising Three Methods");
        return true;  // Rising Three Methods detected
    }
    
    return false;  // Not a Rising Three Methods
}


// Function to detect Morning Star candlestick pattern
bool ThreeCandlestickPatterns::IsMorningStar_Downtrend_Uptrend() {

    // Check if the first candle is a long bearish candle
    bool firstCandleBearish = (open1 > close1);

    // Check if the second candle is a small body candle (indecision)
    bool secondCandleSmall = (MathAbs(close2 - open2) <= 0.3 * (high1 - low1)); // Small body is less than 30% of the first candle's range

    // Check if the third candle is a long bullish candle
    bool thirdCandleBullish = (close3 > open3);

    // The third candle should close above the midpoint of the first candle
    bool thirdCandleAboveMidpoint = (close3 > (open1 + close1) / 2);

    // Confirm Morning Star pattern
    if (firstCandleBearish && secondCandleSmall && thirdCandleBullish && thirdCandleAboveMidpoint) {
        createObject(time,low1,217, 1, clrGreen, "Morning Star");
        return true;  // Morning Star pattern detected
    }

    return false;  // Not a Morning Star pattern
}

// Function to detect Evening Star candlestick pattern
bool ThreeCandlestickPatterns::IsEveningStar_Uptrend_Downtrend() {

    // First candle should be a bullish candle (close > open)
    bool firstCandleBullish = (close1 > open1);

    // Second candle should be a small body (either bullish or bearish)
    bool secondCandleSmallBody = (MathAbs(close2 - open2) < (high2 - low2) * 0.3);

    // Third candle should be a bearish candle (close < open)
    bool thirdCandleBearish = (close3 < open3);

    // The close of the third candle should be below the midpoint of the first candle
    double firstCandleMidpoint = (open1 + close1) / 2;
    bool thirdCloseBelowMidpoint = (close3 < firstCandleMidpoint);

    // Confirm Evening Star pattern
    if (firstCandleBullish && secondCandleSmallBody && thirdCandleBearish && thirdCloseBelowMidpoint) {
        createObject(time,low1,217, -1, clrRed, "Evening Star");
        return true;  // Evening Star pattern detected
    }

    return false;  // Not an Evening Star pattern
}