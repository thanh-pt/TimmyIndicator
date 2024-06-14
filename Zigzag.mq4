//+------------------------------------------------------------------+
//|                                                       Zigzag.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define APP_TAG "Zigzag."

int InpPreQuery = 5;

enum eChartMode {
    eZigZag,
    eBoth,
    eNormal,
};

eChartMode gChartMode = eBoth;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
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
//--- return value of prev_calculated for next call
    scanWindow();
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
    if (id == CHARTEVENT_KEYDOWN) {
        if (lparam == 'N'){
            if (gChartMode == eNormal) gChartMode = eZigZag;
            else gChartMode++;
            scanWindow();
        }
    }
}
//+------------------------------------------------------------------+

#define HI 1
#define LO 2

int gLineIdx;
void scanWindow()
{
    gLineIdx = 0;
    if (gChartMode == eBoth || gChartMode == eNormal){
        ChartSetInteger(ChartID(), CHART_MODE, CHART_CANDLES);
        ChartSetInteger(ChartID(),CHART_COLOR_CHART_LINE,clrDarkGray);
        if (gChartMode == eNormal){
            hideItem(gLineIdx, "Line");
            return;
        }
    }
    else {
        ChartSetInteger(ChartID(), CHART_MODE, CHART_LINE);
        ChartSetInteger(ChartID(),CHART_COLOR_CHART_LINE,clrNONE);
    }
    int bars_count=WindowBarsPerChart();
    int bar=WindowFirstVisibleBar()-2;
    int curLine = 0;
    int point1State = 0;
    int curL = 0;
    int curH = 0;
    for(int i=0; i<bars_count && bar>=0; i++,bar--) {
        if (isPivotH(bar)){
            if (point1State == LO) {
                if (Low[curL] < High[bar]) {
                    curLine = gLineIdx++;
                    curH = bar;
                    drawLine(curLine, Time[curL], Low[curL], Time[curH], High[curH]);
                    point1State = HI;
                }
            }
            else if (point1State == HI) {
                if (High[bar] >= High[curH]){
                    curH = bar;
                    updateLine(curLine, Time[curH], High[curH]);
                }
            }
            else{
                curH = bar;
                point1State = HI;
                drawLine(curLine, Time[curH], High[curH], Time[curH], Low[curH]);
            }
        }
        if (isPivotL(bar)){
            if (point1State == HI) {
                if (High[curH] > Low[bar]) {
                    curLine = gLineIdx++;
                    curL = bar;
                    drawLine(curLine, Time[curH], High[curH], Time[curL], Low[curL]);
                    point1State = LO;
                }
            }
            else if (point1State == LO) {
                if (Low[bar] <= Low[curL]) {
                    curL = bar;
                    updateLine(curLine, Time[curL], Low[curL]);
                }
            }
            else{
                curL = bar;
                point1State = LO;
                drawLine(curLine, Time[curL], Low[curL], Time[curL], Low[curL]);
            }
        }
    }
    hideItem(gLineIdx, "Line");
}

void drawLine(int index, datetime time1, double price1, datetime time2, double price2)
{
    string objName = APP_TAG + "Line" + IntegerToString(index);
    ObjectCreate(objName, OBJ_TREND, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_BACK, true);
    ObjectSet(objName, OBJPROP_RAY, false);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
    // Style
    ObjectSet(objName, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet(objName, OBJPROP_WIDTH, 1);
    // Basic
    ObjectSet(objName, OBJPROP_COLOR, clrGray);
    ObjectSet(objName, OBJPROP_TIME1, time1);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
    ObjectSet(objName, OBJPROP_TIME2, time2);
    ObjectSet(objName, OBJPROP_PRICE2, price2);
}

void hideItem(int index, string tag){
    string objName = APP_TAG + tag + IntegerToString(index);
    while(ObjectFind(objName) >= 0){
        ObjectSet(objName, OBJPROP_TIME1, 0);
        ObjectSet(objName, OBJPROP_TIME2, 0);
        objName = APP_TAG + tag + IntegerToString(index++);
    }
}

void updateLine(int index, datetime time2, double price2)
{
    string objName = APP_TAG + "Line" + IntegerToString(index);
    ObjectSet(objName, OBJPROP_TIME2, time2);
    ObjectSet(objName, OBJPROP_PRICE2, price2);
}

bool isPivotH(int index)
{
    if (index <= 2) return false;
    return isHigherPrevious(index) && High[index] > High[index-1] && High[index] > High[index-2];
}

bool isPivotL(int index)
{
    if (index <= 2) return false;
    return isLowerPrevious(index) && Low[index] < Low[index-1] && Low[index] < Low[index-2];
}

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

bool isStHi(int bar)
{
    if (bar < 3) return false;
    if (High[bar] <= High[bar-1]) return false;
    return isHigherPrevious(bar) && isHigherNext(bar-1);
}

bool isStLo(int bar)
{
    if (bar < 3) return false;
    if (Low[bar] >= Low[bar-1]) return false;
    return isLowerPrevious(bar) && isLowerNext(bar-1);
}

bool isWkHi(int bar)
{
    if (bar < 2) return false;
    if (High[bar] <= High[bar-1]) return false;
    return isHigherPrevious(bar) && isHigherNext(bar);
}

bool isWkLo(int bar)
{
    if (bar < 2) return false;
    if (Low[bar] >= Low[bar-1]) return false;
    return isLowerPrevious(bar) && isLowerNext(bar);
}