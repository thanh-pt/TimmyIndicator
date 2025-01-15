#property copyright "mt4 tools - WIKI"
#property link      "https://aforexstory.notion.site/1104379b17ec80218296ccaa5eb0ff14"
#property version   "1.00"
// #property icon      "../3.Resource/WorldClock.ico"
#property description "This tool helps trader to review their trades"
#property strict
#property indicator_chart_window

#define APP_TAG "*ReviewTrade"
#define COL1 140
#define COL2 60

#define BTN_START   "[StartReview]"
#define BTN_TRDOPEN "[➕]"
#define BTN_TRDCLOSE "[✔]"
#define BTN_TRDHIDE "[✖]"
#define BTN_RELOAD  "[R]"
#define BTN_HIDEPN  "[H]"
#define BTN_SHOWPN  "[S]"

input double    InpRiskPerTrade = 1.5; //Risk per Trade ($)
input int       InpPageSize     = 20;

bool initStatus = false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
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
    int curPage;
    // Print("handleClick on[", description, "]");
    if (description == BTN_TRDOPEN){
        tradeIdx = APP_TAG + "Label" + IntegerToString(getLabelIndex(sparam)+2);
        viewTradeOpen(StrToInteger(ObjectDescription(tradeIdx)));
        ObjectSetText(sparam, BTN_TRDHIDE);
    }
    if (description == BTN_TRDHIDE){
        tradeIdx = APP_TAG + "Label" + IntegerToString(getLabelIndex(sparam)+2);
        hideTrade(StrToInteger(ObjectDescription(tradeIdx)));
        ObjectSetText(sparam, BTN_TRDOPEN);
        string resultBtn = APP_TAG + "Label" + IntegerToString(getLabelIndex(sparam)+1);
        ObjectSetText(resultBtn, BTN_TRDCLOSE);
    }
    else if (description == BTN_TRDCLOSE) {
        tradeIdx = APP_TAG + "Label" + IntegerToString(getLabelIndex(sparam)+1);
        viewTradeClose(StrToInteger(ObjectDescription(tradeIdx)));
        ObjectSetText(sparam, orderResult);
        string viewBtn = APP_TAG + "Label" + IntegerToString(getLabelIndex(sparam)-1);
        ObjectSetText(viewBtn, BTN_TRDHIDE);
    }
    else if (description == BTN_RELOAD || description == BTN_START) {
        getData();
        drawDashboard();
    }
    else if (description == "[>]") {
        curPage = (int)StringToInteger(ObjectDescription(objCurPage));
        int allPage = (int)StringToInteger(ObjectDescription(objAllPage));
        if (curPage < allPage) {
            curPage++;
            ObjectSetText(objCurPage, IntegerToString(curPage));
            drawDashboard();
        }
    }
    else if (description == "[<]") {
        curPage = (int)StringToInteger(ObjectDescription(objCurPage));
        if (curPage > 0) {
            curPage--;
            ObjectSetText(objCurPage, IntegerToString(curPage));
            drawDashboard();
        }
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
    ObjectSet(objName, OBJPROP_ARROWCODE, isTakeProfit ? 3 : 4);
    ObjectSet(objName, OBJPROP_COLOR , clrBlue);
    ObjectSet(objName, OBJPROP_TIME1 , orderCloseTime);
    ObjectSet(objName, OBJPROP_PRICE1, priceTP);

    objName = APP_TAG + "TradeSL" + IntegerToString(tradeIdx);
    ObjectCreate(objName, OBJ_ARROW, 0, 0, 0);
    ObjectSet(objName, OBJPROP_BACK, false);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objName, OBJPROP_ARROWCODE, isTakeProfit ? 4 : 3);
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
    ObjectSet(objName, OBJPROP_PRICE2, isTakeProfit ? priceTP : priceSL);
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
    double profit;
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
            data += DoubleToString(OrderStopLoss()  , 5)                        + ";";
            data += DoubleToString(OrderTakeProfit(), 5)                        + ";";
            profit = OrderProfit();
            if (profit < -InpRiskPerTrade/2)   data += "[sl]";
            else if (profit > InpRiskPerTrade) data += "[tp]";
            else  data += "[be]";
            setDataTo(tradeIdx++, data);
        }
    }
    ObjectSetText(objCurPage, "0");
    ObjectSetText(objAllPage, IntegerToString((int)MathCeil((float)tradeIdx/InpPageSize)-1));
}
//+------------------------------------------------------------------+

