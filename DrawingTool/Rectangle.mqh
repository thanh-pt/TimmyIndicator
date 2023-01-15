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
//-----------------------------------------------------------
input string            Rectangle_3_NAME        = "Boder";
input color             Rectangle_3_BoderColor  = clrDarkGray;
input int               Rectangle_3_BoderWidth  = 0;
input ENUM_LINE_STYLE   Rectangle_3_BoderStyle  = 2;
input color             Rectangle_3_BackGrdClr  = clrNONE;

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
    string cBoder     ;
    string cBackground;
    string cLeftPoint ;
    string cRightPoint;
    string cCenterText;
    string cLeftText  ;
    string cRightText ;

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
    mNameType      [2] = Rectangle_3_NAME      ;
    mBoderColorType[2] = Rectangle_3_BoderColor;
    mBoderWidthType[2] = Rectangle_3_BoderWidth;
    mBoderStyleType[2] = Rectangle_3_BoderStyle;
    mBackGrdClrType[2] = Rectangle_3_BackGrdClr;
    //------------------------------------------
    mIndexType = 0;
    mTypeNum = 3;
}

// Internal Event
void Rectangle::prepareActive(){}
void Rectangle::createItem()
{
    ObjectCreate(cCenterText, OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(cLeftText  , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(cRightText , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(cBackground, OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(cBoder     , OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(cLeftPoint , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cRightPoint, OBJ_ARROW     , 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();
    // Value define update
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void Rectangle::updateDefaultProperty()
{
    ObjectSet(cBoder        , OBJPROP_BACK , false);
    ObjectSet(cBackground   , OBJPROP_BACK , true);

    ObjectSet(cLeftPoint    , OBJPROP_COLOR, clrNONE);
    ObjectSet(cRightPoint   , OBJPROP_COLOR, clrNONE);
    ObjectSet(cLeftPoint    , OBJPROP_ARROWCODE, 255);
    ObjectSet(cRightPoint   , OBJPROP_ARROWCODE, 255);

    ObjectSet(cCenterText   , OBJPROP_COLOR, Rectangle_TextColor);
    ObjectSet(cLeftText     , OBJPROP_COLOR, Rectangle_TextColor);
    ObjectSet(cRightText    , OBJPROP_COLOR, Rectangle_TextColor);

    ObjectSet(cCenterText   , OBJPROP_SELECTABLE, false);
    ObjectSet(cLeftText     , OBJPROP_SELECTABLE, false);
    ObjectSet(cRightText    , OBJPROP_SELECTABLE, false);

    ObjectSetText(cCenterText, "");
    ObjectSetText(cLeftText  , "");
    ObjectSetText(cRightText , "");
    
    ObjectSetInteger(ChartID(), cCenterText, OBJPROP_ANCHOR, ANCHOR_CENTER);
    ObjectSetInteger(ChartID(), cLeftText  , OBJPROP_ANCHOR, ANCHOR_LEFT);
    ObjectSetInteger(ChartID(), cRightText , OBJPROP_ANCHOR, ANCHOR_RIGHT);

    ObjectSetString(ChartID(), cBackground ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cBoder      ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cLeftPoint  ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cRightPoint ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cCenterText ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cLeftText   ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cRightText  ,OBJPROP_TOOLTIP,"\n");
}
void Rectangle::updateTypeProperty()
{
    ObjectSet(cBackground   , OBJPROP_COLOR, mBackGrdClrType[mIndexType]);

    ObjectSet(cBoder        , OBJPROP_COLOR, mBoderColorType[mIndexType]);
    ObjectSet(cBoder        , OBJPROP_WIDTH, mBoderWidthType[mIndexType]);
    ObjectSet(cBoder        , OBJPROP_STYLE, mBoderStyleType[mIndexType]);
}
void Rectangle::activateItem(const string& itemId)
{
    cBackground = itemId + "_Background";
    cBoder      = itemId + "_Boder";
    cLeftPoint  = itemId + "_LeftPoint";
    cRightPoint = itemId + "_RightPoint";
    cCenterText = itemId + "_cCenterText";
    cLeftText   = itemId + "_cLeftText";
    cRightText  = itemId + "_cRightText";
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
        time2 = time1 + ChartPeriod()*180;
    }
    getCenterPos(time1, time2, price1, price2, centerTime, centerPrice);
    setItemPos(cBackground, time1, time2, price1, price2);
    setItemPos(cBoder     , time1, time2, price1, price2);
    //-------------------------------------------------
    setItemPos(cLeftPoint , time1, centerPrice);
    setItemPos(cRightPoint, time2, centerPrice);
    //-------------------------------------------------
    setTextPos(cLeftText  , time1,      centerPrice);
    setTextPos(cRightText , time2,      centerPrice);
    setTextPos(cCenterText, centerTime, centerPrice);
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
    if (objId == cLeftPoint)
    {
        time1 = (datetime)ObjectGet(cLeftPoint, OBJPROP_TIME1);
    }
    else if (objId == cRightPoint)
    {
        time2 = (datetime)ObjectGet(cRightPoint, OBJPROP_TIME1);
    }
    if (pCommonData.mCtrlHold)
    {
        double oldPrice1 = ObjectGet(cBackground, OBJPROP_PRICE1);
        double oldPrice2 = ObjectGet(cBackground, OBJPROP_PRICE2);
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
    if (objId == cCenterText || objId == cLeftText || objId == cRightText) return;
    int objSelected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    ObjectSet(cBoder     , OBJPROP_SELECTED, objSelected);
    ObjectSet(cBackground, OBJPROP_SELECTED, objSelected);
    ObjectSet(cLeftPoint , OBJPROP_SELECTED, objSelected);
    ObjectSet(cRightPoint, OBJPROP_SELECTED, objSelected);
    ObjectSet(cCenterText, OBJPROP_SELECTED, objSelected);
    ObjectSet(cLeftText  , OBJPROP_SELECTED, objSelected);
    ObjectSet(cRightText , OBJPROP_SELECTED, objSelected);
}
void Rectangle::onItemChange(const string &itemId, const string &objId)
{
    string targetItem;
    if (objId == cBoder)            targetItem = cCenterText;
    else if (objId == cRightPoint)  targetItem = cRightText;
    else if (objId == cLeftPoint)   targetItem = cLeftText;
    else                            return;
    
    ObjectSetText(targetItem, ObjectDescription(objId));
    ObjectSetText(objId, "");
    onItemDrag(itemId, objId);
}
void Rectangle::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cBoder     );
    ObjectDelete(cBackground);
    ObjectDelete(cLeftPoint );
    ObjectDelete(cRightPoint);
    ObjectDelete(cCenterText);
    ObjectDelete(cLeftText  );
    ObjectDelete(cRightText );
}