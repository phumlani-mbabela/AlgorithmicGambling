#property copyright "Phumlani Mbabela"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "CandlestickPattern.mqh"

class OneCandlestickPatterns : public CandlestickPattern{

private:
   datetime time ;
   double high1  ;
   double low1   ;
   double open1  ;
   double close1 ;

public:
   OneCandlestickPatterns();
   ~OneCandlestickPatterns();
   void ReInit();
   bool OneShouldBuy();
   bool OneShouldSell();
   bool IsHammer_Downtrend_Uptrend();
   bool IsHangingMan_Uptrend_Downtrend();
   bool IsShootingStar_Uptrend_Downtrend();
   bool IsInvertedHammer_Downtrend_Uptrend();
   bool IsDragonflyDoji_Downtrend_Uptrend();
   bool IsGravestoneDoji_Uptrend_Downtrend();
   bool IsLongLeggedDoji_Continuation();
   bool IsBullishMarubozu_Uptrend_Continuation();
   bool IsBearishMarubozu_Downtrend_Continuation();
   
protected:

};

OneCandlestickPatterns::OneCandlestickPatterns(){
   time = iTime (_Symbol,PERIOD_CURRENT,1);
   high1  = iHigh (_Symbol, PERIOD_CURRENT, 1);
   low1   = iLow  (_Symbol, PERIOD_CURRENT, 1);
   open1  = iOpen (_Symbol, PERIOD_CURRENT, 1);
   close1 = iClose(_Symbol, PERIOD_CURRENT, 1); 
}

OneCandlestickPatterns::~OneCandlestickPatterns(){}

void OneCandlestickPatterns::ReInit(){
   time = iTime (_Symbol,PERIOD_CURRENT,1);
   high1  = iHigh (_Symbol, PERIOD_CURRENT, 1);
   low1   = iLow  (_Symbol, PERIOD_CURRENT, 1);
   open1  = iOpen (_Symbol, PERIOD_CURRENT, 1);
   close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
}

bool OneCandlestickPatterns::OneShouldBuy(){
   ReInit();
   return ( IsHammer_Downtrend_Uptrend() || IsInvertedHammer_Downtrend_Uptrend() || IsDragonflyDoji_Downtrend_Uptrend() || IsBullishMarubozu_Uptrend_Continuation() );
}

bool OneCandlestickPatterns::OneShouldSell(){
   ReInit();
   return ( IsHangingMan_Uptrend_Downtrend() || IsShootingStar_Uptrend_Downtrend() || IsGravestoneDoji_Uptrend_Downtrend() || IsBearishMarubozu_Downtrend_Continuation() );
}

// Function to detect Hammer candlestick pattern
bool OneCandlestickPatterns::IsHammer_Downtrend_Uptrend() {

    // Define the total candlestick range
    double candleRange = high1 - low1;
    if (candleRange == 0) return false; // Avoid division by zero

    // Define the body size
    double bodySize = MathAbs(open1 - close1);

    // Ensure the body is small compared to the total range
    bool smallBody = (bodySize <= 0.3 * candleRange); // Body ≤ 30% of total range

    // Ensure the lower shadow is large
    bool largeLowerShadow = (MathMin(open1, close1) - low1) >= (2 * bodySize);

    // Ensure the upper shadow is minimal
    bool smallUpperShadow = (high1 - MathMax(open1, close1)) <= (0.1 * candleRange);

    // Confirm Hammer pattern
    if (smallBody && largeLowerShadow && smallUpperShadow) {
        if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) createObject(time,low1,233, 1, clrGreen, "Hammer");
        return true;  // Hammer detected
    }
    
    return false;  // Not a Hammer
}

