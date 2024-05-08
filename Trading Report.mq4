//+------------------------------------------------------------------+
//|                                               Trading Report.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define MAXTRADE 1000
#define TXT_SPACE_BLOCK "                    "

string APP_TAG = "TradingReport";

input double RiskPerTrade = 100;

struct TradeInfo
{
    bool        IsBuy;
    double      CostPip;
    double      PlPip;
    double      PlDola;
    double      PlRR;
    int         DayOfWk;
    int         WeekNum;
};

bool  gIsRun = false;
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
   
//---
    long foregroundColor=clrBlack;
    ChartGetInteger(ChartID(),CHART_COLOR_FOREGROUND,0,foregroundColor);
    gTextColor = (color)foregroundColor;
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
    long chartID = ChartID();
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
        enData = ObjectGetString(chartID, objEn, OBJPROP_TOOLTIP);
        exData = ObjectGetString(chartID, objEx, OBJPROP_TOOLTIP);
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
        gListTrades[gTradeCount].PlDola  = plDola;
        gListTrades[gTradeCount].PlRR    = plPip/pipSL;
        gListTrades[gTradeCount].DayOfWk = TimeDayOfWeek(time1);
        gListTrades[gTradeCount].WeekNum = WeeknumOfYear(time1);
        gTradeCount++;
    }
}

void setTableTextLine(int idx, string text)
{
    string objName = APP_TAG+"Table"+IntegerToString(idx);
    ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
    ObjectSetText(objName, text, 12, "Consolas", gTextColor);
    ObjectSet(objName, OBJPROP_XDISTANCE, 5);
    ObjectSet(objName, OBJPROP_YDISTANCE, 10 + idx * 19);
    ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
}

string composeTableLineText(int wkNum, int tp, int be, int sl)
{
    string strData = "|" + NumToStr(wkNum,2) + "|";
    strData += NumToStr(gWkData[1], 4, 1) + "|";
    strData += NumToStr(gWkData[2], 4, 1) + "|";
    strData += NumToStr(gWkData[3], 4, 1) + "|";
    strData += NumToStr(gWkData[4], 4, 1) + "|";
    strData += NumToStr(gWkData[5], 4, 1) + "|";
    strData += NumToStr(gWkData[1] + gWkData[2] + gWkData[3] + gWkData[4] + gWkData[5], 5, 1) + "|";
    strData += NumToStr(tp,2) + "|";
    strData += NumToStr(be,2) + "|";
    strData += NumToStr(sl,2) + "|";
    int allTrade = tp+be+sl;
    strData += NumToStr(allTrade,3) + "|";
    strData += NumToStr(100*(tp+be)/allTrade, 3) + "%|";
    strData += NumToStr(100*tp/allTrade, 3) + "%|";
    return strData;
}

void displayData()
{
    int tbLn = 0;
    setTableTextLine(tbLn++, "+---------------------------------+----------------------+");
    setTableTextLine(tbLn++, "|   W E E K L Y   R E P O R T     |      Performance     |");
    setTableTextLine(tbLn++, "+---------------------------------+----------------------+");
    setTableTextLine(tbLn++, "|Wk| T2 | T3 | T4 | T5 | T6 | P/L |TP|BE|SL|All| WR | PR |");
    setTableTextLine(tbLn++, "+--+----+----+----+----+----+-----+--+--+--+---+----+----+");
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
        if (gListTrades[i].PlDola > RiskPerTrade){
            tp++;
            tpPipSum += gListTrades[i].PlPip;
            tpRRSum  += gListTrades[i].PlRR;
        }
        else if (gListTrades[i].PlDola < 0) sl++;
        else be++;
        gWkData[gListTrades[i].DayOfWk] += gListTrades[i].PlRR;
        costPipSum += gListTrades[i].CostPip;
        plAll   += gListTrades[i].PlRR;
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
        string sumupLine       = "|      T Ổ N G   K Ế T      |";
        sumupLine += NumToStr(plAll, 5, 1) + "|";
        sumupLine += NumToStr(tpAll,2) + "|";
        sumupLine += NumToStr(beAll,2) + "|";
        sumupLine += NumToStr(slAll,2) + "|";
        sumupLine += NumToStr(gTradeCount,3) + "|";
        sumupLine += NumToStr((tpAll+beAll)*100/gTradeCount, 3) + "%|";
        sumupLine += NumToStr(tpAll*100/gTradeCount, 3) + "%|";
        setTableTextLine(tbLn++, "+---------------------------+-----+--+--+--+---+----+----+");
        setTableTextLine(tbLn++, sumupLine);
        setTableTextLine(tbLn++, "+---------------------------+-----+--+--+--+---+----+----+");
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
    if (id == CHARTEVENT_OBJECT_CLICK || gIsRun == false){
        loadData();
        displayData();
        gIsRun = true;
    }
}
//+------------------------------------------------------------------+
