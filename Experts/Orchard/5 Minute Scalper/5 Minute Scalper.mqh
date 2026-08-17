/*
	5 Minute Scalper.mqh
	Copyright 2021, Orchard Forex
	https://www.orchardforex.com

	*/

#property copyright "Copyright 2021, Orchard Forex"
#property link      "https://www.orchardforex.com"
#property version   "1.00"
#property strict

//	Fast MA inputs
input	int						InpFastPeriods			=	200;				//	Fast MA periods
input	ENUM_MA_METHOD			InpFastMethod			=	MODE_EMA;		//	Fast MA Method
input	ENUM_APPLIED_PRICE	InpFastAppliedPrice	=	PRICE_CLOSE;	//	Fast MA Price

//	Slow MA inputs
input	int						InpSlowPeriods			=	400;				//	Slow MA periods
input	ENUM_MA_METHOD			InpSlowMethod			=	MODE_EMA;		//	Slow MA Method
input	ENUM_APPLIED_PRICE	InpSlowAppliedPrice	=	PRICE_CLOSE;	//	Slow MA Price

//	TP/SL/Candle settings
input	int						InpMinCandlePoints	=	20;				//	Minimum trigger candle size in points
input	int						InpTPPercent			=	50;				//	TP as % of trigger candle size
input	int						InpSLPercent			=	50;				//	SL as % of trigger candle size

//	Standard things
input	double					InpLots					=	0.01;				//	Trade lot size
input	string					InpTradeComment		=	__FILE__;		//	Trade comment
input int						InpMagicNumber			=	212121;			//	Magic Number

double							MinCandleSize;

#ifdef __MQL5__

	#include <Trade/Trade.mqh>
	CTrade			Trade;
	CPositionInfo	PositionInfo;

	int							HandleFast;
	int							HandleSlow;
	double						BufferFast[];
	double						BufferSlow[];

#endif 

int OnInit() {

	MinCandleSize	=	InpMinCandlePoints*Point();

   return(CustomInit());
}

void OnDeinit(const int reason) {


}

void OnTick() {

	//	Just exit if trading is not allowed
	if (!(bool)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))	return;
	
	//	Once per bar
	if (!NewBar())	return;
	
	//	Also exit if there is already a trade open
	if (TradeCount()>0)		return;
	
	//	Get the indicator values

	double	fastMa	=	0;
	double	slowMa	=	0;
	GetMA(fastMa, slowMa);	

	double	close2	=	iClose(Symbol(), Period(), 2);
	double	close1	=	iClose(Symbol(), Period(), 1);
	double	candleSize	=	iHigh(Symbol(), Period(), 1)-iLow(Symbol(), Period(), 1);
	
	double	tpSize;
	double	slSize;
	double	tpPrice;
	double	slPrice;
	double	openPrice;
	
	//	Buy condition
	if (fastMa>slowMa && close1>slowMa && close2<slowMa && candleSize>=MinCandleSize) {
		tpSize	=	candleSize * InpTPPercent / 100;
		slSize	=	candleSize * InpSLPercent / 100;
		openPrice	=	SymbolInfoDouble(Symbol(), SYMBOL_ASK);
		tpPrice		=	NormalizeDouble(openPrice + tpSize, Digits());
		slPrice		=	NormalizeDouble(openPrice - slSize, Digits());
		OpenTrade(ORDER_TYPE_BUY, openPrice, slPrice, tpPrice);
	}
	
	if (fastMa<slowMa && close1<slowMa && close2>slowMa && candleSize>=MinCandleSize) {
		tpSize	=	candleSize * InpTPPercent / 100;
		slSize	=	candleSize * InpSLPercent / 100;
		openPrice	=	SymbolInfoDouble(Symbol(), SYMBOL_BID);
		tpPrice		=	NormalizeDouble(openPrice - tpSize, Digits());
		slPrice		=	NormalizeDouble(openPrice + slSize, Digits());
		OpenTrade(ORDER_TYPE_SELL, openPrice, slPrice, tpPrice);
	}
	
}

bool	NewBar() {

	datetime				now		=	iTime(Symbol(), Period(), 0);
	static datetime	prevTime	=	now;
	if (prevTime==now)	return(false);
	prevTime	=	now;
	return(true);
	
}

#ifdef __MQL5__

	int	CustomInit() {

		Trade.SetExpertMagicNumber(InpMagicNumber);
		
		HandleFast		=	iMA(Symbol(), Period(), InpFastPeriods, 0, InpFastMethod, InpFastAppliedPrice);
		if (HandleFast==INVALID_HANDLE)	return(INIT_FAILED);
		
		HandleSlow		=	iMA(Symbol(), Period(), InpSlowPeriods, 0, InpSlowMethod, InpSlowAppliedPrice);
		if (HandleSlow==INVALID_HANDLE)	return(INIT_FAILED);
	
		ArraySetAsSeries(BufferFast, true);
		ArraySetAsSeries(BufferSlow, true);
		return(INIT_SUCCEEDED);
		
	}
	
	void	GetMA(double &fastMa, double &slowMa) {
		CopyBuffer(HandleFast, 0, 0, 1, BufferFast);
		CopyBuffer(HandleSlow, 0, 0, 1, BufferSlow);
		fastMa	=	BufferFast[0];
		slowMa	=	BufferSlow[0];
		return;
	}
	
	void	OpenTrade(int type, double openPrice, double slPrice, double tpPrice) {
		Trade.PositionOpen(Symbol(), (ENUM_ORDER_TYPE)type, InpLots, openPrice, slPrice, tpPrice, InpTradeComment);
	}
	
	int	TradeCount() {
	
		int	tradeCount	=	0;
		int	count			=	PositionsTotal();
		for (int i=0; i<count; i++) {
			if (!PositionInfo.SelectByIndex(i)) continue;
			if (PositionInfo.Symbol()!=Symbol() || PositionInfo.Magic()!=InpMagicNumber) continue;
			tradeCount++;
		}
		return(tradeCount);
		
	}

#endif 

#ifdef __MQL4__

	int	CustomInit() {
		return(INIT_SUCCEEDED);
	}
	
	void	GetMA(double &fastMa, double &slowMa) {
		fastMa	=	iMA(Symbol(), Period(), InpFastPeriods, 0, InpFastMethod, InpFastAppliedPrice, 0);
		slowMa	=	iMA(Symbol(), Period(), InpSlowPeriods, 0, InpSlowMethod, InpSlowAppliedPrice, 0);
		return;
	}

	void	OpenTrade(int type, double openPrice, double slPrice, double tpPrice) {
		if (OrderSend(Symbol(), type, InpLots, openPrice, 0, slPrice, tpPrice, InpTradeComment, InpMagicNumber)) {}
	}

	int	TradeCount() {
	
		int	tradeCount	=	0;
		int	count			=	OrdersTotal();
		for (int i=0; i<count; i++) {
			if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
			if (OrderSymbol()!=Symbol() || OrderMagicNumber()!=InpMagicNumber)	continue;
			tradeCount++;
		}
		return(tradeCount);
		
	}

#endif


