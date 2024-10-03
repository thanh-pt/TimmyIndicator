#include "../Base/BaseItem.mqh"

// input string Label_; // ●  L A B E L  ●

enum LabelTextType
{
    TYPE_NUM,
};

class LabelText : public BaseItem
{
// Internal Value
private:
    int itemDragIdx;
    int posX;
    int posY;
    int spaceSize;
// Component name
private:
    string cTxtM;
    string cTxtX;
    string iTxBg;
    string iTBgX;

// Value define for Item
private:

public:
    LabelText(CommonData* commonData, MouseInfo* mouseInfo);

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
    virtual void onUserRequest(const string &itemId, const string &objId);

public:
    static string getAllItem(string itemId);
    static string Tag;
};

static string LabelText::Tag = ".TMLabel";

LabelText::LabelText(CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = LabelText::Tag;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [0] = "LabelText";
    mTypeNum = TYPE_NUM;
    mIndexType = 0;
    
    /* Size | Space
        10  | 15
        12  | 19
    */
    spaceSize = 19;
    mContextType = "Add";
}

// Internal Event
void LabelText::prepareActive(){}
void LabelText::createItem()
{
    ObjectCreate(iTxBg, OBJ_LABEL, 0, 0, 0);
    ObjectCreate(cTxtM, OBJ_LABEL, 0, 0, 0);
    updateDefaultProperty();
    updateTypeProperty();
    posX = pCommonData.mMouseX;
    posY = pCommonData.mMouseY;
    refreshData();
}
void LabelText::updateDefaultProperty()
{
    ObjectSet(iTxBg, OBJPROP_SELECTABLE, false);
    setTextContent(cTxtM, getRandStr(), 10, FONT_BLOCK, gClrForegrnd);
    setTextContent(iTxBg,           "", 20, FONT_BLOCK, gClrTextBgnd);
    setMultiStrs(OBJPROP_TOOLTIP, "\n", cTxtM+iTxBg);
}
void LabelText::updateTypeProperty(){}
void LabelText::activateItem(const string& itemId)
{
    cTxtM = itemId + TAG_CTRM + "cTxtM";
    cTxtX = itemId + TAG_CTRL + "cTxtX";
    iTxBg = itemId + TAG_INFO + "iTxBg";
    iTBgX = itemId + TAG_INFO + "iTBgX";
}
string LabelText::getAllItem(string itemId)
{
    string allItem = itemId + "_mTData";
    allItem += itemId + TAG_INFO + "iTxBg";
    allItem += itemId + TAG_CTRM + "cTxtM";

    string tBgX   = itemId + TAG_INFO + "iTBgX";
    string txtX   = itemId + TAG_CTRL + "cTxtX";
    int i = 1;
    string objiTBgX = tBgX + "#" + IntegerToString(i);
    string objCTxtX = txtX + "#" + IntegerToString(i++);
    while (ObjectFind(objCTxtX) >= 0){
        allItem += objiTBgX;
        allItem += objCTxtX;
        objiTBgX = tBgX + "#" + IntegerToString(i);
        objCTxtX = txtX + "#" + IntegerToString(i++);
    }

    return allItem;
}
void LabelText::updateItemAfterChangeType(){}
void LabelText::refreshData()
{
    ObjectSet(cTxtM, OBJPROP_XDISTANCE, posX);
    ObjectSet(cTxtM, OBJPROP_YDISTANCE, posY);
    ObjectSet(iTxBg, OBJPROP_XDISTANCE, posX);
    ObjectSet(iTxBg, OBJPROP_YDISTANCE, posY);
    int maxLen = StringLen(ObjectDescription(cTxtM));
    int strLen = 0;

    int idx = 1;
    string objCTxtX = cTxtX +"#"+ IntegerToString(idx);
    string objiTBgX = iTBgX +"#"+ IntegerToString(idx);
    while (ObjectFind(objCTxtX) >= 0)
    {
        ObjectSet(objCTxtX, OBJPROP_XDISTANCE, posX);
        ObjectSet(objCTxtX, OBJPROP_YDISTANCE, posY+(idx)*spaceSize);
        ObjectSet(objiTBgX, OBJPROP_XDISTANCE, posX);
        ObjectSet(objiTBgX, OBJPROP_YDISTANCE, posY+(idx)*spaceSize);
        strLen = StringLen(ObjectDescription(objCTxtX));
        if (strLen > maxLen) maxLen = strLen;
        idx++;
        objCTxtX = cTxtX +"#"+ IntegerToString(idx);
        objiTBgX = iTBgX +"#"+ IntegerToString(idx);
    }
    idx--;
    string bgBlock = getHalfUpBL(maxLen);
    while (idx >= 1){
        objiTBgX = iTBgX +"#"+ IntegerToString(idx--);
        setTextContent(objiTBgX, bgBlock);
    }
    setTextContent(iTxBg, bgBlock);

    if (ObjectGet(cTxtM, OBJPROP_SELECTED) == 1) gContextMenu.openStaticCtxMenu(cTxtM, mContextType);
    else gContextMenu.clearStaticCtxMenu(cTxtM);
}
void LabelText::finishedJobDone(){}

