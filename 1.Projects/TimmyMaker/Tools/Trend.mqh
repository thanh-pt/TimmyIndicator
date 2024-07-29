#include "../Base/BaseItem.mqh"

enum TEXT_POS
{
    TXT_LEFT,   // Left
    TXT_CENTER, // Center
    TXT_RIGHT,  // Right
};

enum ETrendText{
    ETrendTextLeft,     // Left
    ETrendTextCenter,   // Center
    ETrendTextRight,    // Right
    ETrendTextLeftArr,  // Left + Arrow
    ETrendTextCenterArr,// Center + Arrow
    ETrendTextRightArr, // Right + Arrow
};

TEXT_POS getTextPos(ETrendText eTrendText){
    switch (eTrendText){
        case ETrendTextLeft     : return TXT_LEFT;
        case ETrendTextCenter   : return TXT_CENTER;
        case ETrendTextRight    : return TXT_RIGHT;
        case ETrendTextLeftArr  : return TXT_LEFT;
        case ETrendTextCenterArr: return TXT_CENTER;
        case ETrendTextRightArr : return TXT_RIGHT;
    }
    return TXT_CENTER;
}
string getName(string name){
    if (StringFind(name, "-") == -1) return name;
    string listName[];
    int k=StringSplit(name,'-',listName);
    return listName[0];
}
string getAltName(string name){
    if (StringFind(name, "-") == -1) return name;
    string listName[];
    int k=StringSplit(name,'-',listName);
    if(listName[1] == "TF") return getTFString();
    return listName[1];
}


input string Trend_; // ●  T R E N D  ●
input int        Trend_amount       = 6;            // Trend amount:
//--------------------------------------------
input string     Trend_1_Name       = "Flow-";          // _ _ _ _ _ _ Trend 1 _ _ _ _ _ _
input ELineStyle Trend_1_Style      = eLineSolid;       // |___ Style
input color      Trend_1_Color      = clrNavy;        // |___ Color
input ETrendText Trend_1_TxtPos     = ETrendTextCenter; // |___ Text Pos
//--------------------------------------------
input string     Trend_2_Name       = "ofs";            // _ _ _ _ _ _ Trend 2 _ _ _ _ _ _
input ELineStyle Trend_2_Style      = eLineDash;        // |___ Style
input color      Trend_2_Color      = clrGreen;       // |___ Color
input ETrendText Trend_2_TxtPos     = ETrendTextCenter; // |___ Text Pos
//--------------------------------------------
input string     Trend_3_Name       = "BoS-TF";         // _ _ _ _ _ _ Trend 3_ _ _ _ _ _
input ELineStyle Trend_3_Style      = eLineBold;        // |___ Style
input color      Trend_3_Color      = clrNavy;        // |___ Color
input ETrendText Trend_3_TxtPos     = ETrendTextCenter; // |___ Text Pos
//--------------------------------------------
input string     Trend_4_Name       = "x";              // _ _ _ _ _ _ Trend 4_ _ _ _ _ _
input ELineStyle Trend_4_Style      = eLineDot;         // |___ Style
input color      Trend_4_Color      = clrNavy;        // |___ Color
input ETrendText Trend_4_TxtPos     = ETrendTextCenter; // |___ Text Pos
//--------------------------------------------
input string     Trend_5_Name       = "IRL";            // _ _ _ _ _ _ Trend 5_ _ _ _ _ _
input ELineStyle Trend_5_Style      = eLineDot;         // |___ Style
input color      Trend_5_Color      = clrGreen;       // |___ Color
input ETrendText Trend_5_TxtPos     = ETrendTextCenter; // |___ Text Pos
//--------------------------------------------
input string     Trend_6_Name       = "Arw-";           // _ _ _ _ _ _ Trend 6_ _ _ _ _ _
input ELineStyle Trend_6_Style      = eLineSolid;       // |___ Style
input color      Trend_6_Color      = clrNavy;        // |___ Color
input ETrendText Trend_6_TxtPos     = ETrendTextCenterArr; // |___ Text Pos
//--------------------------------------------

