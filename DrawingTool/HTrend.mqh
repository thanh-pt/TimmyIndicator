#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

enum E_HTREND_POS
{
    RIGH_AUTO   = 0,
    CENTER_AUTO = 1,
    LEFT        = 2,
};

enum HTrendType
{
    HTREND1,
    HTREND2,
    HTREND3,
    HTREND_RECENT,
    HTREND_NUM,
};

input string            HTrend_         = SEPARATE_LINE_BIG;
input int               HTrend_Width    = 0;
input int               HTrend_FontSize = 8;
input string            HTrend_sp       = SEPARATE_LINE;
//-----------------------------------------------------------
input string            HTrend_1_NAME   = "BoS";
input string            HTrend_1_TEXT   = "bos";
input E_HTREND_POS      HTrend_1_Pos    = E_HTREND_POS::RIGH_AUTO;
input ENUM_LINE_STYLE   HTrend_1_Style  = STYLE_DOT;
input color             HTrend_1_Color  = clrDarkGray;
input string            HTrend_1_sp     = SEPARATE_LINE;
//-----------------------------------------------------------
input string            HTrend_2_NAME   = "ChoCh";
input string            HTrend_2_TEXT   = "ch";
input E_HTREND_POS      HTrend_2_Pos    = E_HTREND_POS::RIGH_AUTO;
input ENUM_LINE_STYLE   HTrend_2_Style  = STYLE_DOT;
input color             HTrend_2_Color  = clrDarkGray;
input string            HTrend_2_sp     = SEPARATE_LINE;
//-----------------------------------------------------------
input string            HTrend_3_NAME   = "Sweep!";
input string            HTrend_3_TEXT   = "x";
input E_HTREND_POS      HTrend_3_Pos    = E_HTREND_POS::LEFT;
input ENUM_LINE_STYLE   HTrend_3_Style  = STYLE_SOLID;
input color             HTrend_3_Color  = clrSilver;
input string            HTrend_3_sp     = SEPARATE_LINE;
//-----------------------------------------------------------


class HTrend : public BaseItem
{
// Internal Value
private:
    string              mPropText  [MAX_TYPE];
    E_HTREND_POS        mPropPos   [MAX_TYPE];
    ENUM_LINE_STYLE     mPropStyle [MAX_TYPE];
    color               mPropColor [MAX_TYPE];
// Component name
private:
    string cMainTrend;
    string cText     ;
    string sHPos     ;

// Value define for Item
private:
    double price;
    datetime time1;
    datetime time2;

public:
    HTrend(const string name, CommonData* commonData, MouseInfo* mouseInfo);

// Internal Event
public:
    virtual void prepareActive();
    virtual void createItem();
    virtual void updateDefaultProperty();
    virtual void updateTypeProperty();
    virtual void activateItem(const string& itemId);
    virtual void updateItemAfterChangeType();
    virtual void refreshData();

// Chart Event
public:
    virtual void onMouseMove();
    virtual void onMouseClick();
    virtual void onItemDrag(const string &itemId, const string &objId);
    virtual void onItemClick(const string &itemId, const string &objId);
    virtual void onItemChange(const string &itemId, const string &objId);
    virtual void onItemDeleted(const string &itemId, const string &objId);
};

HTrend::HTrend(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType  [HTREND1] = HTrend_1_NAME  ;
    mPropText  [HTREND1] = HTrend_1_TEXT  ;
    mPropPos   [HTREND1] = HTrend_1_Pos;
    mPropStyle [HTREND1] = HTrend_1_Style ;
    mPropColor [HTREND1] = HTrend_1_Color ;
    //-----------------------------
    mNameType  [HTREND2] = HTrend_2_NAME  ;
    mPropText  [HTREND2] = HTrend_2_TEXT  ;
    mPropPos   [HTREND2] = HTrend_2_Pos;
    mPropStyle [HTREND2] = HTrend_2_Style ;
    mPropColor [HTREND2] = HTrend_2_Color ;
    //-----------------------------
    mNameType  [HTREND3] = HTrend_3_NAME  ;
    mPropText  [HTREND3] = HTrend_3_TEXT  ;
    mPropPos   [HTREND3] = HTrend_3_Pos;
    mPropStyle [HTREND3] = HTrend_3_Style ;
    mPropColor [HTREND3] = HTrend_3_Color ;
    //-----------------------------
    mNameType  [HTREND_RECENT] = "R:";
    mPropText  [HTREND_RECENT] = "";
    mPropPos   [HTREND_RECENT] = E_HTREND_POS::CENTER_AUTO;
    mPropStyle [HTREND_RECENT] = STYLE_DOT;
    mPropColor [HTREND_RECENT] = clrDarkGray;
    //-----------------------------
    mIndexType = 0;
    mTypeNum   = HTREND_NUM;
}

// Internal Event
void HTrend::prepareActive(){}

