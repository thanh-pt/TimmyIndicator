//+------------------------------------------------------------------+
//|                                                        ChoCh.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define APP_TAG "ChoCh."

#define BGBLOCK "██████████████████████████████████████████████████████████████████"

int InpPreQuery = 5;


enum ESignalT{
    eSignalBUY,
    eSignalSELL,
    eSignalNONE,
};

bool gInitCalculation = false;
int gHLineIdx = 0;
int gLineIdx = 0;
int gTextIdx = 0;
int gReactIdx = 0;
int gPivotIdx = 0;
ESignalT gCurSig = eSignalNONE;
string gSignalIndi[] = {"Buy", "Sell", "NONE"};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    drawLabel(0, "Choch Indi: " + gSignalIndi[gCurSig], 10, 25);
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
   
//--- return value of prev_calculated for next call
    gInitCalculation = true;
    loadSignal();
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
        if (lparam == 'M'){
            gCurSig = (gCurSig == eSignalBUY) ? eSignalSELL : eSignalBUY;
            loadSignal();
            drawLabel(0, "Choch Indi: " + gSignalIndi[gCurSig], 10, 25);
        }
        else if(lparam == 'N'){
            gCurSig = eSignalNONE;
            loadSignal();
            drawLabel(0, "Choch Indi: " + gSignalIndi[gCurSig], 10, 25);
        }
    }
    else if (id == CHARTEVENT_CHART_CHANGE) loadSignal();
}
//+------------------------------------------------------------------+

void loadSignal(){
    if (gInitCalculation == false) return;
    if (gCurSig == eSignalNONE) {
        hideItem(0, "ChLine");
        hideItem(0, "Text");
        hideItem(0, "React");
        hideItem(0, "Pivot");
        return;
    }
    int startBar = WindowFirstVisibleBar();
    int endBar = startBar - WindowBarsPerChart();
    if (endBar < 0) endBar = 0;
    gHLineIdx = 0;
    gLineIdx = 0;
    gTextIdx = 0;
    gReactIdx = 0;
    gPivotIdx = 0;
    scanWindow(startBar, endBar, eSignalBUY);
    scanWindow(startBar, endBar, eSignalSELL);
}

