# Growi Payment & Order Management System

A comprehensive payment and order management system for the Growi e-commerce application with Firebase integration, email notifications, and admin controls.

## 📋 Features

### User Features
- **Location Capture**: Automatically captures user's current location using geolocator
- **Store Selection**: Choose between PEP or POSTNET stores for pickup
- **Card Payment**: Secure card details input (masked display)
- **Order Tracking**: View all orders with status updates in user dashboard
- **Email Notifications**: Automatic emails for order confirmation, payment success, shipping, and delivery

### Admin Features
- **Order Management**: View all orders across the system
- **Status Updates**: Mark orders as Shipped, Delivered, or Cancelled
- **Tracking Numbers**: Add tracking numbers when marking orders as shipped
- **Real-time Monitoring**: Stream-based order updates

## 🏗️ Architecture

### File Structure
```
growi_project/
├── lib/
│   ├── appscreen/
│   │   ├── payment.dart          # Payment page with location capture
│   │   ├── admin_orders.dart     # Admin order management
│   │   └── models.dart           # Order, OrderItem, PaymentInfo, LocationInfo models
│   ├── services/
│   │   └── firebase_service.dart # Firebase operations and email queuing
│   └── userdashbord.dart         # User dashboard showing orders
└── functions/
    ├── index.js                  # Cloud Functions for email sending
    ├── package.json              # Cloud Functions dependencies
    └── .env.example              # Email configuration template
```

### Models

#### Order
Represents a complete order with all transaction details.

```dart
class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final double taxAmount;
  final double finalTotal;
  final PaymentInfo paymentInfo;
  final LocationInfo locationInfo;
  final String status; // 'Pending', 'Shipped', 'Delivered', 'Cancelled'
  final DateTime orderDate;
  final DateTime? shippedDate;
  final DateTime? deliveredDate;
  final String? trackingNumber;
}
```

#### LocationInfo
Stores user location and store information.

```dart
class LocationInfo {
  final double latitude;
  final double longitude;
  final String address;
  final String storeName;
  final String storeType; // "PEP" or "POSTNET"
}
```

#### PaymentInfo
Stores card details (masked in display).

```dart
class PaymentInfo {
  final String cardHolder;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
}
```

## 🔥 Firebase Collections

### orders
Stores all order documents.

```json
{
  "id": "order-id",
  "userId": "user-id",
  "items": [...],
  "totalAmount": 1500.00,
  "taxAmount": 60.00,
  "finalTotal": 1560.00,
  "paymentInfo": {...},
  "locationInfo": {...},
  "status": "Pending",
  "orderDate": "2024-05-26T10:30:00Z",
  "shippedDate": null,
  "deliveredDate": null,
  "trackingNumber": null
}
```

### users
Stores user email and profile information for email notifications.

```json
{
  "email": "user@example.com",
  "displayName": "John Doe",
  "lastUpdated": "2024-05-26T10:30:00Z"
}
```

### emailQueue
Queue for emails to be sent by Cloud Functions.

```json
{
  "type": "order_confirmation",
  "to": "user@example.com",
  "userName": "John Doe",
  "orderId": "order-id",
  "status": "Pending",
  "sent": false,
  "createdAt": "2024-05-26T10:30:00Z",
  "retryCount": 0
}
```

### emailLogs
Audit trail of sent emails.

```json
{
  "type": "order_confirmation",
  "recipient": "user@example.com",
  "orderId": "order-id",
  "status": "Queued",
  "timestamp": "2024-05-26T10:30:00Z"
}
```

## 📧 Email Types

### 1. Order Confirmation
Sent immediately after order is created.
- Order ID
- Number of items
- Pickup store
- Total amount

### 2. Payment Success
Sent immediately after payment verification.
- Payment amount
- Masked card number
- Order reference

### 3. Order Shipped
Triggered when admin marks order as shipped.
- Pickup store
- Tracking number (if available)
- Expected delivery timeframe

### 4. Order Delivered
Triggered when admin marks order as delivered.
- Pickup location
- Thank you message

### 5. Order Cancelled
Sent if order is cancelled.
- Cancellation reason
- Contact information

## 🚀 Setup Instructions

### 1. Flutter Setup

#### Add Dependencies
```yaml
dependencies:
  geolocator: ^14.0.2
  firebase_core: ^4.9.0
  firebase_auth: ^6.5.1
  cloud_firestore: ^6.4.1
```

#### Install Packages
```bash
flutter pub get
```

### 2. Firebase Setup

#### Create Firestore Database
1. Go to Firebase Console
2. Create Firestore Database in production mode
3. Create collections: `orders`, `users`, `emailQueue`, `emailLogs`

