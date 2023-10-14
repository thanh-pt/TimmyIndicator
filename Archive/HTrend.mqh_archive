#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

//--------------------------------------------
      string     __H_MainBos_Name    = "bos";
      string     __H_MainBos_Text    = "𝙗𝙤𝙨";
input color      __H_MainBos_Color   = clrOlive;
input LINE_STYLE __H_MainBos_Style   = STYLE_SOLID;
input int        __H_MainBos_Width   = 2;
//--------------------------------------------
//       string     __H_SubBos_Name     = "sbos";
// input string     __H_SubBos_Text     = "sbos";
// input color      __H_SubBos_Color    = clrDarkSlateGray;
// input LINE_STYLE __H_SubBos_Style    = STYLE_SOLID;
// input int        __H_SubBos_Width    = 1;
// //--------------------------------------------
//       string     __H_MinorBos_Name     = "mbos";
//       string     __H_MinorBos_Text     = "mbos";
// input color      __H_MinorBos_Color    = clrDarkSlateGray;
// input LINE_STYLE __H_MinorBos_Style    = STYLE_SOLID;
//       int        __H_MinorBos_Width    = 1;
//--------------------------------------------
      string     __H_LqGrap_Name     = "Ø_lq";
      string     __H_LqGrap_Text     = "Ø";
input color      __H_LqGrap_Color    = clrCrimson;
input LINE_STYLE __H_LqGrap_Style    = STYLE_SOLID;
      int        __H_LqGrap_Width    = 1;
//--------------------------------------------
      string     __H_FailSDz_Name    = "ƒail";
      string     __H_FailSDz_Text    = "𝙛?";
input color      __H_FailSDz_Color   = clrCrimson;
input LINE_STYLE __H_FailSDz_Style   = STYLE_DOT;
      int        __H_FailSDz_Width   = 1;
//--------------------------------------------
      string     __H_OFShift_Name    = "ofs";
      string     __H_OFShift_Text    = "𝙤𝙛𝙨";
input color      __H_OFShift_Color   = clrGreen;
input LINE_STYLE __H_OFShift_Style   = STYLE_DOT;
      int        __H_OFShift_Width   = 1;
//--------------------------------------------
      string     __H_BosLG_Name      = "b/lg";
      string     __H_BosLG_Text      = "𝙗𝙤𝙨/𝙡𝙜";
input color      __H_BosLG_Color     = clrCrimson;
input LINE_STYLE __H_BosLG_Style     = STYLE_SOLID;
      int        __H_BosLG_Width     = 2;
//--------------------------------------------
      string     __H_Target_Name     = "eof";
      string     __H_Target_Text     = "𝙚𝙤𝙛";
input color      __H_Target_Color    = clrGreen;
input LINE_STYLE __H_Target_Style    = STYLE_SOLID;
      int        __H_Target_Width    = 1;
//--------------------------------------------
      string     __H_BreakEvent_Name     = "be";
      string     __H_BreakEvent_Text     = "𝙗𝙚";
input color      __H_BreakEvent_Color    = clrGreen;
input LINE_STYLE __H_BreakEvent_Style    = STYLE_SOLID;
      int        __H_BreakEvent_Width    = 1;
//--------------------------------------------
//       string     __H_Partial_Name     = "pa";
//       string     __H_Partial_Text     = "pa";
// input color      __H_Partial_Color    = clrGreen;
// input LINE_STYLE __H_Partial_Style    = STYLE_SOLID;
//       int        __H_Partial_Width    = 1;
// //--------------------------------------------
//       string     __H_Pb_Sig_Name    = "PbSig";
//       string     __H_Pb_Sig_Text    = "pb";
// input color      __H_Pb_Sig_Color   = clrCrimson;
// input LINE_STYLE __H_Pb_Sig_Style   = STYLE_DOT;
//       int        __H_Pb_Sig_Width   = 1;
// //--------------------------------------------
//       string     __H_Mn_Sig_Name    = "MinorSig";
//       string     __H_Mn_Sig_Text    = "mn";
// input color      __H_Mn_Sig_Color   = clrGreen;
// input LINE_STYLE __H_Mn_Sig_Style   = STYLE_DOT;
//       int        __H_Mn_Sig_Width   = 1;
// //--------------------------------------------

enum HTrendType
{
    HTREND_BOS,
    // HTREND_SBOS,
    // HTREND_MBOS,
    HTREND_BOSLG,
    HTREND_LQGP,
    HTREND_FAIL,
    HTREND_OFS,
    // HTREND_PB_SIG,
    // HTREND_MN_SIG,
    HTREND_EOF,
    HTREND_BE,
    // HTREND_PA,
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
    virtual void onUserRequest(const string &itemId, const string &objId);
};

