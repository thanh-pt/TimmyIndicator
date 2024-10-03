#property copyright "mt4 tools - WIKI"
#property link      "https://aforexstory.notion.site/1104379b17ec80218296ccaa5eb0ff14"
#property icon      "Imbalance Bar.ico"
#property version   "2.00"
#property description "The Imbalance Bar shows strong momentum in price movement, making it an important part of technical analysis. Clearly spotting imbalances is a significant advantage for any trader.\nGo to WIKI for detail..."
#property strict
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   6

#define MACRO_BderSize gArrSizeMap[gChartScale]
#define MACRO_BodySize gArrSizeMap[gChartScale]-1
//--- buffers
double         IsmbBuf1[];
double         IsmbBuf2[];

double         LineUp01[];
double         LineUp02[];
double         LineDn01[];
double         LineDn02[];

//--- Input
input color     InpColorUp = clrGoldenrod; // Color UP
input color     InpColorDn = clrGoldenrod; // Color DOWN
input string    InpOnOffHotkey = "M";     // Hotkey ON/OFF
input bool      InpDefaultIndiOn = false; // Default ON?


//--- Variable
int     gTotalRate = 1;

int     gChartScale = (int)ChartGetInteger(0, CHART_SCALE);
int     gChartMode  = (int)ChartGetInteger(0, CHART_MODE);
int     gPreChartScale = gChartScale;
int     gPreChartMode  = gChartMode;

color   gBderUpClr;
color   gBderDnClr;

int     gArrSizeMap[6];

bool gbImbOn = InpDefaultIndiOn;

enum EBarMap{
    eBarIsmb1,
    eBarIsmb2,
    eBarLnU01,
    eBarLnU02,
    eBarLnN01,
    eBarLnN02,
};

int OnInit()
{
//--- indicator buffers mapping
    SetIndexBuffer(eBarIsmb1,IsmbBuf1);
    SetIndexBuffer(eBarIsmb2,IsmbBuf2);
    SetIndexBuffer(eBarLnU01,LineUp01);
    SetIndexBuffer(eBarLnU02,LineUp02);
    SetIndexBuffer(eBarLnN01,LineDn01);
    SetIndexBuffer(eBarLnN02,LineDn02);
    // Boder/body size
    gArrSizeMap[0] = 0;
    gArrSizeMap[1] = 1;
    gArrSizeMap[2] = 1;
    gArrSizeMap[3] = 3;
    gArrSizeMap[4] = 6;
    gArrSizeMap[5] = 13;
    // Setup

    updateStyle();

//---
    return(INIT_SUCCEEDED);
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
    loadBarEnhance(gTotalRate);
//--- return value of prev_calculated for next call
    return(rates_total);
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
//---
    if (id == CHARTEVENT_KEYDOWN) {
        if (lparam == InpOnOffHotkey[0]){
            gbImbOn = !gbImbOn;
            loadBarEnhance(gTotalRate);
        }
    }
    gChartScale = (int)ChartGetInteger(0, CHART_SCALE);
    if (gChartScale != gPreChartScale){
        gPreChartScale = gChartScale;
        updateStyle();
    }
    gChartMode  = (int)ChartGetInteger(0, CHART_MODE);
    if (gChartMode != gPreChartMode) {
        gPreChartMode = gChartMode;
        updateStyle();
    }
}

void updateStyle()
{
    bool bVisible = (gChartScale >= 2 && gChartMode == CHART_CANDLES);
    if (bVisible){
        gBderUpClr = (color)ChartGetInteger(0,CHART_COLOR_CHART_UP);
        gBderDnClr = (color)ChartGetInteger(0,CHART_COLOR_CHART_DOWN);
        // Isb/Imb
        SetIndexStyle(eBarIsmb1, DRAW_HISTOGRAM, 0, MACRO_BodySize, InpColorDn);
        SetIndexStyle(eBarIsmb2, DRAW_HISTOGRAM, 0, MACRO_BodySize, InpColorUp);

        // Line Up/down
        SetIndexStyle(eBarLnU01, DRAW_HISTOGRAM, 0, MACRO_BderSize, gBderDnClr);
        SetIndexStyle(eBarLnU02, DRAW_HISTOGRAM, 0, MACRO_BderSize, gBderUpClr);
        SetIndexStyle(eBarLnN01, DRAW_HISTOGRAM, 0, MACRO_BderSize, gBderDnClr);
        SetIndexStyle(eBarLnN02, DRAW_HISTOGRAM, 0, MACRO_BderSize, gBderUpClr);
    } else {
        SetIndexStyle(eBarIsmb1, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarIsmb2, DRAW_HISTOGRAM, 0, 0, clrNONE);

        SetIndexStyle(eBarLnU01, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarLnU02, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarLnN01, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarLnN02, DRAW_HISTOGRAM, 0, 0, clrNONE);
    }
}

void loadBarEnhance(int totalBar)
{
    bool isGreenBar = false;
    bool isDoji     = false;
    bool isFuncBar  = false;
    double lineOffset = 0.000000001;
    for (int idx = totalBar-2; idx >= 0; idx--) { // ignore first cancel
        // Clean Data:
        IsmbBuf1[idx] = EMPTY_VALUE;
        IsmbBuf2[idx] = EMPTY_VALUE;
        LineUp01[idx] = EMPTY_VALUE;
        LineUp02[idx] = EMPTY_VALUE;
        LineDn01[idx] = EMPTY_VALUE;
        LineDn02[idx] = EMPTY_VALUE;
        if (idx <= 1) continue;
        // Define bar type:
        isDoji      = false;
        isFuncBar   = false;
        if      (Open[idx] > Close[idx]) isGreenBar = false;
        else if (Open[idx] < Close[idx]) isGreenBar = true;
        else    {
            isGreenBar = (Open[idx+1] < Close[idx+1]);
            isDoji = true;
        }

        // Imb
        if (isDoji == false) {
            if (gbImbOn == true && (Low[idx+1] > High[idx-1] || High[idx+1] < Low[idx-1])){
                IsmbBuf1[idx] = Open[idx];
                IsmbBuf2[idx] = Close[idx];
                isFuncBar = true;
            }
        }

        // Layer 3 - Line UP/Down -> mang tính chất trang trí
        if (isFuncBar){
            if (isGreenBar){
                LineUp01[idx] = Open[idx];
                LineUp02[idx] = Open[idx]   + lineOffset;
                LineDn01[idx] = Close[idx]  - lineOffset;
                LineDn02[idx] = Close[idx];
            } else {
                LineUp01[idx] = Open[idx];
                LineUp02[idx] = Open[idx]   - lineOffset;
                LineDn01[idx] = Close[idx]  + lineOffset;
                LineDn02[idx] = Close[idx];
            }
        }
    }
}