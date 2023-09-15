#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

enum TEXT_POS
{
    TXT_POS_LEFT,
    TXT_POS_CENTER,
    TXT_POS_RIGHT,
};

//--------------------------------------------
      string     __T_Normal_Name  = "Normal";
      string     __T_Normal_Text  = "";
      TEXT_POS   __T_Normal_TxtPos= TXT_POS_CENTER;
input color      __T_Normal_Color = clrMidnightBlue;
input LINE_STYLE __T_Normal_Style = STYLE_SOLID;
      int        __T_Normal_Width = 1;
      bool       __T_Normal_Arrow = false;
//--------------------------------------------
      string     __T_Lq_Name  = "Lq";
      string     __T_Lq_Text  = "$";
      TEXT_POS   __T_Lq_TxtPos= TXT_POS_CENTER;
input color      __T_Lq_Color = clrBlack;
input LINE_STYLE __T_Lq_Style = STYLE_SOLID;
      int        __T_Lq_Width = 1;
      bool       __T_Lq_Arrow = false;
//--------------------------------------------
      string     __T_Mtg_Name  = "OF";
      string     __T_Mtg_Text  = "OF";
      TEXT_POS   __T_Mtg_TxtPos= TXT_POS_CENTER;
input color      __T_Mtg_Color = clrGreen;
input LINE_STYLE __T_Mtg_Style = STYLE_SOLID;
      int        __T_Mtg_Width = 1;
      bool       __T_Mtg_Arrow = true;
//--------------------------------------------

enum TrendType
{
    TREND_NML,
    TREND_LQ,
    TREND_MTG,
    TREND_NUM,
};

class Trend : public BaseItem
{
// Internal Value
private:
    string   mDispText [MAX_TYPE];
    TEXT_POS mTextPos  [MAX_TYPE];
    color    mColorType[MAX_TYPE];
    int      mStyleType[MAX_TYPE];
    int      mWidthType[MAX_TYPE];
    bool     mShowArrow[MAX_TYPE];

// Component name
private:
    string cPoint1;
    string cPoint2;
    string cMTrend;
    string iAngle0;
    string iLbText;
    string iArrowT;
    string sTxtPos;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    datetime time3;
    double price1;
    double price2;
    double price3;

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
    mTextPos  [TREND_NML  ] = __T_Normal_TxtPos;
    mColorType[TREND_NML  ] = __T_Normal_Color;
    mStyleType[TREND_NML  ] = __T_Normal_Style;
    mWidthType[TREND_NML  ] = __T_Normal_Width;
    mShowArrow[TREND_NML  ] = __T_Normal_Arrow;
    //--------------------------------------------
    mNameType [TREND_LQ   ] = __T_Lq_Name ;
    mDispText [TREND_LQ   ] = __T_Lq_Text ;
    mTextPos  [TREND_LQ   ] = __T_Lq_TxtPos;
    mColorType[TREND_LQ   ] = __T_Lq_Color;
    mStyleType[TREND_LQ   ] = __T_Lq_Style;
    mWidthType[TREND_LQ   ] = __T_Lq_Width;
    mShowArrow[TREND_LQ   ] = __T_Lq_Arrow;
    //--------------------------------------------
    mNameType [TREND_MTG  ] = __T_Mtg_Name ;
    mDispText [TREND_MTG  ] = __T_Mtg_Text ;
    mTextPos  [TREND_MTG  ] = __T_Mtg_TxtPos;
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
    iLbText = itemId + "_0iLbText";
    iAngle0 = itemId + "_0iAngle0";
    iArrowT = itemId + "_0iArrowT";
    sTxtPos = itemId + "_sTxtPos";
}

