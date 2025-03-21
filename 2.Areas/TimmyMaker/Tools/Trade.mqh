#include "../Base/BaseItem.mqh"

#define LONG_IDX 0

#define CTX_FILLSL      "Fill SL"
#define CTX_FILLTP      "Fill TP"
#define CTX_GOLIVE      "LIVE"
#define CTX_ADDSLTP     "Add Sl/Tp"
#define CTX_BELINE      "BE Line"
#define CTX_FALINE      "FA Line"

#define TAG_TRADEID     ".TMTrade_1440#"

enum eDisplay
{
    HIDE,   // Hide
    SHOW,   // Always
    OPTION, // Option
};

enum eAdjust
{
    E_FIXEN, // Fixed EN
    E_FIXTP, // Fixed TP
};

enum eFillType
{
    BY_PIP,         // Defined Pip
    BY_ADD_SPACE,   // Add Space Only (SL)
    BY_FIXED_RRR,   // Fixed RRR (TP)
};

input string    Trd_; // ●  T R A D E  ●
//-------------------------------------------------
input bool      Trd_TrackTrade    = false;   // Track Trade
input double    Trd_Cost          = 1.5;     // Cost ($)
input double    Trd_Comm          = 7;       // Commission ($)
input double    Trd_Spread        = 0.0;     // Spread (point)
input eFillType Trd_FillSlType    = BY_ADD_SPACE;  // Fill SL Type:
input double    Trd_FillSlOpt     = 2.0;     // Fill SL Opt (pt):
input eFillType Trd_FillTpType    = BY_FIXED_RRR;  // Fill TP Type:
input double    Trd_FillTpOpt     = 2.0;     // Fill TP Opt (pt):
input double    Trd_LotSize       = 0;       // LotSize (0=default)
input bool      Trd_FunctionLine  = false;   // Function Line
//-------------------------------------------------

eDisplay    Trd_ShowStats   = OPTION;   //Show Stats
eDisplay    Trd_ShowDollar  = OPTION;   //Show Dollar
//-------------------------------------------------
string      Trd_apperence; //→ Color:
int         Trd_TextSize      = 8;                   // Text Size
color       Trd_TpColor       = clrSteelBlue;      // TP Line
color       Trd_SlColor       = clrChocolate;      // SL Line
color       Trd_EnColor       = clrChocolate;      // EN Line
int         Trd_LineWidth     = 2;                   // Line Width
color       Trd_SlBkgrdColor  = clrLavenderBlush;  // SlBg
color       Trd_TpBkgrdColor  = clrWhiteSmoke;     // TpBg

double gdLotSize = MarketInfo(Symbol(), MODE_LOTSIZE);

class Trade : public BaseItem
{
// Internal Value
private:
    double mCost;
    double mFillSlPip;
    double mFillTpPip;
    double mSpread;
    double mComPoint;
    bool   mUserActive;
    string mStrTradeItems;
    string mArrTradeItems[];
    bool mShowTradeLevers;

// Component name
private:
    string cPtWD ;
    string cPtSL ;
    string cPtEN ;
    string cPtBE ;
    string cPtTP ;
    string cBgSl ;

    string iBgTP ;
    string iLnTp ;
    string iLnEn ;
    string iLnSl ;
    string iLnBe ;
    string iLnSp ;

    string iTxT2 ; // Text TP outside
    string iTxT1 ; // Text TP inside
    string iTxS2 ; // Text SL outside
    string iTxS1 ; // Text SL inside
    string iTxEn ;
    string iTxBe ;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double priceTP;
    double priceEN;
    double priceSL;
    double priceBE;

public:
    Trade(CommonData* commonData, MouseInfo* mouseInfo);

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
    virtual void onUserRequest(const string &itemId, const string &objId);
// Special functional
    void toggleTradeLevers();
    void showHistory(bool isShow);
    void scanLiveTrade();
    void restoreBacktestingTrade();
private:
    void createTrade(int id, datetime _time1, datetime _time2, double _priceEN, double _priceSL, double _priceTP, double _priceBE);
    void adjustRR(double rr, eAdjust adjType);

// Alpha feature
    void initData();

public:
    static string getAllItem(string itemId);
    static string Tag;
};

static string Trade::Tag = ".TMTrade";

