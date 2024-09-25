#property copyright "Chuot Forex"
#property link      "https://chuot-fx.blogspot.com/"
#property icon      "../3.Resource/Chuột.ico"
#property version   "2.00"
#property description "Support me on Exness my IB: kzhhe6qy44"
#property strict
#property indicator_chart_window

#include "../3.Resource/DrawLib.mqh"
#define APP_TAG "dailyBox"

int          gChartPeriod = ChartPeriod();
string       gSymbol      = Symbol();
int          gTotalRate = 0;

int          gFirstBar;
int          gPreFirstDay=0;

datetime     gDateTime;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
//---
    return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {
    for (int i = ObjectsTotal() - 1; i >= 0; i--) {
        string objName = ObjectName(i);
        if (StringFind(objName, APP_TAG) != -1) ObjectDelete(objName);
    }
    gTotalRate = 0;
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
    if (gTotalRate != rates_total) {
        scanWindow();
    }
    gTotalRate = rates_total;
//--- return value of prev_calculated for next call
    return(rates_total);
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
//---
    if (gTotalRate == 0) return;
    if (id == CHARTEVENT_CHART_CHANGE) {
        gFirstBar = WindowFirstVisibleBar();
        if (gFirstBar <= 0) return;
        if (gPreFirstDay != TimeDay(Time[gFirstBar])) {
            gPreFirstDay = TimeDay(Time[gFirstBar]);
            scanWindow();
        }
    }
    else if (id == CHARTEVENT_OBJECT_DELETE){
        if (StringFind(sparam, APP_TAG) != -1) gPreFirstDay = 0;
    }
}
//+------------------------------------------------------------------+

void scanWindow(){
    if (ChartPeriod() > PERIOD_H4) return;
    // First bar Datetime
    int lastBar = gFirstBar - WindowBarsPerChart();
    gDateTime = Time[gFirstBar];
    if (lastBar < 0) lastBar = 0;
    int dailyBarIdx = 0;
    while (gDateTime < Time[lastBar]){
        dailyBarIdx = iBarShift(gSymbol, 1440, gDateTime, true);
        if (dailyBarIdx > 0 && TimeDayOfWeek(gDateTime) != 0) {
            gDateTime = iTime(gSymbol, 1440, dailyBarIdx);
            createBox(gDateTime, gDateTime+86400, iHigh(gSymbol,1440, dailyBarIdx), iLow(gSymbol,1440, dailyBarIdx));
        }
        // Next day!
        gDateTime += 86400;
    }

    drawLibEnd();
}

void createBox(datetime time1, datetime time2, double price1, double price2){
    // drawRect(time1, time2, price1, price2, clrWhiteSmoke);
    drawLine(time1, time1, price1, price2, clrBlack);
    drawLine(time2, time2, price1, price2, clrBlack);
    drawLine(time1, time2, price1, price1, clrBlack);
    drawLine(time1, time2, price2, price2, clrBlack);
}