// --- Reserved ---
string     Trend_7_Name       = "Arw-";               // _ _ _ _ _ _ Trend 7_ _ _ _ _ _
ELineStyle Trend_7_Style      = eLineSolid;           // |___ Style
color      Trend_7_Color      = clrNavy;            // |___ Color
ETrendText Trend_7_TxtPos     = ETrendTextCenterArr;  // |___ Text Pos
//--------------------------------------------
string     Trend_8_Name       = "Reserved";           // → Trend 8
ELineStyle Trend_8_Style      = eLineSolid;           // Style
color      Trend_8_Color      = clrGreen;           // Color
ETrendText Trend_8_TxtPos     = ETrendTextCenter;     // Text Position
//--------------------------------------------
string     Trend_9_Name       = "Reserved";           // → Trend 9
ELineStyle Trend_9_Style      = eLineSolid;           // Style
color      Trend_9_Color      = clrNavy;            // Color
ETrendText Trend_9_TxtPos     = ETrendTextCenter;     // Text Position

enum TrendType
{
    TREND_1,
    TREND_2,
    TREND_3,
    TREND_4,
    TREND_5,
    TREND_6,
    TREND_7,
    TREND_8,
    TREND_9,
    TREND_NUM,
};

class Trend : public BaseItem
{
// Internal Value
private:
    string   mDispText [CTX_MAX];
    TEXT_POS mTextPos  [CTX_MAX];
    color    mColorType[CTX_MAX];
    int      mStyleType[CTX_MAX];
    int      mWidthType[CTX_MAX];
    bool     mShowArrow[CTX_MAX];

// Component name
private:
    string cLnM0;
    string cPt01;
    string cPt02;
    string iAng0;
    string iTxtC;
    string iTxtR;
    string iTxtL;
    string iTxtA;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    datetime time3;
    double price1;
    double price2;
    double price3;

public:
    Trend(CommonData* commonData, MouseInfo* mouseInfo);

// Internal Event
public:
    virtual void activateItem(const string& itemId);
    virtual void refreshData();
    virtual void createItem();
    virtual void updateDefaultProperty();
    virtual void updateTypeProperty();
    virtual void prepareActive();
    virtual void updateItemAfterChangeType();
private:

// Chart Event
public:
    virtual void onMouseMove();
    virtual void onMouseClick();
    virtual void onItemDrag(const string &itemId, const string &objId);
    virtual void onItemClick(const string &itemId, const string &objId);
    virtual void onItemChange(const string &itemId, const string &objId);

public:
    static string getAllItem(string itemId);
    static string Tag;
};

static string Trend::Tag = ".TMTrend";

