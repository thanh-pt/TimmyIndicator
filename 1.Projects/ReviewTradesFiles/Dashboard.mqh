#ifndef APP_TAG
#define APP_TAG "Dashboard"
#endif

#define COL1 190
#define COL2 100

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

bool getDataFrom(int idx)
{
    string objTradeData = APP_TAG + "TradeData" + IntegerToString(idx);
    string rawData = ObjectDescription(objTradeData);
    if (rawData == "" || rawData == NULL) return false;
    //Print("rawData:[", rawData, "]");
    string data[];
    StringSplit(rawData,';',data);
    orderOpenTime  = StringToTime    (data[0]);
    orderCloseTime = StringToTime    (data[1]);
    orderType      = (int)StringToInteger (data[2]);
    orderLots      = StringToDouble  (data[3]);
    priceEN        = StringToDouble  (data[4]);
    priceSL        = StringToDouble  (data[5]);
    priceTP        = StringToDouble  (data[6]);
    return true;
}

int gTradeIndex = 0;

int gPage = 0;
int gPageTotal = 0;
void getData()
{
    // retrieving info from trade history
    int type,hstTotal=OrdersHistoryTotal(),tradeIdx = 0;
    string data;
    for(int i=0;i<hstTotal;i++) {
        //---- check selection result
        if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) {
            Print("Access to history failed with error (",GetLastError(),")");
            break;
        }
        // some work with order
        type = OrderType();
        if (type == OP_BUY || type == OP_SELL) {
            data = "";
            data += TimeToString(OrderOpenTime(), TIME_DATE|TIME_MINUTES) + ";";
            data += TimeToString(OrderCloseTime(), TIME_DATE|TIME_MINUTES) + ";";
            data += IntegerToString(OrderType()) + ";";
            data += DoubleToString(OrderLots(), 2)  + ";";
            data += DoubleToString(OrderOpenPrice(), 5) + ";";
            data += DoubleToString(OrderStopLoss(), 5) + ";";
            data += DoubleToString(OrderTakeProfit(), 5);
            setDataTo(tradeIdx++, data);
        }
    }
    ObjectSetText(objCurPage, "0");
    ObjectSetText(objAllPage, IntegerToString((int)MathCeil((float)tradeIdx/5)-1));
}

string objBgBoard   = APP_TAG   + "objBgBoard";
string objInitPanel = APP_TAG   + "initPanel";
string objCurPage   = APP_TAG   + "CurPage";
string objAllPage   = APP_TAG   + "AllPage";
void initPanel()
{
    ObjectCreate(objInitPanel, OBJ_TEXT, 0, 0, 0);
    
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
    createLabel("[Start Review Trades]", COL1, 5);
    hideItem(gLabelIndex, "Label");
}

int gRowPos = 0;
void drawDashboard()
{
    gLabelIndex = 0;
    gRowPos = 5;
    // header
    createLabel("Time_Date" , COL1, gRowPos);
    createLabel("Action"    , COL2, gRowPos);
    nextRow(); separateRow();
    // table
    string currentDate;
    int i = (int)StringToInteger(ObjectDescription(objCurPage)) * 5;
    int fullPage = 0;
    while (getDataFrom(i) == true && fullPage < 5) {
        getDataFrom(i);
        currentDate = TimeToStr(orderOpenTime, TIME_MINUTES) + " " + StringSubstr(TimeToStr(orderOpenTime, TIME_DATE), 5);
        createLabel(currentDate         , COL1   , gRowPos);
        createLabel("[View]"            , COL2   , gRowPos);
        createLabel("[Result]"          , COL2-40, gRowPos);
        createLabel(IntegerToString(i)  , 0      , gRowPos);
        nextRow();
        fullPage++;
        i++;
    }
    separateRow();
    // function
    createLabel("[Reload]"  , COL1, gRowPos);
    createLabel("[<]"       , COL2, gRowPos);
    createLabel("/"         , COL2-40, gRowPos);
    createLabel("[>]"       , 25,   gRowPos);
    ObjectSet(objCurPage, OBJPROP_YDISTANCE, gRowPos);
    ObjectSet(objAllPage, OBJPROP_YDISTANCE, gRowPos);
    nextRow();
    separateRow();

    ObjectSet(objBgBoard, OBJPROP_YDISTANCE, gRowPos);
    hideItem(gLabelIndex, "Label");
}

void handleClick(const string &sparam)
{
    string description = ObjectDescription(sparam);
    string tradeIdx;
    int curPage;
    if (description == "[View]"){
        tradeIdx = APP_TAG + "Label" + IntegerToString(getLabelIndex(sparam)+2);
        viewTrade(StrToInteger(ObjectDescription(tradeIdx)));
        ObjectSetText(sparam, "[Hide]");
    }
    if (description == "[Hide]"){
        tradeIdx = APP_TAG + "Label" + IntegerToString(getLabelIndex(sparam)+2);
        hideTrade(StrToInteger(ObjectDescription(tradeIdx)));
        ObjectSetText(sparam, "[View]");
    }
    else if (description == "[Result]") {
        tradeIdx = APP_TAG + "Label" + IntegerToString(getLabelIndex(sparam)+1);
        resultTrade(StrToInteger(ObjectDescription(tradeIdx)));
        string viewBtn = APP_TAG + "Label" + IntegerToString(getLabelIndex(sparam)-1);
        ObjectSetText(viewBtn, "[Hide]");
    }
    else if (description == "[Reload]" || description == "[Start Review Trades]") {
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