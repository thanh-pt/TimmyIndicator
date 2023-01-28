#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string          Fibonacci_  = SEPARATE_LINE_BIG;
//--------------------------------------------
input color           FibBackColor  = clrGray;
input string          Fib_sp_trend  = SEPARATE_LINE;
//--------------------------------------------
input int             FibLevelWidth = 1;
input ENUM_LINE_STYLE FibLevelStyle = 0;
input string          Fib_sp_level  = SEPARATE_LINE;
//--------------------------------------------
input string          Fib_0_Name  = "0";
input bool            Fib_0_Show  = true;
input double          Fib_0_Ratio = 0;
input color           Fib_0_Color = clrGray;
input string          Fib_0_sp    = SEPARATE_LINE;
//--------------------------------------------
input string          Fib_1_Name  = "1";
input bool            Fib_1_Show  = true;
input double          Fib_1_Ratio = 1;
input color           Fib_1_Color = clrGray;
input string          Fib_1_sp    = SEPARATE_LINE;
//--------------------------------------------
input string          Fib_2_Name  = "0.5";
input bool            Fib_2_Show  = true;
input double          Fib_2_Ratio = 0.5;
input color           Fib_2_Color = clrYellow;
input string          Fib_2_sp    = SEPARATE_LINE;
//--------------------------------------------
input string          Fib_3_Name  = "0.618";
input bool            Fib_3_Show  = true;
input double          Fib_3_Ratio = 0.618;
input color           Fib_3_Color = clrYellow;
input string          Fib_3_sp    = SEPARATE_LINE;
//--------------------------------------------
input string          Fib_4_Name  = "-0.27";
input bool            Fib_4_Show  = true;
input double          Fib_4_Ratio = -0.27;
input color           Fib_4_Color = clrGold;
input string          Fib_4_sp    = SEPARATE_LINE;
//--------------------------------------------
input string          Fib_5_Name  = "-0.62";
input bool            Fib_5_Show  = true;
input double          Fib_5_Ratio = -0.62;
input color           Fib_5_Color = clrRed;

