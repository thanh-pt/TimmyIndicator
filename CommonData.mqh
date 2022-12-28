class CommonData
{
// public:
//     datetime mCurrentMouseTime;
//     double   mCurrentMousePrice;
//     int      mX;
//     int      mY;
//     int      mSubwindow;
//     bool     mbToolBoxBarClicked;
//     bool     mbShiftHold;
// public:
//     void updateMousePosition(const long& x, const double& y, const int& option)
//     {
//         mbShiftHold = ((option & SHIFT_HOLD) != 0);
//         int offset = 0;//-20;
//         mX = (int)x+offset;
//         mY = (int)y+offset;
//         ChartXYToTimePrice(ChartID(), (int)mX, (int)mY, mSubwindow, mCurrentMouseTime, mCurrentMousePrice);
//         if((option & CTRL_HOLD) != 0)
//         {
//             controlHold();
//         }
//     }
//     void controlHold()
//     {
//         int shift = iBarShift(ChartSymbol(), ChartPeriod(), mCurrentMouseTime);
//         if (shift <= 0)
//         {
//             return;
//         }
//         if (Low[shift] >= mCurrentMousePrice && Low[shift] <= mCurrentMousePrice+10)
//         {
//             mCurrentMousePrice = Low[shift];
//             ChartTimePriceToXY(ChartID(), 0, mCurrentMouseTime, mCurrentMousePrice, mX, mY);
//         }
//         else
//         if (High[shift] <= mCurrentMousePrice && High[shift] <= mCurrentMousePrice+10)
//         {
//             mCurrentMousePrice = High[shift];
//             ChartTimePriceToXY(ChartID(), 0, mCurrentMouseTime, mCurrentMousePrice, mX, mY);
//         }
//     }
};