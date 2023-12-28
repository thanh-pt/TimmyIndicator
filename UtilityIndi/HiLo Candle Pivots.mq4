//+------------------------------------------------------------------+
//|                                            Pivot Candlestick.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link "https://www.youtube.com/@TimmyTraderHamHoc"
#property version "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_label1 "HiPivot"
#property indicator_label2 "LoPivot"

#define BULLISH 1
#define BEARISH - 1
#define REVERT - 1

#define APP_TAG "HiLoPivots"

input color HiPivotColor = clrBlack;
input string HiPivotCharecter = "H";
input color LoPivotColor = clrBlack;
input string LoPivotCharecter = "L";
input int HiLoPivotSize = 5;

//--- indicator buffers
double hiPivotBuffer[];
double loPivotBuffer[];

int gPos, gIdx, gPivotIdx, gPreHLIdx;
double gPreHi, gPreLo;
int gCurDir = 0, gPreDir = 0;
bool gIsInsideBar, gIsOutsideBar;
double gIndiGap = 0;
long gChartScale = 0;

bool isUpBar(const double& open[], const double& close[], int barIdx) {
    return open[barIdx] < close[barIdx];
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    //--- indicator buffers mapping
    SetIndexBuffer(0, hiPivotBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, loPivotBuffer, INDICATOR_DATA);
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
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
    gPos = prev_calculated;
    if (prev_calculated == 0) {
        gPreHi = high[rates_total-1];
        gPreLo = low[rates_total-1];
        gPos = rates_total-2;
        gIndiGap = (gPreHi - gPreLo) / 5;
    } else {
        gPos = rates_total - prev_calculated;
    }
    for (gIdx = gPos; gIdx > 0; gIdx--) {
        hiPivotBuffer[gIdx] = EMPTY_VALUE;
        loPivotBuffer[gIdx] = EMPTY_VALUE;

        gIsInsideBar = false;
        gIsOutsideBar = false;
        if (high[gIdx] > gPreHi && low[gIdx] >= gPreLo) gCurDir = BULLISH;
        else if (high[gIdx] <= gPreHi && low[gIdx] < gPreLo) gCurDir = BEARISH;
        else if (high[gIdx] > gPreHi && low[gIdx] < gPreLo) { // Outside bar correction
            gCurDir = gCurDir * REVERT;
            gIsOutsideBar = true;
        } else gIsInsideBar = true;

        if (gPreDir != gCurDir && gPreDir != 0) {
            if (gCurDir == BEARISH) {
                if (gIsOutsideBar && isUpBar(open, close, gIdx)==true && high[gIdx] < high[gIdx-1]){
                    hiPivotBuffer[gPreHLIdx] = high[gPreHLIdx] + gIndiGap;
                } else if (high[gIdx] < gPreHi) {
                    hiPivotBuffer[gPreHLIdx] = high[gPreHLIdx] + gIndiGap;
                } else {
                    hiPivotBuffer[gIdx] = high[gIdx] + gIndiGap;
                }
            } else {
                if (gIsOutsideBar && isUpBar(open, close, gIdx)==false && low[gIdx] > low[gIdx-1]){
                    loPivotBuffer[gPreHLIdx] = low[gPreHLIdx] - gIndiGap;
                } else if (low[gIdx] > gPreLo) {
                    loPivotBuffer[gPreHLIdx] = low[gPreHLIdx] - gIndiGap;
                } else {
                    loPivotBuffer[gIdx] = low[gIdx] - gIndiGap;
                }
            }
        }
        gPreDir = gCurDir;

        if (gIsInsideBar == false) {
            gPreHi = high[gIdx];
            gPreLo = low[gIdx];
            gPreHLIdx = gIdx;
        }
    }
    //--- return value of prev_calculated for next call
    return (rates_total);
}

void pivotConfig(const string& objName, bool isHi, const datetime& time, const double& price){
    if (ObjectFind(objName) < 0) {
        ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
        ObjectSet(objName, OBJPROP_BACK, true);
        ObjectSet(objName, OBJPROP_SELECTABLE, false);
        ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
        ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
    }
    ObjectSetText(objName, isHi ? HiPivotCharecter : LoPivotCharecter, HiLoPivotSize, NULL, isHi ? HiPivotColor : LoPivotColor);
    ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR, isHi ? ANCHOR_LOWER : ANCHOR_UPPER);
    ObjectSet(objName, OBJPROP_TIME1, time);
    ObjectSet(objName, OBJPROP_PRICE1, price);
}
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                const long & lparam,
                const double & dparam,
                const string & sparam)
{
    if (id == CHARTEVENT_CHART_CHANGE) {
        bool ret = ChartGetInteger(ChartID(), CHART_SCALE, 0, gChartScale);
        int bars_count=WindowBarsPerChart();
        int bar=WindowFirstVisibleBar();
        int pIdx = 0;
        string objName;
        if (gChartScale >= 2) {
            for(int i=0; i<bars_count && bar>0; i++,bar--) {
                if (hiPivotBuffer[bar] != EMPTY_VALUE) {
                    objName = APP_TAG + IntegerToString(pIdx++);
                    pivotConfig(objName, true, Time[bar], High[bar]);
                }
                if (loPivotBuffer[bar] != EMPTY_VALUE) {
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
}