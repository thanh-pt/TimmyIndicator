//+------------------------------------------------------------------+
//|                                            Pivot Candlestick.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link "https://www.youtube.com/@TimmyTraderHamHoc"
#property version "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
//--- plot hiPivot
#property indicator_label1 "hiPivot"
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
//--- plot loPivot
#property indicator_label2 "loPivot"
#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrGreen
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#define BULLISH 1
#define BEARISH - 1
#define REVERT - 1

input string Hi_Pivot_Configuration = "";
input color HiPivotColor = clrLightPink;
input int HiPivotCode = 119;
input string Lo_Pivot_Configuration = "";
input color LoPivotColor = clrLightGreen;
input int LoPivotCode = 119;

//--- indicator buffers
double hiPivotBuffer[];
double loPivotBuffer[];

int gPos, gIdx, gPivotIdx, gPreHLIdx, gSymbolDigits;
double gPreHi, gPreLo;
int gCurDir = 0, gPreDir = 0;
bool gIsInsideBar, gIsOutsideBar;
double gIndiGap = 0;
long gChartScale = 0;
long gPreChartScale = 0;

bool isUpBar(const double& open[], const double& close[], int barIdx) {
    return open[barIdx] < close[barIdx];
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    //--- indicator buffers mapping
    SetIndexBuffer(0, hiPivotBuffer);
    SetIndexBuffer(1, loPivotBuffer);
    //--- setting a code from the Wingdings charset as the property of PLOT_ARROW
    SetIndexArrow(0, HiPivotCode);
    SetIndexArrow(1, LoPivotCode);
    SetIndexStyle(0, DRAW_ARROW, 0, 0, HiPivotColor);
    SetIndexStyle(1, DRAW_ARROW, 0, 0, LoPivotColor);
    gSymbolDigits = (int) SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
    //---
    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
    //--- counting from 0 to rates_total
    ArraySetAsSeries(hiPivotBuffer, false);
    ArraySetAsSeries(loPivotBuffer, false);
    ArraySetAsSeries(high, false);
    ArraySetAsSeries(low, false);
    ArraySetAsSeries(open, false);
    ArraySetAsSeries(close, false);

    gPos = prev_calculated;
    if (prev_calculated == 0) {
        gPreHi = high[0];
        gPreLo = low[0];
        gPos = 1;
        gIndiGap = (gPreHi - gPreLo) / 5;
    }
    for (gIdx = gPos; gIdx < rates_total; gIdx++) {
        hiPivotBuffer[gIdx] = EMPTY_VALUE;
        loPivotBuffer[gIdx] = EMPTY_VALUE;

        gIsInsideBar = false;
        gIsOutsideBar = false;
        if (high[gIdx] > gPreHi && low[gIdx] >= gPreLo) gCurDir = BULLISH;
        else if (high[gIdx] <= gPreHi && low[gIdx] < gPreLo) gCurDir = BEARISH;
        else if (high[gIdx] > gPreHi && low[gIdx] < gPreLo) { // Outside bar correction
            gCurDir = gCurDir * REVERT;
            gIsOutsideBar = true;
        } else gIsInsideBar = true;

        if (gPreDir != gCurDir && gPreDir != 0) {
            if (gCurDir == BEARISH) {
                if (gIsOutsideBar && isUpBar(open, close, gIdx)==true ){ // && isUpBar(open, close, gIdx-1) == false) {
                    hiPivotBuffer[gPreHLIdx] = high[gPreHLIdx] + gIndiGap;
                } else if (high[gIdx] < gPreHi) {
                    hiPivotBuffer[gPreHLIdx] = high[gPreHLIdx] + gIndiGap;
                } else {
                    hiPivotBuffer[gIdx] = high[gIdx] + gIndiGap;
                }
            } else {
                if (gIsOutsideBar && isUpBar(open, close, gIdx)==false){ // && isUpBar(open, close, gIdx-1) == true) {
                    loPivotBuffer[gPreHLIdx] = low[gPreHLIdx] - gIndiGap;
                } else if (low[gIdx] > gPreLo) {
                    loPivotBuffer[gPreHLIdx] = low[gPreHLIdx] - gIndiGap;
                } else {
                    loPivotBuffer[gIdx] = low[gIdx] - gIndiGap;
                }
            }
        }
        gPreDir = gCurDir;

        if (gIsInsideBar == false) {
            gPreHi = high[gIdx];
            gPreLo = low[gIdx];
            gPreHLIdx = gIdx;
        }
    }
    //--- return value of prev_calculated for next call
    return (rates_total);
}
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                const long & lparam,
                const double & dparam,
                const string & sparam)
{
    //---
    bool ret = ChartGetInteger(ChartID(), CHART_SCALE, 0, gChartScale);
    if (gChartScale != gPreChartScale) {
        gPreChartScale = gChartScale;
        if (gChartScale < 2) {
            SetIndexStyle(0, DRAW_ARROW, 0, 0, clrNONE);
            SetIndexStyle(1, DRAW_ARROW, 0, 0, clrNONE);
        } else {
            SetIndexStyle(0, DRAW_ARROW, 0, 0, HiPivotColor);
            SetIndexStyle(1, DRAW_ARROW, 0, 0, LoPivotColor);
        }
    }
}