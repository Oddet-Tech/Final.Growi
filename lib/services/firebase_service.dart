import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growi_project/appscreen/models.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String ordersCollection = 'orders';
  static const String usersCollection = 'users';
  static const String emailLogsCollection = 'emailLogs';

  // ===== ORDER OPERATIONS =====

  /// Create a new order
  static Future<String> createOrder(Order order) async {
    try {
      final docRef = await _firestore.collection(ordersCollection).add(order.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get user's orders
  static Future<List<Order>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('orderDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return Order.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  /// Get single order by ID
  static Future<Order?> getOrder(String orderId) async {
    try {
      final doc = await _firestore.collection(ordersCollection).doc(orderId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Order.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  /// Update order status
  static Future<void> updateOrderStatus(
    String orderId,
    String newStatus, {
    String? trackingNumber,
    String? notes,
  }) async {
    try {
      final updateData = {
        'status': newStatus,
        if (newStatus == 'Shipped') 'shippedDate': DateTime.now().toIso8601String(),
        if (newStatus == 'Delivered') 'deliveredDate': DateTime.now().toIso8601String(),
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
        if (notes != null) 'notes': notes,
      };

      await _firestore.collection(ordersCollection).doc(orderId).update(updateData);

      // Send notification email
      final order = await getOrder(orderId);
      if (order != null) {
        await _sendStatusUpdateEmail(order);
      }
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // ===== EMAIL OPERATIONS =====

  /// Send order confirmation email
  static Future<void> sendOrderConfirmationEmail(
    Order order,
    String userEmail,
    String userName,
  ) async {
    try {
      await _firestore.collection('emailQueue').add({
        'type': 'order_confirmation',
        'to': userEmail,
        'userName': userName,
        'orderId': order.id,
        'orderData': order.toMap(),
        'totalItems': order.items.length,
        'finalTotal': order.finalTotal,
        'pickupStore': order.locationInfo.storeName,
        'createdAt': DateTime.now().toIso8601String(),
        'sent': false,
      });

      await _logEmailActivity(
        'order_confirmation',
        userEmail,
        order.id,
        'Queued',
      );
    } catch (e) {
      throw Exception('Failed to queue confirmation email: $e');
    }
  }

  /// Send payment success email
  static Future<void> sendPaymentSuccessEmail(
    Order order,
    String userEmail,
    String userName,
  ) async {
    try {
      await _firestore.collection('emailQueue').add({
        'type': 'payment_success',
        'to': userEmail,
        'userName': userName,
        'orderId': order.id,
        'amount': order.finalTotal,
        'cardLastFour': order.paymentInfo.getMaskedCardNumber(),
        'createdAt': DateTime.now().toIso8601String(),
        'sent': false,
      });

      await _logEmailActivity(
        'payment_success',
        userEmail,
        order.id,
        'Queued',
      );
    } catch (e) {
      throw Exception('Failed to queue payment success email: $e');
    }
  }

  /// Send status update email
  static Future<void> _sendStatusUpdateEmail(Order order) async {
    try {
      final userDoc = await _firestore.collection(usersCollection).doc(order.userId).get();
      final userEmail = userDoc.data()?['email'] ?? '';
      final userName = userDoc.data()?['displayName'] ?? 'Customer';

      if (userEmail.isEmpty) return;

      String emailType = '';
      String subject = '';

      switch (order.status) {
        case 'Shipped':
          emailType = 'order_shipped';
          subject = 'Your Order Has Been Shipped!';
          break;
        case 'Delivered':
          emailType = 'order_delivered';
          subject = 'Your Order Has Been Delivered!';
          break;
        case 'Cancelled':
          emailType = 'order_cancelled';
          subject = 'Your Order Has Been Cancelled';
          break;
        default:
          return;
      }

      await _firestore.collection('emailQueue').add({
        'type': emailType,
        'to': userEmail,
        'userName': userName,
        'orderId': order.id,
        'status': order.status,
        'trackingNumber': order.trackingNumber,
        'pickupStore': order.locationInfo.storeName,
        'subject': subject,
        'createdAt': DateTime.now().toIso8601String(),
        'sent': false,
      });

      await _logEmailActivity(
        emailType,
        userEmail,
        order.id,
        'Queued',
      );
    } catch (e) {
      throw Exception('Failed to queue status update email: $e');
    }
  }

  /// Log email activity for tracking
  static Future<void> _logEmailActivity(
    String emailType,
    String recipient,
    String orderId,
    String status,
  ) async {
    try {
      await _firestore.collection(emailLogsCollection).add({
        'type': emailType,
        'recipient': recipient,
        'orderId': orderId,
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to log email activity: $e');
    }
  }

  // ===== USER OPERATIONS =====

  /// Save or update user email
  static Future<void> saveUserEmail(String userId, String email, String displayName) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).set(
        {
          'email': email,
          'displayName': displayName,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to save user email: $e');
    }
  }

  /// Get user email
  static Future<String?> getUserEmail(String userId) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(userId).get();
      return doc.data()?['email'];
    } catch (e) {
      throw Exception('Failed to get user email: $e');
    }
  }

  // ===== ADMIN OPERATIONS =====

  /// Get all pending orders (for admin)
  static Future<List<Order>> getPendingOrders() async {
    try {
      final snapshot = await _firestore
          .collection(ordersCollection)
          .where('status', isEqualTo: 'Pending')
          .orderBy('orderDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return Order.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch pending orders: $e');
    }
  }

  /// Get orders by status (for admin)
  static Future<List<Order>> getOrdersByStatus(String status) async {
    try {
      final snapshot = await _firestore
          .collection(ordersCollection)
          .where('status', isEqualTo: status)
          .orderBy('orderDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return Order.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders by status: $e');
    }
  }

  /// Get all orders (for admin)
  static Future<List<Order>> getAllOrders() async {
    try {
      final snapshot = await _firestore
          .collection(ordersCollection)
          .orderBy('orderDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return Order.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch all orders: $e');
    }
  }

  /// Stream of orders for real-time updates
  static Stream<List<Order>> streamUserOrders(String userId) {
    return _firestore
        .collection(ordersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return Order.fromMap(data);
      }).toList();
    });
  }

  /// Stream of all orders for admin
  static Stream<List<Order>> streamAllOrders() {
    return _firestore
        .collection(ordersCollection)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return Order.fromMap(data);
      }).toList();
    });
  }
}
