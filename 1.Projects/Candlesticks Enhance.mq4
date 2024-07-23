//+------------------------------------------------------------------+
//|                                         Candlesticks Enhance.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 14
#property indicator_plots   14
//--- buffers
double         Wick1Buf[];
double         Wick2Buf[];
double         Body1Buf[];
double         Body2Buf[];
double         IsmbBuf1[];
double         IsmbBuf2[];

double         LineUp01[];
double         LineUp02[];
double         LineDn01[];
double         LineDn02[];
double         LineUp11[];
double         LineUp12[];
double         LineDn11[];
double         LineDn12[];

int     gTotalRate = 1;

int     gWickWidth = 0;
int     gBodyWidth = 0;

int     gChartScale = -1;
int     gPreChartScale = -1;

color   gBdUpClr;
color   gBdDnClr;
color   gIsUpClr; // Don't use currently
color   gIsDnClr; // Don't use currently

bool    gbImbOn = false;

enum EBarMap{
    eBarWick1,
    eBarWick2,
    eBarBody1,
    eBarBody2,
    eBarIsmb1,
    eBarIsmb2,
    eBarLnU01,
    eBarLnU02,
    eBarLnN01,
    eBarLnN02,
    eBarLnU11,
    eBarLnU12,
    eBarLnN11,
    eBarLnN12,
};

input color InpIsbClr = clrWhite;       // Inside Bar Color
input color InpImbClr = clrGoldenrod;   // Imbalance Color
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    SetIndexBuffer(eBarWick1,Wick1Buf);
    SetIndexBuffer(eBarWick2,Wick2Buf);
    SetIndexBuffer(eBarBody1,Body1Buf);
    SetIndexBuffer(eBarBody2,Body2Buf);
    SetIndexBuffer(eBarIsmb1,IsmbBuf1);
    SetIndexBuffer(eBarIsmb2,IsmbBuf2);
    SetIndexBuffer(eBarLnU01,LineUp01);
    SetIndexBuffer(eBarLnU02,LineUp02);
    SetIndexBuffer(eBarLnN01,LineDn01);
    SetIndexBuffer(eBarLnN02,LineDn02);
    SetIndexBuffer(eBarLnU11,LineUp11);
    SetIndexBuffer(eBarLnU12,LineUp12);
    SetIndexBuffer(eBarLnN11,LineDn11);
    SetIndexBuffer(eBarLnN12,LineDn12);

    updateStyle();

//---
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//---
    if (gTotalRate == rates_total) return rates_total;
    gTotalRate = rates_total;
    loadBarEnhance(gTotalRate);
//--- return value of prev_calculated for next call
    return(rates_total);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
//---
    if (id == CHARTEVENT_CHART_CHANGE) {
        gChartScale = (int)ChartGetInteger(ChartID(), CHART_SCALE);
        if (gChartScale == gPreChartScale) return;
        gPreChartScale = gChartScale;
        
        if (gChartScale == 3) {
            gWickWidth = 2;
            gBodyWidth = 4;
        }
        else if (gChartScale == 4) {
            gWickWidth = 2;
            gBodyWidth = 8;
        }
        else if (gChartScale == 5) {
            gWickWidth = 3;
            gBodyWidth = 15;
        }
        else {
            gWickWidth = 0;
            gBodyWidth = gChartScale;
        }
        updateStyle();
    }
    else if (id == CHARTEVENT_KEYDOWN && lparam == 'M') {
        gbImbOn = !gbImbOn;
        loadBarEnhance(gTotalRate);
    }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


