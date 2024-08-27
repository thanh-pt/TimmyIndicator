#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property icon      "../3.Resource/Timmy-Ham-học-Logo.ico"
#property version   "1.00"
#property description "Gann Chart with some customise for inside bar and outside bar in the rule"
#property strict
#property indicator_chart_window
#define LNSTYLE ENUM_LINE_STYLE

#define APP_TAG "GannChart"
#define UPTREND 0
#define DNTREND 1

enum eStyle {
    eLine, // LINE
    eLabel,// POINT
    eBoth, // LINE & POINT
};

enum eGann {
    eGann1, // 1 bar Gann
    eGann2, // 2 bar Gann
};

input eStyle    InpStyle = eLine;               // W A V E S   S T Y L E
input string    _line;                          // LINE
input color     InpLineColor = clrMidnightBlue;// - - - Color
input int       InpLineWidth = 1;               // - - - Width
input LNSTYLE   InpLineStyle = STYLE_SOLID;     // - - - Style
input bool      InpBackLine  = true;            // - - - Back
input string    _label;                         // H I L O   P O I N T
input color     InpLableColor= clrBlack;      // - - - Color
input int       InpLableSize = 5;               // - - - Size
input int       InpLbTfVisblt = 2;              // - - - TF Visibility
input bool      InpSignal = true;               // - - - Signal
input eGann     InpGannType = eGann2;           // GANN TYPE

// -- System variable
int     gChartScale = (int)ChartGetInteger(0, CHART_SCALE);
int     gChartMode = (int)ChartGetInteger(0, CHART_MODE);
int     gTotalRate = -1;
bool    gIndiOn = true;

// -- Indi variable
int    gLastBar = 0;
int    gHotBar  = 0;
int    gTrend   = 0;
int    gFirstBar = 0;
int    gPreFirstBar = -1;

int OnInit()
{
    return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {
    for (int i = ObjectsTotal() - 1; i >= 0; i--) {
        string objName = ObjectName(i);
        if (StringFind(objName, APP_TAG) != -1) ObjectDelete(objName);
    }
}
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
    gTotalRate = rates_total;
    scanWaves();
    return(rates_total);
}
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if (gTotalRate == -1) return;
    
    if (id == CHARTEVENT_KEYDOWN && lparam == 'K') {
        gIndiOn = !gIndiOn;
        if (gIndiOn == false) {
            hideItem(0, "Label");
            hideItem(0, "Line");
            hideItem(0, "Signal");
        }
        else {
            gPreFirstBar = 0;
        }
    }
    gChartScale = (int)ChartGetInteger(0, CHART_SCALE);
    gChartMode  = (int)ChartGetInteger(0, CHART_MODE);
    if (gChartMode == CHART_LINE){
        ChartSetInteger(0,CHART_COLOR_CHART_LINE, clrNONE);
    } else {
        ChartSetInteger(0,CHART_COLOR_CHART_LINE, clrBlack);
    }

    gFirstBar = WindowFirstVisibleBar()-1;
    if (gFirstBar == gPreFirstBar) return;
    gPreFirstBar = gFirstBar;
    scanWaves();
}

enum eBarType {
    eBarUp      = UPTREND,
    eBarDn      = DNTREND,
    eBarInside  ,
    eBarOutside ,
};
eBarType getBarType(int bar)
{
    int preBar = bar+1;
    // Up bar
    if (High[bar] > High[preBar]){
        if (Low[bar] >= Low[preBar]) return eBarUp;
        return eBarOutside;
    }
    // Down bar
    if (Low[bar] < Low[preBar]){
        if (High[bar] <= High[preBar]) return eBarDn;
        return eBarOutside;
    }
    return eBarInside;
}

int gNoteIdx = 0;
void createLabel(int bar, int trend)
{
    if (gChartScale < InpLbTfVisblt) return;
    
    string objName = APP_TAG + "Label" + IntegerToString(gNoteIdx++);
    ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_BACK, true);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSet(objName, OBJPROP_HIDDEN, true);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    // Basic
    ObjectSet(objName, OBJPROP_TIME1, Time[bar]);
    ObjectSet(objName, OBJPROP_PRICE1, trend == UPTREND ? High[bar] : Low[bar]);
    ObjectSet(objName, OBJPROP_ANCHOR, trend == UPTREND ? ANCHOR_LOWER : ANCHOR_UPPER);
    ObjectSetText(objName, "●", InpLableSize, NULL, InpLableColor);
}
int gSignalIdx = 0;
void createSignal(int bar, int trend)
{
    if (gChartScale < InpLbTfVisblt) return;
    
    string objName = APP_TAG + "Signal" + IntegerToString(gSignalIdx++);
    ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_BACK, true);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSet(objName, OBJPROP_HIDDEN, true);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    // Basic
    ObjectSet(objName, OBJPROP_TIME1, Time[bar]);
    if (trend == UPTREND) {
        ObjectSet(objName, OBJPROP_PRICE1, High[bar]);
        ObjectSet(objName, OBJPROP_ANCHOR, ANCHOR_LOWER);
        ObjectSetText(objName, "■", gChartScale*2, NULL, clrSeaGreen);
    }
    else {
        ObjectSet(objName, OBJPROP_PRICE1, Low[bar]);
        ObjectSet(objName, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetText(objName, "■", gChartScale*2, NULL, clrIndianRed);
    }
}
int gLineIdx = 0;
void createLine(int lastBar, int hotBar, int trend){
    string objName = APP_TAG + "Line" + IntegerToString(gLineIdx++);
    ObjectCreate(objName, OBJ_TREND, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_RAY, false);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSet(objName, OBJPROP_HIDDEN, true);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    // Style
    ObjectSet(objName, OBJPROP_BACK,  InpBackLine);
    ObjectSet(objName, OBJPROP_STYLE, InpLineStyle);
    ObjectSet(objName, OBJPROP_WIDTH, InpLineWidth);
    // Basic
    ObjectSet(objName, OBJPROP_COLOR, InpLineColor);
    ObjectSet(objName, OBJPROP_TIME1,   Time[lastBar]);
    ObjectSet(objName, OBJPROP_TIME2,   Time[hotBar]);
    if (trend == UPTREND){
        ObjectSet(objName, OBJPROP_PRICE1,  Low[lastBar]);
        ObjectSet(objName, OBJPROP_PRICE2,  High[hotBar]);
    }
    else {
        ObjectSet(objName, OBJPROP_PRICE1,  High[lastBar]);
        ObjectSet(objName, OBJPROP_PRICE2,  Low[hotBar]);
    }
}
void hideItem(int index, string tag){
    string objName = APP_TAG + tag + IntegerToString(index);
    while(ObjectFind(objName) >= 0){
        ObjectSet(objName, OBJPROP_TIME1, 0);
        ObjectSet(objName, OBJPROP_TIME2, 0);
        objName = APP_TAG + tag + IntegerToString(index++);
    }
}

