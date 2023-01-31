#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string          Pivot_ = "Pivot Config";

class Pivot : public BaseItem
{
// Internal Value
private:
// Component name
private:
    string cPivot;

// Value define for Item
private:
    datetime time;
    double   price;

public:
    Pivot(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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

Pivot::Pivot(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [0] = "Pivot";
    mNameType [1] = "Pivot Cont.";
    mIndexType = 0;
    mTypeNum = 2;
}

// Internal Event
void Pivot::prepareActive(){}
void Pivot::createItem()
{
    ObjectCreate(cPivot, OBJ_TEXT , 0, 0, 0);
    // updateTypeProperty();
    // updateDefaultProperty();
    time  = pCommonData.mMouseTime;
    price = pCommonData.mMousePrice;
    refreshData();
}
void Pivot::updateDefaultProperty(){}
void Pivot::updateTypeProperty(){}
void Pivot::activateItem(const string& itemId)
{
    cPivot = itemId + "_cPivot";
}
void Pivot::updateItemAfterChangeType(){}
void Pivot::refreshData()
{
    int shift = iBarShift(ChartSymbol(), ChartPeriod(), time);
    if (price <= Low[shift])
    {
        ObjectSetText(cPivot, "▲");
        ObjectSetInteger(ChartID(), cPivot, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSet(cPivot     , OBJPROP_COLOR, clrGreen);
    }
    else if (price >= High[shift])
    {
        ObjectSetText(cPivot, "▼");
        ObjectSetInteger(ChartID(), cPivot, OBJPROP_ANCHOR, ANCHOR_LOWER);
        ObjectSet(cPivot     , OBJPROP_COLOR, clrRed);
    }
    else
    {
        ObjectSetText(cPivot, "▼");
        ObjectSetInteger(ChartID(), cPivot, OBJPROP_ANCHOR, ANCHOR_CENTER);
    }
    setItemPos(cPivot, time, price);
}
void Pivot::finishedJobDone(){}

// Chart Event
void Pivot::onMouseMove()
{
    price= pCommonData.mMousePrice;
    time = pCommonData.mMouseTime;
    refreshData();
}
void Pivot::onMouseClick()
{
    createItem();
    if (mIndexType == 0)
    {
        mFinishedJobCb();
        return;
    }
    startActivate(mFinishedJobCb);
}
void Pivot::onItemDrag(const string &itemId, const string &objId)
{
    time  = (datetime)ObjectGet(cPivot, OBJPROP_TIME1);
    price =           ObjectGet(cPivot, OBJPROP_PRICE1);

    if (pCommonData.mCtrlHold)
    {
        price = pCommonData.mMousePrice;
    }
    refreshData();
}
void Pivot::onItemClick(const string &itemId, const string &objId){}
void Pivot::onItemChange(const string &itemId, const string &objId){}
void Pivot::onItemDeleted(const string &itemId, const string &objId){}