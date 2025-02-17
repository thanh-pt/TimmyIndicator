#property copyright "mt4 tools - WIKI"
#property link      "https://aforexstory.notion.site/1104379b17ec80218296ccaa5eb0ff14"
#property version   "1.00"
// #property icon      "../3.Resource/WorldClock.ico"
#property description "This tool helps trader to review their trades"
#property strict
#property indicator_separate_window

#define APP_TAG "*ReviewTrade"
#define TXT_SPACE_BLOCK "                    "

#define COL1 10 
#define COL2 40 
#define COL3 130 
#define COL4 170
#define COL5 210
#define COL6 280

#define BTN_START   "[StartReview]"
#define BTN_PnLON   " [PnL on]"
#define BTN_PnLOFF  "[PnL off]"
#define BTN_TRDOPEN "[➕]"
#define BTN_TRDCLOSE "[✔]"
#define BTN_TRDHIDE "[✖]"
#define BTN_RELOAD  "[Reload]"
#define BTN_HIDEPN  "[H]"
#define BTN_SHOWPN  "[S]"

input double    InpRiskPerTrade = 1.5; //Risk per Trade ($)
input int       InpPageSize     = 20;

bool initStatus = false;


int gWinId;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    IndicatorShortName("");
    gWinId = ChartWindowFind();
    if (ObjectFind(objInitDboard) < 0) initDashboard();
    return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
    if (reason <= REASON_RECOMPILE || reason == REASON_PARAMETERS){
        initStatus = true;
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
    int curPage;
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
            string txtPnL = APP_TAG + "Label" + IntegerToString(btnId-2);
            ObjectSetText(txtPnL, "    ***", 7);
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
        drawDashboard();
    }
    else if (description == BTN_PnLON) {
        gPnlOn = false;
        drawDashboard();
    }
    else if (description == BTN_PnLOFF) {
        gPnlOn = true;
        drawDashboard();
    }
    else if (description == "[>]") {
        curPage = (int)StringToInteger(ObjectDescription(objLasPage));
        int allPage = (int)StringToInteger(ObjectDescription(objAllPage));
        if (curPage < allPage) {
            ObjectSetText(objCurPage, IntegerToString(curPage));
            drawDashboard();
        }
    }
    else if (description == "[<]") {
        // curPage = (int)StringToInteger(ObjectDescription(objCurPage));
        // if (curPage > 0) {
        //     curPage--;
        //     ObjectSetText(objCurPage, IntegerToString(curPage));
        //     drawDashboard();
        // }
    }
    else if (description == BTN_HIDEPN) {
        hideDashboard();
    }
    else if (description == BTN_SHOWPN) {
        drawDashboard();
    }
}
//+------------------------------------------------------------------+

