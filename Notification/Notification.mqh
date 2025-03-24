//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Phumlani Mbabela"
#property link      "https://www.mql5.com"
#property version   "1.00"

class Notification {
private:

public:
   Notification();
   ~Notification();
   void SendEmailNotification(string subject, string message);
   void SendWhatsAppNotification(string phone, string message);
   void SendTelegramNotification(string chatID, string message);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Notification::Notification()
{
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Notification::~Notification()
{
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notification::SendEmailNotification(string subject, string message)
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notification::SendWhatsAppNotification(string phone, string message)
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notification::SendTelegramNotification(string chatID, string message)
{

}
//+------------------------------------------------------------------+
