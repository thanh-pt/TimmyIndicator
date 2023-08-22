#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

//--------------------------------------------
input color      __Imb_Color = clrMidnightBlue;
input LINE_STYLE __Imb_Style = STYLE_DOT;
      int        __Imb_Width = 1;


class ImbTool : public BaseItem
{
// Internal Value
private:

// Component name
private:
    string cPoint1;
    string cPoint2;
    string cMLine0;
    string iIbmPnt;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double price1;
    double price2;

public:
    ImbTool(const string name, CommonData* commonData, MouseInfo* mouseInfo);

// Internal Event
public:
    virtual void activateItem(const string& itemId);
    virtual void refreshData();
    virtual void createItem();
    virtual void updateDefaultProperty();
    virtual void updateTypeProperty();
    virtual void prepareActive();
    virtual void updateItemAfterChangeType();

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

ImbTool::ImbTool(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;
    mIndexType = 0;
}

// Internal Event
void ImbTool::prepareActive(){}

void ImbTool::activateItem(const string& itemId)
{
    cPoint1 = itemId + "_c2Point1";
    cPoint2 = itemId + "_c2Point2";
    cMLine0 = itemId + "_c0MLine0";
    iIbmPnt = itemId + "_iIbmPnt";
}

void ImbTool::refreshData()
{
    setItemPos(cMLine0, time1, time2, price1, price2);
    setItemPos(cPoint1, time1, price1);
    setItemPos(cPoint2, time2, price2);

    bool isUp = false;
    if (price1 > price2)
    {
        ObjectSet(cPoint1, OBJPROP_COLOR, clrRed);
        ObjectSet(cPoint2, OBJPROP_COLOR, clrGreen);
    } else
    {
        isUp = true;
        ObjectSet(cPoint1, OBJPROP_COLOR, clrGreen);
        ObjectSet(cPoint2, OBJPROP_COLOR, clrRed);
    }

    // Remove old IMB draw
    int idx = 0;
    string objName = "";
    do
    {
        objName = iIbmPnt + "#" + IntegerToString(idx);
        idx++;
    }
    while (ObjectDelete(objName) == true);
    // Scan and replace new IMB
    idx = 0;
    int startIdx = iBarShift(ChartSymbol(), ChartPeriod(), time1);
    int endIdx   = iBarShift(ChartSymbol(), ChartPeriod(), time2);

    bool hasImb = false;
    double centerPrice = 0;
    double p1 = 0;
    double p2 = 0;
    for (int i = startIdx+1; i >= endIdx+2; i--)
    {

        if (isUp)
        {
            hasImb = (High[i] < Low[i-2]);
            centerPrice = (High[i]+Low[i-2])/2;
            p1 = High[i];
            p2 = Low[i-2];
        }
        else
        {
            hasImb = (Low[i] > High[i-2]);
            centerPrice = (Low[i]+High[i-2])/2;
            p1 = Low[i];
            p2 = High[i-2];
        }

        if (hasImb)
        {
            objName = iIbmPnt + "#" + IntegerToString(idx);
            // Ver1: Arrow
            // ObjectCreate(objName, OBJ_ARROW , 0, 0, 0);
            // ObjectSet(objName, OBJPROP_ARROWCODE, 3);
            // ObjectSet(objName, OBJPROP_WIDTH    , 0);
            // ObjectSet(objName, OBJPROP_COLOR    , isUp ? clrGreen : clrRed);
            // setItemPos(objName, Time[i-1], centerPrice);
            // Ver2: Rect
            ObjectCreate(objName, OBJ_RECTANGLE , 0, 0, 0);
            ObjectSet(objName   , OBJPROP_SELECTABLE, false);
            setItemPos(objName, Time[i-1], Time[i-2], p1, p2);
            SetRectangleBackground(objName, isUp ? clrGreen : clrRed);
            ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
            idx++;
        }
    }

}

void ImbTool::createItem()
{
    ObjectCreate(cMLine0, OBJ_TREND , 0, 0, 0);
    ObjectCreate(cPoint1, OBJ_TEXT  , 0, 0, 0);
    ObjectCreate(cPoint2, OBJ_TEXT  , 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void ImbTool::updateDefaultProperty()
{
    ObjectSetText (cPoint1,"●", 9, "Consolas", clrGreen);
    ObjectSetText (cPoint2,"●", 9, "Consolas", clrRed);
    ObjectSetInteger(ChartID(), cPoint1, OBJPROP_ANCHOR, ANCHOR_CENTER);
    ObjectSetInteger(ChartID(), cPoint2, OBJPROP_ANCHOR, ANCHOR_CENTER);
    ObjectSet(cMLine0, OBJPROP_RAY  , false);
    ObjectSet(cMLine0, OBJPROP_BACK , true);
    multiSetStrs(OBJPROP_TOOLTIP   , "\n", cPoint1+cPoint2+cMLine0);
}
void ImbTool::updateTypeProperty()
{
    SetObjectStyle(cMLine0, __Imb_Color, __Imb_Style,  __Imb_Width);
}
void ImbTool::updateItemAfterChangeType()
{
    if (mFirstPoint == true)
    {
        updateTypeProperty();
        refreshData();
    }
}

//Chart Event
void ImbTool::onItemDrag(const string &itemId, const string &objId)
{
    time1 = (datetime)ObjectGet(cMLine0, OBJPROP_TIME1);
    time2 = (datetime)ObjectGet(cMLine0, OBJPROP_TIME2);
    price1 =          ObjectGet(cMLine0, OBJPROP_PRICE1);
    price2 =          ObjectGet(cMLine0, OBJPROP_PRICE2);
    
    if (objId == cPoint1)
    {
        time1 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
        if (pCommonData.mShiftHold)
        {
            price1 = price2;
        }
        else if (pCommonData.mCtrlHold)
        {
            price1 = pCommonData.mMousePrice;
        }
        else
        {
            price1 = ObjectGet(objId, OBJPROP_PRICE1);
        }
    }
    else if (objId == cPoint2)
    {
        time2 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
        if (pCommonData.mShiftHold)
        {
            price2 = price1;
        }
        else if (pCommonData.mCtrlHold)
        {
            price2 = pCommonData.mMousePrice;
        }
        else
        {
            price2 = ObjectGet(objId, OBJPROP_PRICE1);
        }
    }

    refreshData();
}
void ImbTool::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, "_c") == -1) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    multiSetProp(OBJPROP_SELECTED, selected, cPoint1+cPoint2+cMLine0);
}
void ImbTool::onItemChange(const string &itemId, const string &objId)
{
}
void ImbTool::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void ImbTool::onMouseMove()
{
    if (mFirstPoint == false) return;
    if (pCommonData.mShiftHold)
    {
        price2 = price1;
    }
    else
    {
        price2 = pCommonData.mMousePrice;
    }
    time2  = pCommonData.mMouseTime;
    refreshData();
}
void ImbTool::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cPoint1);
    ObjectDelete(cPoint2);
    ObjectDelete(cMLine0);
    // Remove old IMB draw
    int idx = 0;
    string objName = "";
    do
    {
        objName = iIbmPnt + "#" + IntegerToString(idx);
        idx++;
    }
    while (ObjectDelete(objName) == true);
}
void ImbTool::onUserRequest(const string &itemId, const string &objId)
{
}