//+------------------------------------------------------------------+
//|                                        Imbalance Highlighter.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link "https://www.youtube.com/@TimmyTraderHamHoc"
#property version "1.00"
#property strict
#property indicator_chart_window

#define APP_TAG "ImbHighter"
//--- input parameters
input color ImbDownColor = C'245,207,194';
input color ImbUpColor = C'207,226,205';
//--- Indi variable
int gLastVisibleBar = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    //--- indicator buffers mapping

    //---
    return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {
    for (int i = ObjectsTotal() - 1; i >= 0; i--) {
        string objName = ObjectName(i);
        if (StringFind(objName, APP_TAG) != -1) ObjectDelete(objName);
    }
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
    return (rates_total);
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if (id == CHARTEVENT_CHART_CHANGE) {
        int bars_count = WindowBarsPerChart();
        int bar = WindowFirstVisibleBar()-1;
        if (MathAbs(gLastVisibleBar - bar) > 10) {
            gLastVisibleBar = bar;
            int imbIdx = 0;
            string objName;
            bool hasImbUp, hasImbDown;
            double p1=0, p2=0;

            for (int i = 0; i < bars_count && bar > 0; i++, bar--) {
                hasImbUp = false;
                hasImbDown = false;
                if (High[bar+1] < Low[bar-1]) {
                    hasImbUp = true;
                    p1 = High[bar+1];
                    p2 = Low[bar-1];
                } else if (Low[bar+1] > High[bar-1]) {
                    hasImbDown = true;
                    p1 = Low[bar+1];
                    p2 = High[bar-1];
                }

                if (hasImbUp || hasImbDown) {
                    objName = APP_TAG + IntegerToString(imbIdx);
                    if (ObjectFind(objName) < 0) {
                        ObjectCreate(objName, OBJ_RECTANGLE , 0, 0, 0);
                        ObjectSet(objName, OBJPROP_SELECTABLE, false);
                        ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
                        ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
                    }
                    ObjectSet(objName, OBJPROP_TIME1, Time[bar]);
                    ObjectSet(objName, OBJPROP_TIME2, Time[bar-1]);
                    ObjectSet(objName, OBJPROP_PRICE1, p1);
                    ObjectSet(objName, OBJPROP_PRICE2, p2);
                    ObjectSet(objName, OBJPROP_COLOR, hasImbUp ? ImbUpColor : ImbDownColor);
                    imbIdx++;
                }
            }
            do {
                objName  = APP_TAG + IntegerToString(imbIdx);
                imbIdx++;
                ObjectSet(objName, OBJPROP_TIME1, 0);
                ObjectSet(objName, OBJPROP_TIME2, 0);
            } while (ObjectFind(objName) >= 0);
        }
    }
}
//+------------------------------------------------------------------+