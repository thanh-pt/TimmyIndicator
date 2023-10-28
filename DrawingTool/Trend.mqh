#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

enum TEXT_POS
{
    TXT_POS_LEFT,
    TXT_POS_CENTER,
    TXT_POS_RIGHT,
};

input string _2 = "";
//--------------------------------------------
      string     Trend_Normal_Name  = "Nml";
      string     Trend_Normal_Text  = "";
      TEXT_POS   Trend_Normal_TxtPos= TXT_POS_CENTER;
input color      Trend_Normal_Color = clrMidnightBlue;
input LINE_STYLE Trend_Normal_Style = STYLE_SOLID;
      int        Trend_Normal_Width = 1;
      bool       Trend_Normal_Arrow = false;
//--------------------------------------------
      string     Trend_Lq_Name  = "Lq";
      string     Trend_Lq_Text  = "$";
      TEXT_POS   Trend_Lq_TxtPos= TXT_POS_CENTER;
input color      Trend_Lq_Color = clrBlack;
input LINE_STYLE Trend_Lq_Style = STYLE_SOLID;
      int        Trend_Lq_Width = 1;
      bool       Trend_Lq_Arrow = false;
//--------------------------------------------
      string     Trend_Bos_Name  = "bos";
      string     Trend_Bos_Text  = "𝙗𝙤𝙨";
      TEXT_POS   Trend_Bos_TxtPos= TXT_POS_CENTER;
input color      Trend_Bos_Color = clrNavy;
input LINE_STYLE Trend_Bos_Style = STYLE_SOLID;
      int        Trend_Bos_Width = 1;
      bool       Trend_Bos_Arrow = false;
//--------------------------------------------
      string     Trend_SpLq_Name  = "xLq";
      string     Trend_SpLq_Text  = "$";
      TEXT_POS   Trend_SpLq_TxtPos= TXT_POS_CENTER;
input color      Trend_SpLq_Color = clrCrimson;
input LINE_STYLE Trend_SpLq_Style = STYLE_SOLID;
      int        Trend_SpLq_Width = 1;
      bool       Trend_SpLq_Arrow = true;
//--------------------------------------------
      string     Trend_Fail_Name  = "ƒail";
      string     Trend_Fail_Text  = "";
      TEXT_POS   Trend_Fail_TxtPos= TXT_POS_CENTER;
input color      Trend_Fail_Color = clrSlateGray;
input LINE_STYLE Trend_Fail_Style = STYLE_DOT;
      int        Trend_Fail_Width = 1;
      bool       Trend_Fail_Arrow = false;
//--------------------------------------------
      string     Trend_BLg_Name  = "b/lg";
      string     Trend_BLg_Text  = "𝙗𝙤𝙨/𝙡𝙜";
      TEXT_POS   Trend_BLg_TxtPos= TXT_POS_CENTER;
input color      Trend_BLg_Color = clrCrimson;
input LINE_STYLE Trend_BLg_Style = STYLE_SOLID;
      int        Trend_BLg_Width = 2;
      bool       Trend_BLg_Arrow = false;
//--------------------------------------------
      string     Trend_Eof_Name  = "ERL";
      string     Trend_Eof_Text  = "ERL";
      TEXT_POS   Trend_Eof_TxtPos= TXT_POS_RIGHT;
input color      Trend_Eof_Color = clrGreen;
input LINE_STYLE Trend_Eof_Style = STYLE_SOLID;
      int        Trend_Eof_Width = 1;
      bool       Trend_Eof_Arrow = false;
//--------------------------------------------
      string     Trend_BE_Name  = "be";
      string     Trend_BE_Text  = "𝙗𝙚";
      TEXT_POS   Trend_BE_TxtPos= TXT_POS_RIGHT;
input color      Trend_BE_Color = clrGreen;
input LINE_STYLE Trend_BE_Style = STYLE_SOLID;
      int        Trend_BE_Width = 1;
      bool       Trend_BE_Arrow = false;
//--------------------------------------------
      string     Trend_Arr_Name  = "Arw";
      string     Trend_Arr_Text  = "";
      TEXT_POS   Trend_Arr_TxtPos= TXT_POS_CENTER;
      color      Trend_Arr_Color = clrNavy;
      LINE_STYLE Trend_Arr_Style = STYLE_SOLID;
      int        Trend_Arr_Width = 1;
      bool       Trend_Arr_Arrow = true;

