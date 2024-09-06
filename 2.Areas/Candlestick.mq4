#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property icon      "../3.Resource/Timmy-Ham-học-Logo.ico"
#property version   "1.00"
#property description "Spot Inside/Imbalance Bar\nEnhance Wick for Candlestick Chart"
#property strict
#property indicator_chart_window
#property indicator_buffers 12
#property indicator_plots   12

#define MACRO_BderSize gArrSizeMap[gChartScale]
#define MACRO_BodySize gArrSizeMap[gChartScale]-1
//--- buffers
double         UWK01Buf[];
double         UWK02Buf[];
double         LWK01Buf[];
double         LWK02Buf[];

double         IsmbBuf1[];
double         IsmbBuf2[];

double         HugeBuf1[];
double         HugeBuf2[];

double         LineUp01[];
double         LineUp02[];
double         LineDn01[];
double         LineDn02[];

int     gTotalRate = 1;

int     gChartScale = (int)ChartGetInteger(0, CHART_SCALE);
int     gChartMode  = (int)ChartGetInteger(0, CHART_MODE);
int     gPreChartScale = gChartScale;
int     gPreChartMode  = gChartMode;

color   gBderUpClr;
color   gBderDnClr;

bool    gbImbOn = true;
bool    gbIsbOn = false;
bool    gbHugeOn = false;

int     gArrSizeMap[6];

enum EBarMap{
    eBarUWK01,
    eBarUWK02,
    eBarULK01,
    eBarULK02,
    eBarIsmb1,
    eBarIsmb2,
    eBarHuge1,
    eBarHuge2,
    eBarLnU01,
    eBarLnU02,
    eBarLnN01,
    eBarLnN02,
};
input bool InpIsbDefaultOn = false;     // Inside bar default ON (N)
input bool InpImbDefaultOn = true;      // Imbalance bar default ON (M)
input color InpIsbClr = clrRoyalBlue; // Inside Bar Color
input color InpImbClr = clrGoldenrod; // Imbalance Color
input bool InpWickEnhance = true;       // Wick Enhance

