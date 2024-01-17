//+------------------------------------------------------------------+
//|                                                      TimeBox.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link "https://www.youtube.com/@TimmyTraderHamHoc"
#property version "1.00"
#property strict
#property indicator_chart_window

#define APP_TAG "TimeBox"

input int BeginHour = 7;
input int EndHour = 12;
input color BoxColor = clrSlateGray;


int chartPeriod;
int barBoxCount;
bool chartReady;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    //--- indicator buffers mapping
    chartPeriod = ChartPeriod();
    barBoxCount = (EndHour-BeginHour)*60/chartPeriod;
    chartReady = false;
    return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {
    string objName = "";
    for (int i = ObjectsTotal() - 1; i >= 0; i--) {
        objName = ObjectName(i);
        if (StringFind(objName, APP_TAG) != -1) ObjectDelete(objName);
    }
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime & time[],
                const double & open[],
                const double & high[],
                const double & low[],
                const double & close[],
                const long & tick_volume[],
                const long & volume[],
                const int & spread[]) {
    //---
    chartReady = true;
    //--- return value of prev_calculated for next call
    return (rates_total);
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                const long & lparam,
                const double & dparam,
                const string & sparam) {
    //---
    if (chartReady && chartPeriod <= PERIOD_M15 && id == CHARTEVENT_CHART_CHANGE) {
        int bar = WindowFirstVisibleBar();
        int bars_count = WindowBarsPerChart();

        int hour = 0;
        double hi=0, lo=0;
        int timeBoxIdx = 0;
        int beginBarIdx = 0;
        bool start = false;

        for (int i = 0; i < bars_count && bar > 0; i++, bar--) {
            hour = TimeHour(Time[bar]);
            if (hour >= BeginHour && hour < EndHour){
                if (start == false) {
                    start = true;
                    hi = High[bar];
                    lo = Low[bar];
                    beginBarIdx = bar;
                } else {
                    if (High[bar] > hi) hi = High[bar];
                    if (Low[bar] < lo) lo = Low[bar];
                }
            } else if (hour == EndHour && TimeMinute(Time[bar]) == 0){
                // last sample and draw
                if (High[bar] > hi) hi = High[bar];
                if (Low[bar] < lo) lo = Low[bar];
                drawTimeBox(timeBoxIdx++, beginBarIdx, bar, hi, lo);
                start = false;
            }
        }
        if (start == true){
            // Draw current box
            drawTimeBox(timeBoxIdx++, beginBarIdx, bar, hi, lo);
        }
        string objName;
        do {
            objName = APP_TAG + "1" + IntegerToString(timeBoxIdx);
            ObjectSet(objName, OBJPROP_TIME1, 0);
            ObjectSet(objName, OBJPROP_TIME2, 0);

            objName = APP_TAG + "2" + IntegerToString(timeBoxIdx);
            ObjectSet(objName, OBJPROP_TIME1, 0);
            ObjectSet(objName, OBJPROP_TIME2, 0);
            
            objName = APP_TAG + "3" + IntegerToString(timeBoxIdx);
            ObjectSet(objName, OBJPROP_TIME1, 0);
            ObjectSet(objName, OBJPROP_TIME2, 0);
            
            objName = APP_TAG + "4" + IntegerToString(timeBoxIdx++);
            ObjectSet(objName, OBJPROP_TIME2, 0);
            ObjectSet(objName, OBJPROP_TIME1, 0);
        } while (ObjectFind(objName) >= 0);
    }
}
//+------------------------------------------------------------------+

