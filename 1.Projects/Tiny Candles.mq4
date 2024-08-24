#property copyright "Timmy Ham Hoc"
#property link "https://www.youtube.com/@TimmyTraderHamHoc"
#property icon "../3.Resource/Timmy-Ham-học-Logo.ico"
#property version "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4

#define APP_TAG "TinyCandles"
//--- plot Wick1
#property indicator_label1 "Wick1"
#property indicator_type1 DRAW_HISTOGRAM
#property indicator_color1 clrIndianRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 0
//--- plot Wick2
#property indicator_label2 "Wick2"
#property indicator_type2 DRAW_HISTOGRAM
#property indicator_color2 clrSeaGreen
#property indicator_style2 STYLE_SOLID
#property indicator_width2 0
//--- plot Body1
#property indicator_label1 "Body1"
#property indicator_type1 DRAW_HISTOGRAM
#property indicator_color1 clrIndianRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
//--- plot Body2
#property indicator_label2 "Body2"
#property indicator_type2 DRAW_HISTOGRAM
#property indicator_color2 clrSeaGreen
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
//--- indicator buffers
double Wick1Buffer[];
double Wick2Buffer[];
double Body1Buffer[];
double Body2Buffer[];

#define M_BD_SIZE gArrSizeMap[gChartScale]-1
int     gTotalRate = -1;
int     gArrSizeMap[6];
int     gChartScale, gPreChartScale;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    //--- indicator buffers mapping
    SetIndexBuffer(0, Wick1Buffer);
    SetIndexBuffer(1, Wick2Buffer);
    SetIndexBuffer(2, Body1Buffer);
    SetIndexBuffer(3, Body2Buffer);

    gArrSizeMap[0] = 0;
    gArrSizeMap[1] = 0;
    gArrSizeMap[2] = 0;
    gArrSizeMap[3] = 3;
    gArrSizeMap[4] = 4;
    gArrSizeMap[5] = 6;

    updateStyle();
    return (INIT_SUCCEEDED);
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
                const int &spread[]) {
    //---
    if (gTotalRate != rates_total) {
        gTotalRate = rates_total;
        loadCandles();
    }
    else {
        int bar = 0;
        Body1Buffer[bar] = Open[bar];
        Body2Buffer[bar] = Close[bar];
        if (Open[bar] > Close[bar]) {
            Wick1Buffer[bar] = High[bar];
            Wick2Buffer[bar] = Low[bar];
        }
        else if (Close[bar] > Open[bar]) {
            Wick1Buffer[bar] = Low[bar];
            Wick2Buffer[bar] = High[bar];
        }
        else {
            if (Open[bar+1] > Close[bar+1]) {
                Wick1Buffer[bar] = High[bar];
                Wick2Buffer[bar] = Low[bar];
            }
            else {
                Wick1Buffer[bar] = Low[bar];
                Wick2Buffer[bar] = High[bar];
            }
        }
    }
    //--- return value of prev_calculated for next call
    return (rates_total);
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
    gChartScale = (int)ChartGetInteger(0, CHART_SCALE);
    if (gChartScale != gPreChartScale){
        gPreChartScale = gChartScale;
        updateStyle();
    }
}
//+------------------------------------------------------------------+

void loadCandles()
{
    for (int bar = gTotalRate-2; bar >= 0; bar --){
        Body1Buffer[bar] = Open[bar];
        Body2Buffer[bar] = Close[bar];
        if (Open[bar] > Close[bar]) {
            Wick1Buffer[bar] = High[bar];
            Wick2Buffer[bar] = Low[bar];
        }
        else {
            Wick1Buffer[bar] = Low[bar];
            Wick2Buffer[bar] = High[bar];
        }
    }
}

void updateStyle()
{
    SetIndexStyle(2, DRAW_HISTOGRAM, 0, M_BD_SIZE, clrIndianRed);
    SetIndexStyle(3, DRAW_HISTOGRAM, 0, M_BD_SIZE, clrSeaGreen);
}