#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string            HTrend_ = "HTrend Config";
//-----------------------------------------------------------
input string            HTrend_1_NAME   = "Break up";
input color             HTrend_1_Color  = clrYellowGreen;
input int               HTrend_1_Width  = 0;
input ENUM_LINE_STYLE   HTrend_1_Style  = 2;
input string            HTrend_1_Text   = "bos";
input ENUM_ANCHOR_POINT HTrend_1_Anchor = ANCHOR_LOWER;
//-----------------------------------------------------------
input string            HTrend_2_NAME   = "Break down";
input color             HTrend_2_Color  = clrOrangeRed;
input int               HTrend_2_Width  = 0;
input ENUM_LINE_STYLE   HTrend_2_Style  = 2;
input string            HTrend_2_Text   = "bos";
input ENUM_ANCHOR_POINT HTrend_2_Anchor = ANCHOR_UPPER;

class HTrend : public BaseItem
{
// Internal Value
private:
    color               mColorType[MAX_TYPE];
    int                 mWidthType[MAX_TYPE];
    ENUM_LINE_STYLE     mStyleType[MAX_TYPE];
    string              mText_Type[MAX_TYPE];
    ENUM_ANCHOR_POINT   mAnchrType[MAX_TYPE];

// Component name
private:
    string cMainTrend;
    string cText    ;

// Value define for Item
private:
    double price;
    double priceText;
    datetime time1;
    datetime time2;
    datetime timeText;

public:
    HTrend(const string name, CommonData* commonData, MouseInfo* mouseInfo);

// Internal Event
public:
    virtual void prepareActive();
    virtual void createItem();
    virtual void updateDefaultProperty();
    virtual void updateTypeProperty();
    virtual void activateItem(const string& itemId);
    virtual void updateItemAfterChangeType();
    virtual void refreshData();

// Chart Event
public:
    virtual void onMouseMove();
    virtual void onMouseClick();
    virtual void onItemDrag(const string &itemId, const string &objId);
    virtual void onItemClick(const string &itemId, const string &objId);
    virtual void onItemChange(const string &itemId, const string &objId);
    virtual void onItemDeleted(const string &itemId, const string &objId);
};

HTrend::HTrend(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [0] = HTrend_1_NAME  ;
    mColorType[0] = HTrend_1_Color ;
    mWidthType[0] = HTrend_1_Width ;
    mStyleType[0] = HTrend_1_Style ;
    mText_Type[0] = HTrend_1_Text  ;
    mAnchrType[0] = HTrend_1_Anchor;
    //-----------------------------
    mNameType [1] = HTrend_2_NAME  ;
    mColorType[1] = HTrend_2_Color ;
    mWidthType[1] = HTrend_2_Width ;
    mStyleType[1] = HTrend_2_Style ;
    mText_Type[1] = HTrend_2_Text  ;
    mAnchrType[1] = HTrend_2_Anchor;
    mIndexType = 0;
    mTypeNum = 2;
}

// Internal Event
void HTrend::prepareActive()
{
    mFirstPoint = false;
    pMouseInfo.setText(mNameType[mIndexType]);
}

void HTrend::createItem()
{
    ObjectCreate(cText    , OBJ_TEXT , 0, 0, 0);
    ObjectCreate(cMainTrend, OBJ_TREND, 0, 0, 0);

    updateTypeProperty();

    updateDefaultProperty();

    // Value define update
    time1 = pCommonData.mMouseTime;
    price = pCommonData.mMousePrice;
    priceText = price;
}
void HTrend::updateDefaultProperty()
{
    ObjectSet(cMainTrend, OBJPROP_RAY, false);
    ObjectSetString(ChartID(), cMainTrend ,OBJPROP_TOOLTIP,"\n");
}
void HTrend::updateTypeProperty()
{
    ObjectSet(cMainTrend, OBJPROP_COLOR, mColorType[mIndexType]);
    ObjectSet(cMainTrend, OBJPROP_WIDTH, mWidthType[mIndexType]);
    ObjectSet(cMainTrend, OBJPROP_STYLE, mStyleType[mIndexType]);
    ObjectSet(cText,     OBJPROP_COLOR, mColorType[mIndexType]);
    ObjectSetText(cText, mText_Type[mIndexType]);
    ObjectSetInteger(ChartID(), cText, OBJPROP_ANCHOR, mAnchrType[mIndexType]);
}
void HTrend::activateItem(const string& itemId)
{
    cMainTrend = itemId + "_cMainTrend";
    cText     = itemId + "_cText";
}
void HTrend::updateItemAfterChangeType()
{
    if (mFirstPoint == true)
    {
        updateTypeProperty();
    }
}
void HTrend::refreshData()
{
    ObjectSet(cMainTrend, OBJPROP_TIME1,  time1);
    ObjectSet(cMainTrend, OBJPROP_TIME2,  time2);
    ObjectSet(cMainTrend, OBJPROP_PRICE1, price);
    ObjectSet(cMainTrend, OBJPROP_PRICE2, price);
    ObjectSet(cText    , OBJPROP_PRICE1, price);

    do
    {
        if (priceText == price)
        {
            ObjectSet(cText, OBJPROP_TIME1, getCenterTime(time1, time2));
            break;
        }

        if (priceText > price)
        {
            ObjectSetInteger(0, cText, OBJPROP_ANCHOR, ANCHOR_LOWER);
        }
        else
        {
            ObjectSetInteger(0, cText, OBJPROP_ANCHOR, ANCHOR_UPPER);
        }
        ObjectSet(cText, OBJPROP_TIME1, timeText);
    }
    while (false);
}

// Chart Event
void HTrend::onMouseMove()
{
    if (mFirstPoint == false)
    {
        return;
    }
    time2 = pCommonData.mMouseTime;
    refreshData();
}
void HTrend::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void HTrend::onItemDrag(const string &itemId, const string &objId)
{
    time1 = (datetime)ObjectGet(cMainTrend, OBJPROP_TIME1);
    time2 = (datetime)ObjectGet(cMainTrend, OBJPROP_TIME2);
    price = ObjectGet(cMainTrend, OBJPROP_PRICE1);
    priceText = price;

    if (objId == cText)
    {
        priceText = ObjectGet(cText, OBJPROP_PRICE1);
        timeText = (datetime)ObjectGet(cText, OBJPROP_TIME1);
    }

    refreshData();
}
void HTrend::onItemClick(const string &itemId, const string &objId){}
void HTrend::onItemChange(const string &itemId, const string &objId){}
void HTrend::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cMainTrend);
    ObjectDelete(cText    );
}