// Chart Event
void LabelText::onMouseMove()
{
    MOUSE_MOVE_RETURN_CHECK
}
void LabelText::onMouseClick()
{
    createItem();
    mFinishedJobCb();
}
void LabelText::onItemDrag(const string &itemId, const string &objId)
{
    int size = (int)ObjectGet(objId, OBJPROP_FONTSIZE);
    if     (size == 10) spaceSize = 15;
    else if(size == 12) spaceSize = 19;

    itemDragIdx = 0;
    if (objId == cTxtM)
    {
        posX = (int)ObjectGet(objId, OBJPROP_XDISTANCE);
        posY = (int)ObjectGet(objId, OBJPROP_YDISTANCE);
    }
    else
    {
        string sparamItems[];
        int k=StringSplit(objId,'#',sparamItems);
        if (k != 3) return;
        itemDragIdx = StrToInteger(sparamItems[2]);
        posX = (int)ObjectGet(objId, OBJPROP_XDISTANCE);
        posY = (int)ObjectGet(objId, OBJPROP_YDISTANCE)-itemDragIdx*spaceSize;
    }
    refreshData();
}
void LabelText::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, TAG_CTRL) < 0) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);

    string lastItem = cTxtM;
    ObjectSet(cTxtM, OBJPROP_SELECTED, selected);

    int idx = 1;
    string objCTxtX = cTxtX +"#"+ IntegerToString(idx);
    while (ObjectFind(objCTxtX) >= 0)
    {
        ObjectSet(objCTxtX, OBJPROP_SELECTED, selected);
        lastItem = objCTxtX;
        idx++;
        objCTxtX = cTxtX +"#"+ IntegerToString(idx);
    }
    if (selected == true && objId == lastItem && pCommonData.mShiftHold) gContextMenu.openContextMenu(cTxtM, mContextType);

    if (selected) gContextMenu.openStaticCtxMenu(cTxtM, mContextType);
    else gContextMenu.clearStaticCtxMenu(cTxtM);
}
void LabelText::onItemChange(const string &itemId, const string &objId)
{
    // font color size
    string font = ObjectGetString(0, objId, OBJPROP_FONT);
    color c     = (color)ObjectGet(objId, OBJPROP_COLOR);
    int size    = (int)  ObjectGet(objId, OBJPROP_FONTSIZE);
    int anchor  = (int)  ObjectGet(cTxtM, OBJPROP_ANCHOR);
    int corner  = (int)  ObjectGet(cTxtM, OBJPROP_CORNER);
    
    ObjectSet(cTxtM, OBJPROP_COLOR, c);
    ObjectSet(cTxtM, OBJPROP_FONTSIZE, size);
    ObjectSet(cTxtM, OBJPROP_ANCHOR, anchor);
    ObjectSet(cTxtM, OBJPROP_CORNER, corner);
    ObjectSetString(0, cTxtM, OBJPROP_FONT, font);
    ObjectSet(iTxBg, OBJPROP_FONTSIZE, size*2);
    ObjectSet(iTxBg, OBJPROP_ANCHOR, anchor);
    ObjectSet(iTxBg, OBJPROP_CORNER, corner);
    ObjectSetString(0,  iTxBg, OBJPROP_FONT, font);

    int idx = 1;
    string objCTxtX = cTxtX +"#"+ IntegerToString(idx);
    string objiTBgX = iTBgX +"#"+ IntegerToString(idx);
    while (ObjectFind(objCTxtX) >= 0) {
        ObjectSet(objCTxtX, OBJPROP_COLOR, c);
        ObjectSet(objCTxtX, OBJPROP_FONTSIZE, size);
        ObjectSet(objCTxtX, OBJPROP_ANCHOR, anchor);
        ObjectSet(objCTxtX, OBJPROP_CORNER, corner);
        ObjectSetString(0, objCTxtX, OBJPROP_FONT, font);
        
        ObjectSet(objiTBgX, OBJPROP_FONTSIZE, size*2);
        ObjectSet(objiTBgX, OBJPROP_ANCHOR, anchor);
        ObjectSet(objiTBgX, OBJPROP_CORNER, corner);
        ObjectSetString(0,  objiTBgX, OBJPROP_FONT, font);
        idx++;
        objCTxtX = cTxtX +"#"+ IntegerToString(idx);
        objiTBgX = iTBgX +"#"+ IntegerToString(idx);
    }
    onItemDrag(itemId, objId);
}
void LabelText::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cTxtM);
    ObjectDelete(iTxBg);
    int idx = 1;
    string objCTxtX;
    string objiTBgX;
    do
    {
        objCTxtX = cTxtX +"#"+ IntegerToString(idx);
        objiTBgX = iTBgX +"#"+ IntegerToString(idx);
        ObjectDelete(objiTBgX);
        idx++;
    }
    while (ObjectDelete(objCTxtX) == true);
}
void LabelText::onUserRequest(const string &itemId, const string &objId)
{
    onItemDrag(itemId, objId);

    int newIdx = itemDragIdx+1;
    string objCTxtX = cTxtX +"#"+ IntegerToString(newIdx);
    string objiTBgX = iTBgX +"#"+ IntegerToString(newIdx);
    while (ObjectFind(objCTxtX) >= 0)
    {
        newIdx++;
        objCTxtX = cTxtX +"#"+ IntegerToString(newIdx);
        objiTBgX = iTBgX +"#"+ IntegerToString(newIdx);
    }
    ObjectCreate(objiTBgX, OBJ_LABEL, 0, 0, 0);
    ObjectCreate(objCTxtX, OBJ_LABEL, 0, 0, 0);
    string font = ObjectGetString(0, cTxtM, OBJPROP_FONT);
    color c     = (color)ObjectGet(cTxtM, OBJPROP_COLOR);
    int size    = (int)  ObjectGet(cTxtM, OBJPROP_FONTSIZE);
    int anchor  = (int)  ObjectGet(cTxtM, OBJPROP_ANCHOR);
    int corner  = (int)  ObjectGet(cTxtM, OBJPROP_CORNER);

    ObjectSet(objCTxtX, OBJPROP_SELECTED, true);
    ObjectSet(objCTxtX, OBJPROP_XDISTANCE, posX);
    ObjectSet(objCTxtX, OBJPROP_YDISTANCE, posY+(newIdx)*spaceSize);
    setTextContent(objCTxtX, getRandStr(), size, font, c);
    ObjectSet(objCTxtX, OBJPROP_ANCHOR, anchor);
    ObjectSet(objCTxtX, OBJPROP_CORNER, corner);

    ObjectSet(objiTBgX, OBJPROP_XDISTANCE, posX);
    ObjectSet(objiTBgX, OBJPROP_YDISTANCE, posY+(newIdx)*spaceSize);
    // todo: case bottom left/ bottom right -> getHalfDwBL
    setTextContent(objiTBgX, getHalfUpBL(StringLen(ObjectDescription(objCTxtX))), size*2, font, gClrTextBgnd);
    ObjectSet(objiTBgX, OBJPROP_ANCHOR, anchor);
    ObjectSet(objiTBgX, OBJPROP_CORNER, corner);
    ObjectSet(objiTBgX, OBJPROP_SELECTABLE, false);

    setMultiStrs(OBJPROP_TOOLTIP, "\n", objCTxtX+objiTBgX);

    refreshData();
    gContextMenu.clearContextMenu();
}