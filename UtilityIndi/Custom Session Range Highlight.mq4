//+------------------------------------------------------------------+
//|                               Custom Session Range Highlight.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link "https://www.youtube.com/@TimmyTraderHamHoc"
#property version "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
//--- plot ssHi
#property indicator_label1 "ssHi"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrTeal
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
//--- plot ssLo
#property indicator_label2 "ssLo"
#property indicator_type2 DRAW_LINE
#property indicator_color2 clrTeal
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#define APP_TAG "SSHighlight"
enum BG_TYPE
{
    NONE_BG,
    FILLED_BG,
    LINE_BG,
};
//--- input parameters
input string RangeName = "Asian";
input int SummerBeginRangeHour = 0;
input int SummerEndRangeHour   = 6;

input string _DisplayConfiguration = "";
input color   RangeColor           = clrTeal;
input bool    DisplayLabel         = true;
input BG_TYPE DisplayBackgound     = LINE_BG;
input color   BackGroundColor      = clrTeal;

input string _OtherConfiguration = "";
input bool AutoShiftWinterHour = true;


//--- indicator buffers
double hiBuffer[];
double loBuffer[];
//--- indicator variable
int winterBeg = 10;
int winterEnd = 4;
string app_tag = "";
double highestRange, lowestRange;
string objName = "";
int beginRangeHour, endRangeHour;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    //--- indicator buffers mapping
    SetIndexBuffer(0, hiBuffer);
    SetIndexBuffer(1, loBuffer);
    SetIndexStyle(0, DRAW_LINE, STYLE_DOT, 0, RangeColor);
    SetIndexStyle(1, DRAW_LINE, STYLE_DOT, 0, RangeColor);
    //---
    app_tag = APP_TAG+RangeName;
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
    for (int i = ObjectsTotal() - 1; i >= 0; i--) {
        objName = ObjectName(i);
        if (StringFind(objName, app_tag) != -1) ObjectDelete(objName);
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

    int i,pos;
    //--- counting from 0 to rates_total
    ArraySetAsSeries(hiBuffer,false);
    ArraySetAsSeries(loBuffer,false);
    ArraySetAsSeries(high,false);
    ArraySetAsSeries(low ,false);
    ArraySetAsSeries(time,false);

    pos = prev_calculated;
    int hour = 0;
    int minute = 0;
    for(i=pos; i<rates_total; i++){
        hour = TimeHour(time[i]);
        minute = TimeMinute(time[i]);
        if (AutoShiftWinterHour && (TimeMonth(time[i]) >= 10 || TimeMonth(time[i]) < 4)) {
            beginRangeHour = SummerBeginRangeHour + 1;
            endRangeHour   = SummerEndRangeHour   + 1;
        } else {
            beginRangeHour = SummerBeginRangeHour;
            endRangeHour   = SummerEndRangeHour  ;
        }
        if (hour == beginRangeHour && minute == 0) {
            highestRange = high[i];
            lowestRange  = low [i];
        }
        if (hour >= beginRangeHour && (hour < endRangeHour || (hour == endRangeHour && minute == 0))) {
            if (high[i] > highestRange) highestRange = high[i];
            if (low [i] <  lowestRange) lowestRange  = low [i];
            hiBuffer[i] = highestRange;
            loBuffer[i] =  lowestRange;

            // Label
            objName = app_tag + TimeToStr(time[i], TIME_DATE) + "Label";
            if (DisplayLabel) {
                if (ObjectFind(objName) < 0) {
                    ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
                    ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
                    ObjectSetText(objName, "►"+RangeName, 8, NULL, RangeColor);
                    ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
                }
                ObjectSet(objName, OBJPROP_TIME1, time[i]);
                ObjectSet(objName, OBJPROP_PRICE1, highestRange);
            }

            if (DisplayBackgound != NONE_BG) {
                objName = app_tag + TimeToStr(time[i], TIME_DATE) + "Bg" + TimeToStr(time[i],TIME_MINUTES);
                if (ObjectFind(objName) < 0) {
                    if (DisplayBackgound == LINE_BG) {
                        ObjectCreate(objName, OBJ_TREND, 0, time[i], highestRange, time[i], lowestRange);
                        ObjectSet(objName, OBJPROP_RAY, false);
                        ObjectSet(objName, OBJPROP_STYLE, STYLE_DOT);
                        ObjectSet(objName, OBJPROP_WIDTH, 0);
                    } else if (i < rates_total-1){
                        ObjectCreate(objName, OBJ_RECTANGLE, 0, time[i], highestRange, time[i+1], lowestRange);
                    }
                    ObjectSet(objName, OBJPROP_COLOR, BackGroundColor);
                    ObjectSet(objName, OBJPROP_BACK, true);
                    ObjectSet(objName, OBJPROP_SELECTABLE, false);
                    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
                    ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
                }
            }

            // End session
            if (hour == endRangeHour) {
                objName = app_tag + TimeToStr(time[i], TIME_DATE) + "Bg" + TimeToStr(time[i],TIME_MINUTES);
                if (ObjectFind(objName) >= 0) ObjectDelete(objName);
                
                ObjectCreate(objName, OBJ_TREND, 0, time[i], highestRange, time[i], lowestRange);
                ObjectSet(objName, OBJPROP_BACK, true);
                ObjectSet(objName, OBJPROP_RAY, false);
                ObjectSet(objName, OBJPROP_STYLE, STYLE_DOT);
                ObjectSet(objName, OBJPROP_WIDTH, 0);
                ObjectSet(objName, OBJPROP_SELECTABLE, false);
                ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
                ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
                ObjectSet(objName, OBJPROP_COLOR, RangeColor);
                objName = app_tag + TimeToStr(time[i], TIME_DATE) + "Label";
                ObjectSetText(objName, RangeName, 8, NULL, RangeColor);
            }
        }
    }
    //--- return value of prev_calculated for next call
    return (rates_total);
}
//+------------------------------------------------------------------+