#property copyright "mt4 tools - WIKI"
#property link      "https://aforexstory.notion.site/1104379b17ec80218296ccaa5eb0ff14"
#property version   "1.00"
#property description "This tool helps trader to review their trades"
#property strict
#property indicator_separate_window

#define APP_TAG "*Report"
#define MAXTRADE 1000
#define TXT_SPACE_BLOCK "                    "

#define WEEKLY_COL1 10
#define WEEKLY_COL2 30
#define WEEKLY_COLW 70

#define DAILY_COLW 70
#define DAILY_COL1 10
#define DAILY_COL2 60+DAILY_COLW*0
#define DAILY_COL3 60+DAILY_COLW*1
#define DAILY_COL4 60+DAILY_COLW*2
#define DAILY_COL5 60+DAILY_COLW*3
#define DAILY_COL6 60+DAILY_COLW*4
#define DAILY_COL7 60+DAILY_COLW*5


#define BTN_START       "[StartReview]"
#define BTN_PnLON       "[PnL  on]"
#define BTN_PnLOFF      "[PnL off]"
#define BTN_TRDOPEN     "[➕]"
#define BTN_TRDCLOSE    "[✔]"
#define BTN_TRDHIDE     "[✖]"
#define BTN_RELOAD      "[Reload]"

enum eReportType {
    eServerDirect,  // Server direct
    eSoft4fx,       // Soft4fx
    eOfflineReport, // Offline Report
};


input eReportType   InpReportType = eServerDirect; // Report from:
input double        InpRiskPerTrade = 1.5; //Risk per Trade ($)

bool initStatus = false;

int gWinId;
bool gPnlOn = false;
string gStrDbSetting = "";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    IndicatorShortName("");
    gWinId = ChartWindowFind();
    if (ObjectFind(objDbSetting) < 0) initDashboard();
    else {
        gStrDbSetting = ObjectDescription(objDbSetting);
    }
    if (StringFind(gStrDbSetting, "gPnlOn") != -1) gPnlOn = true;;
    return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
    if (reason <= REASON_RECOMPILE || reason == REASON_PARAMETERS){
        initStatus = true;
        // TODO: save list deleted object -> delete in all charts
        for (int i = ObjectsTotal() - 1; i >= 0; i--) {
            string objName = ObjectName(i);
            if (StringFind(objName, APP_TAG) != -1) ObjectDelete(objName);
        }
    }
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
    return(rates_total);
}

//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if (id == CHARTEVENT_OBJECT_CLICK && StringFind(sparam, APP_TAG) != -1){
        handleClick(sparam);
    }
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

