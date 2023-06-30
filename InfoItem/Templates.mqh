#include "../Utility.mqh"

input color Templates_TextColor = clrBlack;
input color Templates_BgColor   = clrLightGray;

class Templates
{
private:
    string mActiveObjectId;
    string templateList[];

public:
    Templates()
    {
    }
    virtual void onItemClick(const string &objId)
    {
        // Todo check template item or not?
        gController.handleSparamEvent(CHART_EVENT_SELECT_TEMPLATES, mActiveObjectId);
    }
public:
    void openTemplates(const string &objId, const string data)
    {
        mActiveObjectId = objId;

        int k=StringSplit(data,',',templateList);
        // Todo: draw template!
        for (int i = 0; i < k; i++)
        {
            //
        }
    }
    void clearTemplates()
    {
        mActiveObjectId = "";
    }
};