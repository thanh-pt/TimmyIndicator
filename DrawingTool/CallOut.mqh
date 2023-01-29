#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string          CallOut_ = SEPARATE_LINE_BIG;
input color           CallOut_Color = clrWhite;
input int             CallOut_Width = 1;
input int             CallOut_TextSize = 10;

class CallOut : public BaseItem
{
// Internal Value
private:

// Component name
private:
    string cLbText;
    string cPtLine;
    string iUdLine;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double price1;
    double price2;

public:
    CallOut(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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

// Chart Event
public:
    virtual void onMouseMove();
    virtual void onMouseClick();
    virtual void onItemDrag(const string &itemId, const string &objId);
    virtual void onItemClick(const string &itemId, const string &objId);
    virtual void onItemChange(const string &itemId, const string &objId);
    virtual void onItemDeleted(const string &itemId, const string &objId);
};

CallOut::CallOut(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [0] = "CallOut1";
    mIndexType = 0;
    mTypeNum = 0;
}

// Internal Event
void CallOut::prepareActive(){}
void CallOut::createItem()
{
    ObjectCreate(cPtLine, OBJ_TREND, 0, 0, 0);
    ObjectCreate(iUdLine, OBJ_TREND, 0, 0, 0);
    ObjectCreate(cLbText, OBJ_TEXT , 0, 0, 0);
    updateTypeProperty();
    updateDefaultProperty();
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void CallOut::updateDefaultProperty()
{
    ObjectSet(iUdLine, OBJPROP_SELECTABLE, false);
    multiSetStrs(OBJPROP_TOOLTIP, "\n",cLbText+cPtLine+iUdLine);
}
void CallOut::updateTypeProperty()
{
    SetObjectStyle(cPtLine, CallOut_Color, 0, CallOut_Width);
    SetObjectStyle(iUdLine, CallOut_Color, 0, CallOut_Width+1);
    //-------------------------------------------------------------
    ObjectSetText(cLbText, "Msg!", CallOut_TextSize, NULL, CallOut_Color);
    ObjectSet(cLbText, OBJPROP_SELECTED, true);
}
void CallOut::activateItem(const string& itemId)
{
    cLbText = itemId + "_cLbText";
    cPtLine = itemId + "_cPtLine";
    iUdLine = itemId + "_iUdLine";
}
void CallOut::updateItemAfterChangeType(){}
void CallOut::refreshData()
{
    setItemPos(cPtLine, time1, time2, price1, price2);
    setItemPos(cLbText, time2, price2);
    //-------------------------------------------------------------
    int x, y, offset;
    offset = (int)((double)(StringLen(ObjectDescription(cLbText))*CallOut_TextSize) * 2/3);
    if (time1 > time2)
    {
        ObjectSetInteger(ChartID(), cLbText, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
        offset *= (-1);
    }
    else
    {
        ObjectSetInteger(ChartID(), cLbText, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    }
    datetime time3;
    double price3;
    ChartTimePriceToXY(ChartID(), 0, time2, price2, x, y);
    ChartXYToTimePrice(ChartID(), x + offset, y, offset, time3, price3);
    //-------------------------------------------------------------
    setItemPos(iUdLine, time2, time3, price2, price2);
}
void CallOut::finishedJobDone(){}

// Chart Event
void CallOut::onMouseMove()
{
    if (mFirstPoint == false)
    {
        return;
    }
    time2  = pCommonData.mMouseTime;
    price2 = pCommonData.mMousePrice;
    refreshData();
}
void CallOut::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void CallOut::onItemDrag(const string &itemId, const string &objId)
{
    time1   = (datetime)ObjectGet(cPtLine, OBJPROP_TIME1);
    time2   = (datetime)ObjectGet(cPtLine, OBJPROP_TIME2);
    price1  =           ObjectGet(cPtLine, OBJPROP_PRICE1);
    price2  =           ObjectGet(cPtLine, OBJPROP_PRICE2);

    if (objId == cLbText)
    {
        time2   = (datetime)ObjectGet(cLbText, OBJPROP_TIME1);
        price2  =           ObjectGet(cLbText, OBJPROP_PRICE1);
    }

    refreshData();
}
void CallOut::onItemClick(const string &itemId, const string &objId){}
void CallOut::onItemChange(const string &itemId, const string &objId)
{
    multiSetProp(OBJPROP_COLOR, (color)ObjectGet(objId, OBJPROP_COLOR), cLbText+cPtLine+iUdLine);
    onItemDrag(itemId, objId);
}
void CallOut::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cLbText);
    ObjectDelete(cPtLine);
    ObjectDelete(iUdLine);
}