void drawTimeBox(int index, int beginBarIdx, int endBarIdx, double hi, double lo){
    string objName1 = APP_TAG + "1" + IntegerToString(index);
    string objName2 = APP_TAG + "2" + IntegerToString(index);
    string objName3 = APP_TAG + "3" + IntegerToString(index);
    string objName4 = APP_TAG + "4" + IntegerToString(index);
    if (ObjectFind(objName1) < 0) {
        ObjectCreate(objName1, OBJ_TREND, 0, 0, 0);
        ObjectCreate(objName2, OBJ_TREND, 0, 0, 0);
        ObjectCreate(objName3, OBJ_TREND, 0, 0, 0);
        ObjectCreate(objName4, OBJ_TREND, 0, 0, 0);
        ObjectSet(objName1, OBJPROP_BACK, true);
        ObjectSet(objName2, OBJPROP_BACK, true);
        ObjectSet(objName3, OBJPROP_BACK, true);
        ObjectSet(objName4, OBJPROP_BACK, true);

        ObjectSet(objName1, OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(objName2, OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(objName3, OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(objName4, OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(objName1, OBJPROP_WIDTH, 0);
        ObjectSet(objName2, OBJPROP_WIDTH, 0);
        ObjectSet(objName3, OBJPROP_WIDTH, 0);
        ObjectSet(objName4, OBJPROP_WIDTH, 0);
        ObjectSet(objName1, OBJPROP_SELECTABLE, false);
        ObjectSet(objName2, OBJPROP_SELECTABLE, false);
        ObjectSet(objName3, OBJPROP_SELECTABLE, false);
        ObjectSet(objName4, OBJPROP_SELECTABLE, false);
        ObjectSetString(ChartID(), objName1, OBJPROP_TOOLTIP, "\n");
        ObjectSetString(ChartID(), objName2, OBJPROP_TOOLTIP, "\n");
        ObjectSetString(ChartID(), objName3, OBJPROP_TOOLTIP, "\n");
        ObjectSetString(ChartID(), objName4, OBJPROP_TOOLTIP, "\n");
        ObjectSetInteger(ChartID(), objName1, OBJPROP_HIDDEN, true);
        ObjectSetInteger(ChartID(), objName2, OBJPROP_HIDDEN, true);
        ObjectSetInteger(ChartID(), objName3, OBJPROP_HIDDEN, true);
        ObjectSetInteger(ChartID(), objName4, OBJPROP_HIDDEN, true);
        ObjectSet(objName1, OBJPROP_RAY, false);
        ObjectSet(objName2, OBJPROP_RAY, false);
        ObjectSet(objName3, OBJPROP_RAY, false);
        ObjectSet(objName4, OBJPROP_RAY, false);
        ObjectSet(objName1, OBJPROP_COLOR, BoxColor);
        ObjectSet(objName2, OBJPROP_COLOR, BoxColor);
        ObjectSet(objName3, OBJPROP_COLOR, BoxColor);
        ObjectSet(objName4, OBJPROP_COLOR, BoxColor);
    }
    ObjectSet(objName1, OBJPROP_PRICE1, hi);
    ObjectSet(objName1, OBJPROP_PRICE2, hi);
    ObjectSet(objName1, OBJPROP_TIME1, Time[beginBarIdx]);
    ObjectSet(objName1, OBJPROP_TIME2, Time[endBarIdx]);

    ObjectSet(objName2, OBJPROP_PRICE1, hi);
    ObjectSet(objName2, OBJPROP_PRICE2, lo);
    ObjectSet(objName2, OBJPROP_TIME1, Time[endBarIdx]);
    ObjectSet(objName2, OBJPROP_TIME2, Time[endBarIdx]);

    ObjectSet(objName3, OBJPROP_PRICE1, lo);
    ObjectSet(objName3, OBJPROP_PRICE2, lo);
    ObjectSet(objName3, OBJPROP_TIME1, Time[beginBarIdx]);
    ObjectSet(objName3, OBJPROP_TIME2, Time[endBarIdx]);

    ObjectSet(objName4, OBJPROP_PRICE1, hi);
    ObjectSet(objName4, OBJPROP_PRICE2, lo);
    ObjectSet(objName4, OBJPROP_TIME1, Time[beginBarIdx]);
    ObjectSet(objName4, OBJPROP_TIME2, Time[beginBarIdx]);
}