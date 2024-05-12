//+------------------------------------------------------------------+
//|                                                Session Range.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define APP_TAG "SessionRange"

enum eSession{
    eAs,
    eLo,
    eNy
};

enum eStyle{
    eStyleHiLoLine, // Ｈｉ/Ｌｏ Ｌｉｎｅ
    eStyleHiLoChar, // Ｈｉ/Ｌｏ Ｃｈａｒ Ｌｉｎｅ
    eStyleLineBox,  // Ｌｉｎｅ Ｂｏｘ
    eStyleColorBox, // Ｃｏｌｏｒ Ｂｏｘ
};


input eStyle inpStyle = eStyleHiLoLine; // => Ｓｅｓｓｉｏｎ Ｓｔｙｌｅ <=

input string _mainColor; // - - - Main Color - - -
input color inpAsColor = clrTeal;       // Asian Color
input color inpLoColor = clrForestGreen;// London Color
input color inpNyColor = clrBrown;      // NewYork Color

input string _charLine; // - - - Hi/Lo Char Line Configuration - - -
input string inpChPoint = "•";  // Charecter
input int    inpChSize  = 7;    // Size

input string _colorBox; // - - - Color Box Confignuration - - -
input color inpAsBgColor = clrAliceBlue;     // Asian Color
input color inpLoBgColor = clrHoneydew;      // London Color
input color inpNyBgColor = clrLavenderBlush; // NewYork Color

int asBegHour = 0;
int asEndHour = 6;
int ldBegHour = 7;
int ldEndHour = 11;
int nyBegHour = 12;
int nyEndHour = 16;
int winterBeg = 10;
int winterEnd = 4;


int gChartPeriod;

int gAsBar;
int gLdBar;
int gNyBar;

string gSsLableMap[] = {"As", "Ld", "Ny"};
color gSsColor[3];
color gSsBgColor[3];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
//---
    gChartPeriod = ChartPeriod();
    gAsBar = (asEndHour - asBegHour) * 60 / gChartPeriod;
    gLdBar = (ldEndHour - ldBegHour) * 60 / gChartPeriod;
    gNyBar = (nyEndHour - nyBegHour) * 60 / gChartPeriod;
    gSsColor[0] = inpAsColor;
    gSsColor[1] = inpLoColor;
    gSsColor[2] = inpNyColor;
    gSsBgColor[0] = inpAsBgColor;
    gSsBgColor[1] = inpLoBgColor;
    gSsBgColor[2] = inpNyBgColor;
    if (ChartPeriod() >= PERIOD_H4) Print("This Indi is only work on lower H4 timeframe!!!");
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
    if (ChartPeriod() >= PERIOD_H4) return;
    if (id == CHARTEVENT_CHART_CHANGE) scanWindow();
}
//+------------------------------------------------------------------+

int gLineIdx;
int gLabelIdx;
int gRectIdx;
int gMonth;
int gHour ;
int gMin  ;

void scanWindow(){
    int bars_count = WindowBarsPerChart();
    int bar = WindowFirstVisibleBar();

    gLineIdx = 0;
    gLabelIdx = 0;
    gRectIdx = 0;
    while(bar >= 0) {
        gMonth = TimeMonth(Time[bar]);
        gHour  = TimeHour(Time[bar]);
        gMin   = TimeMinute(Time[bar]);
        if (gMonth >= winterBeg || gMonth < winterEnd) { // Winter Time
            gHour = gHour - 1;
        }
        if (gHour == asBegHour){
            drawSession(eAs, bar, bar-gAsBar);
            bar -= gAsBar;
        }
        else if (gHour == ldBegHour){
            drawSession(eLo, bar, bar-gLdBar);
            bar -= gLdBar;
        }
        else if (gHour == nyBegHour){
            drawSession(eNy, bar, bar-gLdBar);
            bar -= gLdBar;
        }
        else {
            bar--;
        }
    }
}

double gHi, gLo;
void drawSession(eSession ss, int beginBar, int endBar)
{
    // Find HiLo
    gHi = High[beginBar];
    gLo = Low [beginBar];
    bool isSsRunning = false;
    if (endBar < 0){
        endBar = 0;
        isSsRunning = true;
    }
    for (int i = beginBar; i >= 0 && i >= endBar; i--){
        if (High[i] > gHi)  gHi = High[i];
        if (Low[i]  < gLo)  gLo = Low[i];
    }
    if (inpStyle == eStyleHiLoLine || inpStyle == eStyleLineBox){
        // Hi Line
        createLine(gLineIdx++, Time[beginBar], Time[endBar], gHi, gHi, gSsColor[ss]);
        createLine(gLineIdx++, Time[beginBar], Time[endBar], gLo, gLo, gSsColor[ss]);
        if (inpStyle == eStyleLineBox){
            createLine(gLineIdx++, Time[beginBar], Time[beginBar], gHi, gLo, gSsColor[ss]);
            createLine(gLineIdx++, Time[endBar], Time[endBar], gHi, gLo, gSsColor[ss]);
        }
    }
    else if (inpStyle == eStyleHiLoChar){
        for (int i = beginBar; i >= 0 && i >= endBar; i--){
            createLabel(gLabelIdx++, inpChPoint,
                Time[i], gHi, inpChSize, ANCHOR_CENTER, gSsColor[ss]);
            createLabel(gLabelIdx++, inpChPoint,
                Time[i], gLo, inpChSize, ANCHOR_CENTER, gSsColor[ss]);
        }
    }
    else if (inpStyle == eStyleColorBox){
        createRectangle(gRectIdx++, Time[beginBar], Time[endBar], gHi, gLo, gSsBgColor[ss]);
    }
    createLabel(gLabelIdx++, (isSsRunning ? "►" : "") + gSsLableMap[ss],
            Time[endBar], gHi, 7, ANCHOR_RIGHT_LOWER, gSsColor[ss]);
}

void createLabel(int index, string label, datetime time1, double price1, int size, int anchor, color cl){
    string objName = APP_TAG + "Label" + IntegerToString(index);
    ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_BACK, true);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
    // Basic
    ObjectSet(objName, OBJPROP_TIME1, time1);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
    ObjectSetText(objName, label, size, NULL, cl);
    ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR, anchor);
}

void createLine(int index, datetime time1, datetime time2, double price1, double price2, color cl){
    string objName = APP_TAG + "Line" + IntegerToString(index);
    ObjectCreate(objName, OBJ_TREND, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_BACK, true);
    ObjectSet(objName, OBJPROP_RAY, false);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
    // Style
    ObjectSet(objName, OBJPROP_STYLE, STYLE_DOT);
    ObjectSet(objName, OBJPROP_WIDTH, 0);
    // Basic
    ObjectSet(objName, OBJPROP_COLOR, cl);
    ObjectSet(objName, OBJPROP_TIME1, time1);
    ObjectSet(objName, OBJPROP_TIME2, time2);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
    ObjectSet(objName, OBJPROP_PRICE2, price2);
}

void createRectangle(int index, datetime time1, datetime time2, double price1, double price2, color cl){
    string objName = APP_TAG + "Rectangle" + IntegerToString(index);
    ObjectCreate(objName, OBJ_RECTANGLE, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_BACK, true);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
    // Style
    // Basic
    ObjectSet(objName, OBJPROP_COLOR, cl);
    ObjectSet(objName, OBJPROP_TIME1, time1);
    ObjectSet(objName, OBJPROP_TIME2, time2);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
    ObjectSet(objName, OBJPROP_PRICE2, price2);
}