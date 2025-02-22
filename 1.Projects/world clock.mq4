#property copyright "mt4 tools - WIKI"
#property link      "https://aforexstory.notion.site/1104379b17ec80218296ccaa5eb0ff14"
#property version   "1.00"
#property icon      "../3.Resource/WorldClock.ico"
#property description "Display a world clock which helps trader to visualize time in the world"
#property strict
#property indicator_chart_window

#define APP_TAG "*WorldClock"

input string InpLable = "";//Lable (ex:London):
input int  InpTimeZone = 0; //Time Zone:
input bool InpIsOffline = false; //Is Offline:

string gObjWorldClock = APP_TAG + StringTrimRight(InpLable);

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    EventSetTimer(1);
    createTimerLabel();
//---
    return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
    for (int i = ObjectsTotal() - 1; i >= 0; i--) {
        string objName = ObjectName(i);
        if (StringFind(objName, APP_TAG) != -1) ObjectDelete(objName);
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
    return(rates_total);
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    if (InpIsOffline) {
        ObjectSetText(gObjWorldClock, InpLable+TimeToString(Time[0]+InpTimeZone*3600, TIME_SECONDS));
    }
    else {
        ObjectSetText(gObjWorldClock, InpLable+TimeToString(TimeGMT()+InpTimeZone*3600, TIME_SECONDS));
    }
}
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if (id == CHARTEVENT_OBJECT_DELETE && sparam == gObjWorldClock){
        createTimerLabel();
    }
}
void createTimerLabel(){
    if (ObjectFind(gObjWorldClock) < 0){
        ObjectCreate(gObjWorldClock, OBJ_LABEL, 0, 0, 0);
        ObjectSet(gObjWorldClock, OBJPROP_SELECTABLE, true);
        ObjectSetText(gObjWorldClock, "hh:mm:ss", 18, "Consolas");
        ObjectSet(gObjWorldClock, OBJPROP_COLOR, clrMidnightBlue);
        ObjectSet(gObjWorldClock, OBJPROP_XDISTANCE, 10);
        ObjectSet(gObjWorldClock, OBJPROP_YDISTANCE, 10);
        ObjectSet(gObjWorldClock, OBJPROP_CORNER , CORNER_LEFT_LOWER);
        ObjectSet(gObjWorldClock, OBJPROP_ANCHOR , ANCHOR_LEFT_LOWER);
        ObjectSetString(0 , gObjWorldClock, OBJPROP_TOOLTIP, "\n");
    }
}