// Function to detect Hanging Man candlestick pattern
bool OneCandlestickPatterns::IsHangingMan_Uptrend_Downtrend() {

    // Define the total candlestick range
    double candleRange = high1 - low1;
    if (candleRange == 0) return false; // Avoid division by zero

    // Define the body size
    double bodySize = MathAbs(open1 - close1);

    // Ensure the body is small compared to the total range
    bool smallBody = (bodySize <= 0.3 * candleRange); // Body ≤ 30% of total range

    // Ensure the lower shadow is large
    bool largeLowerShadow = (MathMin(open1, close1) - low1) >= (2 * bodySize);

    // Ensure the upper shadow is minimal
    bool smallUpperShadow = (high1 - MathMax(open1, close1)) <= (0.1 * candleRange);

    // Confirm Hanging Man pattern
    if (smallBody && largeLowerShadow && smallUpperShadow) {
        if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) createObject(time,low1,217, 1, clrRed, "Hanging Man");
        return true;  // Hanging Man detected
    }
    
    return false;  // Not a Hanging Man
}

// Function to detect Shooting Star candlestick pattern
bool OneCandlestickPatterns::IsShootingStar_Uptrend_Downtrend() {

    // Define the total candlestick range
    double candleRange = high1 - low1;
    if (candleRange == 0) return false; // Avoid division by zero

    // Define the body size
    double bodySize = MathAbs(open1 - close1);

    // Ensure the body is small compared to the total range
    bool smallBody = (bodySize <= 0.3 * candleRange); // Body ≤ 30% of total range

    // Ensure the upper shadow is large
    bool largeUpperShadow = (high1 - MathMax(open1, close1)) >= (2 * bodySize);

    // Ensure the lower shadow is minimal
    bool smallLowerShadow = (MathMin(open1, close1) - low1) <= (0.1 * candleRange);

    // Confirm Shooting Star pattern
    if (smallBody && largeUpperShadow && smallLowerShadow) {
        if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) createObject(time, low1, 200,1,clrRed,"Shooting Star");
        return true;  // Shooting Star detected
    }
    
    return false;  // Not a Shooting Star
}

// Function to detect Inverted Hammer candlestick pattern
bool OneCandlestickPatterns::IsInvertedHammer_Downtrend_Uptrend() {

    // Define the total candlestick range
    double candleRange = high1 - low1;
    if (candleRange == 0) return false; // Avoid division by zero

    // Define the body size
    double bodySize = MathAbs(open1 - close1);

    // Ensure the body is small compared to the total range
    bool smallBody = (bodySize <= 0.3 * candleRange); // Body ≤ 30% of total range

    // Ensure the upper shadow is large
    bool largeUpperShadow = (high1 - MathMax(open1, close1)) >= (2 * bodySize);

    // Ensure the lower shadow is minimal
    bool smallLowerShadow = (MathMin(open1, close1) - low1) <= (0.1 * candleRange);

    // Confirm Inverted Hammer pattern
    if (smallBody && largeUpperShadow && smallLowerShadow) {
        if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) createObject(time,high1,234, -1, clrGreen, "Inverted Hammer");
        return true;  // Inverted Hammer detected
    }
    
    return false;  // Not an Inverted Hammer
}

// Function to detect Dragonfly Doji
bool OneCandlestickPatterns::IsDragonflyDoji_Downtrend_Uptrend() {

    // Define the candlestick range
    double bodySize   = MathAbs(open1 - close1);
    double candleRange = high1 - low1;

    // Ensure the body is small compared to the candle range
    bool smallBody = (bodySize <= 0.05 * candleRange); // Body ≤ 5% of total range

    // Ensure the lower shadow is large
    bool largeLowerShadow = (MathMin(open1, close1) - low1) >= (2 * bodySize);

    // Ensure the upper shadow is minimal
    bool smallUpperShadow = (high1 - MathMax(open1, close1)) <= (0.02 * candleRange);

    // Confirm Dragonfly Doji conditions
    if (smallBody && largeLowerShadow && smallUpperShadow) {
        if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) createObject(time,high1,234, 1, clrGreen, "Dragonfly Doji");
        return true;  // Dragonfly Doji detected
    }
    
    return false;  // Not a Dragonfly Doji
}

