#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string            R_e_c_t_a_n_g_l_e___Cfg = SEPARATE_LINE;
input color             __R_Text_Color  = clrDarkGray;
//-----------------------------------------------------------
      string            R_e_c_t_a_n_g_l_e___S_z___Cfg = SEPARATE_LINE;
      string            __R_Sz_Name       = "Sz";
input color             __R_Sz_Color      = C'64,0,32';
//-----------------------------------------------------------
      string            R_e_c_t_a_n_g_l_e___D_z___Cfg = SEPARATE_LINE;
      string            __R_Dz_Name       = "Dz";
input color             __R_Dz_Color      = C'21,43,37';
//-----------------------------------------------------------
      string            R_e_c_t_a_n_g_l_e___S_z1__Cfg = SEPARATE_LINE;
      string            __R_SzLight_Name  = "SzLight";
input color             __R_SzLight_Color = C'40,0,21';
//-----------------------------------------------------------
      string            R_e_c_t_a_n_g_l_e___D_z2__Cfg = SEPARATE_LINE;
      string            __R_DzLight_Name  = "DzLight";
input color             __R_DzLight_Color = C'14,29,24';
//-----------------------------------------------------------

enum RectangleType
{
    SYPPLY_TYPE,
    DEMAND_TYPE,
    SZ_LIGHT_TYPE,
    DZ_LIGHT_TYPE,
    RECT_NUM,
};

class Rectangle : public BaseItem
{
// Internal Value
private:
    color mPropColor[MAX_TYPE];

// Component name
private:
    string iBkgnd;
    string iCText;
    string iLText;
    string iRText;

    string cPointL1;
    string cPointL2;
    string cPointR1;
    string cPointR2;
    string cPointC1;
    string cPointC2;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double   price1;
    double   price2;

