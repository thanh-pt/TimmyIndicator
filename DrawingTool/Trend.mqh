#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"


//--------------------------------------------
      string     __T_Normal_Name  = "Normal";
      string     __T_Normal_Text  = "";
input color      __T_Normal_Color = clrMidnightBlue;
input LINE_STYLE __T_Normal_Style = STYLE_SOLID;
      int        __T_Normal_Width = 1;
      bool       __T_Normal_Arrow = false;
//--------------------------------------------
      string     __T_Lq_Name  = "Liquidity";
      string     __T_Lq_Text  = "$";
input color      __T_Lq_Color = clrBlack;
input LINE_STYLE __T_Lq_Style = STYLE_SOLID;
      int        __T_Lq_Width = 1;
      bool       __T_Lq_Arrow = false;
//--------------------------------------------
//       string     __T_LG_Name  = "Liquidation";
//       string     __T_LG_Text  = "";
// input color      __T_LG_Color = clrCrimson;
// input LINE_STYLE __T_LG_Style = STYLE_SOLID;
//       int        __T_LG_Width = 1;
//       bool       __T_LG_Arrow = true;
//--------------------------------------------
      string     __T_Mtg_Name  = "OrderFlow";
      string     __T_Mtg_Text  = "OF";
input color      __T_Mtg_Color = clrGreen;
input LINE_STYLE __T_Mtg_Style = STYLE_SOLID;
      int        __T_Mtg_Width = 1;
      bool       __T_Mtg_Arrow = true;
//--------------------------------------------

/*
TODO:
- Fix arrow <--
- auto text position
*/

enum TrendType
{
    TREND_NML,
    TREND_LQ,
    // TREND_LG,
    TREND_MTG,
    TREND_NUM,
};

class Trend : public BaseItem
{
// Internal Value
private:
    string mDispText [MAX_TYPE];
    color  mColorType[MAX_TYPE];
    int    mStyleType[MAX_TYPE];
    int    mWidthType[MAX_TYPE];
    bool   mShowArrow[MAX_TYPE];

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
    virtual void onUserRequest(const string &itemId, const string &objId);
};

Trend::Trend(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [TREND_NML  ] = __T_Normal_Name ;
    mDispText [TREND_NML  ] = __T_Normal_Text ;
    mColorType[TREND_NML  ] = __T_Normal_Color;
    mStyleType[TREND_NML  ] = __T_Normal_Style;
    mWidthType[TREND_NML  ] = __T_Normal_Width;
    mShowArrow[TREND_NML  ] = __T_Normal_Arrow;
    //--------------------------------------------
    mNameType [TREND_LQ   ] = __T_Lq_Name ;
    mDispText [TREND_LQ   ] = __T_Lq_Text ;
    mColorType[TREND_LQ   ] = __T_Lq_Color;
    mStyleType[TREND_LQ   ] = __T_Lq_Style;
    mWidthType[TREND_LQ   ] = __T_Lq_Width;
    mShowArrow[TREND_LQ   ] = __T_Lq_Arrow;
    //--------------------------------------------
    // mNameType [TREND_LG   ] = __T_LG_Name ;
    // mDispText [TREND_LG   ] = __T_LG_Text ;
    // mColorType[TREND_LG   ] = __T_LG_Color;
    // mStyleType[TREND_LG   ] = __T_LG_Style;
    // mWidthType[TREND_LG   ] = __T_LG_Width;
    // mShowArrow[TREND_LG   ] = __T_LG_Arrow;
    //--------------------------------------------
    mNameType [TREND_MTG  ] = __T_Mtg_Name ;
    mDispText [TREND_MTG  ] = __T_Mtg_Text ;
    mColorType[TREND_MTG  ] = __T_Mtg_Color;
    mStyleType[TREND_MTG  ] = __T_Mtg_Style;
    mWidthType[TREND_MTG  ] = __T_Mtg_Width;
    mShowArrow[TREND_MTG  ] = __T_Mtg_Arrow;
    //--------------------------------------------
    for (int i = 0; i < TREND_NUM; i++)
    {
        mTemplateTypes += mNameType[i];
        if (i < TREND_NUM-1) mTemplateTypes += ",";
    }
    mTypeNum = TREND_NUM;
    mIndexType = 0;
}

// Internal Event
void Trend::prepareActive(){}

