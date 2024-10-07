#include "../Base/BaseItem.mqh"

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


input string Trend_;                // ●  T R E N D  ●
int        Trend_amount       = 5;  // Trend amount:
//--------------------------------------------
input string     Trend_1_Name       = "Flow-";          // _ _ _ _ _ _ Trend 1 _ _ _ _ _ _
input ELineStyle Trend_1_Style      = eLineSolid;       // |___ Style
input color      Trend_1_Color      = clrNavy;        // |___ Color
//--------------------------------------------
input string     Trend_2_Name       = "x";              // _ _ _ _ _ _ Trend 2 _ _ _ _ _ _
input ELineStyle Trend_2_Style      = eLineDot;         // |___ Style
input color      Trend_2_Color      = clrNavy;        // |___ Color
//--------------------------------------------
input string     Trend_3_Name       = "BoS-TF";         // _ _ _ _ _ _ Trend 3_ _ _ _ _ _
input ELineStyle Trend_3_Style      = eLineBold;        // |___ Style
input color      Trend_3_Color      = clrNavy;        // |___ Color
//--------------------------------------------
input string     Trend_4_Name       = "sub";            // _ _ _ _ _ _ Trend 4_ _ _ _ _ _
input ELineStyle Trend_4_Style      = eLineSolid;       // |___ Style
input color      Trend_4_Color      = clrNavy;        // |___ Color
//--------------------------------------------
input string     Trend_5_Name       = "$$$";            // _ _ _ _ _ _ Trend 5_ _ _ _ _ _
input ELineStyle Trend_5_Style      = eLineDot;         // |___ Style
input color      Trend_5_Color      = clrGreen;       // |___ Color
//--------------------------------------------

// --- Reserved ---
string     Trend_6_Name       = "Arw-";           // _ _ _ _ _ _ Trend 6_ _ _ _ _ _
ELineStyle Trend_6_Style      = eLineSolid;       // |___ Style
color      Trend_6_Color      = clrNavy;        // |___ Color
//--------------------------------------------
string     Trend_7_Name       = "sub";                // _ _ _ _ _ _ Trend 7_ _ _ _ _ _
ELineStyle Trend_7_Style      = eLineSolid;           // |___ Style
color      Trend_7_Color      = clrNavy;            // |___ Color
//--------------------------------------------
string     Trend_8_Name       = "Reserved";           // → Trend 8
ELineStyle Trend_8_Style      = eLineSolid;           // Style
color      Trend_8_Color      = clrGreen;           // Color
//--------------------------------------------
string     Trend_9_Name       = "Reserved";           // → Trend 9
ELineStyle Trend_9_Style      = eLineSolid;           // Style
color      Trend_9_Color      = clrNavy;            // Color

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
    color    mColorType[CTX_MAX];
    int      mStyleType[CTX_MAX];
    int      mWidthType[CTX_MAX];

// Component name
private:
    string cLnM0;
    string iTxtC;

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
    mColorType[TREND_1] = Trend_1_Color;
    mStyleType[TREND_1] = getLineStyle(Trend_1_Style);
    mWidthType[TREND_1] = getLineWidth(Trend_1_Style);
    //--------------------------------------------
    mNameType [TREND_2] = getName(Trend_2_Name);
    mDispText [TREND_2] = getAltName(Trend_2_Name);
    mColorType[TREND_2] = Trend_2_Color;
    mStyleType[TREND_2] = getLineStyle(Trend_2_Style);
    mWidthType[TREND_2] = getLineWidth(Trend_2_Style);
    //--------------------------------------------
    mNameType [TREND_3] = getName(Trend_3_Name);
    mDispText [TREND_3] = getAltName(Trend_3_Name);
    mColorType[TREND_3] = Trend_3_Color;
    mStyleType[TREND_3] = getLineStyle(Trend_3_Style);
    mWidthType[TREND_3] = getLineWidth(Trend_3_Style);
    //--------------------------------------------
    mNameType [TREND_4] = getName(Trend_4_Name);
    mDispText [TREND_4] = getAltName(Trend_4_Name);
    mColorType[TREND_4] = Trend_4_Color;
    mStyleType[TREND_4] = getLineStyle(Trend_4_Style);
    mWidthType[TREND_4] = getLineWidth(Trend_4_Style);
    //--------------------------------------------
    mNameType [TREND_5] = getName(Trend_5_Name);
    mDispText [TREND_5] = getAltName(Trend_5_Name);
    mColorType[TREND_5] = Trend_5_Color;
    mStyleType[TREND_5] = getLineStyle(Trend_5_Style);
    mWidthType[TREND_5] = getLineWidth(Trend_5_Style);
    //--------------------------------------------
    mNameType [TREND_6] = getName(Trend_6_Name);
    mDispText [TREND_6] = getAltName(Trend_6_Name);
    mColorType[TREND_6] = Trend_6_Color;
    mStyleType[TREND_6] = getLineStyle(Trend_6_Style);
    mWidthType[TREND_6] = getLineWidth(Trend_6_Style);
    //--------------------------------------------
    mNameType [TREND_7] = getName(Trend_7_Name);
    mDispText [TREND_7] = getAltName(Trend_7_Name);
    mColorType[TREND_7] = Trend_7_Color;
    mStyleType[TREND_7] = getLineStyle(Trend_7_Style);
    mWidthType[TREND_7] = getLineWidth(Trend_7_Style);
    //--------------------------------------------
    mNameType [TREND_8] = getName(Trend_8_Name);
    mDispText [TREND_8] = getAltName(Trend_8_Name);
    mColorType[TREND_8] = Trend_8_Color;
    mStyleType[TREND_8] = getLineStyle(Trend_8_Style);
    mWidthType[TREND_8] = getLineWidth(Trend_8_Style);
    //--------------------------------------------
    mNameType [TREND_9] = getName(Trend_9_Name);
    mDispText [TREND_9] = getAltName(Trend_9_Name);
    mColorType[TREND_9] = Trend_9_Color;
    mStyleType[TREND_9] = getLineStyle(Trend_9_Style);
    mWidthType[TREND_9] = getLineWidth(Trend_9_Style);
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
    iTxtC = itemId + TAG_INFO + "iTxtC";

    mAllItem += cLnM0+iTxtC;
}
string Trend::getAllItem(string itemId)
{
    string allItem = itemId + "_mTData";
    allItem += itemId + TAG_INFO + "iTxtC";
    //--- Control item ---
    allItem += itemId + TAG_CTRM + "cLnM0";

    return allItem;
}

