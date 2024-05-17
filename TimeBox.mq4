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

string APP_TAG = "TimeBox";

input string BoxLabel = "Ld";
input int BeginHour = 7;
input int EndHour = 10;
input color BoxColor = clrSlateGray;
input ENUM_LINE_STYLE BoxStyle = STYLE_DOT;
input bool  DrawTodayLine = true;
input color PreSSColor   = clrSlateGray;
input color StartSSColor = clrDarkGreen;
input color PreEndColor  = clrCrimson;
input color EODColor     = clrSlateGray;


int chartPeriod;
int barBoxCount;
bool chartReady;
long gShowPeriodSep;
int prev_totalRate;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    //--- indicator buffers mapping
    chartPeriod = ChartPeriod();
    barBoxCount = (EndHour-BeginHour)*60/chartPeriod;
    chartReady = false;
    APP_TAG += BoxLabel;
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
    if (id == CHARTEVENT_CHART_CHANGE && chartPeriod <= PERIOD_M15) {
        ChartGetInteger(ChartID(),CHART_SHOW_PERIOD_SEP,0,gShowPeriodSep);
        scanAndDrawTimeBox();
    }
}
//+------------------------------------------------------------------+

void scanAndDrawTimeBox(){
    if (!chartReady) return;
    int timeBoxIdx = 0;
    if (gShowPeriodSep == 1){
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
        if (bar == 0 && DrawTodayLine && chartPeriod < PERIOD_M15){
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
            drawTodayTimeBox(dt_today);
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
        
        objName = APP_TAG + "4" + IntegerToString(timeBoxIdx);
        ObjectSet(objName, OBJPROP_TIME2, 0);
        ObjectSet(objName, OBJPROP_TIME1, 0);

        objName = APP_TAG + "5" + IntegerToString(timeBoxIdx++);
        ObjectSet(objName, OBJPROP_TIME2, 0);
        ObjectSet(objName, OBJPROP_TIME1, 0);
    } while (ObjectFind(objName) >= 0);
}

void drawTimeBox(int index, datetime begin_dt, datetime end_dt, double hi, double lo){
    string objName1 = APP_TAG + "1" + IntegerToString(index);
    string objName2 = APP_TAG + "2" + IntegerToString(index);
    string objName3 = APP_TAG + "3" + IntegerToString(index);
    string objName4 = APP_TAG + "4" + IntegerToString(index);
    string objName5 = APP_TAG + "5" + IntegerToString(index);
    if (ObjectFind(objName1) < 0) {
        ObjectCreate(objName1, OBJ_TREND, 0, 0, 0);
        ObjectCreate(objName2, OBJ_TREND, 0, 0, 0);
        ObjectCreate(objName3, OBJ_TREND, 0, 0, 0);
        ObjectCreate(objName4, OBJ_TREND, 0, 0, 0);
        ObjectCreate(objName5, OBJ_TEXT, 0, 0, 0);
        ObjectSet(objName1, OBJPROP_BACK, true);
        ObjectSet(objName2, OBJPROP_BACK, true);
        ObjectSet(objName3, OBJPROP_BACK, true);
        ObjectSet(objName4, OBJPROP_BACK, true);
        ObjectSet(objName5, OBJPROP_BACK, true);

        ObjectSet(objName1, OBJPROP_STYLE, BoxStyle);
        ObjectSet(objName2, OBJPROP_STYLE, BoxStyle);
        ObjectSet(objName3, OBJPROP_STYLE, BoxStyle);
        ObjectSet(objName4, OBJPROP_STYLE, BoxStyle);
        ObjectSet(objName1, OBJPROP_WIDTH, 0);
        ObjectSet(objName2, OBJPROP_WIDTH, 0);
        ObjectSet(objName3, OBJPROP_WIDTH, 0);
        ObjectSet(objName4, OBJPROP_WIDTH, 0);
        ObjectSet(objName1, OBJPROP_SELECTABLE, false);
        ObjectSet(objName2, OBJPROP_SELECTABLE, false);
        ObjectSet(objName3, OBJPROP_SELECTABLE, false);
        ObjectSet(objName4, OBJPROP_SELECTABLE, false);
        ObjectSet(objName5, OBJPROP_SELECTABLE, false);
        ObjectSetString(ChartID(), objName1, OBJPROP_TOOLTIP, "\n");
        ObjectSetString(ChartID(), objName2, OBJPROP_TOOLTIP, "\n");
        ObjectSetString(ChartID(), objName3, OBJPROP_TOOLTIP, "\n");
        ObjectSetString(ChartID(), objName4, OBJPROP_TOOLTIP, "\n");
        ObjectSetString(ChartID(), objName5, OBJPROP_TOOLTIP, "\n");
        ObjectSetInteger(ChartID(), objName1, OBJPROP_HIDDEN, true);
        ObjectSetInteger(ChartID(), objName2, OBJPROP_HIDDEN, true);
        ObjectSetInteger(ChartID(), objName3, OBJPROP_HIDDEN, true);
        ObjectSetInteger(ChartID(), objName4, OBJPROP_HIDDEN, true);
        ObjectSetInteger(ChartID(), objName5, OBJPROP_HIDDEN, true);
        ObjectSet(objName1, OBJPROP_RAY, false);
        ObjectSet(objName2, OBJPROP_RAY, false);
        ObjectSet(objName3, OBJPROP_RAY, false);
        ObjectSet(objName4, OBJPROP_RAY, false);
        ObjectSet(objName1, OBJPROP_COLOR, BoxColor);
        ObjectSet(objName2, OBJPROP_COLOR, BoxColor);
        ObjectSet(objName3, OBJPROP_COLOR, BoxColor);
        ObjectSet(objName4, OBJPROP_COLOR, BoxColor);
        ObjectSet(objName5, OBJPROP_COLOR, BoxColor);

        ObjectSetText(objName5, BoxLabel, 7);
        ObjectSetInteger(ChartID(), objName5, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
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

    ObjectSet(objName5, OBJPROP_PRICE1, hi);
    ObjectSet(objName5, OBJPROP_TIME1, end_dt);

}

void hideTodayTimeBox()
{
    string objPreSS  = APP_TAG + "PreSS" ;
    string objStart  = APP_TAG + "Start" ;
    string objPreEnd = APP_TAG + "PreEnd";
    string objEOD    = APP_TAG + "EOD"   ;
    ObjectSet(objPreSS , OBJPROP_TIME1, 0);
    ObjectSet(objStart , OBJPROP_TIME1, 0);
    ObjectSet(objPreEnd, OBJPROP_TIME1, 0);
    ObjectSet(objEOD   , OBJPROP_TIME1, 0);
}

void drawHorizontalLine(string lablel, color c, datetime dt)
{
    string objName = APP_TAG + lablel;
    if (ObjectFind(objName) < 0) {
        ObjectCreate(objName, OBJ_VLINE, 0, 0, 0);
        ObjectSet(objName, OBJPROP_BACK, true);

        ObjectSet(objName, OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(objName, OBJPROP_WIDTH, 0);
        ObjectSet(objName, OBJPROP_SELECTABLE, false);
        ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
        ObjectSetText(objName, lablel);
        ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, true);
        ObjectSet(objName, OBJPROP_RAY, false);
        ObjectSet(objName, OBJPROP_COLOR, c);
    }
    ObjectSet(objName, OBJPROP_TIME1, dt);

    if (c == clrNONE) {
        ObjectSet(objName , OBJPROP_TIME1, 0);
    }
}

void drawTodayTimeBox(datetime dt)
{
    drawHorizontalLine("PreSS" , PreSSColor  , dt+BeginHour*3600-1800);
    drawHorizontalLine("Start" , StartSSColor, dt+BeginHour*3600);
    drawHorizontalLine("PreEnd", PreEndColor , dt+EndHour*3600-1800);
    drawHorizontalLine("EOD"   , EODColor    , dt+EndHour*3600);
}