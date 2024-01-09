//+------------------------------------------------------------------+
//|                                                 SessionRange.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link "https://www.youtube.com/@TimmyTraderHamHoc"
#property version "1.02"
#property strict
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 6
//--- plot asHi
#property indicator_label1 "asHi"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrTeal
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
//--- plot asLo
#property indicator_label2 "asLo"
#property indicator_type2 DRAW_LINE
#property indicator_color2 clrTeal
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
//--- plot ldHi
#property indicator_label3 "ldHi"
#property indicator_type3 DRAW_LINE
#property indicator_color3 clrForestGreen
#property indicator_style3 STYLE_DOT
#property indicator_width3 1
//--- plot ldLo
#property indicator_label4 "ldLo"
#property indicator_type4 DRAW_LINE
#property indicator_color4 clrForestGreen
#property indicator_style4 STYLE_DOT
#property indicator_width4 1
//--- plot nyHi
#property indicator_label5 "nyHi"
#property indicator_type5 DRAW_LINE
#property indicator_color5 clrBrown
#property indicator_style5 STYLE_DOT
#property indicator_width5 1
//--- plot nyLo
#property indicator_label6 "nyLo"
#property indicator_type6 DRAW_LINE
#property indicator_color6 clrBrown
#property indicator_style6 STYLE_DOT
#property indicator_width6 1

#define APP_TAG "SSHighlight"
//--- input parameters
input bool displayLabel = true;
input bool displayBackgound = true;
input color asianColor = clrTeal;
input color londonColor = clrForestGreen;
input color newyorkColor = clrBrown;

int asBegHour = 0;
int asEndHour = 6;
int ldBegHour = 7;
int ldEndHour = 11;
int nyBegHour = 12;
int nyEndHour = 16;
int winterBeg = 10;
int winterEnd = 4;
//--- indicator buffers
double asHiBuffer[];
double asLoBuffer[];
double ldHiBuffer[];
double ldLoBuffer[];
double nyHiBuffer[];
double nyLoBuffer[];
//--- indicator variable
bool gReInit = true;
int gLastVisibleBar = 0;

double gPriceHi = 0;
double gPriceLo = 0;
long gChartScale = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    //--- indicator buffers mapping
    if (ChartPeriod() < PERIOD_H4) {
        SetIndexBuffer(0, asHiBuffer);
        SetIndexBuffer(1, asLoBuffer);
        SetIndexBuffer(2, ldHiBuffer);
        SetIndexBuffer(3, ldLoBuffer);
        SetIndexBuffer(4, nyHiBuffer);
        SetIndexBuffer(5, nyLoBuffer);
        SetIndexStyle(0, DRAW_LINE, STYLE_DOT, 0, asianColor);
        SetIndexStyle(1, DRAW_LINE, STYLE_DOT, 0, asianColor);
        SetIndexStyle(2, DRAW_LINE, STYLE_DOT, 0, londonColor);
        SetIndexStyle(3, DRAW_LINE, STYLE_DOT, 0, londonColor);
        SetIndexStyle(4, DRAW_LINE, STYLE_DOT, 0, newyorkColor);
        SetIndexStyle(5, DRAW_LINE, STYLE_DOT, 0, newyorkColor);
    }
    //---
    return (INIT_SUCCEEDED);
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
                const datetime & time[],
                const double & open[],
                const double & high[],
                const double & low[],
                const double & close[],
                const long & tick_volume[],
                const long & volume[],
                const int & spread[]) {
    //---
    if (ChartPeriod() >= PERIOD_H4) return (rates_total);
    int i;
    int counted_bars = IndicatorCounted();

    //---- check for possible errors
    if (counted_bars < 0) return (-1);

    //----Calculation---------------------------
    int month  = 0;
    int hour   = 0;
    int minute = 0;
    for (i = rates_total-counted_bars-1; i>=0; i--){
        month = TimeMonth(Time[i]);
        hour = TimeHour(Time[i]);
        minute = TimeMinute(Time[i]);
        if (month >= winterBeg || month < winterEnd) { // Winter Time
            hour = hour - 1;
        }
        
        asHiBuffer[i] = EMPTY_VALUE;
        asLoBuffer[i] = EMPTY_VALUE;
        ldHiBuffer[i] = EMPTY_VALUE;
        ldLoBuffer[i] = EMPTY_VALUE;
        nyHiBuffer[i] = EMPTY_VALUE;
        nyLoBuffer[i] = EMPTY_VALUE;

        if (minute == 0){
            if      (hour == asBegHour) { gPriceHi = High[i]; gPriceLo = Low[i]; }
            else if (hour == ldBegHour) { gPriceHi = High[i]; gPriceLo = Low[i]; }
            else if (hour == nyBegHour) { gPriceHi = High[i]; gPriceLo = Low[i]; }
        }
        if (High[i] > gPriceHi) gPriceHi = High[i];
        if (Low[i]  < gPriceLo) gPriceLo = Low [i];

        if ((hour >= asBegHour && hour < asEndHour) || (minute == 0 && hour == asEndHour)) {
            asHiBuffer[i] = gPriceHi;
            asLoBuffer[i] = gPriceLo;
        }
        else if ((hour >= ldBegHour && hour < ldEndHour) || (minute == 0 && hour == ldEndHour)) {
            ldHiBuffer[i] = gPriceHi;
            ldLoBuffer[i] = gPriceLo;
        }
        else if ((hour >= nyBegHour && hour < nyEndHour) || (minute == 0 && hour == nyEndHour)) {
            nyHiBuffer[i] = gPriceHi;
            nyLoBuffer[i] = gPriceLo;
        }
    }
    loadBackground();
    //--- Complete Init Done
    if (gReInit) {
        gLastVisibleBar = 0;
        gReInit = false;
        ObjectCreate(APP_TAG+"IndiSoul", OBJ_TEXT, 0, 0, 0);
    }
    //--- return value of prev_calculated for next call
    return (rates_total);
}

