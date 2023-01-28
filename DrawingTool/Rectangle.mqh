#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string            Rectangle_ = SEPARATE_LINE_BIG;
input color             Rectangle_TextColor = clrDarkGray;
//-----------------------------------------------------------
input string            Rectangle_1_NAME        = "Supply";
input color             Rectangle_1_BoderColor  = clrNONE;
input int               Rectangle_1_BoderWidth  = 0;
input ENUM_LINE_STYLE   Rectangle_1_BoderStyle  = 2;
input color             Rectangle_1_BackGrdClr  = C'39,24,34';
input string            Rectangle_1_sp          = SEPARATE_LINE;
//-----------------------------------------------------------
input string            Rectangle_2_NAME        = "Demand";
input color             Rectangle_2_BoderColor  = clrNONE;
input int               Rectangle_2_BoderWidth  = 0;
input ENUM_LINE_STYLE   Rectangle_2_BoderStyle  = 2;
input color             Rectangle_2_BackGrdClr  = C'21,43,37';
input string            Rectangle_2_sp          = SEPARATE_LINE;
// //-----------------------------------------------------------
// input string            Rectangle_3_NAME        = "Boder";
// input color             Rectangle_3_BoderColor  = clrDarkGray;
// input int               Rectangle_3_BoderWidth  = 0;
// input ENUM_LINE_STYLE   Rectangle_3_BoderStyle  = 2;
// input color             Rectangle_3_BackGrdClr  = clrNONE;

class Rectangle : public BaseItem
{
// Internal Value
private:
    color mBoderColorType[MAX_TYPE];
    int   mBoderWidthType[MAX_TYPE];
    int   mBoderStyleType[MAX_TYPE];
    color mBackGrdClrType[MAX_TYPE];

// Component name
private:
    string cBoder;
    string cLPtr0;
    string cRPtr0;
    string iBkgnd;
    string iCText;
    string iLText;
    string iRText;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double price1;
    double price2;

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
    mNameType      [0] = Rectangle_1_NAME      ;
    mBoderColorType[0] = Rectangle_1_BoderColor;
    mBoderWidthType[0] = Rectangle_1_BoderWidth;
    mBoderStyleType[0] = Rectangle_1_BoderStyle;
    mBackGrdClrType[0] = Rectangle_1_BackGrdClr;
    //------------------------------------------
    mNameType      [1] = Rectangle_2_NAME      ;
    mBoderColorType[1] = Rectangle_2_BoderColor;
    mBoderWidthType[1] = Rectangle_2_BoderWidth;
    mBoderStyleType[1] = Rectangle_2_BoderStyle;
    mBackGrdClrType[1] = Rectangle_2_BackGrdClr;
    //------------------------------------------
    // mNameType      [2] = Rectangle_3_NAME      ;
    // mBoderColorType[2] = Rectangle_3_BoderColor;
    // mBoderWidthType[2] = Rectangle_3_BoderWidth;
    // mBoderStyleType[2] = Rectangle_3_BoderStyle;
    // mBackGrdClrType[2] = Rectangle_3_BackGrdClr;
    //------------------------------------------
    mIndexType = 0;
    mTypeNum = 2;
}

// Internal Event
void Rectangle::prepareActive(){}
void Rectangle::createItem()
{
    ObjectCreate(iCText, OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iLText, OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iRText, OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iBkgnd, OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(cBoder, OBJ_RECTANGLE , 0, 0, 0);
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

    multiObjectSet(OBJPROP_COLOR     , Rectangle_TextColor, iCText+iLText+iRText);
    multiObjectSet(OBJPROP_SELECTABLE, false              , iCText+iLText+iRText+iBkgnd);
    multiObjectSetString(OBJPROP_TOOLTIP, "\n", iBkgnd+cBoder+cLPtr0+cRPtr0+iCText+iLText+iRText);
}
void Rectangle::updateTypeProperty()
{
    SetRectangleBackground(iBkgnd, mBackGrdClrType[mIndexType]);
    SetObjectStyle(cBoder, mBoderColorType[mIndexType], mBoderStyleType[mIndexType], mBoderWidthType[mIndexType]);
}
void Rectangle::activateItem(const string& itemId)
{
    cBoder = itemId + "_cBoder";
    cLPtr0 = itemId + "_cLPtr0";
    cRPtr0 = itemId + "_cRPtr0";
    iBkgnd = itemId + "_iBkgnd";
    iCText = itemId + "_iCText";
    iLText = itemId + "_iLText";
    iRText = itemId + "_iRText";
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
    if (time1 == time2)
    {
        time2 = time1 + ChartPeriod()*60*5;
    }
    getCenterPos(time1, time2, price1, price2, centerTime, centerPrice);
    setItemPos(iBkgnd, time1, time2, price1, price2);
    setItemPos(cBoder, time1, time2, price1, price2);
    //-------------------------------------------------
    setItemPos(cLPtr0, time1, centerPrice);
    setItemPos(cRPtr0, time2, centerPrice);
    //-------------------------------------------------
    setTextPos(iLText, time1     , centerPrice);
    setTextPos(iRText, time2     , centerPrice);
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
    time1 = (datetime)ObjectGet(cBoder, OBJPROP_TIME1);
    time2 = (datetime)ObjectGet(cBoder, OBJPROP_TIME2);
    price1 = ObjectGet(cBoder, OBJPROP_PRICE1);
    price2 = ObjectGet(cBoder, OBJPROP_PRICE2);
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
        double oldPrice1 = ObjectGet(iBkgnd, OBJPROP_PRICE1);
        double oldPrice2 = ObjectGet(iBkgnd, OBJPROP_PRICE2);
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
    PrintFormat("%d -> %d", time1, time2);
}
void Rectangle::onItemClick(const string &itemId, const string &objId)
{
    if (objId == iCText || objId == iLText || objId == iRText) return;
    multiObjectSet(OBJPROP_SELECTED, (int)ObjectGet(objId, OBJPROP_SELECTED), iBkgnd+cBoder+cLPtr0+cRPtr0+iCText+iLText+iRText);
}
void Rectangle::onItemChange(const string &itemId, const string &objId)
{
    string targetItem;
    if (objId == cBoder)      targetItem = iCText;
    else if (objId == cRPtr0) targetItem = iRText;
    else if (objId == cLPtr0) targetItem = iLText;
    else                      return;
    
    ObjectSetText(targetItem, ObjectDescription(objId));
    ObjectSetText(objId, "");
    onItemDrag(itemId, objId);
}
void Rectangle::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cBoder);
    ObjectDelete(iBkgnd);
    ObjectDelete(cLPtr0);
    ObjectDelete(cRPtr0);
    ObjectDelete(iCText);
    ObjectDelete(iLText);
    ObjectDelete(iRText);
    removeBackgroundOverlap(iBkgnd);
}