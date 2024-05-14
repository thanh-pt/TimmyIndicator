//+------------------------------------------------------------------+
//|                                              Countdown Timer.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window

string gObjTimer = "CountdownTimer%";
string gObjBkgnd = "CountdownTimer%Bkgnd";
string gRemainTimeStr = "";
long    gChartId = 0;
bool    gInitTimer = false;
bool    gInitChart = false;
int     gX, gY;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    gInitTimer = false;
    gChartId = ChartID();
    EventSetTimer(1);
    createTimerLabel();
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
    gInitChart = true;
    updateTimerPosition();
    return(rates_total);
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    if (gInitTimer == false){
        EventKillTimer();
        EventSetTimer(1);
        gInitTimer = true;
        return;
    }
    loadTimer();
}
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if (id == CHARTEVENT_CHART_CHANGE || id == 10)
        updateTimerPosition();
    else if (id == CHARTEVENT_OBJECT_DELETE){
        if (sparam == gObjTimer) createTimerLabel();
    }
}
void createTimerLabel(){
    ObjectCreate(gObjBkgnd, OBJ_LABEL, 0, 0, 0);
    ObjectSet(gObjBkgnd, OBJPROP_SELECTABLE, false);
    ObjectSetText(gObjBkgnd, "█████", 9, "Consolas");
    ObjectSet(gObjBkgnd, OBJPROP_COLOR, clrLightGray);
    ObjectSet(gObjBkgnd, OBJPROP_XDISTANCE, 1);
    ObjectSet(gObjBkgnd, OBJPROP_YDISTANCE, 0);
    ObjectSetString(gChartId , gObjBkgnd, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(gChartId, gObjBkgnd, OBJPROP_CORNER , CORNER_RIGHT_UPPER);
    ObjectSetInteger(gChartId, gObjBkgnd, OBJPROP_ANCHOR , ANCHOR_RIGHT);
    //--------------------------------------------
    ObjectCreate(gObjTimer, OBJ_LABEL, 0, 0, 0);
    ObjectSetText(gObjTimer, "", 8, "Consolas");
    ObjectSet(gObjTimer, OBJPROP_SELECTABLE, false);
    ObjectSet(gObjTimer, OBJPROP_COLOR, clrBlack);
    ObjectSet(gObjTimer, OBJPROP_XDISTANCE, 1);
    ObjectSet(gObjTimer, OBJPROP_YDISTANCE, 0);
    ObjectSetString(gChartId , gObjTimer, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(gChartId, gObjTimer, OBJPROP_CORNER , CORNER_RIGHT_UPPER);
    ObjectSetInteger(gChartId, gObjTimer, OBJPROP_ANCHOR , ANCHOR_RIGHT);
}

void loadTimer(){
    int min, sec;
    min = (int)(Time[0] + Period()*60 - CurTime());
    sec = min%60;
    min =(min - min%60) / 60;
    if (ChartPeriod() <= PERIOD_H1){
        ObjectSetText(gObjBkgnd, "█████");
        gRemainTimeStr = IntegerToString(min,2,'0') + ":" + IntegerToString(sec,2,'0');
    }
    else if (ChartPeriod() <= PERIOD_H4){
        ObjectSetText(gObjBkgnd, "███████");
        int hour = 0;
        if (min >= 60) {
            hour = min/60;
            min = min - hour*60;
        }
        gRemainTimeStr = IntegerToString(hour) +":"+IntegerToString(min,2,'0') + ":" + IntegerToString(sec,2,'0');
    }
    ObjectSetText(gObjTimer, gRemainTimeStr);
}

void updateTimerPosition(){
    if (gInitChart == false) return;
    ChartTimePriceToXY(gChartId, 0, Time[0], Bid, gX, gY);
    ObjectSet(gObjTimer, OBJPROP_YDISTANCE, gY);
    ObjectSet(gObjBkgnd, OBJPROP_YDISTANCE, gY);
}