void Trend::refreshData()
{
    // Update Main Compoment
    setItemPos(cLnM0, time1, time2, price1, price2);

    // Update Text
    setItemPos(iTxtC, time3, price3);

    int barT1 = iBarShift(ChartSymbol(), ChartPeriod(), time1);
    int barT2 = iBarShift(ChartSymbol(), ChartPeriod(), time2);

    if (price1 == price2){
        ObjectSet(iTxtC, OBJPROP_ANCHOR, price1 >= High[barT1] ? ANCHOR_LOWER : ANCHOR_UPPER);
    }
    else if (barT2 > barT1) {
        if (price1 >= High[barT1]) {
            ObjectSet(iTxtC, OBJPROP_ANCHOR, (price1 > price2) ? ANCHOR_RIGHT_LOWER : ANCHOR_LEFT_LOWER);
        }
        else {
            ObjectSet(iTxtC, OBJPROP_ANCHOR, (price1 > price2) ? ANCHOR_LEFT_UPPER : ANCHOR_RIGHT_UPPER);
        }
    }
    else {
        if (price2 >= High[barT2]) {
            ObjectSet(iTxtC, OBJPROP_ANCHOR, (price2 > price1) ? ANCHOR_RIGHT_LOWER : ANCHOR_LEFT_LOWER);
        }
        else {
            ObjectSet(iTxtC, OBJPROP_ANCHOR, (price2 > price1) ? ANCHOR_LEFT_UPPER : ANCHOR_RIGHT_UPPER);
        }
    }
    // Customization
    int selected = (int)ObjectGet(cLnM0, OBJPROP_SELECTED);
    if (selected) gContextMenu.openStaticCtxMenu(cLnM0, mContextType);
    else gContextMenu.clearStaticCtxMenu(cLnM0);
}

void Trend::createItem()
{
    ObjectCreate(cLnM0, OBJ_TREND       , 0, 0, 0);
    ObjectCreate(iTxtC, OBJ_TEXT        , 0, 0, 0);

    updateDefaultProperty();
    updateTypeProperty();
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void Trend::updateDefaultProperty()
{
    setMultiStrs(OBJPROP_TOOLTIP, "\n", mAllItem);
    ObjectSet(iTxtC, OBJPROP_SELECTABLE, false);
    ObjectSet(cLnM0, OBJPROP_BACK, true );
    ObjectSet(cLnM0, OBJPROP_RAY , false);
}
void Trend::updateTypeProperty()
{
    setMultiProp(OBJPROP_COLOR, mColorType[mIndexType], iTxtC);
    setTextContent(iTxtC, mDispText[mIndexType], 8, FONT_TEXT, mColorType[mIndexType]);
    setObjectStyle(cLnM0,  mColorType[mIndexType], mStyleType[mIndexType],  mWidthType[mIndexType]);
}
void Trend::updateItemAfterChangeType()
{
    if (mFirstPoint == true) {
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

    getCenterPos(time1, time2, price1, price2, time3, price3);

    refreshData();
}
void Trend::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, TAG_CTRL) < 0) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    setCtrlItemSelectState(mAllItem, selected);
    if (selected) gContextMenu.openStaticCtxMenu(cLnM0, mContextType);
    else gContextMenu.clearStaticCtxMenu(cLnM0);
}
void Trend::onItemChange(const string &itemId, const string &objId)
{
    if (objId == cLnM0){
        ObjectSet(iTxtC, OBJPROP_COLOR, (color)ObjectGet(objId, OBJPROP_COLOR));
        string description = ObjectDescription(objId);
        if (description != STR_EMPTY && description != ""){
            setTextContent(objId, "");
            setTextContent(iTxtC, (description == "-") ? STR_EMPTY : description);
        }
    }
    onItemDrag(itemId, objId);
}
void Trend::onMouseClick()
{
    if (mFirstPoint == false){
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void Trend::onMouseMove()
{
    MOUSE_MOVE_RETURN_CHECK
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
