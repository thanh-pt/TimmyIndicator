//+------------------------------------------------------------------+
//|                                                      TimeBox.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link "https://www.youtube.com/@TimmyTraderHamHoc"
#property version "1.00"
#property strict
#property indicator_chart_window

#define APP_TAG "TimeBox"

input int BeginHour = 7;
input int EndHour = 12;
input color BoxColor = clrSlateGray;


int chartPeriod;
int barBoxCount;
bool chartReady;
int prev_totalRate;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    //--- indicator buffers mapping
    chartPeriod = ChartPeriod();
    barBoxCount = (EndHour-BeginHour)*60/chartPeriod;
    chartReady = false;
    return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {
    string objName = "";
    for (int i = ObjectsTotal() - 1; i >= 0; i--) {
        objName = ObjectName(i);
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
    chartReady = true;
    if (prev_totalRate != rates_total){
        scanAndDrawTimeBox();
        prev_totalRate = rates_total;
    }
    //--- return value of prev_calculated for next call
    return (rates_total);
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                const long & lparam,
                const double & dparam,
                const string & sparam) {
    //---
    if (id == CHARTEVENT_CHART_CHANGE) {
        scanAndDrawTimeBox();
    }
}
//+------------------------------------------------------------------+

void scanAndDrawTimeBox(){
    if (!chartReady) return;
    int timeBoxIdx = 0;
    if (chartPeriod <= PERIOD_M15){
        int bar = WindowFirstVisibleBar();
        int bars_count = WindowBarsPerChart();

        int hour = 0;
        double hi=0, lo=0;
        int beginBarIdx = 0;
        bool start = false;

        for (int i = 0; bar > 0; i++, bar--) {
            hour = TimeHour(Time[bar]);
            if (hour >= BeginHour && hour < EndHour){
                if (start == false) {
                    start = true;
                    hi = High[bar];
                    lo = Low[bar];
                    beginBarIdx = bar;
                } else {
                    if (High[bar] > hi) hi = High[bar];
                    if (Low[bar] < lo) lo = Low[bar];
                }
            } else if (hour == EndHour && TimeMinute(Time[bar]) == 0){
                // last sample and draw
                if (High[bar] > hi) hi = High[bar];
                if (Low[bar] < lo) lo = Low[bar];
                drawTimeBox(timeBoxIdx++, Time[beginBarIdx], Time[bar], hi, lo);
                start = false;
                if (i >= bars_count) {
                    break;
                }
            }
        }
        if (bar == 0){
            // Draw current box
            MqlDateTime  dt_struct;
            TimeToStruct(Time[0], dt_struct);
            dt_struct.hour = 0;
            dt_struct.min = 0;
            dt_struct.sec = 0;
            datetime dt_today;
            dt_today = StructToTime(dt_struct);
            bar = iBarShift(ChartSymbol(), chartPeriod, dt_today);
            if (bar > EndHour*60/chartPeriod) {
                hideTodayTimeBox();
                return;
            }
            hi = High[bar];
            lo = Low[bar];
            for (; bar > 0; bar--) {
                if (High[bar] > hi) hi = High[bar];
                if (Low[bar] < lo) lo = Low[bar];
            }
            drawTodayTimeBox(dt_today, hi, lo);
        }
    }

    string objName;
    do {
        objName = APP_TAG + "1" + IntegerToString(timeBoxIdx);
        ObjectSet(objName, OBJPROP_TIME1, 0);
        ObjectSet(objName, OBJPROP_TIME2, 0);

        objName = APP_TAG + "2" + IntegerToString(timeBoxIdx);
        ObjectSet(objName, OBJPROP_TIME1, 0);
        ObjectSet(objName, OBJPROP_TIME2, 0);
        
        objName = APP_TAG + "3" + IntegerToString(timeBoxIdx);
        ObjectSet(objName, OBJPROP_TIME1, 0);
        ObjectSet(objName, OBJPROP_TIME2, 0);
        
        objName = APP_TAG + "4" + IntegerToString(timeBoxIdx++);
        ObjectSet(objName, OBJPROP_TIME2, 0);
        ObjectSet(objName, OBJPROP_TIME1, 0);
    } while (ObjectFind(objName) >= 0);
}

void drawTimeBox(int index, datetime begin_dt, datetime end_dt, double hi, double lo){
    string objName1 = APP_TAG + "1" + IntegerToString(index);
    string objName2 = APP_TAG + "2" + IntegerToString(index);
    string objName3 = APP_TAG + "3" + IntegerToString(index);
    string objName4 = APP_TAG + "4" + IntegerToString(index);
    if (ObjectFind(objName1) < 0) {
        ObjectCreate(objName1, OBJ_TREND, 0, 0, 0);
        ObjectCreate(objName2, OBJ_TREND, 0, 0, 0);
        ObjectCreate(objName3, OBJ_TREND, 0, 0, 0);
        ObjectCreate(objName4, OBJ_TREND, 0, 0, 0);
        ObjectSet(objName1, OBJPROP_BACK, true);
        ObjectSet(objName2, OBJPROP_BACK, true);
        ObjectSet(objName3, OBJPROP_BACK, true);
        ObjectSet(objName4, OBJPROP_BACK, true);

        ObjectSet(objName1, OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(objName2, OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(objName3, OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(objName4, OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(objName1, OBJPROP_WIDTH, 0);
        ObjectSet(objName2, OBJPROP_WIDTH, 0);
        ObjectSet(objName3, OBJPROP_WIDTH, 0);
        ObjectSet(objName4, OBJPROP_WIDTH, 0);
        ObjectSet(objName1, OBJPROP_SELECTABLE, false);
        ObjectSet(objName2, OBJPROP_SELECTABLE, false);
        ObjectSet(objName3, OBJPROP_SELECTABLE, false);
        ObjectSet(objName4, OBJPROP_SELECTABLE, false);
        ObjectSetString(ChartID(), objName1, OBJPROP_TOOLTIP, "\n");
        ObjectSetString(ChartID(), objName2, OBJPROP_TOOLTIP, "\n");
        ObjectSetString(ChartID(), objName3, OBJPROP_TOOLTIP, "\n");
        ObjectSetString(ChartID(), objName4, OBJPROP_TOOLTIP, "\n");
        ObjectSetInteger(ChartID(), objName1, OBJPROP_HIDDEN, true);
        ObjectSetInteger(ChartID(), objName2, OBJPROP_HIDDEN, true);
        ObjectSetInteger(ChartID(), objName3, OBJPROP_HIDDEN, true);
        ObjectSetInteger(ChartID(), objName4, OBJPROP_HIDDEN, true);
        ObjectSet(objName1, OBJPROP_RAY, false);
        ObjectSet(objName2, OBJPROP_RAY, false);
        ObjectSet(objName3, OBJPROP_RAY, false);
        ObjectSet(objName4, OBJPROP_RAY, false);
        ObjectSet(objName1, OBJPROP_COLOR, BoxColor);
        ObjectSet(objName2, OBJPROP_COLOR, BoxColor);
        ObjectSet(objName3, OBJPROP_COLOR, BoxColor);
        ObjectSet(objName4, OBJPROP_COLOR, BoxColor);
    }
    ObjectSet(objName1, OBJPROP_PRICE1, hi);
    ObjectSet(objName1, OBJPROP_PRICE2, hi);
    ObjectSet(objName1, OBJPROP_TIME1, begin_dt);
    ObjectSet(objName1, OBJPROP_TIME2, end_dt);

    ObjectSet(objName2, OBJPROP_PRICE1, hi);
    ObjectSet(objName2, OBJPROP_PRICE2, lo);
    ObjectSet(objName2, OBJPROP_TIME1, end_dt);
    ObjectSet(objName2, OBJPROP_TIME2, end_dt);

    ObjectSet(objName3, OBJPROP_PRICE1, lo);
    ObjectSet(objName3, OBJPROP_PRICE2, lo);
    ObjectSet(objName3, OBJPROP_TIME1, begin_dt);
    ObjectSet(objName3, OBJPROP_TIME2, end_dt);

    ObjectSet(objName4, OBJPROP_PRICE1, hi);
    ObjectSet(objName4, OBJPROP_PRICE2, lo);
    ObjectSet(objName4, OBJPROP_TIME1, begin_dt);
    ObjectSet(objName4, OBJPROP_TIME2, begin_dt);

}

void hideTodayTimeBox()
{
    string preSsLine  = APP_TAG + "preSsLine";
    string beginLine  = APP_TAG + "beginLine";
    string preEndLine = APP_TAG + "preEdLine";
    string endLine    = APP_TAG + "end__Line";
    ObjectSet(preSsLine,  OBJPROP_PRICE1, 0);
    ObjectSet(preSsLine,  OBJPROP_PRICE2, 0);
    ObjectSet(beginLine,  OBJPROP_PRICE1, 0);
    ObjectSet(beginLine,  OBJPROP_PRICE2, 0);
    ObjectSet(preEndLine, OBJPROP_PRICE1, 0);
    ObjectSet(preEndLine, OBJPROP_PRICE2, 0);
    ObjectSet(endLine,    OBJPROP_PRICE1, 0);
    ObjectSet(endLine,    OBJPROP_PRICE2, 0);
}

void drawTodayTimeBox(datetime dt, double hi, double lo)
{
    string preSsLine  = APP_TAG + "preSsLine";
    string beginLine  = APP_TAG + "beginLine";
    string preEndLine = APP_TAG + "preEdLine";
    string endLine    = APP_TAG + "end__Line";
    if (ObjectFind(preSsLine) < 0) {
        ObjectCreate(preSsLine, OBJ_TREND, 0, 0, 0);
        ObjectCreate(beginLine, OBJ_TREND, 0, 0, 0);
        ObjectCreate(endLine, OBJ_TREND, 0, 0, 0);
        ObjectCreate(preEndLine, OBJ_TREND, 0, 0, 0);
        ObjectSet(preSsLine, OBJPROP_BACK, true);
        ObjectSet(beginLine, OBJPROP_BACK, true);
        ObjectSet(preEndLine, OBJPROP_BACK, true);
        ObjectSet(endLine, OBJPROP_BACK, true);

        ObjectSet(preSsLine, OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(beginLine, OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(preEndLine, OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(endLine, OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(preSsLine, OBJPROP_WIDTH, 0);
        ObjectSet(beginLine, OBJPROP_WIDTH, 0);
        ObjectSet(preEndLine, OBJPROP_WIDTH, 0);
        ObjectSet(endLine, OBJPROP_WIDTH, 0);
        ObjectSet(preSsLine, OBJPROP_SELECTABLE, false);
        ObjectSet(beginLine, OBJPROP_SELECTABLE, false);
        ObjectSet(preEndLine, OBJPROP_SELECTABLE, false);
        ObjectSet(endLine, OBJPROP_SELECTABLE, false);
        ObjectSetString(ChartID(), preSsLine, OBJPROP_TOOLTIP, "\n");
        ObjectSetString(ChartID(), beginLine, OBJPROP_TOOLTIP, "\n");
        ObjectSetString(ChartID(), preEndLine, OBJPROP_TOOLTIP, "\n");
        ObjectSetString(ChartID(), endLine, OBJPROP_TOOLTIP, "\n");
        ObjectSetInteger(ChartID(), preSsLine, OBJPROP_HIDDEN, true);
        ObjectSetInteger(ChartID(), beginLine, OBJPROP_HIDDEN, true);
        ObjectSetInteger(ChartID(), preEndLine, OBJPROP_HIDDEN, true);
        ObjectSetInteger(ChartID(), endLine, OBJPROP_HIDDEN, true);
        ObjectSet(preSsLine, OBJPROP_RAY, false);
        ObjectSet(beginLine, OBJPROP_RAY, false);
        ObjectSet(preEndLine, OBJPROP_RAY, false);
        ObjectSet(endLine, OBJPROP_RAY, false);
        ObjectSet(preSsLine, OBJPROP_COLOR, BoxColor);
        ObjectSet(beginLine, OBJPROP_COLOR, BoxColor);
        ObjectSet(preEndLine, OBJPROP_COLOR, BoxColor);
        ObjectSet(endLine, OBJPROP_COLOR, BoxColor);
    }
    ObjectSet(preSsLine, OBJPROP_PRICE1, hi);
    ObjectSet(preSsLine, OBJPROP_PRICE2, lo);
    ObjectSet(preSsLine, OBJPROP_TIME1, dt+BeginHour*3600-30*60);
    ObjectSet(preSsLine, OBJPROP_TIME2, dt+BeginHour*3600-30*60);
    ObjectSet(preEndLine, OBJPROP_PRICE1, hi);
    ObjectSet(preEndLine, OBJPROP_PRICE2, lo);
    ObjectSet(preEndLine, OBJPROP_TIME1, dt+EndHour*3600-30*60);
    ObjectSet(preEndLine, OBJPROP_TIME2, dt+EndHour*3600-30*60);


    ObjectSet(beginLine, OBJPROP_PRICE1, hi);
    ObjectSet(beginLine, OBJPROP_PRICE2, lo);
    ObjectSet(beginLine, OBJPROP_TIME1, dt+EndHour*3600);
    ObjectSet(beginLine, OBJPROP_TIME2, dt+EndHour*3600);
    ObjectSet(endLine, OBJPROP_PRICE1, hi);
    ObjectSet(endLine, OBJPROP_PRICE2, lo);
    ObjectSet(endLine, OBJPROP_TIME1, dt+BeginHour*3600);
    ObjectSet(endLine, OBJPROP_TIME2, dt+BeginHour*3600);
}