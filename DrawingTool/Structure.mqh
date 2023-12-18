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

enum StructureType
{
    HILO_POINT,
    IMB_AREA,
    IMB_NUM,
};

class Structure : public BaseItem
{
// Internal Value
private:

// Component name
private:
    string cMBox;
    string iHLPnt;
    string iImbPnt;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double   price1;
    double   price2;
    
public:
    Structure(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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

Structure::Structure(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;
    mIndexType = 0;
    mNameType[HILO_POINT] = "HiLo Point";
    mNameType[IMB_AREA]   = "Imbalance";
    mTypeNum = IMB_NUM;
    for (int i = 0; i < mTypeNum; i++)
    {
        mTemplateTypes += mNameType[i];
        if (i < mTypeNum-1) mTemplateTypes += ",";
    }
}

// Internal Event
void Structure::prepareActive(){}

void Structure::activateItem(const string& itemId)
{
    iHLPnt  = itemId + "_iHLPnt";
    iImbPnt = itemId + "_iImbPnt";
    cMBox   = itemId + "_c0MBox";
}

void Structure::refreshData()
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
    // HiLo Point Value
    double preH   = High[startIdx+1];
    double preL   = Low[startIdx+1];
    datetime preT = Time[startIdx+1];
    bool isInsideBar = false;
    int preDir = 0;
    int curDir = 0;
    datetime hlPntTime;
    double   hlPntPrice;
    int hiLoIdx = 0;
    // Imbalance Value
    bool hasImbUp = false;
    bool hasImbDown = false;
    double p1 = 0;
    double p2 = 0;
    int imbIdx = 0;
    for (int i = startIdx; i >= endIdx && i > 0; i--)
    {
        if (price1 < High[i]) price1 = High[i];
        if (price2 > Low [i]) price2 = Low[i];
        // HiLo Point Code
        if (mIndexType == HILO_POINT){
            isInsideBar = false;
            if      (High[i] >  preH && Low[i] >= preL) curDir = BULLISH;
            else if (High[i] <= preH && Low[i] <  preL) curDir = BEARISH;
            else if (High[i] >  preH && Low[i] <  preL){ // Outside bar correction
                curDir = curDir * REVERT;
            }
            else isInsideBar = true;

            if (preDir != curDir && preDir != 0) {
                objName = iHLPnt + "#" + IntegerToString(hiLoIdx);
                hlPntPrice = (curDir == BULLISH ? (Low[i] > preL ? preL : Low[i] ) : (High[i] < preH ? preH : High[i]));
                hlPntTime  = (curDir == BULLISH ? (Low[i] > preL ? preT : Time[i]) : (High[i] < preH ? preT : Time[i]));
                ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
                // ObjectSetText(objName, "●", 4);
                ObjectSetText(objName, curDir == BEARISH ? "▼" : "▲", 5);
                setItemPos(objName, hlPntTime, hlPntPrice);
                ObjectSet(objName, OBJPROP_SELECTABLE, false);
                ObjectSet(objName, OBJPROP_COLOR, curDir == BEARISH ? clrRed : clrGreen);
                ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
                ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR, curDir == BEARISH ? ANCHOR_LOWER : ANCHOR_UPPER);
                hiLoIdx++;
            }
            preDir = curDir;

            if (isInsideBar == false) {
                preH = High[i];
                preL = Low[i];
                preT = Time[i];
            }
        }
        else if (mIndexType == IMB_AREA){
            //
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
                objName = iImbPnt + "#" + IntegerToString(imbIdx);
                ObjectCreate(objName, OBJ_RECTANGLE , 0, 0, 0);
                ObjectSet(objName   , OBJPROP_SELECTABLE, false);
                setItemPos(objName, Time[i], Time[i-1], p1, p2);
                ObjectSetString(ChartID(), objName, OBJPROP_TOOLTIP, "\n");
                SetRectangleBackground(objName, hasImbUp ? clrGreen : clrRed);
                imbIdx++;
            }
        }
    }
    // Remove item thừa
    do {// for hiLo
        objName  = iHLPnt + "#" + IntegerToString(hiLoIdx);
        hiLoIdx++;
    }
    while (ObjectDelete(objName) == true);
    
    do {// for Imb
        objName  = iImbPnt + "#" + IntegerToString(imbIdx);
        imbIdx++;
    }
    while (ObjectDelete(objName) == true);

    setItemPos(cMBox, time1, time2, price1, price2);
}

void Structure::createItem()
{
    ObjectCreate(cMBox, OBJ_RECTANGLE , 0, 0, 0);

    updateDefaultProperty();
    updateTypeProperty();
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void Structure::updateDefaultProperty(){}
void Structure::updateTypeProperty()
{
    SetObjectStyle(cMBox, clrGreen, 2, 1);
    ObjectSetString(ChartID(), cMBox, OBJPROP_TOOLTIP, "\n");
}
void Structure::updateItemAfterChangeType()
{
    if (mFirstPoint == true)
    {
        updateTypeProperty();
        refreshData();
    }
}

//Chart Event
void Structure::onItemDrag(const string &itemId, const string &objId)
{
    time1 = (datetime)ObjectGet(cMBox, OBJPROP_TIME1);
    time2 = (datetime)ObjectGet(cMBox, OBJPROP_TIME2);

    refreshData();
}
void Structure::onItemClick(const string &itemId, const string &objId){}
void Structure::onItemChange(const string &itemId, const string &objId)
{
}
void Structure::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void Structure::onMouseMove()
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
void Structure::onItemDeleted(const string &itemId, const string &objId)
{
    // Remove old HiLo Point draw
    int idx = 0;
    string hiLoItemName = "";
    string imbItemName = "";
    do
    {
        hiLoItemName = iHLPnt + "#" + IntegerToString(idx);
        imbItemName  = iImbPnt + "#" + IntegerToString(idx);
        idx++;
    }
    while (ObjectDelete(hiLoItemName) == true || ObjectDelete(imbItemName) == true);
}

void Structure::updateCandle()
{
    string sparamItems[];
    for (int i = ObjectsTotal() - 1; i >= 0; i--)
    {
        string objName = ObjectName(i);
        if (StringFind(objName, "c0MBox") == -1)
        {
            continue;
        }
        int k=StringSplit(objName,'_',sparamItems);
        if (k != 3 || sparamItems[0] != mItemName)
        {
            continue;
        }
        string objId = sparamItems[0] + "_" + sparamItems[1];
        touchItem(objId);
        onItemDrag(objId, objName);
    }
}