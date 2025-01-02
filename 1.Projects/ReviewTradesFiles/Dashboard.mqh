#ifndef APP_TAG
#define APP_TAG "Dashboard"
#endif

#define MAX_TRADES 100
#define COL1 250
#define COL2 225
#define COL3 140
#define COL4 50

datetime orderOpenTime  ;
datetime orderCloseTime ;
int      orderType      ;
double   orderLots      ;
double   priceEN        ;
double   priceSL        ;
double   priceTP        ;

void setDataTo(int idx, string rawData)
{
    string objTradeData = APP_TAG + "TradeData" + IntegerToString(idx);
    ObjectCreate(objTradeData, OBJ_TEXT, 0, 0, 0);
    ObjectSetText(objTradeData, rawData);
}

void getDataFrom(int idx)
{
    string objTradeData = APP_TAG + "TradeData" + IntegerToString(idx);
    string rawData = ObjectDescription(objTradeData);
    string data[];
    StringSplit(rawData,';',data);
    orderOpenTime  = StringToTime    (data[0]);
    orderCloseTime = StringToTime    (data[1]);
    orderType      = (int)StringToInteger (data[2]);
    orderLots      = StringToDouble  (data[3]);
    priceEN        = StringToDouble  (data[4]);
    priceSL        = StringToDouble  (data[5]);
    priceTP        = StringToDouble  (data[6]);
}

int gTradeIndex = 0;
int gPage = 0;
int gPageTotal = 0;
void getData()
{
    gTradeIndex = 0;
    gPage = 0;
    // retrieving info from trade history
    int i,_orderType,hstTotal=OrdersHistoryTotal();
    string data;
    for(i=0;i<hstTotal;i++) {
        //---- check selection result
        if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) {
            Print("Access to history failed with error (",GetLastError(),")");
            break;
        }
        // some work with order
        _orderType = OrderType();
        if (_orderType == OP_BUY || _orderType == OP_SELL) {
            data = "";
            data += TimeToString(OrderOpenTime(), TIME_DATE|TIME_MINUTES) + ";";
            data += TimeToString(OrderCloseTime(), TIME_DATE|TIME_MINUTES) + ";";
            data += IntegerToString(OrderType()) + ";";
            data += DoubleToString(OrderLots(), 2)  + ";";
            data += DoubleToString(OrderOpenPrice(), 5) + ";";
            data += DoubleToString(OrderStopLoss(), 5) + ";";
            data += DoubleToString(OrderTakeProfit(), 5);
            setDataTo(gTradeIndex++, data);
        }
    }
    gPageTotal = (int)MathCeil((float)gTradeIndex/5);
}