/// @brief HMI handler
void handleClick(const string &sparam)
{
    string description = ObjectDescription(sparam);
    string tradeIdx;
    int btnId;
    // Print("handleClick on[", description, "]");
    if (description == BTN_TRDOPEN){
        tradeIdx = APP_TAG + "Label" + IntegerToString(getLabelIndex(sparam)+2);
        viewTradeOpen(StrToInteger(ObjectDescription(tradeIdx)));
        ObjectSetText(sparam, BTN_TRDHIDE);
    }
    if (description == BTN_TRDHIDE){
        btnId = getLabelIndex(sparam);
        tradeIdx = APP_TAG + "Label" + IntegerToString(btnId+2);
        hideTrade(StrToInteger(ObjectDescription(tradeIdx)));
        ObjectSetText(sparam, BTN_TRDOPEN);
        if (gPnlOn == false) {
            string txtPnL = APP_TAG + "Label" + IntegerToString(btnId-1);
            ObjectSetText(txtPnL, "    ***");
        }
        string resultBtn = APP_TAG + "Label" + IntegerToString(btnId+1);
        ObjectSetText(resultBtn, BTN_TRDCLOSE);
    }
    else if (description == BTN_TRDCLOSE) {
        btnId = getLabelIndex(sparam);
        tradeIdx = APP_TAG + "Label" + IntegerToString(btnId+1);
        viewTradeClose(StrToInteger(ObjectDescription(tradeIdx)));
        ObjectSetText(sparam, orderResult);
        if (gPnlOn == false) {
            string txtPnL = APP_TAG + "Label" + IntegerToString(btnId-2);
            ObjectSetText(txtPnL, fixedText(DoubleToString(orderProfit,2), 7));
        }
        string viewBtn = APP_TAG + "Label" + IntegerToString(btnId-1);
        ObjectSetText(viewBtn, BTN_TRDHIDE);
    }
    else if (description == BTN_RELOAD || description == BTN_START) {
        getData();
        if (StringFind(gStrDbSetting, "tab1") != -1) {
            drawDailyDashboard();
        }
        else if (StringFind(gStrDbSetting, "tab2") != -1) {
            drawWeeklyDashboard();
        }
    }
    else if (description == BTN_PnLON) {
        gPnlOn = false;
        StringReplace(gStrDbSetting, "gPnlOn", "");
        ObjectSetText(objDbSetting, gStrDbSetting);
        drawDailyDashboard();
    }
    else if (description == BTN_PnLOFF) {
        gPnlOn = true;
        gStrDbSetting += "gPnlOn";
        ObjectSetText(objDbSetting, gStrDbSetting);
        drawDailyDashboard();
    }
    else if (description == "[>]") {
        string curPage = ObjectDescription(objCurPage);
        string nexPage = ObjectDescription(objNexPage);
        if (curPage != nexPage) {
            ObjectSetText(objCurPage, nexPage);
            drawDailyDashboard();
        }
    }
    else if (description == "[<]") {
        string curPage = ObjectDescription(objCurPage);
        string prePage = ObjectDescription(objPrePage);
        if (curPage != prePage) {
            ObjectSetText(objCurPage, prePage);
            drawDailyDashboard();
        }
    }
    else if (description == "[Daily]") {
        StringReplace(gStrDbSetting, "tab2", "");
        gStrDbSetting += "tab1";
        ObjectSetText(objDbSetting, gStrDbSetting);
        drawDailyDashboard();
    }
    else if (description == "[Weekly]") {
        StringReplace(gStrDbSetting, "tab1", "");
        gStrDbSetting += "tab2";
        ObjectSetText(objDbSetting, gStrDbSetting);
        drawWeeklyDashboard();
    }
}
//+------------------------------------------------------------------+

