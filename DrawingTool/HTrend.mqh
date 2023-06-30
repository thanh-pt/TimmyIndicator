#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

//--------------------------------------------
input string     H_T_r_e_n_d___M_a_i_n_B_o_s___Cfg = SEPARATE_LINE;
      string     __H_MainBos_Name    = "bos";
      string     __H_MainBos_Text    = "bos";
input color      __H_MainBos_Color   = clrOlive;
input LINE_STYLE __H_MainBos_Style   = STYLE_SOLID;
      int        __H_MainBos_Width   = 2;
//--------------------------------------------
input string     H_T_r_e_n_d___S_u_b_B_o_s___Cfg = SEPARATE_LINE;
      string     __H_SubBos_Name     = "sbos";
      string     __H_SubBos_Text     = "sbos";
input color      __H_SubBos_Color    = clrDarkSlateGray;
input LINE_STYLE __H_SubBos_Style    = STYLE_SOLID;
      int        __H_SubBos_Width    = 1;
//--------------------------------------------
input string     H_T_r_e_n_d___L_q_G_r_a_p___Cfg = SEPARATE_LINE;
      string     __H_LqGrap_Name     = "lg";
      string     __H_LqGrap_Text     = "x";
input color      __H_LqGrap_Color    = clrCrimson;
input LINE_STYLE __H_LqGrap_Style    = STYLE_SOLID;
      int        __H_LqGrap_Width    = 1;
//--------------------------------------------
input string     H_T_r_e_n_d___B_o_s_L_G___Cfg = SEPARATE_LINE;
      string     __H_BosLG_Name      = "bos/lg";
      string     __H_BosLG_Text      = "bos-lg";
input color      __H_BosLG_Color     = clrCrimson;
input LINE_STYLE __H_BosLG_Style     = STYLE_DASHDOT;
      int        __H_BosLG_Width     = 1;
//--------------------------------------------
input string     H_T_r_e_n_d___T_a_r_g_e_t___Cfg = SEPARATE_LINE;
      string     __H_Target_Name     = "target";
      string     __H_Target_Text     = "target";
input color      __H_Target_Color    = clrGreen;
input LINE_STYLE __H_Target_Style    = STYLE_SOLID;
      int        __H_Target_Width    = 1;
//--------------------------------------------

enum HTrendType
{
    HTREND_MBOS,
    HTREND_SBOS,
    HTREND_LQGP,
    HTREND_BOSLG,
    HTREND_TARGT,
    HTREND_NUM,
};

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
    mNameType [HTREND_MBOS ] = __H_MainBos_Name ;
    mPropText [HTREND_MBOS ] = __H_MainBos_Text ;
    mPropColor[HTREND_MBOS ] = __H_MainBos_Color;
    mPropStyle[HTREND_MBOS ] = __H_MainBos_Style;
    mPropWidth[HTREND_MBOS ] = __H_MainBos_Width;
    //--------------------------------------------
    mNameType [HTREND_SBOS ] = __H_SubBos_Name ;
    mPropText [HTREND_SBOS ] = __H_SubBos_Text ;
    mPropColor[HTREND_SBOS ] = __H_SubBos_Color;
    mPropStyle[HTREND_SBOS ] = __H_SubBos_Style;
    mPropWidth[HTREND_SBOS ] = __H_SubBos_Width;
    //--------------------------------------------
    mNameType [HTREND_LQGP ] = __H_LqGrap_Name ;
    mPropText [HTREND_LQGP ] = __H_LqGrap_Text ;
    mPropColor[HTREND_LQGP ] = __H_LqGrap_Color;
    mPropStyle[HTREND_LQGP ] = __H_LqGrap_Style;
    mPropWidth[HTREND_LQGP ] = __H_LqGrap_Width;
    //--------------------------------------------
    mNameType [HTREND_BOSLG] = __H_BosLG_Name ;
    mPropText [HTREND_BOSLG] = __H_BosLG_Text ;
    mPropColor[HTREND_BOSLG] = __H_BosLG_Color;
    mPropStyle[HTREND_BOSLG] = __H_BosLG_Style;
    mPropWidth[HTREND_BOSLG] = __H_BosLG_Width;
    //--------------------------------------------
    mNameType [HTREND_TARGT] = __H_Target_Name ;
    mPropText [HTREND_TARGT] = __H_Target_Text ;
    mPropColor[HTREND_TARGT] = __H_Target_Color;
    mPropStyle[HTREND_TARGT] = __H_Target_Style;
    mPropWidth[HTREND_TARGT] = __H_Target_Width;
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