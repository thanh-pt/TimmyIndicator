#property copyright "mt4 tools - WIKI"
#property link      "https://aforexstory.notion.site/1104379b17ec80218296ccaa5eb0ff14"
#property description "Modified from MetaQuotes Software Corp's Heiken Ashi with bellow addition:"
#property description " - Line Chart turn on at when Boot up"
#property description " - Magic CandleStick size when Scale Chart"
#property description " - Convinient on/off when change to Bar Chart"
#property strict

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_color4 Green
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3

//---
input string    ExtOnOffHk = "L";     // Hotkey ON/OFF (Heiken Ashi <-> Candles)
input bool      ExtAutoON  = false;   // Auto ON Heiken Ashi Chart
input color     ExtColor1  = Red;   // Bear candlestick
input color     ExtColor2  = Green; // Bull candlestick
//--- buffers
double ExtLowHighBuffer[];
double ExtHighLowBuffer[];
double ExtOpenBuffer[];
double ExtCloseBuffer[];

int BodySize[6];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
void OnInit(void) {
    IndicatorShortName("Heiken Ashi");
    IndicatorDigits(Digits);
    //--- init Style
    BodySize[0] = 0;
    BodySize[1] = 1;
    BodySize[2] = 2;
    BodySize[3] = 3;
    BodySize[4] = 6;
    BodySize[5] = 13;
    if (ExtAutoON) ChartSetInteger(0, CHART_MODE, CHART_LINE);
    updateStyle();
    //--- indicator lines
    SetIndexStyle(0, DRAW_HISTOGRAM, 0, 1, ExtColor1);
    SetIndexBuffer(0, ExtLowHighBuffer);
    SetIndexStyle(1, DRAW_HISTOGRAM, 0, 1, ExtColor2);
    SetIndexBuffer(1, ExtHighLowBuffer);
    SetIndexStyle(2, DRAW_HISTOGRAM, 0, 3, ExtColor1);
    SetIndexBuffer(2, ExtOpenBuffer);
    SetIndexStyle(3, DRAW_HISTOGRAM, 0, 3, ExtColor2);
    SetIndexBuffer(3, ExtCloseBuffer);
    //---
    SetIndexLabel(0, "Low/High");
    SetIndexLabel(1, "High/Low");
    SetIndexLabel(2, "Open");
    SetIndexLabel(3, "Close");
    SetIndexDrawBegin(0, 10);
    SetIndexDrawBegin(1, 10);
    SetIndexDrawBegin(2, 10);
    SetIndexDrawBegin(3, 10);
    //--- indicator buffers mapping
    SetIndexBuffer(0, ExtLowHighBuffer);
    SetIndexBuffer(1, ExtHighLowBuffer);
    SetIndexBuffer(2, ExtOpenBuffer);
    SetIndexBuffer(3, ExtCloseBuffer);
    //--- initialization done
}
//+------------------------------------------------------------------+
//| Heiken Ashi                                                      |
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
                const int & spread[])
{
    int i, pos;
    double haOpen, haHigh, haLow, haClose;
    //---
    if (rates_total <= 10)
        return (0);
    //--- counting from 0 to rates_total
    ArraySetAsSeries(ExtLowHighBuffer, false);
    ArraySetAsSeries(ExtHighLowBuffer, false);
    ArraySetAsSeries(ExtOpenBuffer, false);
    ArraySetAsSeries(ExtCloseBuffer, false);
    ArraySetAsSeries(open, false);
    ArraySetAsSeries(high, false);
    ArraySetAsSeries(low, false);
    ArraySetAsSeries(close, false);
    //--- preliminary calculation
    if (prev_calculated > 1)
        pos = prev_calculated - 1;
    else {
        //--- set first candle
        if (open[0] < close[0]) {
            ExtLowHighBuffer[0] = low[0];
            ExtHighLowBuffer[0] = high[0];
        } else {
            ExtLowHighBuffer[0] = high[0];
            ExtHighLowBuffer[0] = low[0];
        }
        ExtOpenBuffer[0] = open[0];
        ExtCloseBuffer[0] = close[0];
        //---
        pos = 1;
    }
    //--- main loop of calculations
    for (i = pos; i < rates_total; i++) {
        haOpen = (ExtOpenBuffer[i - 1] + ExtCloseBuffer[i - 1]) / 2;
        haClose = (open[i] + high[i] + low[i] + close[i]) / 4;
        haHigh = MathMax(high[i], MathMax(haOpen, haClose));
        haLow = MathMin(low[i], MathMin(haOpen, haClose));
        if (haOpen < haClose) {
            ExtLowHighBuffer[i] = haLow;
            ExtHighLowBuffer[i] = haHigh;
        } else {
            ExtLowHighBuffer[i] = haHigh;
            ExtHighLowBuffer[i] = haLow;
        }
        ExtOpenBuffer[i] = haOpen;
        ExtCloseBuffer[i] = haClose;
    }
    //--- done
    return (rates_total);
}
//+------------------------------------------------------------------+

int gChartMode = 0;
int gPreChartMode = -1;
int gChartScale = 0;
int gPreChartScale = -1;
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{   
    if (id == CHARTEVENT_KEYDOWN) {
        if (lparam == ExtOnOffHk[0]){
            if (gChartMode == CHART_LINE) {
                ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
                gChartMode = CHART_CANDLES;
            }
            else {
                ChartSetInteger(0, CHART_MODE, CHART_LINE);
                gChartMode = CHART_LINE;
            }
            updateStyle();
            return;
        }
    }
    gChartMode  = (int)ChartGetInteger(0, CHART_MODE);
    if (gChartMode != gPreChartMode) {
        gPreChartMode = gChartMode;
        updateStyle();
    }
    gChartScale = (int) ChartGetInteger(0, CHART_SCALE);
    if (gChartScale != gPreChartScale) {
        gPreChartScale = gChartScale;
        updateStyle();
    }
}

void updateStyle()
{
    if (gChartMode == CHART_LINE) {
        SetIndexStyle(0, DRAW_HISTOGRAM, 0, 1, ExtColor1);
        SetIndexStyle(1, DRAW_HISTOGRAM, 0, 1, ExtColor2);
        SetIndexStyle(2, DRAW_HISTOGRAM, 0, BodySize[gChartScale], ExtColor1);
        SetIndexStyle(3, DRAW_HISTOGRAM, 0, BodySize[gChartScale], ExtColor2);
    }
    else {
        SetIndexStyle(0, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(1, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(2, DRAW_HISTOGRAM, 0, 0, clrNONE);
        SetIndexStyle(3, DRAW_HISTOGRAM, 0, 0, clrNONE);
    }
}