#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string     Point_; //● Point ●
input string     Point_1______Name  = "Swing Point"; // → Point 1:
input string     Point_1_Charecter  = "n";           // Charecter
input string     Point_1_Font       = "webdings";    // Font
input int        Point_1_Size       = 10;            // Size
input color      Point_1_Color      = clrThistle;    // Color

enum PointType
{
    POINT_1,
    // POINT_2,
    // POINT_3,
    // POINT_4,
    POINT_NUM,
};

class Point : public BaseItem
{
// Internal Value
private:
    color  mColor    [MAX_TYPE];
    string mCharecter[MAX_TYPE];
    int    mSize     [MAX_TYPE];
    string mFont     [MAX_TYPE];

// Component name
private:
    string cPoint;

// Value define for Item
private:
    datetime time;
    double   price;

public:
    Point(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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
};

Point::Point(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [POINT_1] = Point_1______Name;
    mColor    [POINT_1] = Point_1_Color  ;
    mCharecter[POINT_1] = Point_1_Charecter;
    mSize     [POINT_1] = Point_1_Size     ;
    mFont     [POINT_1] = Point_1_Font     ;

    mIndexType = 0;
    mTypeNum = POINT_NUM;
    for (int i = 0; i < mTypeNum; i++)
    {
        mTemplateTypes += mNameType[i];
        if (i < mTypeNum-1) mTemplateTypes += ",";
    }
}

// Internal Event
void Point::prepareActive(){}
void Point::createItem()
{
    ObjectCreate(cPoint, OBJ_TEXT , 0, 0, 0);
    updateDefaultProperty();
    updateTypeProperty();
    time  = pCommonData.mMouseTime;
    price = pCommonData.mMousePrice;
    refreshData();
}
void Point::updateDefaultProperty()
{
    ObjectSet(cPoint, OBJPROP_BACK , true);
}
void Point::updateTypeProperty()
{
    ObjectSetText(cPoint, mCharecter[mIndexType], mSize[mIndexType], mFont[mIndexType], mColor[mIndexType]);
}
void Point::activateItem(const string& itemId)
{
    cPoint = itemId + "_cmPoint";
    mAllItem += cPoint;
}
void Point::updateItemAfterChangeType(){}
void Point::refreshData()
{
    int shift = iBarShift(ChartSymbol(), ChartPeriod(), time);
    bool isUp = (price >= High[shift]);
    // ObjectSet(cPoint, OBJPROP_COLOR, mColor[mIndexType]);
    // ObjectSetInteger(ChartID(), cPoint, OBJPROP_ANCHOR, isUp ? ANCHOR_LOWER : ANCHOR_UPPER);
    ObjectSetInteger(ChartID(), cPoint, OBJPROP_ANCHOR, ANCHOR_CENTER);
    ObjectSetString(ChartID(), cPoint, OBJPROP_TOOLTIP, DoubleToString(price, 5));
    setItemPos(cPoint, time, price);
}
void Point::finishedJobDone(){}

// Chart Event
void Point::onMouseMove()
{
    price= pCommonData.mMousePrice;
    time = pCommonData.mMouseTime;
    refreshData();
}
void Point::onMouseClick()
{
    createItem();
    mFinishedJobCb();
}
void Point::onItemDrag(const string &itemId, const string &objId)
{
    gTemplates.clearTemplates();
    time  = (datetime)ObjectGet(cPoint, OBJPROP_TIME1);
    price =           ObjectGet(cPoint, OBJPROP_PRICE1);

    if (pCommonData.mCtrlHold)
    {
        price = pCommonData.mMousePrice;
    }
    refreshData();
}
void Point::onItemClick(const string &itemId, const string &objId)
{
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    multiSetProp(OBJPROP_SELECTED   , selected, mAllItem);
    if (selected && pCommonData.mShiftHold){
        gTemplates.openTemplates(objId, mTemplateTypes, mIndexType);
    }
}
void Point::onItemChange(const string &itemId, const string &objId){}
