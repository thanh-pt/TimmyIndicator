#include "../Base/BaseItem.mqh"

#define ALERT_INDI_H "↑"
#define ALERT_INDI_L "↓"

enum EAlertType
{
    CREATE_ALERT,
    TEST_ALERT,
    CUTIL_NUM,
};

enum ENotiType
{
    ENotiPhone, // Phone
    ENotiPC,    // PC
    ENotiNone,  // Silent
};
#ifdef Lver
input string        _Alert; // ●  A L E R T (Pro Version)
ENotiType     InpNotiType     = ENotiPhone;   // Alert
color         InpAlertColor   = clrGainsboro; // Color
#else
input string        _Alert;                         // ●  A L E R T  ●
input ENotiType     InpNotiType     = ENotiPhone;   // Alert
input color         InpAlertColor   = clrGainsboro; // Color
#endif
    LINE_STYLE    InpAlertStyle   = STYLE_DOT;    // Style

class Alert : public BaseItem
{
// Internal Value
private:
string mAlertIndi;
string mAlertText;
// handleAlertVariable
string mListAlertStr;
string mCurAlertText;
string mListAlertArr[];
int    mAlertNumber;
bool   mIsAlertGoOver;
double mCurAlertPrice;
string mListAlertRemainStr;

// Component name
private:
    string cFb01;
    string cPtM0;
// Value define for Item
private:
    datetime time1;
    double   price1;

public:
    Alert(CommonData* commonData, MouseInfo* mouseInfo);

// Internal Event
public:
    virtual void prepareActive();
    virtual void createItem();
    virtual void updateDefaultProperty();
    virtual void updateTypeProperty();
    virtual void activateItem(const string& itemId);
    virtual void updateItemAfterChangeType();
    virtual void refreshData();
    virtual void finishedJobDone();

// Internal Function
private:
    void initAlarm();
    void sendNotification(string msg);
public:
    void checkAlert();

// Chart Event
public:
    virtual void onMouseMove();
    virtual void onMouseClick();
    virtual void onItemDrag(const string &itemId, const string &objId);
    virtual void onItemClick(const string &itemId, const string &objId);
    virtual void onItemChange(const string &itemId, const string &objId);

public:
    static string getAllItem(string itemId);
    static string Tag;
};

static string Alert::Tag = ".TMAlert";

Alert::Alert(CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = Alert::Tag;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [CREATE_ALERT] = "Alert";
    mNameType [TEST_ALERT]   = "Ping!";
    mTypeNum = CUTIL_NUM;
    mIndexType = 0;

    initAlarm();
}

