//+------------------------------------------------------------------+
//|                                               Trading Report.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot PnL
#property indicator_label1  "PnL"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlack
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- indicator buffers
double         PnLBuffer[];

#define MAXTRADE 1000
#define TXT_SPACING 25
#define TXT_SPACE_BLOCK "                    "
#define BGBLOCK "██████████████████████████████████████████████████████████████████"

string APP_TAG = "TradingReport";

input double RiskPerTrade = 100;

struct TradeInfo
{
    bool        IsBuy;
    double      CostPip;
    double      PlPip;
    double      PnL;
    double      RR;
    int         DayOfWk;
    int         WeekNum;
};

enum eBtnId{
    eBtnNone,
    eBtnReloadGraph,
    eBtnRemoveAll,
};

color gTextColor=clrBlack;

int       gTradeCount = 0;
TradeInfo gListTrades[MAXTRADE+1];
double    gWkData[7];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    SetIndexBuffer(0,PnLBuffer);
    drawHmi();
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
//--- return value of prev_calculated for next call
    return(rates_total);
}

int WeeknumOfYear(datetime date)
{
    return (TimeDayOfYear(date)+TimeDayOfWeek(StrToTime(IntegerToString(TimeYear(date))+".01.01"))-2)/7;
}

string NumToStr(double num, int size, int digit)
{
    string str = DoubleToString(num, digit);
    if (size <= StringLen(str)) return str;
    return StringSubstr(TXT_SPACE_BLOCK, 0, size - StringLen(str)) + str;
}

string NumToStr(int num, int size)
{
    string str = IntegerToString(num);
    if (size <= StringLen(str)) return str;
    return StringSubstr(TXT_SPACE_BLOCK, 0, size - StringLen(str)) + str;
}

void loadData()
{
    gTradeCount = 0;
    string objEn = "";
    string objEx = "";
    string enData = "";
    string exData = "";

    string sparamItems[];
    double lotSize;

    datetime time1;
    double plDola;
    double plPip;
    bool   isBuy;
    double pipSL;
    for (int idx = 0; idx < MAXTRADE; idx++) {
        // Step 1: Find obj
        objEn = "sim#3d_en#" + IntegerToString(idx);
        if (ObjectFind(objEn) < 0) continue;
        objEx = "sim#3d_ex#" + IntegerToString(idx);

        // Step 2: extract data
        enData = ObjectGetString(0, objEn, OBJPROP_TOOLTIP);
        exData = ObjectGetString(0, objEx, OBJPROP_TOOLTIP);
        StringSplit(enData,'\n',sparamItems);
        lotSize = StrToDouble(StringSubstr(sparamItems[1], 6, 4));
        isBuy   = ((color)ObjectGet(objEn, OBJPROP_COLOR) == clrBlue);
        time1   = (datetime)ObjectGet(objEn, OBJPROP_TIME1);
        pipSL   = RiskPerTrade/lotSize/10;
        StringSplit(exData,'\n',sparamItems);
        plDola  = StrToDouble(StringSubstr(sparamItems[3], 5, 6));
        plPip   = StrToDouble(StringSubstr(sparamItems[4], 6, 4));
        //---
        gListTrades[gTradeCount].IsBuy   = isBuy;
        gListTrades[gTradeCount].CostPip = pipSL;
        gListTrades[gTradeCount].PlPip   = plPip;
        gListTrades[gTradeCount].PnL  = plDola;
        gListTrades[gTradeCount].RR    = plDola/RiskPerTrade;
        gListTrades[gTradeCount].DayOfWk = TimeDayOfWeek(time1);
        gListTrades[gTradeCount].WeekNum = WeeknumOfYear(time1);
        gTradeCount++;
    }
}

void setTableTextLine(int idx, string text)
{
    string objName = APP_TAG+"Table"+IntegerToString(idx);
    ObjectCreate(objName, OBJ_LABEL, 1, 0, 0);
    ObjectSetText(objName, text, 12, "Consolas", gTextColor);
    ObjectSet(objName, OBJPROP_XDISTANCE, 10);
    ObjectSet(objName, OBJPROP_YDISTANCE, 10 + idx * 14);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
}