bool OneCandlestickPatterns::IsGravestoneDoji_Uptrend_Downtrend() {

    // Define the candlestick range
    double bodySize   = MathAbs(open1 - close1);
    double candleRange = high1 - low1;

    // Ensure the body is small compared to the candle range
    bool smallBody = (bodySize <= 0.05 * candleRange); // Body ≤ 5% of total range

    // Ensure the upper shadow is large
    bool largeUpperShadow = (high1 - MathMax(open1, close1)) >= (2 * bodySize);

    // Ensure the lower shadow is minimal
    bool smallLowerShadow = (MathMin(open1, close1) - low1) <= (0.02 * candleRange);

    // Confirm Gravestone Doji conditions
    if (smallBody && largeUpperShadow && smallLowerShadow) {
        if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) createObject(time,high1,234, -1, clrRed, "Gravestone Doji");
        return true;  // Gravestone Doji detected
    }
    
    return false;  // Not a Gravestone Doji
}

// Function to detect Long Legged Doji candlestick pattern
bool OneCandlestickPatterns::IsLongLeggedDoji_Continuation() {

    // Define the total candlestick range
    double candleRange = high1 - low1;
    if (candleRange == 0) return false; // Avoid division by zero

    // Define the body size
    double bodySize = MathAbs(open1 - close1);

    // Ensure the body is small compared to the total range (within a threshold)
    bool smallBody = (bodySize <= 0.1 * candleRange); // Body ≤ 10% of total range

    // Ensure the upper and lower shadows are large compared to the body
    bool largeUpperShadow = (high1 - MathMax(open1, close1)) >= (0.4 * candleRange); // Upper shadow is at least 40% of the total range
    bool largeLowerShadow = (MathMin(open1, close1) - low1) >= (0.4 * candleRange);  // Lower shadow is at least 40% of the total range

    // Confirm Long Legged Doji pattern
    if (smallBody && largeUpperShadow && largeLowerShadow) {
        if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) createObject(time,high1,234, 1, clrGreen, "Long Legged Doji");
        return true;  // Long Legged Doji detected
    }
    
    return false;  // Not a Long Legged Doji
}

// Function to detect Bullish Marubozu candlestick pattern
bool OneCandlestickPatterns::IsBullishMarubozu_Uptrend_Continuation() {

    // Define the total candlestick range
    double candleRange = high1 - low1;
    if (candleRange == 0) return false; // Avoid division by zero

    // Define the body size
    double bodySize = close1 - open1;

    // Ensure it's a bullish candle (close > open)
    bool isBullish = (close1 > open1);

    // Ensure there are almost no shadows
    bool noUpperShadow = (high1 - close1) <= (0.02 * candleRange); // ≤ 2% of total range
    bool noLowerShadow = (open1 - low1) <= (0.02 * candleRange);   // ≤ 2% of total range

    // Confirm Bullish Marubozu pattern
    if (isBullish && noUpperShadow && noLowerShadow) {
        if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) createObject(time,high1,234, 1, clrGreen, "Bullish Marubozu");
        return true;  // Bullish Marubozu detected
    }
    
    return false;  // Not a Bullish Marubozu
}

// Function to detect Bearish Marubozu candlestick pattern
bool OneCandlestickPatterns::IsBearishMarubozu_Downtrend_Continuation() {

    // Define the total candlestick range
    double candleRange = high1 - low1;
    if (candleRange == 0) return false; // Avoid division by zero

    // Define the body size
    double bodySize = open1 - close1;

    // Ensure it's a bearish candle (close < open)
    bool isBearish = (close1 < open1);

    // Ensure there are almost no shadows
    bool noUpperShadow = (high1 - open1) <= (0.02 * candleRange); // ≤ 2% of total range
    bool noLowerShadow = (close1 - low1) <= (0.02 * candleRange); // ≤ 2% of total range

    // Confirm Bearish Marubozu pattern
    if (isBearish && noUpperShadow && noLowerShadow) {
        if(!MQL5InfoInteger(MQL5_OPTIMIZATION)) createObject(time,high1,234, -1, clrRed, "Bearish Marubozu");
        return true;  // Bearish Marubozu detected
    }
    
    return false;  // Not a Bearish Marubozu
}