enum TrendType
{
    TREND_NML,
    TREND_FA ,
    TREND_BOS,
    TREND_BLG,
    TREND_LQ ,
    TREND_XLQ,
    TREND_EOF,
    TREND_BE ,
    TREND_ARR,
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
};

Trend::Trend(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [TREND_NML  ] = Trend_Normal_Name ;
    mDispText [TREND_NML  ] = Trend_Normal_Text ;
    mTextPos  [TREND_NML  ] = Trend_Normal_TxtPos;
    mColorType[TREND_NML  ] = Trend_Normal_Color;
    mStyleType[TREND_NML  ] = Trend_Normal_Style;
    mWidthType[TREND_NML  ] = Trend_Normal_Width;
    mShowArrow[TREND_NML  ] = Trend_Normal_Arrow;
    //--------------------------------------------
    mNameType [TREND_LQ   ] = Trend_Lq_Name ;
    mDispText [TREND_LQ   ] = Trend_Lq_Text ;
    mTextPos  [TREND_LQ   ] = Trend_Lq_TxtPos;
    mColorType[TREND_LQ   ] = Trend_Lq_Color;
    mStyleType[TREND_LQ   ] = Trend_Lq_Style;
    mWidthType[TREND_LQ   ] = Trend_Lq_Width;
    mShowArrow[TREND_LQ   ] = Trend_Lq_Arrow;
    //--------------------------------------------
    mNameType [TREND_BOS  ] = Trend_Bos_Name ;
    mDispText [TREND_BOS  ] = Trend_Bos_Text ;
    mTextPos  [TREND_BOS  ] = Trend_Bos_TxtPos;
    mColorType[TREND_BOS  ] = Trend_Bos_Color;
    mStyleType[TREND_BOS  ] = Trend_Bos_Style;
    mWidthType[TREND_BOS  ] = Trend_Bos_Width;
    mShowArrow[TREND_BOS  ] = Trend_Bos_Arrow;
    //--------------------------------------------
    mNameType [TREND_BLG  ] = Trend_BLg_Name ;
    mDispText [TREND_BLG  ] = Trend_BLg_Text ;
    mTextPos  [TREND_BLG  ] = Trend_BLg_TxtPos;
    mColorType[TREND_BLG  ] = Trend_BLg_Color;
    mStyleType[TREND_BLG  ] = Trend_BLg_Style;
    mWidthType[TREND_BLG  ] = Trend_BLg_Width;
    mShowArrow[TREND_BLG  ] = Trend_BLg_Arrow;
    //--------------------------------------------
    mNameType [TREND_FA   ] = Trend_Fail_Name ;
    mDispText [TREND_FA   ] = Trend_Fail_Text ;
    mTextPos  [TREND_FA   ] = Trend_Fail_TxtPos;
    mColorType[TREND_FA   ] = Trend_Fail_Color;
    mStyleType[TREND_FA   ] = Trend_Fail_Style;
    mWidthType[TREND_FA   ] = Trend_Fail_Width;
    mShowArrow[TREND_FA   ] = Trend_Fail_Arrow;
    //--------------------------------------------
    mNameType [TREND_XLQ  ] = Trend_SpLq_Name ;
    mDispText [TREND_XLQ  ] = Trend_SpLq_Text ;
    mTextPos  [TREND_XLQ  ] = Trend_SpLq_TxtPos;
    mColorType[TREND_XLQ  ] = Trend_SpLq_Color;
    mStyleType[TREND_XLQ  ] = Trend_SpLq_Style;
    mWidthType[TREND_XLQ  ] = Trend_SpLq_Width;
    mShowArrow[TREND_XLQ  ] = Trend_SpLq_Arrow;
    //--------------------------------------------
    mNameType [TREND_EOF  ] = Trend_Eof_Name ;
    mDispText [TREND_EOF  ] = Trend_Eof_Text ;
    mTextPos  [TREND_EOF  ] = Trend_Eof_TxtPos;
    mColorType[TREND_EOF  ] = Trend_Eof_Color;
    mStyleType[TREND_EOF  ] = Trend_Eof_Style;
    mWidthType[TREND_EOF  ] = Trend_Eof_Width;
    mShowArrow[TREND_EOF  ] = Trend_Eof_Arrow;
    //--------------------------------------------
    mNameType [TREND_BE  ]  = Trend_BE_Name ;
    mDispText [TREND_BE  ]  = Trend_BE_Text ;
    mTextPos  [TREND_BE  ]  = Trend_BE_TxtPos;
    mColorType[TREND_BE  ]  = Trend_BE_Color;
    mStyleType[TREND_BE  ]  = Trend_BE_Style;
    mWidthType[TREND_BE  ]  = Trend_BE_Width;
    mShowArrow[TREND_BE  ]  = Trend_BE_Arrow;
    //--------------------------------------------
    mNameType [TREND_ARR]  = Trend_Arr_Name ;
    mDispText [TREND_ARR]  = Trend_Arr_Text ;
    mTextPos  [TREND_ARR]  = Trend_Arr_TxtPos;
    mColorType[TREND_ARR]  = Trend_Arr_Color;
    mStyleType[TREND_ARR]  = Trend_Arr_Style;
    mWidthType[TREND_ARR]  = Trend_Arr_Width;
    mShowArrow[TREND_ARR]  = Trend_Arr_Arrow;
    //--------------------------------------------
    mIndexType = 0;
    mTypeNum = TREND_NUM;
    for (int i = 0; i < mTypeNum; i++)
    {
        mTemplateTypes += mNameType[i];
        if (i < mTypeNum-1) mTemplateTypes += ",";
    }
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

    mAllItem += cPoint1+cPoint2+cMTrend+iLbText+iAngle0+iArrowT;
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
    ObjectSet(iArrowT, OBJPROP_ANGLE,  angle-90.0);

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
    else if (angle == 0) 
    {
        if      (mTextPos[mIndexType] == TXT_POS_CENTER) ObjectSetInteger(0, iLbText, OBJPROP_ANCHOR, isUp ? ANCHOR_LOWER : ANCHOR_UPPER);
        else if (mTextPos[mIndexType] == TXT_POS_RIGHT)  ObjectSetInteger(0, iLbText, OBJPROP_ANCHOR, barT1 > barT2 ? ANCHOR_LEFT : ANCHOR_RIGHT);
        else                                             ObjectSetInteger(0, iLbText, OBJPROP_ANCHOR, barT1 > barT2 ? ANCHOR_RIGHT: ANCHOR_LEFT);

        if (barT1 < barT2) ObjectSet(iArrowT, OBJPROP_ANGLE,  90.0); // case 180*
    }
}