int gLastBar2 = 0;
int gLastBar3 = 0;
double gLastHi = 0;
double gLastLo = 0;
void flipTrend(int newTrend, int pivotBar){
    if (InpStyle == eLabel){
        createLabel(gHotBar, gTrend);
    }
    else if (InpStyle == eLine){
        createLine(gLastBar, gHotBar, gTrend);
    }
    else {
        createLine(gLastBar, gHotBar, gTrend);
        createLabel(gHotBar, gTrend);
    }
    gTrend = newTrend;
    gLastBar3 = gLastBar2;
    gLastBar2 = gLastBar;
    gLastBar = gHotBar;
    gHotBar = pivotBar;
    if (gTrend == UPTREND) gLastLo = Low[gLastBar];
    else gLastHi = High[gLastBar];
}

void scanWaves()
{
    if (gIndiOn == false) return;
    if (gFirstBar <= 0) return;
    int lastBar = gFirstBar - WindowBarsPerChart();
    if (lastBar < 0) lastBar = 0;
    gNoteIdx = 0;
    gLineIdx = 0;
    gSignalIdx = 0;
    int bar = gFirstBar;
    eBarType barType;
    gLastBar = bar+1;
    // Init state, find first trend
    for(; bar>=lastBar; bar--) {
        barType = getBarType(bar);
        if (barType == eBarInside || barType == eBarOutside) continue;
        gTrend = barType;
        gHotBar = bar;
        break;
    }
    for(; bar>=lastBar; bar--) {
        barType = getBarType(bar);
        if (barType == eBarInside) continue;
        if (barType == eBarOutside){
            if (gTrend == DNTREND){
                if (Low[bar] <= Low[gHotBar]) gHotBar = bar;
                if (High[bar] > High[gLastBar]) {
                    flipTrend(UPTREND, bar);
                }
            }
            else {
                if (High[bar] >= High[gHotBar]) gHotBar = bar;
                if (Low[bar] < Low[gLastBar]) {
                    flipTrend(DNTREND, bar);
                }
            }
        }
        else  if (barType != gTrend) {
            if (InpGannType == eGann2) {
                if (gTrend == DNTREND){
                    if (High[bar] > High[gLastBar]) {
                        flipTrend(UPTREND, bar);
                    }
                    else if (bar > 1 && Low[bar-1] >= Low[gHotBar]){
                        flipTrend(UPTREND, bar);
                    }
                    else if (getBarType(bar+1) == eBarInside){
                        flipTrend(UPTREND, bar);
                    }
                    else if (getBarType(bar+1) == eBarOutside){
                        flipTrend(UPTREND, bar);
                    }
                }
                else {
                    if (Low[bar] < Low[gLastBar]) {
                        flipTrend(DNTREND, bar);
                    }
                    else if (bar > 1 && High[bar-1] <= High[gHotBar]){
                        flipTrend(DNTREND, bar);
                    }
                    else if (getBarType(bar+1) == eBarInside){
                        flipTrend(DNTREND, bar);
                    }
                    else if (getBarType(bar+1) == eBarOutside){
                        flipTrend(DNTREND, bar);
                    }
                }
            }
            else if (InpGannType == eGann1) {
                flipTrend(barType, bar);
            }
        }
        else if (barType == eBarUp) {
            if (High[bar] >= High[gHotBar]) gHotBar = bar;
        }
        else {
            if (Low[bar] <= Low[gHotBar]) gHotBar = bar;
        }

        if (InpSignal) {
            if (gLastHi != 0 && Close[bar] > gLastHi) {
                createSignal(bar, UPTREND);
                gLastHi = 0;
            }
            if (gLastLo != 0 && Close[bar] < gLastLo) {
                createSignal(bar, DNTREND);
                gLastLo = 0;
            }
        }
    }
    if (InpStyle != eLabel) createLine(gLastBar, gHotBar, gTrend);
    hideItem(gNoteIdx, "Label");
    hideItem(gLineIdx, "Line");
    hideItem(gSignalIdx, "Signal");
}
