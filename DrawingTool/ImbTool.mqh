#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

//--------------------------------------------
input color      __Imb_Color = clrMidnightBlue;
input LINE_STYLE __Imb_MainLine0_Style = STYLE_DOT;
input LINE_STYLE __Imb_RangeLine_Style = STYLE_SOLID;

enum ImbToolType
{
    IMB_TOOL,
    IMB_NUM,
};

class ImbTool : public BaseItem
{
// Internal Value
private:

// Component name
private:
    string cPoint1;
    string cPoint2;
    string cMTrend;
    string iIbmPnt;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double   price1;
    double   price2;

    long     mChartScale;
    

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

// Special functional
    void updateCandle();
};

ImbTool::ImbTool(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;
    mIndexType = 0;
    mNameType[IMB_TOOL] = "Imb Tool";
    mTypeNum = IMB_NUM;
    // for (int i = 0; i < mTypeNum; i++)
    // {
    //     mTemplateTypes += mNameType[i];
    //     if (i < mTypeNum-1) mTemplateTypes += ",";
    // }
}

// Internal Event
void ImbTool::prepareActive(){}

void ImbTool::activateItem(const string& itemId)
{
    cPoint1 = itemId + "_c2Point1";
    cPoint2 = itemId + "_c2Point2";
    cMTrend = itemId + "_c0ImBMTrend";
    iIbmPnt = itemId + "_iIbmPnt";
}

void ImbTool::refreshData()
{
    setItemPos(cMTrend, time1, time2, price1, price2);
    setItemPos(cPoint1, time1, price1);
    setItemPos(cPoint2, time2, price2);

    int idx = 0;
    string objName = "";
    int startIdx = iBarShift(ChartSymbol(), ChartPeriod(), time1);
    int endIdx   = iBarShift(ChartSymbol(), ChartPeriod(), time2);

    if (startIdx < endIdx)
    {
        startIdx = startIdx +endIdx;
        endIdx = startIdx - endIdx;
        startIdx = startIdx - endIdx;
    }

    // IMB Tool
    /*
    bool hasImbUp = false;
    bool hasImbDown = false;
    double p1 = 0;
    double p2 = 0;
    for (int i = startIdx; i >= endIdx && i > 1; i--)
    {
        hasImbUp = false;
        hasImbDown = false;
        if (High[i+1] < Low[i-1])
        {
            hasImbUp = true;
            p1 = High[i+1];
            p2 = Low[i-1];
        } else if (Low[i+1] > High[i-1])
        {
            hasImbDown = true;
            p1 = Low[i+1];
            p2 = High[i-1];
        }

        if (hasImbUp || hasImbDown)
        {
            objName = iIbmPnt + "#" + IntegerToString(idx);
            ObjectCreate(objName, OBJ_RECTANGLE , 0, 0, 0);
            ObjectSet(objName   , OBJPROP_SELECTABLE, false);
            setItemPos(objName, Time[i], Time[i-1], p1, p2);
            SetRectangleBackground(objName, hasImbUp ? clrGreen : clrRed);
            ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
            idx++;
        }
    }
    */
    // Color
    color c = clrNONE;
    color incColor = clrYellowGreen;
    color decColor = clrSienna;
    color insideBarColor = clrWhite;
    // Chart Scale and BarSize
    int barSize = 3;
    if (mChartScale <= 2)
    {
        // set StartIdx = 0 to not do calculate logic
        startIdx = 0;
    }
    else if (mChartScale == 4)barSize = 9;
    else if (mChartScale == 5)barSize = 25;
    // Some value
    double preH = High[startIdx+1];
    double preL = Low[startIdx+1];
    bool isInsideBar = false;
    for (int i = startIdx; i >= endIdx && i > 0; i--)
    {
        // Detect type
        isInsideBar = false;
        if      (High[i] >  preH && Low[i] >= preL) c = incColor;
        else if (High[i] <= preH && Low[i] <  preL) c = decColor;
        else if (High[i] >  preH && Low[i] <  preL) c = (Open[i] > Close[i]) ? decColor : incColor; // outside bar
        else // inside
        {
            isInsideBar = true;
            if (ChartPeriod() == PERIOD_D1 && TimeDayOfWeek(Time[i]) == 0)
            {
                //Ignore Sunday
            }
            else
            {
                c = insideBarColor;
            }
        }
        if (isInsideBar == false)
        {
            preH = High[i];
            preL = Low[i];
        }
        if (c == clrNONE) continue;
        // bg draw:
        objName = iIbmPnt + "#" + IntegerToString(idx);
        ObjectCreate(objName, OBJ_TREND , 0, 0, 0);
        setItemPos(  objName, Time[i], Time[i], Open[i], Close[i]);
        ObjectSet(   objName, OBJPROP_SELECTABLE, false);
        ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
        SetObjectStyle(objName, clrBlack, 0, barSize+2);
        idx++;
        // body draw:
        objName = iIbmPnt + "#" + IntegerToString(idx);
        ObjectCreate(objName, OBJ_TREND , 0, 0, 0);
        setItemPos(  objName, Time[i], Time[i], Open[i], Close[i]);
        ObjectSet(   objName, OBJPROP_SELECTABLE, false);
        ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
        SetObjectStyle(objName, c, 0, barSize);
        idx++;
    }
    // Remove item thừa
    do
    {
        objName = iIbmPnt + "#" + IntegerToString(idx);
        idx++;
    }
    while (ObjectDelete(objName) == true);
}

