#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string  ChartUtil_ = SEPARATE_LINE_BIG;
input int     ChartUtil_LONDON_BODER_StartSession = 10;
input int     ChartUtil_LONDON_BODER_EndOfSession = 19;

enum ChartUtilType
{
    HILO_VIEW,
    LONDON_BODER,
    CUTIL_NUM,
};

class ChartUtil : public BaseItem
{
// Internal Value
private:
    int mCandleIndex;
    string mCandleInfo;

// Component name
private:
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
    mNameType [HILO_VIEW   ] = "Hi/Lo View";
    mNameType [LONDON_BODER] = "London Boder";
    mTypeNum = CUTIL_NUM;
    mIndexType = 0;
}

// Internal Event
void ChartUtil::prepareActive(){}
void ChartUtil::createItem(){}
void ChartUtil::updateDefaultProperty(){}
void ChartUtil::updateTypeProperty(){}
void ChartUtil::activateItem(const string& itemId){}
void ChartUtil::updateItemAfterChangeType(){}
void ChartUtil::refreshData(){}
void ChartUtil::finishedJobDone(){}

// Chart Event
void ChartUtil::onMouseMove()
{
    if (mIndexType == HILO_VIEW)
    {
        mCandleInfo  = strDayOfWeek(pCommonData.mMouseTime);
        mCandleInfo += "_w" + IntegerToString(TimeDayOfYear(pCommonData.mMouseTime)/7+1);

        mCandleIndex = iBarShift(ChartSymbol(), ChartPeriod(), pCommonData.mMouseTime);
        if (pCommonData.mMousePrice > High[mCandleIndex])
        {
            mCandleInfo += "_Hi:" + DoubleToStr(High[mCandleIndex],5);
        }
        else
        {
            mCandleInfo += "_Lo:" + DoubleToStr(Low [mCandleIndex],5);
        }
        pMouseInfo.setText(mCandleInfo);
        return;
    }
}
void ChartUtil::onMouseClick()
{
    if (mIndexType == LONDON_BODER)
    {
        // S1: Detect datetime
        int YY=TimeYear( pCommonData.mMouseTime);
        int MN=TimeMonth(pCommonData.mMouseTime);
        int DD=TimeDay(  pCommonData.mMouseTime);
        string strBeginOfDay = IntegerToString(YY)+"."+IntegerToString(MN)+"."+IntegerToString(DD)+" 00:00";
        // S2: Create Rectangle and Adjust
        string rectLondon = IntegerToString(hashString(strBeginOfDay));
        if (ObjectFind(rectLondon) < 0)
        {
            datetime dtToday = StrToTime(strBeginOfDay);
            datetime openTime  = dtToday + 3600*ChartUtil_LONDON_BODER_StartSession;
            datetime closeTime = dtToday + 3600*ChartUtil_LONDON_BODER_EndOfSession;
            int beginBar = iBarShift(ChartSymbol(), ChartPeriod(), openTime );
            int endBar   = iBarShift(ChartSymbol(), ChartPeriod(), closeTime);
            if (endBar > 0)
            {
                double highest = -1;
                double lowest  = 10;
                for (int i = beginBar; i > endBar && i >= 0; i--){
                    if (High[i] > highest) highest = High[i];
                    if (Low[i] < lowest)   lowest  = Low[i];
                }
                ObjectCreate(rectLondon, OBJ_RECTANGLE , 0, 0, 0);
                SetObjectStyle(rectLondon, clrDarkSlateGray, 2, 0);
                setItemPos(rectLondon, openTime, closeTime, highest, lowest);
            }
            else
            {
                // Don't draw boder when session have not finished
            }
        }
    }
    mFinishedJobCb();
}
void ChartUtil::onItemDrag(const string &itemId, const string &objId){}
void ChartUtil::onItemClick(const string &itemId, const string &objId){}
void ChartUtil::onItemChange(const string &itemId, const string &objId){}
void ChartUtil::onItemDeleted(const string &itemId, const string &objId){}