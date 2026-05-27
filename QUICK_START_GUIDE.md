# Quick Start Guide - Payment System Integration

## 🚀 5-Minute Setup

### Step 1: Update pubspec.yaml
The required dependencies are already in your project:
```yaml
dependencies:
  geolocator: ^14.0.2
  firebase_core: ^4.9.0
  firebase_auth: ^6.5.1
  cloud_firestore: ^6.4.1
```

Run: `flutter pub get`

### Step 2: Import Payment Page
In your cart/checkout screen:
```dart
import 'package:growi_project/appscreen/payment.dart';

// Navigate to payment
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => PaymentPage(
      cartItems: cartItems,
      totalPrice: totalPrice,
      pickupLocation: selectedLocation,
      themeColor: Colors.blue,
    ),
  ),
);
```

### Step 3: Add Admin Orders Screen
In your admin panel:
```dart
import 'package:growi_project/appscreen/admin_orders.dart';

// Navigate to admin orders
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const AdminOrderManagement()),
);
```

### Step 4: Update User Dashboard
Already integrated in userdashbord.dart - users see their orders automatically after login.

### Step 5: Deploy Cloud Functions
```bash
cd functions
npm install
firebase deploy --only functions
```

## 📧 Email Configuration

### Gmail Setup (Free)
1. Go to https://myaccount.google.com/security
2. Enable 2-Step Verification
3. Go to https://myaccount.google.com/apppasswords
4. Select Mail → Windows Computer
5. Copy the 16-character password
6. Add to `functions/.env`:
```
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
EMAIL_FROM=noreply@growi.app
```

### SendGrid Setup (Better for Production)
1. Create account at https://sendgrid.com
2. Create API key
3. Add to `functions/.env`:
```
EMAIL_SERVICE=SendGrid
SENDGRID_API_KEY=your-sendgrid-key
EMAIL_FROM=noreply@growi.app
```

## 🔧 Firestore Security Rules

Set these rules in Firebase Console → Firestore → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Orders - users can only read/write their own
    match /orders/{orderId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.uid == request.resource.data.userId;
      allow update: if request.auth.uid == resource.data.userId || isAdmin();
    }
    
    // Users - own data only
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
    }
    
    // Admin only collections
    match /emailQueue/{document=**} {
      allow read, write: if isAdmin();
    }
    
    match /emailLogs/{document=**} {
      allow read: if isAdmin();
    }
  }
  
  function isAdmin() {
    return request.auth.token.admin == true;
  }
}
```

## ✅ Verification Checklist

- [ ] Dependencies installed (`flutter pub get`)
- [ ] Firebase project created
- [ ] Firestore database created
- [ ] Collections created (orders, users, emailQueue, emailLogs)
- [ ] Security rules deployed
- [ ] Cloud Functions deployed
- [ ] Email service configured (.env file)
- [ ] Location permission in AndroidManifest.xml
- [ ] Location permission in Info.plist (iOS)
- [ ] Admin user has admin claim in Firebase

## 📱 Location Permissions

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby pickup stores</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to show nearby pickup stores</string>
```

## 🧪 Test the Flow

### Test Order Creation
1. Create a test user account
2. Add items to cart
3. Go to checkout
4. Verify location appears
5. Select store
6. Enter test card details:
   - Card: 4111111111111111
   - Expiry: 12/25
   - CVV: 123
7. Submit payment
8. Check Firestore → orders collection
9. Verify order document created

### Test Email Sending
1. Verify `emailQueue` collection created
2. Check if email documents appear after order
3. In Firebase Console, run: `firebase functions:log`
4. Should see email sending activity
5. Check recipient email inbox

### Test Admin Updates
1. Open Admin Order Management
2. Find a Pending order
3. Click to expand
4. Click "Mark as Shipped"
5. Add tracking number (optional)
6. Verify:
   - Order status changes to "Shipped"
   - New email in queue
   - Customer receives email

## 🔍 Debugging

### Check if emails are queuing
```bash
firebase firestore:backup gs://your-project/backups
# Or view in console
```

### Check Cloud Functions logs
```bash
firebase functions:log
```

### Test Cloud Functions locally
```bash
firebase emulators:start --only functions
```

### View email queue status
```bash
firestore_emulator_port=8080 firebase emulators:start
```

## 📊 Order Status Lifecycle

```
User Creates Order
        ↓
Status: PENDING → Confirmation + Payment emails sent
        ↓
Admin marks as SHIPPED → Shipped email sent (with tracking)
        ↓
Admin marks as DELIVERED → Delivered email sent
        ↓
[Complete] → User can leave feedback/review
```

## 💡 Advanced Usage

### Get specific user's orders programmatically
```dart
final userOrders = await FirebaseService.getUserOrders(userId);
for (var order in userOrders) {
  print('Order ${order.id}: ${order.status}');
}
```

### Listen to real-time updates
```dart
FirebaseService.streamUserOrders(userId).listen((orders) {
  // Update UI with latest orders
});
```

### Update order status (Admin)
```dart
await FirebaseService.updateOrderStatus(
  orderId,
  'Shipped',
  trackingNumber: 'TRK123456',
  notes: 'Order shipped successfully',
);
```

### Send custom email
```dart
await FirebaseService.sendOrderConfirmationEmail(
  order,
  userEmail,
  userName,
);
```

## 🚨 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Emails not sending | Check .env file, restart Cloud Functions |
| Location not working | Check permissions, ensure GPS enabled |
| Orders not appearing | Verify Firestore rules, check user auth |
| Admin can't update orders | Add admin claim to user in Firebase Console |
| Long email delays | Reduce Cloud Functions schedule (functions/index.js line 16) |

## 📞 Support Resources

- [Firebase Firestore Docs](https://firebase.google.com/docs/firestore)
- [Cloud Functions Docs](https://firebase.google.com/docs/functions)
- [Flutter Firebase Docs](https://firebase.flutter.dev/)
- [Geolocator Package](https://pub.dev/packages/geolocator)

## 🎯 Production Checklist

- [ ] Enable Firebase backup
- [ ] Set up monitoring/alerts
- [ ] Test email template rendering in multiple clients
- [ ] Configure email rate limits
- [ ] Set up audit logging
- [ ] Enable Firestore export
- [ ] Test failover procedures
- [ ] Document support procedures
- [ ] Set up customer support tickets
- [ ] Monitor Cloud Functions costs

---

**Version**: 1.0.0  
**Last Updated**: May 2024  
**Status**: Ready for Production
