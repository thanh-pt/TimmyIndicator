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
      string     __T_Normal_Name  = "Nml";
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
      string     __T_Bos_Name  = "bos";
      string     __T_Bos_Text  = "𝙗𝙤𝙨";
      TEXT_POS   __T_Bos_TxtPos= TXT_POS_CENTER;
input color      __T_Bos_Color = clrNavy;
input LINE_STYLE __T_Bos_Style = STYLE_SOLID;
      int        __T_Bos_Width = 1;
      bool       __T_Bos_Arrow = false;
//--------------------------------------------
      string     __T_SpLq_Name  = "xLq";
      string     __T_SpLq_Text  = "$";
      TEXT_POS   __T_SpLq_TxtPos= TXT_POS_CENTER;
input color      __T_SpLq_Color = clrCrimson;
input LINE_STYLE __T_SpLq_Style = STYLE_SOLID;
      int        __T_SpLq_Width = 1;
      bool       __T_SpLq_Arrow = true;
//--------------------------------------------
      string     __T_Fail_Name  = "ƒail";
      string     __T_Fail_Text  = "";
      TEXT_POS   __T_Fail_TxtPos= TXT_POS_CENTER;
input color      __T_Fail_Color = clrCrimson;
input LINE_STYLE __T_Fail_Style = STYLE_DOT;
      int        __T_Fail_Width = 1;
      bool       __T_Fail_Arrow = false;
//--------------------------------------------
      string     __T_BLg_Name  = "b/lg";
      string     __T_BLg_Text  = "𝙗𝙤𝙨/𝙡𝙜";
      TEXT_POS   __T_BLg_TxtPos= TXT_POS_CENTER;
input color      __T_BLg_Color = clrCrimson;
input LINE_STYLE __T_BLg_Style = STYLE_SOLID;
      int        __T_BLg_Width = 2;
      bool       __T_BLg_Arrow = false;
//--------------------------------------------
      string     __T_Eof_Name  = "eof";
      string     __T_Eof_Text  = "𝙚𝙤𝙛";
      TEXT_POS   __T_Eof_TxtPos= TXT_POS_RIGHT;
input color      __T_Eof_Color = clrGreen;
input LINE_STYLE __T_Eof_Style = STYLE_SOLID;
      int        __T_Eof_Width = 1;
      bool       __T_Eof_Arrow = false;
//--------------------------------------------
      string     __T_BE_Name  = "be";
      string     __T_BE_Text  = "𝙗𝙚";
      TEXT_POS   __T_BE_TxtPos= TXT_POS_RIGHT;
input color      __T_BE_Color = clrGreen;
input LINE_STYLE __T_BE_Style = STYLE_SOLID;
      int        __T_BE_Width = 1;
      bool       __T_BE_Arrow = false;
//--------------------------------------------
      string     __T_Arr_Name  = "Arw";
      string     __T_Arr_Text  = "";
      TEXT_POS   __T_Arr_TxtPos= TXT_POS_CENTER;
      color      __T_Arr_Color = clrNavy;
      LINE_STYLE __T_Arr_Style = STYLE_SOLID;
      int        __T_Arr_Width = 1;
      bool       __T_Arr_Arrow = true;

