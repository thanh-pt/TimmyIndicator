#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

// input string          Pivot_ = "Pivot Config";

enum PivotType
{
    POINT_PIVOT,
    POINT_REACT,
    POINT_PRICE,
    POINT_NUM,
};

class Pivot : public BaseItem
{
// Internal Value
private:

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
    mNameType [POINT_PIVOT] = "Pivot";
    mNameType [POINT_REACT] = "React";
    mNameType [POINT_PRICE] = "Price";

    mIndexType = 0;
    mTypeNum = POINT_NUM;
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
    bool isUp = false;
    if (price >= High[shift]) isUp = true;

    ObjectSet(cPivot, OBJPROP_COLOR, isUp ? clrRed : clrGreen);
    ObjectSetInteger(ChartID(), cPivot, OBJPROP_ANCHOR, isUp ? ANCHOR_LOWER : ANCHOR_UPPER);

    if (mIndexType == POINT_PIVOT)
    {
        ObjectSetText(cPivot, "░●░");
    } else if (mIndexType == POINT_REACT)
    {
        ObjectSetText(cPivot, isUp ? "▼" : "▲");
    } else if (mIndexType == POINT_PRICE)
    {
        ObjectSetText(cPivot, DoubleToString(price, 5));
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
    mIndexType = StrToInteger(ObjectDescription(sType0));
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