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
    string cMainLine;
    string cFib0    ;
    string cFib1    ;
    string cFib2    ;
    string cFib3    ;
    string cFib4    ;
    string cFib5    ;
    string cText0   ;
    string cText1   ;
    string cText2   ;
    string cText3   ;
    string cText4   ;
    string cText5   ;

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
    if (Fib_0_Show) ObjectCreate(cFib0, OBJ_TREND, 0, 0, 0);
    if (Fib_1_Show) ObjectCreate(cFib1, OBJ_TREND, 0, 0, 0);
    if (Fib_2_Show) ObjectCreate(cFib2, OBJ_TREND, 0, 0, 0);
    if (Fib_3_Show) ObjectCreate(cFib3, OBJ_TREND, 0, 0, 0);
    if (Fib_4_Show) ObjectCreate(cFib4, OBJ_TREND, 0, 0, 0);
    if (Fib_5_Show) ObjectCreate(cFib5, OBJ_TREND, 0, 0, 0);
    //------------------------------------------
    if (Fib_0_Show) ObjectCreate(cText0, OBJ_TEXT, 0, 0, 0);
    if (Fib_1_Show) ObjectCreate(cText1, OBJ_TEXT, 0, 0, 0);
    if (Fib_2_Show) ObjectCreate(cText2, OBJ_TEXT, 0, 0, 0);
    if (Fib_3_Show) ObjectCreate(cText3, OBJ_TEXT, 0, 0, 0);
    if (Fib_4_Show) ObjectCreate(cText4, OBJ_TEXT, 0, 0, 0);
    if (Fib_5_Show) ObjectCreate(cText5, OBJ_TEXT, 0, 0, 0);
    ObjectCreate(cMainLine, OBJ_RECTANGLE, 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();

    time0  = pCommonData.mMouseTime;
    price0 = pCommonData.mMousePrice;
}
void Fibonacci::updateDefaultProperty()
{
    multiObjectSet(OBJPROP_RAY          , false         , cFib0+cFib1+cFib2+cFib3+cFib4+cFib5);
    multiObjectSet(OBJPROP_WIDTH        , FibLevelWidth , cFib0+cFib1+cFib2+cFib3+cFib4+cFib5);
    multiObjectSet(OBJPROP_STYLE        , FibLevelStyle , cFib0+cFib1+cFib2+cFib3+cFib4+cFib5);
    multiObjectSet(OBJPROP_SELECTABLE   , false         , cFib0+cFib1+cFib2+cFib3+cFib4+cFib5
                                                         +cText0+cText1+cText2+cText3+cText4+cText5);
    multiObjectSetInteger(OBJPROP_ANCHOR, ANCHOR_RIGHT  , cText0+cText1+cText2+cText3+cText4+cText5);
    
    multiObjectSetString(OBJPROP_TOOLTIP, "\n",
                            cMainLine
                            +cFib0+cFib1+cFib2+cFib3+cFib4+cFib5
                            +cText0+cText1+cText2+cText3+cText4+cText5);
}
void Fibonacci::updateTypeProperty()
{
    ObjectSetText(cText0, Fib_0_Name + "  ", 7, NULL, Fib_0_Color);
    ObjectSetText(cText1, Fib_1_Name + "  ", 7, NULL, Fib_1_Color);
    ObjectSetText(cText2, Fib_2_Name + "  ", 7, NULL, Fib_2_Color);
    ObjectSetText(cText3, Fib_3_Name + "  ", 7, NULL, Fib_3_Color);
    ObjectSetText(cText4, Fib_4_Name + "  ", 7, NULL, Fib_4_Color);
    ObjectSetText(cText5, Fib_5_Name + "  ", 7, NULL, Fib_5_Color);
    //------------------------------------------
    SetRectangleBackground(cMainLine, FibBackColor);
    //------------------------------------------
    ObjectSet(cFib0, OBJPROP_COLOR, Fib_0_Color);
    ObjectSet(cFib1, OBJPROP_COLOR, Fib_1_Color);
    ObjectSet(cFib2, OBJPROP_COLOR, Fib_2_Color);
    ObjectSet(cFib3, OBJPROP_COLOR, Fib_3_Color);
    ObjectSet(cFib4, OBJPROP_COLOR, Fib_4_Color);
    ObjectSet(cFib5, OBJPROP_COLOR, Fib_5_Color);
}
void Fibonacci::activateItem(const string& itemId)
{
    cMainLine = itemId + "_" + "cMainLine";
    cFib0     = itemId + "_" + "cFib0";
    cFib1     = itemId + "_" + "cFib1";
    cFib2     = itemId + "_" + "cFib2";
    cFib3     = itemId + "_" + "cFib3";
    cFib4     = itemId + "_" + "cFib4";
    cFib5     = itemId + "_" + "cFib5";
    cText0    = itemId + "_" + "cText0";
    cText1    = itemId + "_" + "cText1";
    cText2    = itemId + "_" + "cText2";
    cText3    = itemId + "_" + "cText3";
    cText4    = itemId + "_" + "cText4";
    cText5    = itemId + "_" + "cText5";
}
void Fibonacci::updateItemAfterChangeType(){}
void Fibonacci::refreshData()
{
    double price2 = price1-Fib_2_Ratio*(price1-price0);
    double price3 = price1-Fib_3_Ratio*(price1-price0);
    double price4 = price1-Fib_4_Ratio*(price1-price0);
    double price5 = price1-Fib_5_Ratio*(price1-price0);
    //-------------------------------------------------
    
    setItemPos(cMainLine, time0, time1, price0, price1);
    setItemPos(cFib0    , time0, time1, price0, price0);
    setItemPos(cFib1    , time0, time1, price1, price1);
    setItemPos(cFib2    , time0, time1, price2, price2);
    setItemPos(cFib3    , time0, time1, price3, price3);
    setItemPos(cFib4    , time0, time1, price4, price4);
    setItemPos(cFib5    , time0, time1, price5, price5);
    //-------------------------------------------------
    setItemPos(cText0   , time0, price0);
    setItemPos(cText1   , time0, price1);
    setItemPos(cText2   , time0, price2);
    setItemPos(cText3   , time0, price3);
    setItemPos(cText4   , time0, price4);
    setItemPos(cText5   , time0, price5);
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
    time0   = (datetime)ObjectGet(cMainLine, OBJPROP_TIME1);
    time1   = (datetime)ObjectGet(cMainLine, OBJPROP_TIME2);
    price0  =           ObjectGet(cMainLine, OBJPROP_PRICE1);
    price1  =           ObjectGet(cMainLine, OBJPROP_PRICE2);

    if (pCommonData.mCtrlHold)
    {
        double oldPrice0 = ObjectGet(cText0, OBJPROP_PRICE1);
        double oldPrice1 = ObjectGet(cText1, OBJPROP_PRICE1);
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
    ObjectDelete(cMainLine);
    ObjectDelete(cFib0    );
    ObjectDelete(cFib1    );
    ObjectDelete(cFib2    );
    ObjectDelete(cFib3    );
    ObjectDelete(cFib4    );
    ObjectDelete(cFib5    );
    ObjectDelete(cText0   );
    ObjectDelete(cText1   );
    ObjectDelete(cText2   );
    ObjectDelete(cText3   );
    ObjectDelete(cText4   );
    ObjectDelete(cText5   );
}