#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string          Trend_ = SEPARATE_LINE_BIG;
//--------------------------------------------
input color           Trend1_Color = clrWhite;
input int             Trend1_Width = 1;
input ENUM_LINE_STYLE Trend1_Style = 0;
input string          Trend1_sp    = SEPARATE_LINE;
//--------------------------------------------
input color           Trend2_Color = clrRed;
input int             Trend2_Width = 1;
input ENUM_LINE_STYLE Trend2_Style = 2;
//--------------------------------------------

class Trend : public BaseItem
{
// Internal Value
private:
    color mColorType[MAX_TYPE];
    int   mWidthType[MAX_TYPE];
    int   mStyleType[MAX_TYPE];

// Component name
private:
    string cMainTrend;
    string cText    ;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    datetime time3;
    double price1;
    double price2;
    double price3;
    double priceText;

public:
    Trend(const string name, CommonData* commonData, MouseInfo* mouseInfo);

// Internal Event
public:
    virtual void activateItem(const string& itemId);
    virtual void refreshData();
    virtual void createItem();
    virtual void updateDefaultProperty();
    virtual void updateTypeProperty();
    virtual void prepareActive();
    virtual void updateItemAfterChangeType();

// Chart Event
public:
    virtual void onMouseMove();
    virtual void onMouseClick();
    virtual void onItemDrag(const string &itemId, const string &objId);
    virtual void onItemClick(const string &itemId, const string &objId);
    virtual void onItemChange(const string &itemId, const string &objId);
    virtual void onItemDeleted(const string &itemId, const string &objId);
};

Trend::Trend(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    mNameType [0] = "Trend1";
    mColorType[0] = Trend1_Color;
    mWidthType[0] = Trend1_Width;
    mStyleType[0] = Trend1_Style;
    //--------------------------------
    mNameType [1] = "Trend2";
    mColorType[1] = Trend2_Color;
    mWidthType[1] = Trend2_Width;
    mStyleType[1] = Trend2_Style;

    mIndexType = 0;
    mTypeNum = 2;
}

// Internal Event
void Trend::prepareActive(){}

void Trend::activateItem(const string& itemId)
{
    cMainTrend = itemId + "_mainTrend";
    cText      = itemId + "_text";
}

void Trend::refreshData()
{
    ObjectSet(cMainTrend, OBJPROP_TIME1,  time1);
    ObjectSet(cMainTrend, OBJPROP_PRICE1, price1);

    ObjectSet(cMainTrend, OBJPROP_TIME2,  time2);
    ObjectSet(cMainTrend, OBJPROP_PRICE2, price2);

    ObjectSet(cText, OBJPROP_TIME1,  time3);
    ObjectSet(cText, OBJPROP_PRICE1, price3);
    if (priceText == price3)
    {
        return;
    }
    if (priceText > price3)
    {
        ObjectSetInteger(0, cText, OBJPROP_ANCHOR, ANCHOR_LOWER);
    }
    else
    {
        ObjectSetInteger(0, cText, OBJPROP_ANCHOR, ANCHOR_UPPER);
    }
}

void Trend::createItem()
{
    ObjectCreate(cMainTrend, OBJ_TREND, 0, 0, 0);
    ObjectCreate(cText     , OBJ_TEXT , 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void Trend::updateDefaultProperty()
{
    ObjectSet(cMainTrend, OBJPROP_RAY, false);
    ObjectSetText(cText, "");
    ObjectSetString(ChartID(), cText      ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cMainTrend ,OBJPROP_TOOLTIP,"\n");
}
void Trend::updateTypeProperty()
{
    ObjectSet(cMainTrend, OBJPROP_COLOR, mColorType[mIndexType]);
    ObjectSet(cMainTrend, OBJPROP_WIDTH, mWidthType[mIndexType]);
    ObjectSet(cMainTrend, OBJPROP_STYLE, mStyleType[mIndexType]);
    ObjectSet(cText,      OBJPROP_COLOR, mColorType[mIndexType]);
}
void Trend::updateItemAfterChangeType()
{
    if (mFirstPoint == true)
    {
        updateTypeProperty();
    }
}

//Chart Event
void Trend::onItemDrag(const string &itemId, const string &objId)
{
    time1 = (datetime)ObjectGet(cMainTrend, OBJPROP_TIME1);
    time2 = (datetime)ObjectGet(cMainTrend, OBJPROP_TIME2);
    price1 = ObjectGet(cMainTrend, OBJPROP_PRICE1);
    price2 = ObjectGet(cMainTrend, OBJPROP_PRICE2);
    getCenterPos(time1, time2, price1, price2, time3, price3);
    priceText = price3;

    if (objId == cText)
    {
        priceText = ObjectGet(cText, OBJPROP_PRICE1);
    }

    refreshData();
}
void Trend::onItemClick(const string &itemId, const string &objId)
{
    if (objId == cText)
    {
        ObjectSet(cMainTrend, OBJPROP_SELECTED, ObjectGet(cText, OBJPROP_SELECTED));
    }
}
void Trend::onItemChange(const string &itemId, const string &objId)
{
    color c = (color)ObjectGet(objId, OBJPROP_COLOR);
    ObjectSet(cMainTrend, OBJPROP_COLOR, c);
    ObjectSet(cText     , OBJPROP_COLOR, c);
    if (objId == cMainTrend)
    {
        string lineDescription = ObjectDescription(cMainTrend);
        if (lineDescription != "")
        {
            ObjectSetText(cText    , lineDescription);
            ObjectSetText(cMainTrend, "");
        }
    }
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
    if (mFirstPoint == false)
    {
        return;
    }
    if (pCommonData.mShiftHold)
    {
        price2 = price1;
    }
    else
    {
        price2 = pCommonData.mMousePrice;
    }
    time2  = pCommonData.mMouseTime;
    refreshData();
}
void Trend::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cMainTrend);
    ObjectDelete(cText    );
}