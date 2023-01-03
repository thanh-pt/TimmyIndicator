#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string            Rectangle_ = SEPARATE_LINE_BIG;
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

    ObjectSetString(ChartID(), cBackground ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cBoder      ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cLeftPoint  ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cRightPoint ,OBJPROP_TOOLTIP,"\n");
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
    ObjectSet(cBackground   , OBJPROP_TIME1,  time1);
    ObjectSet(cBackground   , OBJPROP_TIME2,  time2);
    ObjectSet(cBackground   , OBJPROP_PRICE1, price1);
    ObjectSet(cBackground   , OBJPROP_PRICE2, price2);
    //-------------------------------------------------
    ObjectSet(cBoder        , OBJPROP_TIME1,  time1);
    ObjectSet(cBoder        , OBJPROP_TIME2,  time2);
    ObjectSet(cBoder        , OBJPROP_PRICE1, price1);
    ObjectSet(cBoder        , OBJPROP_PRICE2, price2);
    //-------------------------------------------------
    double centerPrice = (price1+price2)/2;
    ObjectSet(cLeftPoint    , OBJPROP_TIME1,  time1);
    ObjectSet(cLeftPoint    , OBJPROP_PRICE1, centerPrice);
    //-------------------------------------------------
    ObjectSet(cRightPoint   , OBJPROP_TIME1,  time2);
    ObjectSet(cRightPoint   , OBJPROP_PRICE1, centerPrice);
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
    refreshData();
}
void Rectangle::onItemClick(const string &itemId, const string &objId)
{
    int objSelected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    ObjectSet(cBoder     , OBJPROP_SELECTED, objSelected);
    ObjectSet(cBackground, OBJPROP_SELECTED, objSelected);
    ObjectSet(cLeftPoint , OBJPROP_SELECTED, objSelected);
    ObjectSet(cRightPoint, OBJPROP_SELECTED, objSelected);
}
void Rectangle::onItemChange(const string &itemId, const string &objId){}
void Rectangle::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cBoder     );
    ObjectDelete(cBackground);
    ObjectDelete(cLeftPoint );
    ObjectDelete(cRightPoint);
}