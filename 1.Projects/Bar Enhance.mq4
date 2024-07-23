//+------------------------------------------------------------------+
//|                                                  Bar Enhance.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8
//--- buffers
double         WickHi1Buf[];
double         WickHi2Buf[];
double         WickLo1Buf[];
double         WickLo2Buf[];
double         Body1Buf[];
double         Body2Buf[];
double         ImbBuf1[];
double         ImbBuf2[];

int     gTotalRate = 1;

int     gWickWidth = 0;
int     gBodyWidth = 0;

int     gChartScale = -1;
int     gPreChartScale = -1;

color   gUpClr;
color   gDownClr;

bool    gbImbOn = false;


enum EBarMap{
    eBarHi01,
    eBarHi02,
    eBarLo01,
    eBarLo02,
    eBarBd01,
    eBarBd02,
    eBarImb1,
    eBarImb2,
};

input color InpIsbClr = clrWhite;       // Inside Bar Color
input color InpImbClr = clrGoldenrod;   // Imbalance Color
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    SetIndexBuffer(eBarHi01,WickHi1Buf  );
    SetIndexBuffer(eBarHi02,WickHi2Buf  );
    SetIndexBuffer(eBarLo01,WickLo1Buf  );
    SetIndexBuffer(eBarLo02,WickLo2Buf  );
    SetIndexBuffer(eBarBd01,Body1Buf    );
    SetIndexBuffer(eBarBd02,Body2Buf    );
    SetIndexBuffer(eBarImb1,ImbBuf1     );
    SetIndexBuffer(eBarImb2,ImbBuf2     );

    updateStyle();

    if (InpIsbClr != clrNONE) {
        ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BULL, InpIsbClr);
        ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BEAR, InpIsbClr);
    }
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
    gUpClr      = (color)ChartGetInteger(ChartID(),CHART_COLOR_CHART_UP);
    gDownClr    = (color)ChartGetInteger(ChartID(),CHART_COLOR_CHART_DOWN);
    SetIndexStyle(eBarHi01, DRAW_HISTOGRAM, 0, gWickWidth, gDownClr);
    SetIndexStyle(eBarHi02, DRAW_HISTOGRAM, 0, gWickWidth, gUpClr  );
    SetIndexStyle(eBarLo01, DRAW_HISTOGRAM, 0, gWickWidth, gDownClr);
    SetIndexStyle(eBarLo02, DRAW_HISTOGRAM, 0, gWickWidth, gUpClr  );
    SetIndexStyle(eBarBd01, DRAW_HISTOGRAM, 0, gBodyWidth, gDownClr);
    SetIndexStyle(eBarBd02, DRAW_HISTOGRAM, 0, gBodyWidth, gUpClr  );
    SetIndexStyle(eBarImb1, DRAW_HISTOGRAM, 0, gBodyWidth, InpImbClr);
    SetIndexStyle(eBarImb2, DRAW_HISTOGRAM, 0, gBodyWidth, InpImbClr);
}

void loadBarEnhance(int totalBar)
{
    for (int idx = totalBar-2; idx > 0; idx--) { // ignore first cancel
        if (InpIsbClr != clrNONE && High[idx] <= High[idx+1] && Low[idx] >= Low[idx+1]){
            Body1Buf[idx] = EMPTY_VALUE;
            Body2Buf[idx] = EMPTY_VALUE;
        }
        else if (gbImbOn == true && InpImbClr != clrNONE && idx > 1 && (Low[idx+1] > High[idx-1] || High[idx+1] < Low[idx-1])){
            ImbBuf1[idx] = Open[idx];
            ImbBuf2[idx] = Close[idx];
            Body1Buf[idx] = EMPTY_VALUE;
            Body2Buf[idx] = EMPTY_VALUE;
        }
        else {
            Body1Buf[idx] = Open[idx];
            Body2Buf[idx] = Close[idx];
            ImbBuf1[idx] = EMPTY_VALUE;
            ImbBuf2[idx] = EMPTY_VALUE;
        }

        // Wick config
        if (Open[idx] > Close[idx]) { // case down
            WickHi1Buf[idx] = High[idx];
            WickHi2Buf[idx] = Open[idx];
            WickLo1Buf[idx] = Close[idx];
            WickLo2Buf[idx] = Low[idx];
        }
        else if (Open[idx] < Close[idx]){ // case up
            WickHi1Buf[idx] = Close[idx];
            WickHi2Buf[idx] = High[idx];
            WickLo1Buf[idx] = Low[idx];
            WickLo2Buf[idx] = Open[idx];
        }
        else {
            if (Open[idx+1] > Close[idx+1]) {
                WickHi1Buf[idx] = High[idx];
                WickHi2Buf[idx] = Open[idx];
                WickLo1Buf[idx] = Close[idx];
                WickLo2Buf[idx] = Low[idx];
            }
            else {
                WickHi1Buf[idx] = Close[idx];
                WickHi2Buf[idx] = High[idx];
                WickLo1Buf[idx] = Low[idx];
                WickLo2Buf[idx] = Open[idx];
            }
        }
    }
    WickHi1Buf[0] = EMPTY_VALUE;
    WickHi2Buf[0] = EMPTY_VALUE;
    WickLo1Buf[0] = EMPTY_VALUE;
    WickLo2Buf[0] = EMPTY_VALUE;
    Body1Buf  [0] = EMPTY_VALUE;
    Body2Buf  [0] = EMPTY_VALUE;
    ImbBuf1   [0] = EMPTY_VALUE;
    ImbBuf2   [0] = EMPTY_VALUE;

}