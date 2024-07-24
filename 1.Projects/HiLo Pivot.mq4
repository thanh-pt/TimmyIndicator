//+------------------------------------------------------------------+
//|                                                   HiLo Pivot.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window
#define LNSTYLE ENUM_LINE_STYLE

#define APP_TAG "HiLoPivot"

input string    _label;                         // - - LABEL CONFIG - -
input bool      InpShowLable = true;            // Show Lable
input color     InpLableColor= clrBlack;        // Color
input int       InpLableSize = 6;               // Size
input string    _line;                          // - - LINE CONFIG - -
input bool      InpShowLine  = true;            // Show Zigzag line
input LNSTYLE   InpLineStyle = STYLE_SOLID;     // Style
input int       InpLineWidth = 1;               // Width
input color     InpLineColor = clrBlack;        // Color
input bool      InpBackLine  = false;           // Is Background

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
    return(rates_total);
}
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    scanWindows();
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
    string text = "●";
    if (ChartGetInteger(ChartID(), CHART_SCALE) == 5) {
        text = IntegerToString((int)((pos == POS_HI ? High[bar] : Low[bar]) * 100000)%100);
    }
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

double lastPrice = 0;
int    lastBar = 0;
int    hotBar = 0;
int    gTrend = 0;
void scanWindows()
{
    gNoteIdx = 0;
    gLineIdx = 0;
    int bars_count=WindowBarsPerChart();
    int bar=WindowFirstVisibleBar()-1;
    int i =0;
    eBarType barType;
    lastBar = bar-1;
    // Init state, find first trend
    for(; i<bars_count && bar>=0; i++,bar--) {
        barType = getBarType(bar);
        if (barType == eBarInside || barType == eBarOutside) {
            continue;
        }
        if (barType == eBarUp) {
            gTrend = UPTREND;
            hotBar = bar;
            lastPrice = -999999;
        }
        else {
            gTrend = DOWNTREND;
            hotBar = bar;
            lastPrice = 999999;
        }
        break;
    }
    for(; i<bars_count && bar>=0; i++,bar--) {
        barType = getBarType(bar);
        if (barType == eBarInside) continue;
        if (gTrend == UPTREND) {
            if (barType == eBarDn) {
                gTrend = DOWNTREND;
                createLine(hotBar, lastBar);
                lastPrice = High[hotBar];
                lastBar = hotBar;
                createLabel(hotBar, POS_HI);
                hotBar = bar;
                continue;
            }
            else if (barType == eBarOutside){
                if (Low[bar] < lastPrice) {
                    gTrend = DOWNTREND;
                    createLine(bar, lastBar);
                    lastPrice = High[bar];
                    lastBar = bar;
                    createLabel(bar, POS_HI);
                    hotBar = bar;
                    continue;
                }
            }
            if (High[bar] > High[hotBar]) hotBar = bar;
        }
        else {
            if (barType == eBarUp) {
                gTrend = UPTREND;
                createLine(lastBar, hotBar);
                lastPrice = Low[hotBar];
                lastBar = hotBar;
                createLabel(hotBar, POS_LO);
                hotBar = bar;
                continue;
            }
            else if (barType == eBarOutside){
                if (High[bar] > lastPrice){
                    gTrend = UPTREND;
                    createLine(lastBar, bar);
                    lastPrice = Low[bar];
                    lastBar = bar;
                    createLabel(bar, POS_LO);
                    hotBar = bar;
                    continue;
                }
            }
            if (Low[bar] < Low[hotBar]) hotBar = bar;
        }
    }
    hideItem(gNoteIdx, "Label");
    hideItem(gLineIdx, "Line");
}


