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

#define APP_TAG "ImbBar"

//--- input parameters
input color     InpImbUpClr     = C'209,225,237';   // Imbalance Up:
input color     InpImbDnClr     = C'255,200,200';   // Imbalance Down:
input string    InpOnOffHotkey  = "M";              // On/Off Hotkey:

long gChartScale = 0;
bool gOnState   = true;
bool gInit      = false;
int  gTimeOfset = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{ 
//---
    gTimeOfset = ChartPeriod() * 60;
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
    gInit = true;
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
        loadImbalance();
    }
    else if (id == CHARTEVENT_KEYDOWN && lparam == InpOnOffHotkey[0]) {
        gOnState = !gOnState;
        loadImbalance();
    }
}
//+------------------------------------------------------------------+

void loadImbalance()
{
    int pIdx = 0;
    gChartScale = ChartGetInteger(ChartID(), CHART_SCALE);
    if (gOnState == false || gChartScale < 2 || gInit == false) {
        while(hideImb(pIdx++) == true){}
        return;
    }
    int bars_count  =   WindowBarsPerChart();
    int bar         =   WindowFirstVisibleBar()-2;
    for(int i=0; i<bars_count && bar>0; i++,bar--) {
        if (Low[bar+1] > High[bar-1]) { // down bar
            drawImb(pIdx++, Time[bar], Low[bar+1], High[bar-1], InpImbDnClr);
        }
        else if (High[bar+1] < Low[bar-1]){ // up bar
            drawImb(pIdx++, Time[bar], High[bar+1], Low[bar-1], InpImbUpClr);
        }
    }
    while(hideImb(pIdx++) == true){}
}

void drawImb(int index, const datetime& time, const double& price1, const double& price2, color clr)
{
    string objName = APP_TAG + IntegerToString(index);
    if (ObjectFind(objName) < 0) {
        ObjectCreate(objName, OBJ_RECTANGLE, 0, 0, 0);
        ObjectSet(objName, OBJPROP_BACK, true);
        ObjectSet(objName, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
    }
    ObjectSet(objName, OBJPROP_COLOR, clr);
    ObjectSet(objName, OBJPROP_TIME1, time);
    ObjectSet(objName, OBJPROP_TIME2, time+gTimeOfset);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
    ObjectSet(objName, OBJPROP_PRICE2, price2);
}

bool hideImb(int index)
{
    string objName = APP_TAG + IntegerToString(index);
    ObjectSet(objName, OBJPROP_TIME1, 0);
    ObjectSet(objName, OBJPROP_TIME2, 0);
    return (ObjectFind(objName) >= 0);
}