#### Enable Required Services
- Authentication
- Firestore
- Cloud Functions
- Cloud Logging

### 3. Cloud Functions Setup

#### Install Node.js
```bash
# Install Node.js 18+
# Download from https://nodejs.org/
```

#### Setup Functions
```bash
cd functions
npm install
```

#### Configure Email Service

Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

Edit `.env` with your email credentials (Gmail or SendGrid):

**For Gmail:**
1. Enable 2-Step Verification on Google Account
2. Generate App Password at https://myaccount.google.com/apppasswords
3. Add credentials to `.env`

**For SendGrid:**
1. Create SendGrid account
2. Generate API key
3. Update `.env` with SendGrid settings

#### Deploy Functions
```bash
firebase login
firebase deploy --only functions
```

### 4. Firestore Security Rules

Create Firestore rules to secure collections:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Orders - users can only read their own
    match /orders/{orderId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.uid == request.resource.data.userId;
      allow update: if request.auth.uid == resource.data.userId 
                      || isAdmin();
    }
    
    // Users - authenticated users can update their own
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
    }
    
    // Email queue - admin only
    match /emailQueue/{document=**} {
      allow read, write: if isAdmin();
    }
    
    // Email logs - admin only
    match /emailLogs/{document=**} {
      allow read: if isAdmin();
    }
  }
  
  function isAdmin() {
    return request.auth.token.admin == true;
  }
}
```

## 💻 Usage

### User Payment Flow
1. User adds items to cart
2. User navigates to checkout
3. Location is automatically captured
4. User selects pickup store (PEP or POSTNET)
5. User enters card details
6. User submits payment
7. Order is created with "Pending" status
8. Confirmation email is sent
9. User is redirected to dashboard

### User Order Tracking
1. User opens dashboard
2. User sees all orders with real-time status updates
3. User can filter by status (All, Pending, Shipped, Delivered)
4. User can expand order to see full details
5. User receives email updates at each status change

### Admin Order Management
1. Admin opens Order Management screen
2. Admin sees all orders from all users
3. Admin filters by status
4. Admin clicks order to expand details
5. Admin can:
   - Mark as Shipped (with optional tracking number)
   - Mark as Delivered
   - Cancel order
6. Notification email automatically sent to customer

## 🔐 Security Considerations

1. **Card Details**: Masked in all displays and stored encrypted in Firebase
2. **User Data**: Users can only see their own orders
3. **Admin Access**: Requires admin role verification
4. **Email Service**: Uses environment variables, never commits credentials
5. **Firestore Rules**: Enforce authentication and authorization

## 📊 Firebase Cloud Functions Triggers

### Scheduled Task: `sendQueuedEmails`
- **Trigger**: Every 5 minutes
- **Function**: Processes email queue and sends pending emails
- **Retry**: Automatically retries failed emails up to 3 times

### Document Trigger: `onOrderStatusChanged`
- **Trigger**: When order document is updated
- **Function**: Queues status update email if status changes from Pending

## 🛠️ Troubleshooting

### Emails Not Sending
1. Check `.env` file is properly configured
2. Verify email credentials in Firebase Console environment variables
3. Check Cloud Functions logs: `firebase functions:log`
4. Ensure `emailQueue` collection exists

### Location Not Capturing
1. Check device location permissions
2. Ensure GPS is enabled
3. Check geolocator plugin installation

### Orders Not Appearing
1. Verify user authentication
2. Check Firestore security rules
3. Ensure user ID matches in orders collection

## 📱 Testing

### Test Order Creation
```dart
// In payment.dart test
final order = Order(
  id: 'test-order',
  userId: 'test-user',
  items: [...],
  totalAmount: 100,
  taxAmount: 4,
  finalTotal: 104,
  paymentInfo: PaymentInfo(...),
  locationInfo: LocationInfo(...),
  status: 'Pending',
  orderDate: DateTime.now(),
);

await FirebaseService.createOrder(order);
```

### Test Email Queue
```bash
firebase emulators:start --only functions
# Then trigger payment flow to test email queuing
```

## 📈 Future Enhancements

- [ ] Real payment gateway integration (Payfast, Stripe)
- [ ] SMS notifications in addition to email
- [ ] Order history export to CSV
- [ ] Multiple payment methods (Bank transfer, EFT)
- [ ] Order refund processing
- [ ] Customer support ticket integration
- [ ] Order analytics dashboard
- [ ] Automatic order reminders

## 📞 Support

For issues or questions:
1. Check Firebase Console logs
2. Review Cloud Functions logs
3. Contact development team

## 📄 License

This payment system is part of the Growi e-commerce application.
