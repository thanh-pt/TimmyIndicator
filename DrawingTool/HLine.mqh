#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string            HLine_ = "HLine Config";
//-----------------------------------------------------------
input string            HLine_1_NAME   = "Break up";
input color             HLine_1_Color  = clrYellowGreen;
input int               HLine_1_Width  = 0;
input ENUM_LINE_STYLE   HLine_1_Style  = 2;
input string            HLine_1_Text   = "bos";
input ENUM_ANCHOR_POINT HLine_1_Anchor = ANCHOR_LOWER;
//-----------------------------------------------------------
input string            HLine_2_NAME   = "Break donw";
input color             HLine_2_Color  = clrOrangeRed;
input int               HLine_2_Width  = 0;
input ENUM_LINE_STYLE   HLine_2_Style  = 2;
input string            HLine_2_Text   = "bos";
input ENUM_ANCHOR_POINT HLine_2_Anchor = ANCHOR_UPPER;

class HLine : public BaseItem
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
    string cMainLine;
    string cText    ;

// Value define for Item
private:
    double price;
    double priceText;
    datetime time1;
    datetime time2;
    datetime timeText;

public:
    HLine(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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

HLine::HLine(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [0] = HLine_1_NAME  ;
    mColorType[0] = HLine_1_Color ;
    mWidthType[0] = HLine_1_Width ;
    mStyleType[0] = HLine_1_Style ;
    mText_Type[0] = HLine_1_Text  ;
    mAnchrType[0] = HLine_1_Anchor;
    //-----------------------------
    mNameType [1] = HLine_2_NAME  ;
    mColorType[1] = HLine_2_Color ;
    mWidthType[1] = HLine_2_Width ;
    mStyleType[1] = HLine_2_Style ;
    mText_Type[1] = HLine_2_Text  ;
    mAnchrType[1] = HLine_2_Anchor;
    mIndexType = 0;
    mTypeNum = 2;
}

// Internal Event
void HLine::prepareActive()
{
    mFirstPoint = false;
    pMouseInfo.setText(mNameType[mIndexType]);
}

void HLine::createItem()
{
    ObjectCreate(cText    , OBJ_TEXT , 0, 0, 0);
    ObjectCreate(cMainLine, OBJ_TREND, 0, 0, 0);

    updateTypeProperty();

    updateDefaultProperty();

    // Value define update
    time1 = pCommonData.mMouseTime;
    price = pCommonData.mMousePrice;
    priceText = price;
}
void HLine::updateDefaultProperty()
{
    ObjectSet(cMainLine, OBJPROP_RAY, false);
    ObjectSetString(ChartID(), cMainLine ,OBJPROP_TOOLTIP,"\n");
}
void HLine::updateTypeProperty()
{
    ObjectSet(cMainLine, OBJPROP_COLOR, mColorType[mIndexType]);
    ObjectSet(cMainLine, OBJPROP_WIDTH, mWidthType[mIndexType]);
    ObjectSet(cMainLine, OBJPROP_STYLE, mStyleType[mIndexType]);
    ObjectSet(cText,     OBJPROP_COLOR, mColorType[mIndexType]);
    ObjectSetText(cText, mText_Type[mIndexType]);
    ObjectSetInteger(ChartID(), cText, OBJPROP_ANCHOR, mAnchrType[mIndexType]);
}
void HLine::activateItem(const string& itemId)
{
    cMainLine = itemId + "_cMainLine";
    cText     = itemId + "_cText";
}
void HLine::updateItemAfterChangeType()
{
    if (mFirstPoint == true)
    {
        updateTypeProperty();
    }
}
void HLine::refreshData()
{
    ObjectSet(cMainLine, OBJPROP_TIME1,  time1);
    ObjectSet(cMainLine, OBJPROP_TIME2,  time2);
    ObjectSet(cMainLine, OBJPROP_PRICE1, price);
    ObjectSet(cMainLine, OBJPROP_PRICE2, price);
    ObjectSet(cText    , OBJPROP_PRICE1, price);

    do
    {
        if (priceText == price)
        {
            if (DEBUG) PrintFormat("HLine::refreshData() priceText == price");
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
void HLine::onMouseMove()
{
    if (mFirstPoint == false)
    {
        return;
    }
    time2 = pCommonData.mMouseTime;
    refreshData();
}
void HLine::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void HLine::onItemDrag(const string &itemId, const string &objId)
{
    time1 = (datetime)ObjectGet(cMainLine, OBJPROP_TIME1);
    time2 = (datetime)ObjectGet(cMainLine, OBJPROP_TIME2);
    price = ObjectGet(cMainLine, OBJPROP_PRICE1);
    priceText = price;

    if (objId == cText)
    {
        priceText = ObjectGet(cText, OBJPROP_PRICE1);
        timeText = (datetime)ObjectGet(cText, OBJPROP_TIME1);
    }

    refreshData();
}
void HLine::onItemClick(const string &itemId, const string &objId){}
void HLine::onItemChange(const string &itemId, const string &objId){}
void HLine::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cMainLine);
    ObjectDelete(cText    );
}