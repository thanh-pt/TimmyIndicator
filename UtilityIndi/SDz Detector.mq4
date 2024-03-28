//+------------------------------------------------------------------+
//|                                                 SDz Detector.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define APP_TAG  "SDzDetector"
#define INDI_ON  "SDz Detector ON"
#define INDI_OFF "SDz Detector OFF"

input int       QueryMgtNum  = 3;
input int       QuerySdzNum  = 5;
input color     SzColor     = clrMistyRose;
input color     DzColor     = clrAliceBlue;
input bool      SDzBgDraw   = true;
input string    OnOffShortCut = "O";

bool   gInit            = false;
string gIndiStage       = INDI_ON;
string gBtnIndiSwitch   = APP_TAG + "BtnIndiSwitch";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    if (ObjectFind(gBtnIndiSwitch) < 0) {
        createBtnIndiSwitch();
    } else {
        gIndiStage = ObjectDescription(gBtnIndiSwitch);
    }
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
    loadSDzDetector();
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
    if (id == CHARTEVENT_CHART_CHANGE) loadSDzDetector();
    else if (id == CHARTEVENT_OBJECT_CLICK) {
        if (sparam == gBtnIndiSwitch) {
            toggleOnOff();
        }
    } else if (id == CHARTEVENT_OBJECT_DELETE){
        if (sparam == gBtnIndiSwitch) {
            createBtnIndiSwitch();
        }
    } else if (id == CHARTEVENT_KEYDOWN){
        if (lparam == OnOffShortCut[0]) toggleOnOff();
    }
}
//+------------------------------------------------------------------+

void toggleOnOff(){
    if (gIndiStage == INDI_ON) {
        gIndiStage = INDI_OFF;
    } else {
        gIndiStage = INDI_ON;
    }
    ObjectSetText(gBtnIndiSwitch, gIndiStage);
    loadSDzDetector();
}

void drawRectangle(string objName, datetime time1, datetime time2, double price1, double price2, color c){
    ObjectCreate(objName, OBJ_RECTANGLE , 0, 0, 0);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSet(objName, OBJPROP_BACK , SDzBgDraw);
    ObjectSet(objName, OBJPROP_STYLE, 2);
    ObjectSet(objName, OBJPROP_COLOR, c);
    ObjectSet(objName, OBJPROP_TIME1 , time1);
    ObjectSet(objName, OBJPROP_TIME2 , time2);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
    ObjectSet(objName, OBJPROP_PRICE2, price2);
}

bool isInsideBar(int barIdx){
    if (Low[barIdx] >= Low[barIdx+1] && High[barIdx] <= High[barIdx+1]) return true;
    return false;
}

bool isPivotHi(int barIdx){
    if (High[barIdx] > High[barIdx-1] && High[barIdx] > High[barIdx+1]) return true;
    return false;
}

bool isPivotLo(int barIdx){
    if (Low[barIdx] < Low[barIdx-1] && Low[barIdx] < Low[barIdx+1]) return true;
    return false;
}

void loadSDzDetector()
{
    int pIdx = 0;
    if (gIndiStage == INDI_ON){
        int bars_count=WindowBarsPerChart();
        int bar=WindowFirstVisibleBar();
        int lastBar = MathMax(bar - bars_count, 1);

        int mtgBar = 0;
        int sdzBar = 0;
        int lastSz = bar+1;
        int lastDz = bar+1;
        bool isClearImb = false;
        double hiLo = 0;

        for(int i=0; i<bars_count && bar>1; i++,bar--) {
            if (Low[bar+1] > High[bar-1] && Low[bar+2] <= High[bar]) { // Down IMB
                isClearImb = false;
                mtgBar = bar-1;
                while (mtgBar >= lastBar){
                    if (High[mtgBar] >= Low[bar+1]){
                        if (bar - mtgBar < QueryMgtNum) isClearImb = true;
                        break;
                    }
                    mtgBar--;
                }
                if (isClearImb == false) {
                    // find Sdz
                    sdzBar = bar+1;
                    hiLo = High[bar];
                    while (sdzBar - bar <= QuerySdzNum){
                        if (High[sdzBar] >= hiLo){
                            hiLo = High[sdzBar];
                            if (isInsideBar(sdzBar)) break;
                            if (isPivotHi(sdzBar)) break;
                        }
                        sdzBar++;
                    }
                    // Check xem SDz có lố quá không
                    if (sdzBar - bar > QuerySdzNum) sdzBar = bar+1;
                    else if (sdzBar >= lastSz) sdzBar = bar+1;
                    lastSz = sdzBar;
                    drawRectangle(APP_TAG + IntegerToString(pIdx++),
                                Time[sdzBar], Time[mtgBar],
                                High[sdzBar], Low[bar+1],
                                SzColor);
                }
            } else if (High[bar+1] < Low[bar-1] && High[bar+2] >= Low[bar]) { // Up IMB
                isClearImb = false;
                mtgBar = bar-1;
                while (mtgBar >= lastBar){
                    if (Low[mtgBar] <= High[bar+1]){
                        if (bar - mtgBar < QueryMgtNum) isClearImb = true;
                        break;
                    }
                    mtgBar--;
                }
                if (isClearImb == false) {
                    // find Sdz
                    sdzBar = bar+1;
                    hiLo = Low[bar];
                    while (sdzBar - bar <= QuerySdzNum){
                        if (Low[sdzBar] <= hiLo){
                            hiLo = Low[sdzBar];
                            if (isInsideBar(sdzBar)) break;
                            if (isPivotLo(sdzBar)) break;
                        }
                        sdzBar++;
                    }
                    // Check xem SDz có lố quá không
                    if (sdzBar - bar > QuerySdzNum) sdzBar = bar+1;
                    else if (sdzBar >= lastDz) sdzBar = bar+1;
                    lastDz = sdzBar;
                    drawRectangle(APP_TAG + IntegerToString(pIdx++),
                                Time[sdzBar], Time[mtgBar],
                                Low[sdzBar], High[bar+1],
                                DzColor);
                }
            }
        }
    }

    string objName;
    do {
        objName  = APP_TAG + IntegerToString(pIdx++);
        ObjectSet(objName, OBJPROP_PRICE1, 0);
        ObjectSet(objName, OBJPROP_PRICE2, 0);
    } while (ObjectFind(objName) >= 0);
}

void createBtnIndiSwitch()
{
    ObjectCreate(gBtnIndiSwitch, OBJ_LABEL, 0, 0, 0);
    ObjectSet(gBtnIndiSwitch, OBJPROP_XDISTANCE, 5);
    ObjectSet(gBtnIndiSwitch, OBJPROP_YDISTANCE, 15);
    ObjectSet(gBtnIndiSwitch, OBJPROP_SELECTABLE, false);
    ObjectSetText(gBtnIndiSwitch, gIndiStage, 10, "Consolas", clrBlack);
    ObjectSetString(ChartID(), gBtnIndiSwitch, OBJPROP_TOOLTIP, "\n");
}