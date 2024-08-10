#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property icon      "../3.Resource/Timmy-Ham-học-Logo.ico"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 12
#property indicator_plots   12

#define MACRO_WickSize gArrSizeMap[0][gChartScale]
#define MACRO_BderSize gArrSizeMap[1][gChartScale]
#define MACRO_BodySize gArrSizeMap[1][gChartScale]-1
//--- buffers
double         Wick1Buf[];
double         Wick2Buf[];
double         Bder1Buf[];
double         Bder2Buf[];
double         Body1Buf[];
double         Body2Buf[];
double         IsmbBuf1[];
double         IsmbBuf2[];

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
color   gBodyUpClr;
color   gBodyDnClr;

bool    gbImbOn = true;
bool    gbIsbOn = false;

int     gArrSizeMap[2][6];

enum EBarMap{
    eBarWick1,
    eBarWick2,
    eBarBder1,
    eBarBder2,
    eBarBody1,
    eBarBody2,
    eBarIsmb1,
    eBarIsmb2,
    eBarLnU01,
    eBarLnU02,
    eBarLnN01,
    eBarLnN02,
};

input bool  InpFunctionCandle = true;     // Function Candle:
input color InpIsbClr = clrRoyalBlue;   // Inside Bar Color (N)
input color InpImbClr = clrGoldenrod;   // Imbalance Color (M)
input bool InpWickEnhance = false; // Wick Enhance:
input bool InpBodyEnhance = false; // Body Enhance:
input int InpCandle3 = 3;  // Candle 3 (3~5)
input int InpCandle4 = 6;  // Candle 4 (6~9)
input int InpCandle5 = 13; // Candle 5 (13~17)