void Trend::activateItem(const string& itemId)
{
    cPoint1 = itemId + "_c2Point1";
    cPoint2 = itemId + "_c2Point2";
    cMTrend = itemId + "_c1MTrend";
    cLbText = itemId + "_c0LbText";
    iAngle0 = itemId + "_0iAngle0";
    iArrowT = itemId + "_0iArrowT";
}

void Trend::refreshData()
{
    setItemPos(iAngle0, time1, time2, price1, price2);
    setItemPos(cMTrend, time1, time2, price1, price2);
    setItemPos(cPoint1, time1, price1);
    setItemPos(cPoint2, time2, price2);
    setTextPos(iArrowT, time2, price2);
    setTextPos(cLbText, time3, price3);

    double angle=ObjectGet(iAngle0, OBJPROP_ANGLE);
    ObjectSet(iArrowT, OBJPROP_ANGLE,  angle-90);
    if (angle > 90 && angle < 270) angle = angle+180;
    ObjectSet(cLbText, OBJPROP_ANGLE,  angle);
    if (priceText != price3)
    {
        ObjectSetInteger(0, cLbText, OBJPROP_ANCHOR, (priceText > price3) ? ANCHOR_LOWER : ANCHOR_UPPER);
    }
    else
    {
        int barT1 = iBarShift(ChartSymbol(), ChartPeriod(), time1);
        int barT2 = iBarShift(ChartSymbol(), ChartPeriod(), time2);
        if (price1 >= High[barT1] && price2 >= High[barT2])
        {
            ObjectSetInteger(0, cLbText, OBJPROP_ANCHOR, ANCHOR_LOWER);
        }
        else if (price1 <= Low[barT1] && price2 <= Low[barT2])
        {
            ObjectSetInteger(0, cLbText, OBJPROP_ANCHOR, ANCHOR_UPPER);
        }
    }
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
    multiSetProp(OBJPROP_ARROWCODE , 4      , cPoint1+cPoint2);
    multiSetProp(OBJPROP_WIDTH     , 0      , cPoint1+cPoint2);
    multiSetProp(OBJPROP_SELECTABLE, false  , iArrowT+iAngle0+cLbText);
    multiSetProp(OBJPROP_COLOR     , clrNONE, cPoint1+cPoint2+iAngle0);
    multiSetStrs(OBJPROP_TOOLTIP   , "\n"   , cPoint1+cPoint2+cMTrend+iAngle0+cLbText+iArrowT);

    ObjectSet(cMTrend, OBJPROP_RAY     , false);
    ObjectSetInteger(ChartID(), iArrowT, OBJPROP_ANCHOR, ANCHOR_CENTER);
    ObjectSetInteger(ChartID(), cLbText, OBJPROP_ANCHOR, ANCHOR_LOWER);
}
void Trend::updateTypeProperty()
{
    ObjectSetText (cLbText,  mDispText[mIndexType], 8, "Consolas", mColorType[mIndexType]);
    ObjectSetText (iArrowT,  mShowArrow[mIndexType] ? "▲" : "", 9, "Consolas", mShowArrow[mIndexType] ? mColorType[mIndexType] : clrNONE);
    SetObjectStyle(cMTrend, mColorType[mIndexType],          mStyleType[mIndexType],  mWidthType[mIndexType]);
}
void Trend::updateItemAfterChangeType()
{
    if (mFirstPoint == true)
    {
        updateTypeProperty();
        refreshData();
    }
}

//Chart Event
void Trend::onItemDrag(const string &itemId, const string &objId)
{
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
    multiSetProp(OBJPROP_SELECTED, (int)ObjectGet(objId, OBJPROP_SELECTED), cPoint1+cPoint2+cMTrend+cLbText);
    if ((bool)ObjectGet(cMTrend, OBJPROP_SELECTED) == true){
        gTemplates.openTemplates(objId, mTemplateTypes, -1);
    }
}
void Trend::onItemChange(const string &itemId, const string &objId)
{
    if (objId == cMTrend)
    {
        color c = (color)ObjectGet(objId, OBJPROP_COLOR);
        multiSetProp(OBJPROP_COLOR, c, cMTrend+cLbText);
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
    getCenterPos(time1, time2, price1, price2, time3, price3);
    priceText = price3;
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
void Trend::onUserRequest(const string &itemId, const string &objId)
{
    activateItem(itemId);
    mIndexType = gTemplates.mActivePos;
    updateTypeProperty();
}