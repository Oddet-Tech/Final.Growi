const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Configure your email service here (Gmail, SendGrid, etc.)
// For this example, we'll use environment configuration
const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST || "smtp.gmail.com",
  port: parseInt(process.env.EMAIL_PORT || "587"),
  secure: process.env.EMAIL_SECURE === "true",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  },
});

// Send emails from the email queue collection
exports.sendQueuedEmails = functions.pubsub
  .schedule("every 5 minutes")
  .onRun(async (context) => {
    try {
      const db = admin.firestore();
      const emailQueue = db.collection("emailQueue");

      // Get unsent emails
      const unsentEmails = await emailQueue
        .where("sent", "==", false)
        .limit(10)
        .get();

      console.log(`Found ${unsentEmails.size} unsent emails`);

      for (const doc of unsentEmails.docs) {
        const emailData = doc.data();

        try {
          const subject = await generateSubject(emailData);
          const htmlContent = await generateHtmlContent(emailData);

          // Send email
          await transporter.sendMail({
            from: process.env.EMAIL_FROM || "noreply@growi.app",
            to: emailData.to,
            subject: subject,
            html: htmlContent,
          });

          // Mark as sent
          await doc.ref.update({
            sent: true,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          console.log(`Email sent to ${emailData.to}`);
        } catch (error) {
          console.error(`Failed to send email: ${error.message}`);

          // Update retry count
          const retryCount = (emailData.retryCount || 0) + 1;
          if (retryCount < 3) {
            await doc.ref.update({
              retryCount: retryCount,
              lastError: error.message,
              lastAttempt: admin.firestore.FieldValue.serverTimestamp(),
            });
          } else {
            // Mark as failed after 3 retries
            await doc.ref.update({
              sent: false,
              failed: true,
              lastError: error.message,
            });
          }
        }
      }

      return null;
    } catch (error) {
      console.error("Error in sendQueuedEmails:", error);
      throw error;
    }
  });

// Trigger when order status is updated
exports.onOrderStatusChanged = functions.firestore
  .document("orders/{orderId}")
  .onUpdate(async (change, context) => {
    const previousData = change.before.data();
    const newData = change.after.data();

    // If status changed and it's not pending
    if (previousData.status !== newData.status && newData.status !== "Pending") {
      const db = admin.firestore();
      const userId = newData.userId;

      // Get user email
      const userDoc = await db.collection("users").doc(userId).get();
      const userEmail = userDoc.data()?.email;
      const userName = userDoc.data()?.displayName || "Customer";

      if (!userEmail) {
        console.log(`No email found for user ${userId}`);
        return null;
      }

      // Queue status update email
      await db.collection("emailQueue").add({
        type: `order_${newData.status.toLowerCase()}`,
        to: userEmail,
        userName: userName,
        orderId: context.params.orderId,
        status: newData.status,
        trackingNumber: newData.trackingNumber,
        pickupStore: newData.locationInfo?.storeName,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        sent: false,
      });

      console.log(`Status update email queued for order ${context.params.orderId}`);
    }

    return null;
  });

/**
 * Generate email subject based on type
 */
async function generateSubject(emailData) {
  switch (emailData.type) {
    case "order_confirmation":
      return `Order Confirmation - #${emailData.orderId.substring(0, 8).toUpperCase()}`;
    case "payment_success":
      return `Payment Received - Order #${emailData.orderId.substring(0, 8).toUpperCase()}`;
    case "order_shipped":
      return `Your Order Has Been Shipped! 🚚`;
    case "order_delivered":
      return `Your Order Has Been Delivered! 📦`;
    case "order_cancelled":
      return `Order Cancellation Notice`;
    default:
      return `Order Update`;
  }
}

/**
 * Generate HTML email content
 */
async function generateHtmlContent(emailData) {
  const brandColor = "#1F7A4C";
  const secondaryColor = "#F8EED2";

  switch (emailData.type) {
    case "order_confirmation":
      return `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: ${brandColor}; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; border: 1px solid #ddd; }
            .order-items { margin: 20px 0; }
            .item { padding: 10px; border-bottom: 1px solid #eee; }
            .total { font-size: 18px; font-weight: bold; color: ${brandColor}; margin-top: 20px; }
            .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #999; }
            .btn { background-color: ${brandColor}; color: white; padding: 10px 20px; text-decoration: none; display: inline-block; margin-top: 20px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Order Confirmed! ✓</h1>
            </div>
            <div class="content">
              <p>Hi ${emailData.userName},</p>
              <p>Thank you for your order! We're excited to process it.</p>
              
              <div class="order-items">
                <h3>Order Details:</h3>
                <p><strong>Order ID:</strong> ${emailData.orderId.substring(0, 8).toUpperCase()}</p>
                <p><strong>Items:</strong> ${emailData.totalItems} product(s)</p>
                <p><strong>Pickup Location:</strong> ${emailData.pickupStore}</p>
                <div class="total">Total: R${parseFloat(emailData.finalTotal).toFixed(2)}</div>
              </div>

              <p>Your order status is currently <strong>Pending</strong>. You'll receive another email when it's shipped with tracking information.</p>

              <a href="#" class="btn">View Order</a>
            </div>
            <div class="footer">
              <p>© 2024 Growi. All rights reserved.</p>
              <p>If you have any questions, please contact us.</p>
            </div>
          </div>
        </body>
        </html>
      `;

    case "payment_success":
      return `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: ${brandColor}; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; border: 1px solid #ddd; }
            .success-box { background-color: #4CAF50; color: white; padding: 15px; border-radius: 5px; margin: 20px 0; }
            .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #999; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Payment Received! 💳</h1>
            </div>
            <div class="content">
              <p>Hi ${emailData.userName},</p>
              
              <div class="success-box">
                <p style="margin: 0; font-size: 16px;"><strong>Payment Successful</strong></p>
              </div>

              <p><strong>Amount:</strong> R${parseFloat(emailData.amount).toFixed(2)}</p>
              <p><strong>Card:</strong> ${emailData.cardLastFour}</p>
              <p><strong>Order ID:</strong> ${emailData.orderId.substring(0, 8).toUpperCase()}</p>

              <p>Your payment has been successfully processed. Your order is now being prepared for shipment.</p>

              <p style="margin-top: 30px; color: #666; font-size: 12px;">
                This is an automated message, please do not reply to this email.
              </p>
            </div>
            <div class="footer">
              <p>© 2024 Growi. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      `;

    case "order_shipped":
      return `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: ${brandColor}; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; border: 1px solid #ddd; }
            .info-box { background-color: #E3F2FD; padding: 15px; border-left: 4px solid #2196F3; margin: 20px 0; }
            .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #999; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Your Order is On Its Way! 🚚</h1>
            </div>
            <div class="content">
              <p>Hi ${emailData.userName},</p>
              
              <div class="info-box">
                <p style="margin: 0;"><strong>Order #${emailData.orderId.substring(0, 8).toUpperCase()} has been shipped!</strong></p>
              </div>

              <p><strong>Pickup Store:</strong> ${emailData.pickupStore}</p>
              ${emailData.trackingNumber ? `<p><strong>Tracking Number:</strong> ${emailData.trackingNumber}</p>` : ""}

              <p>Your order is on its way and will be available for collection at the specified pickup location.</p>

              <p>Thank you for shopping with Growi!</p>
            </div>
            <div class="footer">
              <p>© 2024 Growi. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      `;

    case "order_delivered":
      return `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: ${brandColor}; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; border: 1px solid #ddd; }
            .success { background-color: #C8E6C9; color: #2E7D32; padding: 15px; border-radius: 5px; margin: 20px 0; }
            .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #999; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Order Delivered! 📦</h1>
            </div>
            <div class="content">
              <p>Hi ${emailData.userName},</p>
              
              <div class="success">
                <p style="margin: 0;"><strong>Your order #${emailData.orderId.substring(0, 8).toUpperCase()} has been delivered!</strong></p>
              </div>

              <p>Pickup Location: ${emailData.pickupStore}</p>

              <p>Thank you for your purchase! We hope you enjoy your items.</p>

              <p style="margin-top: 30px;">
                If you have any issues with your order, please contact our customer support team.
              </p>
            </div>
            <div class="footer">
              <p>© 2024 Growi. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      `;

    default:
      return `
        <!DOCTYPE html>
        <html>
        <body>
          <p>Hi ${emailData.userName},</p>
          <p>Your order status has been updated.</p>
        </body>
        </html>
      `;
  }
}