void ImbTool::createItem()
{
    ObjectCreate(cMTrend, OBJ_TREND , 0, 0, 0);
    ObjectCreate(cPoint1, OBJ_TEXT  , 0, 0, 0);
    ObjectCreate(cPoint2, OBJ_TEXT  , 0, 0, 0);

    updateDefaultProperty();
    updateTypeProperty();
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void ImbTool::updateDefaultProperty()
{
    ObjectSetInteger(ChartID(), cPoint1, OBJPROP_ANCHOR, ANCHOR_CENTER);
    ObjectSetInteger(ChartID(), cPoint2, OBJPROP_ANCHOR, ANCHOR_CENTER);
    multiSetStrs(OBJPROP_TOOLTIP   , "\n", cPoint1+cPoint2+cMTrend);
    SetObjectStyle(cMTrend, __Imb_Color, __Imb_MainLine0_Style,  0);
    multiSetProp(OBJPROP_BACK, true, cMTrend);
}
void ImbTool::updateTypeProperty()
{
    ObjectSetText (cPoint1," ●A", 9, "Consolas", clrGreen);
    ObjectSetText (cPoint2," ●B", 9, "Consolas", clrRed);
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
    ChartGetInteger(ChartID(),CHART_SCALE,0,mChartScale);
    time1 = (datetime)ObjectGet(cMTrend, OBJPROP_TIME1);
    time2 = (datetime)ObjectGet(cMTrend, OBJPROP_TIME2);
    price1 =          ObjectGet(cMTrend, OBJPROP_PRICE1);
    price2 =          ObjectGet(cMTrend, OBJPROP_PRICE2);

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
    multiSetProp(OBJPROP_SELECTED, selected, cPoint1+cPoint2+cMTrend);
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
    ObjectDelete(cMTrend);
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
void ImbTool::updateCandle()
{
    // long chartScale;
    // ChartGetInteger(ChartID(),CHART_SCALE,0,chartScale);
    // if (chartScale == mChartScale) return;

    string sparamItems[];
    for (int i = ObjectsTotal() - 1; i >= 0; i--)
    {
        string objName = ObjectName(i);
        if (StringFind(objName, "ImBMTrend") == -1)
        {
            continue;
        }
        int k=StringSplit(objName,'_',sparamItems);
        if (k != 3 || sparamItems[0] != mItemName)
        {
            continue;
        }
        string objId = sparamItems[0] + "_" + sparamItems[1];
        activateItem(objId);
        onItemDrag(objId, objName);
    }
}