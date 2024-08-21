/* TODO:
*/
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define APP_TAG "SessionRange"

enum eSession{
    eAs,
    eLd,
    eNy
};

enum eStyle{
    eStyleLineBox,      // B O X   L I N E
    eStyleColorBox,     // B O X   C O L O R
    eStyleBorderLine,   // B O D E R   L I N E
    eStyleBorderColor,  // B O D E R   C O L O R
};

input string _config;                           // - - - Configuration - - -
input eStyle inpStyle = eStyleLineBox;          // S T Y L E
input bool inpDisplayLable = true;              // L A B E L
input bool inpAlwaysDisplay = false;            // Always Display

input string _display;                          // - - - Display Option - - -
input bool inpDisplayAs = true;                 // Asian
input bool inpDisplayLd = true;                 // London
input bool inpDisplayNy = true;                 // NewYork

input string _lineColor;                          // - - - Main Color - - -
input color inpAsColor = clrTeal;               // Asian
input color inpLdColor = clrForestGreen;        // London
input color inpNyColor = clrBrown;              // NewYork

input string _bgBox;                              // - - - Background Color - - -
input color inpAsBgColor = clrAliceBlue;        // Asian
input color inpLdBgColor = clrHoneydew;         // London
input color inpNyBgColor = clrLavenderBlush;    // NewYork

input string _ssTimezone;         // - - - Timezone - - -
input int inpServerTimeZone  = 0; // Server Timezone:
input int inpLocalTimeZone   = 7; // Local Timezone:
input string _ssTime;        // - - - Session Time (Local) - - -
input int inpAsBegHour = 7;  // Asian Start
input int inpAsEndHour = 11; // Asian End
input int inpLdBegHour = 14; // London Start
input int inpLdEndHour = 17; // London End
input int inpNyBegHour = 19; // NewYork Start
input int inpNyEndHour = 22; // NewYork End

int asBegHour;
int ldBegHour;
int nyBegHour;

int asEndHour;
int ldEndHour;
int nyEndHour;

int          gChartPeriod = ChartPeriod();
bool         gPeriodSep;
string       gSymbol = Symbol();
int          gTotalRate = 0;

MqlDateTime  gStDatetime;
datetime     gBegDatetime;
datetime     gEndDatetime;
int          gFirstBar;
int          gPreFirstDay=0;

int gLineIdx;
int gLabelIdx;
int gRectIdx;

string  gSsLableMap[] = {"As", "Ld", "Ny"};
color   gSsColor[3];
color   gSsBgColor[3];

