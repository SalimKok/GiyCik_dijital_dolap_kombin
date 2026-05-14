import smtplib
from email.message import EmailMessage
from email.utils import formataddr
from app.config import settings

def send_reset_code_email(to_email: str, code: str):
    if not settings.SMTP_USERNAME or not settings.SMTP_PASSWORD:
        print(f"\n[EMAIL_MOCK] To: {to_email} | Şifre Sıfırlama Kodunuz: {code}\n")
        return

    msg = EmailMessage()
    msg['Subject'] = "GiyÇık Şifre Sıfırlama Kodu"
    msg['From'] = formataddr(("GiyÇık Destek", settings.SMTP_USERNAME))
    msg['To'] = to_email
    
    html_content = f"""
    <html>
      <body style="font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;">
        <div style="max-width: 500px; margin: 0 auto; background-color: #ffffff; padding: 30px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.1);">
          <h2 style="color: #2b3a4a; text-align: center;">Şifre Sıfırlama İsteği</h2>
          <p style="color: #555; font-size: 16px;">Merhaba,</p>
          <p style="color: #555; font-size: 16px;">GiyÇık hesabınızın şifresini sıfırlamak için bir talepte bulundunuz. İşlemi tamamlamak için aşağıdaki 6 haneli kodu uygulamaya girin:</p>
          <div style="background-color: #f0f4f8; padding: 15px; text-align: center; border-radius: 8px; margin: 25px 0;">
            <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #1e88e5;">{code}</span>
          </div>
          <p style="color: #888; font-size: 14px; text-align: center;">Bu kod 15 dakika boyunca geçerlidir. Eğer bu talebi siz yapmadıysanız lütfen bu mesajı görmezden gelin.</p>
        </div>
      </body>
    </html>
    """
    msg.set_content(f"Şifre Sıfırlama Kodunuz: {code}")
    msg.add_alternative(html_content, subtype='html')

    try:
        # Use starttls for port 587
        server = smtplib.SMTP(settings.SMTP_SERVER, settings.SMTP_PORT)
        server.ehlo()
        server.starttls()
        server.login(settings.SMTP_USERNAME, settings.SMTP_PASSWORD)
        server.send_message(msg)
        server.quit()
        print(f"Password reset email successfully sent to {to_email}")
    except Exception as e:
        print(f"Failed to send email: {str(e)}")