/// @brief Action area
void viewTradeOpen(int tradeIdx)
{
    getDataFrom(tradeIdx);
    string objName = APP_TAG + "TradeEN" + IntegerToString(tradeIdx);

    long chartID = ChartID();
    long curChart = ChartFirst();
    string chartSymbol = ChartSymbol();
    while(curChart > 0) {
        if (ChartSymbol(curChart) == chartSymbol) {
            ObjectCreate(curChart, objName, OBJ_ARROW, 0, 0, 0);
            ObjectSetInteger(curChart, objName, OBJPROP_BACK, false);
            ObjectSetInteger(curChart, objName, OBJPROP_ARROWCODE, 2);
        
            ObjectSetString(curChart, objName, OBJPROP_TOOLTIP,"Size:" + DoubleToString(orderLots,2));
            ObjectSetInteger(curChart, objName, OBJPROP_COLOR , orderType == OP_BUY ? clrBlue : clrRed);
            ObjectSetInteger(curChart, objName, OBJPROP_TIME1 , orderOpenTime);
            ObjectSetDouble(curChart, objName, OBJPROP_PRICE1, priceEN);
        }
        curChart = ChartNext(curChart);
    }

}
void viewTradeClose(int tradeIdx)
{
    getDataFrom(tradeIdx);
    string objName = APP_TAG + "TradeEN" + IntegerToString(tradeIdx);

    long chartID = ChartID();
    long curChart = ChartFirst();
    string chartSymbol = ChartSymbol();
    while(curChart > 0) {
        if (ChartSymbol(curChart) == chartSymbol) {
            objName = APP_TAG + "TradeEN" + IntegerToString(tradeIdx);
            ObjectCreate(curChart, objName, OBJ_ARROW, 0, 0, 0);
            ObjectSetInteger(curChart, objName, OBJPROP_BACK, false);
            ObjectSetInteger(curChart, objName, OBJPROP_ARROWCODE, 2);
        
            ObjectSetString(curChart, objName, OBJPROP_TOOLTIP,"Size:" + DoubleToString(orderLots,2));
            ObjectSetInteger(curChart, objName, OBJPROP_COLOR , orderType == OP_BUY ? clrBlue : clrRed);
            ObjectSetInteger(curChart, objName, OBJPROP_TIME1 , orderOpenTime);
            ObjectSetDouble(curChart, objName, OBJPROP_PRICE1, priceEN);
        
            objName = APP_TAG + "TradeTP" + IntegerToString(tradeIdx);
            ObjectCreate(curChart, objName, OBJ_ARROW, 0, 0, 0);
            ObjectSetInteger(curChart, objName, OBJPROP_BACK, false);
            ObjectSetString(curChart, objName, OBJPROP_TOOLTIP, "\n");
            ObjectSetInteger(curChart, objName, OBJPROP_ARROWCODE, priceCL == priceTP ? 3 : 4);
            ObjectSetInteger(curChart, objName, OBJPROP_COLOR , clrBlue);
            ObjectSetInteger(curChart, objName, OBJPROP_TIME1 , orderCloseTime);
            ObjectSetDouble(curChart, objName, OBJPROP_PRICE1, priceTP);
        
            objName = APP_TAG + "TradeSL" + IntegerToString(tradeIdx);
            ObjectCreate(curChart, objName, OBJ_ARROW, 0, 0, 0);
            ObjectSetInteger(curChart, objName, OBJPROP_BACK, false);
            ObjectSetString(curChart, objName, OBJPROP_TOOLTIP, "\n");
            ObjectSetInteger(curChart, objName, OBJPROP_ARROWCODE, priceCL == priceSL ? 3 : 4);
            ObjectSetInteger(curChart, objName, OBJPROP_COLOR , clrRed);
            ObjectSetInteger(curChart, objName, OBJPROP_TIME1 , orderCloseTime);
            ObjectSetDouble(curChart, objName, OBJPROP_PRICE1, priceSL);
        
            objName = APP_TAG + "TradeLn" + IntegerToString(tradeIdx);
            ObjectCreate(curChart, objName, OBJ_TREND, 0, 0, 0);
            ObjectSetString(curChart, objName, OBJPROP_TOOLTIP, "\n");
            ObjectSetInteger(curChart, objName, OBJPROP_BACK, false);
            ObjectSetInteger(curChart, objName, OBJPROP_RAY, false);
            ObjectSetInteger(curChart, objName, OBJPROP_STYLE, 2);
            ObjectSetInteger(curChart, objName, OBJPROP_COLOR , orderType == OP_BUY ? clrBlue : clrRed);
            ObjectSetInteger(curChart, objName, OBJPROP_TIME1 , orderOpenTime);
            ObjectSetInteger(curChart, objName, OBJPROP_TIME2 , orderCloseTime);
            ObjectSetDouble(curChart, objName, OBJPROP_PRICE1, priceEN);
            ObjectSetDouble(curChart, objName, OBJPROP_PRICE2, priceCL);
        }
        curChart = ChartNext(curChart);
    }

}
void hideTrade(int tradeIdx)
{
    string objName = APP_TAG + "TradeEN" + IntegerToString(tradeIdx);
    long chartID = ChartID();
    long curChart = ChartFirst();
    string chartSymbol = ChartSymbol();
    while(curChart > 0) {
        if (ChartSymbol(curChart) == chartSymbol) {
            objName = APP_TAG + "TradeEN" + IntegerToString(tradeIdx);
            ObjectSetInteger(curChart, objName, OBJPROP_TIME1 , 0);
            ObjectSetDouble(curChart, objName, OBJPROP_PRICE1 , 0);
            objName = APP_TAG + "TradeTP" + IntegerToString(tradeIdx);
            ObjectSetInteger(curChart, objName, OBJPROP_TIME1 , 0);
            ObjectSetDouble(curChart, objName, OBJPROP_PRICE1 , 0);
            objName = APP_TAG + "TradeSL" + IntegerToString(tradeIdx);
            ObjectSetInteger(curChart, objName, OBJPROP_TIME1 , 0);
            ObjectSetDouble(curChart, objName, OBJPROP_PRICE1 , 0);
            objName = APP_TAG + "TradeLn" + IntegerToString(tradeIdx);
            ObjectSetInteger(curChart, objName, OBJPROP_TIME1 , 0);
            ObjectSetInteger(curChart, objName, OBJPROP_TIME2 , 0);
        }
        curChart = ChartNext(curChart);
    }
}
void getData()
{
    // Remove old data
    int i = 0;
    while (removeData(i) == true) i++;
    int tradeIdx     = 0;
    string data      = "";
    string firstDay  = "";
    string secondDay = "";
    //--- retrieving information from Backtesting
    if (InpReportType == eSoft4fx) {
        string objEn    = "";
        string objEx    = "";
        string strData  = "";
    
        string enDatas[];
        string exDatas[];
        bool isSL;
        string strPriceCL;
    
        for (int idx = 0; idx < MAXTRADE; idx++) {
            //--- Step 1: Find obj
            objEn = "sim#3d_en#" + IntegerToString(idx);
            if (ObjectFind(objEn) < 0) continue;
            objEx = "sim#3d_ex#" + IntegerToString(idx);
    
            //--- Step 2: extract data
            strData = ObjectGetString(0, objEn, OBJPROP_TOOLTIP);
            StringSplit(strData,'\n',enDatas);
            strData = ObjectGetString(0, objEx, OBJPROP_TOOLTIP);
            StringSplit(strData,'\n',exDatas);
    
            //--- Step 3: Write data
            isSL = (StringFind(StringSubstr(exDatas[3], 5, 6), "-") >= 0);
            strPriceCL = DoubleToString(ObjectGet(objEx, OBJPROP_PRICE1), 5);
            data = "";
            data += TimeToString((datetime)ObjectGet(objEn, OBJPROP_TIME1), TIME_DATE|TIME_MINUTES) + ";"; //orderOpenTime 
            data += TimeToString((datetime)ObjectGet(objEx, OBJPROP_TIME1), TIME_DATE|TIME_MINUTES) + ";"; //orderCloseTime
            data += ((color)ObjectGet(objEn, OBJPROP_COLOR) == clrBlue ? "0" : "1")                 + ";"; //orderType     
            data += StringSubstr(enDatas[1], 6, 4)                                                  + ";"; //orderLots     
            data += DoubleToString(ObjectGet(objEn, OBJPROP_PRICE1), 5)                             + ";"; //priceEN       
            data += strPriceCL                                                                      + ";"; //priceCL       
            data += (isSL ? strPriceCL : "0")                                                       + ";"; //priceSL       
            data += (isSL ? "0" : strPriceCL)                                                       + ";"; //priceTP       
            data += StringSubstr(exDatas[3], 5, 6)                                                  + ";"; //orderProfit   
    
            setDataTo(tradeIdx++, data);
            if (firstDay == "") {
                firstDay = StringSubstr(TimeToStr((datetime)ObjectGet(objEx, OBJPROP_TIME1), TIME_DATE), 5);
            } else if (secondDay == "") {
                secondDay = StringSubstr(TimeToStr((datetime)ObjectGet(objEx, OBJPROP_TIME1), TIME_DATE), 5);
            }
        }
    }
    //--- retrieving info from trade history
    else if (InpReportType == eServerDirect) {
        int type,hstTotal=OrdersHistoryTotal();
        for(i=0;i<hstTotal;i++) {
            //---- check selection result
            if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) {
                Print("Access to history failed with error (",GetLastError(),")");
                break;
            }
            // some work with order
            type = OrderType();
            if (type == OP_BUY || type == OP_SELL) {
                data = "";
                data += TimeToString(OrderOpenTime()    , TIME_DATE|TIME_MINUTES)   + ";";
                data += TimeToString(OrderCloseTime()   , TIME_DATE|TIME_MINUTES)   + ";";
                data += IntegerToString(OrderType())                                + ";";
                data += DoubleToString(OrderLots()      , 2)                        + ";";
                data += DoubleToString(OrderOpenPrice() , 5)                        + ";";
                data += DoubleToString(OrderClosePrice(), 5)                        + ";";
                data += DoubleToString(OrderStopLoss()  , 5)                        + ";";
                data += DoubleToString(OrderTakeProfit(), 5)                        + ";";
                data += DoubleToString(OrderProfit()+OrderCommission(), 2)          + ";";
                setDataTo(tradeIdx++, data);
                if (firstDay == "") {
                    firstDay = StringSubstr(TimeToStr(OrderOpenTime(), TIME_DATE), 5);
                } else if (secondDay == "") {
                    secondDay = StringSubstr(TimeToStr(OrderOpenTime(), TIME_DATE), 5);
                }
            }
        }
    }
    //--------------
    ObjectSetText(objCurPage, firstDay);
    ObjectSetText(objPrePage, firstDay);
    ObjectSetText(objNexPage, secondDay);
}
//+------------------------------------------------------------------+