void HTrend::createItem()
{
    ObjectCreate(cText     , OBJ_TEXT , 0, 0, 0);
    ObjectCreate(cMainTrend, OBJ_TREND, 0, 0, 0);
    ObjectCreate(sHPos     , OBJ_TEXT, 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();

    // Value define update
    time1 = pCommonData.mMouseTime;
    price = pCommonData.mMousePrice;
}
void HTrend::updateDefaultProperty()
{
    ObjectSet(cText     , OBJPROP_FONTSIZE, HTrend_FontSize);
    ObjectSetString(ChartID(), cText      ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cMainTrend ,OBJPROP_TOOLTIP,"\n");
}
void HTrend::updateTypeProperty()
{
    SetObjectStyle(cMainTrend, mPropColor[mIndexType], mPropStyle[mIndexType], HTrend_Width);
    ObjectSetText(cText, mPropText[mIndexType], HTrend_FontSize, NULL, mPropColor[mIndexType]);
    ObjectSetText(sHPos, IntegerToString(mPropPos[mIndexType]));
}
void HTrend::activateItem(const string& itemId)
{
    cMainTrend = itemId + "_cMainTrend";
    cText      = itemId + "_cText";
    sHPos      = itemId + "_sHPos";
}
void HTrend::updateItemAfterChangeType()
{
    if (mFirstPoint == true)
    {
        updateTypeProperty();
    }
}
void HTrend::refreshData()
{
    setItemPos(cMainTrend, time1, time2, price, price);
    datetime textTime = time1;
    int hPos = StrToInteger(ObjectDescription(sHPos));
    // Left/right/auto pos
    if      (hPos == RIGH_AUTO  ) textTime = time1+ChartPeriod()*60;
    else if (hPos == CENTER_AUTO) textTime = getCenterTime(time1, time2);
    else if (hPos == LEFT       ) textTime = time2;

    // Up or down the line
    int shift = iBarShift(ChartSymbol(), ChartPeriod(), time1);
    bool isUpper = false;
    if (price > Low[shift]) isUpper = true;
    if      (hPos == RIGH_AUTO  ) ObjectSetInteger(ChartID(), cText, OBJPROP_ANCHOR, isUpper ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER);
    else if (hPos == CENTER_AUTO) ObjectSetInteger(ChartID(), cText, OBJPROP_ANCHOR, isUpper ? ANCHOR_LOWER : ANCHOR_UPPER);
    else if (hPos == LEFT       ) ObjectSetInteger(ChartID(), cText, OBJPROP_ANCHOR, ANCHOR_LEFT);
    setTextPos(cText, textTime, price);
    /*
    string textString = ObjectGetString(ChartID(), cText, OBJPROP_TEXT);
    if (StringFind(textString, ".") == -1 && textString != "")
    {
        textString += "." + getTFString();
        ObjectSetText(cText    , textString);
    }
    */
}

// Chart Event
void HTrend::onMouseMove()
{
    if (mFirstPoint == false)
    {
        return;
    }
    time2 = pCommonData.mMouseTime;
    refreshData();
}
void HTrend::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void HTrend::onItemDrag(const string &itemId, const string &objId)
{
    time1 = (datetime)ObjectGet(cMainTrend, OBJPROP_TIME1);
    time2 = (datetime)ObjectGet(cMainTrend, OBJPROP_TIME2);
    price = ObjectGet(cMainTrend, OBJPROP_PRICE1);

    if (pCommonData.mCtrlHold)
    {
        price = pCommonData.mMousePrice;
    }
    refreshData();
}
void HTrend::onItemClick(const string &itemId, const string &objId)
{
    if (objId == cText)
    {
        ObjectSet(cMainTrend, OBJPROP_SELECTED, ObjectGet(cText, OBJPROP_SELECTED));
        multiSetProp(OBJPROP_SELECTED, (int)ObjectGet(cText, OBJPROP_SELECTED), cMainTrend+sHPos);
    }
}
void HTrend::onItemChange(const string &itemId, const string &objId)
{
    color c = (color)ObjectGet(objId, OBJPROP_COLOR);
    ObjectSet(cMainTrend, OBJPROP_COLOR, c);
    ObjectSet(cText     , OBJPROP_COLOR, c);
    if (objId == cMainTrend)
    {
        string lineDescription = ObjectDescription(cMainTrend);
        if (lineDescription != "")
        {
            ObjectSetText(cText    , lineDescription);
            ObjectSetText(cMainTrend, "");
        }
    }
    mPropText  [HTREND_RECENT] = ObjectDescription(cText);
    mNameType  [HTREND_RECENT] = "R:"+mPropText[HTREND_RECENT];
    mPropPos   [HTREND_RECENT] = E_HTREND_POS::CENTER_AUTO;
    mPropStyle [HTREND_RECENT] = (ENUM_LINE_STYLE)ObjectGet(cMainTrend, OBJPROP_STYLE);
    mPropColor [HTREND_RECENT] = c ;
}
void HTrend::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cMainTrend);
    ObjectDelete(cText    );
}