Trend::Trend(CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = Trend::Tag;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [TREND_1] = getName(Trend_1_Name);
    mDispText [TREND_1] = getAltName(Trend_1_Name);
    mTextPos  [TREND_1] = getTextPos(Trend_1_TxtPos);
    mColorType[TREND_1] = Trend_1_Color     ;
    mStyleType[TREND_1] = getLineStyle(Trend_1_Style);
    mWidthType[TREND_1] = getLineWidth(Trend_1_Style);
    mShowArrow[TREND_1] = (Trend_1_TxtPos>=ETrendTextLeftArr);     ;
    //--------------------------------------------
    mNameType [TREND_2] = getName(Trend_2_Name);
    mDispText [TREND_2] = getAltName(Trend_2_Name);
    mTextPos  [TREND_2] = getTextPos(Trend_2_TxtPos);
    mColorType[TREND_2] = Trend_2_Color     ;
    mStyleType[TREND_2] = getLineStyle(Trend_2_Style);
    mWidthType[TREND_2] = getLineWidth(Trend_2_Style);
    mShowArrow[TREND_2] = (Trend_2_TxtPos>=ETrendTextLeftArr);     ;
    //--------------------------------------------
    mNameType [TREND_3] = getName(Trend_3_Name);
    mDispText [TREND_3] = getAltName(Trend_3_Name);
    mTextPos  [TREND_3] = getTextPos(Trend_3_TxtPos);
    mColorType[TREND_3] = Trend_3_Color     ;
    mStyleType[TREND_3] = getLineStyle(Trend_3_Style);
    mWidthType[TREND_3] = getLineWidth(Trend_3_Style);
    mShowArrow[TREND_3] = (Trend_3_TxtPos>=ETrendTextLeftArr);     ;
    //--------------------------------------------
    mNameType [TREND_4] = getName(Trend_4_Name);
    mDispText [TREND_4] = getAltName(Trend_4_Name);
    mTextPos  [TREND_4] = getTextPos(Trend_4_TxtPos);
    mColorType[TREND_4] = Trend_4_Color     ;
    mStyleType[TREND_4] = getLineStyle(Trend_4_Style);
    mWidthType[TREND_4] = getLineWidth(Trend_4_Style);
    mShowArrow[TREND_4] = (Trend_4_TxtPos>=ETrendTextLeftArr);     ;
    //--------------------------------------------
    mNameType [TREND_5] = getName(Trend_5_Name);
    mDispText [TREND_5] = getAltName(Trend_5_Name);
    mTextPos  [TREND_5] = getTextPos(Trend_5_TxtPos);
    mColorType[TREND_5] = Trend_5_Color     ;
    mStyleType[TREND_5] = getLineStyle(Trend_5_Style);
    mWidthType[TREND_5] = getLineWidth(Trend_5_Style);
    mShowArrow[TREND_5] = (Trend_5_TxtPos>=ETrendTextLeftArr);     ;
    //--------------------------------------------
    mNameType [TREND_6] = getName(Trend_6_Name);
    mDispText [TREND_6] = getAltName(Trend_6_Name);
    mTextPos  [TREND_6] = getTextPos(Trend_6_TxtPos);
    mColorType[TREND_6] = Trend_6_Color     ;
    mStyleType[TREND_6] = getLineStyle(Trend_6_Style);
    mWidthType[TREND_6] = getLineWidth(Trend_6_Style);
    mShowArrow[TREND_6] = (Trend_6_TxtPos>=ETrendTextLeftArr);     ;
    //--------------------------------------------
    mNameType [TREND_7] = getName(Trend_7_Name);
    mDispText [TREND_7] = getAltName(Trend_7_Name);
    mTextPos  [TREND_7] = getTextPos(Trend_7_TxtPos);
    mColorType[TREND_7] = Trend_7_Color     ;
    mStyleType[TREND_7] = getLineStyle(Trend_7_Style);
    mWidthType[TREND_7] = getLineWidth(Trend_7_Style);
    mShowArrow[TREND_7] = (Trend_7_TxtPos>=ETrendTextLeftArr);     ;
    //--------------------------------------------
    mNameType [TREND_8] = getName(Trend_8_Name);
    mDispText [TREND_8] = getAltName(Trend_8_Name);
    mTextPos  [TREND_8] = getTextPos(Trend_8_TxtPos);
    mColorType[TREND_8] = Trend_8_Color     ;
    mStyleType[TREND_8] = getLineStyle(Trend_8_Style);
    mWidthType[TREND_8] = getLineWidth(Trend_8_Style);
    mShowArrow[TREND_8] = (Trend_8_TxtPos>=ETrendTextLeftArr);     ;
    //--------------------------------------------
    mNameType [TREND_9] = getName(Trend_9_Name);
    mDispText [TREND_9] = getAltName(Trend_9_Name);
    mTextPos  [TREND_9] = getTextPos(Trend_9_TxtPos);
    mColorType[TREND_9] = Trend_9_Color    ;
    mStyleType[TREND_9] = getLineStyle(Trend_9_Style);
    mWidthType[TREND_9] = getLineWidth(Trend_9_Style);
    mShowArrow[TREND_9] = (Trend_9_TxtPos>=ETrendTextLeftArr);    ;
    //--------------------------------------------
    mIndexType = 0;
    mTypeNum = MathMin(Trend_amount, TREND_NUM);
    for (int i = 0; i < mTypeNum; i++)
    {
        mContextType += mNameType[i];
        if (i < mTypeNum-1) mContextType += ",";
    }
}

