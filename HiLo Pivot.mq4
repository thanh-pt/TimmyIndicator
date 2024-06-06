//+------------------------------------------------------------------+
//|                                                  HiLo Pivot.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define APP_TAG "HiLoSimple"


enum EQueryBar {
    E_3BAR, // 3 bars
    E_5BAR, // 5 bars
    E_4BAR, // 4 bars
};

input string    CommomConfig;                   // - - - C O M M O N   C O N F I G - - -
input int       InpChartScaleDisplay    = 2;    // →    Scale Visibility:
input string    InpOnOffHotkey          = "K";  // →    On/Off Hotkey:
input string _pivot;                            // - - - P I V O T - - -
input int    InpPivotSize       = 9;            // Size:
input string InpPivotCharecter  = "•";          // Charecter:
input color  InpHiPivotColor    = clrBlack;     // Color Hi:
input color  InpLoPivotColor    = clrBlack;     // Color Lo:
input string _small;                            // - - - S M A L L - - -
input int    InpSmallSize       = 6;            // Size:
input string InpSmallCharecter  = "×";          // Charecter:
input color  InpHiSmallColor    = clrBlack;     // Color Hi:
input color  InpLoSmallColor    = clrBlack;     // Color Lo:


//---
long gChartScale = 0;
bool gInitCalculation = false;
bool gOnState = true;

string gHiPivotCh;
string gLoPivotCh;
string gHiSmallCh;
string gLoSmallCh;

string getSubStr(string str, int start, int len)
{
    string result = "";
    result = StringSubstr(str, start, len);
    if (result == "") return StringSubstr(str, 0, len);
    
    return result;
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    gHiPivotCh = getSubStr(InpPivotCharecter, 0, 1);
    gLoPivotCh = getSubStr(InpPivotCharecter, 1, 1);
    gHiSmallCh = getSubStr(InpSmallCharecter, 0, 1);
    gLoSmallCh = getSubStr(InpSmallCharecter, 1, 1);

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
    else if (id == CHARTEVENT_KEYDOWN && lparam == InpOnOffHotkey[0]) {
        gOnState = !gOnState;
        loadPivotDrawing();
    }
}
//+------------------------------------------------------------------+

void loadPivotDrawing(){
    int pIdx = 0;
    if (gOnState == false) {
        while(hidePivot(pIdx++) == true){}
        return;
    }
    ChartGetInteger(ChartID(), CHART_SCALE, 0, gChartScale);
    int bars_count=WindowBarsPerChart();
    int bar=WindowFirstVisibleBar()-2;
    if (gChartScale >= InpChartScaleDisplay) {
        for(int i=0; i<bars_count && bar>=0; i++,bar--) {
            if ((Low[bar] < Low[bar+1] || (Low[bar] == Low[bar+1] && Low[bar] < Low[bar+2])) // Compare với bar trước đó
                && Low[bar] < Low[bar-1]){
                if (Low[bar-1] < Low[bar-2] || (bar-3 > 0 && Low[bar-1] == Low[bar-2] && Low[bar-2] < Low[bar-3])){
                    drawPivot(pIdx++, gLoPivotCh, InpPivotSize, InpLoPivotColor, ANCHOR_UPPER, Time[bar], Low[bar]);
                }
                else if (InpSmallSize!= 0){
                    drawPivot(pIdx++, gLoSmallCh, InpSmallSize, InpLoSmallColor, ANCHOR_UPPER, Time[bar], Low[bar]);
                }
            }
            if ((High[bar] > High[bar+1] || (High[bar] == High[bar+1] && High[bar] > High[bar+2])) // Compare với bar trước đó
                && High[bar] > High[bar-1]){
                if (High[bar-1] > High[bar-2] || (bar-3 > 0 && High[bar-1] == High[bar-2] && High[bar-2] > High[bar-3])){
                    drawPivot(pIdx++, gHiPivotCh, InpPivotSize, InpHiPivotColor, ANCHOR_LOWER, Time[bar], High[bar]);
                } 
                else if (InpSmallSize!= 0){
                    drawPivot(pIdx++, gHiSmallCh, InpSmallSize, InpHiSmallColor, ANCHOR_LOWER, Time[bar], High[bar]);
                }
            }
            if (bar == 3) break;
        }
    }
    while(hidePivot(pIdx++) == true){}
}

void drawPivot(int index, string _text, int _size, color _color, int _anchor, const datetime& time, const double& price){
    string objName = APP_TAG + IntegerToString(index);
    if (ObjectFind(objName) < 0) {
        ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
        ObjectSet(objName, OBJPROP_BACK, false);
        ObjectSet(objName, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
    }
    ObjectSetText(objName, _text, _size, NULL, _color);
    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, DoubleToString(price, 5));
    ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR, _anchor);
    ObjectSet(objName, OBJPROP_TIME1, time);
    ObjectSet(objName, OBJPROP_PRICE1, price);
}

bool hidePivot(int index){
    string objName = APP_TAG + IntegerToString(index);
    ObjectSet(objName, OBJPROP_TIME1, 0);
    return (ObjectFind(objName) >= 0);
}
