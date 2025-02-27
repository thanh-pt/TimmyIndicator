#property copyright "aForexStory Wiki"
#property link      "https://aforexstory.notion.site/aa613be6d2fc4c5a84722fe629d5b3c4"
#property icon      "../3.Resource/icons/a-Forex-Story.ico"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define APP_TAG "*dailyBox"
#include "../3.Resource/DrawLib.mqh"


enum eBoxType
{
    eLineBox,   // Line Box
    eBgBox,     // Background Box
};

input eBoxType          InpBoxType      = eLineBox;     // Box Type
input ENUM_LINE_STYLE   InpLineStyle    = STYLE_SOLID;  //Line Style:

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
    // if (gTotalRate == 0) return;
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
    int lastBar = gFirstBar - WindowBarsPerChart();
    if (lastBar < 0) lastBar = 0;
    drawBox(gFirstBar, lastBar, (ChartPeriod() >= PERIOD_H4) ? PERIOD_W1 : PERIOD_D1);
    drawLibEnd();
}

void drawBox(int firstBar, int lastBar, int period){
    int barIdx = iBarShift(gSymbol, period, Time[firstBar], true);
    datetime dtBegin = iTime(gSymbol, period, barIdx);
    datetime dtEnd   = dtBegin + period*60;
    color c;
    while (dtEnd < Time[lastBar]){
        c = iOpen(gSymbol, period, barIdx) < iClose(gSymbol, period, barIdx) ? clrAliceBlue : clrLavenderBlush;
        if (InpBoxType == eLineBox) {
            createBox(dtBegin, dtEnd, iHigh(gSymbol, period, barIdx), iLow(gSymbol, period, barIdx), c);
        }
        else {
            drawRect(dtBegin, dtEnd, iHigh(gSymbol, period, barIdx), iLow(gSymbol, period, barIdx), c);
        }
        // Next day!
        dtBegin = dtEnd;
        dtEnd   += period * 60;
        barIdx = iBarShift(gSymbol, period, dtBegin, true);
    }
}

void createBox(datetime time1, datetime time2, double price1, double price2, color c){
    drawLine(time1, time1, price1, price2, c, InpLineStyle);
    drawLine(time2, time2, price1, price2, c, InpLineStyle);
    drawLine(time1, time2, price1, price1, c, InpLineStyle);
    drawLine(time1, time2, price2, price2, c, InpLineStyle);
}
