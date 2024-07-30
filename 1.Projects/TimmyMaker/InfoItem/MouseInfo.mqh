#ifndef MouseInfo_mqh
#define MouseInfo_mqh

#include "../Home/CommonData.mqh"

class MouseInfo
{
private:
    CommonData* pCommonData;
    string mObjMouseInfo;
    string mObjMouseBgnd;
public:
    MouseInfo(CommonData* commonData)
    {
        pCommonData = commonData;
        mObjMouseInfo = TAG_STATIC+"zMouseInfo";
        mObjMouseBgnd = TAG_STATIC+"iMouseBgnd";
        initDrawing();
    }
    void initDrawing()
    {
        // Background
        ObjectCreate(mObjMouseBgnd, OBJ_LABEL, 0, 0, 0);
        ObjectSet(mObjMouseBgnd, OBJPROP_SELECTABLE, false);
        ObjectSet(mObjMouseBgnd, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        setTextContent(mObjMouseBgnd, "", 20, FONT_TEXT, gClrTextBgnd);
        ObjectSetString(0, mObjMouseBgnd, OBJPROP_TOOLTIP,"\n");
        // Content
        ObjectCreate(mObjMouseInfo, OBJ_LABEL, 0, 0, 0);
        ObjectSet(mObjMouseInfo, OBJPROP_SELECTABLE, false);
        ObjectSet(mObjMouseInfo, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        setTextContent(mObjMouseInfo, "", 10, FONT_TEXT, gClrForegrnd);
        ObjectSetString(0, mObjMouseInfo, OBJPROP_TOOLTIP,"\n");
    }
    void onMouseMove()
    {
        ObjectSet(mObjMouseInfo, OBJPROP_XDISTANCE, pCommonData.mMouseX+20);
        ObjectSet(mObjMouseInfo, OBJPROP_YDISTANCE, pCommonData.mMouseY);
        ObjectSet(mObjMouseBgnd, OBJPROP_XDISTANCE, pCommonData.mMouseX+20);
        ObjectSet(mObjMouseBgnd, OBJPROP_YDISTANCE, pCommonData.mMouseY);
    }
    void onObjectDeleted(const string& objectName)
    {
        if (objectName == mObjMouseInfo) {
            initDrawing();
        }
    }
public:
    void setText(const string tIcon)
    {
        setTextContent(mObjMouseInfo, tIcon);
        if (tIcon != "") setTextContent(mObjMouseBgnd, getHalfDwBL(StringLen(tIcon)));
        else setTextContent(mObjMouseBgnd, "");
    }
};

#endif