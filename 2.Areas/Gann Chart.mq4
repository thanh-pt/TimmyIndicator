#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property icon      "../3.Resource/icons/Chuột.ico"
#property version   "2.00"
#property description "Gann Chart:\nUp Bar - Higher High, Higher Low\nDown Bar - Lower High, Lower Low\nInside Bar - Lower High, Higher Low\nOutside Bar - Higher High, Lower Low"
#property strict
#property indicator_chart_window

#define APP_TAG "*GannChart"
#define UPTREND 1
#define DNTREND -1

#define ISGREEN(bar) (Close[bar]>Open[bar])
#define ISRED(bar)   (Open[bar]>Close[bar])

#include "../3.Resource/ELineStyle.mqh"

enum eStyle {
    eTrend, // TREND
    eSwing, // SWING
    eBoth,  // TREND & SWING
};

input eStyle    InpStyle = eTrend;              // G A N N
input string    _trend;                         // TREND
input color     InpTrendColor = clrSlateGray;   // - - - Color
input ELineStyle InpTrendStyle = eLineSolid;    // - - - Style
input bool      InpTrendBack  = true;           // - - - Back
input string    _label;                         // SWING
input color     InpSwingColor= clrBlack;        // - - - Color
input bool      InpSignal = false;              // SIGNAL (Close Body):
input bool      InpIndiDefaultOn = false;       // Indi default ON:

int InpSwingVisblt = 2; // - - - TF Visibility

// -- System variable
int     gChartScale = (int)ChartGetInteger(0, CHART_SCALE);
int     gChartMode  = (int)ChartGetInteger(0, CHART_MODE);
int     gTotalRate = -1;
bool    gIndiOn = InpIndiDefaultOn;
bool    gSwingSize = false;

// -- Indi variable
int    gLastBar = 0;
int    gHotBar  = 0;
int    gTrend   = 0;
int    gFirstBar = 0;
int    gPreFirstBar = -1;

