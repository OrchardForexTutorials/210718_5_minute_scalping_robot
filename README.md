# 5 Minute Scalping Expert (MT4/MT5)

<!-- START_HEADER -->

Youtube: https://youtu.be/SaA67PUuxpg

For a broker with fast execution and tight spreads sign up to IC Markets using our affiliate link <br>
https://orchardforex.com/ic

<!-- END_HEADER -->

This is a tutorial based on a scalping strategy for 5‑minute charts. The strategy itself is not extraordinary and should be considered a learning example rather than a ready‑to‑trade system; on its own it is likely to be around break‑even or slightly negative over time due to spreads and commissions.

However, it is a good basis for starter development and the code is simple enough to understand.

This strategy combines:
- Two exponential moving averages (200‑period fast and 400‑period slow) as a trend filter  
- Price action to trigger trades (the candle crossing the slow MA)  
- Profit and loss targets based on a percentage of the trigger candle’s size (default 50% for both TP and SL)

The expert advisor is written to compile for both MetaTrader 4 and MetaTrader 5 from a common include file, with only small platform‑specific sections for indicator handling and order execution.

The tutorial walks through the full include‑file code used to implement this strategy, explaining how the trend filter, entry logic, and risk management are coded and how the same logic is shared between MT4 and MT5 with only small platform‑specific differences.