void updateStyle()
{
    gBdUpClr = (color)ChartGetInteger(ChartID(),CHART_COLOR_CHART_UP);
    gBdDnClr = (color)ChartGetInteger(ChartID(),CHART_COLOR_CHART_DOWN);
    gIsUpClr = (color)ChartGetInteger(ChartID(),CHART_COLOR_CANDLE_BULL);
    gIsDnClr = (color)ChartGetInteger(ChartID(),CHART_COLOR_CANDLE_BULL);
    SetIndexStyle(eBarWick1, DRAW_HISTOGRAM, 0, gWickWidth, gBdDnClr);
    SetIndexStyle(eBarWick2, DRAW_HISTOGRAM, 0, gWickWidth, gBdUpClr  );
    SetIndexStyle(eBarBody1, DRAW_HISTOGRAM, 0, gBodyWidth, gBdDnClr);
    SetIndexStyle(eBarBody2, DRAW_HISTOGRAM, 0, gBodyWidth, gBdUpClr  );
    SetIndexStyle(eBarIsmb1, DRAW_HISTOGRAM, 0, gBodyWidth-1, InpIsbClr);
    SetIndexStyle(eBarIsmb2, DRAW_HISTOGRAM, 0, gBodyWidth-1, InpImbClr);

    SetIndexStyle(eBarLnU01, DRAW_HISTOGRAM, 0, gBodyWidth, gBdUpClr);
    SetIndexStyle(eBarLnU02, DRAW_HISTOGRAM, 0, gBodyWidth, gBdUpClr);
    SetIndexStyle(eBarLnN01, DRAW_HISTOGRAM, 0, gBodyWidth, gBdUpClr);
    SetIndexStyle(eBarLnN02, DRAW_HISTOGRAM, 0, gBodyWidth, gBdUpClr);
    SetIndexStyle(eBarLnU11, DRAW_HISTOGRAM, 0, gBodyWidth, gBdDnClr);
    SetIndexStyle(eBarLnU12, DRAW_HISTOGRAM, 0, gBodyWidth, gBdDnClr);
    SetIndexStyle(eBarLnN11, DRAW_HISTOGRAM, 0, gBodyWidth, gBdDnClr);
    SetIndexStyle(eBarLnN12, DRAW_HISTOGRAM, 0, gBodyWidth, gBdDnClr);
}

void loadBarEnhance(int totalBar)
{
    bool isGreenBar = false;
    for (int idx = totalBar-2; idx > 0; idx--) { // ignore first cancel
        if      (Open[idx] > Close[idx]) isGreenBar = false;
        else if (Open[idx] < Close[idx]) isGreenBar = true;
        else    isGreenBar = (Open[idx+1] > Close[idx+1]);
        // Layer 1 - Wick
        Wick1Buf[idx] = isGreenBar ? Low[idx]  : High[idx];
        Wick2Buf[idx] = isGreenBar ? High[idx] : Low[idx];

        // Layer 2 - Body
        Body1Buf[idx] = Open[idx];
        Body2Buf[idx] = Close[idx];

        // Layer 3 - Isb/Imb
        IsmbBuf1[idx] = EMPTY_VALUE;
        IsmbBuf2[idx] = EMPTY_VALUE;
        if (InpIsbClr != clrNONE && High[idx] <= High[idx+1] && Low[idx] >= Low[idx+1]){
            IsmbBuf1[idx] = MathMax(Open[idx], Close[idx]);
            IsmbBuf2[idx] = MathMin(Open[idx], Close[idx]);
        }
        else if (gbImbOn == true && InpImbClr != clrNONE && idx > 1 && (Low[idx+1] > High[idx-1] || High[idx+1] < Low[idx-1])){
            IsmbBuf1[idx] = MathMin(Open[idx], Close[idx]);
            IsmbBuf2[idx] = MathMax(Open[idx], Close[idx]);
        }

        // Layer 4 - Line UP/Down -> mang tính chất trang trí
        LineUp01[idx] = EMPTY_VALUE;
        LineUp02[idx] = EMPTY_VALUE;
        LineDn01[idx] = EMPTY_VALUE;
        LineDn02[idx] = EMPTY_VALUE;
        LineUp11[idx] = EMPTY_VALUE;
        LineUp12[idx] = EMPTY_VALUE;
        LineDn11[idx] = EMPTY_VALUE;
        LineDn12[idx] = EMPTY_VALUE;
        if (isGreenBar){
            LineUp01[idx] = Open[idx];
            LineUp02[idx] = Open[idx];
            LineDn01[idx] = Close[idx];
            LineDn02[idx] = Close[idx];
        } else {
            LineUp11[idx] = Open[idx];
            LineUp12[idx] = Open[idx];
            LineDn11[idx] = Close[idx];
            LineDn12[idx] = Close[idx];
        }
    }
    Wick1Buf[0] = EMPTY_VALUE;
    Wick2Buf[0] = EMPTY_VALUE;
    Body1Buf[0] = EMPTY_VALUE;
    Body2Buf[0] = EMPTY_VALUE;
    IsmbBuf1[0] = EMPTY_VALUE;
    IsmbBuf2[0] = EMPTY_VALUE;
    LineUp01[0] = EMPTY_VALUE;
    LineUp02[0] = EMPTY_VALUE;
    LineDn01[0] = EMPTY_VALUE;
    LineDn02[0] = EMPTY_VALUE;
    LineUp11[0] = EMPTY_VALUE;
    LineUp12[0] = EMPTY_VALUE;
    LineDn11[0] = EMPTY_VALUE;
    LineDn12[0] = EMPTY_VALUE;

}