// Internal Event
void Alert::prepareActive(){}
void Alert::createItem()
{
    ObjectCreate(cFb01, OBJ_FIBO , 0, 0, 0);
    ObjectCreate(cPtM0, OBJ_ARROW, 0, 0, 0);

    updateDefaultProperty();
    // updateTypeProperty();
}
void Alert::updateDefaultProperty()
{
    setObjectStyle(cFb01, gClrPointer, InpAlertStyle, 0, true);
    ObjectSet(cFb01, OBJPROP_RAY  , true);
    ObjectSet(cFb01,OBJPROP_LEVELS, 1);
    ObjectSetDouble (0, cFb01,OBJPROP_LEVELVALUE,0, 0);
    ObjectSetInteger(0, cFb01,OBJPROP_LEVELCOLOR,0, gClrPointer);
    ObjectSetInteger(0, cFb01,OBJPROP_LEVELSTYLE,0, STYLE_DOT);
    ObjectSetInteger(0, cFb01,OBJPROP_LEVELWIDTH,0, 1);
    
    ObjectSet(cPtM0, OBJPROP_COLOR, gClrPointer);
    ObjectSet(cPtM0, OBJPROP_ARROWCODE, 4);

    setMultiStrs(OBJPROP_TOOLTIP, "\n", mAllItem);
}
void Alert::updateTypeProperty(){}
void Alert::activateItem(const string& itemId)
{
    cFb01 = itemId + TAG_CTRL + "cFb01";
    cPtM0 = itemId + TAG_CTRM + "cPtM0";
    mAllItem += cPtM0+cFb01;
}
string Alert::getAllItem(string itemId)
{
    string allItem = itemId + "_mTData";
    allItem += itemId + TAG_CTRM + "cPtM0";
    allItem += itemId + TAG_CTRL + "cFb01";
    return allItem;
}
void Alert::updateItemAfterChangeType(){}
void Alert::refreshData(){
    setItemPos(cFb01, time1, iTime(ChartSymbol(), PERIOD_D1, 0) + PERIOD_D1*60, price1, price1);
    setItemPos(cPtM0, time1, price1);

    // Handle logic gì đó
    mAlertText = ObjectGetString(0, cPtM0, OBJPROP_TEXT);
    StringReplace(mAlertText, ALERT_INDI_H, "");
    StringReplace(mAlertText, ALERT_INDI_L, "");
    mAlertIndi = (price1 > Bid ? ALERT_INDI_H : ALERT_INDI_L);
    if (mAlertText == "") {
        ObjectSetString (0, cFb01,OBJPROP_LEVELTEXT,0, "► "+DoubleToString(price1, Digits));
    }
    else {
        ObjectSetString (0, cFb01,OBJPROP_LEVELTEXT,0, "► "+mAlertText);
    }
    mAlertText = mAlertIndi + mAlertText;
    setTextContent(cPtM0, mAlertText);

    if (StringFind(mListAlertStr, cPtM0) == -1) mListAlertStr += cPtM0 + ",";

    // Update vụ Selected or NOT
    int selected = (int)ObjectGet(cPtM0, OBJPROP_SELECTED);
    ObjectSet(cFb01, OBJPROP_COLOR, selected ? gClrForegrnd : gClrPointer);
    ObjectSet(cPtM0, OBJPROP_COLOR, selected ? gClrForegrnd : clrNONE);
    ObjectSetInteger(0, cFb01,OBJPROP_LEVELCOLOR,0, selected ? gClrForegrnd : gClrPointer);
}
void Alert::finishedJobDone(){}

// Chart Event
void Alert::onMouseMove()
{
    MOUSE_MOVE_RETURN_CHECK
}
void Alert::onMouseClick()
{
    if (mIndexType == CREATE_ALERT) {
        createItem();

        time1  = pCommonData.mMouseTime;
        price1 = pCommonData.mMousePrice;
        refreshData();

        // Function Config
        mAlertIndi = (price1 > Bid ? ALERT_INDI_H : ALERT_INDI_L);
        setTextContent(cPtM0, mAlertIndi);
        mListAlertStr += cPtM0 + ",";
    }
    else if (mIndexType == TEST_ALERT){
        sendNotification("↗﹉↘﹍" + DoubleToString(gCommonData.mMousePrice, Digits) + "\nThông báo OK!");
    }
    mFinishedJobCb();
}
void Alert::onItemDrag(const string &itemId, const string &objId)
{
    if (pCommonData.mCtrlHold) {
        price1 = pCommonData.mMousePrice;
        time1  = pCommonData.mMouseTime;
    }
    else if (objId == cPtM0) {
        time1 = (datetime)ObjectGet(cPtM0, OBJPROP_TIME1);
        price1 =          ObjectGet(objId, OBJPROP_PRICE1);
        price1 =          ObjectGet(objId, OBJPROP_PRICE1);
        price1 =          ObjectGet(objId, OBJPROP_PRICE1);
    }
    else if (objId == cFb01) {
        time1 = (datetime)ObjectGet(cPtM0, OBJPROP_TIME1);
        double priceB = ObjectGet(objId, OBJPROP_PRICE1);
        double priceC = ObjectGet(objId, OBJPROP_PRICE2);
        if (priceB == priceC) price1 = priceB;
        else {
            double priceA = ObjectGet(cPtM0, OBJPROP_PRICE1);
            if (priceA == priceB) price1 = priceC;
            else price1 = priceB;
        }
    }

    refreshData();
}
void Alert::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, TAG_CTRL) < 0) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    setCtrlItemSelectState(mAllItem, selected);
    ObjectSet(cFb01, OBJPROP_COLOR, selected ? gClrForegrnd : gClrPointer);
    ObjectSet(cPtM0, OBJPROP_COLOR, selected ? gClrForegrnd : clrNONE);
    ObjectSetInteger(0, cFb01,OBJPROP_LEVELCOLOR,0, selected ? gClrForegrnd : gClrPointer);
}
void Alert::onItemChange(const string &itemId, const string &objId)
{
    if (objId == cFb01) {
        string description = ObjectDescription(objId);
        if (description != ""){
            setTextContent(objId, "");
            if (description == "-") description = "";
            price1 = ObjectGet(objId, OBJPROP_PRICE1);
            mAlertIndi = (price1 > Bid ? ALERT_INDI_H : ALERT_INDI_L);
            mAlertText = mAlertIndi + description;
            setTextContent(cPtM0, mAlertText);
        }
    }
    onItemDrag(itemId, objId);
}
// Internal Function