// Internal Event
void Trend::prepareActive(){}

void Trend::activateItem(const string& itemId)
{
    cLnM0 = itemId + TAG_CTRM + "cLnM0";
    cPt01 = itemId + TAG_CTRL + "cPt01";
    cPt02 = itemId + TAG_CTRL + "cPt02";
    iAng0 = itemId + TAG_INFO + "iAng0";
    iTxtC = itemId + TAG_INFO + "iTxtC";
    iTxtR = itemId + TAG_INFO + "iTxtR";
    iTxtL = itemId + TAG_INFO + "iTxtL";
    iTxtA = itemId + TAG_INFO + "iTxtA";

    mAllItem += cLnM0+cPt01+cPt02+iTxtC+iTxtR+iTxtL+iAng0+iTxtA;
}
string Trend::getAllItem(string itemId)
{
    string allItem = itemId + "_mTData";
    allItem += itemId + TAG_INFO + "iAng0";
    allItem += itemId + TAG_INFO + "iTxtC";
    allItem += itemId + TAG_INFO + "iTxtR";
    allItem += itemId + TAG_INFO + "iTxtL";
    allItem += itemId + TAG_INFO + "iTxtA";
    //--- Control item ---
    allItem += itemId + TAG_CTRM + "cLnM0";
    allItem += itemId + TAG_CTRL + "cPt01";
    allItem += itemId + TAG_CTRL + "cPt02";

    return allItem;
}

