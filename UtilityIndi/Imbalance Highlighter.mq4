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

#define DISPLAY_ON  "[Indi] Imb Highlighter - ON"
#define DISPLAY_OFF "[Indi] Imb Highlighter - OFF"
//--- input parameters
input color ImbDownColor = C'255,200,200';
input color ImbUpColor = C'209,225,237';
// input string _ControlConfig; // Lúc nào conflic thì tính tiếp
//--- Indi variable
int gLastVisibleBar = 0;

// Component
string sBtnDisplaySetting;
// State
string gdisplayState = DISPLAY_OFF;
bool gDeinitState = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    //--- indicator buffers mapping
    sBtnDisplaySetting = APP_TAG + "Control" + "btnDisplaySetting";
    CreateIndiObjects();
    //---
    return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {
    gDeinitState = true;
    for (int i = ObjectsTotal() - 1; i >= 0; i--) {
        string objName = ObjectName(i);
        if (StringFind(objName, APP_TAG) != -1) ObjectDelete(objName);
    }
}
void CreateIndiObjects(){
    if (ObjectFind(sBtnDisplaySetting) < 0){
        ObjectCreate(sBtnDisplaySetting, OBJ_LABEL, 0, 0, 0);
        ObjectSetString(ChartID(), sBtnDisplaySetting, OBJPROP_TOOLTIP, "\n");
        ObjectSet(sBtnDisplaySetting, OBJPROP_SELECTABLE, false);
        ObjectSet(sBtnDisplaySetting, OBJPROP_XDISTANCE, 5);
        ObjectSet(sBtnDisplaySetting, OBJPROP_YDISTANCE, 15);
        long foregroundColor=clrBlack;
        ChartGetInteger(ChartID(),CHART_COLOR_FOREGROUND,0,foregroundColor);
        ObjectSetText(sBtnDisplaySetting, gdisplayState, 8, "Calibri", (color)foregroundColor);
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
    if (id == CHARTEVENT_CHART_CHANGE && gdisplayState == DISPLAY_ON) {
        loadImbFunction();
    } else if (id == CHARTEVENT_OBJECT_CLICK){
        if (sparam == sBtnDisplaySetting){
            if (gdisplayState == DISPLAY_ON) {
                gdisplayState = DISPLAY_OFF;
                // Hide all item;
                int imbIdx = 0;
                string objName;
                do {
                    objName  = APP_TAG + IntegerToString(imbIdx++);
                    ObjectSet(objName, OBJPROP_TIME1, 0);
                    ObjectSet(objName, OBJPROP_TIME2, 0);
                } while (ObjectFind(objName) >= 0);
                gLastVisibleBar = 0;
            } else {
                gdisplayState = DISPLAY_ON;
                loadImbFunction();
            }
            ObjectSetText(sBtnDisplaySetting, gdisplayState);
        }
    } else if (id == CHARTEVENT_OBJECT_DELETE && gDeinitState != true){
        if (StringFind(sparam, APP_TAG + "Control") == -1) return;
        CreateIndiObjects();
    }
}
//+------------------------------------------------------------------+

void loadImbFunction(){
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
            objName  = APP_TAG + IntegerToString(imbIdx++);
            ObjectSet(objName, OBJPROP_TIME1, 0);
            ObjectSet(objName, OBJPROP_TIME2, 0);
        } while (ObjectFind(objName) >= 0);
    }
}
