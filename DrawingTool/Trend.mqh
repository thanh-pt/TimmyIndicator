#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

//--------------------------------------------
input string     T_r_e_n_d___L_i_q_u_i_d_i_t_y___Cfg = SEPARATE_LINE;
      string     __T_Liquidity_Name  = "Liquidity";
      string     __T_Liquidity_Text  = "$$$";
input color      __T_Liquidity_Color = clrGold;
input LINE_STYLE __T_Liquidity_Style = STYLE_SOLID;
      int        __T_Liquidity_Width = 1;
      bool       __T_Liquidity_Arrow = false;
//--------------------------------------------
input string     T_r_e_n_d___E_x_p_e_c_t_O_d_r_F_l_w___Cfg = SEPARATE_LINE;
      string     __T_EptOdrFlw_Name  = "EOF";
      string     __T_EptOdrFlw_Text  = "EOF";
input color      __T_EptOdrFlw_Color = clrGold;
input LINE_STYLE __T_EptOdrFlw_Style = STYLE_DOT;
      int        __T_EptOdrFlw_Width = 1;
      bool       __T_EptOdrFlw_Arrow = true;
//--------------------------------------------

/*
TODO:
- Fix arrow <--
- auto text position
*/

enum TrendType
{
    TREND_LQ,
    TREND_EOF,
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
};

Trend::Trend(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [TREND_LQ   ] = __T_Liquidity_Name ;
    mDispText [TREND_LQ   ] = __T_Liquidity_Text ;
    mColorType[TREND_LQ   ] = __T_Liquidity_Color;
    mStyleType[TREND_LQ   ] = __T_Liquidity_Style;
    mWidthType[TREND_LQ   ] = __T_Liquidity_Width;
    mShowArrow[TREND_LQ   ] = __T_Liquidity_Arrow;
    //--------------------------------------------
    mNameType [TREND_EOF  ] = __T_EptOdrFlw_Name ;
    mDispText [TREND_EOF  ] = __T_EptOdrFlw_Text ;
    mColorType[TREND_EOF  ] = __T_EptOdrFlw_Color;
    mStyleType[TREND_EOF  ] = __T_EptOdrFlw_Style;
    mWidthType[TREND_EOF  ] = __T_EptOdrFlw_Width;
    mShowArrow[TREND_EOF  ] = __T_EptOdrFlw_Arrow;
    //--------------------------------------------
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
    multiSetProp(OBJPROP_SELECTABLE, false  , iArrowT+iAngle0);
    multiSetProp(OBJPROP_COLOR     , clrNONE, cPoint1+cPoint2+iAngle0);
    multiSetStrs(OBJPROP_TOOLTIP   , "\n"   , cPoint1+cPoint2+cMTrend+iAngle0+cLbText+iArrowT);

    ObjectSet(cMTrend, OBJPROP_RAY     , false);
    ObjectSetInteger(ChartID(), iArrowT, OBJPROP_ANCHOR, ANCHOR_CENTER);
    ObjectSetInteger(ChartID(), cLbText, OBJPROP_ANCHOR, ANCHOR_LOWER);
}
void Trend::updateTypeProperty()
{
    ObjectSetText (cLbText,  mDispText[mIndexType], 8, NULL, mColorType[mIndexType]);
    ObjectSetText (iArrowT,  mShowArrow[mIndexType] ? "▲" : "", 8, NULL, mShowArrow[mIndexType] ? mColorType[mIndexType] : clrNONE);
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