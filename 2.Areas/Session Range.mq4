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
    eLd,
    eNy
};

enum eStyle{
    eStyleHiLoLine,     // H I / L O   L I N E
    eStyleHiLoChar,     // H I / L O   C H A R   L I N E
    eStyleLineBox,      // L I N E   B O X
    eStyleColorBox,     // C O L O R   B O X
    eStyleBorderLine,   // B O D E R   L I N E
    eStyleBorderColor,  // B O D E R   C O L O R
};


input string _config;                           // - - - Configuration - - -
input eStyle inpStyle = eStyleBorderColor;      // S T Y L E
input bool inpDisplayLable = false;             // L A B E L
input bool inpHiFreqUpdate = false;             // Update Frequency
input bool inpDaySaving    = false;             // Day Saving for winter

input string _display;                          // - - - Display Option - - -
input bool inpDisplayAs = true;                 // Asian
input bool inpDisplayLd = true;                 // London
input bool inpDisplayNy = true;                 // NewYork

input string _lineColor;                        // - - - Main Color - - -
input color inpAsColor = clrTeal;               // Asian
input color inpLdColor = clrForestGreen;        // London
input color inpNyColor = clrBrown;              // NewYork

input string _bgBox;                            // - - - Background Color - - -
input color inpAsBgColor = clrAliceBlue;        // Asian
input color inpLdBgColor = clrHoneydew;         // London
input color inpNyBgColor = clrLavenderBlush;    // NewYork

input string _charLine;                         // - - - Hi/Lo Char Line Configuration - - -
input string inpChPoint = "•";                  // Charecter
input int    inpChSize  = 7;                    // Size


int asBegHour = 0;
int asEndHour = 6;
int ldBegHour = 7;
int ldEndHour = 11;
int nyBegHour = 12;
int nyEndHour = 16;
int winterBeg = 10;
int winterEnd = 4;


int          gChartPeriod;
string       gSymbol;
int          gTotalRate = 0;

MqlDateTime  gDtStruct;
datetime     gBegTime;
int          gBegDayBar;
int          gWtrOffset;
int          gMonth;

int gLineIdx;
int gLabelIdx;
int gRectIdx;

int gBarAs;
int gBarLd;
int gBarNy;

string  gSsLableMap[] = {"As", "Ld", "Ny"};
color   gSsColor[3];
color   gSsBgColor[3];
int     gSsBarNum[3];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
//---
    gChartPeriod = ChartPeriod();
    gSymbol = Symbol();
    gSsBarNum[eAs] = (asEndHour - asBegHour) * 60 / gChartPeriod;
    gSsBarNum[eLd] = (ldEndHour - ldBegHour) * 60 / gChartPeriod;
    gSsBarNum[eNy] = (nyEndHour - nyBegHour) * 60 / gChartPeriod;
    gSsColor[0] = inpAsColor;
    gSsColor[1] = inpLdColor;
    gSsColor[2] = inpNyColor;
    gSsBgColor[0] = inpAsBgColor;
    gSsBgColor[1] = inpLdBgColor;
    gSsBgColor[2] = inpNyBgColor;
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
        if (inpHiFreqUpdate) scanWindow();
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
    if (id == CHARTEVENT_CHART_CHANGE) scanWindow();
}
//+------------------------------------------------------------------+

void scanWindow(){
    if (ChartPeriod() >= PERIOD_H4) return;
    gLineIdx    = 0;
    gLabelIdx   = 0;
    gRectIdx    = 0;
    // Step 1: Xác định ngày
    if (WindowFirstVisibleBar() <= 0) return;
    TimeToStruct(Time[WindowFirstVisibleBar()], gDtStruct);
    gDtStruct.sec   = 0;
    gDtStruct.min   = 0;
    gDtStruct.hour  = 0;
    // Step 2: Xác định nến bắt đầu ngày
    gBegTime = StructToTime(gDtStruct);
    if (gDtStruct.day_of_week == 0) gBegTime += 86400;
    gBegDayBar = iBarShift(gSymbol, gChartPeriod, gBegTime);
    while (gBegDayBar > 0){
        // Step 3: Tính toán nến index của Session -> Draw
        gMonth = TimeMonth(Time[gBegDayBar]);
        gWtrOffset = 0;
        if (inpDaySaving && (gMonth >= winterBeg || gMonth < winterEnd)) { // Winter Time
            gWtrOffset = 60/gChartPeriod;
        }
        gBarAs = gBegDayBar - asBegHour*60/gChartPeriod - gWtrOffset;
        gBarLd = gBegDayBar - ldBegHour*60/gChartPeriod - gWtrOffset;
        gBarNy = gBegDayBar - nyBegHour*60/gChartPeriod - gWtrOffset;
        if (inpDisplayAs) drawSession(eAs, gBarAs, gBarAs-gSsBarNum[eAs]);
        if (inpDisplayLd) drawSession(eLd, gBarLd, gBarLd-gSsBarNum[eLd]);
        if (inpDisplayNy) drawSession(eNy, gBarNy, gBarNy-gSsBarNum[eNy]);
        // Step 4: Nến ngày tiếp theo
        if (TimeDayOfWeek(Time[gBegDayBar]) == 5) { // Case Thứ 6
            gBegTime += 86400 * 3;
            gBegDayBar = iBarShift(gSymbol, gChartPeriod, gBegTime);
        }
        else {
            gBegTime += 86400;
            gBegDayBar = iBarShift(gSymbol, gChartPeriod, gBegTime);
        }
    }
}