string objDashboardBg = APP_TAG  + "DashboardBg";
string objRowHighlight = APP_TAG + "RowHighlight";
string objInitDashboard = APP_TAG+ "initPanel";
void initPanel()
{
    ObjectCreate(objInitDashboard, OBJ_TEXT, 0, 0, 0);
    
    ObjectCreate(objDashboardBg, OBJ_LABEL, 0, 0, 0);
    ObjectSetText(objDashboardBg, "██████", 10000, "Consolas", clrWhiteSmoke);
    ObjectSetString(0, objDashboardBg, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objDashboardBg, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    ObjectSet(objDashboardBg, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    ObjectSet(objDashboardBg, OBJPROP_SELECTABLE, false);
    ObjectSet(objDashboardBg, OBJPROP_XDISTANCE, 0);
    ObjectSet(objDashboardBg, OBJPROP_YDISTANCE, 0);

    ObjectCreate(objRowHighlight, OBJ_LABEL, 0, 0, 0);
    ObjectSetText(objRowHighlight, "________________________________________________", 10, "Consolas", clrGold);
    ObjectSetString(0, objRowHighlight, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objRowHighlight, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    ObjectSet(objRowHighlight, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    ObjectSet(objRowHighlight, OBJPROP_SELECTABLE, false);
    ObjectSet(objRowHighlight, OBJPROP_XDISTANCE, COL1);
    ObjectSet(objRowHighlight, OBJPROP_YDISTANCE, -20);

    gLabelIndex = 0;
    gRowPos = 5;
    // function
    createLabel("[Reload]"  , COL1, gRowPos);
    hideItem(gLabelIndex, "Label");
}

int gRowPos = 0;
void drawDashboard()
{
    gLabelIndex = 0;
    gRowPos = 5;
    // header
    createLabel("Idx"   , COL1, gRowPos);
    createLabel("Date"  , COL2, gRowPos);
    createLabel("Action", COL3, gRowPos);
    createLabel("Note"  , COL4, gRowPos);
    nextRow();
    separateRow();
    // table
    string currentDate;
    // todo: Chia page
    // todo: hide/show button
    for (int i = gPage*5; i < gTradeIndex && i < (gPage+1) * 5; i++) {
        getDataFrom(i);
        currentDate = TimeToStr(orderOpenTime, TIME_MINUTES) + " "
                    + StringSubstr(TimeToStr(orderOpenTime, TIME_DATE), 5);
        createLabel(IntegerToString(i)  , COL1      , gRowPos);
        createLabel(currentDate         , COL2      , gRowPos);
        createLabel("View"              , COL3      , gRowPos);
        createLabel("Result"            , COL3-40   , gRowPos);
        nextRow();
    }
    separateRow();
    // function
    createLabel("[Reload]"  , COL1, gRowPos);
    createLabel("[<]"       , COL3, gRowPos);
    createLabel(IntegerToString(gPage+1) + "/" + IntegerToString(gPageTotal), COL3-20, gRowPos);
    createLabel("[>]"       , COL3-50, gRowPos);
    nextRow();
    separateRow();

    ObjectSet(objDashboardBg, OBJPROP_XDISTANCE, COL1+5);
    ObjectSet(objDashboardBg, OBJPROP_YDISTANCE, gRowPos);
    hideItem(gLabelIndex, "Label");
}

void handleClick(const string &sparam)
{
    string description = ObjectDescription(sparam);
    string tradeIdx;
    if (description == "View"){
        tradeIdx = APP_TAG + "Label" + IntegerToString(getLabelIndex(sparam)-2);
        viewTrade(StrToInteger(ObjectDescription(tradeIdx)));
        ObjectSetText(sparam, "Hide");
        
        ObjectSet(objRowHighlight, OBJPROP_YDISTANCE, ObjectGet(sparam, OBJPROP_YDISTANCE));
    }
    if (description == "Hide"){
        tradeIdx = APP_TAG + "Label" + IntegerToString(getLabelIndex(sparam)-2);
        hideTrade(StrToInteger(ObjectDescription(tradeIdx)));
        ObjectSetText(sparam, "View");
    }
    else if (description == "Result") {
        tradeIdx = APP_TAG + "Label" + IntegerToString(getLabelIndex(sparam)-3);
        resultTrade(StrToInteger(ObjectDescription(tradeIdx)));
        string viewBtn = APP_TAG + "Label" + IntegerToString(getLabelIndex(sparam)-1);
        ObjectSetText(viewBtn, "Hide");
        ObjectSet(objRowHighlight, OBJPROP_YDISTANCE, ObjectGet(sparam, OBJPROP_YDISTANCE));
    }
    else if (description == "[Reload]") {
        getData();
        drawDashboard();
    }
    else if (description == "[>]") {
        if (gPage < gPageTotal-1) {
            gPage++;
            drawDashboard();
        }
    }
    else if (description == "[<]") {
        if (gPage > 0) {
            gPage--;
            drawDashboard();
        }
    }
}

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

int getLabelIndex(string objIdLabel)
{
    StringReplace(objIdLabel, APP_TAG + "Label", "");
    return StrToInteger(objIdLabel);
}

void viewTrade(int tradeIdx)
{
    string objName = APP_TAG + "TradeEN" + IntegerToString(tradeIdx);
    ObjectCreate(objName, OBJ_ARROW, 0, 0, 0);
    ObjectSet(objName, OBJPROP_BACK, false);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objName, OBJPROP_ARROWCODE, 2);

    getDataFrom(tradeIdx);
    ObjectSet(objName, OBJPROP_COLOR , orderType == OP_BUY ? clrBlue : clrRed);
    ObjectSet(objName, OBJPROP_TIME1 , orderOpenTime);
    ObjectSet(objName, OBJPROP_PRICE1, priceEN);

    objName = APP_TAG + "TradeTP" + IntegerToString(tradeIdx);
    ObjectSet(objName, OBJPROP_TIME1 , 0);
    objName = APP_TAG + "TradeSL" + IntegerToString(tradeIdx);
    ObjectSet(objName, OBJPROP_TIME1 , 0);
}
void hideTrade(int tradeIdx)
{
    string objName = APP_TAG + "TradeEN" + IntegerToString(tradeIdx);
    ObjectSet(objName, OBJPROP_TIME1 , 0);
    objName = APP_TAG + "TradeTP" + IntegerToString(tradeIdx);
    ObjectSet(objName, OBJPROP_TIME1 , 0);
    objName = APP_TAG + "TradeSL" + IntegerToString(tradeIdx);
    ObjectSet(objName, OBJPROP_TIME1 , 0);
}

void resultTrade(int tradeIdx)
{
    string objName = APP_TAG + "TradeEN" + IntegerToString(tradeIdx);
    ObjectCreate(objName, OBJ_ARROW, 0, 0, 0);
    ObjectSet(objName, OBJPROP_BACK, false);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objName, OBJPROP_ARROWCODE, 2);

    getDataFrom(tradeIdx);
    ObjectSet(objName, OBJPROP_COLOR , orderType == OP_BUY ? clrBlue : clrRed);
    ObjectSet(objName, OBJPROP_TIME1 , orderOpenTime);
    ObjectSet(objName, OBJPROP_PRICE1, priceEN);

    objName = APP_TAG + "TradeTP" + IntegerToString(tradeIdx);
    ObjectCreate(objName, OBJ_ARROW, 0, 0, 0);
    ObjectSet(objName, OBJPROP_BACK, false);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objName, OBJPROP_ARROWCODE, 3);
    ObjectSet(objName, OBJPROP_COLOR , clrBlue);
    ObjectSet(objName, OBJPROP_TIME1 , orderCloseTime);
    ObjectSet(objName, OBJPROP_PRICE1, priceTP);

    objName = APP_TAG + "TradeSL" + IntegerToString(tradeIdx);
    ObjectCreate(objName, OBJ_ARROW, 0, 0, 0);
    ObjectSet(objName, OBJPROP_BACK, false);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objName, OBJPROP_ARROWCODE, 3);
    ObjectSet(objName, OBJPROP_COLOR , clrRed);
    ObjectSet(objName, OBJPROP_TIME1 , orderCloseTime);
    ObjectSet(objName, OBJPROP_PRICE1, priceSL);
}

void nextRow() {
    gRowPos += 15;
}

void separateRow() {
    createLabel("------------------------------------------------", COL1, gRowPos);
    gRowPos += 15;
}