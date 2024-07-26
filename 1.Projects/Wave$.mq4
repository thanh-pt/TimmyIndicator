#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property icon      "../3.Resource/Timmy-Ham-học-Logo.ico"
#property version   "1.00"
#property strict
#property indicator_chart_window
#define LNSTYLE ENUM_LINE_STYLE

#define APP_TAG "HiLoPivot"

input bool      InpShowLine  = true;            // - - - WAVE LINE:
input LNSTYLE   InpLineStyle = STYLE_SOLID;     // Style
input int       InpLineWidth = 1;               // Width
input color     InpLineColor = clrBlack;        // Color
input bool      InpBackLine  = false;           // Is Background
input bool      InpShowLable = true;            // - - LABEL:
input color     InpLableColor= clrBlack;        // Color
input int       InpLableSize = 6;               // Size

// -- System variable
int     gChartScale = (int)ChartGetInteger(ChartID(), CHART_SCALE);
int     gTotalRate = -1;
bool    gIndiOn = true;

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
    if (gTotalRate == rates_total) return rates_total;
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

    if (id == CHARTEVENT_CHART_CHANGE) {
        gChartScale = (int)ChartGetInteger(ChartID(), CHART_SCALE);
    }
    else if (id == CHARTEVENT_KEYDOWN && lparam == 'K') {
        gIndiOn = !gIndiOn;
        scanWaves();
    }

    gFirstBar = WindowFirstVisibleBar()-1;
    if (gFirstBar == gOldFirstBar) return;
    gOldFirstBar = gFirstBar;
    scanWaves();
}


#define UPTREND 1
#define DOWNTREND 2

#define POS_HI 0
#define POS_LO 1

enum eBarType {
    eBarUp      ,
    eBarDn      ,
    eBarInside  ,
    eBarOutside ,
};
eBarType getBarType(int bar)
{
    if (High[bar] > High[bar+1]){
        if (Low[bar] >= Low[bar+1]) return eBarUp;
        return eBarOutside;
    }
    if (Low[bar] < Low[bar+1]){
        if (High[bar] <= High[bar+1]) return eBarDn;
        return eBarOutside;
    }
    return eBarInside;
}

int gNoteIdx = 0;
void createLabel(int bar, int pos)
{
    if (InpShowLable == false) return;
    if (gChartScale <=2 ) return;
    string text = "●";
    if (gChartScale == 5) {
        text = IntegerToString((int)((pos == POS_HI ? High[bar] : Low[bar]) * 100000)%100);
    }
    
    string objName = APP_TAG + "Label" + IntegerToString(gNoteIdx++);
    ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_BACK, true);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
    // Basic
    ObjectSet(objName, OBJPROP_TIME1, Time[bar]);
    ObjectSet(objName, OBJPROP_PRICE1, pos == POS_HI ? High[bar] : Low[bar]);
    ObjectSetText(objName, text, InpLableSize, NULL, InpLableColor);
    ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR, pos == POS_HI ? ANCHOR_LOWER : ANCHOR_UPPER);
}
int gLineIdx = 0;
void createLine(int barHi, int barLo){
    if (InpShowLine == false) return;
    string objName = APP_TAG + "Line" + IntegerToString(gLineIdx++);
    ObjectCreate(objName, OBJ_TREND, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_RAY, false);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
    // Style
    ObjectSet(objName, OBJPROP_BACK,  InpBackLine);
    ObjectSet(objName, OBJPROP_STYLE, InpLineStyle);
    ObjectSet(objName, OBJPROP_WIDTH, InpLineWidth);
    // Basic
    ObjectSet(objName, OBJPROP_COLOR, InpLineColor);
    ObjectSet(objName, OBJPROP_TIME1, Time[barHi]);
    ObjectSet(objName, OBJPROP_TIME2, Time[barLo]);
    ObjectSet(objName, OBJPROP_PRICE1, High[barHi]);
    ObjectSet(objName, OBJPROP_PRICE2, Low[barLo]);
}
void hideItem(int index, string tag){
    string objName = APP_TAG + tag + IntegerToString(index);
    while(ObjectFind(objName) >= 0){
        ObjectSet(objName, OBJPROP_TIME1, 0);
        ObjectSet(objName, OBJPROP_TIME2, 0);
        objName = APP_TAG + tag + IntegerToString(index++);
    }
}

double gLastPrice = 0;
int    gLastBar = 0;
int    gHotBar  = 0;
int    gTrend   = 0;
int    gFirstBar = 0;
int    gOldFirstBar = -1;
void scanWaves()
{
    gNoteIdx = 0;
    gLineIdx = 0;
    if (gIndiOn == false) {
        hideItem(gNoteIdx, "Label");
        hideItem(gLineIdx, "Line");
        return;
    }
    if (gFirstBar <= 0) return;
    int bars_count = WindowBarsPerChart();
    int bar = gFirstBar;
    eBarType barType;
    gLastBar = bar-1;
    // Init state, find first trend
    for(; bars_count>0 && bar>=0; bars_count--,bar--) {
        barType = getBarType(bar);
        if (barType == eBarInside || barType == eBarOutside) {
            continue;
        }
        if (barType == eBarUp) {
            gTrend = UPTREND;
            gHotBar = bar;
            gLastPrice = -999999;
        }
        else {
            gTrend = DOWNTREND;
            gHotBar = bar;
            gLastPrice = 999999;
        }
        break;
    }
    for(; bars_count>0 && bar>=0; bars_count--,bar--) {
        barType = getBarType(bar);
        if (barType == eBarInside) continue;
        if (gTrend == UPTREND) {
            if (barType == eBarDn) {
                gTrend = DOWNTREND;
                createLine(gHotBar, gLastBar);
                gLastPrice = High[gHotBar];
                gLastBar = gHotBar;
                gHotBar = bar;
                createLabel(gLastBar, POS_HI);
                continue;
            }
            else if (barType == eBarOutside){
                if (Low[bar] < gLastPrice) {
                    gTrend = DOWNTREND;
                    createLine(bar, gLastBar);
                    gLastPrice = High[bar];
                    gLastBar = bar;
                    gHotBar = bar;
                    createLabel(gLastBar, POS_HI);
                    continue;
                }
            }
            if (High[bar] > High[gHotBar]) gHotBar = bar;
        }
        else {
            if (barType == eBarUp) {
                gTrend = UPTREND;
                createLine(gLastBar, gHotBar);
                gLastPrice = Low[gHotBar];
                gLastBar = gHotBar;
                gHotBar = bar;
                createLabel(gLastBar, POS_LO);
                continue;
            }
            else if (barType == eBarOutside){
                if (High[bar] > gLastPrice){
                    gTrend = UPTREND;
                    createLine(gLastBar, bar);
                    gLastPrice = Low[bar];
                    gLastBar = bar;
                    gHotBar = bar;
                    createLabel(gLastBar, POS_LO);
                    continue;
                }
            }
            if (Low[bar] < Low[gHotBar]) gHotBar = bar;
        }
    }
    if (gTrend == UPTREND) createLine(gHotBar, gLastBar);
    else createLine(gLastBar, gHotBar);
    hideItem(gNoteIdx, "Label");
    hideItem(gLineIdx, "Line");
}


