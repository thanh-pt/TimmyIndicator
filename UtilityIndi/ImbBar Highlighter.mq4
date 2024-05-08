//+------------------------------------------------------------------+
//|                                                Imbalance Bar.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.01"
#property strict
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   6
//--- plot ImbOpen
#property indicator_label1  "ImbOpen"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrSilver
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot ImbClose
#property indicator_label2  "ImbClose"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrSilver
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot ImbH1
#property indicator_label3  "ImbH1"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrBlack
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot ImbH2
#property indicator_label4  "ImbH2"
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_color4  clrBlack
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot ImbL1
#property indicator_label5  "ImbL1"
#property indicator_type5   DRAW_HISTOGRAM
#property indicator_color5  clrBlack
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot ImbL2
#property indicator_label6  "ImbL2"
#property indicator_type6   DRAW_HISTOGRAM
#property indicator_color6  clrBlack
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- Enum Define
enum EImbStyle {
    EFullBody, // Full Body
    EImbOnly,  // Imbalance Only
};

//--- input parameters
input color     ImbColorUp  = clrGoldenrod; // Up Bar Color
input color     ImbColorDn  = clrGoldenrod; // Down Bar Color
input EImbStyle ImbStyle    = EFullBody;    // Style:
//--- indicator buffers
double         ImbOpBuffer[];
double         ImbClBuffer[];
double         ImbH1Buffer[];
double         ImbH2Buffer[];
double         ImbL1Buffer[];
double         ImbL2Buffer[];

int BarWidth = 13;
long gChartScale = 0;
long gPreChartScale = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    SetIndexBuffer(0,ImbOpBuffer);
    SetIndexBuffer(1,ImbClBuffer);
    SetIndexBuffer(2,ImbH1Buffer);
    SetIndexBuffer(3,ImbH2Buffer);
    SetIndexBuffer(4,ImbL1Buffer);
    SetIndexBuffer(5,ImbL2Buffer);

    SetIndexStyle(0, DRAW_HISTOGRAM, 0, BarWidth, ImbColorDn);
    SetIndexStyle(1, DRAW_HISTOGRAM, 0, BarWidth, ImbColorUp);
    SetIndexStyle(2, DRAW_HISTOGRAM, 0, BarWidth+1);
    SetIndexStyle(3, DRAW_HISTOGRAM, 0, BarWidth+1);
    SetIndexStyle(4, DRAW_HISTOGRAM, 0, BarWidth+1);
    SetIndexStyle(5, DRAW_HISTOGRAM, 0, BarWidth+1);
   
//---
    return(INIT_SUCCEEDED);
}

void fillHiLo(int idx, double openPrice, double closePrice, double prePriceGap, double nextPriceGap)
{
    if (openPrice - closePrice == 0) return;
    ImbH1Buffer[idx] = openPrice;
    ImbH2Buffer[idx] = openPrice;
    ImbL1Buffer[idx] = closePrice;
    ImbL2Buffer[idx] = closePrice;
    if (ImbStyle == EFullBody) {
        ImbOpBuffer[idx] = openPrice;
        ImbClBuffer[idx] = closePrice;
    } else {
        ImbOpBuffer[idx] = prePriceGap;
        ImbClBuffer[idx] = nextPriceGap;
    }
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
    for (int idx = rates_total - 2; idx > 0; idx--) {
        ImbOpBuffer[idx-1] = EMPTY_VALUE;
        ImbClBuffer[idx-1] = EMPTY_VALUE;
        ImbH1Buffer[idx-1] = EMPTY_VALUE;
        ImbL1Buffer[idx-1] = EMPTY_VALUE;
        ImbH2Buffer[idx-1] = EMPTY_VALUE;
        ImbL2Buffer[idx-1] = EMPTY_VALUE;

        if (low[idx+1] > high[idx-1]) { // Down
            fillHiLo(idx, open[idx], close[idx], low[idx+1], high[idx-1]);
        } else if (high[idx+1] < low[idx-1]){ // Up
            fillHiLo(idx, open[idx], close[idx], high[idx+1], low[idx-1]);
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
            SetIndexStyle(2, DRAW_HISTOGRAM, 0, 0);
            SetIndexStyle(3, DRAW_HISTOGRAM, 0, 0);
            SetIndexStyle(4, DRAW_HISTOGRAM, 0, 0);
            SetIndexStyle(5, DRAW_HISTOGRAM, 0, 0);
            return;
        }
        SetIndexStyle(0, DRAW_HISTOGRAM, 0, BarWidth, ImbColorDn);
        SetIndexStyle(1, DRAW_HISTOGRAM, 0, BarWidth, ImbColorUp);
        SetIndexStyle(2, DRAW_HISTOGRAM, 0, BarWidth+1);
        SetIndexStyle(3, DRAW_HISTOGRAM, 0, BarWidth+1);
        SetIndexStyle(4, DRAW_HISTOGRAM, 0, BarWidth+1);
        SetIndexStyle(5, DRAW_HISTOGRAM, 0, BarWidth+1);
    }
}
//+------------------------------------------------------------------+
