//+------------------------------------------------------------------+
//|                                                  London Open.mq4 |
//|                                                            Timmy |
//|                            https://www.mql5.com/en/users/thanh01 |
//+------------------------------------------------------------------+
#property copyright "Timmy"
#property link      "https://www.mql5.com/en/users/thanh01"
#property version   "1.00"
#property strict
#property indicator_chart_window


input int   InpLondonOpenHour = 8;
string      gCurrentDay;
string      gNowDay;
MqlDateTime gdtStruct;
int         gLondonOpenBarIdx;
datetime    gLondonOpenTime;
datetime    gLondonCloseTime;
bool        gbHiLoCreated;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    gCurrentDay = "";
    gbHiLoCreated = false;
//---
    return(INIT_SUCCEEDED);
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
    TimeToStruct(time[0], gdtStruct);
    gNowDay = TimeToString(time[0], TIME_DATE);
    if (gNowDay != gCurrentDay && gdtStruct.hour >= InpLondonOpenHour) {
        gCurrentDay = gNowDay;
        gLondonOpenTime = StringToTime(gCurrentDay + " " + IntegerToString(InpLondonOpenHour) + ":00");
        gLondonCloseTime = gLondonOpenTime + 14400;
        gLondonOpenBarIdx = iBarShift(_Symbol, _Period, gLondonOpenTime);
        ObjectCreate("*LondonOpen", OBJ_TREND, 0, 0, 0);
        ObjectSet("*LondonOpen", OBJPROP_RAY, false);
        ObjectSet("*LondonOpen", OBJPROP_BACK, true);
        ObjectSet("*LondonOpen", OBJPROP_COLOR, clrMidnightBlue);
        ObjectSet("*LondonOpen", OBJPROP_STYLE, STYLE_DASH);
        ObjectSet("*LondonOpen", OBJPROP_PRICE1, open[gLondonOpenBarIdx]);
        ObjectSet("*LondonOpen", OBJPROP_PRICE2, open[gLondonOpenBarIdx]);
        ObjectSet("*LondonOpen", OBJPROP_TIME1, gLondonOpenTime);
        ObjectSet("*LondonOpen", OBJPROP_TIME2, gLondonCloseTime);
        gbHiLoCreated = false;
    }
    if (gNowDay == gCurrentDay && gdtStruct.hour >= InpLondonOpenHour + 4 && gbHiLoCreated == false) {
        gbHiLoCreated = true;
        gLondonOpenBarIdx = iBarShift(_Symbol, _Period, gLondonOpenTime);
        double highest = open[gLondonOpenBarIdx];
        double lowest  = open[gLondonOpenBarIdx];
        for (int i = gLondonOpenBarIdx; i >= 0; i--) {
            if (time[i] > gLondonCloseTime) break;
            if (high[i] > highest) {
                highest = high[i];
            }
            if (low[i] < lowest) {
                lowest = low[i];
            }
        }
        // Draw Hi Low
        ObjectCreate("*LondonHi", OBJ_TREND, 0, 0, 0);
        ObjectSet("*LondonHi", OBJPROP_RAY, false);
        ObjectSet("*LondonHi", OBJPROP_BACK, true);
        ObjectSet("*LondonHi", OBJPROP_COLOR, clrDarkGreen);
        ObjectSet("*LondonHi", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet("*LondonHi", OBJPROP_PRICE1, highest);
        ObjectSet("*LondonHi", OBJPROP_PRICE2, highest);
        ObjectSet("*LondonHi", OBJPROP_TIME1, gLondonOpenTime);
        ObjectSet("*LondonHi", OBJPROP_TIME2, gLondonCloseTime);
        ObjectCreate("*LondonLo", OBJ_TREND, 0, 0, 0);
        ObjectSet("*LondonLo", OBJPROP_RAY, false);
        ObjectSet("*LondonLo", OBJPROP_BACK, true);
        ObjectSet("*LondonLo", OBJPROP_COLOR, clrRed);
        ObjectSet("*LondonLo", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet("*LondonLo", OBJPROP_PRICE1, lowest);
        ObjectSet("*LondonLo", OBJPROP_PRICE2, lowest);
        ObjectSet("*LondonLo", OBJPROP_TIME1, gLondonOpenTime);
        ObjectSet("*LondonLo", OBJPROP_TIME2, gLondonCloseTime);
    }
//--- return value of prev_calculated for next call
    return(rates_total);
}
//+------------------------------------------------------------------+
