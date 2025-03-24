# Forex Trading Bot for MetaTrader 5 (MT5)

## 📌 Overview
This is an **automated trading bot (Expert Advisor)** designed for **MetaTrader 5 (MT5)**, optimized for the **EUR/USD** currency pair. It follows a strategy based on market movement, stop-loss adjustments, and trailing stops to manage risk and maximize profit.

🚀 **Key Features:**
- Fully automated trading with risk management
- Optimized for **EUR/USD**
- Supports **trailing stop** and **dynamic TP/SL calculations**
- Configurable **speed classification thresholds**
- Includes **debugging mode** for testing

---

## ⚙️ Installation
1. Open **MetaTrader 5**.
2. Navigate to **File** → **Open Data Folder**.
3. Go to **MQL5** → **Experts**.
4. Copy the **EA file (`YourBotName.ex5`)** into the **Experts** folder.
5. Restart MetaTrader 5 or refresh the **Navigator** panel.

---

## 🛠️ Usage
1. Open the **EUR/USD** chart.
2. Choose the **recommended timeframe** (**H1** or as per `SESSION_PERIOD_RESOLUTION`).
3. Drag and drop the EA onto the chart from the **Navigator** panel.
4. In the **Inputs/Parameters** tab, adjust settings as needed:
   - **Lot Size**: Default `0.01`, adjust based on account balance.
   - **Stop-Loss & Take-Profit**: Default `500 points`, can be dynamically calculated.
   - **Trailing Stop**: Enabled by default, starts trailing after `50 pips`.
   - **Speed Threshold Classification**: Disabled by default but can be enabled for momentum-based trading.
5. Click **OK** to start the bot.
6. Ensure **AutoTrading** is enabled (✅ button on MT5).

---

## 🔧 Input Parameters
| Parameter | Description | Default Value |
|-----------|-------------|--------------|
| `InpFastPeriod` | Fast-moving average period | `14` |
| `InpSlowPeriod` | Slow-moving average period | `21` |
| `lotSize` | Lot size per trade | `0.01` |
| `InpStopLoss` | Stop loss in points | `500` |
| `InpTakeProfit` | Take profit in points | `500` |
| `InpStopLossAdjustment` | SL Adjustment factor | `0.0001` |
| `InpTakeProfitAdjustment` | TP Adjustment factor | `0.0001` |
| `InpMagicNumber` | Unique identifier for trades | `820607` |
| `InpNumberOfCandlesTrailingSL` | Candles to use for trailing stop | `10` |
| `UseTrailing` | Enable trailing stop | `true` |
| `WhenToTrail` | Start trailing after X pips | `50` |
| `TrailBy` | Trail stop distance in pips | `20` |
| `CalculateDynamicTP_SL` | Enable dynamic TP/SL calculations | `false` |
| `FactorVolatilityIn_TP_SL_Calculation` | Factor volatility into TP/SL | `false` |
| `MaxOpenTradesPerSession` | Max open trades per session | `1` |
| `SESSION_PERIOD_RESOLUTION` | Timeframe for session period | `H1` |
| `BEBUG_BOT` | Enable debug mode | `true` |
| `fastThreshold` | Speed classification (fast) | `0.00110` |
| `slowThreshold` | Speed classification (slow) | `0.00011` |
| `EnableSpeedThreshold` | Enable speed threshold for trades | `false` |

---

## 📊 Optimization & Backtesting
To optimize the bot:
1. Open **Strategy Tester** (`Ctrl + R`).
2. Select **YourBotName.ex5** from the Expert Advisor list.
3. Choose **EUR/USD** as the trading pair.
4. Set **H1** as the timeframe.
5. Run a **backtest** and analyze the results.

---

## ⚠️ Important Notes
- 🧪 **Backtesting Recommended:** Run backtests on **EUR/USD** before live trading.
- ⚡ **VPS Recommended:** For 24/7 operation, use a **VPS** to prevent downtime.
- 📈 **Risk Management:** Adjust lot size, stop-loss, and trailing stops based on account balance.

---

## 📩 Contact & Support
For any questions, bug reports, or feature requests, feel free to reach out!

📧 Email: [your-email@example.com](mailto:your-email@example.com)  
🌐 Website: [your-website.com](https://your-website.com)  

**Happy Trading! 🚀📈**
