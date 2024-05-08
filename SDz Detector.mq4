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
#define LineSTYLE ENUM_LINE_STYLE

enum eBdStyle {
    BDSolid = 0, // Solid
    BDDot   = 2, // Dot
    BDNone  = 3, // No Boder
};


input int       QueryMgtNum  = 3;
input int       QuerySdzNum  = 4;
input string    OnOffShortCut = "I";
input string    _1;                             // ● Boder ●
input eBdStyle  BorderStyle  = BDDot;           // Style
input color     SzBdColor     = clrIndianRed;   // Supply
input color     DzBdColor     = clrRoyalBlue;   // Demand

input string    _2;                             // ● Background ●
input bool      DrawBkGrnd    = true;           // Has Bg?
input color     SzBgColor     = C'255,236,234'; // Supply
input color     DzBgColor     = C'244,250,255'; // Demand

bool   gInit            = false;
string gIndiStage       = INDI_ON;
string gBtnIndiSwitch   = APP_TAG + "BtnIndiSwitch";

// Component
string backgrnd;
string brderTop;
string brderBot;
string brderRig;
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

void loadComponent(string id){
    backgrnd = APP_TAG + id + "backgrnd";
    brderTop = APP_TAG + id + "brderTop";
    brderBot = APP_TAG + id + "brderBot";
    brderRig = APP_TAG + id + "brderRig";
}

void hideObj(string obj){
    ObjectSet(obj, OBJPROP_TIME1 , 0);
    ObjectSet(obj, OBJPROP_TIME2 , 0);
}

void updateObj(string obj, datetime time1, datetime time2, double price1, double price2, color c){
    ObjectSet(obj, OBJPROP_SELECTABLE, false);
    ObjectSet(obj, OBJPROP_BACK , true);
    ObjectSet(obj, OBJPROP_RAY  , false);
    ObjectSet(obj, OBJPROP_WIDTH, 0);
    ObjectSet(obj, OBJPROP_STYLE, BorderStyle);
    ObjectSet(obj, OBJPROP_COLOR, c);
    ObjectSet(obj, OBJPROP_TIME1 , time1);
    ObjectSet(obj, OBJPROP_TIME2 , time2);
    ObjectSet(obj, OBJPROP_PRICE1, price1);
    ObjectSet(obj, OBJPROP_PRICE2, price2);
    ObjectSetString( 0, obj, OBJPROP_TOOLTIP,"\n");
}

void drawSDz(string id, datetime time1, datetime time2, double price1, double price2, color bgColor, color bdColor){
    loadComponent(id);
    if (DrawBkGrnd) {
        ObjectCreate(backgrnd, OBJ_RECTANGLE , 0, 0, 0);
        updateObj(backgrnd, time1, time2, price1, price2, bgColor);
        ObjectSetInteger(ChartID(), backgrnd, OBJPROP_HIDDEN, true);
    } else {
        hideObj(backgrnd);
    }
    if (BorderStyle != BDNone){
        ObjectCreate(brderTop, OBJ_TREND , 0, 0, 0);
        ObjectCreate(brderBot, OBJ_TREND , 0, 0, 0);
        ObjectCreate(brderRig, OBJ_TREND , 0, 0, 0);
        ObjectSetInteger(ChartID(), brderTop, OBJPROP_HIDDEN, true);
        ObjectSetInteger(ChartID(), brderBot, OBJPROP_HIDDEN, true);
        ObjectSetInteger(ChartID(), brderRig, OBJPROP_HIDDEN, true);
        updateObj(brderTop, time1, time2, price1, price1, bdColor);
        updateObj(brderBot, time1, time2, price2, price2, bdColor);
        updateObj(brderRig, time2, time2, price1, price2, bdColor);
    } else {
        hideObj(brderTop);
        hideObj(brderBot);
        hideObj(brderRig);
    }
}

bool hideSDz(string id){
    loadComponent(id);
    if (ObjectFind(backgrnd) >= 0 || ObjectFind(brderTop) >= 0){
        hideObj(backgrnd);
        hideObj(brderTop);
        hideObj(brderBot);
        hideObj(brderRig);
        return true;
    }
    return false;
}

bool isInsideBar(int barIdx){
    // if (Low[barIdx] >= Low[barIdx+1] && High[barIdx] <= High[barIdx+1]) return true;
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
            if (Low[bar+1] > High[bar-1] && Low[bar+2] <= High[bar]) { // Down IMB => Supply Zone
                isClearImb = false;
                mtgBar = bar-1;
                while (mtgBar >= lastBar){
                    if (High[mtgBar] >= Low[bar+1]){
                        if (bar - mtgBar <= QueryMgtNum) isClearImb = true;
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
                    if (sdzBar - bar > QuerySdzNum || sdzBar >= lastSz) {
                        sdzBar = (High[bar+1] > High[bar]) ? bar+1 : bar;
                    }
                    lastSz = bar;
                    drawSDz(IntegerToString(pIdx++),
                            Time[sdzBar], Time[mtgBar],
                            High[sdzBar], Low[bar+1],
                            SzBgColor, SzBdColor);
                }
            } else if (High[bar+1] < Low[bar-1] && High[bar+2] >= Low[bar]) { // Up IMB => Demand Zone
                isClearImb = false;
                mtgBar = bar-1;
                while (mtgBar >= lastBar){
                    if (Low[mtgBar] <= High[bar+1]){
                        if (bar - mtgBar <= QueryMgtNum) isClearImb = true;
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
                    if (sdzBar - bar > QuerySdzNum || sdzBar >= lastDz) {
                        sdzBar = (Low[bar+1] < Low[bar]) ? bar+1 : bar;
                    }
                    lastDz = bar;
                    drawSDz(IntegerToString(pIdx++),
                            Time[sdzBar], Time[mtgBar],
                            Low[sdzBar], High[bar+1],
                            DzBgColor, DzBdColor);
                }
            }
        }
    }

    while (hideSDz(IntegerToString(pIdx++))){}
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