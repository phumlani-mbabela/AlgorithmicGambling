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
   if(!SendMail(subject, message))
      Print("Email sending failed. Error: ", GetLastError());
   else
      Print("Email sent successfully.");
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notification::SendWhatsAppNotification(string phone, string message)
{
   string url = "https://api.twilio.com/2010-04-01/Accounts/YOUR_ACCOUNT_SID/Messages.json";
   string data = "To=" + phone + "&From=whatsapp:+YOUR_TWILIO_NUMBER&Body=" + message;

   char headers[][2] ; // { {"Authorization", "Basic YOUR_BASE64_ENCODED_CREDENTIALS"},      {"Content-Type", "application/x-www-form-urlencoded"}   };

   char result[];
   int res = 0;//WebRequest("POST", url, headers, 2, data, result, 5000);

   if(res == 200)
      Print("WhatsApp message sent successfully.");
   else
      Print("Failed to send WhatsApp message. Error: ", GetLastError());
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notification::SendTelegramNotification(string chatID, string message)
{
   string url = "https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage?chat_id=" + chatID + "&text=" + message;
   char result[];

   int res = 0;//WebRequest("GET", url, "", 0, "", result, 5000);

   if(res == 200)
      Print("Telegram message sent successfully.");
   else
      Print("Failed to send Telegram message. Error: ", GetLastError());
}
//+------------------------------------------------------------------+
