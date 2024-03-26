//+------------------------------------------------------------------+
//|                                                 SDz Detector.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define APP_TAG "SDzDetector"
#define INDI_ON  "SDz Detector ON"
#define INDI_OFF "SDz Detector OFF"

input int QueryMgtNum  = 10;
input int QueryHiLoNum = 2;
input color SupplyColor = clrRed;
input color DemandColor = clrDodgerBlue;
input bool  SDzBackGround = false;

bool gInitCalculation = false;
string gIndiStage = INDI_ON;
string gBtnIndiSwitch = APP_TAG + "BtnIndiSwitch";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    if (ObjectFind(gBtnIndiSwitch) < 0) {
        createBtnIndiSwitch();
    } else {
        gIndiStage = ObjectDescription(gBtnIndiSwitch);
    }
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
    reloadSDzDetector();
    gInitCalculation = true;
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
    if (gInitCalculation == false) return;
    if (id == CHARTEVENT_CHART_CHANGE) reloadSDzDetector();
    else if (id == CHARTEVENT_OBJECT_CLICK) {
        if (sparam == gBtnIndiSwitch) {
            if (gIndiStage == INDI_ON) {
                gIndiStage = INDI_OFF;
            } else {
                gIndiStage = INDI_ON;
            }
            ObjectSetText(gBtnIndiSwitch, gIndiStage);
            reloadSDzDetector();
        }
    } else if (id == CHARTEVENT_OBJECT_DELETE){
        if (sparam == gBtnIndiSwitch) {
            createBtnIndiSwitch();
        }
    }
}
//+------------------------------------------------------------------+

void drawRectangle(string objName, double price1, double price2, datetime time1, datetime time2, color c){
    ObjectCreate(objName, OBJ_RECTANGLE , 0, 0, 0);
    ObjectSet(objName, OBJPROP_BACK , SDzBackGround);
    ObjectSet(objName, OBJPROP_STYLE, 2);
    ObjectSet(objName, OBJPROP_COLOR, c);
    ObjectSet(objName, OBJPROP_TIME1 , time1);
    ObjectSet(objName, OBJPROP_TIME2 , time2);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
    ObjectSet(objName, OBJPROP_PRICE2, price2);
}

void reloadSDzDetector()
{
    int pIdx = 0;
    if (gIndiStage == INDI_ON){
        int bars_count=WindowBarsPerChart();
        int bar=WindowFirstVisibleBar();

        bool isStillImb = true;

        for(int i=0; i<bars_count && bar>1; i++,bar--) {
            if (Low[bar+1] > High[bar-1]) { // Down IMB
                // Check Previous not IMB
                if (Low[bar+2] <= High[bar]) {
                    isStillImb = true;
                    for (int j = 1; j < QueryMgtNum && bar-j > 0; j++){
                        if (Low[bar+1] <= High[bar-j]){
                            isStillImb = false;
                            break;
                        }
                    }
                    if (isStillImb) {
                        // find last top
                        int hiLoPos = bar;
                        while (true){
                            if (High[hiLoPos] > High[hiLoPos-1] && High[hiLoPos] > High[hiLoPos+1]) break;
                            if (Low[hiLoPos] > Low[hiLoPos+1] && High[hiLoPos] < High[hiLoPos+1]) break;
                            hiLoPos++;
                        }
                        // Check xem imb có xa không ấy
                        if (hiLoPos - bar > QueryHiLoNum) hiLoPos = bar+1;
                        drawRectangle(APP_TAG + IntegerToString(pIdx++),
                                    High[hiLoPos], Low[bar+1],
                                    Time[hiLoPos], Time[MathMax(bar-QueryMgtNum, 0)],
                                    SupplyColor);
                    }
                }
            } else if (High[bar+1] < Low[bar-1]) { // Up IMB
                // Check Previous not IMB
                if (High[bar+2] >= Low[bar]) {
                    isStillImb = true;
                    for (int j = 1; j < QueryMgtNum && bar-j > 0; j++){
                        if (High[bar+1] >= Low[bar-j]){
                            isStillImb = false;
                            break;
                        }
                    }
                    if (isStillImb) {
                        // find last top
                        int hiLoPos = bar;
                        while (true){
                            if (Low[hiLoPos] < Low[hiLoPos-1] && Low[hiLoPos] < Low[hiLoPos+1]) break;
                            if (Low[hiLoPos] > Low[hiLoPos+1] && High[hiLoPos] < High[hiLoPos+1]) break;
                            hiLoPos++;
                        }
                        // Check xem imb có xa không ấy
                        if (hiLoPos - bar > QueryHiLoNum) hiLoPos = bar+1;
                        drawRectangle(APP_TAG + IntegerToString(pIdx++),
                                    Low[hiLoPos], High[bar+1],
                                    Time[hiLoPos], Time[MathMax(bar-QueryMgtNum, 0)],
                                    DemandColor);
                    }
                }
            }
        }
    }

    string objName;
    do {
        objName  = APP_TAG + IntegerToString(pIdx++);
        ObjectSet(objName, OBJPROP_PRICE1, 0);
        ObjectSet(objName, OBJPROP_PRICE2, 0);
    } while (ObjectFind(objName) >= 0);
}

void createBtnIndiSwitch()
{
    ObjectCreate(gBtnIndiSwitch, OBJ_LABEL, 0, 0, 0);
    ObjectSetText(gBtnIndiSwitch, gIndiStage, 10, "Consolas", clrBlack);
    ObjectSet(gBtnIndiSwitch, OBJPROP_XDISTANCE, 5);
    ObjectSet(gBtnIndiSwitch, OBJPROP_YDISTANCE, 15);
    ObjectSet(gBtnIndiSwitch, OBJPROP_SELECTABLE, false);
    ObjectSetString(ChartID(), gBtnIndiSwitch, OBJPROP_TOOLTIP, "\n");
}