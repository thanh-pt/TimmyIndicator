#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

//--------------------------------------------
input string          F_i_b___C_o_m_m_o_n___Cfg = SEPARATE_LINE;
input color           __F_Bkgrd_Color = clrNONE;
input LINE_STYLE      __F_Style     = STYLE_SOLID;
input int             __F_Width     = 1;
//--------------------------------------------
input string          F_i_b___0___Cfg = SEPARATE_LINE;
input string          __F_0_Text  = "0";
input double          __F_0_Ratio = 0;
input color           __F_0_Color = clrGray;
//--------------------------------------------
input string          F_i_b___1___Cfg = SEPARATE_LINE;
input string          __F_1_Text  = "1";
input double          __F_1_Ratio = 1;
input color           __F_1_Color = clrGray;
//--------------------------------------------
input string          F_i_b___2___Cfg = SEPARATE_LINE;
input string          __F_2_Text  = "0.5";
input double          __F_2_Ratio = 0.5;
input color           __F_2_Color = clrGold;
//--------------------------------------------
      string          F_i_b___3___Cfg = SEPARATE_LINE;
      string          __F_3_Text  = "0.618";
      double          __F_3_Ratio = 0.618;
      color           __F_3_Color = clrNONE;
//--------------------------------------------
      string          F_i_b___4___Cfg = SEPARATE_LINE;
      string          __F_4_Text  = "-0.27";
      double          __F_4_Ratio = -0.27;
      color           __F_4_Color = clrDarkOrange;
//--------------------------------------------
      string          F_i_b___5___Cfg = SEPARATE_LINE;
      string          __F_5_Text  = "-0.62";
      double          __F_5_Ratio = -0.62;
      color           __F_5_Color = clrRed;

enum FibType
{
    FIB_FULL,
    FIB_RANGE,
    FIB_BUY0,
    FIB_SELL,
    FIB_NUM,
};

class Fibonacci : public BaseItem
{
// Internal Value
private:

// Component name
private:
    string ckLne;
    string iFib0;
    string iFib1;
    string iFib2;
    string iFib3;
    string iFib4;
    string iFib5;
    string iTxt0;
    string iTxt1;
    string iTxt2;
    string iTxt3;
    string iTxt4;
    string iTxt5;

    string cPointL1;
    string cPointL2;
    string cPointR1;
    string cPointR2;
    string cPointC1;
    string cPointC2;

// Value define for Item
private:
    datetime time0;
    datetime time1;
    double price0;
    double price1;