/// @brief Action area
void viewTradeOpen(int tradeIdx)
{
    getDataFrom(tradeIdx);
    string objName = APP_TAG + "TradeEN" + IntegerToString(tradeIdx);
    ObjectCreate(objName, OBJ_ARROW, 0, 0, 0);
    ObjectSet(objName, OBJPROP_BACK, false);
    ObjectSet(objName, OBJPROP_ARROWCODE, 2);

    ObjectSetString(0, objName, OBJPROP_TOOLTIP,"Size:" + DoubleToString(orderLots,2));
    ObjectSet(objName, OBJPROP_COLOR , orderType == OP_BUY ? clrBlue : clrRed);
    ObjectSet(objName, OBJPROP_TIME1 , orderOpenTime);
    ObjectSet(objName, OBJPROP_PRICE1, priceEN);
}
void viewTradeClose(int tradeIdx)
{
    getDataFrom(tradeIdx);
    string objName = APP_TAG + "TradeEN" + IntegerToString(tradeIdx);
    ObjectCreate(objName, OBJ_ARROW, 0, 0, 0);
    ObjectSet(objName, OBJPROP_BACK, false);
    ObjectSet(objName, OBJPROP_ARROWCODE, 2);

    ObjectSetString(0, objName, OBJPROP_TOOLTIP,"Size:" + DoubleToString(orderLots,2));
    ObjectSet(objName, OBJPROP_COLOR , orderType == OP_BUY ? clrBlue : clrRed);
    ObjectSet(objName, OBJPROP_TIME1 , orderOpenTime);
    ObjectSet(objName, OBJPROP_PRICE1, priceEN);

    objName = APP_TAG + "TradeTP" + IntegerToString(tradeIdx);
    ObjectCreate(objName, OBJ_ARROW, 0, 0, 0);
    ObjectSet(objName, OBJPROP_BACK, false);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objName, OBJPROP_ARROWCODE, priceCL == priceTP ? 3 : 4);
    ObjectSet(objName, OBJPROP_COLOR , clrBlue);
    ObjectSet(objName, OBJPROP_TIME1 , orderCloseTime);
    ObjectSet(objName, OBJPROP_PRICE1, priceTP);

    objName = APP_TAG + "TradeSL" + IntegerToString(tradeIdx);
    ObjectCreate(objName, OBJ_ARROW, 0, 0, 0);
    ObjectSet(objName, OBJPROP_BACK, false);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objName, OBJPROP_ARROWCODE, priceCL == priceSL ? 3 : 4);
    ObjectSet(objName, OBJPROP_COLOR , clrRed);
    ObjectSet(objName, OBJPROP_TIME1 , orderCloseTime);
    ObjectSet(objName, OBJPROP_PRICE1, priceSL);

    objName = APP_TAG + "TradeLn" + IntegerToString(tradeIdx);
    ObjectCreate(objName, OBJ_TREND, 0, 0, 0);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objName, OBJPROP_BACK, false);
    ObjectSet(objName, OBJPROP_RAY, false);
    ObjectSet(objName, OBJPROP_STYLE, 2);
    ObjectSet(objName, OBJPROP_COLOR , orderType == OP_BUY ? clrBlue : clrRed);
    ObjectSet(objName, OBJPROP_TIME1 , orderOpenTime);
    ObjectSet(objName, OBJPROP_TIME2 , orderCloseTime);
    ObjectSet(objName, OBJPROP_PRICE1, priceEN);
    ObjectSet(objName, OBJPROP_PRICE2, priceCL);
}
void hideTrade(int tradeIdx)
{
    string objName = APP_TAG + "TradeEN" + IntegerToString(tradeIdx);
    ObjectSet(objName, OBJPROP_TIME1 , 0);
    ObjectSet(objName, OBJPROP_PRICE1 , 0);
    objName = APP_TAG + "TradeTP" + IntegerToString(tradeIdx);
    ObjectSet(objName, OBJPROP_TIME1 , 0);
    ObjectSet(objName, OBJPROP_PRICE1 , 0);
    objName = APP_TAG + "TradeSL" + IntegerToString(tradeIdx);
    ObjectSet(objName, OBJPROP_TIME1 , 0);
    ObjectSet(objName, OBJPROP_PRICE1 , 0);
    objName = APP_TAG + "TradeLn" + IntegerToString(tradeIdx);
    ObjectSet(objName, OBJPROP_TIME1 , 0);
    ObjectSet(objName, OBJPROP_TIME2 , 0);
}
void getData()
{
    // Remove old data
    int i = 0;
    while (removeData(i) == true) i++;
    // retrieving info from trade history
    int type,hstTotal=OrdersHistoryTotal(),tradeIdx = 0;
    string data;
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
        }
    }
    ObjectSetText(objCurPage, "0");
    ObjectSetText(objAllPage, IntegerToString(tradeIdx-1));
}
//+------------------------------------------------------------------+

/// @brief HMI creatation
string objInitDboard    = APP_TAG   + "initDashboard";
string objCurPage       = APP_TAG   + "CurPage";
string objLasPage       = APP_TAG   + "LasPage";
string objAllPage       = APP_TAG   + "AllPage";
int gRowPos = 0;
void initDashboard()
{
    ObjectCreate(objInitDboard, OBJ_TEXT, gWinId, 0, 0);

    ObjectCreate(objCurPage, OBJ_LABEL, gWinId, 0, 0);
    ObjectCreate(objLasPage, OBJ_LABEL, gWinId, 0, 0);
    ObjectCreate(objAllPage, OBJ_LABEL, gWinId, 0, 0);
    ObjectSetText(objCurPage, "0", 10, "Consolas", clrBlack);
    ObjectSetText(objLasPage, "0", 10, "Consolas", clrBlack);
    ObjectSetText(objAllPage, "0", 10, "Consolas", clrBlack);
    ObjectSet(objCurPage, OBJPROP_YDISTANCE, -20);
    ObjectSet(objLasPage, OBJPROP_YDISTANCE, -20);
    ObjectSet(objAllPage, OBJPROP_YDISTANCE, -20);
    ObjectSet(objCurPage, OBJPROP_XDISTANCE, 0);
    ObjectSet(objLasPage, OBJPROP_XDISTANCE, 0);
    ObjectSet(objAllPage, OBJPROP_XDISTANCE, 0);

    // init function
    gLabelIndex = 0;
    createLabel(BTN_START, COL1, 5);
    hideItem(gLabelIndex, "Label");
}