string composeTableLineText(int wkNum, int tp, int be, int sl)
{
    string strData = "|" + NumToStr(wkNum,2) + "|";
    strData += NumToStr(gWkData[1], 4, 1) + "|";
    strData += NumToStr(gWkData[2], 4, 1) + "|";
    strData += NumToStr(gWkData[3], 4, 1) + "|";
    strData += NumToStr(gWkData[4], 4, 1) + "|";
    strData += NumToStr(gWkData[5], 4, 1) + "||";
    strData += NumToStr(gWkData[1] + gWkData[2] + gWkData[3] + gWkData[4] + gWkData[5], 5, 1) + "| |";
    strData += NumToStr(tp,2) + "|";
    strData += NumToStr(be,2) + "|";
    strData += NumToStr(sl,2) + "||";
    int allTrade = tp+be+sl;
    strData += NumToStr(allTrade,3) + "|";
    strData += NumToStr(100*(tp+be)/allTrade, 3) + "%|";
    strData += NumToStr(100*tp/allTrade, 3) + "%|";
    return strData;
}

void displayData()
{
    // Background
    string objName = APP_TAG+"#Background";
    ObjectCreate(objName, OBJ_LABEL, 1, 0, 0);
    ObjectSetText(objName, "██", 400, "Consolas", clrWhiteSmoke);
    ObjectSet(objName, OBJPROP_XDISTANCE, 0);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");

    int tbLn = 0;
    setTableTextLine(tbLn++, "+----------------------------------+ +-----------------------+");
    setTableTextLine(tbLn++, "|   W E E K L Y   R E P O R T      | |       Performance     |");
    setTableTextLine(tbLn++, "+----------------------------------+ +-----------------------+");
    setTableTextLine(tbLn++, "|Wk| T2 | T3 | T4 | T5 | T6 || P/L | |TP|BE|SL||All| WR | PR |");
    setTableTextLine(tbLn++, "+--+----+----+----+----+----++-----+ +--+--+--++---+----+----+");
    if (gTradeCount == 0) return;


    int wkNum = -1;
    int tp = 0;
    int be = 0;
    int sl = 0;
    int tpAll = 0;
    int beAll = 0;
    int slAll = 0;
    double plAll = 0;
    double tpRRSum = 0;
    double tpPipSum = 0;
    double costPipSum = 0;
    
    for (int i = 0; i < gTradeCount; i++){
        if (gListTrades[i].WeekNum != wkNum){
            //print Data
            if (wkNum != -1){
                setTableTextLine(tbLn++, composeTableLineText(wkNum, tp, be, sl));
                //---
                tpAll += tp;
                beAll += be;
                slAll += sl;
            }
            //clear data
            tp = 0; be = 0; sl = 0;
            gWkData[0] = 0; gWkData[1] = 0; gWkData[2] = 0; gWkData[3] = 0; gWkData[4] = 0; gWkData[5] = 0; gWkData[6] = 0;
            wkNum = gListTrades[i].WeekNum;
        }
        if (gListTrades[i].PnL > RiskPerTrade*0.6){
            tp++;
            tpPipSum += gListTrades[i].PlPip;
            tpRRSum  += gListTrades[i].RR;
        }
        else if (gListTrades[i].PnL < -RiskPerTrade*0.6) sl++;
        else be++;
        gWkData[gListTrades[i].DayOfWk] += gListTrades[i].RR;
        costPipSum += gListTrades[i].CostPip;
        plAll   += gListTrades[i].RR;
    }
    if (wkNum != -1){
        //print last data
        setTableTextLine(tbLn++, composeTableLineText(wkNum, tp, be, sl));
        //---
        tpAll += tp;
        beAll += be;
        slAll += sl;
    }
    { // Tổng kết
        string sumupLine       = "|                           ||";
        sumupLine += NumToStr(plAll, 5, 1) + "| |";
        sumupLine += NumToStr(tpAll,2) + "|";
        sumupLine += NumToStr(beAll,2) + "|";
        sumupLine += NumToStr(slAll,2) + "||";
        sumupLine += NumToStr(gTradeCount,3) + "|";
        sumupLine += NumToStr((tpAll+beAll)*100/gTradeCount, 3) + "%|";
        sumupLine += NumToStr(tpAll*100/gTradeCount, 3) + "%|";
        setTableTextLine(tbLn++, "+---------------------------++-----+ +--+--+--++---+----+----+");
        setTableTextLine(tbLn++, sumupLine);
        setTableTextLine(tbLn++, "+---------------------------++-----+ +--+--+--++---+----+----+");
    }
    {// Other data
        setTableTextLine(tbLn++, "Chỉ số TRUNG BÌNH");
        if (tpAll != 0){
            setTableTextLine(tbLn++, "TP pip:" + NumToStr(tpPipSum/tpAll, 5, 1) + "   RR:" + NumToStr(tpRRSum/tpAll, 5, 1));
        } else {
            setTableTextLine(tbLn++, "TP pip:" + NumToStr(0, 5, 1) + "   RR:" + NumToStr(0, 5, 1));
        }
        setTableTextLine(tbLn++, "SL pip:" + NumToStr(costPipSum/gTradeCount, 5, 1));
    }
    ObjectSet(objName, OBJPROP_YDISTANCE, tbLn*14-600);
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
    if (id == CHARTEVENT_OBJECT_CLICK){
        string sparamItems[];
        int k = StringSplit(sparam,':',sparamItems);
        if (k != 2) return;
        handleButtonEvent(StrToInteger(sparamItems[1]));
    }
    else if (id == CHARTEVENT_OBJECT_DELETE){
        drawHmi();
    }
}

