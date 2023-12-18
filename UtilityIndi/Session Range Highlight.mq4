//+------------------------------------------------------------------+
//|                                                 SessionRange.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link "https://www.youtube.com/@TimmyTraderHamHoc"
#property version "1.00"
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

#define APP_TAG "SSHighlight%"
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
int asBegHourT = 0;
int asEndHourT = 6;
int ldBegHourT = 7;
int ldEndHourT = 11;
int nyBegHourT = 12;
int nyEndHourT = 16;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    //--- indicator buffers mapping
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
    //---
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
    for (int i = ObjectsTotal() - 1; i >= 0; i--) {
        string objName = ObjectName(i);
        if (StringFind(objName, APP_TAG) != -1) ObjectDelete(objName);
    }
}

void drawSession(string sessionName, int beginIndex, int endHour, double & bufferHi[], double & bufferLo[], color c) {
    double priceHi = High[beginIndex];
    double priceLo = Low[beginIndex];
    string objName = "";
    while (beginIndex >= 0 && (TimeHour(Time[beginIndex]) < endHour || TimeMinute(Time[beginIndex]) == 0)) {
        if (High[beginIndex] > priceHi) priceHi = High[beginIndex];
        if (Low[beginIndex] < priceLo) priceLo = Low[beginIndex];
        // asian Buffer
        bufferHi[beginIndex] = priceHi;
        bufferLo[beginIndex] = priceLo;
        if (displayBackgound) {
            objName = APP_TAG + TimeToStr(Time[beginIndex], TIME_DATE) + sessionName + "Bg" + IntegerToString(beginIndex);
            ObjectCreate(objName, OBJ_TREND, 0, Time[beginIndex], priceHi, Time[beginIndex], priceLo);
            ObjectSet(objName, OBJPROP_COLOR, c);
            ObjectSet(objName, OBJPROP_BACK, true);
            ObjectSet(objName, OBJPROP_RAY, false);
            ObjectSet(objName, OBJPROP_STYLE, STYLE_DOT);
            ObjectSet(objName, OBJPROP_WIDTH, 0);
            ObjectSet(objName, OBJPROP_SELECTABLE, false);
            ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
        }
        beginIndex--;
    }
    beginIndex++;
    objName = APP_TAG + TimeToStr(Time[beginIndex], TIME_DATE) + sessionName + "Label";
    if (displayLabel) {
        ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
        ObjectSet(objName, OBJPROP_TIME1, Time[beginIndex]);
        ObjectSet(objName, OBJPROP_PRICE1, priceHi);
        ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
        ObjectSetText(objName, sessionName, 8, NULL, c);
    }

    if (!displayBackgound && TimeHour(Time[beginIndex]) == endHour) {
        objName = APP_TAG + TimeToStr(Time[beginIndex], TIME_DATE) + sessionName + "Endline";
        ObjectCreate(objName, OBJ_TREND, 0, Time[beginIndex], priceHi, Time[beginIndex], priceLo);
        ObjectSet(objName, OBJPROP_COLOR, c);
        ObjectSet(objName, OBJPROP_BACK, true);
        ObjectSet(objName, OBJPROP_RAY, false);
        ObjectSet(objName, OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(objName, OBJPROP_WIDTH, 0);
        ObjectSet(objName, OBJPROP_SELECTABLE, false);
        ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
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
    int limit, i;
    int counted_bars = IndicatorCounted();

    //---- check for possible errors
    if (counted_bars < 0) return (-1);

    //---- initial zero

    //---- last counted bar will be recounted
    if (counted_bars > 0) counted_bars--;
    limit = Bars - counted_bars;

    //----Calculation---------------------------
    double priceHi = 0;
    double priceLo = 0;
    int beginIndex = 0;
    string session = "";
    int currentMonth = 0;
    for (i = 0; i < limit - 1; i++) {
        if (currentMonth != TimeMonth(Time[i])) {
            currentMonth = TimeMonth(Time[i]);
            if (currentMonth >= winterBeg || currentMonth < winterEnd) {
                asBegHourT = asBegHour + 1;
                asEndHourT = asEndHour + 1;
                ldBegHourT = ldBegHour + 1;
                ldEndHourT = ldEndHour + 1;
                nyBegHourT = nyBegHour + 1;
                nyEndHourT = nyEndHour + 1;
            } else {
                asBegHourT = asBegHour;
                asEndHourT = asEndHour;
                ldBegHourT = ldBegHour;
                ldEndHourT = ldEndHour;
                nyBegHourT = nyBegHour;
                nyEndHourT = nyEndHour;
            }
        }

        if (TimeMinute(Time[i]) == 0) {
            if (TimeHour(Time[i]) == asBegHourT) drawSession("Asian", i, asEndHourT, asHiBuffer, asLoBuffer, asianColor);
            if (TimeHour(Time[i]) == ldBegHourT) drawSession("London", i, ldEndHourT, ldHiBuffer, ldLoBuffer, londonColor);
            if (TimeHour(Time[i]) == nyBegHourT) drawSession("NewYork", i, nyEndHourT, nyHiBuffer, nyLoBuffer, newyorkColor);

        }
    }
    //--- return value of prev_calculated for next call
    return (rates_total);
}
//+------------------------------------------------------------------+