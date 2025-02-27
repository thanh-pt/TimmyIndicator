//+------------------------------------------------------------------+
//|                                              Imbalance Bar 2.mq5 |
//|                                                            Timmy |
//|                                                            Timmy |
//+------------------------------------------------------------------+
#property copyright "Timmy"
#property link      "Timmy"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   2
//--- plot BearishBar
#property indicator_label1  "BearishBar"
#property indicator_type1   DRAW_CANDLES
#property indicator_color1  clrCrimson, clrGoldenrod
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot BullishBar
#property indicator_label2  "BullishBar"
#property indicator_type2   DRAW_CANDLES
#property indicator_color2  clrDarkGreen, clrGoldenrod
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

input color InpImbalanceColor = clrGoldenrod;
//--- indicator buffers
double         BearishBarBuffer1[];
double         BearishBarBuffer2[];
double         BearishBarBuffer3[];
double         BearishBarBuffer4[];
double         BullishBarBuffer1[];
double         BullishBarBuffer2[];
double         BullishBarBuffer3[];
double         BullishBarBuffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BearishBarBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,BearishBarBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,BearishBarBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,BearishBarBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,BullishBarBuffer1,INDICATOR_DATA);
   SetIndexBuffer(5,BullishBarBuffer2,INDICATOR_DATA);
   SetIndexBuffer(6,BullishBarBuffer3,INDICATOR_DATA);
   SetIndexBuffer(7,BullishBarBuffer4,INDICATOR_DATA);
//---
    color clrUp     = (color)ChartGetInteger(0, CHART_COLOR_CHART_UP);
    color clrDown   = (color)ChartGetInteger(0, CHART_COLOR_CHART_DOWN);
    PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrDown);
    PlotIndexSetInteger(1,PLOT_LINE_COLOR,0,clrUp);
    PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,InpImbalanceColor);
    PlotIndexSetInteger(1,PLOT_LINE_COLOR,1,InpImbalanceColor);

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
    if (rates_total == prev_calculated) return(rates_total);
    for (int i = rates_total-2; i >= 1; i--) {
        BullishBarBuffer1[i] = EMPTY_VALUE;
        BullishBarBuffer2[i] = EMPTY_VALUE;
        BullishBarBuffer3[i] = EMPTY_VALUE;
        BullishBarBuffer4[i] = EMPTY_VALUE;
        BearishBarBuffer1[i] = EMPTY_VALUE;
        BearishBarBuffer2[i] = EMPTY_VALUE;
        BearishBarBuffer3[i] = EMPTY_VALUE;
        BearishBarBuffer4[i] = EMPTY_VALUE;
        if (high[i+1] < low[i-1]) {
            BearishBarBuffer1[i] = open[i];
            BearishBarBuffer2[i] = high[i];
            BearishBarBuffer3[i] = low[i];
            BearishBarBuffer4[i] = close[i];
        }
        else if (low[i+1] > high[i-1]){
            BullishBarBuffer1[i] = open[i];
            BullishBarBuffer2[i] = high[i];
            BullishBarBuffer3[i] = low[i];
            BullishBarBuffer4[i] = close[i];
        }
    }
        /*
    if (rates_total == prev_calculated) {
        if (high[2] < low[0]) {
            BullishBarBuffer1[1] = open[1];
            BullishBarBuffer2[1] = high[1];
            BullishBarBuffer3[1] = low[1];
            BullishBarBuffer4[1] = close[1];
        }
        else if (low[2] > high[0]){
            BearishBarBuffer1[1] = open[1];
            BearishBarBuffer2[1] = high[1];
            BearishBarBuffer3[1] = low[1];
            BearishBarBuffer4[1] = close[1];
        }
        else {
            BullishBarBuffer1[0] = EMPTY_VALUE;
            BullishBarBuffer2[0] = EMPTY_VALUE;
            BullishBarBuffer3[0] = EMPTY_VALUE;
            BullishBarBuffer4[0] = EMPTY_VALUE;
            BearishBarBuffer1[0] = EMPTY_VALUE;
            BearishBarBuffer2[0] = EMPTY_VALUE;
            BearishBarBuffer3[0] = EMPTY_VALUE;
            BearishBarBuffer4[0] = EMPTY_VALUE;
        }
        
        //Print("BullishBarBuffer1 open", BullishBarBuffer1[1]);
        //Print("BearishBarBuffer1 open", BearishBarBuffer1[1]);
        
        // Update bar+1
    }
    else {
        int pos = rates_total - prev_calculated;
        if (pos == rates_total) pos -= 2;
        else pos += 2;
        for (int i = pos; i >= 1; i--) {
            if (high[i+1] < low[i-1]) {
                BullishBarBuffer1[i] = open[i];
                BullishBarBuffer2[i] = high[i];
                BullishBarBuffer3[i] = low[i];
                BullishBarBuffer4[i] = close[i];
            }
            else if (low[i+1] > high[i-1]){
                BearishBarBuffer1[i] = open[i];
                BearishBarBuffer2[i] = high[i];
                BearishBarBuffer3[i] = low[i];
                BearishBarBuffer4[i] = close[i];
            }
            else {
                BullishBarBuffer1[i] = EMPTY_VALUE;
                BullishBarBuffer2[i] = EMPTY_VALUE;
                BullishBarBuffer3[i] = EMPTY_VALUE;
                BullishBarBuffer4[i] = EMPTY_VALUE;
                BearishBarBuffer1[i] = EMPTY_VALUE;
                BearishBarBuffer2[i] = EMPTY_VALUE;
                BearishBarBuffer3[i] = EMPTY_VALUE;
                BearishBarBuffer4[i] = EMPTY_VALUE;
            }
        }
        ChartRedraw();
    }
    */
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
   
  }
//+------------------------------------------------------------------+
