#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

// input string          Pivot_ = "Pivot Config";

class Pivot : public BaseItem
{
// Internal Value
private:
    string IconList[2];

// Component name
private:
    string cPivot;
    string sType0;

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
    mNameType [1] = "React";
    mIndexType = 0;
    mTypeNum = 2;
    IconList[0] = "●";
    IconList[1] = "▼";
}

// Internal Event
void Pivot::prepareActive(){}
void Pivot::createItem()
{
    ObjectCreate(cPivot, OBJ_TEXT , 0, 0, 0);
    ObjectCreate(sType0, OBJ_TEXT , 0, 0, 0);
    updateTypeProperty();
    updateDefaultProperty();
    time  = pCommonData.mMouseTime;
    price = pCommonData.mMousePrice;
    refreshData();
}
void Pivot::updateDefaultProperty()
{
    ObjectSetInteger(ChartID(), cPivot, OBJPROP_ANCHOR, ANCHOR_LOWER);
}
void Pivot::updateTypeProperty()
{
    ObjectSetText(sType0, IntegerToString(mIndexType));
    ObjectSetText(cPivot, IconList[mIndexType]);
}
void Pivot::activateItem(const string& itemId)
{
    cPivot = itemId + "_cPivot";
    sType0 = itemId + "_sType0";
}
void Pivot::updateItemAfterChangeType(){}
void Pivot::refreshData()
{
    int shift = iBarShift(ChartSymbol(), ChartPeriod(), time);
    if (price <= Low[shift])
    {
        ObjectSet(cPivot, OBJPROP_ANGLE,  180);
        ObjectSet(cPivot     , OBJPROP_COLOR, clrGreen);
    }
    else
    {
        ObjectSet(cPivot, OBJPROP_ANGLE,  0);
        
        ObjectSet(cPivot     , OBJPROP_COLOR, clrRed);
    }
    ObjectSetString(ChartID(), cPivot, OBJPROP_TOOLTIP, DoubleToString(price, 5));
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
    mFinishedJobCb();
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
void Pivot::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cPivot);
    ObjectDelete(sType0);
}