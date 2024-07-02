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
#property indicator_buffers 6
#property indicator_plots   6
//--- Enum Define
enum EImbState{
    eImbNONE,
    // eImbUpOnly,
    // eImbDnOnly,
    eImbBoth,
};

enum EBarMap{
    eBarImbDn,
    eBarImbUp,
    eBarOpen1,
    eBarOpen2,
    eBarClos1,
    eBarClos2,
};

//--- input parameters
// input color     InpImbUpClr     = clrGoldenrod; // Imbalance Up:
// input color     InpImbDnClr     = clrGoldenrod; // Imbalance Down:
input color     InpImbBtClr     = clrGoldenrod; // Imbalance Color:
input string    InpOnOffHotkey  = "M";           // On/Off Hotkey:
//--- indicator buffers
double         Imb1Buf[];
double         Imb2Buf[];
double         Opn1Buf[];
double         Opn2Buf[];
double         Cls1Buf[];
double         Cls2Buf[];

int  gBarWidth = 13;
long gChartScale = 0;
long gPreChartScale = 0;
EImbState gImbState = eImbBoth;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    SetIndexBuffer(eBarImbDn, Imb1Buf);
    SetIndexBuffer(eBarImbUp, Imb2Buf);
    SetIndexBuffer(eBarOpen1, Opn1Buf);
    SetIndexBuffer(eBarOpen2, Opn2Buf);
    SetIndexBuffer(eBarClos1, Cls1Buf);
    SetIndexBuffer(eBarClos2, Cls2Buf);

    updateStyle();
   
//---
    return(INIT_SUCCEEDED);
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

        if (low[idx+1] > high[idx-1] || high[idx+1] < low[idx-1]) {
            fillImbalanceData(idx);
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
        if (gImbState == eImbBoth) gImbState = eImbNONE;
        else gImbState++;
        updateStyle();
    }
}
//+------------------------------------------------------------------+

void updateStyle()
{
    if (gBarWidth == 0 || gImbState == eImbNONE){
        // Hide Indicator
        SetIndexStyle(eBarImbDn, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarImbUp, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarOpen1, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarOpen2, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarClos1, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(eBarClos2, DRAW_HISTOGRAM, 0, 0, clrNONE);
    }
    else {
        // Show Indicator
        // if (gImbState == eImbUpOnly) {
        //     SetIndexStyle(eBarImbDn, DRAW_HISTOGRAM, 0, gBarWidth, clrNONE    );
        //     SetIndexStyle(eBarImbUp, DRAW_HISTOGRAM, 0, gBarWidth, InpImbUpClr);
        // }
        // else if (gImbState == eImbDnOnly) {
        //     SetIndexStyle(eBarImbDn, DRAW_HISTOGRAM, 0, gBarWidth, InpImbDnClr);
        //     SetIndexStyle(eBarImbUp, DRAW_HISTOGRAM, 0, gBarWidth, clrNONE    );
        // }
        // else {
            SetIndexStyle(eBarImbDn, DRAW_HISTOGRAM, 0, gBarWidth, InpImbBtClr);
            SetIndexStyle(eBarImbUp, DRAW_HISTOGRAM, 0, gBarWidth, InpImbBtClr);
        // }
        SetIndexStyle(eBarOpen1, DRAW_HISTOGRAM, 0, gBarWidth+1, clrBlack);
        SetIndexStyle(eBarOpen2, DRAW_HISTOGRAM, 0, gBarWidth+1, clrBlack);
        SetIndexStyle(eBarClos1, DRAW_HISTOGRAM, 0, gBarWidth+1, clrBlack);
        SetIndexStyle(eBarClos2, DRAW_HISTOGRAM, 0, gBarWidth+1, clrBlack);
    }
}
