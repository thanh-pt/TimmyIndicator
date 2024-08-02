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

input string    CommomConfig;                   // - - - C O M M O N   C O N F I G - - -
input int       InpChartScaleDisplay    = 2;    // →    Scale Visibility:
input string    InpOnOffHotkey          = "K";  // →    On/Off Hotkey:
input string _st;                           // - - - S T R O N G   P I V O T - - -
input int    InpStSize      = 11;           // Size:
input string InpStSymbol    = "•";          // Symbol:
input color  InpStClr       = clrBlack;     // Color:
input string _wk;                           // - - - W E A K   P I V O T - - -
input int    InpWkSize      = 6;            // Size:
input string InpWkSymbol    = "×";          // Symbol:
input color  InpWkClr       = clrDarkGray;  // Color:

int InpPreQuery = 5;


//---
long gChartScale = 0;
int  gTotalRate = 0;
bool gOnState = true;



bool isHigherNext(int index){
    int query = 1;
    while (true){
        if (index < query) return false;
        if (High[index] > High[index-query]) return true;
        else if (High[index] < High[index-query]) return false;
        query++;
        if (query >= InpPreQuery) return false;
    }

    return false;
}

bool isLowerNext(int index){
    int query = 1;
    while (true){
        if (index < query) return false;
        if (Low[index] < Low[index-query]) return true;
        else if (Low[index] > Low[index-query]) return false;
        query++;
        if (query >= InpPreQuery) return false;
    }

    return false;
}

bool isHigherPrevious(int index){
    int query = 1;
    while (true){
        if (High[index] > High[index+query]) return true;
        else if (High[index] < High[index+query]) return false;
        query++;
        if (query >= InpPreQuery) return false;
    }

    return false;
}

bool isLowerPrevious(int index){
    int query = 1;
    while (true){
        if (Low[index] < Low[index+query]) return true;
        else if (Low[index] > Low[index+query]) return false;
        query++;
        if (query >= InpPreQuery) return false;
    }

    return false;
}

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
    if (gTotalRate != rates_total) {
        loadPivotDrawing();
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
    if (id == CHARTEVENT_CHART_CHANGE) loadPivotDrawing();
    else if (id == CHARTEVENT_KEYDOWN && lparam == InpOnOffHotkey[0]) {
        gOnState = !gOnState;
        loadPivotDrawing();
    }
}
//+------------------------------------------------------------------+

void loadPivotDrawing()
{
    int pIdx = 0;
    if (gOnState == false) {
        while(hidePivot(pIdx++) == true){}
        return;
    }
    ChartGetInteger(0, CHART_SCALE, 0, gChartScale);
    int bars_count=WindowBarsPerChart();
    int bar=WindowFirstVisibleBar()-2;
    if (gChartScale >= InpChartScaleDisplay) {
        for(int i=0; i<bars_count && bar>=0; i++,bar--) {
            if (Low[bar] < Low[bar-1] && isLowerPrevious(bar)){
                if (isLowerNext(bar-1) && High[bar-1] > High[bar]){
                    drawPivot(pIdx++, InpStSymbol, InpStSize, InpStClr, ANCHOR_UPPER, Time[bar], Low[bar]);
                }
                else if (Low[bar] < Low[bar-2] && InpWkSize!= 0){
                    drawPivot(pIdx++, InpWkSymbol, InpWkSize, InpWkClr, ANCHOR_UPPER, Time[bar], Low[bar]);
                }
            }
            if (High[bar] > High[bar-1] && isHigherPrevious(bar)) {
                if (isHigherNext(bar-1) && Low[bar-1] < Low[bar]){
                    drawPivot(pIdx++, InpStSymbol, InpStSize, InpStClr, ANCHOR_LOWER, Time[bar], High[bar]);
                }
                else if (High[bar] > High[bar-2] && InpWkSize!= 0){
                    drawPivot(pIdx++, InpWkSymbol, InpWkSize, InpWkClr, ANCHOR_LOWER, Time[bar], High[bar]);
                }
            }
            if (bar == 3) break;
        }
    }
    while(hidePivot(pIdx++) == true){}
}

void drawPivot(int index, string _text, int _size, color _color, int _anchor, const datetime& time, const double& price)
{
    string objName = APP_TAG + IntegerToString(index);
    if (ObjectFind(objName) < 0) {
        ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
        ObjectSet(objName, OBJPROP_BACK, false);
        ObjectSet(objName, OBJPROP_SELECTABLE, false);
        ObjectSet(objName, OBJPROP_HIDDEN, true);
    }
    ObjectSetText(objName, _text, _size, NULL, _color);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, IntegerToString((int)(price*100000)%100));
    ObjectSet(objName, OBJPROP_ANCHOR, _anchor);
    ObjectSet(objName, OBJPROP_TIME1, time);
    ObjectSet(objName, OBJPROP_PRICE1, price);
}

bool hidePivot(int index)
{
    string objName = APP_TAG + IntegerToString(index);
    ObjectSet(objName, OBJPROP_TIME1, 0);
    return (ObjectFind(objName) >= 0);
}
