//+------------------------------------------------------------------+
//|                                         [Signal] Outside Bar.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window

enum eBias {
    eBiasBuy,   // Bias Buy
    eBiasSell,  // Bias Sell 
    eBiasNone,  // No Bias
};

input eBias  inpBias = eBiasNone; // Bias
input int    inpSize = 5;         // Size
input string inpHotkey = "K";     // Hotkey

eBias gBias = eBiasNone;
string gListBiasStr[] = {"BUY", "SELL", "NONE"};

#define APP_TAG "Signal.OutsideBar"
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    gBias = inpBias;
    createSignalIndication();
//---
    return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {
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
    scanWindow();
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
    if (id == CHARTEVENT_CHART_CHANGE) scanWindow();
    else if (id == CHARTEVENT_KEYDOWN && lparam == inpHotkey[0]) {
        if (gBias == eBiasNone) gBias = eBiasBuy;
        else gBias++;
        createSignalIndication();
        scanWindow();
    }
    else if (id == CHARTEVENT_OBJECT_DELETE){
        if (StringFind(sparam, APP_TAG) >= 0) createSignalIndication();
    }
}
//+------------------------------------------------------------------+
int gLabelIdx;
void scanWindow(){
    if (gBias == eBiasNone){
        hideItem(0, "Label");
        return;
    }
    int bar = WindowFirstVisibleBar();
    int barLimit = bar - WindowBarsPerChart();

    bar--;// không tín bar đầu tiên

    gLabelIdx = 0;
    while(bar >= 0 && bar > barLimit) {
        if (High[bar] > High[bar+1] && Low[bar] < Low[bar+1]){
            if (gBias == eBiasBuy && Close[bar] > Open[bar+1]) createLabel(gLabelIdx++, "🔺", Time[bar], High[bar], inpSize, ANCHOR_LOWER, clrGreen);
            if (gBias == eBiasSell && Close[bar] < Open[bar+1]) createLabel(gLabelIdx++, "🔻", Time[bar], Low[bar], inpSize, ANCHOR_UPPER, clrRed);
        }
        bar--;
    }
    hideItem(gLabelIdx, "Label");
}

void createLabel(int index, string label, datetime time1, double price1, int size, int anchor, color cl){
    string objName = APP_TAG + "Label" + IntegerToString(index);
    ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_BACK, false);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
    // Basic
    ObjectSet(objName, OBJPROP_TIME1, time1);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
    ObjectSetText(objName, label, size, NULL, cl);
    ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR, anchor);
}

void hideItem(int index, string tag){
    string objName = APP_TAG + tag + IntegerToString(index);
    while(ObjectFind(objName) >= 0){
        ObjectSet(objName, OBJPROP_TIME1, 0);
        ObjectSet(objName, OBJPROP_TIME2, 0);
        objName = APP_TAG + tag + IntegerToString(index++);
    }
}

void createSignalIndication(){
    string objName = APP_TAG + "SignalIndi";
    ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_BACK, true);
    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
    // Basic
    ObjectSet(objName, OBJPROP_XDISTANCE, 5);
    ObjectSet(objName, OBJPROP_YDISTANCE, 15);
    ObjectSetText(objName, "[Signal] Outside Bar: " + gListBiasStr[gBias], 9, NULL, clrBlack);
}