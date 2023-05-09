#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

enum HTrendType
{
    HTREND_MBOS,
    HTREND_SBOS,
    HTREND_LQGP,
    HTREND_BOSLG,
    HTREND_TARGT,
    HTREND_NUM,
};

input string     HTrend_Configuration   = SEPARATE_LINE_BIG;
//--------------------------------------------
input string     HTrend_MainBos_cf      = SEPARATE_LINE;
      string     HTrend_MainBos_Name    = "bos";
      string     HTrend_MainBos_Text    = "";
input color      HTrend_MainBos_Color   = clrOlive;
input LINE_STYLE HTrend_MainBos_Style   = STYLE_SOLID;
      int        HTrend_MainBos_Width   = 1;
//--------------------------------------------
input string     HTrend_SubBos_cf       = SEPARATE_LINE;
      string     HTrend_SubBos_Name     = "sbos";
      string     HTrend_SubBos_Text     = "";
input color      HTrend_SubBos_Color    = clrDarkSlateGray;
input LINE_STYLE HTrend_SubBos_Style    = STYLE_SOLID;
      int        HTrend_SubBos_Width    = 1;
//--------------------------------------------
input string     HTrend_LqGrap_cf       = SEPARATE_LINE;
      string     HTrend_LqGrap_Name     = "lg";
      string     HTrend_LqGrap_Text     = "";
input color      HTrend_LqGrap_Color    = clrCrimson;
input LINE_STYLE HTrend_LqGrap_Style    = STYLE_SOLID;
      int        HTrend_LqGrap_Width    = 1;
//--------------------------------------------
input string     HTrend_BosLG_cf        = SEPARATE_LINE;
      string     HTrend_BosLG_Name      = "bos/lg";
      string     HTrend_BosLG_Text      = "bos-lg";
input color      HTrend_BosLG_Color     = clrCrimson;
input LINE_STYLE HTrend_BosLG_Style     = STYLE_DASHDOT;
      int        HTrend_BosLG_Width     = 1;
//--------------------------------------------
input string     HTrend_Target_cf       = SEPARATE_LINE;
      string     HTrend_Target_Name     = "target";
      string     HTrend_Target_Text     = "target";
input color      HTrend_Target_Color    = clrGreen;
input LINE_STYLE HTrend_Target_Style    = STYLE_SOLID;
      int        HTrend_Target_Width    = 1;
//--------------------------------------------


class HTrend : public BaseItem
{
// Internal Value
private:
    string mPropText [MAX_TYPE];
    color  mPropColor[MAX_TYPE];
    int    mPropStyle[MAX_TYPE];
    int    mPropWidth[MAX_TYPE];
// Component name
private:
    string cMainTrend;
    string cText     ;

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
    mNameType [HTREND_MBOS ] = HTrend_MainBos_Name ;
    mPropText [HTREND_MBOS ] = HTrend_MainBos_Text ;
    mPropColor[HTREND_MBOS ] = HTrend_MainBos_Color;
    mPropStyle[HTREND_MBOS ] = HTrend_MainBos_Style;
    mPropWidth[HTREND_MBOS ] = HTrend_MainBos_Width;
    //--------------------------------------------
    mNameType [HTREND_SBOS ] = HTrend_SubBos_Name ;
    mPropText [HTREND_SBOS ] = HTrend_SubBos_Text ;
    mPropColor[HTREND_SBOS ] = HTrend_SubBos_Color;
    mPropStyle[HTREND_SBOS ] = HTrend_SubBos_Style;
    mPropWidth[HTREND_SBOS ] = HTrend_SubBos_Width;
    //--------------------------------------------
    mNameType [HTREND_LQGP ] = HTrend_LqGrap_Name ;
    mPropText [HTREND_LQGP ] = HTrend_LqGrap_Text ;
    mPropColor[HTREND_LQGP ] = HTrend_LqGrap_Color;
    mPropStyle[HTREND_LQGP ] = HTrend_LqGrap_Style;
    mPropWidth[HTREND_LQGP ] = HTrend_LqGrap_Width;
    //--------------------------------------------
    mNameType [HTREND_BOSLG] = HTrend_BosLG_Name ;
    mPropText [HTREND_BOSLG] = HTrend_BosLG_Text ;
    mPropColor[HTREND_BOSLG] = HTrend_BosLG_Color;
    mPropStyle[HTREND_BOSLG] = HTrend_BosLG_Style;
    mPropWidth[HTREND_BOSLG] = HTrend_BosLG_Width;
    //--------------------------------------------
    mNameType [HTREND_TARGT] = HTrend_Target_Name ;
    mPropText [HTREND_TARGT] = HTrend_Target_Text ;
    mPropColor[HTREND_TARGT] = HTrend_Target_Color;
    mPropStyle[HTREND_TARGT] = HTrend_Target_Style;
    mPropWidth[HTREND_TARGT] = HTrend_Target_Width;
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

    updateTypeProperty();
    updateDefaultProperty();

    // Value define update
    time1 = pCommonData.mMouseTime;
    price = pCommonData.mMousePrice;
}
void HTrend::updateDefaultProperty()
{
    ObjectSetString(ChartID(), cText      ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cMainTrend ,OBJPROP_TOOLTIP,"\n");
}
void HTrend::updateTypeProperty()
{
    SetObjectStyle(cMainTrend, mPropColor[mIndexType], mPropStyle[mIndexType], mPropWidth[mIndexType]);
    ObjectSetText( cText     , mPropText [mIndexType], 8, NULL, mPropColor[mIndexType]);
}
void HTrend::activateItem(const string& itemId)
{
    cMainTrend = itemId + "_cMainTrend";
    cText      = itemId + "_cText";
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
    datetime textTime = getCenterTime(time1, time2);;

    // Up or down the line
    int shift = iBarShift(ChartSymbol(), ChartPeriod(), time1);
    bool isUpper = false;
    if (price > Low[shift]) isUpper = true;
    ObjectSetInteger(ChartID(), cText, OBJPROP_ANCHOR, isUpper ? ANCHOR_LOWER : ANCHOR_UPPER);
    setTextPos(cText, textTime, price);
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
            ObjectSetText(cText     , lineDescription);
            ObjectSetText(cMainTrend, "");
        }
    }
}
void HTrend::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cMainTrend);
    ObjectDelete(cText    );
}