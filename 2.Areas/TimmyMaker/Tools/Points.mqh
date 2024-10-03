#include "../Base/BaseItem.mqh"

enum eAnchor{
    eAchCenter,
    eAchHiLoBar,
};

input string     Point_; // ●  P O I N T  ●
input string     Point_1______Name  = "Swing";       // → Point 1:
input int        Point_1_Size       = 25;            // Size
input color      Point_1_Color      = clrMidnightBlue; // Color
      string     Point_1_Charecter  = "¡";           // Charecter
      string     Point_1_Font       = "wingdings";   // Font
      eAnchor    Point_1_Anchor     = eAchCenter;
input string     Point_2______Name  = "Sub";         // → Point 2:
input int        Point_2_Size       = 20;            // Size
input color      Point_2_Color      = clrDimGray;  // Color
      string     Point_2_Charecter  = "¡";           // Charecter
      string     Point_2_Font       = "wingdings";   // Font
      eAnchor    Point_2_Anchor     = eAchCenter;

#define CTX_IncSize "+Size"
#define CTX_DecSize "-Size"

enum PointType
{
    POINT_1,
    POINT_2,
    POINT_NUM,
};

class Point : public BaseItem
{
// Internal Value
private:
    color   mColor    [CTX_MAX];
    string  mSymbol   [CTX_MAX];
    string  mSymbol2  [CTX_MAX];
    int     mSize     [CTX_MAX];
    string  mFont     [CTX_MAX];
    eAnchor mAnchor   [CTX_MAX];

// Component name
private:
    string cPtM0;

// Value define for Item
private:
    datetime time;
    double   price;

public:
    Point(CommonData* commonData, MouseInfo* mouseInfo);

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
    virtual void onUserRequest2(const string &itemId, const string &objId);

public:
    static string getAllItem(string itemId);
    static string Tag;
};

static string Point::Tag = ".TMPoint";

Point::Point(CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = Point::Tag;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [POINT_1] = Point_1______Name;
    mColor    [POINT_1] = Point_1_Color  ;
    mSymbol   [POINT_1] = getSubStr(Point_1_Charecter, 0, 1);
    mSymbol2  [POINT_1] = getSubStr(Point_1_Charecter, 1, 1);
    mSize     [POINT_1] = Point_1_Size     ;
    mFont     [POINT_1] = Point_1_Font     ;
    mAnchor   [POINT_1] = Point_1_Anchor;
    mNameType [POINT_2] = Point_2______Name;
    mColor    [POINT_2] = Point_2_Color  ;
    mSymbol   [POINT_2] = getSubStr(Point_2_Charecter, 0, 1);
    mSymbol2  [POINT_2] = getSubStr(Point_2_Charecter, 1, 1);
    mSize     [POINT_2] = Point_2_Size     ;
    mFont     [POINT_2] = Point_2_Font     ;
    mAnchor   [POINT_2] = Point_2_Anchor;

    mIndexType = 0;
    mTypeNum = POINT_NUM;
    for (int i = 0; i < mTypeNum; i++)
    {
        mContextType += mNameType[i];
        if (i < mTypeNum-1) mContextType += ",";
    }
    mContextType += "," + CTX_IncSize;
    mContextType += "," + CTX_DecSize;
}

// Internal Event
void Point::prepareActive(){}
void Point::createItem()
{
    ObjectCreate(cPtM0, OBJ_TEXT , 0, 0, 0);
    updateDefaultProperty();
    updateTypeProperty();
    time  = pCommonData.mMouseTime;
    price = pCommonData.mMousePrice;
    refreshData();
}
void Point::updateDefaultProperty()
{
    ObjectSet(cPtM0, OBJPROP_BACK , false);
    setMultiStrs(OBJPROP_TOOLTIP, "\n", mAllItem);
}
void Point::updateTypeProperty()
{
    setTextContent(cPtM0, mSymbol[mIndexType], mSize[mIndexType], mFont[mIndexType], mColor[mIndexType]);
}
void Point::activateItem(const string& itemId)
{
    cPtM0 = itemId + TAG_CTRM + "cPtM0";
    mAllItem += cPtM0;
}
string Point::getAllItem(string itemId)
{
    string allItem = itemId + "_mTData";
    allItem += itemId + TAG_CTRM + "cPtM0";

    return allItem;
}
void Point::updateItemAfterChangeType(){}
void Point::refreshData()
{
    ObjectSet(cPtM0, OBJPROP_ANCHOR, ANCHOR_CENTER);
    ObjectSetString(0, cPtM0, OBJPROP_TOOLTIP, DoubleToString(price, 5));
    setItemPos(cPtM0, time, price);
    bool isUp = (price >= High[iBarShift(ChartSymbol(), ChartPeriod(), time)]);
    setTextContent(cPtM0, isUp ? mSymbol[mIndexType] : mSymbol2[mIndexType]);
    if (mAnchor[mIndexType] == eAchCenter) {
        ObjectSet(cPtM0, OBJPROP_ANCHOR, ANCHOR_CENTER);
    }
    else if (mAnchor[mIndexType] == eAchHiLoBar) {
        ObjectSet(cPtM0, OBJPROP_ANCHOR, isUp ? ANCHOR_LOWER : ANCHOR_UPPER);
    }
    int selected = (int)ObjectGet(cPtM0, OBJPROP_SELECTED);
    if (selected) gContextMenu.openStaticCtxMenu(cPtM0, mContextType);
    else gContextMenu.clearStaticCtxMenu(cPtM0);
}
void Point::finishedJobDone(){}

// Chart Event
void Point::onMouseMove()
{
    MOUSE_MOVE_RETURN_CHECK
}
void Point::onMouseClick()
{
    createItem();
    mFinishedJobCb();
}
void Point::onItemDrag(const string &itemId, const string &objId)
{
    gContextMenu.clearContextMenu();
    time  = (datetime)ObjectGet(cPtM0, OBJPROP_TIME1);
    price =           ObjectGet(cPtM0, OBJPROP_PRICE1);

    if (pCommonData.mCtrlHold)
    {
        price = pCommonData.mMousePrice;
    }
    refreshData();
}
void Point::onItemClick(const string &itemId, const string &objId)
{
    // if (StringFind(objId, TAG_CTRL) < 0) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    if (selected && pCommonData.mShiftHold) gContextMenu.openContextMenu(cPtM0, mContextType, mIndexType);
    // setCtrlItemSelectState(mAllItem, selected);
    if (selected) gContextMenu.openStaticCtxMenu(cPtM0, mContextType);
    else gContextMenu.clearStaticCtxMenu(cPtM0);
}
void Point::onItemChange(const string &itemId, const string &objId){}
void Point::onUserRequest2(const string &itemId, const string &objId)
{
    if (gContextMenu.mActiveItemStr == CTX_IncSize) {
        ObjectSet(cPtM0, OBJPROP_FONTSIZE, ObjectGet(cPtM0, OBJPROP_FONTSIZE)+5);
    }
    else if (gContextMenu.mActiveItemStr == CTX_DecSize) {
        ObjectSet(cPtM0, OBJPROP_FONTSIZE, ObjectGet(cPtM0, OBJPROP_FONTSIZE)-5);
    }
}