enum TrendType
{
    TREND_NML,
    TREND_FA ,
    TREND_BOS,
    TREND_BLG,
    TREND_LQ ,
    TREND_XLQ,
    // TREND_OF ,
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
    string sTData;

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
    mNameType [TREND_BOS  ] = __T_Bos_Name ;
    mDispText [TREND_BOS  ] = __T_Bos_Text ;
    mTextPos  [TREND_BOS  ] = __T_Bos_TxtPos;
    mColorType[TREND_BOS  ] = __T_Bos_Color;
    mStyleType[TREND_BOS  ] = __T_Bos_Style;
    mWidthType[TREND_BOS  ] = __T_Bos_Width;
    mShowArrow[TREND_BOS  ] = __T_Bos_Arrow;
    //--------------------------------------------
    mNameType [TREND_BLG  ] = __T_BLg_Name ;
    mDispText [TREND_BLG  ] = __T_BLg_Text ;
    mTextPos  [TREND_BLG  ] = __T_BLg_TxtPos;
    mColorType[TREND_BLG  ] = __T_BLg_Color;
    mStyleType[TREND_BLG  ] = __T_BLg_Style;
    mWidthType[TREND_BLG  ] = __T_BLg_Width;
    mShowArrow[TREND_BLG  ] = __T_BLg_Arrow;
    //--------------------------------------------
    mNameType [TREND_FA   ] = __T_Fail_Name ;
    mDispText [TREND_FA   ] = __T_Fail_Text ;
    mTextPos  [TREND_FA   ] = __T_Fail_TxtPos;
    mColorType[TREND_FA   ] = __T_Fail_Color;
    mStyleType[TREND_FA   ] = __T_Fail_Style;
    mWidthType[TREND_FA   ] = __T_Fail_Width;
    mShowArrow[TREND_FA   ] = __T_Fail_Arrow;
    //--------------------------------------------
    mNameType [TREND_XLQ  ] = __T_SpLq_Name ;
    mDispText [TREND_XLQ  ] = __T_SpLq_Text ;
    mTextPos  [TREND_XLQ  ] = __T_SpLq_TxtPos;
    mColorType[TREND_XLQ  ] = __T_SpLq_Color;
    mStyleType[TREND_XLQ  ] = __T_SpLq_Style;
    mWidthType[TREND_XLQ  ] = __T_SpLq_Width;
    mShowArrow[TREND_XLQ  ] = __T_SpLq_Arrow;
    //--------------------------------------------
    mNameType [TREND_EOF  ] = __T_Eof_Name ;
    mDispText [TREND_EOF  ] = __T_Eof_Text ;
    mTextPos  [TREND_EOF  ] = __T_Eof_TxtPos;
    mColorType[TREND_EOF  ] = __T_Eof_Color;
    mStyleType[TREND_EOF  ] = __T_Eof_Style;
    mWidthType[TREND_EOF  ] = __T_Eof_Width;
    mShowArrow[TREND_EOF  ] = __T_Eof_Arrow;
    //--------------------------------------------
    mNameType [TREND_BE  ]  = __T_BE_Name ;
    mDispText [TREND_BE  ]  = __T_BE_Text ;
    mTextPos  [TREND_BE  ]  = __T_BE_TxtPos;
    mColorType[TREND_BE  ]  = __T_BE_Color;
    mStyleType[TREND_BE  ]  = __T_BE_Style;
    mWidthType[TREND_BE  ]  = __T_BE_Width;
    mShowArrow[TREND_BE  ]  = __T_BE_Arrow;
    //--------------------------------------------
    mNameType [TREND_ARR]  = __T_Arr_Name ;
    mDispText [TREND_ARR]  = __T_Arr_Text ;
    mTextPos  [TREND_ARR]  = __T_Arr_TxtPos;
    mColorType[TREND_ARR]  = __T_Arr_Color;
    mStyleType[TREND_ARR]  = __T_Arr_Style;
    mWidthType[TREND_ARR]  = __T_Arr_Width;
    mShowArrow[TREND_ARR]  = __T_Arr_Arrow;
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
    sTData = itemId + "_sTData";
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
        if      (mTextPos[mIndexType] == TXT_POS_CENTER) ObjectSetInteger(0, iLbText, OBJPROP_ANCHOR, isUp ?        ANCHOR_LOWER :       ANCHOR_UPPER);
        else if (mTextPos[mIndexType] == TXT_POS_RIGHT)  ObjectSetInteger(0, iLbText, OBJPROP_ANCHOR, isUp ?   ANCHOR_LEFT_LOWER :  ANCHOR_LEFT_UPPER);
        else                                             ObjectSetInteger(0, iLbText, OBJPROP_ANCHOR, isUp ?  ANCHOR_RIGHT_LOWER : ANCHOR_RIGHT_UPPER);

        if (barT1 < barT2) ObjectSet(iArrowT, OBJPROP_ANGLE,  90.0); // case 180*
    }
}

void Trend::createItem()
{
    ObjectCreate(sTData, OBJ_TEXT        , 0, 0, 0);
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
    multiSetStrs(OBJPROP_TOOLTIP   , "\n"   , cPoint1+cPoint2+cMTrend+iAngle0+iLbText+iArrowT);

    multiSetProp(OBJPROP_RAY     , false, cMTrend+iAngle0);
    ObjectSetInteger(ChartID(), iArrowT, OBJPROP_ANCHOR, ANCHOR_CENTER);
}
void Trend::updateTypeProperty()
{
    ObjectSetText (iLbText,  mDispText[mIndexType], 8, "Consolas", mColorType[mIndexType]);
    ObjectSetText (iArrowT,  mShowArrow[mIndexType] ? "▲" : "", 9, "Consolas", mShowArrow[mIndexType] ? mColorType[mIndexType] : clrNONE);
    SetObjectStyle(cMTrend,  mColorType[mIndexType],          mStyleType[mIndexType],  mWidthType[mIndexType]);
    ObjectSetText (sTData,  IntegerToString(mIndexType));
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
    mIndexType = StrToInteger(ObjectDescription(sTData));
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
    multiSetProp(OBJPROP_SELECTED, (int)ObjectGet(targetobj, OBJPROP_SELECTED), cPoint1+cPoint2+cMTrend+iAngle0+iLbText+iArrowT+sTData);
    if (targetobj == cPoint2 && (bool)ObjectGet(cMTrend, OBJPROP_SELECTED) == true){
        gTemplates.openTemplates(targetobj, mTemplateTypes, StrToInteger(ObjectDescription(sTData)));
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
    onItemDrag(itemId, objId);
}