/// @brief HMI creatation
string objDbSetting = APP_TAG   + "initDB";
string objCurPage   = APP_TAG   + "CurPage";
string objPrePage   = APP_TAG   + "PrePage";
string objNexPage   = APP_TAG   + "NexPage";
int gRowPos = 0;
void initDashboard()
{
    gStrDbSetting = "tab2";
    //
    ObjectCreate(objDbSetting, OBJ_TEXT, gWinId, 0, 0);

    ObjectCreate(objCurPage, OBJ_TEXT, gWinId, 0, 0);
    ObjectCreate(objPrePage, OBJ_TEXT, gWinId, 0, 0);
    ObjectCreate(objNexPage, OBJ_TEXT, gWinId, 0, 0);
    ObjectSetText(objCurPage, "0");
    ObjectSetText(objPrePage, "0");
    ObjectSetText(objNexPage, "0");
    ObjectSetText(objDbSetting, gStrDbSetting);

    // init function
    gLabelIndex = 0;
    createLabel(BTN_START, DAILY_COL1, 5);
    hideItem(gLabelIndex, "Label");
}

void drawWeeklyDashboard()
{
    gLabelIndex = 0;
    gRowPos = 5;
    // tab
    createLabel("[Daily]", WEEKLY_COL1, gRowPos);
    createLabel(" Weekly", 70, gRowPos);
    createLabel(" ______", 70, gRowPos);
    createLabel(BTN_RELOAD, WEEKLY_COL2 + WEEKLY_COLW*5, gRowPos);
    gRowPos = 25;
    // header
    createLabel("No."      , WEEKLY_COL1                , gRowPos);
    createLabel("       T2", WEEKLY_COL2 + WEEKLY_COLW*0, gRowPos);
    createLabel("       T3", WEEKLY_COL2 + WEEKLY_COLW*1, gRowPos);
    createLabel("       T4", WEEKLY_COL2 + WEEKLY_COLW*2, gRowPos);
    createLabel("       T5", WEEKLY_COL2 + WEEKLY_COLW*3, gRowPos);
    createLabel("       T6", WEEKLY_COL2 + WEEKLY_COLW*4, gRowPos);
    createLabel("      P/L", WEEKLY_COL2 + WEEKLY_COLW*5, gRowPos);
    nextRow(); weeklySeparateRow();

    // table
    int i = 0, wknum, preWkNum=-1;
    double wPnl = 0;
    double dPnl = 0;
    double sPnl = 0;
    string currentDate, strPreDate = "";
    datetime dtPreDate = orderOpenTime;
    while (getDataFrom(i) == true) {
        currentDate = StringSubstr(TimeToStr(orderOpenTime, TIME_DATE), 5);
        wknum = WeeknumOfYear(orderOpenTime);
        // Print and reset data:
        if (strPreDate != currentDate && strPreDate != "") {
            createLabel(fixedText(DoubleToString(dPnl,2), 9), WEEKLY_COL2 + WEEKLY_COLW*(TimeDayOfWeek(dtPreDate)-1), gRowPos);
            wPnl += dPnl;
            dPnl = 0;
            if (wknum != preWkNum) {
                createLabel(IntegerToString(preWkNum), WEEKLY_COL1, gRowPos);
                createLabel(fixedText(DoubleToString(wPnl,2), 9), WEEKLY_COL2 + WEEKLY_COLW*5, gRowPos);
                nextRow(); weeklySeparateRow();
                sPnl += wPnl;
                wPnl = 0;
            }
        }
        dPnl += orderProfit;
        preWkNum = wknum;
        strPreDate = currentDate;
        dtPreDate = orderOpenTime;
        i++;
    }
    if (strPreDate != ""){
        wPnl += dPnl;
        sPnl += wPnl;
        createLabel(fixedText(DoubleToString(dPnl,2), 9), WEEKLY_COL2 + WEEKLY_COLW*(TimeDayOfWeek(dtPreDate)-1), gRowPos);
        createLabel(IntegerToString(preWkNum), WEEKLY_COL1, gRowPos);
        createLabel(fixedText(DoubleToString(wPnl,2), 9), WEEKLY_COL2 + WEEKLY_COLW*5, gRowPos);
        nextRow(); weeklySeparateRow();
        createLabel(fixedText(DoubleToString(sPnl,2), 9), WEEKLY_COL2 + WEEKLY_COLW*5, gRowPos);
    }
    
    hideItem(gLabelIndex, "Label");
}

