#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

// input string          CandleXray_ = "CandleXray Config";

class CandleXray : public BaseItem
{
// Internal Value
private:
    int mCandleIndex;
    double mBodyPercentage;

// Component name
private:
// Value define for Item
private:

public:
    CandleXray(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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

CandleXray::CandleXray(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [0] = "H/L View";
    mNameType [1] = "DateInfo";
    mNameType [2] = "BodyScan";
    mTypeNum = 3;
    mIndexType = 0;
}

// Internal Event
void CandleXray::prepareActive(){}
void CandleXray::createItem(){}
void CandleXray::updateDefaultProperty(){}
void CandleXray::updateTypeProperty(){}
void CandleXray::activateItem(const string& itemId){}
void CandleXray::updateItemAfterChangeType(){}
void CandleXray::refreshData(){}
void CandleXray::finishedJobDone(){}

// Chart Event
void CandleXray::onMouseMove()
{
    // Does not need candle info
    if (mIndexType == 1)
    {
        pMouseInfo.setText( strDayOfWeek(pCommonData.mMouseTime) + " - CW:" + IntegerToString(TimeDayOfYear(pCommonData.mMouseTime)/7+1));
        return;
    }

    // Need candle info
    mCandleIndex = iBarShift(ChartSymbol(), ChartPeriod(), pCommonData.mMouseTime);
    if (mCandleIndex <= 0 && mIndexType != 2)
    {
        pMouseInfo.setText(createMouseInfo());
        return;
    }

    if (mIndexType == 0)
    {
        if (pCommonData.mMousePrice > High[mCandleIndex])
        {
            pMouseInfo.setText("High: " + DoubleToStr(High[mCandleIndex],5));
        }
        else
        {
            pMouseInfo.setText("Low: " + DoubleToStr(Low[mCandleIndex],5));
        }
        return;
    }

    if (mIndexType == 2)
    {
        mBodyPercentage = MathAbs(Close[mCandleIndex]-Open[mCandleIndex])/(High[mCandleIndex] - Low[mCandleIndex])*100;
        pMouseInfo.setText("Body(%): " + DoubleToStr(mBodyPercentage,1));
        return;
    }
}
void CandleXray::onMouseClick()
{
    mFinishedJobCb();
}
void CandleXray::onItemDrag(const string &itemId, const string &objId){}
void CandleXray::onItemClick(const string &itemId, const string &objId){}
void CandleXray::onItemChange(const string &itemId, const string &objId){}
void CandleXray::onItemDeleted(const string &itemId, const string &objId){}