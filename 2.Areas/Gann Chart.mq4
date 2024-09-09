#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property icon      "../3.Resource/Timmy-Ham-học-Logo.ico"
#property version   "2.00"
#property description "Gann Chart:\nUp Bar - Higher High, Higher Low\nDown Bar - Lower High, Lower Low\nInside Bar - Lower High, Higher Low\nOutside Bar - Higher High, Lower Low"
#property strict
#property indicator_chart_window
#define LNSTYLE ENUM_LINE_STYLE

#define APP_TAG "GannChart"
#define UPTREND 1
#define DNTREND -1

#define ISGREEN(bar) Close[bar]>Open[bar]
#define ISRED(bar)   Open[bar]>Close[bar]

enum eStyle {
    eTrend, // TREND
    eSwing, // SWING
    eBoth,  // TREND & SWING
};

enum eGann {
    eGann1, // <1bar>
    eGannP, // <bar+>
    eGann2, // <2bar>
};

input string    _gann;                          // G A N N
input eStyle    InpStyle = eTrend;              // - - - Style
input eGann     InpGannType = eGann2;           // - - - Type
input string    _trend;                         // TREND
input color     InpTrendColor = clrMidnightBlue;// - - - Color
input int       InpTrendWidth = 1;               // - - - Width
input LNSTYLE   InpTrendStyle = STYLE_SOLID;     // - - - Style
input bool      InpTrendBack  = true;            // - - - Back
input string    _label;                         // SWING
input color     InpSwingColor= clrBlack;      // - - - Color
input int       InpSwingSize = 5;               // - - - Size
input int       InpSwingVisblt = 2;             // - - - TF Visibility
input bool      InpSignal = false;              // SIGNAL

// -- System variable
int     gChartScale = (int)ChartGetInteger(0, CHART_SCALE);
int     gChartMode  = (int)ChartGetInteger(0, CHART_MODE);
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
void OnDeinit(const int reason)
{
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
    scanGannSwing();
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
            hideItem(0, "Swing");
            hideItem(0, "Trend");
            hideItem(0, "Signal");
        }
        else {
            gPreFirstBar = 0;
        }
    }
    gChartScale = (int)ChartGetInteger(0, CHART_SCALE);
    gChartMode  = (int)ChartGetInteger(0, CHART_MODE);
    ChartSetInteger(0,CHART_COLOR_CHART_LINE, gChartMode == CHART_LINE ? clrNONE : clrBlack);

    gFirstBar = WindowFirstVisibleBar()-1;
    if (gFirstBar == gPreFirstBar) return;
    gPreFirstBar = gFirstBar;
    scanGannSwing();
}

enum eBarType {
    eBarUp      = UPTREND,
    eBarDn      = DNTREND,
    eBarInside  = 2,
    eBarOutside = 4,
};
eBarType getBarType(int bar)
{
    int preBar = bar+1;
    // Up bar
    if (High[bar] > High[preBar]){
        if (Low[bar] > Low[preBar]) return eBarUp;
        return eBarOutside;
    }
    // Down bar
    if (Low[bar] < Low[preBar]){
        if (High[bar] < High[preBar]) return eBarDn;
        return eBarOutside;
    }
    return eBarInside;
}

int gLastBar2 = 0;
int gLastBar3 = 0;
double gLastHi = 0;
double gLastLo = 0;
void flipTrend(int pivotBar){
    if (InpStyle == eSwing){
        createSwing(gHotBar, gTrend);
    }
    else if (InpStyle == eTrend){
        createTrend(gLastBar, gHotBar, gTrend);
    }
    else {
        createTrend(gLastBar, gHotBar, gTrend);
        createSwing(gHotBar, gTrend);
    }
    gTrend = -gTrend;
    gLastBar3 = gLastBar2;
    gLastBar2 = gLastBar;
    gLastBar = gHotBar;
    gHotBar = pivotBar;
    if (gTrend == UPTREND) gLastLo = Low[gLastBar];
    else gLastHi = High[gLastBar];
}