double gHi, gLo;
void drawSession(eSession ss, int beginBar, int endBar)
{
    // Find HiLo
    if (beginBar < 0) return;
    bool isSsRunning = false;
    if (endBar < 0){
        endBar = 0;
        isSsRunning = true;
    }
    gHi = High[beginBar];
    gLo = Low [beginBar];
    for (int i = beginBar; i >= 0 && i >= endBar; i--){
        if (High[i] > gHi)  gHi = High[i];
        if (Low[i]  < gLo)  gLo = Low[i];
    }
    if (inpStyle == eStyleHiLoLine || inpStyle == eStyleLineBox){
        // Hi Line
        datetime endTime = Time[beginBar] + gSsBarNum[ss]*gChartPeriod*60;
        if (isSsRunning == false) {
            createLine(gLineIdx++, Time[beginBar], endTime, gHi, gHi, gSsColor[ss]);
            createLine(gLineIdx++, Time[beginBar], endTime, gLo, gLo, gSsColor[ss]);
        }
        if (inpStyle == eStyleLineBox){
            createLine(gLineIdx++, Time[beginBar], Time[beginBar], gHi, gLo, gSsColor[ss]);
            createLine(gLineIdx++, endTime, endTime, gHi, gLo, gSsColor[ss]);
            if (isSsRunning == false && endBar*gChartPeriod < 15){
                createLabel(gLabelIdx++, "🏴 E N D", Time[0] + 120*gChartPeriod, High[0], 9, ANCHOR_LEFT_LOWER, gSsColor[ss]);
            }
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
    else if (inpStyle == eStyleBorderLine){
        double currHi = High[beginBar];
        double currLo = Low[beginBar];
        for (int i = beginBar-1; i >= 0 && i >= endBar; i--){
            createLine(gLineIdx++, Time[i+1], Time[i], currHi, MathMax(currHi, High[i]), gSsColor[ss]);
            createLine(gLineIdx++, Time[i+1], Time[i], currLo, MathMin(currLo, Low[i]), gSsColor[ss]);
            if (High[i] > currHi) currHi = High[i];
            if (Low[i] < currLo) currLo = Low[i];
        }
        if (isSsRunning == false) createLine(gLineIdx++, Time[endBar], Time[endBar], gHi, gLo, gSsColor[ss]);
    }
    else if (inpStyle == eStyleBorderColor){
        double currHi = High[beginBar];
        double currLo = Low[beginBar];
        for (int i = beginBar-1; i >= 0 && i >= endBar; i--){
            createRectangle(gRectIdx++, Time[i+1], Time[i], currHi, currLo, gSsBgColor[ss]);
            if (High[i] > currHi) currHi = High[i];
            if (Low[i] < currLo) currLo = Low[i];
        }
    }
    if (inpDisplayLable){
        createLabel(gLabelIdx++, (isSsRunning ? "►" : "") + gSsLableMap[ss],
                Time[endBar], gHi, 7, isSsRunning ? ANCHOR_LEFT_LOWER : ANCHOR_RIGHT_LOWER, gSsColor[ss]);
    } else if (isSsRunning){
        createLabel(gLabelIdx++, "►" + gSsLableMap[ss],
                Time[endBar], gHi, 7, ANCHOR_LEFT_LOWER, gSsColor[ss]);
    }
    
    hideItem(gLabelIdx, "Label");
    hideItem(gLineIdx,  "Line");
    hideItem(gRectIdx,  "Rectangle");
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

void hideItem(int index, string tag){
    string objName = APP_TAG + tag + IntegerToString(index);
    while(ObjectFind(objName) >= 0){
        ObjectSet(objName, OBJPROP_TIME1, 0);
        ObjectSet(objName, OBJPROP_TIME2, 0);
        objName = APP_TAG + tag + IntegerToString(index++);
    }
}