int adjustTime(int t){
    if (t > 24) t = t - 24;
    else if (t < 0) t = t + 24;
    return t;
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
//---
    asBegHour = adjustTime(inpAsBegHour - inpLocalTimeZone + inpServerTimeZone);
    ldBegHour = adjustTime(inpLdBegHour - inpLocalTimeZone + inpServerTimeZone);
    nyBegHour = adjustTime(inpNyBegHour - inpLocalTimeZone + inpServerTimeZone);

    asEndHour = adjustTime(inpAsEndHour - inpLocalTimeZone + inpServerTimeZone);
    ldEndHour = adjustTime(inpLdEndHour - inpLocalTimeZone + inpServerTimeZone);
    nyEndHour = adjustTime(inpNyEndHour - inpLocalTimeZone + inpServerTimeZone);

    gSsColor[eAs] = inpAsColor;
    gSsColor[eLd] = inpLdColor;
    gSsColor[eNy] = inpNyColor;
    gSsBgColor[eAs] = inpAsBgColor;
    gSsBgColor[eLd] = inpLdBgColor;
    gSsBgColor[eNy] = inpNyBgColor;
    return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {
    for (int i = ObjectsTotal() - 1; i >= 0; i--) {
        string objName = ObjectName(i);
        if (StringFind(objName, APP_TAG) != -1) ObjectDelete(objName);
    }
    gTotalRate = 0;
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
        scanWindow();
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
    if (id == CHARTEVENT_CHART_CHANGE) {
        gPeriodSep = (bool)ChartGetInteger(0,CHART_SHOW_PERIOD_SEP);
        gFirstBar = WindowFirstVisibleBar();
        if (gFirstBar <= 0) return;
        if (gPreFirstDay != TimeDay(Time[gFirstBar])) {
            gPreFirstDay = TimeDay(Time[gFirstBar]);
            scanWindow();
        }
    }
    else if (id == CHARTEVENT_OBJECT_DELETE){
        if (StringFind(sparam, APP_TAG) != -1) gPreFirstDay = 0;
    }
}
//+------------------------------------------------------------------+

void scanWindow(){
    if (ChartPeriod() >= PERIOD_H4) return;
    gLineIdx    = 0;
    gLabelIdx   = 0;
    gRectIdx    = 0;
    // First bar Datetime
    int lastBar = gFirstBar - WindowBarsPerChart();
    if (lastBar < 0) lastBar = 0;
    TimeToStruct(Time[gFirstBar], gStDatetime);
    gBegDatetime = Time[gFirstBar];
    while (gBegDatetime < Time[lastBar]){
        gStDatetime.sec   = 0;
        gStDatetime.min   = 0;
        if (gStDatetime.day_of_week != 0 && gStDatetime.day_of_week != 6) {
            if (inpDisplayAs) {
                gStDatetime.hour  = asBegHour;
                gBegDatetime = StructToTime(gStDatetime);
                gStDatetime.hour  = asEndHour;
                gEndDatetime = StructToTime(gStDatetime);
                if (asEndHour < asBegHour) gEndDatetime += 86400;
                drawSession(eAs, gBegDatetime, gEndDatetime);
            }
            if (inpDisplayLd) {
                gStDatetime.hour  = ldBegHour;
                gBegDatetime = StructToTime(gStDatetime);
                gStDatetime.hour  = ldEndHour;
                gEndDatetime = StructToTime(gStDatetime);
                if (ldEndHour < ldBegHour) gEndDatetime += 86400;
                drawSession(eLd, gBegDatetime, gEndDatetime);
            }
            if (inpDisplayNy) {
                gStDatetime.hour  = nyBegHour;
                gBegDatetime = StructToTime(gStDatetime);
                gStDatetime.hour  = nyEndHour;
                gEndDatetime = StructToTime(gStDatetime);
                if (nyEndHour < nyBegHour) gEndDatetime += 86400;
                drawSession(eNy, gBegDatetime, gEndDatetime);
            }
        }
        // Next day!
        gStDatetime.hour  = 0;
        gBegDatetime = StructToTime(gStDatetime);
        gBegDatetime += 86400;
        TimeToStruct(gBegDatetime, gStDatetime);
    }
    hideItem(gLabelIdx, "Label");
    hideItem(gLineIdx,  "Line");
    hideItem(gRectIdx,  "Rectangle");
}

double gHi, gLo;
void drawSession(eSession ss, datetime begDt, datetime endDt)
{
    // Find HiLo
    int beginBar = iBarShift(gSymbol, gChartPeriod, begDt);
    int endBar   = iBarShift(gSymbol, gChartPeriod, endDt);

    if (beginBar == 0) {
        createLabel(gLabelIdx++, "● "+gSsLableMap[ss], begDt, Low[0], 8, ANCHOR_LEFT_UPPER, gSsColor[ss]);
        return;
    }
    bool isSsRunning = (endBar == 0);
    if (inpAlwaysDisplay || (gPeriodSep == false && isSsRunning == false)) return;

    gHi = High[beginBar];
    gLo = Low [beginBar];
    for (int i = beginBar; i >= 0 && i >= endBar; i--){
        if (High[i] > gHi)  gHi = High[i];
        if (Low[i]  < gLo)  gLo = Low[i];
    }
    if (inpStyle == eStyleLineBox){
        createLine(gLineIdx++, begDt, begDt, gHi, gLo, gSsColor[ss]);
        createLine(gLineIdx++, endDt, endDt, gHi, gLo, gSsColor[ss]);
        if (isSsRunning == false) {
            createLine(gLineIdx++, begDt, endDt, gHi, gHi, gSsColor[ss]);
            createLine(gLineIdx++, begDt, endDt, gLo, gLo, gSsColor[ss]);
        }
    }
    else if (inpStyle == eStyleColorBox){
        createRectangle(gRectIdx++, begDt, endDt, gHi, gLo, gSsBgColor[ss]);
    }
    else if (inpStyle == eStyleBorderLine){
        double currHi = High[beginBar];
        double currLo = Low[beginBar];
        for (int i = beginBar-1; i >= 0 && i >= endBar; i--){
            createLine(gLineIdx++, Time[i+1], Time[i], currHi, MathMax(currHi, High[i]), gSsColor[ss]);
            createLine(gLineIdx++, Time[i+1], Time[i], currLo, MathMin(currLo, Low[i]), gSsColor[ss]);
            if (High[i] > currHi) currHi = High[i];
            if (Low[i] < currLo) currLo = Low[i];
        }
        createLine(gLineIdx++, endDt, endDt, currHi, currLo, gSsColor[ss]);
    }
    else if (inpStyle == eStyleBorderColor){
        double currHi = High[beginBar];
        double currLo = Low[beginBar];
        int i = beginBar-1;
        for (; i >= 0 && i >= endBar; i--){
            createRectangle(gRectIdx++, Time[i+1], Time[i], currHi, currLo, gSsBgColor[ss]);
            if (High[i] > currHi) currHi = High[i];
            if (Low[i] < currLo) currLo = Low[i];
        }
        if (isSsRunning) createRectangle(gRectIdx++, Time[i+1], endDt, currHi, currLo, gSsBgColor[ss]);
    }
    
    if (isSsRunning){
        createLabel(gLabelIdx++, "►" + gSsLableMap[ss], begDt, gHi, 8, ANCHOR_LEFT_LOWER, gSsColor[ss]);
    }
    else {
        if (inpDisplayLable) createLabel(gLabelIdx++, gSsLableMap[ss], endDt, gHi, 7, ANCHOR_RIGHT_LOWER, gSsColor[ss]);
        if (endBar*gChartPeriod < 15) createLabel(gLabelIdx++, "🏴 E N D", Time[0] + 120*gChartPeriod, Low[0], 9, ANCHOR_LEFT_UPPER, gSsColor[ss]);
    }
}

void createLabel(int index, string label, datetime time1, double price1, int size, int anchor, color cl){
    string objName = APP_TAG + "Label" + IntegerToString(index);
    ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_BACK, true);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSet(objName, OBJPROP_HIDDEN, true);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    // Basic
    ObjectSet(objName, OBJPROP_TIME1, time1);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
    ObjectSet(objName, OBJPROP_ANCHOR, anchor);
    ObjectSetText(objName, label, size, NULL, cl);
}

void createLine(int index, datetime time1, datetime time2, double price1, double price2, color cl){
    string objName = APP_TAG + "Line" + IntegerToString(index);
    ObjectCreate(objName, OBJ_TREND, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_BACK, true);
    ObjectSet(objName, OBJPROP_RAY, false);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSet(objName, OBJPROP_HIDDEN, true);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
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
    ObjectSet(objName, OBJPROP_HIDDEN, true);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    // Style
    // Basic
    ObjectSet(objName, OBJPROP_COLOR, cl);
    ObjectSet(objName, OBJPROP_TIME1, time1);
    ObjectSet(objName, OBJPROP_TIME2, time2);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
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