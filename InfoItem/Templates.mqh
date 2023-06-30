#include "../Utility.mqh"

input color Templates_TextColor = clrBlack;
input color Templates_BgColor1  = clrGray;
input color Templates_BgColor2  = clrLightGray;

#define TEXT_FULL_BLOCK "██████████████████████████████████████████████████████████████████"

class Templates
{
private:
    string mActiveObjectId;
    string mTemplates[];
    int mSize;
public:
    int mActivePos;

public:
    Templates()
    {
    }
    virtual void onItemClick(const string &objId)
    {
        // Todo check template item or not?
        if (StringFind(objId, "Templates") == -1) return;

        string sparamItems[];
        int k=StringSplit(objId,'_',sparamItems);
        if (k != 2) return;

        mActivePos = StrToInteger(sparamItems[1]);
        string itemBgnd;
        for (int i = 0; i < mSize; i++)
        {
            itemBgnd = "TemplatesBgnd_"+IntegerToString(i);
            if (i == mActivePos){
                ObjectSet(itemBgnd, OBJPROP_COLOR, Templates_BgColor2);
            }
            else {
                ObjectSet(itemBgnd, OBJPROP_COLOR, Templates_BgColor1);
            }
        }
        gController.handleSparamEvent(CHART_EVENT_SELECT_TEMPLATES, mActiveObjectId);
    }
public:
    void openTemplates(const string objId, const string data, const int activePos)
    {
        mActiveObjectId = objId;
        mActivePos = activePos;
        mSize = StringSplit(data,',',mTemplates);
        for (int i = 0; i < mSize; i++)
        {
            drawItem(mTemplates[i], i);
        }
    }
    void clearTemplates()
    {
        mActiveObjectId = "";
        for (int i = 0; i < 10; i++)
        {
            deleteItem(i);
        }
    }
private:
    void drawItem(const string& name, int pos)
    {
        string itemName = "TemplatesName_"+IntegerToString(pos);
        string itemBgnd = "TemplatesBgnd_"+IntegerToString(pos);
        ObjectCreate(itemBgnd, OBJ_LABEL, 0, 0, 0);
        ObjectCreate(itemName, OBJ_LABEL, 0, 0, 0);
        ObjectSet(itemBgnd, OBJPROP_SELECTABLE, false);
        ObjectSet(itemName, OBJPROP_SELECTABLE, false);
        ObjectSetText(itemBgnd, StringSubstr(TEXT_FULL_BLOCK, 0, StringLen(name)+2), 10, "Courier New", Templates_BgColor1);
        ObjectSetText(itemName,                                            " "+name, 10, "Courier New", Templates_TextColor);
        ObjectSetInteger(0, itemName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
        ObjectSetInteger(0, itemBgnd, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);

        int topOffset = 20;
        int leftOffset = 5;
        int textSpace = 17;

        ObjectSet(itemName, OBJPROP_XDISTANCE, leftOffset);
        ObjectSet(itemName, OBJPROP_YDISTANCE, topOffset+pos*textSpace);

        ObjectSet(itemBgnd, OBJPROP_XDISTANCE, leftOffset);
        ObjectSet(itemBgnd, OBJPROP_YDISTANCE, topOffset+pos*textSpace);

        if (pos == mActivePos)
        {
            ObjectSet(itemBgnd, OBJPROP_COLOR, Templates_BgColor2);
        }
    }
    void deleteItem(int pos)
    {
        string itemName = "TemplatesName_"+IntegerToString(pos);
        string itemBgnd = "TemplatesBgnd_"+IntegerToString(pos);
        ObjectDelete(itemName);
        ObjectDelete(itemBgnd);
    }
};