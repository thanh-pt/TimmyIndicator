/* TODO:
*/
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property icon      "../3.Resource/Timmy-Ham-học-Logo.ico"
#property version   "1.00"
#property strict
#property indicator_chart_window
#define LNSTYLE ENUM_LINE_STYLE

#define APP_TAG "HiLoPivot"

enum eStyle {
    eLine, // Line
    eLabel,// Label
    eBoth, // Line & Label
};

input eStyle    InpStyle = eLine;               // W A V E S   S T Y L E
input string    _line;                          // - - - LINE:
input LNSTYLE   InpLineStyle = STYLE_SOLID;     // Style
input int       InpLineWidth = 1;               // Width
input color     InpLineColor = clrSlateGray; // Color
input bool      InpBackLine  = true;            // Is Back
input string    _label;                         // - - LABEL:
input color     InpLableColor= clrBlack;        // Color
input int       InpLableSize = 6;               // Size
input int       InpLbTfVisblt = 2;              // TF Visibility

// -- System variable
int     gChartScale = (int)ChartGetInteger(0, CHART_SCALE);
int     gTotalRate = -1;
bool    gIndiOn = true;

// -- Indi variable
int    gLastBar = 0;
int    gHotBar  = 0;
int    gTrend   = 0;
int    gFirstBar = 0;
int    gOldFirstBar = -1;

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
        gChartScale = (int)ChartGetInteger(0, CHART_SCALE);
    }
    else if (id == CHARTEVENT_KEYDOWN && lparam == 'K') {
        gIndiOn = !gIndiOn;
        if (gIndiOn == false) {
            hideItem(0, "Label");
            hideItem(0, "Line");
        }
        else gOldFirstBar = 0;
    }

    if (ChartGetInteger(0, CHART_MODE) == CHART_LINE){
        ChartSetInteger(0,CHART_COLOR_CHART_LINE, clrNONE);
    } else {
        ChartSetInteger(0,CHART_COLOR_CHART_LINE, clrBlack);
    }

    gFirstBar = WindowFirstVisibleBar()-1;
    if (gFirstBar == gOldFirstBar) return;
    gOldFirstBar = gFirstBar;
    scanWaves();
}

#define UPTREND 0
#define DNTREND 1

enum eBarType {
    eBarUp      = UPTREND,
    eBarDn      = DNTREND,
    eBarInside  ,
    eBarOutside ,
};
eBarType getBarType(int bar)
{
    int preBar = bar+1;
    // if (High[preBar] < High[preBar+1] && Low[preBar] > Low[preBar+1]) preBar = bar + 2;
    if (High[bar] > High[preBar]){
        if (Low[bar] >= Low[preBar]) return eBarUp;
        return eBarOutside;
    }
    if (Low[bar] < Low[preBar]){
        if (High[bar] <= High[preBar]) return eBarDn;
        return eBarOutside;
    }
    return eBarInside;
}

eBarType getBarDirection(int bar)
{
    if (Open[bar] > Close[bar]) return eBarDn;
    if (Open[bar] < Close[bar]) return eBarUp;
    return eBarInside;
}

int gNoteIdx = 0;
void createLabel(int bar, int trend)
{
    if (gChartScale < InpLbTfVisblt) return;
    string text = "●";
    if (gChartScale == 5) text = IntegerToString((int)((trend == UPTREND ? High[bar] : Low[bar]) * 100000)%100);
    
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
    ObjectSetText(objName, text, InpLableSize, NULL, InpLableColor);
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
    gLastBar = gHotBar;
    gHotBar = pivotBar;
}

void scanWaves()
{
    gNoteIdx = 0;
    gLineIdx = 0;
    if (gIndiOn == false) return;
    if (gFirstBar <= 0) return;
    int bars_count = WindowBarsPerChart();
    int bar = gFirstBar;
    eBarType barType;
    gLastBar = bar-1;
    // Init state, find first trend
    for(; bars_count>0 && bar>=0; bars_count--,bar--) {
        barType = getBarType(bar);
        if (barType == eBarInside || barType == eBarOutside) continue;
        gTrend = barType;
        gHotBar = bar;
        break;
    }
    for(; bars_count>0 && bar>=0; bars_count--,bar--) {
        barType = getBarType(bar);
        if (barType == eBarInside) continue;
        // if (barType == eBarInside) barType = (gTrend  == DNTREND ? UPTREND : DNTREND);

        if (barType == gTrend) {
            if (barType == eBarUp && (High[bar] > High[gHotBar])) gHotBar = bar;
            else if (barType == eBarDn && (Low[bar] < Low[gHotBar])) gHotBar = bar;
            continue;
        }

        if (barType == eBarOutside){
            if (gTrend == DNTREND){
                if (bar > 1 && getBarType(bar-1) != UPTREND ){
                    flipTrend(UPTREND, bar);
                    flipTrend(DNTREND, bar);
                }
                else if (High[bar] > High[gLastBar]){
                    gHotBar = bar;
                    flipTrend(UPTREND, bar);
                } else if (Low[bar] < Low[gHotBar]) gHotBar = bar;
            }
            else {
                if (bar > 1 && getBarType(bar-1) != DNTREND){
                    flipTrend(DNTREND, bar);
                    flipTrend(UPTREND, bar);
                }
                else if (Low[bar] < Low[gLastBar]){
                    gHotBar = bar;
                    flipTrend(DNTREND, bar);
                } else if (High[bar] > High[gHotBar]) gHotBar = bar;
            }
            continue;
        }
        flipTrend(barType, bar);
    }
    createLine(gLastBar, gHotBar, gTrend);
    hideItem(gNoteIdx, "Label");
    hideItem(gLineIdx, "Line");
}
