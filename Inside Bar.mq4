//+------------------------------------------------------------------+
//|                                                    InsideBar.mq4 |
//|                                                    Timmy Ham Học |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 6
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

input color InpColorUp = clrGoldenrod;
input color InpColorDn = clrGoldenrod;

double  ImbH1Buffer[];
double  ImbH2Buffer[];
double  ImbL1Buffer[];
double  ImbL2Buffer[];

double  Bar1[], Bar2[];


int     gBarWidth = 13;
long    gChartScale = 0;
long    gPreChartScale = 0;
int     gChartPeriod;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
    SetIndexBuffer(0, Bar1);
    SetIndexBuffer(1, Bar2);
    SetIndexBuffer(2,ImbH1Buffer);
    SetIndexBuffer(3,ImbH2Buffer);
    SetIndexBuffer(4,ImbL1Buffer);
    SetIndexBuffer(5,ImbL2Buffer);

    SetIndexStyle(0, DRAW_HISTOGRAM, 0, gBarWidth, InpColorUp);
    SetIndexStyle(1, DRAW_HISTOGRAM, 0, gBarWidth, InpColorDn);
   
//---
    gChartPeriod = ChartPeriod();
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
        Bar1[i]        = EMPTY_VALUE;
        Bar2[i]        = EMPTY_VALUE;
        ImbH1Buffer[i] = EMPTY_VALUE;
        ImbL1Buffer[i] = EMPTY_VALUE;
        ImbH2Buffer[i] = EMPTY_VALUE;
        ImbL2Buffer[i] = EMPTY_VALUE;

        if ((Low[i + 1] <= Low[i] && High[i + 1] >= High[i]) || (Low[i + 1] <= Low[i] && High[i + 1] >= High[i])) {
            SetCandleColor(i);
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
        if (gChartScale == 2) gBarWidth = 1;
        else if (gChartScale == 3) gBarWidth = 2;
        else if (gChartScale == 4) gBarWidth = 5;
        else if (gChartScale == 5) gBarWidth = 12;
        else {
            SetIndexStyle(0, DRAW_HISTOGRAM, 0, 0, clrNONE);
            SetIndexStyle(1, DRAW_HISTOGRAM, 0, 0, clrNONE);
            SetIndexStyle(2, DRAW_HISTOGRAM, 0, 0);
            SetIndexStyle(3, DRAW_HISTOGRAM, 0, 0);
            SetIndexStyle(4, DRAW_HISTOGRAM, 0, 0);
            SetIndexStyle(5, DRAW_HISTOGRAM, 0, 0);
            return;
        }
        SetIndexStyle(0, DRAW_HISTOGRAM, 0, gBarWidth, InpColorUp);
        SetIndexStyle(1, DRAW_HISTOGRAM, 0, gBarWidth, InpColorDn);
        SetIndexStyle(2, DRAW_HISTOGRAM, 0, gBarWidth+1);
        SetIndexStyle(3, DRAW_HISTOGRAM, 0, gBarWidth+1);
        SetIndexStyle(4, DRAW_HISTOGRAM, 0, gBarWidth+1);
        SetIndexStyle(5, DRAW_HISTOGRAM, 0, gBarWidth+1);
    }
  }
//+------------------------------------------------------------------+
void SetCandleColor(int i) {
    if (gChartPeriod == PERIOD_D1 && TimeDayOfWeek(Time[i]) == 0) { // Chủ nhật
        return;
    }
    ImbH1Buffer[i] = Close[i];
    ImbH2Buffer[i] = Close[i];
    ImbL1Buffer[i] = Open[i];
    ImbL2Buffer[i] = Open[i];
    Bar1[i] = Close[i];
    Bar2[i] = Open[i];
}