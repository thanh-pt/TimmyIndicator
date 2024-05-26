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
};

input string    CommomConfig;                   // C O M M O N   C O N F I G
input EQueryBar InpQueryBar = E_3BAR;           // →   Query Bar
input int       InpPivotSize = 12;              // →   Pivot Size
input int       InpSmallSize = 3;               // →   Small Size
input int       InpChartScaleDisplay = 2;       // →   Scale Visibility
input string _separateLine;                     // D I S P L A Y   C O N F I G
input string _charecter;                        // → Pivot Charecter:
input string HiPivotCharecter = "•";            // Hi
input string LoPivotCharecter = "•";            // Lo
input string _cl;                               // → Charecter:
input color  HiPivotColor     = clrCrimson;     // Hi
input color  LoPivotColor     = clrRoyalBlue;   // Lo


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
    int bar=WindowFirstVisibleBar()-2;
    int pIdx = 0;
    if (gChartScale >= InpChartScaleDisplay) {
        gPreState = 0;
        gPrePrice = Open[bar];
        for(int i=0; i<bars_count && bar>=0; i++,bar--) {
            if (InpQueryBar == E_3BAR){
                if (High[bar] > High[bar+1] && High[bar] >= High[bar-1]){
                    drawPivot(pIdx++, true, Time[bar], High[bar]);
                }
                if (Low[bar] < Low[bar+1] && Low[bar] <= Low[bar-1]){
                    drawPivot(pIdx++, false, Time[bar], Low[bar]);
                }
                if (bar == 1) break;
            } else if (InpQueryBar == E_5BAR){
                if ((High[bar] > High[bar+1] && High[bar] >= High[bar-1])
                 && (High[bar] > High[bar+2] && High[bar] > High[bar-2])){
                    drawPivot(pIdx++, true, Time[bar], High[bar]);
                }
                if ((Low[bar] < Low[bar+1] && Low[bar] <= Low[bar-1])
                 && (Low[bar] < Low[bar+2] && Low[bar] < Low[bar-2])){
                    drawPivot(pIdx++, false, Time[bar], Low[bar]);
                }
                if (bar == 2) break;
            }
        }
    }
    while(hidePivot(pIdx++) == true){}
}

int gPreState = 0;
double gPrePrice = 0;
int gPreIdx = 0;

void drawPivot(int index, bool isHi, const datetime& time, const double& price){
    string objName = APP_TAG + IntegerToString(index);
    if (ObjectFind(objName) < 0) {
        ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
        ObjectSet(objName, OBJPROP_BACK, false);
        ObjectSet(objName, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
    }
    ObjectSetText(objName, isHi ? HiPivotCharecter : LoPivotCharecter, InpPivotSize, NULL, isHi ? HiPivotColor : LoPivotColor);
    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, DoubleToString(price, 5));
    ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR, isHi ? ANCHOR_LOWER : ANCHOR_UPPER);
    ObjectSet(objName, OBJPROP_TIME1, time);
    ObjectSet(objName, OBJPROP_PRICE1, price);

    if (isHi){
        if (gPreState == 2) {
            if (price > gPrePrice){
                resizePivot(gPreIdx, InpSmallSize);
                gPrePrice = price;
                gPreIdx = index;
            } else {
                resizePivot(index, InpSmallSize);
            }
        } else {
            gPrePrice = price;
            gPreIdx = index;
        }
    } else {
        if (gPreState == 3){
            if (price < gPrePrice){
                resizePivot(index-1, InpSmallSize);
                gPrePrice = price;
                gPreIdx = index;
            } else {
                resizePivot(index, InpSmallSize);
            }
        } else{
            gPrePrice = price;
            gPreIdx = index;
        }
    }
    gPreState = (isHi ? 2 : 3);
}

bool hidePivot(int index){
    string objName = APP_TAG + IntegerToString(index);
    ObjectSet(objName, OBJPROP_TIME1, 0);
    return (ObjectFind(objName) >= 0);
}

void resizePivot(int index, int size){
    if (size == 0) {
        hidePivot(index);
        return;
    }
    string objName = APP_TAG + IntegerToString(index);
    ObjectSet(objName, OBJPROP_FONTSIZE, size);
}