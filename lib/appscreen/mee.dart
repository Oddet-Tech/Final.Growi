import 'package:flutter/material.dart';

/// 🔥 EVENT APPLICATIONS
List<Map<String, dynamic>> globalEventApplications = [];

/// 🔥 APPROVED EVENTS (SHOW IN TICKET PAGE)
List<Map<String, dynamic>> approvedEvents = [];

class Mee extends StatefulWidget {
  const Mee({super.key});

  @override
  State<Mee> createState() => _MeeState();
}

class _MeeState extends State<Mee> {

  /// 🔥 ACCEPT APPLICATION
  void acceptApplication(Map<String, dynamic> application) {

    /// UPDATE STATUS
    application['status'] = 'Accepted';

    /// ADD TO TICKET PAGE
    approvedEvents.add(application);

    /// SEND EMAIL
    sendEmail(
      application['email'],
      'Event Approved',
      'Congratulations! Your event "${application['eventName']}" has been approved and is now listed.',
    );

    setState(() {});
  }

  /// 🔥 REJECT APPLICATION
  void rejectApplication(Map<String, dynamic> application) {

    /// UPDATE STATUS
    application['status'] = 'Rejected';

    /// SEND EMAIL
    sendEmail(
      application['email'],
      'Event Rejected',
      'We are sorry. Your event "${application['eventName']}" was rejected.',
    );

    setState(() {});
  }

  /// 🔥 EMAIL FUNCTION
  void sendEmail(
    String email,
    String subject,
    String message,
  ) {

    /// LATER CONNECT FIREBASE / EMAIL API

    debugPrint('EMAIL SENT');
    debugPrint('To: $email');
    debugPrint('Subject: $subject');
    debugPrint('Message: $message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Applications Dashboard'),
      ),

      body: globalEventApplications.isEmpty
          ? const Center(
              child: Text(
                'No Applications Yet',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: globalEventApplications.length,
              itemBuilder: (context, index) {

                final application =
                    globalEventApplications[index];

                final String eventName =
                    application['eventName'];

                final String organizer =
                    application['organizer'];

                final String email =
                    application['email'];

                final String location =
                    application['location'];

                final String description =
                    application['description'];

                final String status =
                    application['status'] ?? 'Pending';

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 4,

                  child: ExpansionTile(

                    leading: const Icon(
                      Icons.event,
                      color: Colors.blue,
                    ),

                    title: Text(
                      eventName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      'Organizer: $organizer',
                    ),

                    children: [

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            /// EVENT DETAILS
                            Text(
                              'Email: $email',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'Location: $location',
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'Description:',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(description),

                            const SizedBox(height: 20),

                            /// STATUS
                            Row(
                              children: [

                                const Text(
                                  'Status: ',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                Text(
                                  status,
                                  style: TextStyle(
                                    color: status ==
                                            'Accepted'
                                        ? Colors.green
                                        : status ==
                                                'Rejected'
                                            ? Colors.red
                                            : Colors.orange,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            /// ACTION BUTTONS
                            if (status == 'Pending')
                              Row(
                                children: [

                                  Expanded(
                                    child: ElevatedButton(
                                      style:
                                          ElevatedButton
                                              .styleFrom(
                                        backgroundColor:
                                            Colors.green,
                                      ),

                                      onPressed: () {
                                        acceptApplication(
                                            application);
                                      },

                                      child: const Text(
                                        'Accept',
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: ElevatedButton(
                                      style:
                                          ElevatedButton
                                              .styleFrom(
                                        backgroundColor:
                                            Colors.red,
                                      ),

                                      onPressed: () {
                                        rejectApplication(
                                            application);
                                      },

                                      child: const Text(
                                        'Reject',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}