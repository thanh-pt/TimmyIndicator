//+------------------------------------------------------------------+
//|                                           InsideBarHighlight.mq4 |
//|                                                    Timmy Ham Học |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2

#define APP_TAG "InsideBar"

#define DISPLAY_ON  "[Indi] InsideBar - ON"
#define DISPLAY_OFF "[Indi] InsideBar - OFF"

input color upCandleColor = clrDarkOrange;
input color downCandleColor = clrDarkOrange;
int BarWidth = 13;
long gChartScale = 0;
long gPreChartScale = 0;
double Bar1[], Bar2[];
int gChartPeriod;

// Component
string sBtnDisplaySetting;
// State
string gdisplayState = DISPLAY_OFF;
bool   gDeinitState = false;
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
    gChartPeriod = ChartPeriod();

    sBtnDisplaySetting = APP_TAG + "Control" + "btnDisplaySetting";
    CreateIndiObjects();
    return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason) {
    gDeinitState = true;
    for (int i = ObjectsTotal() - 1; i >= 0; i--) {
        string objName = ObjectName(i);
        if (StringFind(objName, APP_TAG) != -1) ObjectDelete(objName);
    }
}
void CreateIndiObjects(){
    if (ObjectFind(sBtnDisplaySetting) < 0){
        ObjectCreate(sBtnDisplaySetting, OBJ_LABEL, 0, 0, 0);
        ObjectSetString(ChartID(), sBtnDisplaySetting, OBJPROP_TOOLTIP, "\n");
        ObjectSet(sBtnDisplaySetting, OBJPROP_SELECTABLE, false);
        ObjectSet(sBtnDisplaySetting, OBJPROP_XDISTANCE, 5);
        ObjectSet(sBtnDisplaySetting, OBJPROP_YDISTANCE, 25);
        long foregroundColor=clrBlack;
        ChartGetInteger(ChartID(),CHART_COLOR_FOREGROUND,0,foregroundColor);
        ObjectSetText(sBtnDisplaySetting, gdisplayState, 8, "Calibri", (color)foregroundColor);
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
        Bar1[i] = EMPTY_VALUE;
        Bar2[i] = EMPTY_VALUE;
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
    if (id == CHARTEVENT_CHART_CHANGE) {
        ChartGetInteger(ChartID(), CHART_SCALE, 0, gChartScale);
        if (gChartScale == gPreChartScale) return;
        gPreChartScale = gChartScale;
        if (gChartScale == 2) BarWidth = 1;
        else if (gChartScale == 3) BarWidth = 2;
        else if (gChartScale == 4) BarWidth = 5;
        else if (gChartScale == 5) BarWidth = 12;
        else {
            displayInsideBar(false);
            return;
        }
        displayInsideBar(gdisplayState == DISPLAY_ON);
    } else if (id == CHARTEVENT_OBJECT_CLICK){
        if (sparam == sBtnDisplaySetting){
            if (gdisplayState == DISPLAY_ON) {
                gdisplayState = DISPLAY_OFF;
                displayInsideBar(false);
            } else {
                gdisplayState = DISPLAY_ON;
                displayInsideBar(true);
            }
            ObjectSetText(sBtnDisplaySetting, gdisplayState);
        }
    }
  }
//+------------------------------------------------------------------+
void SetCandleColor(int col, int i) {
    if (gChartPeriod == PERIOD_D1 && TimeDayOfWeek(Time[i]) == 0) { // Chủ nhật
        return;
    }
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

void displayInsideBar(bool isDisplay){
    if (isDisplay){
        SetIndexStyle(0, DRAW_HISTOGRAM, 0, BarWidth, upCandleColor);
        SetIndexStyle(1, DRAW_HISTOGRAM, 0, BarWidth, downCandleColor);
    } else {
        SetIndexStyle(0, DRAW_HISTOGRAM, 0, BarWidth, clrNONE);
        SetIndexStyle(1, DRAW_HISTOGRAM, 0, BarWidth, clrNONE);
    }
}