Trade::Trade(CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = Trade::Tag;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    mUserActive = false;

    // Init variable type
    mNameType [0] = "Long";
    mNameType [1] = "Short";
    mIndexType = 0;
    mTypeNum = 2;

    mContextType  =        CTX_FILLSL;
    mContextType +=  "," + CTX_FILLTP;
    mContextType +=  "," + CTX_FALINE;
    mContextType +=  "," + CTX_BELINE;
    mContextType +=  "," + CTX_GOLIVE;
    mContextType +=  "," + CTX_ADDSLTP;

    // Other initialize
    mCost     = Trd_Cost;
    if (Trd_LotSize != 0) gdLotSize = Trd_LotSize;
    if (gdLotSize == 0) gdLotSize = 100000;
    mSpread     = Trd_Spread    / gdLotSize;
    mFillSlPip  = Trd_FillSlOpt / gdLotSize;
    mFillTpPip  = Trd_FillTpOpt / gdLotSize;
    mComPoint   = Trd_Comm      / gdLotSize;

    
    ObjectCreate(TAG_STATIC + "Cost" , OBJ_ARROW, 0, 0, 0);
    ObjectCreate(TAG_STATIC + "Comm" , OBJ_ARROW, 0, 0, 0);
    ObjectCreate(TAG_STATIC + "LotSize" , OBJ_ARROW, 0, 0, 0);

    setTextContent(TAG_STATIC + "Cost", DoubleToString(Trd_Cost, 6));
    setTextContent(TAG_STATIC + "Comm", DoubleToString(Trd_Comm, 6));
    setTextContent(TAG_STATIC + "LotSize", DoubleToString(gdLotSize));
    /* TODO: Chuyển đổi tỷ giá
        string strSymbol = Symbol();
        Example:
            - xxxJPY: mCost = Trd_Cost * 1.49;
            - XAUUSD: mCost = Trd_Cost * 10;
    */

   mShowTradeLevers = (bool)ChartGetInteger(0, CHART_SHOW_TRADE_LEVELS);
}

