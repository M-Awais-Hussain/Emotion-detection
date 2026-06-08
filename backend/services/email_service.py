"""
Email Service
Handles sending contact emails
"""

import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import Dict

class EmailService:
    """Service for sending emails"""
    
    def __init__(self):
        """Initialize email service"""
        self.smtp_server = os.getenv("SMTP_SERVER", "smtp.gmail.com")
        self.smtp_port = int(os.getenv("SMTP_PORT", "587"))
        self.smtp_username = os.getenv("SMTP_USERNAME", "")
        self.smtp_password = os.getenv("SMTP_PASSWORD", "")
        self.recipient_email = os.getenv("RECIPIENT_EMAIL", "")
        
        # Fallback to EmailJS if SMTP not configured
        self.use_emailjs = not (self.smtp_username and self.smtp_password)
        
        if self.use_emailjs:
            self.emailjs_service_id = os.getenv("EMAILJS_SERVICE_ID", "service_fpeqneh")
            self.emailjs_template_id = os.getenv("EMAILJS_TEMPLATE_ID", "template_akrz1dd")
            self.emailjs_user_id = os.getenv("EMAILJS_USER_ID", "NYLx1xbXXe8jZ62U6")
    
    async def send_email(self, name: str, subject: str, message: str) -> Dict[str, any]:
        """
        Send contact email
        
        Args:
            name: Sender name
            subject: Email subject
            message: Email message
        
        Returns:
            Result dictionary
        """
        try:
            if self.use_emailjs:
                return await self._send_via_emailjs(name, subject, message)
            else:
                return await self._send_via_smtp(name, subject, message)
        
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    async def _send_via_smtp(self, name: str, subject: str, message: str) -> Dict[str, any]:
        """Send email via SMTP"""
        try:
            import aiosmtplib
            
            msg = MIMEMultipart()
            msg['From'] = self.smtp_username
            msg['To'] = self.recipient_email
            msg['Subject'] = f"Emotion Eye Contact: {subject}"
            
            body = f"""
            Contact Form Submission from Emotion Eye App
            
            Name: {name}
            Subject: {subject}
            
            Message:
            {message}
            """
            
            msg.attach(MIMEText(body, 'plain'))
            
            await aiosmtplib.send(
                msg,
                hostname=self.smtp_server,
                port=self.smtp_port,
                username=self.smtp_username,
                password=self.smtp_password,
                use_tls=True
            )
            
            return {"success": True}
        
        except Exception as e:
            return {
                "success": False,
                "error": f"SMTP error: {str(e)}"
            }
    
    async def _send_via_emailjs(self, name: str, subject: str, message: str) -> Dict[str, any]:
        """Send email via EmailJS API"""
        try:
            import httpx
            
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.post(
                    "https://api.emailjs.com/api/v1.0/email/send",
                    json={
                        "service_id": self.emailjs_service_id,
                        "template_id": self.emailjs_template_id,
                        "user_id": self.emailjs_user_id,
                        "template_params": {
                            "name": name,
                            "subject": subject,
                            "message": message
                        }
                    },
                    headers={"Content-Type": "application/json"}
                )
                
                if response.status_code == 200:
                    return {"success": True}
                else:
                    return {
                        "success": False,
                        "error": f"EmailJS API error: {response.status_code}"
                    }
        
        except Exception as e:
            return {
                "success": False,
                "error": f"EmailJS error: {str(e)}"
            }

