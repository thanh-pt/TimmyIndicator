#include "../CommonData.mqh"
#include "../Utility.mqh"

input color CrossHair_Color = clrDarkSlateGray;

class CrossHair
{
private:
    CommonData* pCommonData;
    string mVCrossHair;
    string mHCrossHair;
    uint mTimeOffset;
public:
    CrossHair(CommonData* commonData)
    {
        mVCrossHair = STATIC_TAG + "VCrossHair";
        mHCrossHair = STATIC_TAG + "HCrossHair";
        pCommonData = commonData;

        if (ChartPeriod() == PERIOD_MN1) mTimeOffset = ChartPeriod()*60*100;
        else mTimeOffset = 120000*ChartPeriod();

        initDrawing();
    }
    void initDrawing()
    {
        ObjectCreate(mVCrossHair, OBJ_RECTANGLE, 0, 0, 0);
        ObjectCreate(mHCrossHair, OBJ_RECTANGLE, 0, 0, 0);
        SetObjectStyle(mVCrossHair, CrossHair_Color, STYLE_DOT, 0);
        SetObjectStyle(mHCrossHair, CrossHair_Color, STYLE_DOT, 0);
        ObjectSet(mVCrossHair, OBJPROP_SELECTABLE, false);
        ObjectSet(mHCrossHair, OBJPROP_SELECTABLE, false);

        ObjectSet(mVCrossHair, OBJPROP_TIME2, 0);
        
        ObjectSet(mHCrossHair, OBJPROP_TIME2, 0);
        ObjectSet(mHCrossHair, OBJPROP_PRICE2, 0);
    }
    void onMouseMove()
    {
        ObjectSet(mHCrossHair, OBJPROP_TIME1, pCommonData.mMouseTime + mTimeOffset);
        ObjectSet(mHCrossHair, OBJPROP_TIME2, pCommonData.mMouseTime - mTimeOffset);

        ObjectSet(mVCrossHair, OBJPROP_PRICE1, ChartGetDouble(ChartID(),CHART_FIXED_MIN)-10);
        ObjectSet(mVCrossHair, OBJPROP_PRICE2, ChartGetDouble(ChartID(),CHART_FIXED_MAX)+10);

        ObjectSet(mHCrossHair, OBJPROP_PRICE1, pCommonData.mMousePrice);
        ObjectSet(mVCrossHair, OBJPROP_TIME1, pCommonData.mMouseTime);
    }
    void onObjectDeleted(const string& objectName)
    {
        if (objectName == mVCrossHair || objectName == mHCrossHair)
        {
            initDrawing();
        }
    }
};