void drawDailyDashboard()
{
    gLabelIndex = 0;
    gRowPos = 5;
    // tab
    createLabel(" Daily", DAILY_COL1, gRowPos, true);
    createLabel(" _____", DAILY_COL1, gRowPos, true);
    createLabel("[Weekly]", 70, gRowPos, true);
    createLabel(BTN_RELOAD, DAILY_COL6, gRowPos);
    gRowPos = 25;

    string curPage = ObjectDescription(objCurPage);
    // header
    createLabel("No."      , DAILY_COL1, gRowPos, true);
    createLabel(curPage    , DAILY_COL2, gRowPos); // createLabel("Time"     , DAILY_COL2, gRowPos, true);
    createLabel("Type"     , DAILY_COL3, gRowPos, true);
    createLabel("Size"     , DAILY_COL4, gRowPos, true);
    createLabel(gPnlOn ? BTN_PnLON : BTN_PnLOFF, DAILY_COL5, gRowPos, true);
    nextRow(); dailySeparateRow();
    // table
    string currentDate, objName;
    string prePage = curPage;
    string nexPage = curPage;
    int i = 0, num = 0;
    double sPnl = 0;
    while (getDataFrom(i) == true) {
        currentDate = StringSubstr(TimeToStr(orderOpenTime, TIME_DATE), 5);
        if (currentDate != curPage) {
            if (num == 0) prePage = currentDate;
            else {
                nexPage = currentDate;
                break;
            }
            i++;
            continue;
        }
        num++;

        createLabel(IntegerToString(num)                    , DAILY_COL1, gRowPos);
        createLabel(TimeToStr(orderOpenTime, TIME_MINUTES) , DAILY_COL2, gRowPos);
        createLabel(orderType == OP_BUY ? " buy" : "sell"   , DAILY_COL3, gRowPos);
        createLabel(DoubleToString(orderLots,2)             , DAILY_COL4, gRowPos);
        if (gPnlOn) {
            createLabel(fixedText(DoubleToString(orderProfit,2), 7), DAILY_COL5, gRowPos);
            sPnl += orderProfit;
        }
        else createLabel("    ***", DAILY_COL5, gRowPos);
        
        objName = APP_TAG + "TradeEN" + IntegerToString(i);
        if (ObjectGet(objName, OBJPROP_PRICE1) == 0) {
            createLabel(BTN_TRDOPEN , DAILY_COL6   , gRowPos);
            createLabel(BTN_TRDCLOSE, DAILY_COL6+25, gRowPos);
        }
        else {
            createLabel(BTN_TRDHIDE , DAILY_COL6   , gRowPos);
            objName = APP_TAG + "TradeSL" + IntegerToString(i);
            if (ObjectGet(objName, OBJPROP_PRICE1) == 0) createLabel(BTN_TRDCLOSE  , DAILY_COL6+25, gRowPos);
            else createLabel(orderResult, DAILY_COL6+25, gRowPos);
        }
        createLabel(IntegerToString(i)  , 0, -20);
        nextRow();
        i++;
    }
    dailySeparateRow();
    if (gPnlOn) createLabel(fixedText(DoubleToString(sPnl,2), 7), DAILY_COL5, gRowPos);
    else createLabel("    ***", DAILY_COL5, gRowPos);
    // function
    gRowPos = 25;
    if (prePage != curPage) createLabel("[<]", DAILY_COL6, gRowPos);
    if (curPage != nexPage) createLabel("[>]", DAILY_COL6+35, gRowPos);
    
    ObjectSetText(objCurPage, curPage);
    ObjectSetText(objPrePage, prePage);
    ObjectSetText(objNexPage, nexPage);

    hideItem(gLabelIndex, "Label");
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//+---------------------Utilidies------------------------------------+
//+------------------------------------------------------------------+

/// @brief Data handle Utilidies
datetime orderOpenTime  ;
datetime orderCloseTime ;
int      orderType      ;
double   orderLots      ;
double   priceEN        ;
double   priceCL        ;
double   priceSL        ;
double   priceTP        ;
double   orderProfit    ;
string   orderResult    ;
void setDataTo(int idx, string rawData)
{
    string str1 = StringSubstr(rawData, 0, 63);
    string str2 = StringSubstr(rawData, 63);

    string objTradeData = APP_TAG + "TradeData1" + IntegerToString(idx);
    ObjectCreate(objTradeData, OBJ_TEXT, gWinId, 0, 0);
    ObjectSet(objTradeData, OBJPROP_XDISTANCE, 0);
    ObjectSet(objTradeData, OBJPROP_YDISTANCE, 250);
    ObjectSetText(objTradeData, str1);
    objTradeData = APP_TAG + "TradeData2" + IntegerToString(idx);
    ObjectCreate(objTradeData, OBJ_TEXT, gWinId, 0, 0);
    ObjectSetText(objTradeData, str2);
    ObjectSet(objTradeData, OBJPROP_XDISTANCE, 0);
    ObjectSet(objTradeData, OBJPROP_YDISTANCE, 250);
}
bool getDataFrom(int idx)
{
    string objTradeData = APP_TAG + "TradeData1" + IntegerToString(idx);
    string rawData = ObjectDescription(objTradeData);
    objTradeData = APP_TAG + "TradeData2" + IntegerToString(idx);
    rawData += ObjectDescription(objTradeData);
    if (rawData == "" || rawData == NULL) return false;
    // Print("rawData:[", rawData, "]");
    string data[];
    StringSplit(rawData,';',data);
    orderOpenTime  = StringToTime    (data[0]);
    orderCloseTime = StringToTime    (data[1]);
    orderType      = (int)StringToInteger (data[2]);
    orderLots      = StringToDouble  (data[3]);
    priceEN        = StringToDouble  (data[4]);
    priceCL        = StringToDouble  (data[5]);
    priceSL        = StringToDouble  (data[6]);
    priceTP        = StringToDouble  (data[7]);
    orderProfit    = StringToDouble  (data[8]);
    orderResult    = orderProfit > InpRiskPerTrade/3 ? "[tp]" : (orderProfit < -InpRiskPerTrade/3 ? "[sl]" : "[be]");
    return true;
}
bool removeData(int idx)
{
    string objTradeData = APP_TAG + "TradeData1" + IntegerToString(idx);
    ObjectDelete(objTradeData);
    objTradeData = APP_TAG + "TradeData2" + IntegerToString(idx);
    return ObjectDelete(objTradeData);
}
int WeeknumOfYear(datetime date)
{
    return (TimeDayOfYear(date)+TimeDayOfWeek(StrToTime(IntegerToString(TimeYear(date))+".01.01"))-2)/7;
}
//+------------------------------------------------------------------+

/// @brief Drawing Utilidies
int gLabelIndex = 0;
void createLabel(string text, int posX, int posY){
    createLabel(text, posX, posY, false, "\n");
}
void createLabel(string text, int posX, int posY, bool editable){
    createLabel(text, posX, posY, editable, "\n");
}
void createLabel(string text, int posX, int posY, string tooltip){
    createLabel(text, posX, posY, false, tooltip);
}
void createLabel(string text, int posX, int posY, bool editable, string tooltip)
{
    string objName = APP_TAG + "Label" + IntegerToString(gLabelIndex++);
    ObjectCreate(objName, OBJ_LABEL, gWinId, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSet(objName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    ObjectSet(objName, OBJPROP_BACK, false);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, tooltip);
    // Basic
    ObjectSet(objName, OBJPROP_SELECTABLE, editable);
    ObjectSet(objName, OBJPROP_XDISTANCE, posX);
    ObjectSet(objName, OBJPROP_YDISTANCE, posY);
    ObjectSetText(objName, text, 10, "Consolas", clrBlack);
}
void hideItem(int index, string tag){
    string objName = APP_TAG + tag + IntegerToString(index);
    while(ObjectFind(objName) >= 0){
        ObjectSet(objName, OBJPROP_XDISTANCE, 0);
        ObjectSet(objName, OBJPROP_YDISTANCE, -20);
        // ObjectSet(objName, OBJPROP_TIME1, 0);
        // ObjectSet(objName, OBJPROP_TIME2, 0);
        objName = APP_TAG + tag + IntegerToString(index++);
    }
}
//+------------------------------------------------------------------+


/// @brief Other Utilidies
int getLabelIndex(string objIdLabel)
{
    StringReplace(objIdLabel, APP_TAG + "Label", "");
    return StrToInteger(objIdLabel);
}
void nextRow() {
    gRowPos += 15;
}
void dailySeparateRow() {
    createLabel("-------------------------------------------------------", DAILY_COL1, gRowPos, true);
    gRowPos += 15;
}
void weeklySeparateRow() {
    createLabel("--------------------------------------------------------------", DAILY_COL1, gRowPos, true);
    gRowPos += 15;
}
string fixedText(string str, int size) {
    int spaceSize = size - StringLen(str);
    if (spaceSize <= 0) return str;
    return StringSubstr(TXT_SPACE_BLOCK, 0, spaceSize) + str;
}
//+------------------------------------------------------------------+