    double   centerPrice;
    datetime centerTime;

public:
    Rectangle(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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

Rectangle::Rectangle(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [SYPPLY_TYPE]   = __R_Sz_Name      ;
    mPropColor[SYPPLY_TYPE]   = __R_Sz_Color     ;
    //------------------------------------------
    mNameType [DEMAND_TYPE]   = __R_Dz_Name      ;
    mPropColor[DEMAND_TYPE]   = __R_Dz_Color     ;
    //------------------------------------------
    mNameType [SZ_LIGHT_TYPE] = __R_SzLight_Name ;
    mPropColor[SZ_LIGHT_TYPE] = __R_SzLight_Color;
    //------------------------------------------
    mNameType [DZ_LIGHT_TYPE] = __R_DzLight_Name ;
    mPropColor[DZ_LIGHT_TYPE] = __R_DzLight_Color;
    //------------------------------------------
    mTypeNum = RECT_NUM;
    mIndexType = 0;
}

// Internal Event
void Rectangle::prepareActive(){}
void Rectangle::createItem()
{
    ObjectCreate(cPointL1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointL2, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointR1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointR2, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointC1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointC2, OBJ_ARROW, 0, 0, 0);

    ObjectCreate(iCText, OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iLText, OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iRText, OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iBkgnd, OBJ_RECTANGLE , 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();
    // Value define update
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void Rectangle::updateDefaultProperty()
{
    multiSetProp(OBJPROP_ARROWCODE,       4, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);
    multiSetProp(OBJPROP_COLOR    , clrNONE, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);

    ObjectSetText(iCText, "");
    ObjectSetText(iLText, "");
    ObjectSetText(iRText, "");

    ObjectSetInteger(ChartID(), iCText, OBJPROP_ANCHOR, ANCHOR_CENTER);
    ObjectSetInteger(ChartID(), iLText, OBJPROP_ANCHOR, ANCHOR_LEFT);
    ObjectSetInteger(ChartID(), iRText, OBJPROP_ANCHOR, ANCHOR_RIGHT);

    multiSetProp(OBJPROP_COLOR     , __R_Text_Color, iCText+iLText+iRText);
    multiSetProp(OBJPROP_SELECTABLE, false         , iCText+iLText+iRText);
    multiSetStrs(OBJPROP_TOOLTIP   , "\n"          , cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2+iBkgnd+iCText+iLText+iRText);
}
void Rectangle::updateTypeProperty()
{
    SetRectangleBackground(iBkgnd, mPropColor[mIndexType]);
}
void Rectangle::activateItem(const string& itemId)
{
    iBkgnd = itemId + "_c0Bkgnd";
    iCText = itemId + "_0iCText";
    iLText = itemId + "_0iLText";
    iRText = itemId + "_0iRText";

    cPointL1 = itemId + "_cPointL1";
    cPointL2 = itemId + "_cPointL2";
    cPointR1 = itemId + "_cPointR1";
    cPointR2 = itemId + "_cPointR2";
    cPointC1 = itemId + "_cPointC1";
    cPointC2 = itemId + "_cPointC2";
}
void Rectangle::updateItemAfterChangeType()
{
    if (mFirstPoint == true)
    {
        updateTypeProperty();
    }
}
void Rectangle::refreshData()
{
    getCenterPos(time1, time2, price1, price2, centerTime, centerPrice);

    setItemPos(cPointL1, time1, price1);
    setItemPos(cPointL2, time1, price2);
    setItemPos(cPointR1, time2, price1);
    setItemPos(cPointR2, time2, price2);
    setItemPos(cPointC1, time1, centerPrice);
    setItemPos(cPointC2, time2, centerPrice);

    setItemPos(iBkgnd, time1, time2, price1, price2);
    //-------------------------------------------------
    setTextPos(iLText, time1 + ChartPeriod()*60, centerPrice);
    setTextPos(iRText, time2 - ChartPeriod()*60, centerPrice);
    setTextPos(iCText, centerTime, centerPrice);
    //-------------------------------------------------
    scanBackgroundOverlap(iBkgnd);
}
void Rectangle::finishedJobDone(){}

// Chart Event
void Rectangle::onMouseMove()
{
    if (mFirstPoint == false)
    {
        return;
    }
    time2  = pCommonData.mMouseTime;
    price2 = pCommonData.mMousePrice;
    refreshData();
}
void Rectangle::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void Rectangle::onItemDrag(const string &itemId, const string &objId)
{
    if (pCommonData.mCtrlHold)
    {
        if (objId == cPointL1 || objId == cPointR2 || objId == cPointL2 || objId == cPointR1) ObjectSet(objId, OBJPROP_PRICE1, pCommonData.mMousePrice);
    }

    if (objId == cPointL1 || objId == cPointR2 )
    {
        time1  = (datetime)ObjectGet(cPointL1, OBJPROP_TIME1);
        price1 =           ObjectGet(cPointL1, OBJPROP_PRICE1);
        time2  = (datetime)ObjectGet(cPointR2, OBJPROP_TIME1);
        price2 =           ObjectGet(cPointR2, OBJPROP_PRICE1);
    }
    else if (objId == cPointL2 || objId == cPointR1)
    {
        time1  = (datetime)ObjectGet(cPointL2, OBJPROP_TIME1);
        price2 =           ObjectGet(cPointL2, OBJPROP_PRICE1);
        time2  = (datetime)ObjectGet(cPointR1, OBJPROP_TIME1);
        price1 =           ObjectGet(cPointR1, OBJPROP_PRICE1);
    }
    else
    {
        time1  = (datetime)ObjectGet(cPointL1, OBJPROP_TIME1);
        price1 =           ObjectGet(cPointL1, OBJPROP_PRICE1);
        time2  = (datetime)ObjectGet(cPointR2, OBJPROP_TIME1);
        price2 =           ObjectGet(cPointR2, OBJPROP_PRICE1);
        if (objId == cPointC1)
        {
            time1 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
        }
        else if (objId == cPointC2)
        {
            time2 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
        }
    }
    refreshData();
}
void Rectangle::onItemClick(const string &itemId, const string &objId)
{
    if (objId == iCText || objId == iLText || objId == iRText) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    multiSetProp(OBJPROP_SELECTED, selected, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2+iBkgnd+iCText+iLText+iRText);
    if (selected) multiSetProp(OBJPROP_COLOR    ,  MidnightBlue, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);
    else          multiSetProp(OBJPROP_COLOR    ,       clrNONE, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);
}
void Rectangle::onItemChange(const string &itemId, const string &objId)
{
    string targetItem;
    if (objId == iBkgnd)      targetItem = iCText;
    else if (objId == cPointC2) targetItem = iRText;
    else if (objId == cPointC1) targetItem = iLText;
    else                      return;
    
    string txtContent = ObjectDescription(objId);
    if (txtContent == "" ) return;
    if (txtContent == ".") txtContent = "";
    ObjectSetText(targetItem, ObjectDescription(objId));
    ObjectSetText(objId, "");
    onItemDrag(itemId, objId);
}
void Rectangle::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(iBkgnd);
    removeBackgroundOverlap(iBkgnd);
}