bool gPnlOn = false;
void drawDashboard()
{
    gLabelIndex = 0;
    gRowPos = 5;
    // header
    createLabel("No."      , COL1, gRowPos, true);
    createLabel("Time"     , COL2, gRowPos, true);
    createLabel("Type"     , COL3, gRowPos, true);
    createLabel("Size"     , COL4, gRowPos, true);
    createLabel(gPnlOn ? BTN_PnLON : BTN_PnLOFF, COL5, gRowPos, true);
    createLabel(BTN_RELOAD , COL6, gRowPos);
    nextRow(); separateRow();
    // table
    string currentDate, objName, strOpenOrder;
    int curPage = (int)StringToInteger(ObjectDescription(objCurPage));
    int allPage = (int)StringToInteger(ObjectDescription(objAllPage));
    int i = curPage;
    double sPnl = 0;
    while (getDataFrom(i) == true) {
        if (StringSubstr(TimeToStr(orderOpenTime, TIME_DATE), 5) != currentDate) {
            if (curPage != i) {
                ObjectSetText(objLasPage, IntegerToString(i));
                break;
            }
            currentDate = StringSubstr(TimeToStr(orderOpenTime, TIME_DATE), 5);
            strOpenOrder = currentDate;
        }
        else {
            strOpenOrder = "     ";
        }
        createLabel(IntegerToString(i), COL1, gRowPos);
        strOpenOrder += " " + TimeToStr(orderOpenTime, TIME_MINUTES);
        createLabel(strOpenOrder, COL2, gRowPos);
        createLabel(orderType == OP_BUY ? " buy" : "sell", COL3, gRowPos);
        createLabel(DoubleToString(orderLots,2)          , COL4, gRowPos);
        sPnl += orderProfit;
        if (gPnlOn) createLabel(fixedText(DoubleToString(orderProfit,2), 7), COL5, gRowPos);
        else createLabel("    ***", COL5, gRowPos);

        objName = APP_TAG + "TradeEN" + IntegerToString(i);
        if (ObjectGet(objName, OBJPROP_PRICE1) == 0) {
            createLabel(BTN_TRDOPEN , COL6   , gRowPos);
            createLabel(BTN_TRDCLOSE, COL6+25, gRowPos);
        }
        else {
            createLabel(BTN_TRDHIDE , COL6   , gRowPos);
            objName = APP_TAG + "TradeSL" + IntegerToString(i);
            if (ObjectGet(objName, OBJPROP_PRICE1) == 0) createLabel(BTN_TRDCLOSE  , COL6+25, gRowPos);
            else createLabel(orderResult, COL6+25, gRowPos);
        }
        createLabel(IntegerToString(i)  , 0, -10);
        nextRow();
        i++;
    }
    separateRow();
    if (gPnlOn) createLabel(fixedText(DoubleToString(sPnl,2), 7), COL5, gRowPos);
    else createLabel("    ***", COL5, gRowPos);
    // function
    if (i < allPage){
        createLabel("[<]"       , COL6      , gRowPos);
        createLabel("[>]"       , COL6+25   , gRowPos);
    }
    nextRow();separateRow();

    hideItem(gLabelIndex, "Label");
}
void hideDashboard()
{
    gLabelIndex = 0;
    createLabel(BTN_SHOWPN, 25, 20);
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
    ObjectSetText(objTradeData, str1);
    objTradeData = APP_TAG + "TradeData2" + IntegerToString(idx);
    ObjectCreate(objTradeData, OBJ_TEXT, gWinId, 0, 0);
    ObjectSetText(objTradeData, str2);
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
void separateRow() {
    createLabel("-----------------------------------------------", COL1, gRowPos, true);
    gRowPos += 15;
}
string fixedText(string str, int size) {
    int spaceSize = size - StringLen(str);
    if (spaceSize <= 0) return str;
    return StringSubstr(TXT_SPACE_BLOCK, 0, spaceSize) + str;
}
//+------------------------------------------------------------------+