# NostalgiaForInfinityX5 analysis (WIP)

# [Configuration](#config)

# Entry protections

1. [global_protections_long_pump](#gplp)
2. [global_protections_short_pump](#gpsp)

# Entry signals

## Long signals

### Normal mode
1. [Condition 1 - Normal mode (Long)](#long_1)
2. [Condition 2 - Normal mode (Long)](#long_2)
3. [Condition 3 - Normal mode (Long)](#long_3)
4. [Condition 4 - Normal mode (Long)](#long_4)
5. [Condition 5 - Normal mode (Long)](#long_5)
6. [Condition 6 - Normal mode (Long)](#long_6)

### Quick mode
8. [Condition 42 - Quick mode (Long)](#long_42)
9. [Condition 43 - Quick mode (Long)](#long_43)

### Grind mode
11. [Condition 120 - Grind mode (Long)](#long_120)

### Top coins mode
13. [Condition 143 - Top Coins mode (Long)](#long_143)

## Short signals

### Normal mode
13. [Condition 501 - Normal mode (Short)](#short_501)
14. [Condition 502 - Normal mode (Short)](#short_502)
15. [Condition 503 - Normal mode (Short)](#short_503)
16. [Condition 504 - Normal mode (Short)](#short_504)

### Quick and rapid mode
18. [Condition 542 - Quick mode (Short)](#short_542)
19. [Condition 543 - Rapid mode (Short)](#short_543)

### Top coins mode
21. [Condition 641 - Top Coins mode (Short)](#short_641)
22. [Condition 642 - Top Coins mode (Short)](#short_642)

# Position adjustment modes
1. [Grind](#grinding)
2. [Rebuy](#rebuy)
3. [Derisk](#derisk)

# Exit signals

1. [Tags](#exit_tags)
2. [Long exit normal function](#long_exit_normal)
   1. [long_exit_signals function](#long_exit_signals)
   2. [long_exit_main function](#long_exit_main)
   3. [long_exit_williams_r function](#long_exit_williams)
   4. [long_exit_dec function](#long_exit_dec)
   5. [long_exit_stoploss](#long_exit_stoploss)

---

# Config.json

Keys that can be added to config.json<a name="config"></a>

```
"exit_profit_only"                  # Default: False
"num_cores_indicators_calc"         # Default: 0. Number of cores to use for pandas_ta indicators calculations.
"custom_fee_open_rate"              # Default: trade.fee_open
"custom_fee_close_rate"             # Default: trade.fee_close
"futures_mode_leverage"             # Default: 3.0
"futures_mode_leverage_rebuy_mode"  # Default: 3.0
"futures_mode_leverage_grind_mode"  # Default: 3.0
"stop_threshold_doom_spot"          # Default: 0.25
"stop_threshold_doom_futures"       # Default: 0.60
"derisk_enable"                     # Default: True
"regular_mode_derisk_spot"          # Default: -0.24
"regular_mode_derisk_1_spot"        # Default: -0.24
"regular_mode_derisk_futures"       # Default: -0.60
"regular_mode_derisk_1_futures"     # Default: -0.60
"grind_mode_max_slots"              # Default: 1
"grind_mode_coins"                  # Default: ["MATIC", "ADA", "ARB", "DOT", "XLM", "ALGO", "ETH", "RNDR", "XMR", "AVAX", "NEAR", "DOGE", "BCH", "ETC", "FTM", "KAS", "HBAR", "SUI", "TON", "XRP", "UNI", "LTC", "FIL", "ATOM", "GRT", "LINK", "VET", "THETA", "EOS", "LRC", "QTUM", "CELR" ]
"max_slippage"                     # Default: 0.012

  


```

# Entry protections

## global_protections_long_pump <a name="gplp"></a>

### Summary of Implemented Protections
The "pump" signal is designed to safeguard against specific scenarios where entering a long position would be highly risky. This is achieved through a combination of indicators that analyze overbought conditions, weak corrections, and unsustainable trends across various timeframes.

The primary indicators used include:  
- **RSI (Relative Strength Index):** Evaluates overbought or oversold conditions.  
- **Aroon:** Determines trend strength.  
- **Stochastic RSI:** An adapted RSI for greater sensitivity to changes.  
- **ROC (Rate of Change):** Measures the speed of price changes.  
- **WILLIAMS %R:** Another overbought/oversold indicator.

### Scenario Examples and How the Signal Provides Protection

#### 1. **Avoiding Entries in Overbought Markets**
**Conditions:**  
- RSI_3 > 60 on the 1-day timeframe.  
- AROONU_14_1d < 75 (weak or exhausted uptrend).  
- ROC_9_1d < 40 (insufficient momentum).  

**Example:**  
An asset shows strong upward movement over the past two days, with RSI and ROC indicating that the trend is losing strength. While the price may seem attractive due to its recent momentum, the algorithm identifies that entering at this point could mean buying near a local top.  

**Protection:**  
The combination of high RSI, weakened Aroon trend, and low momentum (ROC) prevents entry when the price is likely near a reversal point.


#### 2. **False Correction Signals**
**Conditions:**  
- RSI_14_15m < 30 (mild oversold condition on the 15-minute timeframe).  
- AROONU_14_15m < 50 (mild downtrend).  
- STOCHk_14_3_3_15m < 20 (additional confirmation of oversold condition).  

**Example:**  
An asset shows slight downward movement over the past hour, but the volume is low, and longer timeframes (such as 4h and 1d) indicate that the price remains high or overbought.  

**Protection:**  
Although the 15-minute timeframe suggests oversold conditions, the lack of alignment with higher timeframes prevents premature entry, safeguarding against a potential continued pullback.


#### 3. **Unsustainable Momentum**
**Conditions:**  
- RSI_3_4h > 50 (mild overbought condition on the 4-hour timeframe).  
- ROC_9_4h < 30 (weakened momentum on the 4-hour timeframe).  
- AROONU_14_4h < 75 (uptrend lacks solid strength).  

**Example:**  
The price has risen rapidly in the last 4 hours, but the rate of change (ROC) is starting to decelerate. Additionally, Aroon indicates that the uptrend is not strong enough to guarantee its continuation.  

**Protection:**  
The algorithm blocks entry to avoid exposure to a move that could reverse abruptly due to insufficient momentum support.

#### 4. **Timeframe Divergence**
**Conditions:**  
- RSI_14_15m < 30 (oversold on the 15-minute timeframe).  
- RSI_3_1h > 45 (overbought on the 1-hour timeframe).  
- RSI_3_4h > 50 (overbought on the 4-hour timeframe).  

**Example:**  
An asset appears oversold on the 15-minute timeframe, but higher timeframes indicate persistent overbought conditions. This suggests that the correction in the 15-minute timeframe is minor, merely a small pullback within an overall overbought trend.  

**Protection:**  
The algorithm avoids decisions based on a single timeframe, ensuring a more comprehensive view of the market.

### Conclusion
The "pump" signal primarily protects against:  
1. **Entries at local tops.**  
2. **Minor pullbacks that do not present real opportunities.**  
3. **Uptrends with weakened momentum.**  
4. **Divergences across timeframes that suggest elevated risks.**  

This strategy minimizes the risk of getting caught in unfavorable price movements by leveraging a multi-indicator, multi-timeframe approach.

## global_protections_short_pump<a name="gpsp"></a>

TODO

# Entry signals

## Condition #1 - Normal mode (Long)<a name="long_1"></a>

### **Analysis of the Entry Signal**

1. **`df["EMA_26"] > df["EMA_12"]`**  
   - **Meaning:** The 26-period EMA is greater than the 12-period EMA.  
   - **Interpretation:** This indicates that the broader trend is bearish, as the slower-moving EMA is above the faster one. The condition ensures that the strategy aligns with the current downtrend.

2. **`(df["EMA_26"] - df["EMA_12"]) > (df["open"] * 0.030)`**  
   - **Meaning:** The difference between the 26-period and 12-period EMAs is greater than 3% of the opening price.  
   - **Interpretation:** This highlights a strong bearish trend with a significant gap between the EMAs, ensuring that the signal only triggers in pronounced downward momentum scenarios.

3. **`(df["EMA_26"].shift() - df["EMA_12"].shift()) > (df["open"] / 100.0)`**  
   - **Meaning:** The EMA difference from the previous candle is greater than 1% of the opening price.  
   - **Interpretation:** This condition confirms the consistency of the bearish trend over consecutive candles, avoiding false signals in choppy markets.

4. **`df["close"] < (df["BBL_20_2.0"] * 0.999)`**  
   - **Meaning:** The closing price is below 99.9% of the lower Bollinger Band (calculated with a 20-period moving average and a 2-standard deviation band).  
   - **Interpretation:** This indicates extreme bearish pressure, as the price is trading outside the lower Bollinger Band, suggesting oversold conditions or strong selling activity.

### **Overall Strategy Analysis**  
This signal seeks **long entries during oversold conditions in a strongly bearish market**, by combining:  
- **Trend Confirmation:** The EMA relationship and gap thresholds ensure alignment with a well-defined bearish trend.  
- **Oversold Conditions:** The closing price below the Bollinger Band highlights extreme selling pressure, making it a potential reversal point.

### **Strengths**  
1. **Strong Trend Confirmation:** By using EMA relationships and thresholds, the signal only triggers in pronounced bearish conditions, reducing the likelihood of false positives.  
2. **Oversold Market Indicator:** The Bollinger Band condition adds a reversal component, identifying extreme conditions where a rebound might occur.  
3. **Robust Filtering:** The multi-condition approach helps filter out weaker signals and focuses on higher-probability setups.

### **Suggestions for Improvement or Consideration**  
1. **Volume Confirmation:** Add a volume-based condition (e.g., high volume during the close below Bollinger Band) to validate the signal.  
2. **Dynamic EMA Thresholds:** Consider adjusting the `0.030` multiplier dynamically based on recent volatility to improve adaptability.  
3. **Exit Strategy:** Define clear profit-taking or stop-loss rules, such as targeting the middle Bollinger Band (mean reversion) or the EMA 12 level.  
4. **Add Reversal Triggers:** Include a bullish confirmation signal (e.g., RSI crossing above a threshold) to improve timing and reduce entry risk.  
5. **Backtesting:** Test the impact of values like `0.030` and `0.999` on performance across various assets and time frames to ensure optimal results.

### **Conclusion**  
This signal combines **trend-following and mean-reversion components**, designed for identifying oversold conditions in bearish markets. While robust, adding volume confirmation and dynamic thresholds could further enhance its reliability.

---

## Condition #2 - Normal mode (Long)<a name="long_2"></a>

### **Analysis of the Entry Signal**

1. **`df["AROONU_14"] < 25.0`**  
   - **Meaning:** The 14-period Aroon Up is below 25.  
   - **Interpretation:** This indicates a lack of recent highs, reflecting weak upward momentum and suggesting that the market is in a bearish phase or consolidation.

2. **`df["STOCHRSIk_14_14_3_3"] < 20.0`**  
   - **Meaning:** The Stochastic RSI is below 20, signaling oversold conditions.  
   - **Interpretation:** This suggests that the price has moved to an extreme low within its recent range, potentially indicating a reversal opportunity as selling pressure could be exhausted.

3. **`df["close"] < (df["EMA_20"] * 0.944)`**  
   - **Meaning:** The closing price is below 94.4% of the 20-period EMA.  
   - **Interpretation:** This reflects significant bearish pressure, as the price is trading well below a key moving average. It further reinforces the oversold nature of the market, highlighting a potential reversal zone.


### **Overall Strategy Analysis**  
This signal is designed to identify **long entry points in oversold conditions within a bearish or consolidating market**, relying on:  
- **Momentum Weakness:** The Aroon Up and Stochastic RSI both confirm that bullish momentum is absent and the market is oversold.  
- **Bearish Price Context:** The close being significantly below the EMA 20 suggests strong bearish sentiment, providing a discount entry opportunity if the trend reverses.


### **Strengths**  
1. **Momentum and Oversold Confluence:** Combining the Aroon Up and Stochastic RSI ensures that the signal aligns with both weak momentum and oversold conditions, increasing the likelihood of a successful reversal.  
2. **Clear Price Threshold:** The EMA 20 condition filters entries based on bearish price action, ensuring alignment with a defined price context.  
3. **Simplicity:** This setup uses straightforward conditions that are computationally efficient and easy to interpret.


### **Suggestions for Improvement or Consideration**  
1. **Volume Confirmation:** Adding a volume condition (e.g., high or increasing volume near the signal) could enhance confidence in a potential reversal.  
2. **Trend Filter:** Consider incorporating a broader trend filter (e.g., EMA 50 > EMA 200) to ensure the signal aligns with the overall market direction.  
3. **Dynamic EMA Multiplier:** Adjust the `0.944` factor based on market volatility or average true range (ATR) to make the condition adaptable to different market environments.  
4. **Exit Strategy:** Define a clear exit plan, such as targeting the EMA 20 for mean reversion or setting a percentage-based stop-loss to manage risk.  
5. **Backtesting:** Test various thresholds for the Aroon, Stochastic RSI, and EMA multiplier to identify optimal values for different assets and time frames.

### **Conclusion**  
This signal is a **reversal-based strategy**, leveraging oversold conditions and bearish price action to identify potential long entry points. While effective in its simplicity, adding volume-based validation and dynamic thresholds could further refine its performance.

---

## Condition #3 - Normal mode (Long)<a name="long_3"></a>

### **Analysis of the Entry Signal**

1. **`df["RSI_20"] < df["RSI_20"].shift(1)`**  
   - **Meaning:** The 20-period RSI is decreasing compared to the previous period.  
   - **Interpretation:** This indicates that momentum is weakening, with price action showing a lack of bullish strength. The condition reflects ongoing bearish sentiment.

2. **`df["RSI_4"] < 46.0`**  
   - **Meaning:** The 4-period RSI is below 46, suggesting short-term weakness in price momentum.  
   - **Interpretation:** This reinforces the bearish bias, as the short-term momentum indicator remains below a neutral level (typically 50), signaling that sellers are still in control.

3. **`df["AROONU_14"] < 25.0`**  
   - **Meaning:** The 14-period Aroon Up is below 25.  
   - **Interpretation:** This suggests that recent highs are weak or absent, reflecting a lack of bullish activity and strengthening the bearish sentiment.

4. **`df["close"] < df["SMA_16"] * 0.942`**  
   - **Meaning:** The closing price is below 94.2% of the 16-period simple moving average (SMA).  
   - **Interpretation:** This confirms that the price is trading well below its short-term average, highlighting significant bearish pressure and signaling a possible discount for long entry if conditions reverse.

### **Overall Strategy Analysis**  
This signal is designed to identify **long entry points during bearish or oversold conditions**, relying on:  
- **Momentum Weakness:** Both RSI indicators and the Aroon Up confirm weak momentum and bearish conditions.  
- **Price Context:** The close being far below the SMA 16 provides a measure of undervaluation, reinforcing the potential for a rebound.

### **Strengths**  
1. **Momentum-Based Filtering:** The combination of two RSI indicators ensures the signal captures both long-term and short-term bearish momentum, improving accuracy.  
2. **Trend Confirmation:** The Aroon Up condition filters out situations where bullish activity might resume prematurely.  
3. **Price Undervaluation:** The SMA multiplier ensures the entry occurs only at a significant discount, increasing the likelihood of entering near a potential reversal zone.

### **Suggestions for Improvement or Consideration**  
1. **Trend Alignment:** Add a higher timeframe trend filter (e.g., EMA 50 > EMA 200) to avoid countertrend entries in strong bear markets.  
2. **Dynamic SMA Multiplier:** Adjust the `0.942` factor dynamically using recent volatility (e.g., ATR) to enhance adaptability across different market conditions.  
3. **Volume Condition:** Include a volume-based filter to ensure that the signal aligns with increased trading activity, improving its reliability.  
4. **Exit Strategy:** Define clear exit rules, such as targeting the SMA 16 for mean reversion or a percentage-based profit target and stop-loss.  
5. **Backtesting:** Experiment with different thresholds for RSI, Aroon, and SMA multipliers to identify optimal settings for specific assets and time frames.

### **Conclusion**  
This signal leverages **momentum weakness and undervaluation** to identify long entry points in bearish market conditions. Its simplicity and focus on multiple indicators make it robust, but enhancements like trend alignment, volume filters, and dynamic thresholds could further improve its effectiveness.

---

## Condition #4 - Normal mode (Long)<a name="long_4"></a>

### **Analysis of the Entry Signal**

1. **`df["AROONU_14"] < 25.0`**  
   - **Meaning:** The 14-period Aroon Up is below 25.  
   - **Interpretation:** This indicates weak bullish momentum or the absence of recent highs, suggesting that the market is in a bearish phase or consolidation.

2. **`df["AROONU_14_15m"] < 25.0`**  
   - **Meaning:** The 14-period Aroon Up on the 15-minute timeframe is also below 25.  
   - **Interpretation:** This confirms that weak bullish momentum is consistent across both the current and a higher timeframe, reinforcing the bearish bias.

3. **`df["close"] < (df["EMA_9"] * 0.942)`**  
   - **Meaning:** The closing price is below 94.2% of the 9-period Exponential Moving Average (EMA).  
   - **Interpretation:** This reflects significant short-term bearish pressure, indicating the price is trading at a discount relative to its recent average.

4. **`df["close"] < (df["EMA_20"] * 0.960)`**  
   - **Meaning:** The closing price is below 96% of the 20-period EMA.  
   - **Interpretation:** This further validates the bearish trend over a slightly longer timeframe, suggesting a strong oversold condition and potential reversal zone.

### **Overall Strategy Analysis**  
This signal focuses on identifying **long entry points in oversold conditions across multiple timeframes**, leveraging:  
- **Momentum Weakness:** The Aroon Up indicators confirm bearish momentum across both the current and higher timeframe.  
- **Bearish Price Context:** The close being well below both the 9-period and 20-period EMAs reinforces the idea of significant price undervaluation.

### **Strengths**  
1. **Multi-Timeframe Analysis:** Incorporating the 15-minute Aroon Up ensures consistency in the bearish signal across timeframes, increasing the signal's reliability.  
2. **Dynamic Price Undervaluation:** Using two EMAs with different multipliers provides a nuanced measure of bearish pressure and helps identify potential reversal zones.  
3. **Momentum Confirmation:** The dual Aroon conditions ensure that momentum is consistently weak, avoiding premature long entries.

### **Suggestions for Improvement or Consideration**  
1. **Volume Condition:** Add a volume-based filter (e.g., above average volume) to confirm that the signal aligns with increased market participation.  
2. **Trend Filter:** Implement a higher timeframe trend filter (e.g., EMA 50 > EMA 200) to avoid countertrend trades in strong bear markets.  
3. **Dynamic Multipliers:** Adjust the `0.942` and `0.960` multipliers based on recent volatility (e.g., ATR) to enhance adaptability across different market conditions.  
4. **Exit Plan:** Define exit rules, such as targeting the EMA 9 or EMA 20 for mean reversion or setting a percentage-based stop-loss and profit target.  
5. **Backtesting:** Optimize the thresholds for Aroon, EMA multipliers, and timeframes to determine their effectiveness for specific assets and market conditions.


### **Conclusion**  
This signal is well-suited for capturing **oversold conditions with multi-timeframe confirmation**, using momentum weakness and price undervaluation as its core components. While robust in design, incorporating volume and trend alignment could further improve its reliability and performance. 

---

## Condition 5 - Normal mode (Long)<a name="long_5"></a>

### **Analysis of the Entry Signal**

1. **`df["RSI_3"] < 50.0`**  
   - **Meaning:** The 3-period RSI is below 50.  
   - **Interpretation:** This indicates weakening momentum in the very short term. The RSI below 50 suggests that bearish pressure is slightly dominant, but it's not yet in oversold territory.

2. **`df["AROONU_14"] < 25.0`**  
   - **Meaning:** The 14-period Aroon Up is below 25.  
   - **Interpretation:** This shows a lack of recent highs, signaling weakening upward momentum.

3. **`df["AROOND_14"] > 75.0`**  
   - **Meaning:** The 14-period Aroon Down is above 75.  
   - **Interpretation:** A high Aroon Down value indicates that recent lows are dominating, further reinforcing bearish momentum.

4. **`df["STOCHRSIk_14_14_3_3"] < 30.0`**  
   - **Meaning:** The Stochastic RSI is below 30.  
   - **Interpretation:** This indicates oversold conditions, suggesting that the market might be nearing a reversal.

5. **`df["EMA_26"] > df["EMA_12"]`**  
   - **Meaning:** The 26-period EMA is greater than the 12-period EMA.  
   - **Interpretation:** This reflects a bearish trend in the medium term, as the slower EMA (26) is above the faster EMA (12). This condition ensures that the strategy only triggers in a broader bearish environment.

6. **`(df["EMA_26"] - df["EMA_12"]) > (df["open"] * 0.020)`**  
   - **Meaning:** The difference between the 26-period and 12-period EMAs is greater than 2% of the opening price.  
   - **Interpretation:** This condition ensures that there is a significant gap between the two EMAs, confirming a strong bearish trend.

7. **`(df["EMA_26"].shift() - df["EMA_12"].shift()) > (df["open"] / 100.0)`**  
   - **Meaning:** The difference between the 26-period and 12-period EMAs in the previous candle is greater than 1% of the opening price.  
   - **Interpretation:** This reinforces the current EMA condition by requiring a consistent bearish trend across consecutive candles.

### **Overall Strategy Analysis**  
This signal is tailored to identify **long entry points in oversold conditions within a bearish trend**, characterized by:  
- **Momentum Weakness:** Multiple indicators (RSI, Aroon Up, Aroon Down, and Stochastic RSI) confirm that the market is oversold and dominated by bearish momentum.  
- **Bearish Trend Confirmation:** The EMA conditions ensure that the overall trend is bearish, adding a layer of protection against entering too early in a potential trend reversal.

### **Strengths**  
1. **Comprehensive Trend Analysis:** By incorporating both momentum indicators (RSI, Aroon, and Stochastic RSI) and moving average crossovers, the signal ensures alignment with both trend and reversal conditions.  
2. **Multi-Condition Filtering:** The EMA gap thresholds provide additional confirmation, filtering out weaker trends and improving reliability.  

### **Suggestions for Improvement or Consideration**  
1. **Exit Strategy:** Include a clear exit plan, such as targeting a return to the EMA 12 level or setting fixed profit and stop-loss thresholds.  
2. **Dynamic Thresholds:** Consider making the EMA gap conditions dynamic based on market volatility to adapt to different trading environments.  
3. **Volume Confirmation:** Add a condition for high or increasing volume to validate the signal’s reliability, especially in oversold conditions.  
4. **Backtesting:** Optimize values like `0.020` for the EMA gap and `50.0` for the RSI_3 threshold to ensure the signal is tuned for your asset and time frame.

### **Conclusion**  
This signal is well-suited for **counter-trend trading in bearish environments**. It provides a robust framework for identifying oversold conditions, but the reliance on bearish trends (EMA_26 > EMA_12) suggests it works best in markets with predictable reversals rather than chaotic price action.

---

## Condition 6 - Normal mode (Long)<a name="long_6"></a>

### **Analysis of the Entry Signal**

1. **`df["RSI_20"] < df["RSI_20"].shift(1)`**  
   - **Meaning:** The 20-period RSI is decreasing compared to the previous candle.  
   - **Interpretation:** This indicates a weakening momentum, which could signal either a pullback in an uptrend or a continuation of a downtrend.  

2. **`df["RSI_4"] < 46.0`**  
   - **Meaning:** The 4-period RSI is below 46.  
   - **Interpretation:** A low RSI typically indicates oversold conditions or market weakness. However, 46 is not close to the usual oversold threshold (<30), suggesting the strategy is targeting subtle moves rather than extreme conditions.

3. **`df["AROONU_14"] < 25.0`**  
   - **Meaning:** The 14-period Aroon Up is below 25.  
   - **Interpretation:** A low Aroon Up value means the market hasn’t made a new high recently, potentially signaling a weakening uptrend. This aligns with the strategy’s intent to detect a market that has lost upward momentum.

4. **`df["close"] < df["SMA_16"] * 0.942`**  
   - **Meaning:** The current closing price is below 94.2% of the 16-period simple moving average.  
   - **Interpretation:** This indicates that the price is significantly below a recent average, suggesting potential oversold conditions or market weakness.


### **Overall Strategy Analysis**  
This combination of conditions seeks to identify **long entries in a weakened market** where:  
- Momentum is slowing down (RSI and Aroon).  
- Price levels are relatively low (below the SMA).

The strategy appears to be designed to capture **potential rebounds in a mildly bearish or consolidating market**, rather than markets experiencing extreme volatility or steep declines.

### **Suggestions for Improvement or Consideration**  
1. **Additional Confirmation:** Consider adding another indicator to confirm the rebound, such as an RSI divergence or a moving average crossover.  
2. **Exit Plan:** Ensure the exit conditions are aligned with this logic to avoid holding positions if the market continues to fall.  
3. **Optimization:** Ensure that values like `46.0` for RSI_4 and `0.942` for SMA_16 are optimized for your target market and time frame through proper backtesting.

---

## Condition #41 - Quick mode (Long)<a name="long_41"></a>

### **Analysis of the Entry Signal**

1. **`df["RSI_14"] < 36.0`**  
   - **Meaning:** The 14-period Relative Strength Index (RSI) is below 36.  
   - **Interpretation:** This indicates that the market is approaching oversold territory. While not yet at extreme levels (e.g., <30), it suggests weakening bullish momentum and the potential for a reversal.

2. **`df["AROONU_14"] < 25.0`**  
   - **Meaning:** The 14-period Aroon Up is below 25.  
   - **Interpretation:** This confirms weak bullish momentum, indicating that new highs are not being made and that the market may be trending downward or consolidating.

3. **`df["AROOND_14"] > 75.0`**  
   - **Meaning:** The 14-period Aroon Down is above 75.  
   - **Interpretation:** This indicates strong bearish momentum, as recent lows dominate the price action. Together with the Aroon Up condition, this reflects a significant bearish trend.

4. **`df["EMA_9"] < (df["EMA_26"] * 0.960)`**  
   - **Meaning:** The 9-period Exponential Moving Average (EMA) is below 96% of the 26-period EMA.  
   - **Interpretation:** This reflects short-term price weakness relative to a longer-term average, confirming bearish sentiment and adding further evidence of oversold conditions.


### **Overall Strategy Analysis**  
This signal aims to identify **long entry opportunities in strongly bearish or oversold market conditions** by leveraging:  
- **Momentum Indicators:** RSI and Aroon provide confirmation of bearish trends and potential oversold states.  
- **Trend Dynamics:** The EMA comparison ensures that the short-term trend is significantly weaker than the longer-term trend, supporting the idea of undervaluation.


### **Strengths**  
1. **Momentum and Trend Convergence:** The combination of RSI, Aroon, and EMA conditions ensures that momentum and trend signals align to indicate a bearish environment.  
2. **Confirmation of Oversold Conditions:** The RSI and Aroon indicators effectively highlight potential oversold areas for a reversal or mean reversion.  
3. **Dynamic Trend Comparison:** Using EMA multipliers provides a flexible way to detect significant deviations in short-term vs. long-term trends.


### **Suggestions for Improvement or Consideration**  
1. **Refinement of RSI Threshold:** Test different RSI levels (e.g., <30) to capture deeper oversold conditions, especially in strong bearish trends.  
2. **Volume Filter:** Add a condition based on volume (e.g., higher-than-average volume) to confirm participation during potential reversal points.  
3. **Trend Context:** Introduce a higher timeframe trend filter (e.g., EMA 50 > EMA 200) to avoid taking long trades during strong bearish markets.  
4. **Dynamic Multipliers:** Consider adapting the `0.960` multiplier for the EMA condition based on recent volatility (e.g., ATR).  
5. **Exit Strategy:** Define clear exit rules, such as targeting the 9-period EMA or another dynamic level for mean reversion, alongside stop-loss thresholds to limit risk.  
6. **Backtesting:** Optimize the Aroon thresholds and EMA multipliers for specific assets or market conditions to ensure effectiveness.


### **Conclusion**  
This signal effectively combines momentum and trend-based criteria to identify potential **reversal or undervaluation scenarios in a bearish market context**. While robust in design, integrating additional filters such as volume and higher timeframe trends could improve its precision and profitability.

---

## Condition #42 - Quick mode (Long)<a name="long_42"></a>

### **Analysis of the Entry Signal**

1. **`df["WILLR_14"] < -50.0`**  
   - **Meaning:** The 14-period Williams %R is below -50.  
   - **Interpretation:** This indicates that the asset is in the lower half of its trading range, suggesting bearish momentum. However, it is not yet oversold, as the oversold threshold typically lies below -80.

2. **`df["STOCHRSIk_14_14_3_3"] < 20.0`**  
   - **Meaning:** The Stochastic RSI (%K) with parameters `14_14_3_3` is below 20.  
   - **Interpretation:** This signals an oversold condition on a short-term momentum indicator, suggesting the potential for a reversal.

3. **`df["WILLR_84_1h"] < -70.0`**  
   - **Meaning:** The 84-period Williams %R on the 1-hour timeframe is below -70.  
   - **Interpretation:** This indicates bearish momentum on a higher timeframe, supporting the bearish sentiment in the shorter-term signals.

4. **`df["STOCHRSIk_14_14_3_3_1h"] < 20.0`**  
   - **Meaning:** The Stochastic RSI (%K) with parameters `14_14_3_3` on the 1-hour timeframe is below 20.  
   - **Interpretation:** This confirms an oversold condition on the 1-hour timeframe, aligning with the shorter-term signals and increasing the likelihood of a reversal.

5. **`df["BBB_20_2.0_1h"] > 16.0`**  
   - **Meaning:** The Bollinger Bandwidth (BBB) on the 1-hour timeframe with parameters `20_2.0` is greater than 16.  
   - **Interpretation:** This indicates high volatility in the 1-hour timeframe. Elevated Bollinger Bandwidth often precedes significant price movements, making this condition a potential filter for trading opportunities.

6. **`df["close_max_48"] >= (df["close"] * 1.10)`**  
   - **Meaning:** The highest close price in the last 48 periods is at least 10% higher than the current close price.  
   - **Interpretation:** This highlights a significant downward movement over recent periods, suggesting that the asset is undervalued and potentially due for a mean reversion or bounce.


### **Overall Strategy Analysis**  
This signal aims to identify **oversold conditions across multiple timeframes and high volatility environments** with the potential for reversals. It combines momentum indicators, higher-timeframe confirmation, and volatility filters to enhance the precision of entry points.


### **Strengths**  
1. **Multi-Timeframe Confirmation:** The use of both current and 1-hour timeframe indicators ensures alignment of momentum signals, increasing reliability.  
2. **Volatility Awareness:** The Bollinger Bandwidth condition ensures that trades are only considered in high-volatility environments, where significant price moves are more likely.  
3. **Momentum and Undervaluation:** The combination of Williams %R, Stochastic RSI, and recent close price conditions effectively identifies oversold and undervalued scenarios.


### **Suggestions for Improvement or Consideration**  
1. **Threshold Optimization:**  
   - Adjust `-50.0` for Williams %R to a more oversold level (e.g., `< -80.0`) to filter out weaker signals.  
   - Validate the `20.0` threshold for Stochastic RSI across different assets and market conditions.  

2. **Additional Filters:**  
   - Add a volume filter to confirm market participation in the reversal.  
   - Introduce a higher timeframe trend filter (e.g., EMA 50 > EMA 200 on the daily timeframe) to ensure trades align with broader market trends.

3. **Exit Strategy:**  
   - Clearly define exit conditions, such as targeting the mid or upper Bollinger Band or a specific RSI level.  
   - Consider using trailing stops to lock in gains during potential reversals.  

4. **Dynamic Conditions:**  
   - Use an adaptive Bollinger Bandwidth threshold (e.g., based on recent historical averages) to account for varying market volatility.  
   - Adjust the `1.10` multiplier for recent close prices dynamically, depending on the asset's typical volatility.  

5. **Backtesting and Validation:**  
   - Thoroughly test this setup on multiple asset classes and timeframes to ensure robustness.  
   - Evaluate signal effectiveness in different market conditions (e.g., trending vs. ranging).


### **Conclusion**  
This signal leverages a well-rounded combination of **multi-timeframe momentum, volatility, and undervaluation criteria** to pinpoint potential reversal opportunities. While effective in concept, further refinement of thresholds and the addition of volume or trend-based filters could improve its performance.

---

## Condition #43 - Quick mode (Long)<a name="long_43"></a>

### **Analysis of the Entry Signal**

1. **`df["RSI_14"] < 40.0`**  
   - **Meaning:** The 14-period RSI is below 40.  
   - **Interpretation:** Indicates bearish momentum but not yet oversold (typically below 30). This suggests weakness in price but leaves room for further downward movement.

2. **`df["MFI_14"] < 40.0`**  
   - **Meaning:** The 14-period Money Flow Index is below 40.  
   - **Interpretation:** Combines price and volume to indicate bearish sentiment. Values below 50 show weakness, and levels below 20 are oversold. This condition aligns with the RSI to confirm bearish pressure.

3. **`df["AROONU_14"] < 25.0`**  
   - **Meaning:** The 14-period Aroon Up indicator is below 25.  
   - **Interpretation:** Indicates that recent highs are distant, signaling a lack of bullish momentum.

4. **`df["EMA_26"] > df["EMA_12"]`**  
   - **Meaning:** The 26-period EMA is above the 12-period EMA.  
   - **Interpretation:** Suggests that the short-term trend is below the longer-term trend, confirming bearish market conditions.

5. **`(df["EMA_26"] - df["EMA_12"]) > (df["open"] * 0.024)`**  
   - **Meaning:** The difference between the 26-period EMA and the 12-period EMA is greater than 2.4% of the current opening price.  
   - **Interpretation:** Ensures a significant bearish divergence between the two EMAs, reinforcing a strong bearish trend.

6. **`(df["EMA_26"].shift() - df["EMA_12"].shift()) > (df["open"] / 100.0)`**  
   - **Meaning:** The previous period's EMA difference is greater than 1% of the current opening price.  
   - **Interpretation:** Confirms that the bearish divergence between the EMAs is consistent over time, ensuring trend persistence.

7. **`df["close"] < (df["EMA_20"] * 0.958)`**  
   - **Meaning:** The current closing price is below 95.8% of the 20-period EMA.  
   - **Interpretation:** Indicates that the price is significantly below its short-term average, suggesting bearish momentum.

8. **`df["close"] < (df["BBL_20_2.0"] * 0.992)`**  
   - **Meaning:** The current closing price is below 99.2% of the 20-period lower Bollinger Band.  
   - **Interpretation:** Indicates that the price is near or outside the lower Bollinger Band, suggesting oversold conditions and potential for a reversal.


### **Overall Strategy Analysis**  
This entry signal identifies **oversold conditions within a strong bearish trend**. It combines momentum indicators (RSI, MFI, Aroon Up), EMA relationships to confirm trend strength, and Bollinger Bands to detect extreme price levels.

### **Strengths**  
1. **Momentum and Volume Confirmation:** The RSI and MFI together provide a robust view of price and volume-based momentum.  
2. **Trend Reinforcement:** The EMA conditions ensure that trades align with a strong bearish trend.  
3. **Oversold Levels:** The Bollinger Band condition ensures that entries are made at potentially oversold price levels, increasing the chance of a reversal.

### **Suggestions for Improvement or Consideration**  
1. **Optimize Thresholds:**  
   - Adjust the RSI and MFI levels (e.g., `< 30.0`) to focus on more extreme oversold conditions.  
   - Experiment with the Bollinger Band multiplier (e.g., `0.990` instead of `0.992`) for tighter entry points.

2. **Trend Continuation Filter:**  
   - Add a higher timeframe trend filter to ensure the trade aligns with broader market direction, reducing false signals.

3. **Volume Confirmation:**  
   - Introduce a volume condition (e.g., `df["volume"] > df["volume"].rolling(20).mean()`) to confirm market participation.

4. **Exit Strategy:**  
   - Define clear exit conditions, such as reaching the mid or upper Bollinger Band, or when the RSI exceeds 50.  
   - Use a trailing stop to protect gains during potential reversals.

5. **Backtesting and Optimization:**  
   - Test the setup on multiple assets and timeframes to determine its robustness.  
   - Validate the 2.4% EMA divergence condition against historical data for varying market environments.

### **Conclusion**  
This signal effectively combines **momentum, trend, and volatility conditions** to pinpoint potential oversold scenarios within bearish trends. While it appears well-constructed, refining thresholds and adding additional filters could further improve its precision and reliability.

---

## Condition 120 - Grind mode (Long)<a name="long_120"></a>

### **Analysis of the Entry Signal**

1. **`df["STOCHRSIk_14_14_3_3"] < 20.0`**  
   - **Meaning:** The stochastic RSI (with a 14-period RSI, smoothed over 14, 3, and 3 periods) is below 20.  
   - **Interpretation:** This indicates that the asset is in a deeply oversold state on a stochastic basis, which combines RSI and stochastic oscillators. Such low values suggest the market may be near a reversal or rebound point.

2. **`df["WILLR_14"] < -80.0`**  
   - **Meaning:** The 14-period Williams %R is below -80.  
   - **Interpretation:** Williams %R values below -80 indicate that the market is in oversold territory, reinforcing the idea that the asset might be due for a rebound.

3. **`df["AROONU_14"] < 25.0`**  
   - **Meaning:** The 14-period Aroon Up is below 25.  
   - **Interpretation:** A low Aroon Up value indicates a lack of new highs in the recent period, suggesting weakness in upward momentum. This complements the oversold signals by adding a momentum perspective.

4. **`df["close"] < (df["EMA_20"] * 0.978)`**  
   - **Meaning:** The closing price is below 97.8% of the 20-period exponential moving average.  
   - **Interpretation:** This signals that the price is trading significantly below its recent average, suggesting short-term weakness or oversold conditions.

### **Overall Strategy Analysis**  
This signal logic aims to identify **long entry points in deeply oversold market conditions**, using a combination of:  
- **Oscillator-Based Oversold Levels:** Both stochastic RSI and Williams %R provide strong indicators of oversold conditions, increasing the likelihood of capturing reversal points.  
- **Momentum Weakness:** The Aroon indicator ensures that the market has lost upward momentum.  
- **Price Deviation:** The EMA condition adds a layer of confirmation by requiring the price to be significantly below its recent average, indicating potential undervaluation.

### **Strengths**  
1. **Diverse Indicator Use:** The strategy combines oscillators (Stochastic RSI, Williams %R), momentum (Aroon), and price action (EMA deviation) for a well-rounded approach.  
2. **High Oversold Confirmation:** Multiple indicators pointing to oversold conditions reduce the risk of false signals.  

### **Suggestions for Improvement or Consideration**  
1. **Volume Confirmation:** Add a condition for volume, such as high volume during the oversold state, to confirm the market’s interest in a potential reversal.  
2. **Reversal Signal:** Consider including a trigger for a reversal confirmation (e.g., a bullish candlestick pattern or a moving average crossover).  
3. **Exit Strategy Alignment:** Ensure that the exit logic complements the entry signal by defining clear profit targets or using mean reversion thresholds.  
4. **Backtesting and Optimization:** Test and optimize thresholds like `20.0` for Stochastic RSI, `-80.0` for Williams %R, and `0.978` for EMA multipliers for the target asset and time frame.

This signal is well-designed for capturing potential rebounds in oversold markets.

---
## Condition #143 - Top Coins mode (Long)<a name="long_143"></a>

### **Analysis of the Entry Signal**

1. **`df["RSI_3"] < 40.0`**  
   - **Meaning:** The 3-period RSI is below 40.  
   - **Interpretation:** A very short-term momentum indicator suggests the price is in bearish momentum but not yet oversold (typically below 30). This indicates temporary weakness in the market.

2. **`df["STOCHRSIk_14_14_3_3"] < 50.0`**  
   - **Meaning:** The %K line of the 14-period Stochastic RSI is below 50.  
   - **Interpretation:** Indicates bearish sentiment within the Stochastic RSI's range. Values below 50 suggest momentum is leaning downward.

3. **`df["EMA_26"] > df["EMA_12"]`**  
   - **Meaning:** The 26-period EMA is greater than the 12-period EMA.  
   - **Interpretation:** Confirms that the short-term trend (12 EMA) is below the longer-term trend (26 EMA), indicating bearish conditions.

4. **`(df["EMA_26"] - df["EMA_12"]) > (df["open"] * 0.020)`**  
   - **Meaning:** The gap between the 26 EMA and the 12 EMA is greater than 2% of the current opening price.  
   - **Interpretation:** Reinforces a strong bearish divergence between the EMAs, suggesting that the market is trending downward with sufficient momentum.

5. **`(df["EMA_26"].shift() - df["EMA_12"].shift()) > (df["open"] / 100.0)`**  
   - **Meaning:** The difference between the 26 EMA and 12 EMA from the previous period is greater than 1% of the current opening price.  
   - **Interpretation:** Confirms that the bearish divergence between the EMAs has been consistent across time, strengthening the reliability of the trend.


### **Overall Strategy Analysis**  
This entry signal focuses on **capturing bearish momentum** within a strong downward trend, combining very short-term indicators (RSI 3) with longer-term EMA relationships and the Stochastic RSI. The conditions aim to align with bearish market sentiment while identifying moments of temporary weakness.

### **Strengths**  
1. **Momentum and Trend Confirmation:**  
   - The combination of short-term RSI and Stochastic RSI with EMA relationships ensures trades align with both short-term momentum and longer-term trend direction.
   
2. **Trend Strength Filter:**  
   - The EMA gap conditions (both current and historical) ensure that only strong bearish trends are considered, reducing the likelihood of false entries during sideways markets.

3. **Short-Term Focus:**  
   - Using the 3-period RSI allows the strategy to react quickly to short-term market changes while maintaining alignment with the overall trend.

### **Suggestions for Improvement or Consideration**  
1. **Optimize Thresholds:**  
   - Test the RSI 3 threshold at `< 30.0` to focus on more extreme oversold conditions for potentially better entry timing.  
   - For the Stochastic RSI, a threshold of `< 20.0` could identify more precise moments of oversold momentum.

2. **Volume Confirmation:**  
   - Add a condition for volume to ensure that entries occur during periods of significant market activity (e.g., `df["volume"] > df["volume"].rolling(20).mean()`).

3. **Higher Timeframe Confirmation:**  
   - Include a condition to confirm the trend on a higher timeframe (e.g., the 1-hour chart) to filter out false signals in choppy markets.

4. **Exit Strategy:**  
   - Define clear exit rules, such as:  
   - RSI 3 exceeds 70.  
   - Price crosses above the 12 EMA.  
   - Stochastic RSI %K exceeds 80.

5. **Backtesting:**  
   - Test the signal on different assets and timeframes to evaluate its effectiveness across varying market conditions.


### **Conclusion**  
This signal is designed to **identify bearish momentum in strong downward trends**, using both short-term and longer-term confirmations. While it is well-constructed, refining the thresholds and adding volume or higher timeframe filters could improve its robustness and reduce noise.

## Condition #501 - Normal mode (Short)<a name="short_501"></a>

TODO

## Condition #502 - Normal mode (Short)<a name="short_502"></a>

TODO

## Condition #503 - Normal mode (Short)<a name="short_503"></a>

TODO

## Condition #504 - Normal mode (Short)<a name="short_504"></a>

TODO

## Condition #542 - Quick mode (Short)<a name="short_542"></a>

TODO

## Condition #543 - Rapid mode (Short)<a name="short_543"></a>

TODO

## Condition #641 - Top Coins mode (Short)<a name="short_641"></a>

TODO

## Condition #642 - Top Coins mode (Short)<a name="short_642"></a>

TODO

# Position adjustment modes

## adjust_trade_position function

The `adjust_trade_position` function in the **NostalgiaForInfinityX5** strategy of Freqtrade is responsible for dynamically adjusting the position of an ongoing trade based on specific conditions. Here's a breakdown of its functionality:

### Overview
This method is invoked to determine whether and how a trade's position should be adjusted, such as increasing the stake or modifying the strategy, depending on the trade's status, market conditions, and predefined rules. It supports both long and short positions and handles different trading modes like rebuy and grind modes.


### Key Components

#### **1. Position Adjustment Toggle**
```python
if self.position_adjustment_enable == False:
    return None
```
- **Purpose:** If `position_adjustment_enable` is set to `False`, the function exits without making any changes.
- **Effect:** This provides a global switch to enable or disable position adjustments.


#### **2. Enter Tag Parsing**
```python
enter_tag = "empty"
if hasattr(trade, "enter_tag") and trade.enter_tag is not None:
    enter_tag = trade.enter_tag
enter_tags = enter_tag.split()
```
- **Purpose:** The `enter_tag` is extracted from the `trade` object to determine the mode or strategy associated with the trade (e.g., rebuy, grind).
- **Effect:** Tags are split into a list for easier matching against predefined mode-specific tags.


#### **3. Rebuy Mode**
```python
if not trade.is_short and (
    all(c in self.long_rebuy_mode_tags for c in enter_tags)
    or (
        any(c in self.long_rebuy_mode_tags for c in enter_tags)
        and all(c in (self.long_rebuy_mode_tags + self.long_grind_mode_tags) for c in enter_tags)
    )
):
    return self.long_rebuy_adjust_trade_position(...)
```
- **Purpose:** If the trade is a **long** position and matches specific `long_rebuy_mode_tags`, it triggers the `long_rebuy_adjust_trade_position` method.
- **Effect:** Adjusts the trade by implementing the logic for the rebuy mode, which likely increases the position size to capitalize on favorable market conditions.


#### **4. Grinding Mode (Long Trades)**
```python
elif not trade.is_short and (
    any(c in (...) for c in enter_tags)
    or not any(c in (...) for c in enter_tags)
):
    return self.long_grind_adjust_trade_position(...)
```
- **Purpose:** If the trade is a **long** position and matches tags related to grinding modes (e.g., normal, pump, rapid), it triggers the `long_grind_adjust_trade_position` method.
- **Effect:** Implements adjustments for grinding mode strategies, which might aim to optimize profits in slow-moving markets.


#### **5. Grinding Mode (Short Trades)**
```python
elif trade.is_short and (
    any(c in (...) for c in enter_tags)
    or not any(c in (...) for c in enter_tags)
):
    return self.short_grind_adjust_trade_position(...)
```
- **Purpose:** Similar to the grinding mode for long trades, but applied to **short** trades. Uses predefined tags like `short_normal_mode_tags` and others.
- **Effect:** Adjusts short positions based on grinding mode rules.


#### **6. Default Return**
```python
return None
```
- **Purpose:** If none of the above conditions are met, no adjustment is made.
- **Effect:** Ensures the function doesn't make unnecessary changes when conditions don't align.


### Additional Insights
- **Customizability:** The function relies heavily on predefined tags (`long_rebuy_mode_tags`, `long_grind_mode_tags`, etc.), allowing for extensive customization of trading behavior.
- **Reusability:** Calls to `long_rebuy_adjust_trade_position`, `long_grind_adjust_trade_position`, and `short_grind_adjust_trade_position` encapsulate specific logic for those modes, making the function modular.
- **Flexibility:** Supports both long and short trades and distinguishes between various trading modes for nuanced control over adjustments.


### High-Level Purpose
The `adjust_trade_position` function is a critical part of the strategy's risk management and profit optimization framework. It dynamically adjusts ongoing trades based on the context, enabling the strategy to respond adaptively to changing market conditions. This can help maximize profits in favorable situations (e.g., rebuying) and mitigate risks in less favorable ones.

## Grind mode<a name="grinding"></a>

The "grind mode" is a strategy which involves increasing the position in a losing trade. It activates when the asset's price falls significantly below the initial entry point, offering an opportunity to buy more of the asset at a lower price and thereby reduce the average entry price.

**Objective of "Grind Mode":**

The goal of "grind mode" is to improve the chances of making a profit when the asset's price eventually reverses upward. By buying more at a lower price, the overall loss of the trade is reduced, requiring a smaller upward movement to reach the breakeven point.

**Key Parameters of "Grind Mode":**

* **`grind_mode_stake_multiplier_spot`** and **`grind_mode_stake_multiplier_futures`**: These parameters determine the multiplier applied to the position size for each additional buy during "grind mode." For example, a value of `[0.20, 0.30, 0.40, 0.50]` means the first additional buy will be 20% of the initial position size, the second 30%, and so on.

* **`grind_mode_first_entry_profit_threshold_spot`** and **`grind_mode_first_entry_profit_threshold_futures`**: These parameters define the profit threshold that must be reached to exit the first entry in "grind mode" for spot and futures markets, respectively.

* **`grind_mode_first_entry_stop_threshold_spot`** and **`grind_mode_first_entry_stop_threshold_futures`**: These parameters define the maximum loss threshold (stop-loss) that will be applied to the first entry in "grind mode" for spot and futures markets, respectively.

* **`grind_mode_max_slots`**: Defines the maximum number of positions (slots) that can be opened in "grind mode" for the same trading pair.

* **`grind_mode_coins`**: List of cryptocurrencies for which "grind mode" will be activated.

In summary, "grind mode" in NostalgiaForInfinityX5 is an aggressive strategy aimed at leveraging price drops to accumulate a position at a lower average cost. By increasing the position during market weakness, "grind mode" seeks to maximize potential profits when the price reverses.

### Grind buy signal 1 (gd1)

1. **Initial Restrictions**:
   - It must not be a partial sell: `not partial_sell`.
   - The number of active operations (sub grind) must be less than the maximum allowed: `grind_1_sub_grind_count < grind_1_max_sub_grinds`.

2. **Specific Context Conditions**:
   - One of the following scenarios must apply:
     - At least one sub operation already exists, and the negative distance ratio is below the configured threshold for the respective sub operation.
     - The strategy is in "derisk" mode, and this is the first sub operation.
     - Grind mode is enabled, and this is the first sub operation.

3. **Time Restrictions**:
   - The last entry must have been filled more than 10 minutes ago: `current_time - timedelta(minutes=10) > filled_entries[-1].order_filled_utc`.
   - The last filled order must meet at least one of these conditions:
     - It was executed more than 2 hours ago.
     - Accumulated profit (slice profit) is greater than 2%: `slice_profit > 0.02`.

4. **Restrictions on Open Grinds**:
   - If no grinds are open, the operation can proceed.
   - If grinds are open, at least one of these conditions must apply:
     - The last order was filled more than 6 hours ago.
     - Accumulated profit is greater than 6%.

5. **Short Grind Entry Condition**:
   - The entry must be categorized as a short grind entry: `is_short_grind_entry`.


#### Detailed Analysis

1. **Focus on Profitability**:
   Unlike **Grinding 6 (GD6)**, which includes loss thresholds to limit entry during losses, GD1 emphasizes profitability. Conditions like `slice_profit > 0.02` and `slice_profit > 0.06` ensure that the strategy enters only when there is evidence of positive returns.

2. **Risk Management Through Time**:
   By spacing out entries (at least 10 minutes between entries and 2-6 hours between filled orders depending on the conditions), GD1 mitigates the risk of over-trading.

3. **Dependence on Context and Entry Type**:
   The condition `is_short_grind_entry` enforces that only specific short-grind setups qualify for entry, likely tied to the broader strategy's rules.

4. **Flexibility for Sub Operations**:
   The logic accounts for varying thresholds for different sub grind operations (`grind_1_sub_thresholds`), providing flexibility to manage entries based on the number of sub operations already active.


#### Potential Improvements or Adjustments

1. **Dynamic Profit Thresholds**:
   - The static profit thresholds (`0.02` and `0.06`) could be adapted dynamically based on market volatility or recent performance.

2. **Indicator-Based Conditions**:
   - Unlike GD6, GD1 lacks technical indicator checks (e.g., RSI, EMA). Adding these could provide additional confirmation for entries, especially for short grind entries.

3. **Modularity and Readability**:
   - Breaking the logic into smaller functions could make it easier to debug, update, and maintain.

4. **Testing Under Different Market Conditions**:
   - Ensure the strategy performs well in trending, ranging, and volatile markets to validate the robustness of these conditions.

### Grind buy signal 2 (gd2)

1. **Initial Restrictions**:
   - Order tags must exist: `has_order_tags`.
   - It must not be a partial sell: `not partial_sell`.
   - The number of active sub-operations (sub grind) must be less than the maximum allowed: `grind_2_sub_grind_count < grind_2_max_sub_grinds`.

2. **Specific Context Conditions**:
   - One of the following scenarios must apply:
     - At least one sub operation already exists, and the negative distance ratio is below the configured threshold for the respective sub operation: `-grind_2_distance_ratio < grind_2_sub_thresholds[grind_2_sub_grind_count]`.
     - The strategy is in "derisk" mode, and this is the first sub operation.
     - Grind mode is enabled, and this is the first sub operation.

3. **Time Restrictions**:
   - The last entry must have been filled more than 10 minutes ago: `current_time - timedelta(minutes=10) > filled_entries[-1].order_filled_utc`.
   - The last filled order must meet at least one of these conditions:
     - It was executed more than 2 hours ago.
     - Accumulated profit (slice profit) is greater than 2%: `slice_profit > 0.02`.

4. **Restrictions on Open Grinds**:
   - If no grinds are open, the operation can proceed.
   - If grinds are open, at least one of these conditions must apply:
     - The last order was filled more than 6 hours ago.
     - Accumulated profit is greater than 6%.

5. **Short Grind Entry Condition**:
   - The entry must qualify as a short grind entry: `is_short_grind_entry`.

#### Detailed Analysis

1. **Profit-Oriented Logic**:
   - Like **GD1**, GD2 focuses on profitability by including conditions such as `slice_profit > 0.02` and `slice_profit > 0.06`. These ensure the strategy enters positions only when there is evidence of positive returns.

2. **Time-Based Entry Spacing**:
   - Conditions such as `current_time - timedelta(minutes=10)` and `current_time - timedelta(hours=2)` ensure that entries are spaced apart, preventing over-trading.

3. **Flexibility for Sub Operations**:
   - The condition `grind_2_sub_thresholds` provides flexibility by setting thresholds that vary based on the number of sub operations already active. This allows for nuanced handling of entries based on the strategy's current position in the market.

4. **Risk and Context Management**:
   - By incorporating `is_derisk` and `is_derisk_calc`, the strategy accounts for risk-reducing scenarios, especially for the first sub operation.

5. **Dependence on Short Grind Entries**:
   - The condition `is_short_grind_entry` ensures that only specific setups designed for short grind entries are considered, maintaining consistency with the overall strategy's framework.


#### Potential Improvements or Adjustments

1. **Dynamic Profit and Distance Thresholds**:
   - Consider adjusting the profit thresholds (`0.02` and `0.06`) and distance ratio dynamically based on market conditions (e.g., volatility or recent performance).

2. **Incorporating Technical Indicators**:
   - Unlike **GD6**, which includes indicators like RSI and EMA for additional confirmation, GD2 relies solely on thresholds and profitability metrics. Adding technical indicators could improve the precision of entries.

3. **Code Modularity**:
   - Breaking this logic into smaller, reusable functions could make the code more maintainable and easier to debug.

4. **Performance Testing**:
   - Test the strategy across various market conditions (e.g., trending, ranging, and volatile markets) to ensure robustness.


#### Comparison to GD1

The logic for **GD2** is very similar to **GD1**, focusing on profitability and time-based restrictions. However, **GD2** includes an additional condition requiring order tags (`has_order_tags`). Both strategies share an emphasis on positive slice profit, but neither includes technical indicators as seen in **GD6**.

### Grind buy signal 3 (gd3)

1. **Initial Restrictions**:
   - Order tags must exist: `has_order_tags`.
   - It must not be a partial sell: `not partial_sell`.
   - The number of active sub-operations (sub grind) must be less than the maximum allowed: `grind_3_sub_grind_count < grind_3_max_sub_grinds`.

2. **Specific Context Conditions**:
   - One of the following scenarios must apply:
     - At least one sub operation already exists, and the negative distance ratio is below the configured threshold for the respective sub operation: `-grind_3_distance_ratio < grind_3_sub_thresholds[grind_3_sub_grind_count]`.
     - The strategy is in "derisk" mode, and this is the first sub operation: `is_derisk or is_derisk_calc`.
     - Grind mode is enabled, and this is the first sub operation: `is_grind_mode`.

3. **Time Restrictions**:
   - The last entry must have been filled more than 10 minutes ago: `current_time - timedelta(minutes=10) > filled_entries[-1].order_filled_utc`.
   - The last filled order must meet at least one of these conditions:
     - It was executed more than 2 hours ago.
     - Accumulated profit (slice profit) is greater than 2%: `slice_profit > 0.02`.

4. **Restrictions on Open Grinds**:
   - If no grinds are open, the operation can proceed.
   - If grinds are open, at least one of these conditions must apply:
     - The last order was filled more than 6 hours ago.
     - Accumulated profit is greater than 6%.

5. **Short Grind Entry Condition**:
   - The entry must qualify as a short grind entry: `is_short_grind_entry`.


#### Detailed Analysis

1. **Profit-Oriented Logic**:
   - Similar to **GD1** and **GD2**, GD3 focuses on profitability by requiring conditions such as `slice_profit > 0.02` and `slice_profit > 0.06`. These thresholds ensure the strategy enters only when positive returns are evident.

2. **Time-Based Entry Spacing**:
   - Conditions like `current_time - timedelta(minutes=10)` and `current_time - timedelta(hours=2)` ensure that entries are spaced apart to prevent over-trading.

3. **Flexibility for Sub Operations**:
   - The condition `grind_3_sub_thresholds` allows for dynamic handling of sub operations by setting thresholds that vary based on the number of active sub operations.

4. **Risk and Context Management**:
   - By incorporating `is_derisk` and `is_derisk_calc`, the strategy ensures proper handling of risk-reduction scenarios for initial sub operations.

5. **Dependence on Short Grind Entries**:
   - The condition `is_short_grind_entry` ensures consistency with the broader strategy by limiting entries to setups designed for short grinds.


#### Potential Improvements or Adjustments

1. **Dynamic Profit and Distance Thresholds**:
   - The profit thresholds (`0.02` and `0.06`) and distance ratio could be dynamically adjusted based on market volatility or recent performance.

2. **Addition of Technical Indicators**:
   - Unlike **GD6**, GD3 does not utilize technical indicators such as RSI or EMA. Adding these could enhance precision and alignment with market conditions.

3. **Modularity**:
   - Breaking this logic into smaller, reusable functions would improve maintainability and make debugging easier.

4. **Performance Testing**:
   - Testing the strategy under different market conditions (e.g., trending, ranging, and volatile markets) would help validate its robustness and adaptability.


#### Comparison to Other Grinding Strategies

- **Similarity to GD1 and GD2**:
  - GD3 shares a focus on profitability and similar timing conditions for entries. All three strategies emphasize slice profit thresholds and rely on `is_short_grind_entry` as a critical condition.

- **Differences from GD6**:
  - GD3 does not incorporate technical indicators like RSI or EMA, which are used in GD6 to refine entries further.


### Grind buy signal 4 (gd6)

1. **Initial Restrictions**:
   - Order tags must exist: `has_order_tags`.
   - It must not be a partial sell: `not partial_sell`.
   - The number of active sub-operations (sub grind) must be less than the maximum allowed: `grind_4_sub_grind_count < grind_4_max_sub_grinds`.

2. **Specific Context Conditions**:
   - One of the following scenarios must apply:
     - At least one sub operation already exists, and the negative distance ratio is below the configured threshold for the respective sub operation: `-grind_4_distance_ratio < grind_4_sub_thresholds[grind_4_sub_grind_count]`.
     - The strategy is in "derisk" mode, and this is the first sub operation: `is_derisk or is_derisk_calc`.
     - Grind mode is enabled, and this is the first sub operation: `is_grind_mode`.

3. **Time Restrictions**:
   - The last entry must have been filled more than 10 minutes ago: `current_time - timedelta(minutes=10) > filled_entries[-1].order_filled_utc`.
   - The last filled order must meet at least one of these conditions:
     - It was executed more than 2 hours ago.
     - Accumulated profit (slice profit) is greater than 2%: `slice_profit > 0.02`.

4. **Restrictions on Open Grinds**:
   - If no grinds are open, the operation can proceed.
   - If grinds are open, at least one of these conditions must apply:
     - The last order was filled more than 6 hours ago.
     - Accumulated profit is greater than 6%.

5. **Enhanced Entry Conditions**:
   - One of the following must apply:
     - The entry qualifies as a short grind entry: `is_short_grind_entry`.
     - Additional indicator-based conditions are met:
       - Accumulated profit (`slice_profit`) is greater than 4%: `slice_profit > 0.04`.
       - **RSI Conditions**:
         - `RSI_14` is above 64.
         - `RSI_3` across multiple timeframes (15m, 1h, and 4h) is below their respective thresholds (90 for shorter timeframes and 85 for longer ones).
       - **AROON Conditions**:
         - The AROOND_14 indicator is below 25.
       - **Price Condition**:
         - The current price is above 101.2% of the EMA_20: `last_candle["close"] > (last_candle["EMA_20"] * 1.012)`.


#### Detailed Analysis

1. **Profit-Oriented Logic**:
   - GD4 incorporates profitability thresholds (`slice_profit > 0.02` and `slice_profit > 0.04`) to ensure entries are made in favorable conditions.

2. **Technical Indicators for Confirmation**:
   - Unlike GD1, GD2, and GD3, GD4 includes additional technical indicators to refine entries:
     - RSI conditions favor overbought scenarios for potential reversals, balancing momentum and entry precision.
     - AROOND_14 and EMA conditions ensure alignment with market trends.

3. **Flexibility for Sub Operations**:
   - As with other Grinding strategies, the use of thresholds for sub operations (`grind_4_sub_thresholds`) allows dynamic handling of entries based on the number of active sub operations.

4. **Enhanced Risk and Entry Management**:
   - By requiring specific RSI and price conditions for non-short grind entries, GD4 seeks to filter out low-probability setups.

5. **Time-Based Entry Spacing**:
   - The spacing conditions (`10 minutes` and `2-6 hours`) prevent over-trading and ensure more deliberate entry timing.


#### Potential Improvements or Adjustments

1. **Dynamic Threshold Adjustments**:
   - The static thresholds for slice profit and indicators could be dynamically adjusted based on market conditions, such as volatility or recent performance.

2. **Refinement of RSI Conditions**:
   - The RSI thresholds could be fine-tuned to consider different market phases (e.g., trending vs. ranging).

3. **Enhanced Modularity**:
   - Breaking the logic into modular functions for sub operations, time conditions, and indicator-based filtering would improve maintainability and readability.

4. **Performance Monitoring**:
   - Backtesting across diverse market conditions (e.g., trending, ranging, or volatile markets) would help validate the robustness and adaptability of the strategy.


#### Comparison to Other Grinding Strategies

- **Similarities**:
  - GD4 shares foundational structures with GD1, GD2, and GD3, including sub-operation thresholds, slice profit conditions, and time-based restrictions.

- **Key Differences**:
  - **Indicator-Based Filters**: GD4 stands out by incorporating additional technical indicators (RSI, AROON, and EMA).
  - **Stronger Profit Thresholds**: GD4 requires slice profit > 4% in certain conditions, compared to lower thresholds in other grinding strategies.

### Grind buy signal 5 (gd5)

1. **Initial Restrictions**:
   - Order tags must exist: `has_order_tags`.
   - It must not be a partial sell: `not partial_sell`.
   - The number of active sub-operations (sub grind) must be less than the maximum allowed: `grind_5_sub_grind_count < grind_5_max_sub_grinds`.

2. **Specific Context Conditions**:
   - One of the following scenarios must apply:
     - At least one sub operation already exists, and the negative distance ratio is below the configured threshold for the respective sub operation: `-grind_5_distance_ratio < grind_5_sub_thresholds[grind_5_sub_grind_count]`.
     - The strategy is in "derisk" mode, and this is the first sub operation: `is_derisk or is_derisk_calc`.
     - Grind mode is enabled, and this is the first sub operation: `is_grind_mode`.

3. **Time Restrictions**:
   - The last entry must have been filled more than 10 minutes ago: `current_time - timedelta(minutes=10) > filled_entries[-1].order_filled_utc`.
   - The last filled order must meet at least one of these conditions:
     - It was executed more than 2 hours ago.
     - Accumulated profit (slice profit) is greater than 2%: `slice_profit > 0.02`.

4. **Restrictions on Open Grinds**:
   - If no grinds are open, the operation can proceed.
   - If grinds are open, at least one of these conditions must apply:
     - The last order was filled more than 6 hours ago.
     - Accumulated profit is greater than 6%.

5. **Short Grind Entry Condition**:
   - The entry must qualify as a short grind entry: `is_short_grind_entry`.


#### Detailed Analysis

1. **Profit-Oriented Logic**:
   - Like **GD1, GD2, and GD3**, GD5 incorporates profitability thresholds (`slice_profit > 0.02` and `slice_profit > 0.06`) to ensure entries occur under favorable conditions.

2. **Time-Based Entry Spacing**:
   - Time-based restrictions (`10 minutes` and `2-6 hours`) prevent frequent entries, ensuring the strategy does not overtrade and operates with sufficient spacing between orders.

3. **Sub Operation Flexibility**:
   - The use of sub-operation thresholds (`grind_5_sub_thresholds`) allows for adaptive handling of entries based on the number of active sub operations.

4. **Risk and Context Management**:
   - The inclusion of `is_derisk` and `is_derisk_calc` ensures that risk-reducing conditions are prioritized for the first sub operation.

5. **Dependence on Short Grind Entries**:
   - The condition `is_short_grind_entry` enforces alignment with the strategy’s focus, limiting entries to setups specifically designed for short grind scenarios.


#### Potential Improvements or Adjustments

1. **Incorporating Technical Indicators**:
   - Unlike **GD4**, GD5 lacks additional technical filters like RSI or EMA, which could improve precision and market alignment.

2. **Dynamic Threshold Adjustments**:
   - The fixed profit thresholds (`0.02` and `0.06`) and distance ratio could be dynamically adjusted based on market conditions (e.g., volatility or trend strength).

3. **Code Modularity**:
   - Breaking the logic into smaller functions (e.g., time-based conditions, sub operation thresholds, and profitability checks) would enhance readability and maintainability.

4. **Performance Testing**:
   - Backtesting across various market conditions (trending, ranging, and volatile markets) would help validate GD5's robustness and effectiveness.


#### Comparison to Other Grinding Strategies

- **Similarity to GD1, GD2, and GD3**:
  - GD5 shares a focus on profitability and time-based restrictions. The structure and logic are largely consistent across these strategies.

- **Difference from GD4**:
  - GD4 incorporates additional technical indicators (RSI, AROON, and EMA), whereas GD5 relies on slice profit thresholds and short grind entries without technical filters.


GD5 is a straightforward, profit-driven strategy similar to GD1-GD3, with a clear focus on managing sub operations and enforcing profitability conditions. However, it lacks the enhanced filtering provided by technical indicators (seen in GD4). 


### Grind buy signal 6 (gd6)

1. **Initial Restrictions**:
   - Order tags must exist: `has_order_tags`.
   - It must not be a partial sell: `not partial_sell`.
   - The number of active operations (sub grind) must be less than the maximum allowed: `grind_6_sub_grind_count < grind_6_max_sub_grinds`.

2. **Specific Context Conditions**:
   - One of the following situations must apply:
     - At least one sub operation already exists, and the current distance ratio is below the configured threshold.
     - The strategy is in "derisk" mode, and this is the first sub operation.
     - Grind mode is enabled, and this is the first sub operation.

3. **Time Restrictions**:
   - The last entry must have been filled more than 10 minutes ago: `current_time - timedelta(minutes=10) > filled_entries[-1].order_filled_utc`.
   - The last filled order must meet at least one of these conditions:
     - It was executed more than 2 hours ago.
     - Accumulated loss (slice profit) is less than -2%: `slice_profit < -0.02`.

4. **Restrictions on Open Grinds**:
   - If no grinds are open, the operation can proceed.
   - If grinds are open, at least one of these conditions must apply:
     - The last order was filled more than 6 hours ago.
     - Accumulated loss is less than -6%.

5. **Conditions Based on Technical Indicators**:
   - If it is a long grind entry (`is_long_grind_entry`), it is automatically allowed.
   - If not, then:
     - RSI_14 must be below 36.
     - RSI_3 across multiple timeframes must be above 10 (1 minute, 15 minutes, 1 hour, and 4 hours).
     - The AROONU_14 indicator must be below 25.
     - The current price must be below 98.8% of the EMA_20.


#### Detailed Analysis

1. **Complex but Structured Logic**:
   The logic is well-organized and uses combined logical operators to cover a wide range of situations. This ensures flexibility and control under different market conditions.

2. **Reliance on Technical Indicators**:
   Using multiple periods for RSI_3 and checking oversold levels (RSI_14 < 36 and AROONU_14 < 25) suggests that this strategy aims to identify opportunities in highly oversold markets.

3. **Time-Based Restrictions**:
   These limit entry frequency, avoiding over-trading and ensuring that entry decisions are spaced either by time or loss context.

4. **Risk Management**:
   The "slice_profit" conditions indicate a focus on limiting cumulative losses. Additionally, both distance ratios and custom thresholds for sub operations are taken into account.


#### Potential Improvements or Adjustments

1. **Modularity**:
   Consider breaking these conditions into smaller functions to make the code easier to maintain and debug.

2. **Dynamic Thresholds**:
   Certain conditions, such as RSI values or percentages related to the EMA, could be adjusted dynamically based on volatility or general market conditions.

3. **Performance Monitoring**:
   It's essential to test how these conditions affect performance across different market environments (trending, ranging, high volatility, etc.).

If you'd like, we can optimize the code or run backtests using historical data to validate its effectiveness.


## Rebuy Mode<a name="rebuy"></a>

The "rebuy mode" is another type of strategy that, like "grind mode," aims to increase the position in a losing trade. However, unlike "grind mode," which activates during significant price drops, "rebuy mode" is triggered when the price falls below specific thresholds, which are less severe than those for "grind mode."

**Objective of "Rebuy Mode":**

The goal of "rebuy mode" is to reduce the average entry price of a trade by buying more of the asset at a lower price. This decreases the overall loss and increases the chances of making a profit when the price recovers.

**Key Parameters of "Rebuy Mode":**

* **`rebuy_mode_stake_multiplier`**: This parameter defines the percentage of the initial position size to be used for each additional buy during "rebuy mode." For example, a value of `0.2` means each additional buy will be 20% of the original position size.

* **`rebuy_mode_max`**: Defines the maximum number of additional buys (rebuys) that can be made in a single trade.

* **`rebuy_mode_derisk_spot`** and **`rebuy_mode_derisk_futures`**: These parameters set the loss thresholds to activate the "derisk" in "rebuy mode" for spot and futures markets, respectively.

* **`rebuy_mode_stakes_spot`** and **`rebuy_mode_stakes_futures`**: These parameters are a list of multipliers applied to the position size for each additional buy (rebuy) in spot and futures markets, respectively.

* **`rebuy_mode_thresholds_spot`** and **`rebuy_mode_thresholds_futures`**: These parameters define the loss thresholds that must be reached to trigger each additional buy (rebuy) in spot and futures markets, respectively.

In summary, "rebuy mode" in NostalgiaForInfinityX5 is a strategy designed to capitalize on small price drops to improve the position of a trade. By making additional buys at lower prices, "rebuy mode" reduces the average cost of the position, increasing the likelihood of achieving profitability when the price eventually recovers.

---

## Derisk mode<a name="derisk"></a>

The "derisk" is a feature within the NostalgiaForInfinityX5 trading strategy designed to reduce the risk of a trade. It activates when the asset's price moves against the open position, whether it is a long (buy) or short (sell) position.

**The goal of "derisk" is to mitigate potential losses or secure a small profit by selling a portion of the position.** This is done at a price considered favorable, typically a point where the loss is minimized or even a small profit is achieved.

**Key Parameters of "Derisk"**

* **Derisk Thresholds:** These thresholds define the point at which the "derisk" is triggered for different operation modes (regular, rebuy, grind mode) and market types (spot or futures). Examples include:
    * **`regular_mode_derisk_spot`** and **`regular_mode_derisk_futures`**: Thresholds for "derisk" in regular mode for spot and futures markets, respectively.
    * **`rebuy_mode_derisk_futures`**: Threshold for "derisk" in rebuy mode for futures markets.

* **Calculation of the Amount to Sell:** The algorithm determines the amount of the asset to sell during the "derisk" process. This decision is based on factors such as the current profit, the total position size, and the minimum order size.

In summary, the "derisk" in NostalgiaForInfinityX5 functions as a safety mechanism to protect trades from significant losses. By selling a portion of the position at strategic moments, the "derisk" aims to minimize the impact of unfavorable price movements.

# Exit signals<a name="exit"></a>

## Tags<a name="exit_tags"></a>

### Long exit signals (original)

#### Sell signal 1 (exit_{mode_name}_1_X_Y}

The **Sell Signal 1** tags focus on overbought conditions identified by a high RSI (>84) and consistent price action above the upper Bollinger Band for the last 5 candles. These tags aim to secure profits in extended bullish trends, with exits further categorized based on whether the price is above or below the EMA 200. This differentiation helps adapt the strategy to the broader trend, allowing profit-taking in both strong uptrends and potential bearish reversals.

```
exit_{mode_name}_1_1_1
```

Triggered when the closing price of the last candle is above the EMA 200.
This indicates an overall bullish trend, but the trade is closed due to overbought conditions (high RSI and price above the Bollinger Bands).
It represents a profit-taking decision in a strong uptrend.

```
exit_{mode_name}_1_2_1:
```

Triggered when the closing price of the last candle is below the EMA 200.
This suggests a weaker trend or a bearish shift, combined with overbought conditions.
The exit is more cautious, aiming to secure profits before further potential downside.


#### Sell signal 2 (exit_{mode_name}_2_X_Y}

The Sell Signal 2 tags respond to stronger overbought conditions, with an RSI threshold of >86 and price action above the upper Bollinger Band for the last 3 candles. These tags aim for quicker profit-taking compared to Sell Signal 1, targeting trades where the market shows extreme overbought signals but over a shorter timeframe. The exits are further categorized based on whether the price is above or below the EMA 200, adjusting the strategy to the prevailing trend while locking in profits.

```
exit_{mode_name}_2_1_1:
```

Triggered when the closing price of the last candle is above the EMA 200.
Indicates a bullish trend, but the trade is closed due to even more extreme overbought conditions (higher RSI threshold of >86 and price above the Bollinger Bands for the last 3 candles).
The exit reflects a strategy to secure profits in a strong uptrend before a likely correction.

```
exit_{mode_name}_2_2_1:
```

Triggered when the closing price of the last candle is below the EMA 200.
Suggests a weaker or bearish trend while still closing the trade due to extreme overbought conditions.
This exit aims to lock in profits in a less favorable trend environment before potential further downside.

#### Exit signal 3 (exit_{mode_name}_3_X_X)

This sell signal focuses solely on an extremely high RSI threshold (>88) as the primary trigger, making it the most sensitive to overbought conditions among the three signals. It does not depend on Bollinger Band conditions like the previous signals, allowing for a quicker response.

```
exit_{mode_name}_3_1_1:
```

Triggered when the closing price of the last candle is above the EMA 200.
Indicates a bullish trend, but the trade is exited due to extremely overbought conditions (RSI > 88).
This exit represents a precautionary profit-taking decision in an overheated market during a strong uptrend.

```
exit_{mode_name}_3_2_1:
```

Triggered when the closing price of the last candle is below the EMA 200.
Suggests a weaker or bearish trend while still exiting the trade due to extremely overbought conditions.
The goal is to secure profits in a less favorable trend environment before a likely price correction.

#### Sell Signal 4 (exit_{mode_name}_4_X_X):

The **Sell Signal 4** tags consider overbought conditions on multiple timeframes, with RSI thresholds of >84 on the current timeframe and >80 on the 1-hour timeframe. This combination ensures that both the short-term and medium-term market conditions are overheated. The exits are categorized based on whether the price is above or below the EMA 200, allowing the strategy to adapt to the overall trend while securing profits in highly overbought scenarios.

Sell Signal 4 introduces the additional confirmation of **multi-timeframe RSI conditions**, making it more robust in identifying overbought scenarios compared to previous signals. This ensures the exit is based on a broader market perspective, increasing its reliability in highly volatile markets.

```
exit_{mode_name}_4_1_1
```
   - Triggered when:
     - The closing price of the last candle is **above the EMA 200**, indicating a **bullish trend**.
     - RSI > 84 on the current timeframe and RSI > 80 on the 1-hour timeframe, signaling **overbought conditions across multiple timeframes**.
     - The trade has a current profit >1%.
   - This exit reflects a cautious profit-taking strategy in a strong uptrend, driven by overbought signals confirmed on both short-term and medium-term timeframes.

```
exit_{mode_name}_4_2_1
```
   - Triggered when:
     - The closing price of the last candle is **below the EMA 200**, indicating a **weaker or bearish trend**.
     - RSI > 84 on the current timeframe and RSI > 80 on the 1-hour timeframe, signaling **overbought conditions across multiple timeframes**.
     - The trade has a current profit >1%.
   - This exit secures profits in a less favorable trend environment, taking into account that overbought conditions may lead to stronger corrections when the overall trend is bearish. 

#### Sell Signal 6 (exit_{mode_name}_6_X_Y):

The **Sell Signal 6** tag identifies overbought conditions in a transitional trend phase, where the price is below the long-term EMA 200 (suggesting a bearish trend) but above the short-term EMA 50 (indicating a temporary bullish recovery). With RSI > 79, the signal targets profit-taking before a potential reversal. This exit prioritizes locking in profits in uncertain or transitional market conditions.

Sell Signal 6 is designed for scenarios where the market is transitioning between bearish and bullish phases. The combination of price action relative to EMA 200 and EMA 50, along with overbought RSI conditions, ensures that profits are secured before the potential continuation of the bearish trend. This signal is particularly useful for avoiding losses in markets showing temporary recoveries within a long-term downtrend.

```
exit_{mode_name}_6_1
```
   - Triggered when:
     - The closing price of the last candle is **below the EMA 200**, signaling a **bearish overall trend**.
     - The closing price is **above the EMA 50**, indicating a **short-term bullish recovery** within a broader bearish trend.
     - RSI > 79, which suggests **overbought conditions**.
     - The trade has a current profit >1%.
   - This exit reflects a cautious approach, aiming to secure profits in a potentially unstable market where short-term bullish momentum may not sustain due to the broader bearish context.

#### Sell Signal 8 (exit_{mode_name}_8_X_Y)

The **Sell Signal 8** tags target scenarios where the price has significantly exceeded the upper Bollinger Band (BBU) on the 1-hour timeframe, specifically by more than 14%. This indicates extreme overbought conditions and a potential reversal. The exits are further categorized based on whether the price is above or below the EMA 200, adapting the strategy to the overall trend while locking in profits in overheated markets.

Sell Signal 8 focuses on **extreme price deviations** relative to Bollinger Bands on a higher timeframe (1-hour). By requiring the price to exceed the BBU by 14%, it ensures that exits are only triggered under truly overextended market conditions. The differentiation based on EMA 200 further refines the strategy, allowing it to adapt to both bullish and bearish trends while prioritizing profit-taking.

```
exit_{mode_name}_8_1_1
```
   - Triggered when:
     - The closing price is **above the upper Bollinger Band (BBU) on the 1-hour timeframe by 14% or more**, indicating **extreme overbought conditions**.
     - The closing price is **above the EMA 200**, suggesting an **overall bullish trend**.
     - The trade has a current profit >1%.
   - This exit aims to secure profits in a strong uptrend where the price has reached unsustainable levels relative to its volatility.

```
exit_{mode_name}_8_2_1
```
   - Triggered when:
     - The closing price is **above the upper Bollinger Band (BBU) on the 1-hour timeframe by 14% or more**, indicating **extreme overbought conditions**.
     - The closing price is **below the EMA 200**, signaling a **weaker or bearish trend**.
     - The trade has a current profit >1%.
   - This exit reflects a more cautious approach, aiming to secure profits in a potentially bearish market where extreme overbought conditions are unlikely to sustain.


### Long exit signals (main)

#### Sell with profits over SMA 200

```
exit_{mode_name}_o_X
```

The exit_{mode_name}_o_X signals are designed to manage trade exits based on a combination of profit targets and Relative Strength Index (RSI) values. This mechanism is particularly focused on locking in profits when the trade is in a generally bullish context, as determined by the closing price being above the EMA 200.

1. **Profit Thresholds (X)**:
   ```python
   elif current_profit >= 0.001:
   ```
   - The logic evaluates different **profit levels** ranging from 0.1% (`0.001`) to above 20% (`0.2`).
   - For each profit range, an **RSI-based condition** determines whether the exit signal is triggered.
   - The profit ranges are as follows:
     - **0.001 to 0.01** (1%): Exit if RSI < 10.0.
     - **0.01 to 0.02** (2%): Exit if RSI < 28.0.
     - **0.02 to 0.03** (3%): Exit if RSI < 30.0.
     - (Continues incrementally with higher thresholds up to **20% or more**).

2. **RSI Thresholds**:
   ```python
   if last_candle["RSI_14"] < threshold:
   ```
   - RSI thresholds are **dynamic** and **increase with profit levels**, reflecting a willingness to hold the trade longer in stronger bullish conditions.
   - For higher profits, the strategy allows higher RSI thresholds, signaling that a pullback from overbought conditions (indicated by a lower RSI) is acceptable.


3. **Key Characteristics of the Signal**

   - **Dynamic Profit-Taking**:
      - As profits increase, the RSI threshold becomes more forgiving, allowing trades to ride the bullish trend longer. This ensures profits are locked in while still capturing potential upside momentum.
   
   - **Adaptation to Market Strength**:
      - By only considering trades where the price is above the EMA 200, the strategy avoids reactive exits in weaker markets and focuses on maximizing gains in a strong market.

   - **Granular Exit Management**:
      - The use of incremental profit brackets (e.g., 1% to 2%, 2% to 3%) allows the strategy to handle trade exits with fine-tuned precision, adapting to varying market conditions.

4. **Potential Improvements**

   1. **RSI Divergences**:
      - Incorporate divergence detection (e.g., RSI showing bearish divergence despite profits) to enhance the robustness of exits.

   2. **Volatility Adjustments**:
      - Adjust profit or RSI thresholds dynamically based on market volatility to better adapt to fast-moving markets.

   3. **Trailing Stop Integration**:
      - Introduce trailing stop-loss mechanisms for profits beyond 10% to lock in gains while leaving room for potential upside.


#### Sell with profits under SMA 200

```
exit_{mode_name}_u_X
```

The **`exit_{mode_name}_u_X` signals** are designed to handle trade exits when the market is in a **bearish context**, as identified by the closing price being below the **EMA 200**. These signals focus on managing trades that are profitable or near breakeven but where the market shows signs of weakness or exhaustion.

- **Protective Profit-Taking**:
  - The strategy aims to secure small profits or minimize potential losses in a bearish market, where the risk of further declines is higher.
  
- **Dynamic Adjustments**:
  - The RSI thresholds increase with profit levels, allowing trades with higher gains to tolerate more fluctuation before exiting.

- **Risk-Averse in Downtrends**:
  - By only triggering when the price is below the EMA 200, the logic ensures tighter risk management in bearish trends.


##### **`exit_{mode_name}_u_0`**:
- Triggered for minimal profits (0.1%–1%).
- RSI < 12.0 indicates extreme bearish momentum, prompting a cautious exit.

##### **`exit_{mode_name}_u_1` to `exit_{mode_name}_u_10`**:
- Covers profit ranges from 1% to 12%.
- RSI thresholds gradually increase from 30.0 to 48.0, reflecting a more relaxed approach as profits grow.

##### **`exit_{mode_name}_u_11`**:
- Profit range: 12%–20%.
- RSI threshold decreases slightly to 46.0, emphasizing the need to protect profits in this range.

##### **`exit_{mode_name}_u_12`**:
- Triggered for profits of 20% or more.
- RSI < 44.0 ensures the trade is exited promptly if bearish conditions persist, protecting significant gains.


##### **Strengths**

1. **Bearish Trend Adaptation**:
   - The strategy recognizes the increased risks in a downtrend and prioritizes protecting profits or minimizing exposure.

2. **Granular Exit Control**:
   - Fine-tuned profit brackets allow for precise control of trade exits, making the strategy adaptable to various market conditions.

3. **RSI-Based Validation**:
   - The use of RSI ensures that exits are triggered based on both market momentum and the trade's profitability.


##### **Potential Improvements**

1. **Multi-Timeframe Confirmation**:
   - Incorporate higher timeframe RSI or trend indicators to validate bearish conditions further.

2. **Dynamic Volatility Adjustment**:
   - Adjust profit and RSI thresholds based on market volatility to better handle fast-moving or stagnant markets.

3. **Divergence Signals**:
   - Integrate bearish RSI divergence detection to enhance the signal’s robustness in identifying weakening trends.


### Downtrend/descending based sells

```
exit_{mode_name}_d_{X}_{Y}
```

The two digits in the label `d_X_Y` have specific meanings related to the strategy's decision-making process:

1. **First Digit (`X`):**
   - Represents the **profit range** for the trade.
   - **Example:**
     - `X = 0`: Profit range between `0.001` and `0.01` (low profits).
     - `X = 1`: Profit range between `0.01` and `0.02` (moderate profits).
     - Higher values would likely correspond to higher profit ranges.

2. **Second Digit (`Y`):**
   - Indicates the **specific condition** that triggered the exit within the given profit range.
   - Each number corresponds to a unique combination of technical indicators:
     - **Example conditions:**
       - Overbought signals (e.g., `RSI`, `Williams %R`).
       - Momentum loss (`ROC`).
       - Pressure indicators like `CMF` or `AROON`.
     - **`Y = 1` to `Y = 7`:** Different technical setups or combinations that meet the strategy's criteria for exiting.


### **Summary**
- The **first digit (`X`)** defines the profit range.
- The **second digit (`Y`)** specifies the exact technical condition that justifies the exit within that range.

### Stoploss signals

#### Stoploss doom (`exit_{mode_name}_stoploss_doom`):

The **Stoploss Doom Signal** targets scenarios where a trade has reached a catastrophic loss level and no longer meets the conditions for remaining open. This signal is designed to act as a safeguard, ensuring that trades are exited promptly in extreme adverse conditions to prevent further losses. 

   - Triggered when:
     - The **profit loss** exceeds the "doom" threshold (adjusted for market type and leverage).
     - By default stop_threshold_doom_spot is 25% and stop_threshold_doom_futures is 60%.
     - The **entry conditions are no longer valid**, indicating the trade setup is no longer favorable.
     - The trade is **recent** (post-September 13, 2024) or being analyzed in a backtesting environment.
   - This exit prevents further losses and resets the trade for a better opportunity. 

## TODO tags

- exit_{mode_name}_stoploss_u_e
- exit_profit_{mode_name}_max
- exit_long_quick_q_{1-10}
- exit_long_rapid_rpd_{1-10}
- exit_long_grind_g
- exit_{mode_name}_o_{1-10}   # exit with price over SMA 200, and current_profit over {1-10} and last candle under RSI_14 specific level.
- exit_{mode_name}_w_{0-12}_{0-16}


## long_exit_normal<a name="long_exit_normal"></a>

The `long_exit_normal` function is a method that determines whether a trade should close its position under certain predefined conditions. Its logic is structured around multiple checks that include profitability, indicators, trends, and stop-loss mechanisms. Here's a breakdown of its key components:

### **1. Initial Condition: Skip for Non-Profitable Trades**
- The function begins by checking if the initial profit ratio (`profit_init_ratio`) is greater than `0.0`. If the trade is already at a loss, most subsequent checks are skipped.

### **2. Sequential Exit Signals**
The function iterates through several exit signal functions in a specific order. It stops as soon as one of them returns a `True` signal:

1. **`long_exit_signals`**:
   - Used for basic or original exit signals based on specific criteria.
   
2. **`long_exit_main`**:
   - The main logic for detecting whether the trade should exit, likely using more refined or frequently checked conditions.
   
3. **`long_exit_williams_r`**:
   - Uses the Williams %R indicator for determining whether to exit. This indicator detects overbought or oversold conditions.
   
4. **`long_exit_dec`**:
   - Detects downtrends or descending patterns to trigger an exit.

### **3. Stop-Losses**
- If no exit signals were triggered, the function checks the stop-loss conditions using `long_exit_stoploss`.
- This method ensures the trade is exited if the losses reach predefined thresholds, preserving capital.

### **4. Target Profit Mechanism**
- The function integrates a target profit mechanism using `self.target_profit_cache`.
- It evaluates whether the pair has reached or exceeded its target profit. If yes, it triggers an exit and adjusts targets dynamically for better performance.

### **5. Maximizing Profit Targets**
- For trades already marked with a stop-loss reason, the function attempts to recover if the profit increases by a small margin (e.g., `0.005`).
- When possible, it dynamically raises the profit target to ensure maximum returns.


### **6. Fallback and Signal Consolidation**
- If no conditions are met but the `profit_init_ratio` exceeds `0.005`, the function updates the target profit with a "maximization" signal.
- Finally, it ensures certain conditions are met before returning an exit signal (`True`) or skipping (`False`).


### **Return Values**
- **`True, signal_name`**: Indicates the trade should exit based on a specific signal.
- **`False, None`**: No exit conditions were met; the trade remains open.


### **Key Observations**
1. **Flexible Structure**: The function is modular, allowing easy addition or modification of exit conditions.
2. **Profit Optimization**: The logic favors maximizing profit before closing a trade, showing a preference for efficiency over immediate closure.
3. **Dynamic Adjustments**: By relying on `self.target_profit_cache`, the function dynamically tracks and updates profit targets for optimal results.
4. **Risk Management**: The inclusion of stop-loss mechanisms ensures the function adheres to solid risk management principles.

## long_exit_signals<a name="long_exit_signals"></a>

The `long_exit_signals` function identifies whether specific market conditions are met to exit a long position. It uses a set of predefined technical indicators and thresholds to determine whether the position should be closed. Below is a detailed breakdown of its logic:


### **Function Parameters**
- **`mode_name`**: A string representing the mode of operation (likely used to distinguish between different strategies or signals).
- **`current_profit`**, **`max_profit`**, **`max_loss`**: Metrics representing the trade's profitability and loss.
- **`last_candle`** and **`previous_candles`**: Contain data from recent candles (OHLC, indicators like RSI, EMA, Bollinger Bands, etc.).
- **`trade`**: Represents the trade being evaluated.
- **`current_time`**: Current timestamp of evaluation.
- **`buy_tag`**: Likely a tag or label related to the trade entry conditions.


### **Exit Conditions**
The function sequentially evaluates various sell signals. If one signal triggers, the function exits early with `True` and a descriptive exit tag. Otherwise, it returns `False` and `None`.


### **1. Sell Signal 1: RSI and Bollinger Band Exceedance Over 5 Candles**
- **Conditions**:
  - RSI (`RSI_14`) > 84.0.
  - Current and previous 5 candles' closing prices are above the Bollinger Band upper boundary (`BBU_20_2.0`).
- **Additional Checks**:
  - If the close price > EMA 200, it uses the tag `exit_{mode_name}_1_1_1`.
  - If close price ≤ EMA 200, it uses `exit_{mode_name}_1_2_1`.
  - Requires `current_profit` > 0.01 (ensures a minimum profit).

**Implication**: This signal indicates overbought conditions sustained over multiple candles, suggesting a potential reversal.


### **2. Sell Signal 2: RSI and Bollinger Band Exceedance Over 3 Candles**
- **Conditions**:
  - RSI > 86.0.
  - Current and previous 3 candles' closing prices are above the Bollinger Band upper boundary.
- **Tagging**:
  - Similar structure to Signal 1, with tags adjusted to `exit_{mode_name}_2_1_1` and `exit_{mode_name}_2_2_1`.

**Implication**: A variation of Signal 1 with tighter conditions and a higher RSI threshold, targeting quicker exits.


### **3. Sell Signal 3: RSI Alone**
- **Condition**: RSI > 88.0.
- **Tagging**:
  - Close price > EMA 200: `exit_{mode_name}_3_1_1`.
  - Otherwise: `exit_{mode_name}_3_2_1`.

**Implication**: A simple threshold-based exit for extreme overbought conditions.


### **4. Sell Signal 4: RSI with 1-Hour RSI Confirmation**
- **Conditions**:
  - RSI > 84.0.
  - 1-hour RSI (`RSI_14_1h`) > 80.0.
- **Tagging**:
  - Similar to previous signals, with tags `exit_{mode_name}_4_1_1` or `exit_{mode_name}_4_2_1`.

**Implication**: Confirms overbought conditions across multiple timeframes, strengthening the exit signal.


### **5. Sell Signal 6: EMA and RSI Combined**
- **Conditions**:
  - Close price < EMA 200 and > EMA 50.
  - RSI > 79.0.
- **Tagging**: Always exits with `exit_{mode_name}_6_1`.

**Implication**: Indicates weakening upward momentum and potential for a reversal.


### **6. Sell Signal 8: Extreme Deviation from 1-Hour Bollinger Band**
- **Condition**: Current close price > 1-hour Bollinger Band upper boundary (`BBU_20_2.0_1h`) * 1.14.
- **Tagging**:
  - Close price > EMA 200: `exit_{mode_name}_8_1_1`.
  - Otherwise: `exit_{mode_name}_8_2_1`.

**Implication**: Suggests unsustainable price deviations and potential reversion to the mean.


### **Excluded Signals**
- Signal 7 is commented out. It involves a crossover with EMA 12/26 and RSI conditions but is not active in the logic.

### **Return Value**
- **`True, exit_tag`**: An exit condition was triggered.
- **`False, None`**: No conditions were met; the trade remains open.

### **Key Observations**
1. **Prioritization**: Signals are evaluated sequentially, meaning earlier conditions take precedence.
2. **Focus on Overbought Conditions**: The function heavily relies on RSI and Bollinger Bands to detect overbought scenarios.
3. **Dynamic Tagging**: Exit tags are descriptive, allowing detailed tracking of which signal triggered the exit.
4. **Profit Threshold**: Ensures exits occur only when there is a minimum profit (`> 0.01`), avoiding premature closures.


### **Suggestions for Improvement**
1. **Scalability**: Consider modularizing signal conditions into separate functions for easier maintenance and testing.
2. **Parameterization**: Use configuration files or parameters for thresholds like RSI levels (e.g., 84.0, 88.0), allowing flexibility without code changes.
3. **Optimize Priority**: Review the order of signals to ensure the most critical ones are evaluated first, reducing unnecessary computations.


## long_exit_main function<a name="long_exit_main"></a>

This function evaluates whether to exit a long position based on a set of conditions related to the current profit, RSI levels, and the relationship between the closing price and the EMA 200 indicator.

### Strengths:

1. **Granular Exit Levels**:
   - The function provides finely detailed exit conditions depending on the `current_profit`. This allows for a highly adaptable strategy based on profit thresholds.

2. **Dynamic RSI Adjustments**:
   - The RSI thresholds decrease as profits increase, which aligns well with the logic of securing profits when overbought signals are detected.

3. **EMA 200 Condition**:
   - The function considers the relationship between the price and the EMA 200, differentiating between bullish (`close > EMA_200`) and bearish (`close < EMA_200`) contexts, which is a solid approach for managing trades in varying market conditions.

4. **Clear Tagging**:
   - The `mode_name` and suffixes like `_o_` or `_u_` (indicating above or below EMA 200) allow for easy tracking and debugging of exit signals.

### Weaknesses and Suggestions for Improvement:

1. **Repetitive Code**:
   - There is a lot of duplicated code between the `close > EMA_200` and `close < EMA_200` blocks. Both segments perform similar checks with slightly adjusted RSI thresholds.
   - **Solution**: Extract the repetitive logic into a helper function that accepts parameters such as `current_profit`, `RSI_thresholds`, and a tag suffix. This will improve maintainability.

2. **Static Thresholds**:
   - Both the profit and RSI thresholds are hardcoded, which makes the function less adaptable to changes in market conditions or user preferences.
   - **Solution**: Use a configuration or parameterized approach to allow dynamic adjustments of these thresholds.

3. **Lack of Comments**:
   - The function lacks inline comments explaining the rationale behind specific thresholds (e.g., why `RSI_14 < 42.0` for `current_profit >= 0.2`).
   - **Solution**: Add comments to clarify the logic for future developers or traders.

4. **Limited Signal Types**:
   - The function only considers `RSI_14` and `EMA_200`. While these are commonly used, other indicators or conditions (e.g., volume, ATR, or MACD) might improve its accuracy.
   - **Solution**: Consider integrating additional indicators or conditions to create a more robust strategy.

5. **Binary Outcome**:
   - The function returns either a signal (`True`) or nothing (`False`). It does not account for scenarios where partial exits or staggered profit-taking might be optimal.
   - **Solution**: Modify the return logic to include a more nuanced response, such as suggested exit percentages.

6. **Performance Considerations**:
   - Checking many conditions sequentially for each candle could slow down performance, especially with high-frequency strategies or large datasets.
   - **Solution**: Optimize the order of checks or use vectorized operations if applicable in the broader context.

### Code Refactor Suggestion:

Here's an example of how the function could be refactored:

```python
def long_exit_main(
    self,
    mode_name: str,
    current_profit: float,
    last_candle,
    RSI_thresholds: dict,
    ema_threshold: float,
    suffix: str,
) -> tuple:
    for profit_range, rsi_limit in RSI_thresholds.items():
        lower_bound, upper_bound = profit_range
        if upper_bound > current_profit >= lower_bound and last_candle["RSI_14"] < rsi_limit:
            return True, f"exit_{mode_name}_{suffix}_{RSI_thresholds[profit_range]}"
    return False, None

# Example Usage:
RSI_THRESHOLDS_ABOVE_EMA = {
    (0.001, 0.01): 10.0,
    (0.01, 0.02): 28.0,
    (0.02, 0.03): 30.0,
    # Add other ranges here...
    (0.2, float("inf")): 42.0,
}

RSI_THRESHOLDS_BELOW_EMA = {
    (0.001, 0.01): 12.0,
    (0.01, 0.02): 30.0,
    (0.02, 0.03): 32.0,
    # Add other ranges here...
    (0.2, float("inf")): 44.0,
}

if last_candle["close"] > last_candle["EMA_200"]:
    return long_exit_main(
        self,
        mode_name,
        current_profit,
        last_candle,
        RSI_THRESHOLDS_ABOVE_EMA,
        last_candle["EMA_200"],
        "o"
    )
else:
    return long_exit_main(
        self,
        mode_name,
        current_profit,
        last_candle,
        RSI_THRESHOLDS_BELOW_EMA,
        last_candle["EMA_200"],
        "u"
    )
```

This approach eliminates redundancy and makes the function easier to maintain and extend.

## long_exit_williams_r function<a name="long_exit_williams"></a>

## Analysis of the Function `long_exit_williams_r`

The `long_exit_williams_r` function is used to generate exit signals for long (buy) positions in an automated trading system. Its logic is based on a series of conditions involving technical indicators, primarily the Williams %R, to identify opportune moments to close a position and secure profits.

Below is a detailed breakdown of the function's logic:

### **Purpose**
The function aims to identify overbought conditions or signs of market weakness that suggest the asset's price may begin to decline. In such cases, the function issues an exit signal to protect the accumulated profits from a long position.

### **Context**
The `long_exit_williams_r` function is just one of many exit functions used within the trading system. It is called after other exit functions, such as `long_exit_main`, and only executes if the previous functions have not generated an exit signal. This indicates that `long_exit_williams_r` acts as an additional or backup exit mechanism.

### **Indicators**
The function relies on various technical indicators, including:  
- **Williams %R (WILLR):** A momentum indicator that measures overbought and oversold levels.  
- **Relative Strength Index (RSI):** Another momentum indicator that evaluates the magnitude of recent price changes to assess overbought and oversold conditions.  
- **RSI across different timeframes (RSI_3_1h, RSI_3_4h):** Used to provide a broader perspective on RSI trends.  
- **Aroon (AROONU_14_4h):** An indicator that measures trend strength by comparing recent highs and lows.  
- **Rate of Change (ROC):** A momentum indicator that calculates the rate of price change over a specific period.  
- **Chaikin Money Flow (CMF):** A volume-based indicator measuring the flow of money into and out of an asset.

### **Conditional Logic**
The `long_exit_williams_r` function employs a series of nested `if` statements to evaluate different combinations of indicators and threshold levels. Each condition is designed to capture a specific market scenario that may signal a potential reversal of the bullish trend. If a condition is met, the function returns `True` along with a unique signal name, indicating that an exit order should be executed.

### **Examples of Conditions**
- If `WILLR_480` is greater than `-0.1`, `WILLR_14` is greater than or equal to `-1.0`, and `RSI_14` is greater than `75.0`, the function triggers the exit signal `exit_{mode_name}_w_0_1`.  
- If `RSI_3` is greater than `99.0`, `WILLR_14` is greater than `-1.0`, and both `RSI_3_1h` and `RSI_3_4h` are below `50.0`, the function triggers the exit signal `exit_{mode_name}_w_10_13`.

### **Benefits**
- Using a logic framework based on technical indicators can help automate exit decisions and minimize the emotional impact on trading.
  
### **Limitations**
- It is important to recognize that no technical indicator is perfect. Indicators can generate false signals or miss exit opportunities.  
- The configuration of the indicators and threshold levels must be carefully adjusted to suit specific market conditions and trading goals.

### **Summary**
The `long_exit_williams_r` function uses a combination of technical indicators and complex conditional logic to generate exit signals for long positions. While this function can be a valuable tool for automated traders, it is crucial to understand its limitations and use it alongside other risk management strategies.

---

## long_exit_dec function<a name="long_exit_dec"></a>

The `long_exit_dec` function is part of the source code for an automated trading strategy. This function is used to generate exit signals for long (buy) positions by employing a combination of technical indicators and complex conditional logic.

### General Logic

The `long_exit_dec` function implements a series of nested conditions using `if` and `elif` statements. Each condition evaluates the current market state through technical indicators such as RSI, WILLR, STOCHRSIk, AROONU, ROC, and CMF. These conditions aim to identify moments when the asset's price may be about to reverse its upward trend, signaling a good opportunity to sell and secure profits.

### Exit Signals

Each condition within the `long_exit_dec` function is associated with a specific exit signal, identified by a unique name starting with `exit_{mode_name}_d_`. 

Examples of exit signals within `long_exit_dec` include:  

- **`exit_{mode_name}_d_2_29`:** This signal triggers when RSI_3 is greater than 80.0, RSI_3_1h is less than 25.0, RSI_3_4h is less than 20.0, and STOCHRSIk_14_14_3_3_1h is greater than 30.0.  
- **`exit_{mode_name}_d_10_16`:** This signal activates when RSI_3 is greater than 95.0, AROONU_14_4h is greater than 25.0, ROC_9_4h is less than -25.0, AROONU_14_1d is greater than 50.0, and `change_pct_1d` is less than -15.0.  
- **`exit_{mode_name}_d_12_103`:** This signal triggers when RSI_3 is greater than 98.0, WILLR_14 is greater than -10.0, RSI_3_4h is less than 30.0, ROC_9_4h is less than -80.0, and STOCHRSIk_14_14_3_3_4h is greater than 40.0.  

These exit signals represent different market scenarios. For instance, some conditions focus on divergences between RSI values across various timeframes, while others rely on a combination of overbought indicators with signs of trend weakness.

### Function Context

The `long_exit_dec` function is called within the `custom_exit` function. This general function manages exit logic for various trading modes. The `long_exit_dec` function is specifically used for the "quick" mode. If `long_exit_dec` does not generate a sell signal, other exit functions, such as `long_exit_stoploss`, are evaluated.

### Additional Observations

- The `long_exit_dec` function is not used in isolation. It is integrated into a broader trading strategy that includes other entry and exit functions.  
- The specific configurations of indicators and threshold levels used in the function may vary depending on the trading strategy.  
- The naming of exit signals (e.g., `exit_{mode_name}_d_2_29`) suggests that the code is part of a modular system where different trading "modes" may have their own exit functions.  

### Summary

The `long_exit_dec` function plays a crucial role in identifying exit opportunities for long positions within an automated trading strategy. Its logic, based on a combination of technical indicators and specific conditions, aims to protect profits by anticipating potential reversals in the asset's upward price trend.

---

## long_exit_stoploss function<a name="long_exit_stoploss"></a>

The `long_exit_stoploss` function defines specific conditions to exit a long position when certain stop-loss thresholds are met. It is designed to protect against excessive losses and to ensure that market conditions support the decision to exit the position.

### Key Parameters
1. **`profit_stake`**: The current profit or loss of the position in monetary terms.
2. **`filled_entries`**: A list of completed entries with their associated costs.
3. **`last_candle`, `previous_candle_*`**: Market data for recent candles, used to evaluate conditions.
4. **`trade`**: Information about the current trade, including its opening date and leverage.
5. **`current_time`**: Current time, for calculating trade duration.
6. **`stop_threshold_doom_*`**: Thresholds defining the maximum allowed loss, adjusted for futures or spot trading modes.

### Logic and Conditions

#### 1. **"Stoploss Doom" Condition**
- **Purpose**: Exit immediately if losses exceed a critical threshold.
- **Conditions:**
  - `profit_stake` falls below a defined limit:
    
    \[
    \text{limit} = \text{initial cost} \times \frac{\text{threshold}}{\text{leverage}}
    \]
  - Valid entry conditions are not met (via `has_valid_entry_conditions`).
  - Trade was opened after a specific date (`2024-09-13`) or the function is in backtesting mode.

- **Example Scenario:**
  Suppose an open position shows significant losses, and the leverage amplifies the risk of further downside. The "Stoploss Doom" condition triggers an exit to prevent catastrophic losses.

- **Action:**
  Returns `True` with the reason: `"exit_{mode_name}_stoploss_doom"`.


### Default Return
If none of the conditions are met, the function returns `False` and `None`, indicating that no stop-loss signal has been triggered.

### Summary of Behavior
- The function prioritizes avoiding excessive losses through a critical stop-loss mechanism.
- It integrates checks to ensure the trade’s conditions remain valid and align with predefined thresholds.

This approach minimizes risk exposure and ensures the algorithm adheres to strict loss-management principles.
