//+------------------------------------------------------------------+
//|                                                  HiLo Simple.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define APP_TAG "HiLoSimple"

input string HiPivotCharecter = "•";
input color  HiPivotColor     = clrBlack;
input string LoPivotCharecter = "•";
input color  LoPivotColor     = clrBlack;
input int HiLoPivotSize = 9;
input int VisibilityChartScale = 2;

//---
long gChartScale = 0;
bool gInitCalculation = false;


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
    loadPivotDrawing();
    gInitCalculation = true;

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
    if (gInitCalculation == false) return;
    if (id == CHARTEVENT_CHART_CHANGE) loadPivotDrawing();
}
//+------------------------------------------------------------------+

void loadPivotDrawing(){
    ChartGetInteger(ChartID(), CHART_SCALE, 0, gChartScale);
    int bars_count=WindowBarsPerChart();
    int bar=WindowFirstVisibleBar();
    int pIdx = 0;
    string objName;
    if (gChartScale >= VisibilityChartScale) {
        for(int i=0; i<bars_count && bar>0; i++,bar--) {
            if (High[bar] > High[bar+1] && High[bar] > High[bar-1]){
                objName = APP_TAG + IntegerToString(pIdx++);
                pivotConfig(objName, true, Time[bar], High[bar]);
            }
            if (Low[bar] < Low[bar+1] && Low[bar] < Low[bar-1]){
                objName = APP_TAG + IntegerToString(pIdx++);
                pivotConfig(objName, false, Time[bar], Low[bar]);
            }
        }
    }
    do {
        objName  = APP_TAG + IntegerToString(pIdx++);
        ObjectSet(objName, OBJPROP_TIME1, 0);
    } while (ObjectFind(objName) >= 0);
}

void pivotConfig(const string& objName, bool isHi, const datetime& time, const double& price){
    if (ObjectFind(objName) < 0) {
        ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
        ObjectSet(objName, OBJPROP_BACK, false);
        ObjectSet(objName, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
    }
    ObjectSetText(objName, isHi ? HiPivotCharecter : LoPivotCharecter, HiLoPivotSize, NULL, isHi ? HiPivotColor : LoPivotColor);
    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, DoubleToString(price, 5));
    ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR, isHi ? ANCHOR_LOWER : ANCHOR_UPPER);
    ObjectSet(objName, OBJPROP_TIME1, time);
    ObjectSet(objName, OBJPROP_PRICE1, price);
}