HTrend::HTrend(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [HTREND_BOS  ] = __H_MainBos_Name ;
    mPropText [HTREND_BOS  ] = __H_MainBos_Text ;
    mPropColor[HTREND_BOS  ] = __H_MainBos_Color;
    mPropStyle[HTREND_BOS  ] = __H_MainBos_Style;
    mPropWidth[HTREND_BOS  ] = __H_MainBos_Width;
    //--------------------------------------------
    // mNameType [HTREND_SBOS ] = __H_SubBos_Name ;
    // mPropText [HTREND_SBOS ] = __H_SubBos_Text ;
    // mPropColor[HTREND_SBOS ] = __H_SubBos_Color;
    // mPropStyle[HTREND_SBOS ] = __H_SubBos_Style;
    // mPropWidth[HTREND_SBOS ] = __H_SubBos_Width;
    // //--------------------------------------------
    // mNameType [HTREND_MBOS ] = __H_MinorBos_Name ;
    // mPropText [HTREND_MBOS ] = __H_MinorBos_Text ;
    // mPropColor[HTREND_MBOS ] = __H_MinorBos_Color;
    // mPropStyle[HTREND_MBOS ] = __H_MinorBos_Style;
    // mPropWidth[HTREND_MBOS ] = __H_MinorBos_Width;
    //--------------------------------------------
    mNameType [HTREND_LQGP ] = __H_LqGrap_Name ;
    mPropText [HTREND_LQGP ] = __H_LqGrap_Text ;
    mPropColor[HTREND_LQGP ] = __H_LqGrap_Color;
    mPropStyle[HTREND_LQGP ] = __H_LqGrap_Style;
    mPropWidth[HTREND_LQGP ] = __H_LqGrap_Width;
    //--------------------------------------------
    mNameType [HTREND_FAIL ] = __H_FailSDz_Name ;
    mPropText [HTREND_FAIL ] = __H_FailSDz_Text ;
    mPropColor[HTREND_FAIL ] = __H_FailSDz_Color;
    mPropStyle[HTREND_FAIL ] = __H_FailSDz_Style;
    mPropWidth[HTREND_FAIL ] = __H_FailSDz_Width;
    //--------------------------------------------
    mNameType [HTREND_OFS  ] = __H_OFShift_Name ;
    mPropText [HTREND_OFS  ] = __H_OFShift_Text ;
    mPropColor[HTREND_OFS  ] = __H_OFShift_Color;
    mPropStyle[HTREND_OFS  ] = __H_OFShift_Style;
    mPropWidth[HTREND_OFS  ] = __H_OFShift_Width;
    //--------------------------------------------
    mNameType [HTREND_BOSLG] = __H_BosLG_Name ;
    mPropText [HTREND_BOSLG] = __H_BosLG_Text ;
    mPropColor[HTREND_BOSLG] = __H_BosLG_Color;
    mPropStyle[HTREND_BOSLG] = __H_BosLG_Style;
    mPropWidth[HTREND_BOSLG] = __H_BosLG_Width;
    //--------------------------------------------
    mNameType [HTREND_EOF] = __H_Target_Name ;
    mPropText [HTREND_EOF] = __H_Target_Text ;
    mPropColor[HTREND_EOF] = __H_Target_Color;
    mPropStyle[HTREND_EOF] = __H_Target_Style;
    mPropWidth[HTREND_EOF] = __H_Target_Width;
    mPropWidth[HTREND_EOF] = __H_Target_Width;
    //--------------------------------------------
    mNameType [HTREND_BE] = __H_BreakEvent_Name ;
    mPropText [HTREND_BE] = __H_BreakEvent_Text ;
    mPropColor[HTREND_BE] = __H_BreakEvent_Color;
    mPropStyle[HTREND_BE] = __H_BreakEvent_Style;
    mPropWidth[HTREND_BE] = __H_BreakEvent_Width;
    mPropWidth[HTREND_BE] = __H_Target_Width;
    //--------------------------------------------
    // mNameType [HTREND_PA] = __H_Partial_Name ;
    // mPropText [HTREND_PA] = __H_Partial_Text ;
    // mPropColor[HTREND_PA] = __H_Partial_Color;
    // mPropStyle[HTREND_PA] = __H_Partial_Style;
    // mPropWidth[HTREND_PA] = __H_Partial_Width;
    // //--------------------------------------------
    // mNameType [HTREND_PB_SIG] = __H_Pb_Sig_Name ;
    // mPropText [HTREND_PB_SIG] = __H_Pb_Sig_Text ;
    // mPropColor[HTREND_PB_SIG] = __H_Pb_Sig_Color;
    // mPropStyle[HTREND_PB_SIG] = __H_Pb_Sig_Style;
    // mPropWidth[HTREND_PB_SIG] = __H_Pb_Sig_Width;
    // //--------------------------------------------
    // mNameType [HTREND_MN_SIG] = __H_Mn_Sig_Name ;
    // mPropText [HTREND_MN_SIG] = __H_Mn_Sig_Text ;
    // mPropColor[HTREND_MN_SIG] = __H_Mn_Sig_Color;
    // mPropStyle[HTREND_MN_SIG] = __H_Mn_Sig_Style;
    // mPropWidth[HTREND_MN_SIG] = __H_Mn_Sig_Width;
    //-----------------------------
    mIndexType = 0;
    mTypeNum   = HTREND_NUM;
    for (int i = 0; i < mTypeNum; i++)
    {
        mTemplateTypes += mNameType[i];
        if (i < mTypeNum-1) mTemplateTypes += ",";
    }
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
    ObjectSetText( cText     , mPropText [mIndexType], 8, "Consolas", mPropColor[mIndexType]);
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
    bool selected = (bool)ObjectGet(objId, OBJPROP_SELECTED);
    multiSetProp(OBJPROP_SELECTED, selected, cMainTrend+cText);
    if (objId == cText && selected == true)
    {
        gTemplates.openTemplates(objId, mTemplateTypes, -1);
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
void HTrend::onUserRequest(const string &itemId, const string &objId)
{
    activateItem(itemId);
    mIndexType = gTemplates.mActivePos;
    updateTypeProperty();
}