void handleButtonEvent(int btnIdx)
{
    switch (btnIdx){
        case eBtnReloadGraph:
            removeAllItem();
            loadData();
            drawGraph();
            displayData();
            break;
        case eBtnRemoveAll:
            removeAllItem();
            break;
    }
}

int gTextLabelIdx = 0;
int gVerticalLineIdx = 0;
int gDotIdx = 0;

void drawGraph()
{
    gTextLabelIdx = 0;
    gVerticalLineIdx = 0;
    gDotIdx = 0;
    double currRR = 0;
    double contLoss = 0;
    double contProfit = 0;
    int curCW = gListTrades[0].WeekNum;
    drawVerticalLine(gVerticalLineIdx++, "Wk"+IntegerToString(curCW), Time[gTradeCount]);
    for (int i = 0; i < gTradeCount; i++){
        currRR += gListTrades[i].RR;
        PnLBuffer[gTradeCount-i] = currRR;
        drawDot(gDotIdx++, Time[gTradeCount-i], currRR);
        if (gListTrades[i].RR < 0){ // loss
            contLoss += gListTrades[i].RR;
            if (contProfit > 1){
                drawTextLabel(gTextLabelIdx++, DoubleToString(contProfit, 1), Time[gTradeCount-i+1], PnLBuffer[gTradeCount-i+1], ANCHOR_RIGHT_LOWER);
            }
            contProfit = 0;
        }
        else if (gListTrades[i].RR > 0.8){ // Profit
            contProfit += gListTrades[i].RR;
            if (contLoss != 0){
                drawTextLabel(gTextLabelIdx++, DoubleToString(contLoss, 1), Time[gTradeCount-i+1], PnLBuffer[gTradeCount-i+1], ANCHOR_RIGHT_UPPER);
            }
            contLoss = 0;
        }
        // Wk separate
        if (gListTrades[i].WeekNum != curCW){
            curCW = gListTrades[i].WeekNum;
            drawVerticalLine(gVerticalLineIdx++, "Wk"+IntegerToString(curCW), Time[gTradeCount-i+1]);
        }
    }
    // Draw last contPnL
    if (contLoss != 0){
        drawTextLabel(gTextLabelIdx++, DoubleToString(contLoss, 1), Time[1], PnLBuffer[1], ANCHOR_RIGHT_UPPER);
        contLoss = 0;
    }
    if (contProfit != 0){
        drawTextLabel(gTextLabelIdx++, DoubleToString(contProfit, 1), Time[1], PnLBuffer[1], ANCHOR_RIGHT_LOWER);
        contProfit = 0;
    }
}