void scanGannSwing()
{
    if (gIndiOn == false) return;
    if (gFirstBar <= 0) return;
    int bar = gFirstBar;
    int lastBar = gFirstBar - WindowBarsPerChart();
    if (lastBar < 0) lastBar = 0;
    gSwingIdx = 0;
    gTrendIdx = 0;
    gSignalIdx = 0;
    gLastBar = bar+1;
    eBarType barType, preBarType;
    // Init state, find first trend
    for(; bar>=lastBar; bar--) {
        barType = getBarType(bar);
        if (barType >= eBarInside) continue;
        gTrend = barType;
        gHotBar = bar;
        break;
    }
    for(; bar>=lastBar; bar--) {
        barType = getBarType(bar);
        // if (barType == eBarInside) continue;
        if (barType == eBarOutside){
            if (gTrend == DNTREND){
                if (Low[bar] <= Low[gHotBar]) gHotBar = bar;
                if (High[bar] > High[gLastBar]) flipTrend(bar);
            }
            else {
                if (High[bar] >= High[gHotBar]) gHotBar = bar;
                if (Low[bar] < Low[gLastBar]) flipTrend(bar);
            }
        }
        else  if (barType != eBarInside && barType != gTrend) {
            if (InpGannType == eGann1) {
                flipTrend(bar);
            }
            else if (InpGannType == eGann2) {
                preBarType = getBarType(bar+1);
                if (gTrend == DNTREND){
                    if((High[bar] > High[gLastBar])
                    || (preBarType == eBarOutside)
                    || (preBarType == UPTREND)
                    ){
                        flipTrend(bar);
                    }
                }
                else {
                    if((Low[bar] < Low[gLastBar])
                    || (preBarType == eBarOutside)
                    || (preBarType == DNTREND)
                    ){
                        flipTrend(bar);
                    }
                }
            }
            else if (InpGannType == eGannP) {
                preBarType = getBarType(bar+1);
                if (gTrend == DNTREND){
                    if((High[bar] > High[gLastBar])
                    || (preBarType == eBarUp)
                    || (ISGREEN(bar) && preBarType == eBarOutside && ISGREEN(bar+1))
                    || (ISGREEN(bar) && bar == gHotBar-1 && ISGREEN(gHotBar))
                    || (preBarType == eBarInside && getBarType(bar+2) == eBarUp)
                    ){
                        flipTrend(bar);
                    }
                }
                else {
                    if((Low[bar] < Low[gLastBar])
                    || (preBarType == eBarDn)
                    || (ISRED(bar) && preBarType == eBarOutside && ISRED(bar+1))
                    || (ISRED(bar) && bar == gHotBar-1 && ISRED(gHotBar))
                    || (preBarType == eBarInside && getBarType(bar+2) == eBarDn)
                    ){
                        flipTrend(bar);
                    }
                }
            }
        }
        else if (gTrend == UPTREND) {
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

    flipTrend(lastBar);
    hideItem(gSwingIdx, "Swing");
    hideItem(gTrendIdx, "Trend");
    hideItem(gSignalIdx, "Signal");
}


//// Drawing code
int gSwingIdx = 0;
void createSwing(int bar, int trend)
{
    if (gChartScale < InpSwingVisblt) return;
    
    string objName = APP_TAG + "Swing" + IntegerToString(gSwingIdx++);
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
    ObjectSetText(objName, "●", InpSwingSize, NULL, InpSwingColor);
}
int gSignalIdx = 0;
void createSignal(int bar, int trend)
{
    if (gChartScale < InpSwingVisblt) return;
    
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
int gTrendIdx = 0;
void createTrend(int lastBar, int hotBar, int trend){
    string objName = APP_TAG + "Trend" + IntegerToString(gTrendIdx++);
    ObjectCreate(objName, OBJ_TREND, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_RAY, false);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSet(objName, OBJPROP_HIDDEN, true);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    // Style
    ObjectSet(objName, OBJPROP_BACK,  InpTrendBack);
    ObjectSet(objName, OBJPROP_STYLE, InpTrendStyle);
    ObjectSet(objName, OBJPROP_WIDTH, InpTrendWidth);
    // Basic
    ObjectSet(objName, OBJPROP_COLOR, InpTrendColor);
    ObjectSet(objName, OBJPROP_TIME1, Time[lastBar]);
    ObjectSet(objName, OBJPROP_TIME2, Time[hotBar]);
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