int gBgIdx = 0;
int gSsIdx = 0;
double gPreSsHigh = 0;

void ConfigBgLine(string sessionName, color c, int bar, const double& buffHi[], const double& buffLo[]){
    string objName = "";
    if (bar>0 && buffHi[bar-1] == EMPTY_VALUE) gPreSsHigh = buffHi[bar];
    if ((gChartScale>=2&&displayBackgound == true) || (bar>0 && buffHi[bar-1] == EMPTY_VALUE)){
        objName = APP_TAG + "Bg" + IntegerToString(gBgIdx++);
        if (ObjectFind(objName) < 0) {
            ObjectCreate(objName, OBJ_TREND, 0, 0, 0);
            ObjectSet(objName, OBJPROP_BACK, true);
            ObjectSet(objName, OBJPROP_RAY, false);
            ObjectSet(objName, OBJPROP_STYLE, STYLE_DOT);
            ObjectSet(objName, OBJPROP_WIDTH, 0);
            ObjectSet(objName, OBJPROP_SELECTABLE, false);
            ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
            ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
        }
        ObjectSet(objName, OBJPROP_COLOR, c);
        ObjectSet(objName, OBJPROP_TIME1, Time[bar]);
        ObjectSet(objName, OBJPROP_TIME2, Time[bar]);
        ObjectSet(objName, OBJPROP_PRICE1, buffHi[bar]);
        ObjectSet(objName, OBJPROP_PRICE2, buffLo[bar]);
    }
    if (gChartScale>=1 && displayLabel && (bar == 0 || buffHi[bar-1] == EMPTY_VALUE)) {
        objName = APP_TAG + "Label" + IntegerToString(gSsIdx++);
        if (ObjectFind(objName) < 0) {
            ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
            ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
            ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
        }
        if (bar == 0) {
            ObjectSetText(objName, "►" + sessionName, 8, NULL, c);
            ObjectSet(objName, OBJPROP_PRICE1, MathMax(gPreSsHigh, buffHi[bar]));
        } else {
            ObjectSetText(objName, sessionName, 7, NULL, c);
            ObjectSet(objName, OBJPROP_PRICE1, buffHi[bar]);
        }
        ObjectSet(objName, OBJPROP_TIME1, Time[bar]);
    }
}

void loadBackground(){
    int bars_count=WindowBarsPerChart();
    int bar=WindowFirstVisibleBar();
    ChartGetInteger(ChartID(), CHART_SCALE, 0, gChartScale);
    gBgIdx = 0;
    gSsIdx = 0;
    for(int i=0; i<bars_count && bar>=0; i++,bar--) {
        if      (asHiBuffer[bar] != EMPTY_VALUE && asianColor   != clrNONE) ConfigBgLine("As"  , asianColor  , bar, asHiBuffer, asLoBuffer);
        else if (ldHiBuffer[bar] != EMPTY_VALUE && londonColor  != clrNONE) ConfigBgLine("Ld" , londonColor , bar, ldHiBuffer, ldLoBuffer);
        else if (nyHiBuffer[bar] != EMPTY_VALUE && newyorkColor != clrNONE) ConfigBgLine("Ny", newyorkColor, bar, nyHiBuffer, nyLoBuffer);
    }
    string objName = "";
    do {
        objName = APP_TAG + "Label" + IntegerToString(gSsIdx++);
        ObjectSet(objName, OBJPROP_TIME1, 0);
    } while (ObjectFind(objName) >= 0);
    do {
        objName = APP_TAG + "Bg" + IntegerToString(gBgIdx++);
        ObjectSet(objName, OBJPROP_TIME1, 0);
        ObjectSet(objName, OBJPROP_TIME2, 0);
    } while (ObjectFind(objName) >= 0);
}
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if (ChartPeriod() >= PERIOD_H4) return;
    if (gReInit) return;

    if (id == CHARTEVENT_CHART_CHANGE) {
        loadBackground();
    } else if (id == CHARTEVENT_OBJECT_DELETE){
        if (StringFind(sparam, APP_TAG+"IndiSoul") != -1) gReInit = true;
    }
}
//+------------------------------------------------------------------+