int OnInit()
{
    gTrendWidth = getLineWidth(InpTrendStyle);
    gTrendStyle = getLineStyle(InpTrendStyle);
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
    
    if (id == CHARTEVENT_KEYDOWN) {
        if (lparam == 'K') {
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
        else if (lparam == 'L') {
            gSwingSize = !gSwingSize;
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
        if (High[preBar] < High[preBar+1] && Low[preBar] > Low[preBar+1]){
            preBar = preBar+1;
            if (High[bar] > High[preBar] && Low[bar] > Low[preBar]) return eBarUp;
            if (Low[bar] < Low[preBar] && High[bar] < High[preBar]) return eBarDn;
        }
        return eBarOutside;
    }
    // Down bar
    if (Low[bar] < Low[preBar]){
        if (High[bar] < High[preBar]) return eBarDn;
        if (High[preBar] < High[preBar+1] && Low[preBar] > Low[preBar+1]){
            preBar = preBar+1;
            if (High[bar] > High[preBar] && Low[bar] > Low[preBar]) return eBarUp;
            if (Low[bar] < Low[preBar] && High[bar] < High[preBar]) return eBarDn;
        }
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
    eBarType barType;
    gLastHi = 0;
    gLastLo = 0;
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

        // Case Bar UP/DOWN bar and BarType != Trend
        if (barType < eBarInside && barType != gTrend) {
            while (1) {
                if (gTrend == DNTREND) {
                    if (ISGREEN(bar) == false && ISGREEN(bar+1) == false && gHotBar == bar+1) break;
                }
                else {
                    if (ISRED(bar) == false && ISRED(bar+1) == false && gHotBar == bar+1) break;
                }

                flipTrend(bar);
                break;
            }
        }
        else if (gTrend == UPTREND) {
            if (High[bar] > High[gHotBar]) gHotBar = bar;
        }
        else {
            if (Low[bar] < Low[gHotBar]) gHotBar = bar;
        }

        if (InpSignal) {
            if (gLastHi != 0 && Close[bar+1] > gLastHi && (High[bar] > High[bar+1]) && Low[gLastBar3] < Low[gLastBar]) {
                createSignal(bar, UPTREND);
                gLastHi = 0;
            }
            if (gLastLo != 0 && Close[bar+1] < gLastLo && (Low[bar] < Low[bar+1]) && High[gLastBar3] > High[gLastBar]) {
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


//// Drawing code ////
int gSwingIdx = 0;
int gSWSize[] = {0,0,7,7,8,9};
void createSwing(int bar, int trend)
{
    if (gChartScale < InpSwingVisblt) return;
    
    string objName = APP_TAG + "Swing" + IntegerToString(gSwingIdx++);
    ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_HIDDEN, true);
    ObjectSet(objName, OBJPROP_BACK, false);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    // Basic
    ObjectSet(objName, OBJPROP_TIME1, Time[bar]);
    if (gSwingSize == true) {
        if (trend == UPTREND) {
            ObjectSet(objName, OBJPROP_PRICE1, High[bar]);
            ObjectSet(objName, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
            ObjectSetText(objName, DoubleToString((High[gHotBar]-Low[gLastBar]) * gPd,0), gSWSize[gChartScale], "Arial", InpSwingColor);
        }
        else {
            ObjectSet(objName, OBJPROP_PRICE1, Low[bar]);
            ObjectSet(objName, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
            ObjectSetText(objName, DoubleToString((High[gLastBar]-Low[gHotBar]) * gPd,0), gSWSize[gChartScale], "Arial", InpSwingColor);
        }
    }
    else {
        if (trend == UPTREND) {
            ObjectSet(objName, OBJPROP_PRICE1, High[bar]);
            ObjectSet(objName, OBJPROP_ANCHOR, ANCHOR_UPPER);
            ObjectSetText(objName, "▀", 4, "consolas", Open[bar] > Close[bar] ? clrCrimson : clrGreen);
        }
        else {
            ObjectSet(objName, OBJPROP_PRICE1, Low[bar]);
            ObjectSet(objName, OBJPROP_ANCHOR, ANCHOR_LOWER);
            ObjectSetText(objName, "▄", 4, "consolas", Open[bar] > Close[bar] ? clrCrimson : clrGreen);
        }
    }
    
}
int gSignalIdx = 0;
void createSignal(int bar, int trend)
{
    if (gChartScale < InpSwingVisblt) return;
    
    string objName = APP_TAG + "Signal" + IntegerToString(gSignalIdx++);
    ObjectCreate(objName, OBJ_TREND, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_RAY, false);
    ObjectSet(objName, OBJPROP_SELECTABLE, true);
    ObjectSet(objName, OBJPROP_HIDDEN, true);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    // Style
    ObjectSet(objName, OBJPROP_BACK,  false);
    ObjectSet(objName, OBJPROP_STYLE, 0);
    ObjectSet(objName, OBJPROP_WIDTH, 2);
    ObjectSet(objName, OBJPROP_TIME1, Time[gLastBar2]);
    ObjectSet(objName, OBJPROP_TIME2, Time[bar+1]);
    // Basic
    if (trend == UPTREND){
        ObjectSet(objName, OBJPROP_COLOR, clrGreen);
        ObjectSet(objName, OBJPROP_PRICE1, High[gLastBar2]);
        ObjectSet(objName, OBJPROP_PRICE2, High[gLastBar2]);
    }
    else {
        ObjectSet(objName, OBJPROP_COLOR, clrRed);
        ObjectSet(objName, OBJPROP_PRICE1, Low[gLastBar2]);
        ObjectSet(objName, OBJPROP_PRICE2, Low[gLastBar2]);
    }
}
int gTrendIdx = 0;
int gTrendWidth = 0;
int gTrendStyle = 0;
double gPd = pow(10, Digits-1);
void createTrend(int lastBar, int hotBar, int trend){
    string objName = APP_TAG + "Trend" + IntegerToString(gTrendIdx++);
    ObjectCreate(objName, OBJ_TREND, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_RAY, false);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSet(objName, OBJPROP_HIDDEN, true);
    // ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    // Style
    ObjectSet(objName, OBJPROP_BACK,  InpTrendBack);
    ObjectSet(objName, OBJPROP_STYLE, gTrendStyle);
    ObjectSet(objName, OBJPROP_WIDTH, gTrendWidth);
    // Basic
    ObjectSet(objName, OBJPROP_COLOR, InpTrendColor);
    ObjectSet(objName, OBJPROP_TIME1, Time[lastBar]);
    ObjectSet(objName, OBJPROP_TIME2, Time[hotBar]);
    if (trend == UPTREND){
        ObjectSet(objName, OBJPROP_PRICE1,  Low[lastBar]);
        ObjectSet(objName, OBJPROP_PRICE2,  High[hotBar]);
        ObjectSetString(0, objName, OBJPROP_TOOLTIP, DoubleToString((High[hotBar]-Low[lastBar]) * gPd,1));
    }
    else {
        ObjectSet(objName, OBJPROP_PRICE1,  High[lastBar]);
        ObjectSet(objName, OBJPROP_PRICE2,  Low[hotBar]);
        ObjectSetString(0, objName, OBJPROP_TOOLTIP, DoubleToString((High[lastBar]-Low[hotBar]) * gPd,1));
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
