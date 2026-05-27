import 'package:flutter/material.dart';

/// 🔥 APPROVED EVENTS FROM MEE
List<Map<String, dynamic>> approvedEvents = [];

class Ticket extends StatefulWidget {
  const Ticket({super.key});

  @override
  State<Ticket> createState() => _TicketState();
}

class _TicketState extends State<Ticket> {

  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';

  @override
  Widget build(BuildContext context) {

    /// 🔥 FILTER APPROVED EVENTS
    final filteredEvents = approvedEvents.where((event) {

      final eventName =
          event['eventName']
              .toString()
              .toLowerCase();

      return eventName.contains(
        searchText.toLowerCase(),
      );

    }).toList();

    return Scaffold(

      backgroundColor: Colors.white,

      /// 🔥 APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Events',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [

          /// 🔥 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(10),

            child: TextField(

              controller: searchController,

              onChanged: (value) {

                setState(() {
                  searchText = value;
                });
              },

              decoration: InputDecoration(

                hintText: 'Search events...',

                prefixIcon:
                    const Icon(Icons.search),

                filled: true,

                fillColor: Colors.grey.shade200,

                contentPadding:
                    const EdgeInsets.symmetric(
                  vertical: 0,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),

                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// 🔥 EVENT LIST
          Expanded(

            child: approvedEvents.isEmpty

                /// 🔥 WAITING FOR APPROVAL
                ? const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        Icon(
                          Icons.hourglass_empty,
                          size: 80,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 20),

                        Text(
                          'No Approved Events Yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          'Waiting for approval from Mee',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )

                /// 🔥 SEARCH RESULT NOT FOUND
                : filteredEvents.isEmpty

                    ? const Center(
                        child: Text(
                          'Event not found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      )

                    /// 🔥 SHOW APPROVED EVENTS
                    : ListView.builder(

                        padding:
                            const EdgeInsets.all(10),

                        itemCount:
                            filteredEvents.length,

                        itemBuilder:
                            (context, index) {

                          final event =
                              filteredEvents[index];

                          return Card(

                            margin:
                                const EdgeInsets.only(
                              bottom: 15,
                            ),

                            elevation: 4,

                            child: Container(

                              height: 170,

                              decoration:
                                  BoxDecoration(

                                borderRadius:
                                    BorderRadius
                                        .circular(12),

                                image:
                                    const DecorationImage(
                                  image: AssetImage(
                                    'assets/ticket.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),

                              child: Padding(
                                padding:
                                    const EdgeInsets.all(
                                  16,
                                ),

                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    const Row(
                                      children: [

                                        Icon(
                                          Icons
                                              .confirmation_number_outlined,
                                          color:
                                              Colors.white,
                                          size: 28,
                                        ),

                                        SizedBox(
                                            width: 8),

                                        Text(
                                          'Approved Event',
                                          style:
                                              TextStyle(
                                            color: Colors
                                                .white,
                                            fontSize:
                                                22,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const Spacer(),

                                    Text(
                                      event['eventName'],
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white,
                                        fontSize: 20,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),

                                    const SizedBox(
                                        height: 5),

                                    Text(
                                      event['location'],
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}