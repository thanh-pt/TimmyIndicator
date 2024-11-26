//+------------------------------------------------------------------+
//|                                              Mini Price Line.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window


string objBid = "*MiniPriceLineBid";
string objAsk = "*MiniPriceLineAsk";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    ObjectCreate(objAsk, OBJ_TREND, 0, 0, 0);
    ObjectCreate(objBid, OBJ_TREND, 0, 0, 0);
    ObjectSet(objBid, OBJPROP_BACK, true);
    ObjectSet(objBid, OBJPROP_SELECTABLE, false);
    ObjectSet(objBid, OBJPROP_RAY, true);
    ObjectSet(objBid, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet(objBid, OBJPROP_WIDTH, 0);
    ObjectSet(objBid, OBJPROP_COLOR, clrLightGray);
    ObjectSetString(0, objBid, OBJPROP_TOOLTIP, "\n");
    
    ObjectSet(objAsk, OBJPROP_BACK, true);
    ObjectSet(objAsk, OBJPROP_SELECTABLE, false);
    ObjectSet(objAsk, OBJPROP_RAY, true);
    ObjectSet(objAsk, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet(objAsk, OBJPROP_WIDTH, 0);
    ObjectSet(objAsk, OBJPROP_COLOR, clrRed);
    ObjectSetString(0, objAsk, OBJPROP_TOOLTIP, "\n");

//---
    ChartSetInteger(0, CHART_SHOW_ASK_LINE, false);
    ChartSetInteger(0, CHART_SHOW_BID_LINE, false);
    return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
    ChartSetInteger(0, CHART_SHOW_ASK_LINE, true);
    ChartSetInteger(0, CHART_SHOW_BID_LINE, true);
    ObjectDelete(objBid);
    ObjectDelete(objAsk);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
//--- return value of prev_calculated for next call
    ObjectSet(objBid, OBJPROP_PRICE1, Bid);
    ObjectSet(objBid, OBJPROP_PRICE2, Bid);
    ObjectSet(objBid, OBJPROP_TIME1, time[0]);
    ObjectSet(objBid, OBJPROP_TIME2, time[0] + Period()*300);
    
    ObjectSet(objAsk, OBJPROP_PRICE1, Ask);
    ObjectSet(objAsk, OBJPROP_PRICE2, Ask);
    ObjectSet(objAsk, OBJPROP_TIME1, time[0]);
    ObjectSet(objAsk, OBJPROP_TIME2, time[0] + Period()*300);
    return(rates_total);
}
//+------------------------------------------------------------------+