void Trend::refreshData()
{
    // Update Main Compoment
    setItemPos(cMTrend, time1, time2, price1, price2);
    setItemPos(cPoint1, time1, price1);
    setItemPos(cPoint2, time2, price2);
    setItemPos(iAngle0, time1, time2, price1, price2);
    setTextPos(iArrowT, time2, price2);
    double angle=ObjectGet(iAngle0, OBJPROP_ANGLE);
    ObjectSet(iArrowT, OBJPROP_ANGLE,  angle-90);

    // Update Text
    if      (mTextPos[mIndexType] == TXT_POS_CENTER) setTextPos(iLbText, time3, price3);
    else if (mTextPos[mIndexType] == TXT_POS_RIGHT)  setTextPos(iLbText, time2, price2);
    else                                             setTextPos(iLbText, time1, price1);

    bool isUp = false;
    int barT1 = iBarShift(ChartSymbol(), ChartPeriod(), time1);
    int barT2 = iBarShift(ChartSymbol(), ChartPeriod(), time2);
    if (barT1 > barT2 && price1 >= High[barT1]) isUp = true;
    else if (barT2 > barT1 && price2 >= High[barT2]) isUp = true;

    if      (angle > 000 && angle <=  90) ObjectSetInteger(0, iLbText, OBJPROP_ANCHOR, isUp ? ANCHOR_RIGHT_LOWER : ANCHOR_LEFT_UPPER);
    else if (angle > 090 && angle <  180) ObjectSetInteger(0, iLbText, OBJPROP_ANCHOR, isUp ?  ANCHOR_LEFT_LOWER : ANCHOR_RIGHT_UPPER);
    else if (angle > 180 && angle <= 270) ObjectSetInteger(0, iLbText, OBJPROP_ANCHOR, isUp ? ANCHOR_RIGHT_LOWER : ANCHOR_LEFT_UPPER);
    else if (angle > 270 && angle <  360) ObjectSetInteger(0, iLbText, OBJPROP_ANCHOR, isUp ?  ANCHOR_LEFT_LOWER : ANCHOR_RIGHT_UPPER);
    else if (angle == 0  || angle == 180) ObjectSetInteger(0, iLbText, OBJPROP_ANCHOR, isUp ?  ANCHOR_LOWER : ANCHOR_UPPER);
}

void Trend::createItem()
{
    ObjectCreate(sTxtPos, OBJ_TEXT        , 0, 0, 0);
    ObjectCreate(iAngle0, OBJ_TRENDBYANGLE, 0, 0, 0);
    ObjectCreate(iArrowT, OBJ_TEXT        , 0, 0, 0);
    ObjectCreate(cMTrend, OBJ_TREND       , 0, 0, 0);
    ObjectCreate(iLbText, OBJ_TEXT        , 0, 0, 0);
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
    multiSetProp(OBJPROP_SELECTABLE, false  , iArrowT+iAngle0+iLbText);
    multiSetProp(OBJPROP_COLOR     , clrNONE, cPoint1+cPoint2+iAngle0);
    multiSetStrs(OBJPROP_TOOLTIP   , "\n"   , cPoint1+cPoint2+cMTrend+iAngle0+iLbText+iArrowT);

    multiSetProp(OBJPROP_RAY     , false, cMTrend+iAngle0);
    ObjectSetInteger(ChartID(), iArrowT, OBJPROP_ANCHOR, ANCHOR_CENTER);
}
void Trend::updateTypeProperty()
{
    ObjectSetText (iLbText,  mDispText[mIndexType], 8, "Consolas", mColorType[mIndexType]);
    ObjectSetText (iArrowT,  mShowArrow[mIndexType] ? "▲" : "", 9, "Consolas", mShowArrow[mIndexType] ? mColorType[mIndexType] : clrNONE);
    SetObjectStyle(cMTrend,  mColorType[mIndexType],          mStyleType[mIndexType],  mWidthType[mIndexType]);
    ObjectSetText (sTxtPos,  IntegerToString(mIndexType));
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
    mIndexType = StrToInteger(ObjectDescription(sTxtPos));
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

    refreshData();
}
void Trend::onItemClick(const string &itemId, const string &objId)
{
    if (objId == iAngle0) return;
    if (objId == iArrowT) return;
    if (objId == iLbText) return;
    multiSetProp(OBJPROP_SELECTED, (int)ObjectGet(objId, OBJPROP_SELECTED), cPoint1+cPoint2+cMTrend+iAngle0+iLbText+iArrowT+sTxtPos);
    if (objId == cMTrend && (bool)ObjectGet(cMTrend, OBJPROP_SELECTED) == true){
        gTemplates.openTemplates(objId, mTemplateTypes, -1);
    }
}
void Trend::onItemChange(const string &itemId, const string &objId)
{
    if (objId == cMTrend)
    {
        color c = (color)ObjectGet(objId, OBJPROP_COLOR);
        multiSetProp(OBJPROP_COLOR, c, cMTrend+iLbText);
        string lineDescription = ObjectDescription(cMTrend);
        if (lineDescription != "")
        {
            ObjectSetText(iLbText, lineDescription);
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
    refreshData();
}
void Trend::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cPoint1);
    ObjectDelete(cPoint2);
    ObjectDelete(cMTrend);
    ObjectDelete(iLbText);
    ObjectDelete(iAngle0);
    ObjectDelete(iArrowT);
}
void Trend::onUserRequest(const string &itemId, const string &objId)
{
    activateItem(itemId);
    mIndexType = gTemplates.mActivePos;
    updateTypeProperty();
}