void Trend::createItem()
{
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
    multiSetProp(OBJPROP_WIDTH     , 5      , cPoint1+cPoint2);
    multiSetProp(OBJPROP_SELECTABLE, false  , iArrowT+iAngle0+iLbText);
    multiSetProp(OBJPROP_COLOR     , clrNONE, cPoint1+cPoint2+iAngle0);
    multiSetStrs(OBJPROP_TOOLTIP   , "\n"   , mAllItem);

    multiSetProp(OBJPROP_RAY     , false, cMTrend+iAngle0);
    ObjectSetInteger(ChartID(), iArrowT, OBJPROP_ANCHOR, ANCHOR_CENTER);
}
void Trend::updateTypeProperty()
{
    ObjectSetText (iLbText,  mDispText[mIndexType], 8, "Consolas", mColorType[mIndexType]);
    ObjectSetText (iArrowT,  mShowArrow[mIndexType] ? "▲" : "", 9, "Consolas", mShowArrow[mIndexType] ? mColorType[mIndexType] : clrNONE);
    SetObjectStyle(cMTrend,  mColorType[mIndexType],          mStyleType[mIndexType],  mWidthType[mIndexType]);
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
    gTemplates.clearTemplates();
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
    string targetobj = objId;
    if (objId == iAngle0 || objId == iArrowT || objId == iLbText)
    {
        if ((int)ObjectGet(cMTrend, OBJPROP_SELECTED) == 0) return;
        targetobj = cMTrend;
    }
    multiSetProp(OBJPROP_SELECTED, (int)ObjectGet(targetobj, OBJPROP_SELECTED), mAllItem);
    if (targetobj == cPoint2 && (bool)ObjectGet(cMTrend, OBJPROP_SELECTED) == true){
        gTemplates.openTemplates(objId, mTemplateTypes, mIndexType);
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
