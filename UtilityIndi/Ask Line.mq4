//+------------------------------------------------------------------+
//|                                                     Ask Line.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot AskLine
#property indicator_label1  "AskLine"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_DOT
#property indicator_width1  1
//--- input parameters
input bool     Active=true;
//--- indicator buffers
double         AskLineBuffer[];

int gPos, gIdx, gDigit;
int gPrevCalculated = -1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,AskLineBuffer);
   gDigit = (int)MarketInfo(Symbol(),MODE_DIGITS);
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
   
//--- return value of prev_calculated for next call
   if (gPrevCalculated == prev_calculated && prev_calculated != 0) return (rates_total);
    gPrevCalculated = prev_calculated;
    gPos = prev_calculated;
    if (prev_calculated == 0) {
        gPos = rates_total-2;
    } else {
        gPos = rates_total - prev_calculated;
    }
    gPos = rates_total-2;
    double spreadValue = MarketInfo(Symbol(),MODE_SPREAD);
    for (gIdx = gPos; gIdx >= 0; gIdx--) {
       AskLineBuffer[gIdx] = High[gIdx] + spreadValue/pow(10, gDigit);
    }
    return(rates_total);
  }
//+------------------------------------------------------------------+