    double   centerPrice;
    datetime centerTime;

public:
    Fibonacci(const string name, CommonData* commonData, MouseInfo* mouseInfo);

// Internal Event
public:
    virtual void prepareActive();
    virtual void createItem();
    virtual void updateDefaultProperty();
    virtual void updateTypeProperty();
    virtual void activateItem(const string& itemId);
    virtual void updateItemAfterChangeType();
    virtual void refreshData();
    virtual void finishedJobDone();

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

Fibonacci::Fibonacci(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mIndexType = 0;
    mNameType[FIB_FULL] = "Fib Full";
    mNameType[FIB_RANGE] = "RANGE";
    mNameType[FIB_BUY0] = "BUY Block";
    mNameType[FIB_SELL] = "SELL Block";
    mTypeNum = FIB_NUM;
    for (int i = 0; i < FIB_NUM; i++)
    {
        mTemplateTypes += mNameType[i];
        if (i < FIB_NUM-1) mTemplateTypes += ",";
    }
}

// Internal Event
void Fibonacci::prepareActive(){}
void Fibonacci::createItem()
{
    if (__F_0_Color != clrNONE) ObjectCreate(iFib0, OBJ_TREND, 0, 0, 0);
    if (__F_1_Color != clrNONE) ObjectCreate(iFib1, OBJ_TREND, 0, 0, 0);
    if (__F_2_Color != clrNONE) ObjectCreate(iFib2, OBJ_TREND, 0, 0, 0);
    if (__F_3_Color != clrNONE) ObjectCreate(iFib3, OBJ_TREND, 0, 0, 0);
    if (__F_4_Color != clrNONE) ObjectCreate(iFib4, OBJ_TREND, 0, 0, 0);
    if (__F_5_Color != clrNONE) ObjectCreate(iFib5, OBJ_TREND, 0, 0, 0);
    //------------------------------------------
    if (__F_0_Color != clrNONE /*&& __F_0_Text != ""*/) ObjectCreate(iTxt0, OBJ_TEXT, 0, 0, 0);
    if (__F_1_Color != clrNONE /*&& __F_1_Text != ""*/) ObjectCreate(iTxt1, OBJ_TEXT, 0, 0, 0);
    if (__F_2_Color != clrNONE /*&& __F_2_Text != ""*/) ObjectCreate(iTxt2, OBJ_TEXT, 0, 0, 0);
    if (__F_3_Color != clrNONE /*&& __F_3_Text != ""*/) ObjectCreate(iTxt3, OBJ_TEXT, 0, 0, 0);
    if (__F_4_Color != clrNONE /*&& __F_4_Text != ""*/) ObjectCreate(iTxt4, OBJ_TEXT, 0, 0, 0);
    if (__F_5_Color != clrNONE /*&& __F_5_Text != ""*/) ObjectCreate(iTxt5, OBJ_TEXT, 0, 0, 0);
    ObjectCreate(ckLne, OBJ_RECTANGLE, 0, 0, 0);

    ObjectCreate(cPointL1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointL2, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointR1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointR2, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointC1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointC2, OBJ_ARROW, 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();

    time0  = pCommonData.mMouseTime;
    price0 = pCommonData.mMousePrice;
}
void Fibonacci::updateDefaultProperty()
{
    multiSetProp(OBJPROP_RAY          , false     , iFib0+iFib1+iFib2+iFib3+iFib4+iFib5);
    multiSetProp(OBJPROP_WIDTH        , __F_Width , iFib0+iFib1+iFib2+iFib3+iFib4+iFib5);
    multiSetProp(OBJPROP_STYLE        , __F_Style , iFib0+iFib1+iFib2+iFib3+iFib4+iFib5);
    multiSetProp(OBJPROP_SELECTABLE   , false     , iFib0+iFib1+iFib2+iFib3+iFib4+iFib5
                                                   +iTxt0+iTxt1+iTxt2+iTxt3+iTxt4+iTxt5);
    multiSetInts(OBJPROP_ANCHOR, ANCHOR_RIGHT     , iTxt0+iTxt1+iTxt2+iTxt3+iTxt4+iTxt5);

    multiSetProp(OBJPROP_ARROWCODE,       4, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);
    multiSetProp(OBJPROP_COLOR    , clrNONE, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);
    
    multiSetStrs(OBJPROP_TOOLTIP, "\n",
                            ckLne
                            +iFib0+iFib1+iFib2+iFib3+iFib4+iFib5
                            +iTxt0+iTxt1+iTxt2+iTxt3+iTxt4+iTxt5);
    
    multiSetStrs(OBJPROP_TOOLTIP   , "\n",
                            cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);
}
void Fibonacci::updateTypeProperty()
{
    ObjectSetText(iTxt0, __F_0_Text + "  ", 7, NULL, __F_0_Color);
    ObjectSetText(iTxt1, __F_1_Text + "  ", 7, NULL, __F_1_Color);
    ObjectSetText(iTxt2, __F_2_Text + "  ", 7, NULL, __F_2_Color);
    ObjectSetText(iTxt3, __F_3_Text + "  ", 7, NULL, __F_3_Color);
    ObjectSetText(iTxt4, __F_4_Text + "  ", 7, NULL, __F_4_Color);
    ObjectSetText(iTxt5, __F_5_Text + "  ", 7, NULL, __F_5_Color);
    //------------------------------------------
    SetRectangleBackground(ckLne, __F_Bkgrd_Color);
    multiSetProp(OBJPROP_RAY, false, iFib0+iFib1+iFib2+iFib3+iFib4+iFib5);
    //------------------------------------------
    ObjectSet(iFib0, OBJPROP_COLOR, __F_0_Color);
    ObjectSet(iFib1, OBJPROP_COLOR, __F_1_Color);
    ObjectSet(iFib2, OBJPROP_COLOR, __F_2_Color);
    ObjectSet(iFib3, OBJPROP_COLOR, __F_3_Color);
    ObjectSet(iFib4, OBJPROP_COLOR, __F_4_Color);
    ObjectSet(iFib5, OBJPROP_COLOR, __F_5_Color);

    if (mIndexType != FIB_FULL)
    {
        multiSetProp(OBJPROP_COLOR, clrNONE, iFib3+iFib4+iFib5 + iTxt3+iTxt4+iTxt5);
    }
    if (mIndexType == FIB_BUY0 || mIndexType == FIB_SELL)
    {
        multiSetProp(OBJPROP_COLOR, clrNONE, iTxt0+iTxt1+iTxt2);
    }
    if (mIndexType == FIB_RANGE)
    {
        ObjectSetText(iTxt0, "𝙇𝙤𝙬  " , 8);
        ObjectSetText(iTxt1, "𝙃𝙞𝙜𝙝  ", 8);
        ObjectSetText(iTxt2, "50%  ", 8);
        multiSetProp(OBJPROP_COLOR, clrGreen, iFib0+iTxt0);
        multiSetProp(OBJPROP_COLOR, clrRed  , iFib1+iTxt1);
        multiSetProp(OBJPROP_COLOR, clrDarkOrange, iFib2+iTxt2);
        multiSetProp(OBJPROP_RAY, true, iFib0+iFib1);
    }
    if (mIndexType == FIB_BUY0)
    {
        SetRectangleBackground(ckLne, __R_Dz_Color);
    }
    if (mIndexType == FIB_SELL)
    {
        SetRectangleBackground(ckLne, __R_Sz_Color);
    }
}
void Fibonacci::activateItem(const string& itemId)
{
    ckLne = itemId + "_c0Lne";
    iFib0 = itemId + "_iFib0";
    iFib1 = itemId + "_iFib1";
    iFib2 = itemId + "_iFib2";
    iFib3 = itemId + "_iFib3";
    iFib4 = itemId + "_iFib4";
    iFib5 = itemId + "_iFib5";
    iTxt0 = itemId + "_iTxt0";
    iTxt1 = itemId + "_iTxt1";
    iTxt2 = itemId + "_iTxt2";
    iTxt3 = itemId + "_iTxt3";
    iTxt4 = itemId + "_iTxt4";
    iTxt5 = itemId + "_iTxt5";

    cPointL1 = itemId + "_cPointL1";
    cPointL2 = itemId + "_cPointL2";
    cPointR1 = itemId + "_cPointR1";
    cPointR2 = itemId + "_cPointR2";
    cPointC1 = itemId + "_cPointC1";
    cPointC2 = itemId + "_cPointC2";
}
void Fibonacci::updateItemAfterChangeType()
{
    updateTypeProperty();
}
void Fibonacci::refreshData()
{
    double price2 = price1-__F_2_Ratio*(price1-price0);
    double price3 = price1-__F_3_Ratio*(price1-price0);
    double price4 = price1-__F_4_Ratio*(price1-price0);
    double price5 = price1-__F_5_Ratio*(price1-price0);
    //-------------------------------------------------
    setItemPos(ckLne, time0, time1, price0, price1);
    setItemPos(iFib0, time0, time1, price0, price0);
    setItemPos(iFib1, time0, time1, price1, price1);
    setItemPos(iFib2, time0, time1, price2, price2);
    setItemPos(iFib3, time0, time1, price3, price3);
    setItemPos(iFib4, time0, time1, price4, price4);
    setItemPos(iFib5, time0, time1, price5, price5);
    //-------------------------------------------------
    setTextPos(iTxt0, time0, price0);
    setTextPos(iTxt1, time0, price1);
    setTextPos(iTxt2, time0, price2);
    setTextPos(iTxt3, time0, price3);
    setTextPos(iTxt4, time0, price4);
    setTextPos(iTxt5, time0, price5);
    //-------------------------------------------------
    getCenterPos(time0, time1, price0, price1, centerTime, centerPrice);

    setItemPos(cPointL1, time0, price0);
    setItemPos(cPointL2, time0, price1);
    setItemPos(cPointR1, time1, price0);
    setItemPos(cPointR2, time1, price1);
    setItemPos(cPointC1, time0, centerPrice);
    setItemPos(cPointC2, time1, centerPrice);
    //-------------------------------------------------
    int selected = (int)ObjectGet(ckLne, OBJPROP_SELECTED);
    multiSetProp(OBJPROP_COLOR   , selected ? gColorMousePoint : clrNONE, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);
    multiSetProp(OBJPROP_SELECTED, selected, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2+ckLne);
}
void Fibonacci::finishedJobDone(){}

// Chart Event
void Fibonacci::onMouseMove()
{
    if (mFirstPoint == false)
    {
        return;
    }
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
    refreshData();
}
void Fibonacci::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void Fibonacci::onItemDrag(const string &itemId, const string &objId)
{
    if (objId == ckLne)
    {
        time0   = (datetime)ObjectGet(ckLne, OBJPROP_TIME1);
        time1   = (datetime)ObjectGet(ckLne, OBJPROP_TIME2);
        price0  =           ObjectGet(ckLne, OBJPROP_PRICE1);
        price1  =           ObjectGet(ckLne, OBJPROP_PRICE2);
    }
    else
    {
        if (pCommonData.mCtrlHold)
        {
            if (objId == cPointL1 || objId == cPointR2 || objId == cPointL2 || objId == cPointR1) ObjectSet(objId, OBJPROP_PRICE1, pCommonData.mMousePrice);
        }

        if (objId == cPointL1 || objId == cPointR2 )
        {
            time0  = (datetime)ObjectGet(cPointL1, OBJPROP_TIME1);
            price0 =           ObjectGet(cPointL1, OBJPROP_PRICE1);
            time1  = (datetime)ObjectGet(cPointR2, OBJPROP_TIME1);
            price1 =           ObjectGet(cPointR2, OBJPROP_PRICE1);
        }
        else if (objId == cPointL2 || objId == cPointR1)
        {
            time0  = (datetime)ObjectGet(cPointL2, OBJPROP_TIME1);
            price1 =           ObjectGet(cPointL2, OBJPROP_PRICE1);
            time1  = (datetime)ObjectGet(cPointR1, OBJPROP_TIME1);
            price0 =           ObjectGet(cPointR1, OBJPROP_PRICE1);
        }
        else
        {
            time0  = (datetime)ObjectGet(cPointL1, OBJPROP_TIME1);
            price0 =           ObjectGet(cPointL1, OBJPROP_PRICE1);
            time1  = (datetime)ObjectGet(cPointR2, OBJPROP_TIME1);
            price1 =           ObjectGet(cPointR2, OBJPROP_PRICE1);
            if (objId == cPointC1)
            {
                time0 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
            }
            else if (objId == cPointC2)
            {
                time1 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
            }
        }
    }

    refreshData();
}
void Fibonacci::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, "_c") == -1) return;

    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    multiSetProp(OBJPROP_COLOR   , selected ? gColorMousePoint : clrNONE, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);
    multiSetProp(OBJPROP_SELECTED, selected, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2+ckLne);
    if (selected)
    {
        unSelectAllExcept(itemId);
        if (objId == cPointC1 || objId == cPointC2)
            gTemplates.openTemplates(objId, mTemplateTypes, -1);
    }
}
void Fibonacci::onItemChange(const string &itemId, const string &objId){}
void Fibonacci::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(ckLne);
    ObjectDelete(iFib0);
    ObjectDelete(iFib1);
    ObjectDelete(iFib2);
    ObjectDelete(iFib3);
    ObjectDelete(iFib4);
    ObjectDelete(iFib5);
    ObjectDelete(iTxt0);
    ObjectDelete(iTxt1);
    ObjectDelete(iTxt2);
    ObjectDelete(iTxt3);
    ObjectDelete(iTxt4);
    ObjectDelete(iTxt5);
}
void Fibonacci::onUserRequest(const string &itemId, const string &objId)
{
    activateItem(itemId);
    mIndexType = gTemplates.mActivePos;
    updateTypeProperty();
}