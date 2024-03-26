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
#property indicator_buffers 6
#property indicator_plots   6
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
//--- input parameters
//--- input parameters
input color    ImbColor=clrGoldenrod;
input bool     ImbFullBody = false;
//--- indicator buffers
double         ImbHiBuffer[];
double         ImbLoBuffer[];
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
    SetIndexBuffer(0,ImbHiBuffer);
    SetIndexBuffer(1,ImbLoBuffer);
    SetIndexBuffer(2,ImbH1Buffer);
    SetIndexBuffer(3,ImbH2Buffer);
    SetIndexBuffer(4,ImbL1Buffer);
    SetIndexBuffer(5,ImbL2Buffer);

    SetIndexStyle(0, DRAW_HISTOGRAM, 0, BarWidth, ImbColor);
    SetIndexStyle(1, DRAW_HISTOGRAM, 0, BarWidth, ImbColor);
   
//---
    return(INIT_SUCCEEDED);
}

void fillHiLo(int idx, double hiCandle, double loCandle, double hiGap, double loGap)
{
    if (hiCandle - loCandle == 0) return;
    ImbH1Buffer[idx] = hiCandle;
    ImbH2Buffer[idx] = hiCandle;
    ImbL1Buffer[idx] = loCandle;
    ImbL2Buffer[idx] = loCandle;
    if (ImbFullBody == true) {
        ImbHiBuffer[idx] = hiCandle;
        ImbLoBuffer[idx] = loCandle;
    } else if ((hiGap-loGap)/(hiCandle-loCandle) > 0.6){
        ImbHiBuffer[idx] = hiCandle;
        ImbLoBuffer[idx] = loCandle;
    } else {
        ImbHiBuffer[idx] = MathMin(hiCandle, hiGap);
        ImbLoBuffer[idx] = MathMax(loCandle, loGap);
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
    double bodyHigh, bodyLow;
    for (int idx = rates_total - 2; idx > 0; idx--) {
        bodyHigh = MathMax(open[idx], close[idx]);
        bodyLow  = MathMin(open[idx], close[idx]);
        ImbHiBuffer[idx-1] = EMPTY_VALUE;
        ImbLoBuffer[idx-1] = EMPTY_VALUE;
        ImbH1Buffer[idx-1] = EMPTY_VALUE;
        ImbL1Buffer[idx-1] = EMPTY_VALUE;
        ImbH2Buffer[idx-1] = EMPTY_VALUE;
        ImbL2Buffer[idx-1] = EMPTY_VALUE;

        if (low[idx+1] > high[idx-1]) { // Down
            fillHiLo(idx, bodyHigh, bodyLow, low[idx+1], high[idx-1]);
        } else if (high[idx+1] < low[idx-1]){ // Up
            fillHiLo(idx, bodyHigh, bodyLow, low[idx-1], high[idx+1]);
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
        SetIndexStyle(0, DRAW_HISTOGRAM, 0, BarWidth, ImbColor);
        SetIndexStyle(1, DRAW_HISTOGRAM, 0, BarWidth, ImbColor);
        SetIndexStyle(2, DRAW_HISTOGRAM, 0, BarWidth+1);
        SetIndexStyle(3, DRAW_HISTOGRAM, 0, BarWidth+1);
        SetIndexStyle(4, DRAW_HISTOGRAM, 0, BarWidth+1);
        SetIndexStyle(5, DRAW_HISTOGRAM, 0, BarWidth+1);
    }
}
//+------------------------------------------------------------------+
