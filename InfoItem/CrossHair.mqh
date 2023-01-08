#include "../CommonData.mqh"
#include "../Utility.mqh"

input color CrossHairColor = clrLightGray;

class CrossHair
{
private:
    CommonData* pCommonData;
    string mVCrossHair;
    string mHCrossHair;
public:
    CrossHair(CommonData* commonData)
    {
        mVCrossHair = STATIC_TAG + "VCrossHair";
        mHCrossHair = STATIC_TAG + "HCrossHair";
        pCommonData = commonData;
        initDrawing();
    }
    void initDrawing()
    {
        ObjectCreate(mVCrossHair, OBJ_RECTANGLE, 0, 0, 0);
        ObjectCreate(mHCrossHair, OBJ_RECTANGLE, 0, 0, 0);
        ObjectSet(mVCrossHair, OBJPROP_COLOR, CrossHairColor);
        ObjectSet(mHCrossHair, OBJPROP_COLOR, CrossHairColor);
        ObjectSet(mVCrossHair, OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(mHCrossHair, OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(mVCrossHair, OBJPROP_SELECTABLE, false);
        ObjectSet(mHCrossHair, OBJPROP_SELECTABLE, false);
        ObjectSet(mVCrossHair, OBJPROP_BACK, false);
        ObjectSet(mHCrossHair, OBJPROP_BACK, false);

        ObjectSet(mVCrossHair, OBJPROP_PRICE1, 10);
        ObjectSet(mVCrossHair, OBJPROP_PRICE2, 0);
        ObjectSet(mVCrossHair, OBJPROP_TIME2, 0);
        
        ObjectSet(mHCrossHair, OBJPROP_PRICE2, 0);
    }
    void onMouseMove()
    {
        ObjectSet(mHCrossHair, OBJPROP_TIME1, pCommonData.mMouseTime + 120000*ChartPeriod());
        ObjectSet(mHCrossHair, OBJPROP_TIME2, pCommonData.mMouseTime - 120000*ChartPeriod());
        ObjectSet(mVCrossHair, OBJPROP_TIME1, pCommonData.mMouseTime);
        ObjectSet(mHCrossHair, OBJPROP_PRICE1, pCommonData.mMousePrice);
    }
    void onObjectDeleted(const string& objectName)
    {
        if (objectName == mVCrossHair || objectName == mHCrossHair)
        {
            initDrawing();
        }
    }
};