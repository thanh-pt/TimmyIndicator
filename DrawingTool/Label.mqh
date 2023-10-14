#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string _10 = "";
input color Label_Color = clrMidnightBlue;

enum LabelTextType
{
    TYPE_NUM,
};

class LabelText : public BaseItem
{
// Internal Value
private:
    int posX;
    int posY;
    int spaceSize;
// Component name
private:
    string cLbText;

// Value define for Item
private:

public:
    LabelText(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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

LabelText::LabelText(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
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
}

// Internal Event
void LabelText::prepareActive(){}
void LabelText::createItem()
{
    ObjectCreate(cLbText, OBJ_LABEL, 0, 0, 0);
    updateDefaultProperty();
    updateTypeProperty();
    ObjectSet(cLbText, OBJPROP_XDISTANCE, pCommonData.mMouseX);
    ObjectSet(cLbText, OBJPROP_YDISTANCE, pCommonData.mMouseY);
}
void LabelText::updateDefaultProperty()
{
    ObjectSetText(cLbText, "label", 12, "Consolas", Label_Color);
}
void LabelText::updateTypeProperty(){}
void LabelText::activateItem(const string& itemId)
{
    cLbText = itemId + "_cLbText";
}
void LabelText::updateItemAfterChangeType(){}
void LabelText::refreshData()
{
    ObjectSet(cLbText, OBJPROP_XDISTANCE, posX);
    ObjectSet(cLbText, OBJPROP_YDISTANCE, posY);
    int idx = 0;
    string additionalText = cLbText +"#"+ IntegerToString(idx);
    while (ObjectFind(additionalText) >= 0)
    {
        ObjectSet(additionalText, OBJPROP_XDISTANCE, posX);
        ObjectSet(additionalText, OBJPROP_YDISTANCE, posY+(idx+1)*spaceSize);
        idx++;
        additionalText = cLbText +"#"+ IntegerToString(idx);
    }
}
void LabelText::finishedJobDone(){}

// Chart Event
void LabelText::onMouseMove(){}
void LabelText::onMouseClick()
{
    createItem();
    mFinishedJobCb();
}
void LabelText::onItemDrag(const string &itemId, const string &objId)
{
    if (objId == cLbText)
    {
        posX = (int)ObjectGet(objId, OBJPROP_XDISTANCE);
        posY = (int)ObjectGet(objId, OBJPROP_YDISTANCE);
    }
    else
    {
        string sparamItems[];
        int k=StringSplit(objId,'#',sparamItems);
        if (k != 3) return;
        int idx = StrToInteger(sparamItems[2]);
        posX = (int)ObjectGet(objId, OBJPROP_XDISTANCE);
        posY = (int)ObjectGet(objId, OBJPROP_YDISTANCE)-(idx+1)*spaceSize;
    }
    refreshData();
}
void LabelText::onItemClick(const string &itemId, const string &objId)
{
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    ObjectSet(cLbText, OBJPROP_SELECTED, selected);

    int idx = 0;
    string additionalText = cLbText +"#"+ IntegerToString(idx);
    while (ObjectFind(additionalText) >= 0)
    {
        ObjectSet(additionalText, OBJPROP_SELECTED, selected);
        idx++;
        additionalText = cLbText +"#"+ IntegerToString(idx);
    }
}
void LabelText::onItemChange(const string &itemId, const string &objId){}
void LabelText::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cLbText);
    int idx = 0;
    string objName = "";
    do
    {
        objName = cLbText +"#"+ IntegerToString(idx);
        idx++;
    }
    while (ObjectDelete(objName) == true);
}