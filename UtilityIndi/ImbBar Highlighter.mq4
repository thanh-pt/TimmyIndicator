//+------------------------------------------------------------------+
//|                                           ImbBar Highlighter.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot ImbHi
#property indicator_label1  "ImbHi"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrSilver
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot ImbLo
#property indicator_label2  "ImbLo"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrSilver
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input color    ImbColor=clrSilver;
//--- indicator buffers
double         ImbHiBuffer[];
double         ImbLoBuffer[];

int BarWidth = 13;
long gChartScale = 0;
long gPreChartScale = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    SetIndexBuffer(0,ImbHiBuffer);
    SetIndexBuffer(1,ImbLoBuffer);

    SetIndexStyle(0, DRAW_HISTOGRAM, 0, BarWidth, ImbColor);
    SetIndexStyle(1, DRAW_HISTOGRAM, 0, BarWidth, ImbColor);
   
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
    double bodyHigh, bodyLow, gap;
    for (int idx = rates_total - 2; idx > 0; idx--) {
        {
            bodyHigh = MathMax(open[idx], close[idx]);
            bodyLow  = MathMin(open[idx], close[idx]);
        }
        gap = (bodyHigh - bodyLow) * 1/90;

        if (low[idx+1] > high[idx-1]) { // Down
            ImbHiBuffer[idx] = open[idx] - gap;
            ImbLoBuffer[idx] = close[idx] + gap;
        } else if (high[idx+1] < low[idx-1]){ // Up
            ImbHiBuffer[idx] = close[idx] - gap;
            ImbLoBuffer[idx] = open[idx] + gap;
        } else {
            ImbHiBuffer[idx] = EMPTY_VALUE;
            ImbLoBuffer[idx] = EMPTY_VALUE;
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
    if (id == CHARTEVENT_CHART_CHANGE) {
        ChartGetInteger(ChartID(), CHART_SCALE, 0, gChartScale);
        if (gChartScale == gPreChartScale) return;
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
        SetIndexStyle(0, DRAW_HISTOGRAM, 0, BarWidth, ImbColor);
        SetIndexStyle(1, DRAW_HISTOGRAM, 0, BarWidth, ImbColor);
    }
}
//+------------------------------------------------------------------+
