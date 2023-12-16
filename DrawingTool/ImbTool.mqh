#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

//--------------------------------------------
input string            _4 = "";
input color      Imb_Color = clrMidnightBlue;
input LINE_STYLE Imb_MainLine0_Style = STYLE_DOT;
input LINE_STYLE Imb_RangeLine_Style = STYLE_SOLID;


#define BULLISH 1
#define BEARISH -1
#define REVERT  -1

enum ImbToolType
{
    STRUCTURE_POINT,
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
    string cMBox;
    string iIbmPnt;
    string iHLPnt;

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

// Special functional
    void updateCandle();
};

ImbTool::ImbTool(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;
    mIndexType = 0;
    mNameType[STRUCTURE_POINT] = "Structure Point";
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
    iHLPnt  = itemId + "_iHLPnt";
    cMBox   = itemId + "_c0MBox";
}

void ImbTool::refreshData()
{
    string objName = "";
    int startIdx = iBarShift(ChartSymbol(), ChartPeriod(), time1);
    int endIdx   = iBarShift(ChartSymbol(), ChartPeriod(), time2);

    if (startIdx < endIdx) {
        startIdx = startIdx +endIdx;
        endIdx   = startIdx - endIdx;
        startIdx = startIdx - endIdx;
    }
    // Some value
    price1 = High[startIdx+1];
    price2 = Low[startIdx+1];
    //
    double preH   = High[startIdx+1];
    double preL   = Low[startIdx+1];
    datetime preT = Time[startIdx+1];
    bool isInsideBar = false;
    bool itOutsideBarCorrectionContinuation = false;
    int preDir = 0;
    int curDir = 0;
    // value for drawing
    int pointIdx = 0;
    datetime hlPntTime;
    double   hlPntPrice;
    for (int i = startIdx; i >= endIdx && i > 0; i--)
    {
        if (price1 < High[i]) price1 = High[i];
        if (price2 > Low [i]) price2 = Low[i];
        // Detect type
        isInsideBar = false;
        itOutsideBarCorrectionContinuation = false;
        if      (High[i] >  preH && Low[i] >= preL) curDir = BULLISH;
        else if (High[i] <= preH && Low[i] <  preL) curDir = BEARISH;
        else if (High[i] >  preH && Low[i] <  preL){ // Outside bar correction
            curDir = curDir * REVERT;
            //if (curDir == BEARISH && Close[i] > Open[i]) itOutsideBarCorrectionContinuation = true;
            //else if (curDir == BULLISH && Open[i] > Close[i]) itOutsideBarCorrectionContinuation = true;
        }
        else isInsideBar = true;

        if (preDir != curDir && preDir != 0) {
            objName = iHLPnt + "#" + IntegerToString(pointIdx);
            if (itOutsideBarCorrectionContinuation == false) {
                if (curDir == BULLISH) {
                    if (Low[i] > preL) {
                        hlPntPrice = preL;
                        hlPntTime  = preT;
                    } else {
                        hlPntPrice = Low[i];
                        hlPntTime  = Time[i];
                    }
                } else {
                    if (High[i] < preH) {
                        hlPntPrice = preH;
                        hlPntTime  = preT;
                    } else {
                        hlPntPrice = High[i];
                        hlPntTime  = Time[i];
                    }
                }
            } else {
                if (curDir == BULLISH) {
                    hlPntPrice = preL;
                    hlPntTime  = preT;
                } else {
                    hlPntPrice = preH;
                    hlPntTime  = preT;
                }
            }
            ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
            // ObjectSetText(objName, "●", 5);
            ObjectSetText(objName, curDir == BEARISH ? "▼" : "▲", 5);
            setItemPos(objName, hlPntTime, hlPntPrice);
            ObjectSet(objName, OBJPROP_SELECTABLE, false);
            ObjectSet(objName, OBJPROP_COLOR, curDir == BEARISH ? clrRed : clrGreen);
            ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR, curDir == BEARISH ? ANCHOR_LOWER : ANCHOR_UPPER);
            pointIdx++;
        }
        preDir = curDir;

        if (isInsideBar == false) {
            preH = High[i];
            preL = Low[i];
            preT = Time[i];
        }
    }
    // Remove item thừa
    do
    {
        objName = iHLPnt + "#" + IntegerToString(pointIdx);
        pointIdx++;
    }
    while (ObjectDelete(objName) == true);

    setItemPos(cMBox, time1, time2, price1, price2);
}

void ImbTool::createItem()
{
    ObjectCreate(cMBox, OBJ_RECTANGLE , 0, 0, 0);

    updateDefaultProperty();
    updateTypeProperty();
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void ImbTool::updateDefaultProperty()
{
    multiSetStrs(OBJPROP_TOOLTIP   , "\n", cPoint1+cPoint2);
}
void ImbTool::updateTypeProperty()
{
    SetObjectStyle(cMBox, clrGreen, 2, 1);
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
    time1 = (datetime)ObjectGet(cMBox, OBJPROP_TIME1);
    time2 = (datetime)ObjectGet(cMBox, OBJPROP_TIME2);

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
        objName = iHLPnt + "#" + IntegerToString(idx);
        idx++;
    }
    while (ObjectDelete(objName) == true);
}

void ImbTool::updateCandle()
{
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