void Alert::initAlarm()
{
    mListAlertStr = "";
    mCurAlertText = "";
    mAlertNumber = 0;
    mIsAlertGoOver  = false;
    mCurAlertPrice = 0;
    mListAlertRemainStr = "";
    string alertLine = "";
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--) {
        alertLine = ObjectName(i);
        if (StringFind(alertLine, Alert::Tag) == -1) continue;
        if (StringFind(alertLine, TAG_CTRM) == -1) continue;
        // Add Alert to the list
        if (mListAlertStr != "") mListAlertStr += ",";
        mListAlertStr += alertLine;
    }
}

void Alert::checkAlert()
{
    mAlertNumber  = StringSplit(mListAlertStr,',',mListAlertArr);
    mListAlertRemainStr = "";
    bool isHighAlert = false;
    for (int i = mAlertNumber-1; i >= 0; i--) {
        // Check valid Alert
        if (ObjectFind(mListAlertArr[i]) < 0) continue;

        // Get Alert information
        mIsAlertGoOver  = false;
        mCurAlertPrice = ObjectGet(mListAlertArr[i], OBJPROP_PRICE1);
        mCurAlertText  = ObjectGetString(0, mListAlertArr[i], OBJPROP_TEXT);
        // Check Alert Price
        if (StringFind(mCurAlertText,ALERT_INDI_H) != -1) {
            mIsAlertGoOver  = (Bid > mCurAlertPrice);
            isHighAlert = true;
        }
        else if (StringFind(mCurAlertText,ALERT_INDI_L) != -1){
            mIsAlertGoOver  = (Bid < mCurAlertPrice);
            isHighAlert = false;
        }

        // Send notification or save remain Alert
        if (mIsAlertGoOver) {
            StringReplace(mCurAlertText, ALERT_INDI_H, "");
            StringReplace(mCurAlertText, ALERT_INDI_L, "");
            mCurAlertText = ChartSymbol() + mCurAlertText;
            sendNotification(   (isHighAlert ? ALERT_INDI_H : ALERT_INDI_L) + DoubleToString(mCurAlertPrice, Digits) + "\n"
                                + mCurAlertText);
            ObjectDelete(mListAlertArr[i]);
            StringReplace(mListAlertArr[i], TAG_CTRM + "cPtM0", TAG_CTRL + "cFb01");
            ObjectDelete(mListAlertArr[i]);
        }
        else {
            mListAlertRemainStr += mListAlertArr[i] + ",";
            if (Bid == mCurAlertPrice) {
                StringReplace(mCurAlertText, ALERT_INDI_H, "");
                StringReplace(mCurAlertText, ALERT_INDI_L, "");
                mCurAlertText = ChartSymbol() + mCurAlertText;
                sendNotification(   (isHighAlert ? "↗﹉" : "↘﹍") + DoubleToString(mCurAlertPrice, Digits) + "\n"
                                    + mCurAlertText);
            }
        }
    }
    mListAlertStr = mListAlertRemainStr;
}

void Alert::sendNotification(string msg)
{
    if (InpNotiType == ENotiNone) return;
    if (InpNotiType == ENotiPhone){
        SendNotification(msg);
    } else {
        Alert(msg);
    }
}
