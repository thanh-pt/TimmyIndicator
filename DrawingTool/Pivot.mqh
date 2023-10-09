#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

// input string          Pivot_ = "Pivot Config";

enum PivotType
{
    POINT_PIVOT,
    POINT_REACT,
    POINT_LEFT ,
    POINT_RIGHT,
    POINT_TOP  ,
    // POINT_DOWN,
    POINT_NUM,
};

class Pivot : public BaseItem
{
// Internal Value
private:
    int leftRighTopDownPos[4];

// Component name
private:
    string cPivot;
    string sType;

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
    virtual void onUserRequest(const string &itemId, const string &objId);
};

Pivot::Pivot(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [POINT_PIVOT] = "Pivot";
    mNameType [POINT_REACT] = "React";
    mNameType [POINT_LEFT ] = "⭠ ";
    mNameType [POINT_RIGHT] = "⭢ ";
    mNameType [POINT_TOP  ] = "↓";

    leftRighTopDownPos[POINT_LEFT-POINT_LEFT] = ANCHOR_LEFT;
    leftRighTopDownPos[POINT_RIGHT-POINT_LEFT] = ANCHOR_RIGHT;
    leftRighTopDownPos[POINT_TOP-POINT_LEFT] = ANCHOR_LOWER;

    mIndexType = 0;
    mTypeNum = POINT_NUM;
    for (int i = 0; i < mTypeNum; i++)
    {
        mTemplateTypes += mNameType[i];
        if (i < mTypeNum-1) mTemplateTypes += ",";
    }
}

// Internal Event
void Pivot::prepareActive(){}
void Pivot::createItem()
{
    ObjectCreate(cPivot, OBJ_TEXT , 0, 0, 0);
    ObjectCreate(sType, OBJ_TEXT , 0, 0, 0);
    updateDefaultProperty();
    updateTypeProperty();
    time  = pCommonData.mMouseTime;
    price = pCommonData.mMousePrice;
    refreshData();
}
void Pivot::updateDefaultProperty()
{
}
void Pivot::updateTypeProperty()
{
    ObjectSetText(sType, IntegerToString(mIndexType));
    if (mIndexType == POINT_LEFT || mIndexType == POINT_RIGHT || mIndexType == POINT_TOP)
    {
        ObjectSetText(cPivot, mNameType[mIndexType], 10, NULL, clrNavy);
        ObjectSetInteger(ChartID(), cPivot, OBJPROP_ANCHOR, leftRighTopDownPos[mIndexType - POINT_LEFT]);
    }
}
void Pivot::activateItem(const string& itemId)
{
    cPivot = itemId + "_cPivot";
    sType = itemId + "_sType";
}
void Pivot::updateItemAfterChangeType(){}
void Pivot::refreshData()
{
    if (mIndexType == POINT_PIVOT || mIndexType == POINT_REACT)
    {
        int shift = iBarShift(ChartSymbol(), ChartPeriod(), time);
        bool isUp = (price >= High[shift]);
        ObjectSet(cPivot, OBJPROP_COLOR, isUp ? clrRed : clrGreen);
        ObjectSetInteger(ChartID(), cPivot, OBJPROP_ANCHOR, isUp ? ANCHOR_LOWER : ANCHOR_UPPER);
        if (mIndexType == POINT_PIVOT)
        {
            ObjectSetText(cPivot, " ● ");
        } else if (mIndexType == POINT_REACT)
        {
            // ObjectSetText(cPivot, isUp ? "▼" : "▲");
            ObjectSetText(cPivot, isUp ? " ⭣ " : " ⭡ ");
        }
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
    gTemplates.clearTemplates();
    mIndexType = StrToInteger(ObjectDescription(sType));
    time  = (datetime)ObjectGet(cPivot, OBJPROP_TIME1);
    price =           ObjectGet(cPivot, OBJPROP_PRICE1);

    if (pCommonData.mCtrlHold)
    {
        price = pCommonData.mMousePrice;
    }
    refreshData();
}
void Pivot::onItemClick(const string &itemId, const string &objId)
{
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    multiSetProp(OBJPROP_SELECTED   , selected, cPivot+sType);
    if (selected)
    {
        gTemplates.openTemplates(objId, mTemplateTypes, StrToInteger(ObjectDescription(sType)));
    }
}
void Pivot::onItemChange(const string &itemId, const string &objId){}
void Pivot::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cPivot);
    ObjectDelete(sType);
}
void Pivot::onUserRequest(const string &itemId, const string &objId)
{
    activateItem(itemId);
    mIndexType = gTemplates.mActivePos;
    updateTypeProperty();
    onItemDrag(itemId, objId);
}