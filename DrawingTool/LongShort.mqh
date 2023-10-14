#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

#define LONG_IDX 0

enum e_display
{
    HIDE,
    SHOW,
    OPTION,
};

input string          _7 = "";
//-------------------------------------------------
input color           LS_TextColor     = clrMidnightBlue;
input int             LS_TextSize      = 8;
input color           LS_TpColor       = clrSteelBlue;
input color           LS_SlColor       = clrChocolate;
input color           LS_EnColor       = clrChocolate;
input int             LS_LineWidth     = 1;
input color           LS_SlBkgrdColor  = clrLavenderBlush;
input color           LS_TpBkgrdColor  = clrWhiteSmoke;
//-------------------------------------------------
input double          LS_Cost          = 5;
input e_display       LS_ShowStats     = SHOW;
input e_display       LS_ShowPrice     = OPTION;
input e_display       LS_ShowDollar    = HIDE;
input bool            LS_ShowModel     = false;

class LongShort : public BaseItem
{
// Internal Value
private:
double mTradeLot;

// Component name
private:
    string iBgndSL  ;
    string iBgndTP  ;
    string iTpLine  ;
    string iEnLine  ;
    string iSlLine  ;
    string iBeLine  ;
    string iTpPrice ;
    string iEnPrice ;
    string iSlPrice ;
    string iTpText  ;
    string iEnText  ;
    string iSlText  ;
    string iBeText  ;
    string iMdlTxt  ;
    string cBoder   ;
    string cPointTP ;
    string cPointSL ;
    string cPointEN ;
    string cPointWD ;
    string cPointBE ;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double priceTP;
    double priceEN;
    double priceSL;
    double priceBE;

public:
    LongShort(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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
// Special functional
    void showHistory(bool isShow);

// Alpha feature
    void initData();
};

LongShort::LongShort(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [0] = "Long";
    mNameType [1] = "Short";
    mIndexType = 0;
    mTypeNum = 2;
}

// Internal Event
void LongShort::prepareActive(){}
void LongShort::createItem()
{
    ObjectCreate(iBgndSL  , OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(iBgndTP  , OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(iTpLine  , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iBeLine  , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iEnLine  , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iSlLine  , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iTpPrice , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iEnPrice , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iSlPrice , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iTpText  , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iEnText  , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iSlText  , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iBeText  , OBJ_TEXT      , 0, 0, 0);
    if (LS_ShowModel) ObjectCreate(iMdlTxt  , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(cBoder   , OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(cPointTP , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPointSL , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPointEN , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPointWD , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPointBE , OBJ_ARROW     , 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();
}
void LongShort::initData()
{
    time1   = pCommonData.mMouseTime;
    priceEN = pCommonData.mMousePrice;
    static int wd = 0;
    ChartXYToTimePrice(ChartID(), (int)pCommonData.mMouseX+100, (int)pCommonData.mMouseY+(mIndexType == LONG_IDX ? 50:-50), wd,  time2, priceSL);
    priceTP = 4*priceEN - 3*priceSL;
    priceBE = 2*priceEN - 1*priceSL;
}
void LongShort::updateDefaultProperty()
{
    ObjectSetText(iMdlTxt, "Model-??", LS_TextSize+1, "Consolas", LS_TextColor);
    //-------------------------------------------------
    ObjectSet(iBgndSL, OBJPROP_BACK, true);
    ObjectSet(iBgndTP, OBJPROP_BACK, true);
    //-------------------------------------------------
    ObjectSet(cBoder, OBJPROP_BACK, false);
    ObjectSet(cBoder, OBJPROP_COLOR, clrNONE);
    //-------------------------------------------------
    multiSetProp(OBJPROP_ARROWCODE , 4    , cPointWD+cPointBE);
    multiSetProp(OBJPROP_ARROWCODE , 4    , cPointTP+cPointSL);
    ObjectSet(cPointEN, OBJPROP_ARROWCODE, 4);
    
    multiSetProp(OBJPROP_SELECTED  , true , cPointTP+cPointSL+cPointEN+cPointWD+cPointBE);
    multiSetProp(OBJPROP_RAY       , false, iTpLine+iBeLine+iEnLine+iSlLine);
    multiSetProp(OBJPROP_SELECTABLE, false, iBgndSL+iBgndTP+iTpLine+iBeLine+iEnLine+iSlLine+iTpPrice+iEnPrice+iSlPrice+iTpText+iEnText+iSlText+iBeText);
    //-------------------------------------------------
    multiSetStrs(OBJPROP_TOOLTIP, "\n", iBgndSL+iBgndTP+iTpLine+iBeLine+iEnLine+iSlLine+iTpPrice+iEnPrice+iSlPrice+iTpText+iEnText+iSlText+iBeText+iMdlTxt+cBoder+cPointTP+cPointSL+cPointEN+cPointWD+cPointBE);
}
void LongShort::updateTypeProperty()
{
    ObjectSet(iBgndSL, OBJPROP_COLOR, LS_SlBkgrdColor);
    ObjectSet(iBgndTP, OBJPROP_COLOR, LS_TpBkgrdColor);
    ObjectSet(iBeLine, OBJPROP_WIDTH, 1);
    ObjectSet(iBeLine, OBJPROP_STYLE, 2);
    //-------------------------------------------------
    multiSetProp(OBJPROP_COLOR, LS_TpColor  , iTpLine+iBeLine+cPointTP+cPointBE);
    multiSetProp(OBJPROP_COLOR, LS_EnColor  , iEnLine+cPointEN+cPointWD);
    multiSetProp(OBJPROP_COLOR, LS_SlColor  , iSlLine+cPointSL);
    multiSetProp(OBJPROP_COLOR, LS_TextColor, iTpText+iEnText+iSlText+iBeText+iTpPrice+iEnPrice+iSlPrice);
    //-------------------------------------------------
    multiSetProp(OBJPROP_WIDTH   , LS_LineWidth, iTpLine+iEnLine+iSlLine);
    multiSetProp(OBJPROP_FONTSIZE, LS_TextSize , iTpPrice+iEnPrice+iSlPrice+iTpText+iEnText+iSlText+iBeText+iTpPrice+iEnPrice+iSlPrice);
}
void LongShort::activateItem(const string& itemId)
{
    iBgndSL  = itemId + "_iBgndSL";
    iBgndTP  = itemId + "_iBgndTP";
    iTpLine  = itemId + "_iTpLine";
    iEnLine  = itemId + "_iEnLine";
    iSlLine  = itemId + "_iSlLine";
    iBeLine  = itemId + "_iBeLine";
    iTpPrice = itemId + "_iTpPrice";
    iEnPrice = itemId + "_iEnPrice";
    iSlPrice = itemId + "_iSlPrice";
    iTpText  = itemId + "_iTpText";
    iEnText  = itemId + "_iEnText";
    iSlText  = itemId + "_iSlText";
    iBeText  = itemId + "_iBeText";
    iMdlTxt  = itemId + "_iMdlTxt";
    cBoder   = itemId + "_cBoder";
    cPointTP = itemId + "_cPointTP";
    cPointSL = itemId + "_cPointSL";
    cPointEN = itemId + "_c0PointEN";
    cPointWD = itemId + "_ckPointWD";
    cPointBE = itemId + "_cPointBE";
}
void LongShort::updateItemAfterChangeType(){}
void LongShort::refreshData()
{
    if (ObjectFind(ChartID(), iBgndSL) < 0)
    {
        createItem();
    }
    datetime centerTime = getCenterTime(time1, time2);
    
    setItemPos(iBgndSL  , time1, time2, priceEN, priceSL);
    setItemPos(iBgndTP  , time1, time2, priceEN, priceTP);
    setItemPos(cBoder   , time1, time2, priceSL, priceTP);
    setItemPos(iTpLine  , time1, time2, priceTP, priceTP);
    setItemPos(iEnLine  , time1, time2, priceEN, priceEN);
    setItemPos(iSlLine  , time1, time2, priceSL, priceSL);
    setItemPos(iBeLine  , time1, time2, priceBE, priceBE);
    //-------------------------------------------------
    setItemPos(cPointTP , time2, priceTP);
    setItemPos(cPointSL , time2, priceSL);
    setItemPos(cPointEN , time1, priceEN);
    setItemPos(cPointWD , time2, priceEN);
    setItemPos(cPointBE , time2, priceBE);
    //-------------------------------------------------
    setItemPos(iTpText  , centerTime, priceTP);
    setItemPos(iEnText  , centerTime, priceEN);
    setItemPos(iSlText  , centerTime, priceSL);
    setItemPos(iBeText  , time2, priceBE);
    //-------------------------------------------------
    ObjectSetInteger(0,iMdlTxt, OBJPROP_ANCHOR, ANCHOR_CENTER);
    setItemPos(iMdlTxt  , centerTime, (priceSL+priceEN)/2);
    //-------------------------------------------------
    ObjectSetInteger(0, iEnText, OBJPROP_ANCHOR, ANCHOR_LOWER);
    if (priceTP > priceSL)
    {
        ObjectSetInteger(0, iSlText, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(0, iTpText, OBJPROP_ANCHOR, ANCHOR_LOWER);
        ObjectSetInteger(0, iBeText, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
        ObjectSetInteger(0,iTpPrice, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(0,iEnPrice, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(0,iSlPrice, OBJPROP_ANCHOR, ANCHOR_LOWER);
    }
    else
    {
        ObjectSetInteger(0, iSlText, OBJPROP_ANCHOR, ANCHOR_LOWER);
        ObjectSetInteger(0, iTpText, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(0, iBeText, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
        ObjectSetInteger(0,iTpPrice, OBJPROP_ANCHOR, ANCHOR_LOWER);
        ObjectSetInteger(0,iEnPrice, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(0,iSlPrice, OBJPROP_ANCHOR, ANCHOR_UPPER);
    }
    //-------------------------------------------------
    if (priceEN == priceSL) return;
    string strTpInfo   = ""; // RR + dola
    string strEnInfo   = ""; // lot 
    string strSlInfo   = ""; // pip + dola
    string strBeInfo   = ObjectDescription(cPointBE); // RR1
    double slPip       = 10000*MathAbs(priceEN-priceSL);
    double rr          = (priceTP-priceEN) / (priceEN-priceSL);
    double be          = (priceBE-priceEN) / (priceEN-priceSL);
    mTradeLot          = NormalizeDouble((LS_Cost/slPip/10),2);
    double realCost    = mTradeLot*slPip*10;
    bool   selectState = (bool)ObjectGet(cPointWD, OBJPROP_SELECTED);
    bool   showStats   = (LS_ShowStats  == SHOW) || (LS_ShowStats  == OPTION && selectState);
    bool   showPrice   = (LS_ShowPrice  == SHOW) || (LS_ShowPrice  == OPTION && selectState);
    bool   showDollar  = (LS_ShowDollar == SHOW) || (LS_ShowDollar == OPTION && selectState);
    if (showStats)
    {
        if (strBeInfo != "") strBeInfo += ": ";
        strTpInfo += DoubleToString(rr,1) + "ʀ";
        strBeInfo += DoubleToString(be,1) + "ʀ  ";
        strSlInfo += DoubleToString(slPip, 1) + "ᖰ";
    }
    //-------------------------------------------------
    if (showDollar)
    {
        if (showStats)
        {
            strTpInfo += " ~ ";
            strSlInfo += " ~ ";
        }
        strTpInfo += DoubleToString(rr*realCost, 2) + "$";
        strSlInfo += DoubleToString(realCost, 2) + "$";
    }
    //-------------------------------------------------
    if (showPrice)
    {
        ObjectSetText(iTpPrice, DoubleToString(priceTP,5));
        ObjectSetText(iEnPrice, DoubleToString(priceEN,5));
        ObjectSetText(iSlPrice, DoubleToString(priceSL,5));
        strEnInfo += DoubleToString(mTradeLot,2) + "lot";
    }
    else
    {
        ObjectSetText(iTpPrice, "");
        ObjectSetText(iEnPrice, "");
        ObjectSetText(iSlPrice, "");
    }
    
    setTextPos(iTpPrice, centerTime, priceTP);
    setTextPos(iEnPrice, centerTime, priceEN);
    setTextPos(iSlPrice, centerTime, priceSL);
    //-------------------------------------------------
    ObjectSetText(iTpText, strTpInfo);
    ObjectSetText(iEnText, strEnInfo);
    ObjectSetText(iSlText, strSlInfo);
    ObjectSetText(iBeText, strBeInfo);
    //scanBackgroundOverlap(iBgndSL);
    //scanBackgroundOverlap(iBgndTP);

}
void LongShort::finishedJobDone(){}

// Chart Event
void LongShort::onMouseMove(){}
void LongShort::onMouseClick()
{
    createItem();
    initData();
    refreshData();
    mFinishedJobCb();
}
void LongShort::onItemDrag(const string &itemId, const string &objId)
{
    priceTP =           ObjectGet(cPointTP, OBJPROP_PRICE1);
    priceEN =           ObjectGet(cPointEN, OBJPROP_PRICE1);
    priceSL =           ObjectGet(cPointSL, OBJPROP_PRICE1);
    priceBE =           ObjectGet(cPointBE, OBJPROP_PRICE1);
    time1   = (datetime)ObjectGet(cPointEN, OBJPROP_TIME1);
    time2   = (datetime)ObjectGet(cPointWD, OBJPROP_TIME1);
    if (objId == cBoder)
    {
        datetime newtime1 = (datetime)ObjectGet(cBoder, OBJPROP_TIME1);
        datetime newtime2 = (datetime)ObjectGet(cBoder, OBJPROP_TIME2);
        double newtpPrice =           ObjectGet(cBoder, OBJPROP_PRICE2);
        double newslPrice =           ObjectGet(cBoder, OBJPROP_PRICE1);

        if ((newtime1 == time1 && newslPrice == priceSL) || (newtime2 == time2 && newtpPrice == priceTP))
        {
            // move edge -> ignore
        }
        else
        {
            priceBE += (newtpPrice-priceTP);
            priceEN += (newtpPrice-priceTP);
            priceSL = newslPrice;
            priceTP = newtpPrice;
            time1 = newtime1;
            time2 = newtime2;
        }
    }
    else
    {
        if (pCommonData.mCtrlHold == true)
        {
            if      (objId == cPointTP) priceTP = pCommonData.mMousePrice;
            else if (objId == cPointEN) priceEN = pCommonData.mMousePrice;
            else if (objId == cPointSL) priceSL = pCommonData.mMousePrice;
            else if (objId == cPointBE) priceBE = pCommonData.mMousePrice;
        }
    }
    refreshData();
}
void LongShort::onItemClick(const string &itemId, const string &objId)
{
    int selectState = (int)ObjectGet(objId, OBJPROP_SELECTED);
    if (objId == cPointTP || objId == cPointSL || objId == cPointEN || objId == cPointWD || objId == cPointBE)
    {
        ObjectSet(cPointTP, OBJPROP_SELECTED, selectState);
        ObjectSet(cPointSL, OBJPROP_SELECTED, selectState);
        ObjectSet(cPointEN, OBJPROP_SELECTED, selectState);
        ObjectSet(cPointWD, OBJPROP_SELECTED, selectState);
        ObjectSet(cPointBE, OBJPROP_SELECTED, selectState);
    }
    onItemDrag(itemId, objId);
    if (objId == cPointWD && selectState == true && (int)ObjectGet(cBoder, OBJPROP_SELECTED) == true && LS_ShowPrice  != HIDE)
    {
        string buySell = "Sell";
        if (priceTP > priceEN) buySell = "Buy";
        Alert(buySell + ": " + DoubleToString(mTradeLot,2) + "\nEn: " + DoubleToString(priceEN,5) + "\nSL: " + DoubleToString(priceSL,5) + "\nTP: " + DoubleToString(priceTP,5));
    }
}
void LongShort::onItemChange(const string &itemId, const string &objId)
{
    onItemDrag(itemId, objId);
    refreshData();
}
void LongShort::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(iBgndSL );
    ObjectDelete(iBgndTP );
    ObjectDelete(iTpLine );
    ObjectDelete(iBeLine );
    ObjectDelete(iEnLine );
    ObjectDelete(iSlLine );
    ObjectDelete(iTpPrice);
    ObjectDelete(iEnPrice);
    ObjectDelete(iSlPrice);
    ObjectDelete(iTpText );
    ObjectDelete(iEnText );
    ObjectDelete(iSlText );
    ObjectDelete(iBeText );
    ObjectDelete(iMdlTxt );
    ObjectDelete(cBoder  );
    ObjectDelete(cPointTP);
    ObjectDelete(cPointSL);
    ObjectDelete(cPointEN);
    ObjectDelete(cPointWD);
    ObjectDelete(cPointBE);
}

//-------------------------------------------------------------------
void LongShort::showHistory(bool isShow)
{
    for (int i = ObjectsTotal() - 1; i >= 0; i--)
    {
        string objName = ObjectName(i);
        if (StringFind(objName, "ckPointWD") == -1)
        {
            continue;
        }
        string sparamItems[];
        int k=StringSplit(objName,'_',sparamItems);
        if (k != 3 || sparamItems[0] != mItemName)
        {
            continue;
        }
        string objId = sparamItems[0] + "_" + sparamItems[1];
        activateItem(objId);
        if (isShow)
        {
            priceTP =           ObjectGet(cPointTP, OBJPROP_PRICE1);
            priceEN =           ObjectGet(cPointEN, OBJPROP_PRICE1);
            priceSL =           ObjectGet(cPointSL, OBJPROP_PRICE1);
            priceBE =           ObjectGet(cPointBE, OBJPROP_PRICE1);
            time1   = (datetime)ObjectGet(cBoder, OBJPROP_TIME1);
            time2   = (datetime)ObjectGet(cBoder, OBJPROP_TIME2);
            refreshData();
            continue;
        }
        
        if ((bool)ObjectGet(cPointWD, OBJPROP_SELECTED))
        {
            continue;
        }
        // Hide Item
        ObjectSet(iBgndSL , OBJPROP_PRICE1, 0);
        ObjectSet(iBgndTP , OBJPROP_PRICE1, 0);
        ObjectSet(iTpLine , OBJPROP_PRICE1, 0);
        ObjectSet(iBeLine , OBJPROP_PRICE1, 0);
        ObjectSet(iEnLine , OBJPROP_PRICE1, 0);
        ObjectSet(iSlLine , OBJPROP_PRICE1, 0);
        ObjectSet(cBoder  , OBJPROP_PRICE1, 0);
        ObjectSet(iBgndSL , OBJPROP_PRICE2, 0);
        ObjectSet(iBgndTP , OBJPROP_PRICE2, 0);
        ObjectSet(iTpLine , OBJPROP_PRICE2, 0);
        ObjectSet(iBeLine , OBJPROP_PRICE2, 0);
        ObjectSet(iEnLine , OBJPROP_PRICE2, 0);
        ObjectSet(iSlLine , OBJPROP_PRICE2, 0);
        ObjectSet(cBoder  , OBJPROP_PRICE2, 0);

        ObjectSet(iTpPrice, OBJPROP_TIME1, 0);
        ObjectSet(iEnPrice, OBJPROP_TIME1, 0);
        ObjectSet(iSlPrice, OBJPROP_TIME1, 0);
        ObjectSet(iTpText , OBJPROP_TIME1, 0);
        ObjectSet(iEnText , OBJPROP_TIME1, 0);
        ObjectSet(iSlText , OBJPROP_TIME1, 0);
        ObjectSet(iBeText , OBJPROP_TIME1, 0);
        ObjectSet(iMdlTxt , OBJPROP_TIME1, 0);
        ObjectSet(cPointTP, OBJPROP_TIME1, 0);
        ObjectSet(cPointSL, OBJPROP_TIME1, 0);
        ObjectSet(cPointEN, OBJPROP_TIME1, 0);
        ObjectSet(cPointWD, OBJPROP_TIME1, 0);
        ObjectSet(cPointBE, OBJPROP_TIME1, 0);
        
        //removeBackgroundOverlap(iBgndSL);
        //removeBackgroundOverlap(iBgndTP);
    }
}
