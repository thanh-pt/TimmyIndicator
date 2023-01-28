#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string          Trend_ = SEPARATE_LINE_BIG;
//--------------------------------------------
input color           Trend1_Color = clrWhite;
input int             Trend1_Width = 1;
input ENUM_LINE_STYLE Trend1_Style = 0;
input string          Trend1_sp    = SEPARATE_LINE;
input bool            Trend1_Arrow = false;
//--------------------------------------------
input color           Trend2_Color = clrRed;
input int             Trend2_Width = 1;
input ENUM_LINE_STYLE Trend2_Style = 2;
input bool            Trend2_Arrow = true;
//--------------------------------------------

class Trend : public BaseItem
{
// Internal Value
private:
    color mColorType[MAX_TYPE];
    int   mWidthType[MAX_TYPE];
    int   mStyleType[MAX_TYPE];
    int   mArrowDisp[MAX_TYPE];

// Component name
private:
    string cPoint1;
    string cPoint2;
    string cMTrend;
    string iAngle0;
    string cLbText;
    string iArrowT;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    datetime time3;
    double price1;
    double price2;
    double price3;
    double priceText;

public:
    Trend(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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
};

Trend::Trend(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    mNameType [0] = "Trend1";
    mColorType[0] = Trend1_Color;
    mWidthType[0] = Trend1_Width;
    mStyleType[0] = Trend1_Style;
    mArrowDisp[0] = Trend1_Arrow;
    //--------------------------------
    mNameType [1] = "Trend2";
    mColorType[1] = Trend2_Color;
    mWidthType[1] = Trend2_Width;
    mStyleType[1] = Trend2_Style;
    mArrowDisp[1] = Trend2_Arrow;

    mIndexType = 0;
    mTypeNum = 2;
}

// Internal Event
void Trend::prepareActive(){}

void Trend::activateItem(const string& itemId)
{
    cPoint1 = itemId + "_cPoint1";
    cPoint2 = itemId + "_cPoint2";
    cMTrend = itemId + "_cMTrend";
    iAngle0 = itemId + "_iAngle0";
    cLbText = itemId + "_cLbText";
    iArrowT = itemId + "_iArrowT";
}

void Trend::refreshData()
{
    if (ObjectFind(iAngle0) < 0)
    {
        // TODO: How to optimise this???
        ObjectCreate(iAngle0, OBJ_TRENDBYANGLE, 0, 0, 0);
        ObjectSet(iAngle0, OBJPROP_SELECTABLE, 0);
        ObjectSet(iAngle0, OBJPROP_COLOR,clrNONE);
        ObjectSetString(ChartID(), iAngle0,OBJPROP_TOOLTIP,"\n");
    }
    setItemPos(iAngle0, time1, time2, price1, price2);
    setTextPos(iArrowT, time2, price2);
    setItemPos(cPoint1, time1, price1);
    setItemPos(cPoint2, time2, price2);
    setItemPos(cMTrend, time1, time2, price1, price2);
    setTextPos(cLbText, time3, price3);

    double angle=ObjectGet(iAngle0, OBJPROP_ANGLE);
    ObjectSet(iArrowT, OBJPROP_ANGLE,  angle-90);
    if (angle > 90 && angle < 270) angle = angle+180;
    ObjectSet(cLbText, OBJPROP_ANGLE,  angle);
    if (priceText == price3)
    {
        return;
    }
    ObjectSetInteger(0, cLbText, OBJPROP_ANCHOR, (priceText > price3) ? ANCHOR_LOWER : ANCHOR_UPPER);
}

void Trend::createItem()
{
    ObjectCreate(iAngle0, OBJ_TRENDBYANGLE, 0, 0, 0);
    ObjectCreate(iArrowT, OBJ_TEXT        , 0, 0, 0);
    ObjectCreate(cMTrend, OBJ_TREND       , 0, 0, 0);
    ObjectCreate(cLbText, OBJ_TEXT        , 0, 0, 0);
    ObjectCreate(cPoint1, OBJ_ARROW       , 0, 0, 0);
    ObjectCreate(cPoint2, OBJ_ARROW       , 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void Trend::updateDefaultProperty()
{
    ObjectSet(cMTrend, OBJPROP_RAY      , false);
    ObjectSet(cPoint1, OBJPROP_ARROWCODE, 4);
    ObjectSet(cPoint2, OBJPROP_ARROWCODE, 4);

    ObjectSet(cPoint1, OBJPROP_WIDTH, 0);
    ObjectSet(cPoint2, OBJPROP_WIDTH, 0);
    ObjectSetText(cLbText, "");
    multiSetStrs(OBJPROP_TOOLTIP, "\n", cPoint1+cPoint2+cMTrend+iAngle0+cLbText+iArrowT);
    multiSetProp(OBJPROP_SELECTABLE, false, iArrowT+iAngle0);
    ObjectSet(iAngle0, OBJPROP_COLOR,clrNONE);

    ObjectSetInteger(ChartID(), iArrowT, OBJPROP_ANCHOR, ANCHOR_CENTER);
}
void Trend::updateTypeProperty()
{
    ObjectSet(cPoint1   , OBJPROP_COLOR, clrNONE);
    ObjectSet(cPoint2   , OBJPROP_COLOR, clrNONE);
    SetObjectStyle(cMTrend, mColorType[mIndexType], mStyleType[mIndexType], mWidthType[mIndexType]);
    ObjectSet(cLbText, OBJPROP_COLOR, mColorType[mIndexType]);
    ObjectSet(iArrowT, OBJPROP_COLOR, mColorType[mIndexType]);
    ObjectSetText(iArrowT, mArrowDisp[mIndexType] ? "▲" : "");
}
void Trend::updateItemAfterChangeType()
{
    if (mFirstPoint == true)
    {
        updateTypeProperty();
    }
}

//Chart Event
void Trend::onItemDrag(const string &itemId, const string &objId)
{
    time1 = (datetime)ObjectGet(cMTrend, OBJPROP_TIME1);
    time2 = (datetime)ObjectGet(cMTrend, OBJPROP_TIME2);
    price1 = ObjectGet(cMTrend, OBJPROP_PRICE1);
    price2 = ObjectGet(cMTrend, OBJPROP_PRICE2);
    
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

    getCenterPos(time1, time2, price1, price2, time3, price3);
    priceText = price3;

    if (objId == cLbText)
    {
        priceText = ObjectGet(cLbText, OBJPROP_PRICE1);
    }

    refreshData();
}
void Trend::onItemClick(const string &itemId, const string &objId)
{
    if (objId == iAngle0) return;
    if (objId == iArrowT) return;
    int objSelected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    ObjectSet(cPoint1 , OBJPROP_SELECTED, objSelected);
    ObjectSet(cPoint2 , OBJPROP_SELECTED, objSelected);
    ObjectSet(cMTrend , OBJPROP_SELECTED, objSelected);
    ObjectSet(cLbText , OBJPROP_SELECTED, objSelected);
    ObjectSet(iArrowT , OBJPROP_SELECTED, objSelected);
    // ObjectSet(iAngle0 , OBJPROP_SELECTED, objSelected);
}
void Trend::onItemChange(const string &itemId, const string &objId)
{
    if (objId == cMTrend)
    {
        color c = (color)ObjectGet(objId, OBJPROP_COLOR);
        ObjectSet(cMTrend, OBJPROP_COLOR, c);
        ObjectSet(cLbText, OBJPROP_COLOR, c);
        string lineDescription = ObjectDescription(cMTrend);
        if (lineDescription != "")
        {
            ObjectSetText(cLbText, lineDescription);
            ObjectSetText(cMTrend, "");
        }
        onItemDrag(itemId, objId);
    }
}
void Trend::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void Trend::onMouseMove()
{
    if (mFirstPoint == false)
    {
        return;
    }
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
void Trend::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cPoint1);
    ObjectDelete(cPoint2);
    ObjectDelete(cMTrend);
    ObjectDelete(cLbText);
    ObjectDelete(iAngle0);
    ObjectDelete(iArrowT);
}