void Trend::refreshData()
{
    // Update Main Compoment
    setItemPos(cLnM0, time1, time2, price1, price2);
    setItemPos(cPt01, time1, price1);
    setItemPos(cPt02, time2, price2);
    setItemPos(iAng0, time1, time2, pCommonData.mTopPrice, pCommonData.mTopPrice + price2 - price1);
    setItemPos(iTxtA, time2, price2);
    double angle=ObjectGet(iAng0, OBJPROP_ANGLE);
    ObjectSet(iTxtA, OBJPROP_ANGLE,  angle-90.0);

    // Update Text
    setItemPos(iTxtC, time3, price3);
    setItemPos(iTxtR, time2, price2);
    setItemPos(iTxtL, time1, price1);
    // Update Text content
    setTextContent(iTxtL, ObjectDescription(cPt01));
    setTextContent(iTxtR, ObjectDescription(cPt02));

    bool isUp = false;
    int barT1 = iBarShift(ChartSymbol(), ChartPeriod(), time1);
    int barT2 = iBarShift(ChartSymbol(), ChartPeriod(), time2);
    if (barT1 > barT2 && price1 >= High[barT1]) isUp = true;
    else if (barT2 > barT1 && price2 >= High[barT2]) isUp = true;

    if (angle > 000 && angle <=  90) {
        ObjectSetInteger(0, iTxtC, OBJPROP_ANCHOR, isUp ? ANCHOR_RIGHT_LOWER : ANCHOR_LEFT_UPPER);
        ObjectSetInteger(0, iTxtR, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        ObjectSetInteger(0, iTxtL, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
    }
    else if (angle > 090 && angle <  180) {
        ObjectSetInteger(0, iTxtC, OBJPROP_ANCHOR, isUp ? ANCHOR_LEFT_LOWER  : ANCHOR_RIGHT_UPPER);
        ObjectSetInteger(0, iTxtR, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
        ObjectSetInteger(0, iTxtL, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    }
    else if (angle > 180 && angle <= 270) {
        ObjectSetInteger(0, iTxtC, OBJPROP_ANCHOR, isUp ? ANCHOR_RIGHT_LOWER : ANCHOR_LEFT_UPPER);
        ObjectSetInteger(0, iTxtR, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
        ObjectSetInteger(0, iTxtL, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    }
    else if (angle > 270 && angle <  360) {
        ObjectSetInteger(0, iTxtC, OBJPROP_ANCHOR, isUp ? ANCHOR_LEFT_LOWER  : ANCHOR_RIGHT_UPPER);
        ObjectSetInteger(0, iTxtR, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
        ObjectSetInteger(0, iTxtL, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
    }
    else if (angle == 0) 
    {
        ObjectSetInteger(0, iTxtC, OBJPROP_ANCHOR, isUp ? ANCHOR_LOWER : ANCHOR_UPPER);
        ObjectSetInteger(0, iTxtR, OBJPROP_ANCHOR, barT1 > barT2 ? ANCHOR_LEFT : ANCHOR_RIGHT);
        ObjectSetInteger(0, iTxtL, OBJPROP_ANCHOR, barT1 > barT2 ? ANCHOR_RIGHT: ANCHOR_LEFT);

        if (barT1 < barT2) ObjectSet(iTxtA, OBJPROP_ANGLE,  90.0); // case 180*
    }
    if (price1 == price2){
        ObjectSetInteger(0, iTxtC, OBJPROP_ANCHOR, isUp ? ANCHOR_LOWER : ANCHOR_UPPER);
        ObjectSetInteger(0, iTxtR, OBJPROP_ANCHOR, barT1 > barT2 ? ANCHOR_LEFT : ANCHOR_RIGHT);
        ObjectSetInteger(0, iTxtL, OBJPROP_ANCHOR, barT1 > barT2 ? ANCHOR_RIGHT: ANCHOR_LEFT);
    }
    // Customization

    int selected = (int)ObjectGet(cLnM0, OBJPROP_SELECTED);
    setMultiProp(OBJPROP_COLOR   , selected ? gClrPointer : clrNONE, cPt01+cPt02);
    if (selected) gContextMenu.openStaticCtxMenu(cLnM0, mContextType);
    else gContextMenu.clearStaticCtxMenu(cLnM0);
}

void Trend::createItem()
{
    ObjectCreate(iAng0, OBJ_TRENDBYANGLE, 0, 0, 0);
    ObjectCreate(iTxtA, OBJ_TEXT        , 0, 0, 0);
    ObjectCreate(cLnM0, OBJ_TREND       , 0, 0, 0);
    ObjectCreate(iTxtC, OBJ_TEXT        , 0, 0, 0);
    ObjectCreate(iTxtR, OBJ_TEXT        , 0, 0, 0);
    ObjectCreate(iTxtL, OBJ_TEXT        , 0, 0, 0);
    ObjectCreate(cPt01, OBJ_ARROW       , 0, 0, 0);
    ObjectCreate(cPt02, OBJ_ARROW       , 0, 0, 0);

    updateDefaultProperty();
    updateTypeProperty();
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void Trend::updateDefaultProperty()
{
    setMultiProp(OBJPROP_ARROWCODE , 4      , cPt01+cPt02);
    setMultiProp(OBJPROP_WIDTH     , 5      , cPt01+cPt02);
    setMultiProp(OBJPROP_SELECTABLE, false  , iTxtA+iAng0+iTxtC+iTxtR+iTxtL);
    setMultiProp(OBJPROP_COLOR     , clrNONE, cPt01+cPt02+iAng0);
    setMultiStrs(OBJPROP_TOOLTIP   , "\n"   , mAllItem);

    setMultiProp(OBJPROP_BACK ,  true, cLnM0+iAng0);
    setMultiProp(OBJPROP_RAY  , false, cLnM0+iAng0);
    ObjectSetInteger(ChartID(), iTxtA, OBJPROP_ANCHOR, ANCHOR_CENTER);
    
    setTextContent(iTxtC, "", 8, FONT_TEXT, mColorType[mIndexType]);
    setTextContent(iTxtR, "", 8, FONT_TEXT, mColorType[mIndexType]);
    setTextContent(iTxtL, "", 8, FONT_TEXT, mColorType[mIndexType]);
    setTextContent(iTxtA, "", 9, FONT_TEXT, clrNONE);
}
void Trend::updateTypeProperty()
{
    setTextContent(iTxtC,  "");
    setTextContent(cPt02,  "");
    setTextContent(cPt01,  "");

    setMultiProp(OBJPROP_COLOR, mColorType[mIndexType], iTxtC+iTxtR+iTxtL+iTxtA);

    if      (mTextPos[mIndexType] == TXT_CENTER) setTextContent (iTxtC,  mDispText[mIndexType]);
    else if (mTextPos[mIndexType] == TXT_RIGHT)  setTextContent (cPt02,  mDispText[mIndexType]);
    else                                         setTextContent (cPt01,  mDispText[mIndexType]);

    setTextContent(iTxtA,  mShowArrow[mIndexType] ? "▲" : "");
    setObjectStyle(cLnM0,  mColorType[mIndexType], mStyleType[mIndexType],  mWidthType[mIndexType]);
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
    gContextMenu.clearContextMenu();

    if (objId == cLnM0){
        time1 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
        time2 = (datetime)ObjectGet(objId, OBJPROP_TIME2);
        price1 =          ObjectGet(objId, OBJPROP_PRICE1);
        price2 =          ObjectGet(objId, OBJPROP_PRICE2);
        if (pCommonData.mMouseTime == time1){
            if (pCommonData.mShiftHold == true) price1 = price2;
            else if (pCommonData.mCtrlHold == true) price1 = pCommonData.mMousePrice;
        }
        else if (pCommonData.mMouseTime == time2){
            if (pCommonData.mShiftHold == true) price2 = price1;
            else if (pCommonData.mCtrlHold == true) price2 = pCommonData.mMousePrice;
        }
    }
    else if (objId == cPt01) {
        time2   = (datetime)ObjectGet(cPt02, OBJPROP_TIME1);
        price2  =           ObjectGet(cPt02, OBJPROP_PRICE1);

        time1 = (datetime)ObjectGet(cPt01, OBJPROP_TIME1);
        if (pCommonData.mShiftHold == true) price1 = price2;
        else if (pCommonData.mCtrlHold == true) price1 = pCommonData.mMousePrice;
        else price1 = ObjectGet(cPt01, OBJPROP_PRICE1);
    }
    else if (objId == cPt02) {
        time1   = (datetime)ObjectGet(cPt01, OBJPROP_TIME1);
        price1  =           ObjectGet(cPt01, OBJPROP_PRICE1);

        time2 = (datetime)ObjectGet(cPt02, OBJPROP_TIME1);
        if (pCommonData.mShiftHold == true) price2 = price1;
        else if (pCommonData.mCtrlHold == true) price2 = pCommonData.mMousePrice;
        else price2 = ObjectGet(cPt02, OBJPROP_PRICE1);
    }

    getCenterPos(time1, time2, price1, price2, time3, price3);

    refreshData();
}
void Trend::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, TAG_CTRL) < 0) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    if (selected && pCommonData.mShiftHold) gContextMenu.openContextMenu(cLnM0, mContextType, mIndexType);
    setCtrlItemSelectState(mAllItem, selected);
    setMultiProp(OBJPROP_COLOR, selected ? gClrPointer : clrNONE, cPt01+cPt02);
    
    if (selected) gContextMenu.openStaticCtxMenu(cLnM0, mContextType);
    else gContextMenu.clearStaticCtxMenu(cLnM0);
}
void Trend::onItemChange(const string &itemId, const string &objId)
{
    if (objId == cLnM0){
        setMultiProp(OBJPROP_COLOR, (color)ObjectGet(objId, OBJPROP_COLOR), iTxtC+iTxtR+iTxtL+iTxtA);
        string description = ObjectDescription(objId);
        if (description != ""){
            setTextContent(objId, "");
            setTextContent(iTxtC, (description == "-") ? STR_EMPTY : description);
        }
    }
    onItemDrag(itemId, objId);
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
    if (pCommonData.mShiftHold) {
        price2 = price1;
    }
    else {
        price2 = pCommonData.mMousePrice;
    }
    time2  = pCommonData.mMouseTime;
    getCenterPos(time1, time2, price1, price2, time3, price3);
    refreshData();
}
