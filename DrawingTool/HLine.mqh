#include "../Base/BaseItem.mqh"

class HLine : public BaseItem
{
    private:
        int myValue;
    public:
    HLine(){myValue = 1;}
    virtual void onMouseMove();
    virtual void onMouseClick();
};

void HLine::onMouseMove()
{
    PrintFormat("HLine::onMouseMove %d", myValue);
}

void HLine::onMouseClick()
{
    PrintFormat("HLine::onMouseClick");
}