//+------------------------------------------------------------------+
//|                                                   InsideBars.mq4 |
//|                                                    Timmy Ham Học |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2

input color upCandleColor = clrDarkOrange;
input color downCandleColor = clrDarkOrange;
int BarWidth = 13;
long gChartScale = 0;
long gPreChartScale = 0;
double Bar1[], Bar2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
    SetIndexBuffer(0, Bar1);
    SetIndexBuffer(1, Bar2);

    SetIndexStyle(0, DRAW_HISTOGRAM, 0, BarWidth, upCandleColor);
    SetIndexStyle(1, DRAW_HISTOGRAM, 0, BarWidth, downCandleColor);
   
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
    int limit, i;
    int counted_bars = IndicatorCounted();

    //---- check for possible errors
    if (counted_bars < 0) return (-1);

    //---- initial zero

    //---- last counted bar will be recounted
    if (counted_bars > 0) counted_bars--;
    limit = Bars - counted_bars;

    //----Calculation---------------------------
    for (i = 0; i < limit-1; i++) {
        Bar1[i] = 0;
        Bar2[i] = 0;
        if (Low[i + 1] <= Low[i] && High[i + 1] >= High[i] && Close[i] > Open[i]) {
            SetCandleColor(1, i); // 
        } else if (Low[i + 1] <= Low[i] && High[i + 1] >= High[i] && Open[i] > Close[i]) {
            SetCandleColor(2, i); // 
        }
    }
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
    bool ret = ChartGetInteger(ChartID(), CHART_SCALE, 0, gChartScale);
    if (gChartScale != gPreChartScale) {
        gPreChartScale = gChartScale;
        if (gChartScale == 2) BarWidth = 1;
        else if (gChartScale == 3) BarWidth = 2;
        else if (gChartScale == 4) BarWidth = 5;
        else if (gChartScale == 5) BarWidth = 12;
        else {
            SetIndexStyle(0, DRAW_HISTOGRAM, 0, 0, clrNONE);
            SetIndexStyle(1, DRAW_HISTOGRAM, 0, 0, clrNONE);
            return;
        }
        SetIndexStyle(0, DRAW_HISTOGRAM, 0, BarWidth, upCandleColor);
        SetIndexStyle(1, DRAW_HISTOGRAM, 0, BarWidth, downCandleColor);
    }
  }
//+------------------------------------------------------------------+
void SetCandleColor(int col, int i) {
    double bodyHigh, bodyLow;
    {
        bodyHigh = MathMax(Open[i], Close[i]);
        bodyLow = MathMin(Open[i], Close[i]);
    }
    double gap = (bodyHigh - bodyLow) * 1/100;
    Bar1[i] = bodyLow + gap;
    Bar2[i] = bodyLow + gap;

    switch (col) {
    case 1:
        Bar1[i] = bodyHigh - gap;
        break;

    case 2:
        Bar2[i] = bodyHigh - gap;
        break;
    }
}