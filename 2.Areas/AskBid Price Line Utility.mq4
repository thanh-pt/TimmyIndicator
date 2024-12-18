#property copyright "aForexStory Wiki"
#property link      "https://aforexstory.notion.site/aa613be6d2fc4c5a84722fe629d5b3c4"
#property version   "1.00"
#property strict
#property indicator_chart_window

input bool InpMiniAskBid = true;        // Mini Ask/Bid
input bool InpCountDownTimer = true;    // Countdown Timer

string objAsk    = "*1MiniPriceLineAsk";
string objBid    = "*2MiniPriceLineBid";

string gObjBkgnd = "*1gObjBkgnd";
string gObjTimer = "*2gObjTimer";
string gRemainTimeStr = "";
bool    gInitChart = false;
int     gX, gY;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    if (InpCountDownTimer){
        EventSetTimer(1);
        createTimerLabel();
    }
    if (InpMiniAskBid) createMiniAskBid();
//---
    return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
    gInitChart = false;
    if (reason <= REASON_RECOMPILE || reason == REASON_PARAMETERS){
        ChartSetInteger(0, CHART_SHOW_ASK_LINE, true);
        ChartSetInteger(0, CHART_SHOW_BID_LINE, true);
        ObjectDelete(objBid);
        ObjectDelete(objAsk);
        ObjectDelete(gObjBkgnd);
        ObjectDelete(gObjTimer);
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
   
//--- return value of prev_calculated for next call
    gInitChart = true;
    if (InpCountDownTimer) updateTimerPosition();
    if (InpMiniAskBid) updateMiniAskBid();
    return(rates_total);
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    if (InpCountDownTimer) loadTimer();
}
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if (id == CHARTEVENT_CHART_CHANGE || id == 10){
        if (gInitChart == false) return;
        updateTimerPosition();
    }
    else if (id == CHARTEVENT_OBJECT_DELETE){
        if (gInitChart == false) return;
        if (sparam == gObjTimer) createTimerLabel();
    }
}
void createTimerLabel(){
    ObjectCreate(gObjBkgnd, OBJ_LABEL, 0, 0, 0);
    ObjectSet(gObjBkgnd, OBJPROP_SELECTABLE, false);
    ObjectSetText(gObjBkgnd, "", 9, "Consolas");
    ObjectSet(gObjBkgnd, OBJPROP_COLOR, clrLightGray);
    ObjectSet(gObjBkgnd, OBJPROP_XDISTANCE, 1);
    ObjectSet(gObjBkgnd, OBJPROP_YDISTANCE, 0);
    ObjectSet(gObjBkgnd, OBJPROP_CORNER , CORNER_RIGHT_UPPER);
    ObjectSet(gObjBkgnd, OBJPROP_ANCHOR , ANCHOR_RIGHT);
    ObjectSetString(0 , gObjBkgnd, OBJPROP_TOOLTIP, "\n");
    //--------------------------------------------
    ObjectCreate(gObjTimer, OBJ_LABEL, 0, 0, 0);
    ObjectSetText(gObjTimer, "", 8, "Consolas");
    ObjectSet(gObjTimer, OBJPROP_SELECTABLE, false);
    ObjectSet(gObjTimer, OBJPROP_COLOR, clrBlack);
    ObjectSet(gObjTimer, OBJPROP_XDISTANCE, 1);
    ObjectSet(gObjTimer, OBJPROP_YDISTANCE, 0);
    ObjectSet(gObjTimer, OBJPROP_CORNER , CORNER_RIGHT_UPPER);
    ObjectSet(gObjTimer, OBJPROP_ANCHOR , ANCHOR_RIGHT);
    ObjectSetString(0 , gObjTimer, OBJPROP_TOOLTIP, "\n");
}
void createMiniAskBid(){
    ObjectCreate(objAsk, OBJ_TREND, 0, 0, 0);
    ObjectCreate(objBid, OBJ_TREND, 0, 0, 0);
    ObjectSet(objBid, OBJPROP_BACK, true);
    ObjectSet(objBid, OBJPROP_SELECTABLE, false);
    ObjectSet(objBid, OBJPROP_RAY, true);
    ObjectSet(objBid, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet(objBid, OBJPROP_WIDTH, 0);
    ObjectSet(objBid, OBJPROP_COLOR, clrLightGray);
    ObjectSetString(0, objBid, OBJPROP_TOOLTIP, "\n");
    
    ObjectSet(objAsk, OBJPROP_BACK, true);
    ObjectSet(objAsk, OBJPROP_SELECTABLE, false);
    ObjectSet(objAsk, OBJPROP_RAY, true);
    ObjectSet(objAsk, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet(objAsk, OBJPROP_WIDTH, 0);
    ObjectSet(objAsk, OBJPROP_COLOR, clrRed);
    ObjectSetString(0, objAsk, OBJPROP_TOOLTIP, "\n");

//---
    ChartSetInteger(0, CHART_SHOW_ASK_LINE, false);
    ChartSetInteger(0, CHART_SHOW_BID_LINE, false);
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
        ObjectSetText(gObjBkgnd, "█████");
        // ObjectSetText(gObjBkgnd, "███████");
        int hour = 0;
        if (min >= 60) {
            hour = min/60;
            min = min - hour*60;
        }
        gRemainTimeStr = IntegerToString(hour) +"h:"+IntegerToString(min,2,'0');// + ":" + IntegerToString(sec,2,'0');
    }
    ObjectSetText(gObjTimer, gRemainTimeStr);
}

void updateTimerPosition(){
    ChartTimePriceToXY(0, 0, Time[0], Bid, gX, gY);
    ObjectSet(gObjBkgnd, OBJPROP_YDISTANCE, gY);
    ObjectSet(gObjTimer, OBJPROP_YDISTANCE, gY);
}

void updateMiniAskBid(){
    ObjectSet(objBid, OBJPROP_PRICE1, Bid);
    ObjectSet(objBid, OBJPROP_PRICE2, Bid);
    ObjectSet(objBid, OBJPROP_TIME1, Time[0]);
    ObjectSet(objBid, OBJPROP_TIME2, Time[0] + Period()*300);
    
    ObjectSet(objAsk, OBJPROP_PRICE1, Ask);
    ObjectSet(objAsk, OBJPROP_PRICE2, Ask);
    ObjectSet(objAsk, OBJPROP_TIME1, Time[0]);
    ObjectSet(objAsk, OBJPROP_TIME2, Time[0] + Period()*300);
}