int OnInit()
{
//--- indicator buffers mapping
    SetIndexBuffer(eBarWick1,Wick1Buf);
    SetIndexBuffer(eBarWick2,Wick2Buf);
    SetIndexBuffer(eBarBder1,Bder1Buf);
    SetIndexBuffer(eBarBder2,Bder2Buf);
    SetIndexBuffer(eBarBody1,Body1Buf);
    SetIndexBuffer(eBarBody2,Body2Buf);
    SetIndexBuffer(eBarIsmb1,IsmbBuf1);
    SetIndexBuffer(eBarIsmb2,IsmbBuf2);
    SetIndexBuffer(eBarLnU01,LineUp01);
    SetIndexBuffer(eBarLnU02,LineUp02);
    SetIndexBuffer(eBarLnN01,LineDn01);
    SetIndexBuffer(eBarLnN02,LineDn02);
    // Wick size
    gArrSizeMap[0][0] = 0;
    gArrSizeMap[0][1] = 0;
    gArrSizeMap[0][2] = 0;
    gArrSizeMap[0][3] = 2;
    gArrSizeMap[0][4] = 2;
    gArrSizeMap[0][5] = 3;
    // Boder/body size
    gArrSizeMap[1][0] = 0;
    gArrSizeMap[1][1] = 1;
    gArrSizeMap[1][2] = 3;  // max 3 <- Inactive
    gArrSizeMap[1][3] = 3 ;
    gArrSizeMap[1][4] = 6 ;
    gArrSizeMap[1][5] = 13;
    if (InpBodyEnhance) {
        gArrSizeMap[1][3] = MathMin(MathMax(InpCandle3, 3 ), 5);  // max 5
        gArrSizeMap[1][4] = MathMin(MathMax(InpCandle4, 6 ), 9);  // max 9
        gArrSizeMap[1][5] = MathMin(MathMax(InpCandle5, 13),17);  // max 17
    }

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
        else if (lparam == 'N'){
            gbIsbOn = !gbIsbOn;
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
        gBodyUpClr = (color)ChartGetInteger(0,CHART_COLOR_CANDLE_BULL);
        gBodyDnClr = (color)ChartGetInteger(0,CHART_COLOR_CANDLE_BEAR);

        // Wick
        SetIndexStyle(eBarWick1, DRAW_HISTOGRAM, 0, MACRO_WickSize, gBderDnClr);
        SetIndexStyle(eBarWick2, DRAW_HISTOGRAM, 0, MACRO_WickSize, gBderUpClr);
        // Boder
        SetIndexStyle(eBarBder1, DRAW_HISTOGRAM, 0, MACRO_BderSize, gBderDnClr);
        SetIndexStyle(eBarBder2, DRAW_HISTOGRAM, 0, MACRO_BderSize, gBderUpClr);
        // Body
        SetIndexStyle(eBarBody1, DRAW_HISTOGRAM, 0, MACRO_BodySize, gBodyDnClr);
        SetIndexStyle(eBarBody2, DRAW_HISTOGRAM, 0, MACRO_BodySize, gBodyUpClr);
        // Isb/Imb
        SetIndexStyle(eBarIsmb1, DRAW_HISTOGRAM, 0, MACRO_BodySize, InpIsbClr);
        SetIndexStyle(eBarIsmb2, DRAW_HISTOGRAM, 0, MACRO_BodySize, InpImbClr);

        // Line Up/down
        SetIndexStyle(eBarLnU01, DRAW_HISTOGRAM, 0, MACRO_BderSize, gBderDnClr);
        SetIndexStyle(eBarLnU02, DRAW_HISTOGRAM, 0, MACRO_BderSize, gBderUpClr);
        SetIndexStyle(eBarLnN01, DRAW_HISTOGRAM, 0, MACRO_BderSize, gBderDnClr);
        SetIndexStyle(eBarLnN02, DRAW_HISTOGRAM, 0, MACRO_BderSize, gBderUpClr);
    } else {
        SetIndexStyle(eBarWick1, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarWick2, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarBder1, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarBder2, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarBody1, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarBody2, DRAW_HISTOGRAM, 0, 0, clrNONE);
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
    bool isDoji = false;
    bool isFuncBar = false;
    double lineOffset = 0.00000001;
    for (int idx = totalBar-2; idx > 0; idx--) { // ignore first cancel
        // Clean Data:
        Wick1Buf[idx] = EMPTY_VALUE;
        Wick2Buf[idx] = EMPTY_VALUE;
        Bder1Buf[idx] = EMPTY_VALUE;
        Bder2Buf[idx] = EMPTY_VALUE;
        Body1Buf[idx] = EMPTY_VALUE;
        Body2Buf[idx] = EMPTY_VALUE;
        IsmbBuf1[idx] = EMPTY_VALUE;
        IsmbBuf2[idx] = EMPTY_VALUE;
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
        if (InpWickEnhance) {
            Wick1Buf[idx] = isGreenBar ? Low[idx]  : High[idx];
            Wick2Buf[idx] = isGreenBar ? High[idx] : Low[idx];
        }

        // Layer 2 - Boder/Body
        if (InpBodyEnhance) {
            Bder1Buf[idx] = Open[idx];
            Bder2Buf[idx] = Close[idx];
            if (isDoji == false) {
                Body1Buf[idx] = Open[idx];
                Body2Buf[idx] = Close[idx];
            }
        }

        // Layer 3 - Isb/Imb
        if (InpFunctionCandle && isDoji == false) {
            if (gbIsbOn == true && InpIsbClr != clrNONE && High[idx] <= High[idx+1] && Low[idx] >= Low[idx+1]){
                IsmbBuf1[idx] = MathMax(Open[idx], Close[idx]);
                IsmbBuf2[idx] = MathMin(Open[idx], Close[idx]);
                isFuncBar = true;
            }
            else if (gbImbOn == true && InpImbClr != clrNONE && idx >= 1 && (Low[idx+1] > High[idx-1] || High[idx+1] < Low[idx-1])){
                IsmbBuf1[idx] = MathMin(Open[idx], Close[idx]);
                IsmbBuf2[idx] = MathMax(Open[idx], Close[idx]);
                isFuncBar = true;
            }
        }

        // Layer 4 - Line UP/Down -> mang tính chất trang trí
        if (isDoji == false && (InpBodyEnhance || isFuncBar)){
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
    Wick1Buf[0] = EMPTY_VALUE;
    Wick2Buf[0] = EMPTY_VALUE;
    Bder1Buf[0] = EMPTY_VALUE;
    Bder2Buf[0] = EMPTY_VALUE;
    Body1Buf[0] = EMPTY_VALUE;
    Body2Buf[0] = EMPTY_VALUE;
    IsmbBuf1[0] = EMPTY_VALUE;
    IsmbBuf2[0] = EMPTY_VALUE;
    LineUp01[0] = EMPTY_VALUE;
    LineUp02[0] = EMPTY_VALUE;
    LineDn01[0] = EMPTY_VALUE;
    LineDn02[0] = EMPTY_VALUE;
}