/// @brief HMI creatation
string objBgBoard       = APP_TAG   + "objBgBoard";
string objInitDboard    = APP_TAG   + "initDashboard";
string objCurPage       = APP_TAG   + "CurPage";
string objAllPage       = APP_TAG   + "AllPage";
int gRowPos = 0;
void initDashboard()
{
    ObjectCreate(objInitDboard, OBJ_TEXT, 0, 0, 0);
    
    ObjectCreate(objBgBoard, OBJ_LABEL, 0, 0, 0);
    ObjectSetText(objBgBoard, "██████", 10000, "Consolas", clrWhiteSmoke);
    ObjectSetString(0, objBgBoard, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objBgBoard, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    ObjectSet(objBgBoard, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    ObjectSet(objBgBoard, OBJPROP_SELECTABLE, false);
    ObjectSet(objBgBoard, OBJPROP_XDISTANCE, COL1+5);
    ObjectSet(objBgBoard, OBJPROP_YDISTANCE, 25);

    ObjectCreate(objCurPage, OBJ_LABEL, 0, 0, 0);
    ObjectCreate(objAllPage, OBJ_LABEL, 0, 0, 0);
    ObjectSetText(objCurPage, "0", 10, "Consolas", clrBlack);
    ObjectSetText(objAllPage, "0", 10, "Consolas", clrBlack);
    ObjectSetString(0, objCurPage, OBJPROP_TOOLTIP, "\n");
    ObjectSetString(0, objAllPage, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objCurPage, OBJPROP_YDISTANCE, -20);
    ObjectSet(objAllPage, OBJPROP_YDISTANCE, -20);

    ObjectSet(objCurPage, OBJPROP_SELECTABLE, false);
    ObjectSet(objCurPage, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    ObjectSet(objCurPage, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    ObjectSet(objAllPage, OBJPROP_SELECTABLE, false);
    ObjectSet(objAllPage, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    ObjectSet(objAllPage, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);

    ObjectSet(objCurPage, OBJPROP_XDISTANCE, COL2-25);
    ObjectSet(objAllPage, OBJPROP_XDISTANCE, COL2-50);

    // init function
    gLabelIndex = 0;
    createLabel(BTN_START, COL1, 5);
    hideItem(gLabelIndex, "Label");
}
void drawDashboard()
{
    gLabelIndex = 0;
    gRowPos = 5;
    // header
    createLabel(BTN_HIDEPN  , COL1+50, gRowPos);
    createLabel(BTN_RELOAD  , COL1+30, gRowPos);
    createLabel("Time_Date" , COL1, gRowPos);
    createLabel("Action"    , COL2, gRowPos);
    nextRow(); separateRow();
    // table
    string currentDate, objName, strOpenOrder;
    int curPage = (int)StringToInteger(ObjectDescription(objCurPage));
    int allPage = (int)StringToInteger(ObjectDescription(objAllPage));
    int i = curPage * InpPageSize;
    int fullPage = 0;
    while (getDataFrom(i) == true && fullPage < InpPageSize) {
        if (StringSubstr(TimeToStr(orderOpenTime, TIME_DATE), 5) != currentDate) {
            // if (fullPage != 0) nextRow(); TODO: Nghiên cứu phương cách mà next row vẫn được mà không bị cắt ngày.
            currentDate = StringSubstr(TimeToStr(orderOpenTime, TIME_DATE), 5);
            strOpenOrder = currentDate;
        }
        else {
            strOpenOrder = "     ";
        }
        strOpenOrder += " " + TimeToStr(orderOpenTime, TIME_MINUTES);
        objName = APP_TAG + "TradeEN" + IntegerToString(i);
        createLabel(strOpenOrder, COL1   , gRowPos);
        if (ObjectGet(objName, OBJPROP_PRICE1) == 0) {
            createLabel(BTN_TRDOPEN , COL2   , gRowPos);
            createLabel(BTN_TRDCLOSE, COL2-25, gRowPos);
        }
        else {
            createLabel(BTN_TRDHIDE , COL2   , gRowPos);
            objName = APP_TAG + "TradeSL" + IntegerToString(i);
            if (ObjectGet(objName, OBJPROP_PRICE1) == 0) createLabel(BTN_TRDCLOSE  , COL2-25, gRowPos);
            else createLabel(orderResult, COL2-25, gRowPos);
        }
        createLabel(IntegerToString(i)  , 0      , gRowPos);
        nextRow();
        fullPage++;
        i++;
    }
    // function
    if (allPage > 0){
        createLabel("――――――――――――――" + IntegerToString(curPage+1) + "/" + IntegerToString(allPage+1) + "―", COL1, gRowPos);
        nextRow();
        createLabel("[<]"       , COL2      , gRowPos);
        createLabel("[>]"       , COL2-25   , gRowPos);
        nextRow();
        separateRow();
    }
    else {
        separateRow();
    }

    ObjectSet(objBgBoard, OBJPROP_YDISTANCE, gRowPos);
    hideItem(gLabelIndex, "Label");
}
void hideDashboard()
{
    gLabelIndex = 0;
    createLabel(BTN_SHOWPN, 25, 20);
    ObjectSet(objBgBoard, OBJPROP_YDISTANCE, 0);
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
double   priceSL        ;
double   priceTP        ;
string   orderResult    ;
bool     isTakeProfit   ;
void setDataTo(int idx, string rawData)
{
    string str1 = StringSubstr(rawData, 0, 63);
    string str2 = StringSubstr(rawData, 63);

    string objTradeData = APP_TAG + "TradeData1" + IntegerToString(idx);
    ObjectCreate(objTradeData, OBJ_TEXT, 0, 0, 0);
    ObjectSetText(objTradeData, str1);
    objTradeData = APP_TAG + "TradeData2" + IntegerToString(idx);
    ObjectCreate(objTradeData, OBJ_TEXT, 0, 0, 0);
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
    priceSL        = StringToDouble  (data[5]);
    priceTP        = StringToDouble  (data[6]);
    orderResult    = data[7];
    isTakeProfit   = (orderResult == "[tp]");
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
    ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
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
        ObjectSet(objName, OBJPROP_YDISTANCE, 0);
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
    createLabel("―――――――――――――――――――", COL1, gRowPos);
    gRowPos += 15;
}
//+------------------------------------------------------------------+