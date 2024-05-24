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
    eStyleHiLoLine,     // Ｈｉ/Ｌｏ Ｌｉｎｅ
    eStyleHiLoChar,     // Ｈｉ/Ｌｏ Ｃｈａｒ Ｌｉｎｅ
    eStyleLineBox,      // Ｌｉｎｅ Ｂｏｘ
    eStyleColorBox,     // Ｃｏｌｏｒ Ｂｏｘ
    eStyleBorderLine,   // Ｂｏｄｅｒ Ｌｉｎｅ
    eStyleBorderColor,  // Ｂｏｄｅｒ Ｃｏｌｏｒ
};


input eStyle inpStyle = eStyleBorderColor;      // => Ｓｅｓｓｉｏｎ Ｓｔｙｌｅ <=
input bool inpDisplayLable = false;              // Label Display

input string _display;                          // - - - Display - - -
input bool inpDisplayAs = true;                 // Asian Display
input bool inpDisplayLd = true;                 // London Display
input bool inpDisplayNy = true;                 // NewYork Display

input string _lineColor;                        // - - - Main Color - - -
input color inpAsColor = clrTeal;               // Asian Color
input color inpLdColor = clrForestGreen;        // London Color
input color inpNyColor = clrBrown;              // NewYork Color

input string _bgBox;                            // - - - Background Color - - -
input color inpAsBgColor = clrAliceBlue;        // Asian Color
input color inpLdBgColor = clrHoneydew;         // London Color
input color inpNyBgColor = clrLavenderBlush;    // NewYork Color

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
bool         gInit = false;

MqlDateTime  gDtStruct;
datetime     gBegTime;
int          gBegDayBar;
int          gWtrOffset;
int          gMonth;

int gLineIdx;
int gLabelIdx;
int gRectIdx;

int gAsBarNum;
int gLdBarNum;
int gNyBarNum;

int gBarAs;
int gBarLd;
int gBarNy;

string  gSsLableMap[] = {"As", "Ld", "Ny"};
color   gSsColor[3];
color   gSsBgColor[3];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
//---
    gChartPeriod = ChartPeriod();
    gSymbol = Symbol();
    gAsBarNum = (asEndHour - asBegHour) * 60 / gChartPeriod;
    gLdBarNum = (ldEndHour - ldBegHour) * 60 / gChartPeriod;
    gNyBarNum = (nyEndHour - nyBegHour) * 60 / gChartPeriod;
    gSsColor[0] = inpAsColor;
    gSsColor[1] = inpLdColor;
    gSsColor[2] = inpNyColor;
    gSsBgColor[0] = inpAsBgColor;
    gSsBgColor[1] = inpLdBgColor;
    gSsBgColor[2] = inpNyBgColor;
    if (ChartPeriod() >= PERIOD_H4) Print("This Indi is only work on lower H4 timeframe!!!");
    return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {
    for (int i = ObjectsTotal() - 1; i >= 0; i--) {
        string objName = ObjectName(i);
        if (StringFind(objName, APP_TAG) != -1) ObjectDelete(objName);
    }
    gInit = false;
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
    gInit = true;

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
    if (gInit == false) return;
    if (ChartPeriod() >= PERIOD_H4) return;
    if (id == CHARTEVENT_CHART_CHANGE) scanWindow();
}
//+------------------------------------------------------------------+

void scanWindow(){
    gLineIdx    = 0;
    gLabelIdx   = 0;
    gRectIdx    = 0;
    // Step 1: Xác định ngày
    TimeToStruct(Time[WindowFirstVisibleBar()], gDtStruct);
    gDtStruct.sec   = 0;
    gDtStruct.min   = 0;
    gDtStruct.hour  = 0;
    gBegTime = StructToTime(gDtStruct);
    // Step 2: Xác định nến bắt đầu ngày
    gBegDayBar = iBarShift(gSymbol, gChartPeriod, gBegTime);
    if (gDtStruct.day_of_week == 0) { // Shift 3 tiếng
        gBegDayBar -= (3 * 60 / gChartPeriod + 1);
    }
    while (gBegDayBar >= 0){
        // Step 3: Tính toán nến index của Session -> Draw
        gMonth = TimeMonth(Time[gBegDayBar]);
        gWtrOffset = 0;
        if (gMonth >= winterBeg || gMonth < winterEnd) { // Winter Time
            gWtrOffset = 60/gChartPeriod;
        }
        gBarAs = gBegDayBar - asBegHour*60/gChartPeriod - gWtrOffset;
        gBarLd = gBegDayBar - ldBegHour*60/gChartPeriod - gWtrOffset;
        gBarNy = gBegDayBar - nyBegHour*60/gChartPeriod - gWtrOffset;
        drawSession(eAs, gBarAs, gBarAs-gAsBarNum);
        drawSession(eLd, gBarLd, gBarLd-gLdBarNum);
        drawSession(eNy, gBarNy, gBarNy-gNyBarNum);
        // Step 4: Nến ngày tiếp theo
        gBegDayBar -= 24 * 60 / gChartPeriod;
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
    else if (inpStyle == eStyleBorderLine){
        double currHi = High[beginBar];
        double currLo = Low[beginBar];
        for (int i = beginBar-1; i >= 0 && i >= endBar; i--){
            createLine(gLineIdx++, Time[i+1], Time[i], currHi, MathMax(currHi, High[i]), gSsColor[ss]);
            createLine(gLineIdx++, Time[i+1], Time[i], currLo, MathMin(currLo, Low[i]), gSsColor[ss]);
            if (High[i] > currHi) currHi = High[i];
            if (Low[i] < currLo) currLo = Low[i];
        }
        createLine(gLineIdx++, Time[endBar], Time[endBar], gHi, gLo, gSsColor[ss]);
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
                Time[endBar], gHi, 7, ANCHOR_RIGHT_LOWER, gSsColor[ss]);
    } else if (isSsRunning){
        createLabel(gLabelIdx++, "►" + gSsLableMap[ss],
                Time[endBar], gHi, 7, ANCHOR_RIGHT_LOWER, gSsColor[ss]);
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