// Internal Event
void Trade::prepareActive()
{
    mUserActive = true;
}
void Trade::createItem()
{
    ObjectCreate(iBgTP , OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(iLnTp , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iLnEn , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iLnSl , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iLnSp , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iTxT2 , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iTxS2 , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iTxT1 , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iTxEn , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iTxS1 , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(cBgSl , OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(cPtTP , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPtSL , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPtEN , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPtWD , OBJ_ARROW     , 0, 0, 0);
    if (Trd_FunctionLine) {
        ObjectCreate(iLnBe , OBJ_TREND     , 0, 0, 0);
        ObjectCreate(iTxBe , OBJ_TEXT      , 0, 0, 0);
        ObjectCreate(cPtBE , OBJ_ARROW     , 0, 0, 0);
    }

    updateTypeProperty();
    updateDefaultProperty();
}
void Trade::initData()
{
    time1   = pCommonData.mMouseTime;
    priceEN = pCommonData.mMousePrice;
    static int wd = 0;
    ChartXYToTimePrice(0, (int)pCommonData.mMouseX+100, (int)pCommonData.mMouseY+(mIndexType == LONG_IDX ? 50:-50), wd,  time2, priceSL);
    adjustRR(1, E_FIXEN);
    // if (mIndexType == LONG_IDX) {
    //     priceSL = priceEN - (150 - Trd_Comm) / gdLotSize;
    //     priceTP = priceEN + (150 + Trd_Comm) / gdLotSize;
    // }
    // else {
    //     priceSL = priceEN + (150 - Trd_Comm) / gdLotSize;
    //     priceTP = priceEN - (150 + Trd_Comm) / gdLotSize;
    // }
    priceBE = (priceEN + priceTP)/2;
}
void Trade::updateDefaultProperty()
{
    //-------------------------------------------------
    setMultiProp(OBJPROP_BACK, true , iBgTP+iLnTp+iLnBe+iLnEn+iLnSl+iTxT2+iLnSp+iTxS2+iTxT1+iTxEn+iTxS1+iTxBe);
    setMultiProp(OBJPROP_BACK, false, cPtTP+cPtSL+cPtEN+cPtWD+cPtBE);
    //-------------------------------------------------
    setMultiProp(OBJPROP_ARROWCODE , 4    , cPtTP+cPtSL+cPtEN+cPtWD+cPtBE);
    
    setMultiProp(OBJPROP_SELECTED  , true , cBgSl+cPtTP+cPtSL+cPtEN+cPtWD+cPtBE);
    setMultiProp(OBJPROP_RAY       , false, iLnTp+iLnBe+iLnEn+iLnSl+iLnSp);
    setMultiProp(OBJPROP_SELECTABLE, false, iBgTP+iLnTp+iLnBe+iLnEn+iLnSl+iTxT2+iLnSp+iTxS2+iTxT1+iTxEn+iTxS1+iTxBe);

    setMultiProp(OBJPROP_COLOR, gClrPointer, cPtTP+cPtSL+cPtEN+cPtWD+cPtBE);
    //-------------------------------------------------
    ObjectSet(cBgSl, OBJPROP_COLOR, Trd_SlBkgrdColor);
    ObjectSet(iBgTP, OBJPROP_COLOR, Trd_TpBkgrdColor);
    setMultiProp(OBJPROP_WIDTH, 1        , iLnSp+iLnBe);
    setMultiProp(OBJPROP_STYLE, STYLE_DOT, iLnSp+iLnBe);
    //-------------------------------------------------
    setMultiProp(OBJPROP_COLOR, Trd_TpColor  , iLnTp+iLnBe);
    setMultiProp(OBJPROP_COLOR, Trd_SlColor  , iLnSl+iLnSp);
    setMultiProp(OBJPROP_COLOR, Trd_EnColor  , iLnEn);
    setMultiProp(OBJPROP_COLOR, gClrForegrnd , iTxT1+iTxT2+iTxS1+iTxS2+iTxBe+iTxEn);
    //-------------------------------------------------
    setMultiProp(OBJPROP_WIDTH   , Trd_LineWidth, iLnTp+iLnEn+iLnSl);
    setMultiProp(OBJPROP_FONTSIZE, Trd_TextSize , iTxT1+iTxT2+iTxS1+iTxS2+iTxBe+iTxEn);
    setMultiStrs(OBJPROP_FONT    , FONT_TEXT    , iTxT1+iTxT2+iTxS1+iTxS2+iTxBe+iTxEn);
    //-------------------------------------------------
    setMultiStrs(OBJPROP_TOOLTIP, "\n", mAllItem);
}
void Trade::updateTypeProperty(){}
void Trade::activateItem(const string& itemId)
{
    cPtWD = itemId + TAG_CTRM + "cPtWD";
    cPtSL = itemId + TAG_CTRL + "cPtSL";
    cPtEN = itemId + TAG_CTRL + "cPtEN";
    cPtBE = itemId + TAG_CTRL + "cPtBE";
    cPtTP = itemId + TAG_CTRL + "cPtTP";
    cBgSl = itemId + TAG_CTRL + "cBgSl";
    iBgTP = itemId + TAG_INFO + "iBgTP";
    iLnTp = itemId + TAG_INFO + "iLnTp";
    iLnEn = itemId + TAG_INFO + "iLnEn";
    iLnSl = itemId + TAG_INFO + "iLnSl";
    iLnBe = itemId + TAG_INFO + "iLnBe";
    iLnSp = itemId + TAG_INFO + "iLnSp";
    iTxT2 = itemId + TAG_INFO + "iTxT2";
    iTxS2 = itemId + TAG_INFO + "iTxS2";
    iTxT1 = itemId + TAG_INFO + "iTxT1";
    iTxEn = itemId + TAG_INFO + "iTxEn";
    iTxS1 = itemId + TAG_INFO + "iTxS1";
    iTxBe = itemId + TAG_INFO + "iTxBe";

    mAllItem += iBgTP+iLnTp+iLnEn+iLnSl+iLnBe+iTxT2+iLnSp+iTxS2+iTxT1+iTxEn+iTxS1+iTxBe;
    mAllItem += cPtTP+cPtSL+cPtEN+cPtWD+cPtBE+cBgSl;
}

string Trade::getAllItem(string itemId)
{
    string allItem = itemId + "_mTData";
    allItem += itemId + TAG_INFO + "iBgTP";
    allItem += itemId + TAG_INFO + "iLnTp";
    allItem += itemId + TAG_INFO + "iLnEn";
    allItem += itemId + TAG_INFO + "iLnSl";
    allItem += itemId + TAG_INFO + "iLnBe";
    allItem += itemId + TAG_INFO + "iLnSp";
    allItem += itemId + TAG_INFO + "iTxT2";
    allItem += itemId + TAG_INFO + "iTxS2";
    allItem += itemId + TAG_INFO + "iTxT1";
    allItem += itemId + TAG_INFO + "iTxEn";
    allItem += itemId + TAG_INFO + "iTxS1";
    allItem += itemId + TAG_INFO + "iTxBe";
    //--- Control item ---
    allItem += itemId + TAG_CTRL + "cBgSl";
    allItem += itemId + TAG_CTRM + "cPtWD";
    allItem += itemId + TAG_CTRL + "cPtSL";
    allItem += itemId + TAG_CTRL + "cPtEN";
    allItem += itemId + TAG_CTRL + "cPtBE";
    allItem += itemId + TAG_CTRL + "cPtTP";

    return allItem;
}

void Trade::updateItemAfterChangeType(){}
void Trade::refreshData()
{
    datetime centerTime = getCenterTime(time1, time2);
    
    setItemPos(cBgSl  , time1, time2, priceEN, priceSL);
    setItemPos(iBgTP  , time1, time2, priceEN, priceTP);
    setItemPos(iLnTp  , time1, time2, priceTP, priceTP);
    setItemPos(iLnEn  , time1, time2, priceEN, priceEN);
    setItemPos(iLnSl  , time1, time2, priceSL, priceSL);
    setItemPos(iLnBe  , time1, time2, priceBE, priceBE);
    //-------------------------------------------------
    setItemPos(cPtTP , time1, priceTP);
    setItemPos(cPtSL , time1, priceSL);
    setItemPos(cPtEN , time1, priceEN);
    setItemPos(cPtWD , time2, priceEN);
    setItemPos(cPtBE , time2, priceBE);
    //-------------------------------------------------
    setItemPos(iTxT1  , centerTime, priceTP);
    setItemPos(iTxEn  , centerTime, priceEN);
    setItemPos(iTxS1  , centerTime, priceSL);
    setItemPos(iTxBe  , time1, priceBE);

    setItemPos(iTxT2, centerTime, priceTP);
    setItemPos(iTxS2, centerTime, priceSL);
    //-------------------------------------------------
    ObjectSet(iTxEn, OBJPROP_ANCHOR, ANCHOR_LOWER);
    if (priceTP > priceSL) {
        ObjectSet(iTxS1, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSet(iTxT1, OBJPROP_ANCHOR, ANCHOR_LOWER);
        ObjectSet(iTxT2, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSet(iTxS2, OBJPROP_ANCHOR, ANCHOR_LOWER);
        if (priceBE > priceEN) ObjectSet(iTxBe, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        else ObjectSet(iTxBe, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
        if (mSpread != 0) setItemPos(iLnSp, time1, time2, priceEN-mSpread, priceEN-mSpread);
        else setItemPos(iLnSp, time1, time2, 0, 0);
    }
    else {
        ObjectSet(iTxS1, OBJPROP_ANCHOR, ANCHOR_LOWER);
        ObjectSet(iTxT1, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSet(iTxT2, OBJPROP_ANCHOR, ANCHOR_LOWER);
        ObjectSet(iTxS2, OBJPROP_ANCHOR, ANCHOR_UPPER);
        if (priceBE < priceEN) ObjectSet(iTxBe, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
        else ObjectSet(iTxBe, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);

        if (mSpread != 0) setItemPos(iLnSp, time1, time2, priceSL-mSpread, priceSL-mSpread);
        else setItemPos(iLnSp, time1, time2, 0, 0);
    }
    //-------------------------------------------------
    //            TÍNH TOÁN CÁC THỨ
    //-------------------------------------------------
    // 1. Thông tin lệnh
    if (priceSL == priceEN) return;
    double point    = floor(fabs(priceEN-priceSL) * gdLotSize);
    if (point <= 1) return;
    double absRR    = (priceTP-priceEN) / (priceEN-priceSL);
    double absBe    = fabs((priceBE-priceEN) / (priceEN-priceSL));
    double tradeSize = NormalizeDouble(floor(mCost / (point + Trd_Comm) * 100)/100, 2);
    double realCost = tradeSize * (point + Trd_Comm);
    double profit   = tradeSize * (absRR*point - Trd_Comm);

    // 2. Thông tin hiển thị
    bool   selectState = (bool)ObjectGet(cPtWD, OBJPROP_SELECTED);
    bool   showStats   = (Trd_ShowStats  == SHOW) || (Trd_ShowStats  == OPTION && selectState);
    bool   showDollar  = (Trd_Cost != 0) && ((Trd_ShowDollar == SHOW) || (Trd_ShowDollar == OPTION && selectState));
    
    // 3. String Data để hiển thị
    string strTpInfo   = ""; // point + dola
    string strSlInfo   = ""; // point + dola
    string strEnInfo   = ObjectDescription(cPtWD); // Cmt + lot 
    string strBeInfo   = ObjectDescription(cPtBE); // BE RR + point
    
    if (showStats) {
        strTpInfo += DoubleToString(absRR*point/10, 1) + "ᴘ";
        if (strBeInfo != "") strBeInfo += ": ";
        strBeInfo += DoubleToString(absBe,1) + "r/" + DoubleToString(absBe * point / 10, 1) + "ᴘ ";
        strSlInfo += DoubleToString(point/10, 1) + "ᴘ";
    }
    //-------------------------------------------------
    if (showDollar) {
        if (showStats) {
            strTpInfo += "/";
            strSlInfo += "/";
        }
        strTpInfo += DoubleToString(profit,   2) + "$";
        strSlInfo += DoubleToString(realCost, 2) + "$";
        if (strEnInfo != "") strEnInfo += ": ";
        strEnInfo += DoubleToString(tradeSize,2) + "lot";
    }
    string strRRInfo = "";
    if (fabs(absRR) > 0.2) {
        strRRInfo += DoubleToString(absRR,1) + "r";
        // if (Trd_Comm > 0 && realCost > 0) strRRInfo += "/" + DoubleToString(profit/realCost,1) + "ʀ";
    }
    //-------------------------------------------------
    setTextContent(iTxT2, strTpInfo);
    setTextContent(iTxS2, STR_EMPTY);
    bool isShowSpr = (Trd_Comm + Trd_Spread > 0 && (selectState || ObjectGet(cPtEN, OBJPROP_ARROWCODE) == 2));
    ObjectSet(iLnSp, OBJPROP_COLOR, isShowSpr ? Trd_SlColor : clrNONE);
    //-------------------------------------------------
    setTextContent(iTxT1, strRRInfo);
    setTextContent(iTxEn, strEnInfo);
    setTextContent(iTxS1, strSlInfo);
    setTextContent(iTxBe, strBeInfo);
    //-----------POINT TOOLTIP-------------------------
    ObjectSetString(0, cPtTP, OBJPROP_TOOLTIP, DoubleToString(priceTP, Digits));
    ObjectSetString(0, cPtSL, OBJPROP_TOOLTIP, DoubleToString(priceSL, Digits));
    ObjectSetString(0, cPtEN, OBJPROP_TOOLTIP, DoubleToString(priceEN, Digits));
    ObjectSetString(0, cPtWD, OBJPROP_TOOLTIP, DoubleToString(priceEN, Digits));
    ObjectSetString(0, cPtBE, OBJPROP_TOOLTIP, DoubleToString(priceBE, Digits));

    int selected = (int)ObjectGet(cPtWD, OBJPROP_SELECTED);
    if (selected) {
        gContextMenu.openStaticCtxMenu(cPtWD, mContextType);
        setMultiProp(OBJPROP_COLOR, gClrPointer, cPtTP+cPtSL+cPtEN+cPtWD+cPtBE);
        ObjectSet(iLnBe, OBJPROP_COLOR, Trd_TpColor);
    }
    else {
        gContextMenu.clearStaticCtxMenu(cPtWD);
        setMultiProp(OBJPROP_COLOR, clrNONE, cPtTP+cPtSL+cPtEN+cPtWD+cPtBE);
        if (strBeInfo == "") ObjectSet(iLnBe, OBJPROP_COLOR, clrNONE);
    }
    if (ObjectGet(cPtEN, OBJPROP_ARROWCODE) == 2) {
        ObjectSet(cPtEN, OBJPROP_COLOR, priceTP > priceSL ? clrBlue : clrRed);
    }
}
void Trade::finishedJobDone()
{
    mUserActive = false;
}

// Chart Event
void Trade::onMouseMove()
{
    MOUSE_MOVE_RETURN_CHECK
}
void Trade::onMouseClick()
{
    createItem();
    initData();
    refreshData();
    mFinishedJobCb();
}
void Trade::onItemDrag(const string &itemId, const string &objId)
{
    priceTP =           ObjectGet(cPtTP, OBJPROP_PRICE1);
    priceEN =           ObjectGet(cPtEN, OBJPROP_PRICE1);
    priceSL =           ObjectGet(cPtSL, OBJPROP_PRICE1);
    priceBE =           ObjectGet(cPtBE, OBJPROP_PRICE1);
    time1   = (datetime)ObjectGet(cBgSl, OBJPROP_TIME1);
    time2   = (datetime)ObjectGet(cPtWD, OBJPROP_TIME1);
    if (objId == cBgSl) {
        datetime newtime1 = (datetime)ObjectGet(cBgSl, OBJPROP_TIME1);
        datetime newtime2 = (datetime)ObjectGet(cBgSl, OBJPROP_TIME2);
        datetime timeCenter;
        double newSlPrice;
        getCenterPos(newtime1, newtime2, priceTP, priceTP, timeCenter, newSlPrice);
        if (timeCenter == pCommonData.mMouseTime) {
            priceEN     = ObjectGet(cBgSl, OBJPROP_PRICE1);
            newSlPrice  = ObjectGet(cBgSl, OBJPROP_PRICE2);
            priceBE += (newSlPrice-priceSL);
            priceTP += (newSlPrice-priceSL);
            priceSL = newSlPrice;
            time1 = newtime1;
            time2 = newtime2;
        }
        else {
            // move edge -> ignore
        }
    }
    else {
        if (pCommonData.mCtrlHold == true) {
            if      (objId == cPtTP) priceTP = pCommonData.mMousePrice;
            else if (objId == cPtEN) priceEN = pCommonData.mMousePrice;
            else if (objId == cPtSL) priceSL = pCommonData.mMousePrice;
            else if (objId == cPtBE) priceBE = pCommonData.mMousePrice;
        }
        else if (objId == cPtEN){
            if (pCommonData.mShiftHold == true){
                priceEN =           ObjectGet(cPtWD, OBJPROP_PRICE1);
                time1   = (datetime)ObjectGet(cPtEN, OBJPROP_TIME1);
            }
            else {
                priceEN = ObjectGet(cPtEN, OBJPROP_PRICE1);
            }
        }
    }
    refreshData();
}
void Trade::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, TAG_CTRL) < 0) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    if (selected) {
        gContextMenu.openStaticCtxMenu(cPtWD, mContextType);
        setMultiProp(OBJPROP_COLOR, gClrPointer, cPtTP+cPtSL+cPtEN+cPtWD+cPtBE);
    }
    else {
        gContextMenu.clearStaticCtxMenu(cPtWD);
        setMultiProp(OBJPROP_COLOR, clrNONE, cPtTP+cPtSL+cPtEN+cPtWD+cPtBE);
    }
    if (ObjectGet(cPtEN, OBJPROP_ARROWCODE) == 2) {
        onItemDrag(itemId, objId);
        ObjectSet(cPtEN, OBJPROP_COLOR, priceTP > priceSL ? clrBlue : clrRed);
    }
    setCtrlItemSelectState(mAllItem, selected);
}
void Trade::onItemChange(const string &itemId, const string &objId)
{
    onItemDrag(itemId, objId);
}

//-------------------------------------------------------------------
void Trade::toggleTradeLevers()
{
    mShowTradeLevers = !mShowTradeLevers;
    ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS, mShowTradeLevers);
}
void Trade::showHistory(bool isShow)
{
    string sparamItems[];
    int k;
    string objId;
    for (int i = ObjectsTotal() - 1; i >= 0; i--) {
        string objName = ObjectName(i);
        if (StringFind(objName, TAG_CTRM) == -1) continue;
        k=StringSplit(objName,'_',sparamItems);
        if (k != 3 || sparamItems[0] != mItemName) {
            continue;
        }
        objId = sparamItems[0] + "_" + sparamItems[1];
        activateItem(objId);
        if (isShow) {
            priceTP =           ObjectGet(cPtTP, OBJPROP_PRICE1);
            priceEN =           ObjectGet(cPtEN, OBJPROP_PRICE1);
            priceSL =           ObjectGet(cPtSL, OBJPROP_PRICE1);
            priceBE =           ObjectGet(cPtBE, OBJPROP_PRICE1);
            time1   = (datetime)ObjectGet(cBgSl, OBJPROP_TIME1);
            time2   = (datetime)ObjectGet(cBgSl, OBJPROP_TIME2);
            refreshData();
            continue;
        }
        
        if ((bool)ObjectGet(cPtWD, OBJPROP_SELECTED)) continue;
        if (ObjectGet(cPtEN, OBJPROP_ARROWCODE) == 2) continue; // Don't hide live trade
        // Hide Item
        ObjectSet(cBgSl, OBJPROP_PRICE1, 0);
        ObjectSet(iBgTP, OBJPROP_PRICE1, 0);
        ObjectSet(iLnTp, OBJPROP_PRICE1, 0);
        ObjectSet(iLnSp, OBJPROP_PRICE1, 0);
        ObjectSet(iLnBe, OBJPROP_PRICE1, 0);
        ObjectSet(iLnEn, OBJPROP_PRICE1, 0);
        ObjectSet(iLnSl, OBJPROP_PRICE1, 0);
        ObjectSet(cBgSl, OBJPROP_PRICE2, 0);
        ObjectSet(iBgTP, OBJPROP_PRICE2, 0);
        ObjectSet(iLnTp, OBJPROP_PRICE2, 0);
        ObjectSet(iLnSp, OBJPROP_PRICE2, 0);
        ObjectSet(iLnBe, OBJPROP_PRICE2, 0);
        ObjectSet(iLnEn, OBJPROP_PRICE2, 0);
        ObjectSet(iLnSl, OBJPROP_PRICE2, 0);

        ObjectSet(iTxT2, OBJPROP_TIME1, 0);
        ObjectSet(iTxS2, OBJPROP_TIME1, 0);
        ObjectSet(iTxT1, OBJPROP_TIME1, 0);
        ObjectSet(iTxEn, OBJPROP_TIME1, 0);
        ObjectSet(iTxS1, OBJPROP_TIME1, 0);
        ObjectSet(iTxBe, OBJPROP_TIME1, 0);
        ObjectSet(cPtTP, OBJPROP_TIME1, 0);
        ObjectSet(cPtSL, OBJPROP_TIME1, 0);
        ObjectSet(cPtEN, OBJPROP_TIME1, 0);
        ObjectSet(cPtWD, OBJPROP_TIME1, 0);
        ObjectSet(cPtBE, OBJPROP_TIME1, 0);
    }
}

#define REVERT_ENGINE
void Trade::onUserRequest(const string &itemId, const string &objId)
{
    // Add Live Trade
    if (gContextMenu.mActiveItemStr == CTX_GOLIVE) {
        priceEN   = NormalizeDouble(priceEN, Digits);
        priceSL   = NormalizeDouble(priceSL, Digits);
        priceTP   = NormalizeDouble(priceTP, Digits);
#ifndef REVERT_ENGINE
        ObjectSet("sim#3d_visual_sl", OBJPROP_PRICE1, priceSL);
        ObjectSet("sim#3d_visual_ap", OBJPROP_PRICE1, priceEN);
        ObjectSet("sim#3d_visual_tp", OBJPROP_PRICE1, priceTP);
#else
        ObjectSet("sim#3d_visual_sl", OBJPROP_PRICE1, priceTP);
        ObjectSet("sim#3d_visual_ap", OBJPROP_PRICE1, priceEN);
        ObjectSet("sim#3d_visual_tp", OBJPROP_PRICE1, priceSL);
#endif
    }
    // Auto adjust FillRR
    else if (gContextMenu.mActiveItemStr == CTX_FILLTP) {
        onItemDrag(itemId, objId);
        if (Trd_FillTpType == BY_PIP) {
            if (priceTP > priceSL) {
                priceTP = priceEN + 150/gdLotSize+mComPoint;
            }
            else {
                priceTP = priceEN - 150/gdLotSize-mComPoint;
            }
        }
        else if (Trd_FillTpType == BY_FIXED_RRR){
            adjustRR(Trd_FillTpOpt, E_FIXEN);
        }
        refreshData();
    }
    else if (gContextMenu.mActiveItemStr == CTX_FILLSL) {
        onItemDrag(itemId, objId);
        if (Trd_FillSlType == BY_PIP) {
            if (priceTP > priceSL) {
                priceSL = priceEN - mFillSlPip + mComPoint;
            }
            else {
                priceSL = priceEN + mFillSlPip - mComPoint;
            }
        }
        else if (Trd_FillSlType == BY_ADD_SPACE){
            if (priceTP > priceSL) {
                priceSL -= mFillSlPip;
            }
            else {
                priceSL += mFillSlPip + mSpread;
            }
        }
        refreshData();
    }
    // Add TP/SL if they don't have
    else if (gContextMenu.mActiveItemStr == CTX_ADDSLTP) {
        /// TradeWorker Handler this one
    }
    else if (gContextMenu.mActiveItemStr == CTX_BELINE) {
        onItemDrag(itemId, objId);
        if (ObjectDescription(cPtBE) != "be") setTextContent(cPtBE, "be");
        else setTextContent(cPtBE, "");
        refreshData();
    }
    else if (gContextMenu.mActiveItemStr == CTX_FALINE) {
        onItemDrag(itemId, objId);
        if (ObjectDescription(cPtBE) != "fa") setTextContent(cPtBE, "fa");
        else setTextContent(cPtBE, "");
        refreshData();
    }
}

void Trade::createTrade(int id, datetime _time1, datetime _time2, double _priceEN, double _priceSL, double _priceTP, double _priceBE)
{
    string itemId = TAG_TRADEID + IntegerToString(id);
    activateItem(itemId);
    createItem();
    time1 = _time1;
    time2 = _time2;
    priceTP = _priceTP;
    priceEN = _priceEN;
    priceSL = _priceSL;
    priceBE = _priceBE;
    refreshData();
}

void Trade::scanLiveTrade()
{
    if (Trd_TrackTrade == false) return;
    if (mUserActive == true) return; // User are trying to draw new trade
    string strOrderTicket = "";
    string itemId = "";
    string strNewTradeItems = "";
    double point = 0;
    double tradeSize = 0;
    double orgSL = 0;
    int orderType;
    bool buyOrder;
    for (int i = 0 ; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS) == false) continue;
        if (OrderSymbol() != Symbol()) continue;
        strOrderTicket = IntegerToString(OrderTicket());
        if (ObjectFind(strOrderTicket) < 0) {
            itemId = TAG_TRADEID + strOrderTicket;
            ObjectCreate(strOrderTicket, OBJ_LABEL, 0, 0, 0);
            setTextContent(strOrderTicket, itemId);
            ObjectSet(strOrderTicket, OBJPROP_YDISTANCE, -20);
        }
        else {
            itemId = ObjectDescription(strOrderTicket);
        }
        strNewTradeItems += itemId;
        StringReplace(mStrTradeItems, itemId, "");
        activateItem(itemId);
        orderType = OrderType();
        priceEN = OrderOpenPrice();
        priceSL = OrderStopLoss();
        priceTP = OrderTakeProfit();
        // Priority OnlineTradeData >> Chart Data >> Generate by Cost
        if (orderType == OP_BUY || orderType == OP_BUYLIMIT){
            buyOrder = true;
            if (priceSL == 0.0 || priceSL >= priceEN) {
                priceSL = ObjectGet(cPtSL, OBJPROP_PRICE1);
            }
            if (priceTP == 0.0 || priceTP <= priceEN + mComPoint + mSpread) {
                priceTP = ObjectGet(cPtTP, OBJPROP_PRICE1);
            }
        }
        else {
            buyOrder = false;
            if (priceSL == 0.0 || priceSL <= priceEN) {
                priceSL = ObjectGet(cPtSL, OBJPROP_PRICE1);
            }
            if (priceTP == 0.0 || priceTP >= priceEN - mComPoint - mSpread) {
                priceTP = ObjectGet(cPtTP, OBJPROP_PRICE1);
            }
        }
        if (ObjectFind(cPtWD) < 0) {
            tradeSize = OrderLots();
            if (priceSL == 0.0) priceSL = priceEN + (buyOrder? -1 : 1) * (mCost/tradeSize  - Trd_Comm) / gdLotSize;
            if (priceTP == 0.0) priceTP = 2*priceEN - priceSL; // RRR = 1
            priceBE = (priceEN + priceTP)/2;
            createTrade(OrderTicket(), OrderOpenTime(), OrderOpenTime()+getDistanceBar(10),
                                    priceEN, priceSL, priceTP, priceBE);
            itemId = TAG_TRADEID + IntegerToString(OrderTicket());
            setTextContent(strOrderTicket, itemId);
            ObjectSet(cPtEN, OBJPROP_ARROWCODE, 2);
            ObjectSet(cPtEN, OBJPROP_COLOR, clrRed);
            refreshData();
            continue;
        }
        priceBE = ObjectGet(cPtBE, OBJPROP_PRICE1);
        time1 = (datetime)ObjectGet(cPtEN, OBJPROP_TIME1);
        time2 = (datetime)ObjectGet(cPtWD, OBJPROP_TIME1);
        refreshData();
    }
    if (mStrTradeItems != "") {
        int k = StringSplit(mStrTradeItems, '.', mArrTradeItems);
        for (int i = 0; i < k; i++) {
            if (mArrTradeItems[i] == "") continue;
            itemId = "." + mArrTradeItems[i];
            activateItem(itemId);
            ObjectSet(cPtEN, OBJPROP_ARROWCODE, 4);
        }
        showHistory(false);
    }
    mStrTradeItems = strNewTradeItems;
}

void Trade::restoreBacktestingTrade()
{
    string objEn = "";
    string enData = "";

    string sparamItems[];
    double size;
    bool isBuy;

    for (int idx = 0; idx < 1000; idx++) {
        // Step 1: Find obj
        objEn = "sim#3d_en#" + IntegerToString(idx);
        if (ObjectFind(objEn) < 0) continue;

        // Step 2: extract data
        enData = ObjectGetString(0, objEn, OBJPROP_TOOLTIP);
        StringSplit(enData,'\n',sparamItems);
        size    = StrToDouble(StringSubstr(sparamItems[1], 6, 4));
        time1   = (datetime)ObjectGet(objEn, OBJPROP_TIME1);
        isBuy   = ((color)ObjectGet(objEn, OBJPROP_COLOR) == clrBlue);

        priceEN = ObjectGet(objEn, OBJPROP_PRICE1);
        priceSL = NormalizeDouble(priceEN - (isBuy ? 1 : -1) * 100 / size / 100000, 5);
        priceTP = priceEN + 2 * (isBuy ? 1 : -1) * fabs(priceEN-priceSL);
        priceBE = priceEN + (isBuy ? 1 : -1) * fabs(priceEN-priceSL);
        time2   = time1 + ChartPeriod()*600; // = time1 + 10 candle = time1 + 10 * 60* period
        // Step 3: Create Trade
        createTrade(idx, time1, time2, priceEN, priceSL, priceTP, priceBE);
    }
}

void Trade::adjustRR(double rr, eAdjust adjType)
{
    bool isBUY = (priceTP > priceSL);
    if (adjType == E_FIXTP){
        priceEN = (priceTP + rr*priceSL) / (rr+1) + (isBUY ? -1 : 1) * mComPoint;
    }
    else if (adjType == E_FIXEN){
        priceTP = (priceEN + (isBUY ? 1 : -1) * mComPoint) * (rr + 1) - rr*priceSL;
    }
    refreshData();
}
