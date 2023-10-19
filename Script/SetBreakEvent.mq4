//+------------------------------------------------------------------+
//|                                                SetBreakEvent.mq4 |
//|                                           Timmy - Trader Ham Học |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy - Trader Ham Học"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
    int openedTrade = 0;
    int tradePos    = -1;
    for( int i = 0 ; i < OrdersTotal() ; i++ ) { 
        if (OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false) continue;
        if (OrderSymbol() == Symbol() && fabs(OrderProfit()) > 0.001)
        {
            openedTrade++;
            tradePos = i;
        }
    }
    if (openedTrade == 1)
    {
        if (OrderSelect( tradePos, SELECT_BY_POS, MODE_TRADES ) == true)
        {
            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Blue);
            if(!res)
                Print("Error in OrderModify. Error code=",GetLastError());
            else
                Print("Order modified successfully.");
        }
    }
    else if (openedTrade > 1)
    {
        Print("There are ", openedTrade, " opened trades. UNDER Develop!!!");
    }
}
//+------------------------------------------------------------------+
