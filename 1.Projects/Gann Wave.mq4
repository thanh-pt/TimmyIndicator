/* TODO:
*/
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property icon      "../3.Resource/Timmy-Ham-học-Logo.ico"
#property version   "1.00"
#property description "This indi based on Gann Wave rule and some customise for inside bar and outside bar"
#property strict
#property indicator_chart_window
#define LNSTYLE ENUM_LINE_STYLE

#property indicator_buffers 4
#property indicator_plots   4
//--- plot WkHi
#property indicator_label1  "WkHi"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrIndianRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot WkLo
#property indicator_label2  "WkLo"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrSeaGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot BdOp
#property indicator_label3  "BdOp"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrIndianRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  4
//--- plot BdCl
#property indicator_label4  "BdCl"
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_color4  clrSeaGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  4

#define APP_TAG "GannWave"
#define UPTREND 0
#define DNTREND 1

enum eStyle {
    eLine, // WAVE
    eLabel,// POINT
    eBoth, // WAVE & POINT
};

input eStyle    InpStyle = eLine;               // W A V E S   S T Y L E
input string    _line;                          // LINE
input color     InpLineColor = clrSlateGray; // - - - Color
input int       InpLineWidth = 1;               // - - - Width
input LNSTYLE   InpLineStyle = STYLE_SOLID;     // - - - Style
input bool      InpBackLine  = true;            // - - - Back
input string    _label;                         //H I L O   P O I N T
input color     InpLableColor= clrBlack;      // - - - Color
input int       InpLableSize = 6;               // - - - Size
input int       InpLbTfVisblt = 2;              // - - - TF Visibility
input bool      InpPriceLb   = false;           // - - - Price Label
input bool      InpLastBar   = false;           // - - - Last Bar:

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
int    gOldFirstBar = -1;
//--- indicator buffers
double         WkHiBuffer[];
double         WkLoBuffer[];
double         BdOpBuffer[];
double         BdClBuffer[];

int OnInit()
{
    SetIndexBuffer(0,WkHiBuffer);
    SetIndexBuffer(1,WkLoBuffer);
    SetIndexBuffer(2,BdOpBuffer);
    SetIndexBuffer(3,BdClBuffer);

    SetIndexStyle(0, DRAW_HISTOGRAM, 0, 0, clrIndianRed);
    SetIndexStyle(1, DRAW_HISTOGRAM, 0, 0, clrSeaGreen);
    SetIndexStyle(2, DRAW_HISTOGRAM, 0, gChartScale, clrIndianRed);
    SetIndexStyle(3, DRAW_HISTOGRAM, 0, gChartScale, clrSeaGreen);
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
    if (gTotalRate == rates_total) {
        if (gHotBar <= 5 && gChartMode == CHART_LINE && InpLastBar) {
            BdOpBuffer[0] = Open[0];
            BdClBuffer[0] = Close[0];
            if (Open[0] > Close[0]) {
                WkHiBuffer[0] = High[0];
                WkLoBuffer[0] = Low[0];
            }
            else {
                WkHiBuffer[0] = Low[0];
                WkLoBuffer[0] = High[0];
            }
        }
        return rates_total;
    }
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
        if (gChartScale < 2){
            SetIndexStyle(0, DRAW_HISTOGRAM, 0, 0, clrNONE);
            SetIndexStyle(1, DRAW_HISTOGRAM, 0, 0, clrNONE);
            SetIndexStyle(2, DRAW_HISTOGRAM, 0, 0, clrNONE);
            SetIndexStyle(3, DRAW_HISTOGRAM, 0, 0, clrNONE);
        }
        else {
            SetIndexStyle(0, DRAW_HISTOGRAM, 0, 0, clrIndianRed);
            SetIndexStyle(1, DRAW_HISTOGRAM, 0, 0, clrSeaGreen);
            SetIndexStyle(2, DRAW_HISTOGRAM, 0, gChartScale, clrIndianRed);
            SetIndexStyle(3, DRAW_HISTOGRAM, 0, gChartScale, clrSeaGreen);
        }
    }
    else if (id == CHARTEVENT_KEYDOWN && lparam == 'K') {
        gIndiOn = !gIndiOn;
        if (gIndiOn == false) {
            hideItem(0, "Label");
            hideItem(0, "Line");
        }
        else gOldFirstBar = 0;
    }
    gChartMode = (int)ChartGetInteger(0, CHART_MODE);
    if (gChartMode == CHART_LINE){
        ChartSetInteger(0,CHART_COLOR_CHART_LINE, clrNONE);
        if (gHotBar <= 5 && InpLastBar) drawCandle();
    } else {
        ChartSetInteger(0,CHART_COLOR_CHART_LINE, clrBlack);
        hideCandle();
    }

    gFirstBar = WindowFirstVisibleBar()-1;
    if (gFirstBar == gOldFirstBar) return;
    gOldFirstBar = gFirstBar;
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
    if (High[bar] > High[preBar]){
        if (Low[bar] > Low[preBar]) return eBarUp;
        if (Low[bar] == Low[preBar] && Close[bar] > High[preBar]) return eBarUp;
        return eBarOutside;
    }
    if (Low[bar] < Low[preBar]){
        if (High[bar] < High[preBar]) return eBarDn;
        if (High[bar] == High[preBar] && Close[bar] < Low[preBar]) return eBarDn;
        return eBarOutside;
    }
    return eBarInside;
}

int gNoteIdx = 0;
void createLabel(int bar, int trend)
{
    if (gChartScale < InpLbTfVisblt) return;
    string text = "●";
    if (InpPriceLb && gChartScale == 5) text = IntegerToString((int)((trend == UPTREND ? High[bar] : Low[bar]) * 100000)%100);
    
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

int gLastBar2 = 0;
int gLastBar3 = 0;
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
    gLastBar = bar+1;
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
            continue;
        }

        if (barType == eBarInside) barType = (eBarType) gTrend;
        else if (barType != gTrend) {
            flipTrend(barType, bar);
            continue;
        }

        if (barType == eBarUp) {
            if (High[bar] >= High[gHotBar]) gHotBar = bar;
        }
        else {
            if (Low[bar] <= Low[gHotBar]) gHotBar = bar;
        }
    }
    if (InpStyle != eLabel) createLine(gLastBar, gHotBar, gTrend);
    hideItem(gNoteIdx, "Label");
    hideItem(gLineIdx, "Line");
    if (gHotBar <= 5 && gChartMode == CHART_LINE && InpLastBar) drawCandle();
}

void drawCandle()
{
    for (int i = gFirstBar; i >= 0; i--){
        if (i > gLastBar3) {
            BdOpBuffer[i] = EMPTY_VALUE;
            BdClBuffer[i] = EMPTY_VALUE;
            WkHiBuffer[i] = EMPTY_VALUE;
            WkLoBuffer[i] = EMPTY_VALUE;
            continue;
        }
        BdOpBuffer[i] = Open[i];
        BdClBuffer[i] = Close[i];
        if (Open[i] > Close[i]) {
            WkHiBuffer[i] = High[i];
            WkLoBuffer[i] = Low[i];
        }
        else {
            WkHiBuffer[i] = Low[i];
            WkLoBuffer[i] = High[i];
        }
    }
}
void hideCandle()
{
    for (int i = gFirstBar; i >= 0; i--){
        BdOpBuffer[i] = EMPTY_VALUE;
        BdClBuffer[i] = EMPTY_VALUE;
        WkHiBuffer[i] = EMPTY_VALUE;
        WkLoBuffer[i] = EMPTY_VALUE;
    }
}