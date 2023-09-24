#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string  C_h_a_r_t_U_t_i_l___Cfg = SEPARATE_LINE;
input int     __U_Working_Start = 4;
input int     __U_Working_Finsh = 20;

enum ChartUtilType
{
    WORKING_AREA,
    CREATE_ALERT,
    CUTIL_NUM,
};

class ChartUtil : public BaseItem
{
// Internal Value
private:
string mAlertIndi;
string mAlertText;

// Component name
private:
    string cAlert;
// Value define for Item
private:

public:
    ChartUtil(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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

ChartUtil::ChartUtil(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [WORKING_AREA] = "Working Area";
    mNameType [CREATE_ALERT] = (AlertActive ? "Create Alert" : "Draft Alert");
    mTypeNum = CUTIL_NUM;
    mIndexType = 0;
}

// Internal Event
void ChartUtil::prepareActive(){}
void ChartUtil::createItem(){}
void ChartUtil::updateDefaultProperty(){}
void ChartUtil::updateTypeProperty(){}
void ChartUtil::activateItem(const string& itemId)
{
    cAlert = itemId + "_cAlert";
}
void ChartUtil::updateItemAfterChangeType(){}
void ChartUtil::refreshData(){}
void ChartUtil::finishedJobDone(){}

// Chart Event
void ChartUtil::onMouseMove()
{
}
void ChartUtil::onMouseClick()
{
    if (mIndexType == WORKING_AREA)
    {
        // TODO: indi này chỉ vẽ trong trong TF H4 đổ xuống thôi
        // S1: Detect datetime
        int YY=TimeYear( pCommonData.mMouseTime);
        int MN=TimeMonth(pCommonData.mMouseTime);
        int DD=TimeDay(  pCommonData.mMouseTime);
        string strBeginOfDay = IntegerToString(YY)+"."+IntegerToString(MN)+"."+IntegerToString(DD)+" 00:00";
        // S2: Detect working time
        string workingRect = IntegerToString(hashString(strBeginOfDay));
        datetime dtToday = StrToTime(strBeginOfDay);
        datetime openTime  = dtToday + 3600*__U_Working_Start;
        datetime closeTime = dtToday + 3600*__U_Working_Finsh;
        int beginBar = iBarShift(ChartSymbol(), ChartPeriod(), openTime );
        int endBar   = iBarShift(ChartSymbol(), ChartPeriod(), closeTime);

        // S3: Detect High Low
        double highest = High[beginBar];
        double lowest  = Low[beginBar];
        if (beginBar > 0)
        {
            for (int i = beginBar; i > endBar; i--){
                if (High[i] > highest) highest = High[i];
                if (Low[i] < lowest)   lowest  = Low[i];
            }
        }
        else
        {
            highest = iHigh(ChartSymbol(), PERIOD_D1, 1);
            lowest  = iLow(ChartSymbol(), PERIOD_D1, 1);
        }
        // S4: Create and set workingRect Position
        if (ObjectFind(workingRect) < 0)
        {
            ObjectCreate(workingRect, OBJ_RECTANGLE , 0, 0, 0);
            SetObjectStyle(workingRect, clrDarkSlateGray, 2, 0);
        }
        setItemPos(workingRect, openTime, closeTime, highest, lowest);
    }
    else if (mIndexType == CREATE_ALERT)
    {
        ObjectCreate(cAlert, OBJ_HLINE, 0, 0, pCommonData.mMousePrice);
        SetObjectStyle(cAlert, clrDarkSlateGray, STYLE_DASHDOT, 0);
        mAlertIndi = (ObjectGet(cAlert, OBJPROP_PRICE1) > Bid ? "[H]" : "[L]");
        ObjectSetText(cAlert, mAlertIndi + " Alert!");
        // Add Alert to gListAlert
        gListAlert += cAlert + ",";
    }
    mFinishedJobCb();
}
void ChartUtil::onItemDrag(const string &itemId, const string &objId)
{
    if (objId == cAlert)
    {
        mAlertText = ObjectGetString(ChartID(), cAlert, OBJPROP_TEXT);
        mAlertIndi = (ObjectGet(cAlert, OBJPROP_PRICE1) > Bid ? "[H]" : "[L]");

        if (StringFind(mAlertText, "[H]") == -1 && StringFind(mAlertText, "[L]") == -1 )
        {
            // Cannot found Indi => Add Indi
            mAlertText = mAlertIndi + " " + mAlertText;
            ObjectSetText(cAlert, mAlertText);
        }
        else if (StringFind(mAlertText, mAlertIndi) == -1)
        {
            // Indi not correct, remove old indi and replate new indi
            StringSetCharacter(mAlertText, 1, 'x');
            StringReplace(mAlertText, "[x]", mAlertIndi);
            ObjectSetText(cAlert, mAlertText);
        }

        if (StringFind(gListAlert, cAlert) == -1)
        {
            gListAlert += cAlert + ",";
        }
    }
}
void ChartUtil::onItemClick(const string &itemId, const string &objId){}
void ChartUtil::onItemChange(const string &itemId, const string &objId)
{
    if (objId == cAlert) onItemDrag(itemId, objId);
}
void ChartUtil::onItemDeleted(const string &itemId, const string &objId){}