int OnInit()
{
//--- indicator buffers mapping
    SetIndexBuffer(eBarUWK01,UWK01Buf);
    SetIndexBuffer(eBarUWK02,UWK02Buf);
    SetIndexBuffer(eBarULK01,LWK01Buf);
    SetIndexBuffer(eBarULK02,LWK02Buf);
    SetIndexBuffer(eBarIsmb1,IsmbBuf1);
    SetIndexBuffer(eBarIsmb2,IsmbBuf2);
    SetIndexBuffer(eBarHuge1,HugeBuf1);
    SetIndexBuffer(eBarHuge2,HugeBuf2);
    SetIndexBuffer(eBarLnU01,LineUp01);
    SetIndexBuffer(eBarLnU02,LineUp02);
    SetIndexBuffer(eBarLnN01,LineDn01);
    SetIndexBuffer(eBarLnN02,LineDn02);
    // Boder/body size
    gArrSizeMap[0] = 0;
    gArrSizeMap[1] = 1;
    gArrSizeMap[2] = 3;
    gArrSizeMap[3] = 3;
    gArrSizeMap[4] = 6;
    gArrSizeMap[5] = 13;
    // Setup
    gbIsbOn = InpIsbDefaultOn;
    gbImbOn = InpImbDefaultOn;
    gbHugeOn = false;

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
        if (lparam == 'M'){
            gbImbOn = !gbImbOn;
            loadBarEnhance(gTotalRate);
        }
        else if (lparam == '?'){
            gbIsbOn = !gbIsbOn;
            loadBarEnhance(gTotalRate);
        }
        else if (lparam == 'N'){
            gbHugeOn = !gbHugeOn;
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
    bool bVisible = (gChartScale > 2 && gChartMode == CHART_CANDLES);
    if (bVisible){
        gBderUpClr = (color)ChartGetInteger(0,CHART_COLOR_CHART_UP);
        gBderDnClr = (color)ChartGetInteger(0,CHART_COLOR_CHART_DOWN);
        // Wick
        SetIndexStyle(eBarUWK01, DRAW_HISTOGRAM, 0, 0, gBderDnClr);
        SetIndexStyle(eBarUWK02, DRAW_HISTOGRAM, 0, 0, gBderUpClr);
        SetIndexStyle(eBarULK01, DRAW_HISTOGRAM, 0, 0, gBderDnClr);
        SetIndexStyle(eBarULK02, DRAW_HISTOGRAM, 0, 0, gBderUpClr);
        // Isb/Imb
        SetIndexStyle(eBarIsmb1, DRAW_HISTOGRAM, 0, MACRO_BodySize, InpIsbClr);
        SetIndexStyle(eBarIsmb2, DRAW_HISTOGRAM, 0, MACRO_BodySize, InpImbClr);
        SetIndexStyle(eBarHuge1, DRAW_HISTOGRAM, 0, MACRO_BodySize, clrTomato);
        SetIndexStyle(eBarHuge2, DRAW_HISTOGRAM, 0, MACRO_BodySize, clrYellowGreen);

        // Line Up/down
        SetIndexStyle(eBarLnU01, DRAW_HISTOGRAM, 0, MACRO_BderSize, gBderDnClr);
        SetIndexStyle(eBarLnU02, DRAW_HISTOGRAM, 0, MACRO_BderSize, gBderUpClr);
        SetIndexStyle(eBarLnN01, DRAW_HISTOGRAM, 0, MACRO_BderSize, gBderDnClr);
        SetIndexStyle(eBarLnN02, DRAW_HISTOGRAM, 0, MACRO_BderSize, gBderUpClr);
    } else {
        SetIndexStyle(eBarUWK01, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarUWK02, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarULK01, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarULK02, DRAW_HISTOGRAM, 0, 0, clrNONE);
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
    for (int idx = totalBar-2; idx > 0; idx--) { // ignore first cancel
        // Clean Data:
        UWK01Buf[idx] = EMPTY_VALUE;
        UWK02Buf[idx] = EMPTY_VALUE;
        LWK01Buf[idx] = EMPTY_VALUE;
        LWK02Buf[idx] = EMPTY_VALUE;
        IsmbBuf1[idx] = EMPTY_VALUE;
        IsmbBuf2[idx] = EMPTY_VALUE;
        HugeBuf1[idx] = EMPTY_VALUE;
        HugeBuf2[idx] = EMPTY_VALUE;
        LineUp01[idx] = EMPTY_VALUE;
        LineUp02[idx] = EMPTY_VALUE;
        LineDn01[idx] = EMPTY_VALUE;
        LineDn02[idx] = EMPTY_VALUE;
        // Define bar type
        isDoji      = false;
        isFuncBar   = false;
        if      (Open[idx] > Close[idx]) isGreenBar = false;
        else if (Open[idx] < Close[idx]) isGreenBar = true;
        else    {
            isGreenBar = (Open[idx+1] < Close[idx+1]);
            isDoji = true;
        }
        // Layer 1 - Wick
        if (InpWickEnhance){
            if (isGreenBar) {
                UWK01Buf[idx] = Close[idx];
                UWK02Buf[idx] = High[idx];
                LWK01Buf[idx] = Low[idx];
                LWK02Buf[idx] = Open[idx];
            }
            else {
                UWK01Buf[idx] = High[idx];
                UWK02Buf[idx] = Open[idx];
                LWK01Buf[idx] = Close[idx];
                LWK02Buf[idx] = Low[idx];
            }
        }

        // Layer 2 - Isb/Imb
        if (isDoji == false) {
            if (gbIsbOn == true && High[idx] <= High[idx+1] && Low[idx] >= Low[idx+1]){
                IsmbBuf1[idx] = MathMax(Open[idx], Close[idx]);
                IsmbBuf2[idx] = MathMin(Open[idx], Close[idx]);
                isFuncBar = true;
            }
            else if (gbImbOn == true && idx >= 1 && (Low[idx+1] > High[idx-1] || High[idx+1] < Low[idx-1])){
                IsmbBuf1[idx] = MathMin(Open[idx], Close[idx]);
                IsmbBuf2[idx] = MathMax(Open[idx], Close[idx]);
                isFuncBar = true;
            }
            if (gbHugeOn == true && MathAbs(Open[idx] - Close[idx]) >= (High[idx+1] - Low[idx+1])){
                if (isGreenBar) isFuncBar = (Close[idx] > High[idx+1]);
                else isFuncBar = (Close[idx] < Low[idx+1]);
                if (isFuncBar) {
                    HugeBuf1[idx] = Open[idx];
                    HugeBuf2[idx] = Close[idx];
                }
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