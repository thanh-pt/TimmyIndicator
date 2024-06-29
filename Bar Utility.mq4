//+------------------------------------------------------------------+
//|                                                  Bar Utility.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.01"
#property strict
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8
//--- plot Imb1
#property indicator_label1  "Imb1"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrNONE
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Imb2
#property indicator_label2  "Imb2"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrNONE
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Ins1
#property indicator_label3  "Ins1"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrNONE
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Ins2
#property indicator_label4  "Ins2"
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_color4  clrNONE
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Open1
#property indicator_label5  "Open1"
#property indicator_type5   DRAW_HISTOGRAM
#property indicator_color5  clrBlack
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot Open2
#property indicator_label6  "Open2"
#property indicator_type6   DRAW_HISTOGRAM
#property indicator_color6  clrBlack
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot Close1
#property indicator_label7  "Close1"
#property indicator_type7   DRAW_HISTOGRAM
#property indicator_color7  clrBlack
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot Close2
#property indicator_label8  "Close2"
#property indicator_type8   DRAW_HISTOGRAM
#property indicator_color8  clrBlack
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- Enum Define

//--- input parameters
input color     InpImbUpClr     = clrGoldenrod; // Imbalance Up:
input color     InpImbDnClr     = clrGoldenrod; // Imbalance Down:
input color     InpInsClr       = clrNONE;       // Inside Bar Color:
input string    InpOnOffHotkey  = "M";           // On/Off Hotkey:
color gBoderUp = (color)ChartGetInteger(ChartID(), CHART_COLOR_CHART_UP);
color gBoderDn = (color)ChartGetInteger(ChartID(), CHART_COLOR_CHART_DOWN);
//--- indicator buffers
double         Imb1Buf[];
double         Imb2Buf[];
double         Ins1Buf[];
double         Ins2Buf[];
double         Opn1Buf[];
double         Opn2Buf[];
double         Cls1Buf[];
double         Cls2Buf[];

int  gBarWidth = 13;
long gChartScale = 0;
long gChartMode = 0;
long gPreChartScale = 0;
int  gChartPeriod = ChartPeriod();
bool gOnState = true;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    SetIndexBuffer(0,Imb1Buf);
    SetIndexBuffer(1,Imb2Buf);
    SetIndexBuffer(2,Ins1Buf);
    SetIndexBuffer(3,Ins2Buf);
    SetIndexBuffer(4,Opn1Buf);
    SetIndexBuffer(5,Opn2Buf);
    SetIndexBuffer(6,Cls1Buf);
    SetIndexBuffer(7,Cls2Buf);

    updateStyle();
   
//---
    gChartPeriod = ChartPeriod();
    return(INIT_SUCCEEDED);
}

void fillInsideBarData(int idx)
{
    if (gChartPeriod == PERIOD_D1 && TimeDayOfWeek(Time[idx]) == 0) { // Chủ nhật
        return;
    }
    if (Open[idx] ==  Close[idx]) return;
    Opn1Buf[idx] = Open[idx];
    Opn2Buf[idx] = Open[idx];
    Cls1Buf[idx] = Close[idx];
    Cls2Buf[idx] = Close[idx];

    Ins1Buf[idx] = Close[idx];
    Ins2Buf[idx] = Open [idx];
}

void fillImbalanceData(int idx)
{
    if (Open[idx] ==  Close[idx]) return;
    Opn1Buf[idx] = Open[idx];
    Opn2Buf[idx] = Open[idx];
    Cls1Buf[idx] = Close[idx];
    Cls2Buf[idx] = Close[idx];

    Imb1Buf[idx] = Open[idx];
    Imb2Buf[idx] = Close[idx];
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
        Imb1Buf[idx-1] = EMPTY_VALUE;
        Imb2Buf[idx-1] = EMPTY_VALUE;
        Opn1Buf[idx-1] = EMPTY_VALUE;
        Cls1Buf[idx-1] = EMPTY_VALUE;
        Opn2Buf[idx-1] = EMPTY_VALUE;
        Cls2Buf[idx-1] = EMPTY_VALUE;

        Ins1Buf[idx-1] = EMPTY_VALUE;
        Ins2Buf[idx-1] = EMPTY_VALUE;

        if (low[idx+1] > high[idx-1] || high[idx+1] < low[idx-1]) {
            fillImbalanceData(idx);
        }
        else if (Low[idx] >= Low[idx+1] && High[idx] <= High[idx+1]){
            fillInsideBarData(idx);
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
        gChartScale = ChartGetInteger(ChartID(), CHART_SCALE);
        gChartMode = ChartGetInteger(ChartID(), CHART_MODE);
        if (gChartScale == gPreChartScale) return;
        gPreChartScale = gChartScale;
        if (gChartScale == 2) gBarWidth = 1;
        else if (gChartScale == 3) gBarWidth = 2;
        else if (gChartScale == 4) gBarWidth = 5;
        else if (gChartScale == 5) gBarWidth = 12;
        else {
            // Hide Indicator
            gBarWidth = 0;
            updateStyle();
            return;
        }
        updateStyle();
    }
    else if (id == CHARTEVENT_KEYDOWN && lparam == InpOnOffHotkey[0]) {
        gOnState = !gOnState;
        updateStyle();
    }
}
//+------------------------------------------------------------------+

void updateStyle()
{
    if (gBarWidth == 0 || gOnState == false){
        // Hide Indicator
        SetIndexStyle(0, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(1, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(2, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(3, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(4, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(5, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(6, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(7, DRAW_HISTOGRAM, 0, 0, clrNONE);
    }
    else {
        // Show Indicator
        SetIndexStyle(0, DRAW_HISTOGRAM, 0, gBarWidth, InpImbDnClr);
        SetIndexStyle(1, DRAW_HISTOGRAM, 0, gBarWidth, InpImbUpClr);
        SetIndexStyle(2, DRAW_HISTOGRAM, 0, gBarWidth, InpInsClr);
        SetIndexStyle(3, DRAW_HISTOGRAM, 0, gBarWidth, InpInsClr);
        SetIndexStyle(4, DRAW_HISTOGRAM, 0, gBarWidth+1, gBoderUp);
        SetIndexStyle(5, DRAW_HISTOGRAM, 0, gBarWidth+1, gBoderDn);
        SetIndexStyle(6, DRAW_HISTOGRAM, 0, gBarWidth+1, gBoderUp);
        SetIndexStyle(7, DRAW_HISTOGRAM, 0, gBarWidth+1, gBoderDn);
    }
}
