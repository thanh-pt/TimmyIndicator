#property copyright "mt4 tools - WIKI"
#property link      "https://aforexstory.notion.site/1104379b17ec80218296ccaa5eb0ff14"
#property version   "1.00"
// #property icon      "../3.Resource/WorldClock.ico"
#property description "This tool helps trader to review their trades"
#property strict
#property indicator_chart_window

#define APP_TAG "*ReviewTrade"

#include "ReviewTradesFiles/Dashboard.mqh"
bool initStatus = false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    if (ObjectFind(objInitPanel) < 0) initPanel();
    return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
    if (reason <= REASON_RECOMPILE || reason == REASON_PARAMETERS){
        initStatus = true;
        for (int i = ObjectsTotal() - 1; i >= 0; i--) {
            string objName = ObjectName(i);
            if (StringFind(objName, APP_TAG) != -1) ObjectDelete(objName);
        }
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
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if (id == CHARTEVENT_OBJECT_CLICK && StringFind(sparam, APP_TAG) != -1){
        handleClick(sparam);
    }
}