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
#property indicator_buffers 6
#property indicator_plots   6
//--- buffers
double         WickHi1Buf[];
double         WickHi2Buf[];
double         WickLo1Buf[];
double         WickLo2Buf[];
double         Body1Buf[];
double         Body2Buf[];

int     gTotalRate = 1;
int     gWickWidth = 0;
int     gBodyWidth = 0;
int     gChartScale = -1;
int     gPreChartScale = -1;
color   gUpClr;
color   gDownClr;

input color InpInsideBarClr = clrWhite; // Inside Bar Color
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    SetIndexBuffer(0,WickHi1Buf);
    SetIndexBuffer(1,WickHi2Buf);
    SetIndexBuffer(2,WickLo1Buf);
    SetIndexBuffer(3,WickLo2Buf);
    SetIndexBuffer(4,Body1Buf);
    SetIndexBuffer(5,Body2Buf);

    updateStyle();

    if (InpInsideBarClr != clrNONE) {
        ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BULL, InpInsideBarClr);
        ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BEAR, InpInsideBarClr);
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
    for (int idx = rates_total-2; idx > 0; idx--) { // ignore first cancel
    
        WickHi1Buf[idx] = EMPTY_VALUE;
        WickHi2Buf[idx] = EMPTY_VALUE;
        WickLo1Buf[idx] = EMPTY_VALUE;
        WickLo2Buf[idx] = EMPTY_VALUE;
        Body1Buf  [idx] = EMPTY_VALUE;
        Body2Buf  [idx] = EMPTY_VALUE;
        
        WickHi1Buf[idx-1] = EMPTY_VALUE;
        WickHi2Buf[idx-1] = EMPTY_VALUE;
        WickLo1Buf[idx-1] = EMPTY_VALUE;
        WickLo2Buf[idx-1] = EMPTY_VALUE;
        Body1Buf  [idx-1] = EMPTY_VALUE;
        Body2Buf  [idx-1] = EMPTY_VALUE;
            
        Body1Buf[idx] = open[idx];
        Body2Buf[idx] = close[idx];

        if (InpInsideBarClr != clrNONE && high[idx] <= high[idx+1] && low[idx] >= low[idx+1]){
            Body1Buf[idx] = EMPTY_VALUE;
            Body2Buf[idx] = EMPTY_VALUE;
        }

        if (open[idx] > close[idx]) { // case down
            WickHi1Buf[idx] = high[idx];
            WickHi2Buf[idx] = open[idx];
            WickLo1Buf[idx] = close[idx];
            WickLo2Buf[idx] = low[idx];
        }
        else if (open[idx] < close[idx]){ // case up
            WickHi1Buf[idx] = close[idx];
            WickHi2Buf[idx] = high[idx];
            WickLo1Buf[idx] = low[idx];
            WickLo2Buf[idx] = open[idx];
        }
        else {
            if (open[idx+1] > close[idx+1]) {
                WickHi1Buf[idx] = high[idx];
                WickHi2Buf[idx] = open[idx];
                WickLo1Buf[idx] = close[idx];
                WickLo2Buf[idx] = low[idx];
            }
            else {
                WickHi1Buf[idx] = close[idx];
                WickHi2Buf[idx] = high[idx];
                WickLo1Buf[idx] = low[idx];
                WickLo2Buf[idx] = open[idx];
            }
        }
    }
    gTotalRate = rates_total;
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
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


void updateStyle()
{
    gUpClr      = (color)ChartGetInteger(ChartID(),CHART_COLOR_CHART_UP);
    gDownClr    = (color)ChartGetInteger(ChartID(),CHART_COLOR_CHART_DOWN);
    SetIndexStyle(0, DRAW_HISTOGRAM, 0, gWickWidth, gDownClr);
    SetIndexStyle(1, DRAW_HISTOGRAM, 0, gWickWidth, gUpClr  );
    SetIndexStyle(2, DRAW_HISTOGRAM, 0, gWickWidth, gDownClr);
    SetIndexStyle(3, DRAW_HISTOGRAM, 0, gWickWidth, gUpClr  );
    SetIndexStyle(4, DRAW_HISTOGRAM, 0, gBodyWidth, gDownClr);
    SetIndexStyle(5, DRAW_HISTOGRAM, 0, gBodyWidth, gUpClr  );
}