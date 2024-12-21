#include "../Home/UtilityHeader.mqh"

// input string ContexMenu_; // ●  C O N T E X T   M E N U  ●

#define MAX_ROW 4

class ContextMenu
{
private:
    string NameTag;
    string BgndTag;
private:
    string mContextMenu[];
    int    mSize;
    int    mMaxLength;
public:
    string mActiveObjectId;
    int    mActivePos;
    string mActiveItemStr;
    bool   mStaticCtxOn;

public:
    ContextMenu() {
        NameTag = ".StaticCtxMenuName_";
        BgndTag = ".StaticCtxMenuBgnd_";
    }
    virtual void onItemClick(const string &objId) {
        if (StringFind(objId, "StaticCtxMenu") < 0) return;
        string sparamItems[];
        int k=StringSplit(objId,'_',sparamItems);
        if (k != 2) return;
        onNumKeyPress(StrToInteger(sparamItems[1]));
    }
    void onNumKeyPress(int index) {
        string itemName = NameTag+IntegerToString(index);
        mActivePos = index;
        mActiveItemStr = StringTrimRight(StringTrimLeft(ObjectDescription(itemName)));
        gController.handleEvent(CHARTEVENT_SELECT_CONTEXTMENU, mActiveObjectId);
    }
    void openStaticCtxMenu(const string objId, const string data) {
        mActiveObjectId = objId;
        mSize = StringSplit(data,',',mContextMenu);
        mMaxLength = 0;
        int tempLength;
        for (int i = 0; i < mSize; i++) {
            tempLength = StringLen(mContextMenu[i]);
            if (tempLength > mMaxLength) mMaxLength = tempLength;
        }
        mMaxLength += 2;

        string itemName;
        string itemBgnd;
        string allItem;
        int bottomOffset = mSize*16;
        int i = 0;
        for (; i < mSize; i++) {
            itemName = NameTag+IntegerToString(i);
            itemBgnd = BgndTag+IntegerToString(i);
            allItem = itemBgnd+itemName;
            ObjectCreate(itemBgnd, OBJ_LABEL, 0, 0, 0);
            ObjectCreate(itemName, OBJ_LABEL, 0, 0, 0);
            setTextContent(itemBgnd, IntegerToString(i+1) + getFullBL(mMaxLength)                           , 10, FONT_BLOCK, gClrTextBgnd);
            setTextContent(itemName, mContextMenu[i]+getSpaceBL((mMaxLength-StringLen(mContextMenu[i]))/2)  , 10, FONT_BLOCK, gClrForegrnd);

            bottomOffset -= 16;
            setMultiProp(OBJPROP_BACK       , false             , allItem);
            setMultiProp(OBJPROP_SELECTABLE , false             , allItem);
            setMultiProp(OBJPROP_ANCHOR     , ANCHOR_RIGHT_LOWER, allItem);
            setMultiProp(OBJPROP_CORNER     , CORNER_RIGHT_LOWER, allItem);
            setMultiProp(OBJPROP_XDISTANCE  , 0                 , allItem);
            setMultiProp(OBJPROP_YDISTANCE  , bottomOffset      , allItem);
            setMultiStrs(OBJPROP_TOOLTIP    , "\n"              , allItem);
        }
        do {
            itemName = NameTag+IntegerToString(i);
            itemBgnd = BgndTag+IntegerToString(i);
            setMultiProp(OBJPROP_COLOR, clrNONE, itemBgnd+itemName);
            i++;
        } while (ObjectFind(itemName) >= 0);
        
        mStaticCtxOn = true;
    }
    void clearStaticCtxMenu() {
        clearStaticCtxMenu(mActiveObjectId);
    }
    void clearStaticCtxMenu(string who)
    {
        if (who != mActiveObjectId) return;
        string itemName;
        string itemBgnd;
        int i = 0;
        do {
            itemName = NameTag+IntegerToString(i);
            itemBgnd = BgndTag+IntegerToString(i);
            ObjectSet(itemName, OBJPROP_YDISTANCE, -50);
            ObjectSet(itemBgnd, OBJPROP_YDISTANCE, -50);
            i++;
        } while (ObjectFind(itemName) >= 0);
        mStaticCtxOn = false;
    }
};