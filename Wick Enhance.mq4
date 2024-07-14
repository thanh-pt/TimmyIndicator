//+------------------------------------------------------------------+
//|                                                 Wick Enhance.mq4 |
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
double         WickUp1Buf[];
double         WickUp2Buf[];
double         WickDn1Buf[];
double         WickDn2Buf[];
double         Body1Buf[];
double         Body2Buf[];


int     gTotalRate = 1;
int     gWickWidth = 0;
int     gBodyWidth = 0;
int     gChartScale = -1;
int     gPreChartScale = -1;
color   gUpClr;
color   gDownClr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    SetIndexBuffer(0,WickUp1Buf);
    SetIndexBuffer(1,WickUp2Buf);
    SetIndexBuffer(2,WickDn1Buf);
    SetIndexBuffer(3,WickDn2Buf);
    SetIndexBuffer(4,Body1Buf);
    SetIndexBuffer(5,Body2Buf);

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
    for (int idx = rates_total-2; idx > 0; idx--) { // ignore first cancel
    
        WickUp1Buf[idx] = EMPTY_VALUE;
        WickUp2Buf[idx] = EMPTY_VALUE;
        WickDn1Buf[idx] = EMPTY_VALUE;
        WickDn2Buf[idx] = EMPTY_VALUE;
        Body1Buf  [idx] = EMPTY_VALUE;
        Body2Buf  [idx] = EMPTY_VALUE;
        
        WickUp1Buf[idx-1] = EMPTY_VALUE;
        WickUp2Buf[idx-1] = EMPTY_VALUE;
        WickDn1Buf[idx-1] = EMPTY_VALUE;
        WickDn2Buf[idx-1] = EMPTY_VALUE;
        Body1Buf  [idx-1] = EMPTY_VALUE;
        Body2Buf  [idx-1] = EMPTY_VALUE;
            
        Body1Buf[idx] = open[idx];
        Body2Buf[idx] = close[idx];

        if (high[idx] <= high[idx+1] && low[idx] >= low[idx+1]){
            Body1Buf[idx] = EMPTY_VALUE;
            Body2Buf[idx] = EMPTY_VALUE;
        }

        if (open[idx] > close[idx]) { // case down
            WickUp1Buf[idx] = high[idx];
            WickUp2Buf[idx] = open[idx];
            WickDn1Buf[idx] = close[idx];
            WickDn2Buf[idx] = low[idx];
        }
        else if (open[idx] < close[idx]){ // case up
            WickUp1Buf[idx] = close[idx];
            WickUp2Buf[idx] = high[idx];
            WickDn1Buf[idx] = low[idx];
            WickDn2Buf[idx] = open[idx];
        }
        else {
            if (open[idx+1] > close[idx+1]) {
                WickUp1Buf[idx] = high[idx];
                WickUp2Buf[idx] = open[idx];
                WickDn1Buf[idx] = close[idx];
                WickDn2Buf[idx] = low[idx];
            }
            else {
                WickUp1Buf[idx] = close[idx];
                WickUp2Buf[idx] = high[idx];
                WickDn1Buf[idx] = low[idx];
                WickDn2Buf[idx] = open[idx];
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
            gBodyWidth = gChartScale;
        }
        else if (gChartScale == 4) {
            gWickWidth = 2;
            gBodyWidth = 6;
        }
        else if (gChartScale == 5) {
            gWickWidth = 3;
            gBodyWidth = 12;
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