class Fibonacci : public BaseItem
{
// Internal Value
private:

// Component name
private:
    string cMLne;
    string iFib0;
    string iFib1;
    string iFib2;
    string iFib3;
    string iFib4;
    string iFib5;
    string iTxt0;
    string iTxt1;
    string iTxt2;
    string iTxt3;
    string iTxt4;
    string iTxt5;

// Value define for Item
private:
    datetime time0;
    datetime time1;
    double price0;
    double price1;

public:
    Fibonacci(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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

Fibonacci::Fibonacci(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [0] = "Fibonacci";
    mIndexType = 0;
    mTypeNum = 0;
}

// Internal Event
void Fibonacci::prepareActive(){}
void Fibonacci::createItem()
{
    if (Fib_0_Show) ObjectCreate(iFib0, OBJ_TREND, 0, 0, 0);
    if (Fib_1_Show) ObjectCreate(iFib1, OBJ_TREND, 0, 0, 0);
    if (Fib_2_Show) ObjectCreate(iFib2, OBJ_TREND, 0, 0, 0);
    if (Fib_3_Show) ObjectCreate(iFib3, OBJ_TREND, 0, 0, 0);
    if (Fib_4_Show) ObjectCreate(iFib4, OBJ_TREND, 0, 0, 0);
    if (Fib_5_Show) ObjectCreate(iFib5, OBJ_TREND, 0, 0, 0);
    //------------------------------------------
    if (Fib_0_Show) ObjectCreate(iTxt0, OBJ_TEXT, 0, 0, 0);
    if (Fib_1_Show) ObjectCreate(iTxt1, OBJ_TEXT, 0, 0, 0);
    if (Fib_2_Show) ObjectCreate(iTxt2, OBJ_TEXT, 0, 0, 0);
    if (Fib_3_Show) ObjectCreate(iTxt3, OBJ_TEXT, 0, 0, 0);
    if (Fib_4_Show) ObjectCreate(iTxt4, OBJ_TEXT, 0, 0, 0);
    if (Fib_5_Show) ObjectCreate(iTxt5, OBJ_TEXT, 0, 0, 0);
    ObjectCreate(cMLne, OBJ_RECTANGLE, 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();

    time0  = pCommonData.mMouseTime;
    price0 = pCommonData.mMousePrice;
}
void Fibonacci::updateDefaultProperty()
{
    multiSetProp(OBJPROP_RAY          , false         , iFib0+iFib1+iFib2+iFib3+iFib4+iFib5);
    multiSetProp(OBJPROP_WIDTH        , FibLevelWidth , iFib0+iFib1+iFib2+iFib3+iFib4+iFib5);
    multiSetProp(OBJPROP_STYLE        , FibLevelStyle , iFib0+iFib1+iFib2+iFib3+iFib4+iFib5);
    multiSetProp(OBJPROP_SELECTABLE   , false         , iFib0+iFib1+iFib2+iFib3+iFib4+iFib5
                                                         +iTxt0+iTxt1+iTxt2+iTxt3+iTxt4+iTxt5);
    multiSetInts(OBJPROP_ANCHOR, ANCHOR_RIGHT  , iTxt0+iTxt1+iTxt2+iTxt3+iTxt4+iTxt5);
    
    multiSetStrs(OBJPROP_TOOLTIP, "\n",
                            cMLne
                            +iFib0+iFib1+iFib2+iFib3+iFib4+iFib5
                            +iTxt0+iTxt1+iTxt2+iTxt3+iTxt4+iTxt5);
}
void Fibonacci::updateTypeProperty()
{
    ObjectSetText(iTxt0, Fib_0_Name + "  ", 7, NULL, Fib_0_Color);
    ObjectSetText(iTxt1, Fib_1_Name + "  ", 7, NULL, Fib_1_Color);
    ObjectSetText(iTxt2, Fib_2_Name + "  ", 7, NULL, Fib_2_Color);
    ObjectSetText(iTxt3, Fib_3_Name + "  ", 7, NULL, Fib_3_Color);
    ObjectSetText(iTxt4, Fib_4_Name + "  ", 7, NULL, Fib_4_Color);
    ObjectSetText(iTxt5, Fib_5_Name + "  ", 7, NULL, Fib_5_Color);
    //------------------------------------------
    SetRectangleBackground(cMLne, FibBackColor);
    //------------------------------------------
    ObjectSet(iFib0, OBJPROP_COLOR, Fib_0_Color);
    ObjectSet(iFib1, OBJPROP_COLOR, Fib_1_Color);
    ObjectSet(iFib2, OBJPROP_COLOR, Fib_2_Color);
    ObjectSet(iFib3, OBJPROP_COLOR, Fib_3_Color);
    ObjectSet(iFib4, OBJPROP_COLOR, Fib_4_Color);
    ObjectSet(iFib5, OBJPROP_COLOR, Fib_5_Color);
}
void Fibonacci::activateItem(const string& itemId)
{
    cMLne = itemId + "_cMLne";
    iFib0 = itemId + "_iFib0";
    iFib1 = itemId + "_iFib1";
    iFib2 = itemId + "_iFib2";
    iFib3 = itemId + "_iFib3";
    iFib4 = itemId + "_iFib4";
    iFib5 = itemId + "_iFib5";
    iTxt0 = itemId + "_iTxt0";
    iTxt1 = itemId + "_iTxt1";
    iTxt2 = itemId + "_iTxt2";
    iTxt3 = itemId + "_iTxt3";
    iTxt4 = itemId + "_iTxt4";
    iTxt5 = itemId + "_iTxt5";
}
void Fibonacci::updateItemAfterChangeType(){}
void Fibonacci::refreshData()
{
    double price2 = price1-Fib_2_Ratio*(price1-price0);
    double price3 = price1-Fib_3_Ratio*(price1-price0);
    double price4 = price1-Fib_4_Ratio*(price1-price0);
    double price5 = price1-Fib_5_Ratio*(price1-price0);
    //-------------------------------------------------
    setItemPos(cMLne, time0, time1, price0, price1);
    setItemPos(iFib0, time0, time1, price0, price0);
    setItemPos(iFib1, time0, time1, price1, price1);
    setItemPos(iFib2, time0, time1, price2, price2);
    setItemPos(iFib3, time0, time1, price3, price3);
    setItemPos(iFib4, time0, time1, price4, price4);
    setItemPos(iFib5, time0, time1, price5, price5);
    //-------------------------------------------------
    setItemPos(iTxt0, time0, price0);
    setItemPos(iTxt1, time0, price1);
    setItemPos(iTxt2, time0, price2);
    setItemPos(iTxt3, time0, price3);
    setItemPos(iTxt4, time0, price4);
    setItemPos(iTxt5, time0, price5);
}
void Fibonacci::finishedJobDone(){}

// Chart Event
void Fibonacci::onMouseMove()
{
    if (mFirstPoint == false)
    {
        return;
    }
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
    refreshData();
}
void Fibonacci::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void Fibonacci::onItemDrag(const string &itemId, const string &objId)
{
    time0   = (datetime)ObjectGet(cMLne, OBJPROP_TIME1);
    time1   = (datetime)ObjectGet(cMLne, OBJPROP_TIME2);
    price0  =           ObjectGet(cMLne, OBJPROP_PRICE1);
    price1  =           ObjectGet(cMLne, OBJPROP_PRICE2);

    if (pCommonData.mCtrlHold)
    {
        double oldPrice0 = ObjectGet(iTxt0, OBJPROP_PRICE1);
        double oldPrice1 = ObjectGet(iTxt1, OBJPROP_PRICE1);
        if (price0 == oldPrice0 && price1 != oldPrice1)
        {
            price1 = pCommonData.mMousePrice;
        }
        else if (price0 != oldPrice0 && price1 == oldPrice1)
        {
            price0 = pCommonData.mMousePrice;
        }
    }

    refreshData();
}
void Fibonacci::onItemClick(const string &itemId, const string &objId){}
void Fibonacci::onItemChange(const string &itemId, const string &objId){}
void Fibonacci::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cMLne);
    ObjectDelete(iFib0);
    ObjectDelete(iFib1);
    ObjectDelete(iFib2);
    ObjectDelete(iFib3);
    ObjectDelete(iFib4);
    ObjectDelete(iFib5);
    ObjectDelete(iTxt0);
    ObjectDelete(iTxt1);
    ObjectDelete(iTxt2);
    ObjectDelete(iTxt3);
    ObjectDelete(iTxt4);
    ObjectDelete(iTxt5);
}