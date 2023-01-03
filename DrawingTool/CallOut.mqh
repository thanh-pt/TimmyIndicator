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
    string cText        ;
    string cPointerLine ;
    string cUnderLine   ;

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
    ObjectCreate(cPointerLine, OBJ_TREND, 0, 0, 0);
    ObjectCreate(cUnderLine  , OBJ_TREND, 0, 0, 0);
    ObjectCreate(cText       , OBJ_TEXT , 0, 0, 0);
    updateTypeProperty();
    updateDefaultProperty();
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void CallOut::updateDefaultProperty()
{
    ObjectSet(cUnderLine, OBJPROP_SELECTABLE, false);

    ObjectSet(cPointerLine, OBJPROP_RAY, 0);
    ObjectSet(cUnderLine  , OBJPROP_RAY, 0);

    ObjectSetString(ChartID(), cText        ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cPointerLine ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cUnderLine   ,OBJPROP_TOOLTIP,"\n");
}
void CallOut::updateTypeProperty()
{
    ObjectSet(cPointerLine, OBJPROP_COLOR, CallOut_Color);
    ObjectSet(cPointerLine, OBJPROP_WIDTH, CallOut_Width);
    //-------------------------------------------------------------
    ObjectSet(cUnderLine  , OBJPROP_COLOR, CallOut_Color);
    ObjectSet(cUnderLine  , OBJPROP_WIDTH, CallOut_Width+1);
    //-------------------------------------------------------------
    ObjectSet(cText       , OBJPROP_COLOR   , CallOut_Color);
    ObjectSet(cText       , OBJPROP_FONTSIZE, CallOut_TextSize);
    ObjectSet(cText       , OBJPROP_SELECTED, true);
}
void CallOut::activateItem(const string& itemId)
{
    cText        = itemId + "_" + "cText";
    cPointerLine = itemId + "_" + "cPointerLine";
    cUnderLine   = itemId + "_" + "cUnderLine";
}
void CallOut::updateItemAfterChangeType(){}
void CallOut::refreshData()
{
    ObjectSet(cPointerLine, OBJPROP_TIME1,  time1);
    ObjectSet(cPointerLine, OBJPROP_PRICE1, price1);
    ObjectSet(cPointerLine, OBJPROP_TIME2,  time2);
    ObjectSet(cPointerLine, OBJPROP_PRICE2, price2);
    //-------------------------------------------------------------
    ObjectSet(cText, OBJPROP_TIME1,  time2);
    ObjectSet(cText, OBJPROP_PRICE1, price2);
    //-------------------------------------------------------------
    int x, y, offset = 100;
    if (time1 > time2)
    {
        ObjectSetInteger(ChartID(), cText, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
        offset = -100;
    }
    else
    {
        ObjectSetInteger(ChartID(), cText, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        offset = 100;
    }
    datetime time3;
    double price3;
    ChartTimePriceToXY(ChartID(), 0, time2, price2, x, y);
    ChartXYToTimePrice(ChartID(), x + offset, y, offset, time3, price3);
    //-------------------------------------------------------------
    ObjectSet(cUnderLine, OBJPROP_TIME1,  time2);
    ObjectSet(cUnderLine, OBJPROP_PRICE1, price2);
    ObjectSet(cUnderLine, OBJPROP_TIME2,  time3);
    ObjectSet(cUnderLine, OBJPROP_PRICE2, price2);

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
    time1   = (datetime)ObjectGet(cPointerLine, OBJPROP_TIME1);
    time2   = (datetime)ObjectGet(cPointerLine, OBJPROP_TIME2);
    price1  =           ObjectGet(cPointerLine, OBJPROP_PRICE1);
    price2  =           ObjectGet(cPointerLine, OBJPROP_PRICE2);

    if (objId == cText)
    {
        time2   = (datetime)ObjectGet(cText, OBJPROP_TIME1);
        price2  =           ObjectGet(cText, OBJPROP_PRICE1);
    }

    refreshData();
}
void CallOut::onItemClick(const string &itemId, const string &objId){}
void CallOut::onItemChange(const string &itemId, const string &objId)
{
    double c = ObjectGet(objId, OBJPROP_COLOR);
    ObjectSet(cText       , OBJPROP_COLOR, c);
    ObjectSet(cPointerLine, OBJPROP_COLOR, c);
    ObjectSet(cUnderLine  , OBJPROP_COLOR, c);
}
void CallOut::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cText       );
    ObjectDelete(cPointerLine);
    ObjectDelete(cUnderLine  );
}