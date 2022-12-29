#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

#define LONG_IDX 0

enum e_display
{
    HIDE,
    SHOW,
    SHOW_WHEN_SELECTED,
};

input string          LongShort_ = "LongShort Config";
input color           LongShort_TextColor = clrWhite;
input int             LongShort_TextSize  = 8;
input color           LongShort_TpColor   = clrYellowGreen;
input color           LongShort_SlColor   = clrRed;
input color           LongShort_EnColor   = clrOrange;
input int             LongShort_LineWidth = 1;
input color           LongShort_SlBkgrdColor = C'80,50,70';
input color           LongShort_TpBkgrdColor = C'40,80,70';
//-------------------------------------------------
input double          LongShort_Cost       = 50;
input e_display       LongShort_ShowStats  = SHOW;
input e_display       LongShort_ShowPrice  = SHOW;
input e_display       LongShort_ShowDollar = SHOW;

class LongShort : public BaseItem
{
// Internal Value
private:

// Component name
private:
    string cBgndSL  ;
    string cBgndTP  ;
    string cTpLine  ;
    string cEnLine  ;
    string cSlLine  ;
    string cTpPrice ;
    string cEnPrice ;
    string cSlPrice ;
    string cTpText  ;
    string cEnText  ;
    string cSlText  ;
    string cBoder   ;
    string cPointTP ;
    string cPointSL ;
    string cPointEN ;
    string cPointWD ;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double priceTP;
    double priceEN;
    double priceSL;

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
void LongShort::prepareActive()
{
    pMouseInfo.setText(mNameType[mIndexType]);
}
void LongShort::createItem()
{
    ObjectCreate(cBgndSL  , OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(cBgndTP  , OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(cTpLine  , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(cEnLine  , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(cSlLine  , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(cTpPrice , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cEnPrice , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cSlPrice , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cTpText  , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(cEnText  , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(cSlText  , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(cBoder   , OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(cPointTP , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPointSL , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPointEN , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPointWD , OBJ_ARROW     , 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();

    time1   = pCommonData.mMouseTime;
    priceEN = pCommonData.mMousePrice;
    static int wd = 0;
    ChartXYToTimePrice(0, (int)pCommonData.mMouseX+100, (int)pCommonData.mMouseY+(mIndexType == LONG_IDX ? 50:-50), wd,  time2, priceSL);
    priceTP = 4*priceEN - 3*priceSL;
}
void LongShort::updateDefaultProperty()
{
    ObjectSet(cBgndSL, OBJPROP_BACK, true);
    ObjectSet(cBgndTP, OBJPROP_BACK, true);
    //-------------------------------------------------
    ObjectSet(cBoder, OBJPROP_BACK, false);
    ObjectSet(cBoder, OBJPROP_COLOR, clrNONE);
    //-------------------------------------------------
    ObjectSet(cPointTP, OBJPROP_ARROWCODE, 4);
    ObjectSet(cPointSL, OBJPROP_ARROWCODE, 4);
    ObjectSet(cPointEN, OBJPROP_ARROWCODE, 4);
    ObjectSet(cPointWD, OBJPROP_ARROWCODE, 4);
    ObjectSet(cTpPrice, OBJPROP_ARROWCODE, 6);
    ObjectSet(cEnPrice, OBJPROP_ARROWCODE, 6);
    ObjectSet(cSlPrice, OBJPROP_ARROWCODE, 6);
    //-------------------------------------------------
    ObjectSet(cPointTP, OBJPROP_SELECTED, true);
    ObjectSet(cPointSL, OBJPROP_SELECTED, true);
    ObjectSet(cPointEN, OBJPROP_SELECTED, true);
    ObjectSet(cPointWD, OBJPROP_SELECTED, true);
    //-------------------------------------------------
    ObjectSet(cTpLine, OBJPROP_RAY, false);
    ObjectSet(cEnLine, OBJPROP_RAY, false);
    ObjectSet(cSlLine, OBJPROP_RAY, false);
    //-------------------------------------------------
    ObjectSet(cBgndSL  , OBJPROP_SELECTABLE, 0);
    ObjectSet(cBgndTP  , OBJPROP_SELECTABLE, 0);
    ObjectSet(cTpLine  , OBJPROP_SELECTABLE, 0);
    ObjectSet(cEnLine  , OBJPROP_SELECTABLE, 0);
    ObjectSet(cSlLine  , OBJPROP_SELECTABLE, 0);
    ObjectSet(cTpPrice , OBJPROP_SELECTABLE, 0);
    ObjectSet(cEnPrice , OBJPROP_SELECTABLE, 0);
    ObjectSet(cSlPrice , OBJPROP_SELECTABLE, 0);
    ObjectSet(cTpText  , OBJPROP_SELECTABLE, 0);
    ObjectSet(cEnText  , OBJPROP_SELECTABLE, 0);
    ObjectSet(cSlText  , OBJPROP_SELECTABLE, 0);
    //-------------------------------------------------
    ObjectSetString(ChartID(), cBgndSL  ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cBgndTP  ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cTpLine  ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cEnLine  ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cSlLine  ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cTpPrice ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cEnPrice ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cSlPrice ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cTpText  ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cEnText  ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cSlText  ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cBoder   ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cPointTP ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cPointSL ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cPointEN ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cPointWD ,OBJPROP_TOOLTIP,"\n");
}
void LongShort::updateTypeProperty()
{
    ObjectSet(cTpPrice , OBJPROP_COLOR, LongShort_TpColor);
    ObjectSet(cEnPrice , OBJPROP_COLOR, LongShort_EnColor);
    ObjectSet(cSlLine  , OBJPROP_COLOR, LongShort_SlColor);

    ObjectSet(cBgndSL  , OBJPROP_COLOR, LongShort_SlBkgrdColor);
    ObjectSet(cBgndTP  , OBJPROP_COLOR, LongShort_TpBkgrdColor);
    ObjectSet(cTpLine  , OBJPROP_COLOR, LongShort_TpColor);
    ObjectSet(cPointTP , OBJPROP_COLOR, LongShort_TpColor);
    ObjectSet(cEnLine  , OBJPROP_COLOR, LongShort_EnColor);
    ObjectSet(cPointEN , OBJPROP_COLOR, LongShort_EnColor);
    ObjectSet(cPointWD , OBJPROP_COLOR, LongShort_EnColor);
    ObjectSet(cPointSL , OBJPROP_COLOR, LongShort_SlColor);
    ObjectSet(cSlPrice , OBJPROP_COLOR, LongShort_SlColor);
    
    ObjectSet(cEnText  , OBJPROP_COLOR, LongShort_TextColor);
    ObjectSet(cSlText  , OBJPROP_COLOR, LongShort_TextColor);
    ObjectSet(cTpText  , OBJPROP_COLOR, LongShort_TextColor);
    //-------------------------------------------------
    ObjectSet(cTpLine, OBJPROP_WIDTH, LongShort_LineWidth);
    ObjectSet(cEnLine, OBJPROP_WIDTH, LongShort_LineWidth);
    ObjectSet(cSlLine, OBJPROP_WIDTH, LongShort_LineWidth);
    //-------------------------------------------------
    ObjectSet(cTpPrice, OBJPROP_FONTSIZE, LongShort_TextSize);
    ObjectSet(cEnPrice, OBJPROP_FONTSIZE, LongShort_TextSize);
    ObjectSet(cSlPrice, OBJPROP_FONTSIZE, LongShort_TextSize);
    ObjectSet(cTpText , OBJPROP_FONTSIZE, LongShort_TextSize);
    ObjectSet(cEnText , OBJPROP_FONTSIZE, LongShort_TextSize);
    ObjectSet(cSlText , OBJPROP_FONTSIZE, LongShort_TextSize);
}
void LongShort::activateItem(const string& itemId)
{
    cBgndSL  = itemId + "_BgndSL";
    cBgndTP  = itemId + "_BgndTP";
    cTpLine  = itemId + "_TpLine";
    cEnLine  = itemId + "_EnLine";
    cSlLine  = itemId + "_SlLine";
    cTpPrice = itemId + "_TpPrice";
    cEnPrice = itemId + "_EnPrice";
    cSlPrice = itemId + "_SlPrice";
    cTpText  = itemId + "_TpText";
    cEnText  = itemId + "_EnText";
    cSlText  = itemId + "_SlText";
    cBoder   = itemId + "_Boder";
    cPointTP = itemId + "_PointTP";
    cPointSL = itemId + "_PointSL";
    cPointEN = itemId + "_PointEN";
    cPointWD = itemId + "_PointWD";
}
void LongShort::updateItemAfterChangeType(){}
void LongShort::refreshData()
{
    datetime centerTime = getCenterTime(time1, time2);
    ObjectSet(cBgndSL, OBJPROP_TIME1,  time1);
    ObjectSet(cBgndSL, OBJPROP_TIME2,  time2);
    ObjectSet(cBgndSL, OBJPROP_PRICE1, priceEN);
    ObjectSet(cBgndSL, OBJPROP_PRICE2, priceSL);
    //-------------------------------------------------
    ObjectSet(cBgndTP, OBJPROP_TIME1,  time1);
    ObjectSet(cBgndTP, OBJPROP_TIME2,  time2);
    ObjectSet(cBgndTP, OBJPROP_PRICE1, priceEN);
    ObjectSet(cBgndTP, OBJPROP_PRICE2, priceTP);
    //-------------------------------------------------
    ObjectSet(cBoder , OBJPROP_TIME1,  time1);
    ObjectSet(cBoder , OBJPROP_TIME2,  time2);
    ObjectSet(cBoder , OBJPROP_PRICE1, priceSL);
    ObjectSet(cBoder , OBJPROP_PRICE2, priceTP);
    //-------------------------------------------------
    ObjectSet(cTpLine, OBJPROP_TIME1,  time1);
    ObjectSet(cTpLine, OBJPROP_TIME2,  time2);
    ObjectSet(cTpLine, OBJPROP_PRICE1, priceTP);
    ObjectSet(cTpLine, OBJPROP_PRICE2, priceTP);
    //-------------------------------------------------
    ObjectSet(cEnLine, OBJPROP_TIME1,  time1);
    ObjectSet(cEnLine, OBJPROP_TIME2,  time2);
    ObjectSet(cEnLine, OBJPROP_PRICE1, priceEN);
    ObjectSet(cEnLine, OBJPROP_PRICE2, priceEN);
    //-------------------------------------------------
    ObjectSet(cSlLine, OBJPROP_TIME1,  time1);
    ObjectSet(cSlLine, OBJPROP_TIME2,  time2);
    ObjectSet(cSlLine, OBJPROP_PRICE1, priceSL);
    ObjectSet(cSlLine, OBJPROP_PRICE2, priceSL);
    //-------------------------------------------------
    ObjectSet(cPointTP, OBJPROP_TIME1,  time1);
    ObjectSet(cPointSL, OBJPROP_TIME1,  time1);
    ObjectSet(cPointEN, OBJPROP_TIME1,  time1);
    ObjectSet(cPointWD, OBJPROP_TIME1,  time2);
    ObjectSet(cPointTP, OBJPROP_PRICE1, priceTP);
    ObjectSet(cPointSL, OBJPROP_PRICE1, priceSL);
    ObjectSet(cPointEN, OBJPROP_PRICE1, priceEN);
    ObjectSet(cPointWD, OBJPROP_PRICE1, priceEN);
    //-------------------------------------------------
    ObjectSet(cTpText, OBJPROP_TIME1,  centerTime);
    ObjectSet(cEnText, OBJPROP_TIME1,  centerTime);
    ObjectSet(cSlText, OBJPROP_TIME1,  centerTime);
    ObjectSet(cTpText, OBJPROP_PRICE1, priceTP);
    ObjectSet(cEnText, OBJPROP_PRICE1, priceEN);
    ObjectSet(cSlText, OBJPROP_PRICE1, priceSL);
    //-------------------------------------------------
    ObjectSet(cTpPrice, OBJPROP_TIME1,  centerTime);
    ObjectSet(cEnPrice, OBJPROP_TIME1,  centerTime);
    ObjectSet(cSlPrice, OBJPROP_TIME1,  centerTime);
    ObjectSet(cTpPrice, OBJPROP_PRICE1, priceTP);
    ObjectSet(cEnPrice, OBJPROP_PRICE1, priceEN);
    ObjectSet(cSlPrice, OBJPROP_PRICE1, priceSL);
    //-------------------------------------------------
    ObjectSetInteger(0, cEnText, OBJPROP_ANCHOR, ANCHOR_LOWER);
    if (priceTP > priceSL)
    {
        ObjectSetInteger(0, cSlText, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(0, cTpText, OBJPROP_ANCHOR, ANCHOR_LOWER);
    }
    else
    {
        ObjectSetInteger(0, cSlText, OBJPROP_ANCHOR, ANCHOR_LOWER);
        ObjectSetInteger(0, cTpText, OBJPROP_ANCHOR, ANCHOR_UPPER);
    }
    //-------------------------------------------------
    string strTpInfo = ""; // pip + dola
    string strEnInfo = ""; // RR  + lot 
    string strSlInfo = ""; // pip + dola
    if (priceEN == priceSL) return;
    double slPip     = 10000*MathAbs(priceEN-priceSL);
    double rr        = (priceTP-priceEN) / (priceEN-priceSL);
    double lot       = (double)((int)(LongShort_Cost/slPip*10))/100;
    double realCost  = lot*slPip*10;
    bool selectState = (bool)ObjectGet(cPointWD, OBJPROP_SELECTED);
    bool showStats  = (LongShort_ShowStats  == SHOW) || (LongShort_ShowStats  == SHOW_WHEN_SELECTED && selectState);
    bool showPrice  = (LongShort_ShowPrice  == SHOW) || (LongShort_ShowPrice  == SHOW_WHEN_SELECTED && selectState);
    bool showDollar = (LongShort_ShowDollar == SHOW) || (LongShort_ShowDollar == SHOW_WHEN_SELECTED && selectState);

    if (showStats)
    {
        strTpInfo += DoubleToString(slPip*rr,1) + "p";
        strEnInfo += DoubleToString(rr,1) + "R";
        strSlInfo += DoubleToString(slPip, 1) + "p";
    }

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
        ObjectSet(cTpPrice, OBJPROP_TIME1,  time2);
        ObjectSet(cEnPrice, OBJPROP_TIME1,  time2);
        ObjectSet(cSlPrice, OBJPROP_TIME1,  time2);
        ObjectSet(cTpPrice, OBJPROP_PRICE1, priceTP);
        ObjectSet(cEnPrice, OBJPROP_PRICE1, priceEN);
        ObjectSet(cSlPrice, OBJPROP_PRICE1, priceSL);
        strEnInfo += " ~ " + DoubleToString(lot,2) + "lot";
    }
    else
    {
        ObjectSet(cTpPrice, OBJPROP_PRICE1, 0);
        ObjectSet(cEnPrice, OBJPROP_PRICE1, 0);
        ObjectSet(cSlPrice, OBJPROP_PRICE1, 0);
    }

    //-------------------------------------------------
    ObjectSetText(cTpText, strTpInfo);
    ObjectSetText(cEnText, strEnInfo);
    ObjectSetText(cSlText, strSlInfo);

}
void LongShort::finishedJobDone(){}

// Chart Event
void LongShort::onMouseMove(){}
void LongShort::onMouseClick()
{
    createItem();
    refreshData();
    mFinishedJobCb();
}
void LongShort::onItemDrag(const string &itemId, const string &objId)
{
    priceTP =           ObjectGet(cPointTP, OBJPROP_PRICE1);
    priceEN =           ObjectGet(cPointEN, OBJPROP_PRICE1);
    priceSL =           ObjectGet(cPointSL, OBJPROP_PRICE1);
    time1   = (datetime)ObjectGet(cPointEN, OBJPROP_TIME1);
    time2   = (datetime)ObjectGet(cPointWD, OBJPROP_TIME1);
    if (objId == cBoder)
    {
        datetime newtime1 = (datetime)ObjectGet(cBoder, OBJPROP_TIME1);
        datetime newtime2 = (datetime)ObjectGet(cBoder, OBJPROP_TIME2);
        double newtpPrice =           ObjectGet(cBoder, OBJPROP_PRICE2);
        double newslPrice =           ObjectGet(cBoder, OBJPROP_PRICE1);

        if (newtime1 == time1 || newtime2 == time2 || newtpPrice == priceTP || newslPrice == priceSL)
        {
            // move edge -> ignore
        }
        else
        {
            priceEN += (newtpPrice-priceTP);
            priceSL = newslPrice;
            priceTP = newtpPrice;
            time1 = newtime1;
            time2 = newtime2;
        }
    }
    refreshData();
}
void LongShort::onItemClick(const string &itemId, const string &objId)
{
    if (objId == cPointTP || objId == cPointSL || objId == cPointEN || objId == cPointWD)
    {
        int selectState = (int)ObjectGet(objId, OBJPROP_SELECTED);
        // ObjectSet(cBgndSL , OBJPROP_SELECTED, selectState);
        // ObjectSet(cBgndTP , OBJPROP_SELECTED, selectState);
        // ObjectSet(cTpLine , OBJPROP_SELECTED, selectState);
        // ObjectSet(cEnLine , OBJPROP_SELECTED, selectState);
        // ObjectSet(cSlLine , OBJPROP_SELECTED, selectState);
        // ObjectSet(cTpPrice, OBJPROP_SELECTED, selectState);
        // ObjectSet(cEnPrice, OBJPROP_SELECTED, selectState);
        // ObjectSet(cSlPrice, OBJPROP_SELECTED, selectState);
        // ObjectSet(cTpText , OBJPROP_SELECTED, selectState);
        // ObjectSet(cEnText , OBJPROP_SELECTED, selectState);
        // ObjectSet(cSlText , OBJPROP_SELECTED, selectState);
        // ObjectSet(cBoder  , OBJPROP_SELECTED, selectState);
        ObjectSet(cPointTP, OBJPROP_SELECTED, selectState);
        ObjectSet(cPointSL, OBJPROP_SELECTED, selectState);
        ObjectSet(cPointEN, OBJPROP_SELECTED, selectState);
        ObjectSet(cPointWD, OBJPROP_SELECTED, selectState);
    }
    onItemDrag(itemId, objId);
}
void LongShort::onItemChange(const string &itemId, const string &objId){}
void LongShort::onItemDeleted(const string &itemId, const string &objId)
{
    if (DEBUG) PrintFormat("LongShort::onItemDeleted %s", objId);
    ObjectDelete(cBgndSL );
    ObjectDelete(cBgndTP );
    ObjectDelete(cTpLine );
    ObjectDelete(cEnLine );
    ObjectDelete(cSlLine );
    ObjectDelete(cTpPrice);
    ObjectDelete(cEnPrice);
    ObjectDelete(cSlPrice);
    ObjectDelete(cTpText );
    ObjectDelete(cEnText );
    ObjectDelete(cSlText );
    ObjectDelete(cBoder  );
    ObjectDelete(cPointTP);
    ObjectDelete(cPointSL);
    ObjectDelete(cPointEN);
    ObjectDelete(cPointWD);
}