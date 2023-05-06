#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string            Rectangle_ = SEPARATE_LINE_BIG;
input color             Rectangle_TextColor = clrDarkGray;
//-----------------------------------------------------------
input string            Rectangle_1_NAME        = "Supply";
input color             Rectangle_1_BackGrdClr  = C'39,24,34';
input string            Rectangle_1_sp          = SEPARATE_LINE;
//-----------------------------------------------------------
input string            Rectangle_2_NAME        = "Demand";
input color             Rectangle_2_BackGrdClr  = C'21,43,37';
input string            Rectangle_2_sp          = SEPARATE_LINE;
//-----------------------------------------------------------

enum RectangleType
{
    SYPPLY_TYPE,
    DEMAND_TYPE,
    RECT_NUM,
};

class Rectangle : public BaseItem
{
// Internal Value
private:
    color mBackGrdClrType[MAX_TYPE];

// Component name
private:
    string sOldPr;
    string cBkgnd;
    string cLPtr0;
    string cRPtr0;
    string iCText;
    string iLText;
    string iRText;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double   price1;
    double   price2;

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
    mNameType      [SYPPLY_TYPE] = Rectangle_1_NAME      ;
    mBackGrdClrType[SYPPLY_TYPE] = Rectangle_1_BackGrdClr;
    //------------------------------------------
    mNameType      [DEMAND_TYPE] = Rectangle_2_NAME      ;
    mBackGrdClrType[DEMAND_TYPE] = Rectangle_2_BackGrdClr;
    //------------------------------------------
    mTypeNum = RECT_NUM;
    mIndexType = 0;
}

// Internal Event
void Rectangle::prepareActive(){}
void Rectangle::createItem()
{
    ObjectCreate(sOldPr, OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iCText, OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iLText, OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iRText, OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(cBkgnd, OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(cLPtr0, OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cRPtr0, OBJ_ARROW     , 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();
    // Value define update
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void Rectangle::updateDefaultProperty()
{
    ObjectSet(cLPtr0, OBJPROP_COLOR, clrNONE);
    ObjectSet(cRPtr0, OBJPROP_COLOR, clrNONE);
    ObjectSet(cLPtr0, OBJPROP_ARROWCODE, 255);
    ObjectSet(cRPtr0, OBJPROP_ARROWCODE, 255);

    ObjectSetText(iCText, "");
    ObjectSetText(iLText, "");
    ObjectSetText(iRText, "");

    ObjectSetInteger(ChartID(), iCText, OBJPROP_ANCHOR, ANCHOR_CENTER);
    ObjectSetInteger(ChartID(), iLText, OBJPROP_ANCHOR, ANCHOR_LEFT);
    ObjectSetInteger(ChartID(), iRText, OBJPROP_ANCHOR, ANCHOR_RIGHT);

    multiSetProp(OBJPROP_COLOR     , Rectangle_TextColor, iCText+iLText+iRText);
    multiSetProp(OBJPROP_SELECTABLE, false              , iCText+iLText+iRText);
    multiSetStrs(OBJPROP_TOOLTIP   , "\n"               , cBkgnd+cLPtr0+cRPtr0+iCText+iLText+iRText);
}
void Rectangle::updateTypeProperty()
{
    SetRectangleBackground(cBkgnd, mBackGrdClrType[mIndexType]);
}
void Rectangle::activateItem(const string& itemId)
{
    cBkgnd = itemId + "_c0Boder";
    cLPtr0 = itemId + "_c1LPtr0";
    cRPtr0 = itemId + "_c1RPtr0";
    iCText = itemId + "_0iCText";
    iLText = itemId + "_0iLText";
    iRText = itemId + "_0iRText";
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
    double centerPrice;
    datetime centerTime;
    if (time1 == time2) time2 = time1 + ChartPeriod()*60*5;
    getCenterPos(time1, time2, price1, price2, centerTime, centerPrice);
    setItemPos(cBkgnd, time1, time2, price1, price2);
    setItemPos(sOldPr, time1, time2, 0     , 0     );
    //-------------------------------------------------
    setItemPos(cLPtr0, time1, centerPrice);
    setItemPos(cRPtr0, time2, centerPrice);
    //-------------------------------------------------
    setTextPos(iLText, time1 + ChartPeriod()*60, centerPrice);
    setTextPos(iRText, time2 - ChartPeriod()*60, centerPrice);
    setTextPos(iCText, centerTime, centerPrice);
    //-------------------------------------------------
    scanBackgroundOverlap(cBkgnd);
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
    time1  = (datetime)ObjectGet(cBkgnd, OBJPROP_TIME1);
    time2  = (datetime)ObjectGet(cBkgnd, OBJPROP_TIME2);
    price1 =           ObjectGet(cBkgnd, OBJPROP_PRICE1);
    price2 =           ObjectGet(cBkgnd, OBJPROP_PRICE2);
    if (objId == cLPtr0)
    {
        time1 = (datetime)ObjectGet(cLPtr0, OBJPROP_TIME1);
    }
    else if (objId == cRPtr0)
    {
        time2 = (datetime)ObjectGet(cRPtr0, OBJPROP_TIME1);
    }
    if (pCommonData.mCtrlHold)
    {
        double oldPrice1 = ObjectGet(sOldPr, OBJPROP_PRICE1);
        double oldPrice2 = ObjectGet(sOldPr, OBJPROP_PRICE2);
        if (price1 == oldPrice1 && price2 != oldPrice2)
        {
            price2 = pCommonData.mMousePrice;
        }
        else if (price2 == oldPrice2 && price1 != oldPrice1)
        {
            price1 = pCommonData.mMousePrice;
        }
    }
    refreshData();
}
void Rectangle::onItemClick(const string &itemId, const string &objId)
{
    if (objId == iCText || objId == iLText || objId == iRText) return;
    multiSetProp(OBJPROP_SELECTED, (int)ObjectGet(objId, OBJPROP_SELECTED), cBkgnd+cLPtr0+cRPtr0+iCText+iLText+iRText+sOldPr);
}
void Rectangle::onItemChange(const string &itemId, const string &objId)
{
    string targetItem;
    if (objId == cBkgnd)      targetItem = iCText;
    else if (objId == cRPtr0) targetItem = iRText;
    else if (objId == cLPtr0) targetItem = iLText;
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
    ObjectDelete(cBkgnd);
    ObjectDelete(cLPtr0);
    ObjectDelete(cRPtr0);
    ObjectDelete(iCText);
    ObjectDelete(iLText);
    ObjectDelete(iRText);
    removeBackgroundOverlap(cBkgnd);
}