void drawHmi()
{
    drawButton(eBtnReloadGraph, "Reload Graph");
    drawButton(eBtnRemoveAll, "Remove All");
}

void drawButton(int index, string text)
{
    string objName = APP_TAG + "#BtnBg:" + IntegerToString(index);
    ObjectCreate(objName, OBJ_LABEL, 1, 0, 0);// TODO: using find window index https://docs.mql4.com/chart_operations/windowfind
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSetText(objName, StringSubstr(BGBLOCK, 0, StringLen(text)), 15, "Consolas", clrGainsboro);
    ObjectSet(objName, OBJPROP_XDISTANCE, 5);
    ObjectSet(objName, OBJPROP_YDISTANCE, index * TXT_SPACING);
    ObjectSetString(0 , objName, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objName, OBJPROP_CORNER , CORNER_RIGHT_UPPER);
    ObjectSet(objName, OBJPROP_ANCHOR , ANCHOR_RIGHT_UPPER);
    //--------------------------------------------
    objName = APP_TAG + "#Btn:" + IntegerToString(index);
    ObjectCreate(objName, OBJ_LABEL, 1, 0, 0);
    ObjectSetText(objName, text, 14, "Consolas");
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSet(objName, OBJPROP_COLOR, clrBlack);
    ObjectSet(objName, OBJPROP_XDISTANCE, 5+3);
    ObjectSet(objName, OBJPROP_YDISTANCE, index * TXT_SPACING);
    ObjectSetString(0 , objName, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objName, OBJPROP_CORNER , CORNER_RIGHT_UPPER);
    ObjectSet(objName, OBJPROP_ANCHOR , ANCHOR_RIGHT_UPPER);
}

void drawTextLabel(int index, string text, datetime time1, double price1, int anchor)
{
    string objName = APP_TAG + "TextLabel" + IntegerToString(index);
    ObjectCreate(objName, OBJ_TEXT, 1, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_BACK, true);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objName, OBJPROP_HIDDEN, true);
    // Basic
    ObjectSet(objName, OBJPROP_TIME1, time1);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
    ObjectSetText(objName, text, 7, NULL, clrBlack);
    ObjectSet(objName, OBJPROP_ANCHOR, anchor);
}

void drawDot(int index, datetime time1, double price1)
{
    string objName = APP_TAG + "Dot" + IntegerToString(index);
    ObjectCreate(objName, OBJ_TEXT, 1, 0, 0);
    // Default
    // ObjectSet(objName, OBJPROP_BACK, true);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, DoubleToString(price1, 1));
    ObjectSet(objName, OBJPROP_HIDDEN, true);
    // Basic
    ObjectSet(objName, OBJPROP_TIME1, time1);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
    ObjectSetText(objName, "n", 4, "webdings", clrBlack);
    ObjectSet(objName, OBJPROP_ANCHOR, ANCHOR_CENTER);
}

void drawVerticalLine(int index, string text, datetime time1)
{
    string objName = APP_TAG + "VerticalLine" + IntegerToString(index);
    ObjectCreate(objName, OBJ_VLINE, 1, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_BACK, true);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objName, OBJPROP_HIDDEN, true);
    // Basic
    ObjectSet(objName, OBJPROP_TIME1, time1);
    ObjectSetText(objName, text);
    // Style
    ObjectSet(objName, OBJPROP_STYLE, STYLE_DOT);
    ObjectSet(objName, OBJPROP_WIDTH, 0);
    // Basic
    ObjectSet(objName, OBJPROP_COLOR, clrGray);
}

void removeAllItem()
{
    for (int i = ObjectsTotal() - 1; i >= 0; i--) {
        string objName = ObjectName(i);
        if (StringFind(objName, "#") != -1) continue;
        if (StringFind(objName, APP_TAG) != -1) ObjectDelete(objName);
    }

    int i = 1;
    while (PnLBuffer[i] != EMPTY_VALUE){
        PnLBuffer[i++] = EMPTY_VALUE;
    }
}