void scanWindow(int start, int end, ESignalT eSig)
{
    int failCount;
    for (int barIdx = start; barIdx > end; barIdx--){
        if (eSig == eSignalBUY){
            if (isWkHi(barIdx) == false) continue;
            drawPivot(gPivotIdx++, true, barIdx);
            // Find next LOW!
            for (int loIdx = barIdx-1; loIdx>end; loIdx--){
                if (High[loIdx] > High[barIdx]) break;
                if (isStLo(loIdx) == false) continue;
                drawPivot(gPivotIdx++, false, loIdx);
                // Find Choch
                failCount = 0;
                for (int chIdx = loIdx-1; chIdx>end; chIdx--){
                    if (Low[chIdx] < Low[loIdx]) break;
                    if (High[chIdx] <= High[barIdx]){
                        if (isStHi(chIdx) == true) {
                            failCount++;
                            if (failCount >= 2) break;
                        }
                        continue;
                    }
                    bool hasReaction = false;
                    for (int reactIdx = loIdx-1; reactIdx>chIdx; reactIdx--){
                        if (isInsideBar(reactIdx) == true || isWkHi(reactIdx) == true) {
                            hasReaction = true;
                            drawReact(gReactIdx++, eSig, reactIdx);
                            break;
                        }
                    }
                    if (hasReaction) {
                        drawChLine(gHLineIdx++, eSig, barIdx, chIdx);
                        drawText(gTextIdx++, eSig, barIdx);
                    }
                    break;
                }
                break;
            }
        }
        else {
            if (isWkLo(barIdx) == false) continue;
            drawPivot(gPivotIdx++, false, barIdx);
            // Find next HIGHT!
            for (int hiIdx = barIdx-1; hiIdx>end; hiIdx--){
                if (Low[hiIdx] < Low[barIdx]) break; // Không tạo được Hi
                if (isStHi(hiIdx) == false) continue;
                drawPivot(gPivotIdx++, true, hiIdx);
                // Find Choch
                failCount = 0;
                for (int chIdx = hiIdx-1; chIdx>end; chIdx--){
                    if (High[chIdx] > High[hiIdx]) break; // Chưa choch được mà điểm Hi đã bị phá (?) Tìm HI mới???
                    if (Low[chIdx] >= Low[barIdx]){
                        if (isStLo(chIdx) == true) {
                            failCount++;
                            if (failCount >= 2) break;
                        }
                        continue;
                    }
                    bool hasReaction = false;
                    for (int reactIdx = hiIdx-1; reactIdx>chIdx; reactIdx--){
                        if (isInsideBar(reactIdx) == true || isWkLo(reactIdx) == true) {
                            hasReaction = true;
                            drawReact(gReactIdx++, eSig, reactIdx);
                            break;
                        }
                    }
                    if (hasReaction){
                        drawChLine(gHLineIdx++, eSig, barIdx, chIdx);
                        drawText(gTextIdx++, eSig, barIdx);
                    }
                    break;
                }
                break;
            }
        }
    }
    hideItem(gHLineIdx, "ChLine");
    hideItem(gTextIdx,  "Text");
    hideItem(gReactIdx, "React");
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

bool isInsideBar(int index){
    return High[index] <= High[index+1] && Low[index] >= Low[index+1];
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

void drawChLine(int index, ESignalT eSig, int start, int end)
{
    string objName = APP_TAG + "ChLine" + IntegerToString(index);
    ObjectCreate(objName, OBJ_TREND, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_BACK, true);
    ObjectSet(objName, OBJPROP_RAY, false);
    // ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
    // Style
    ObjectSet(objName, OBJPROP_STYLE, STYLE_DOT);
    ObjectSet(objName, OBJPROP_WIDTH, 0);
    // Basic
    ObjectSet(objName, OBJPROP_COLOR, eSig == eSignalBUY ? clrGreen : clrRed);
    ObjectSet(objName, OBJPROP_TIME1, Time[start]);
    ObjectSet(objName, OBJPROP_TIME2, Time[end]);
    ObjectSet(objName, OBJPROP_PRICE1, eSig == eSignalBUY ? High[start] : Low[start]);
    ObjectSet(objName, OBJPROP_PRICE2, eSig == eSignalBUY ? High[start] : Low[start]);
}

void drawReact(int index, ESignalT eSig, int bar)
{
    string objName = APP_TAG + "React" + IntegerToString(index);
    ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
    ObjectSet(objName, OBJPROP_BACK, false);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
    ObjectSetText(objName, eSig == eSignalBUY ? "▼" : "▲", 5, "Consolas", clrGray);
    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR, eSig == eSignalBUY ? ANCHOR_LOWER : ANCHOR_UPPER);
    ObjectSet(objName, OBJPROP_TIME1, Time[bar]);
    ObjectSet(objName, OBJPROP_PRICE1, eSig == eSignalBUY ? High[bar] : Low[bar]);
}

void drawText(int index, ESignalT eSig, int bar)
{
    string objName = APP_TAG + "Text" + IntegerToString(index);
    ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
    ObjectSet(objName, OBJPROP_BACK, false);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
    ObjectSetText(objName, "ch", 6, "Consolas", eSig == eSignalBUY ? clrGreen : clrRed);
    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR, eSig == eSignalBUY ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER);
    ObjectSet(objName, OBJPROP_TIME1, Time[bar-1]);
    ObjectSet(objName, OBJPROP_PRICE1, eSig == eSignalBUY ? High[bar] : Low[bar]);
}

void drawPivot(int index, bool isHi, int bar)
{
    return;
    string objName = APP_TAG + "Pivot" + IntegerToString(index);
    ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
    ObjectSet(objName, OBJPROP_BACK, false);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
    ObjectSetText(objName, "•", 11, NULL, clrBlack);
    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR, isHi ? ANCHOR_LOWER : ANCHOR_UPPER);
    ObjectSet(objName, OBJPROP_TIME1, Time[bar]);
    ObjectSet(objName, OBJPROP_PRICE1, isHi ? High[bar] : Low[bar]);
}

void hideItem(int index, string tag){
    string objName = APP_TAG + tag + IntegerToString(index);
    while(ObjectFind(objName) >= 0){
        ObjectSet(objName, OBJPROP_TIME1, 0);
        ObjectSet(objName, OBJPROP_TIME2, 0);
        objName = APP_TAG + tag + IntegerToString(index++);
    }
}

void drawLabel(int index, string text, int posX, int posY)
{
    string objName = APP_TAG + "0LabelBG" + IntegerToString(index);
    ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSetText(objName, StringSubstr(BGBLOCK, 0, StringLen(text)), 8, "Consolas", clrGainsboro);
    ObjectSet(objName, OBJPROP_XDISTANCE, posX);
    ObjectSet(objName, OBJPROP_YDISTANCE, posY);
    ObjectSetString(ChartID() , objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(ChartID(), objName, OBJPROP_CORNER , CORNER_LEFT_UPPER);
    ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR , ANCHOR_LEFT_UPPER);
    //--------------------------------------------
    objName = APP_TAG + "1LabelText" + IntegerToString(index);
    ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
    ObjectSetText(objName, text, 8, "Consolas");
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSet(objName, OBJPROP_COLOR, clrBlack);
    ObjectSet(objName, OBJPROP_XDISTANCE, posX);
    ObjectSet(objName, OBJPROP_YDISTANCE, posY);
    ObjectSetString(ChartID() , objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(ChartID(), objName, OBJPROP_CORNER , CORNER_LEFT_UPPER);
    ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR , ANCHOR_LEFT_UPPER);
}