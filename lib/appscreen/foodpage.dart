import 'package:flutter/material.dart';
import 'dart:async';

class FoodPage extends StatefulWidget {
	const FoodPage({super.key});

	@override
	State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
	late Timer _scheduleTimer;
	DateTime _currentTime = DateTime.now();

	@override
	void initState() {
		super.initState();
		_scheduleTimer = Timer.periodic(const Duration(seconds: 1), (_) {
			if (mounted) {
				setState(() => _currentTime = DateTime.now());
			}
		});
	}

	@override
	void dispose() {
		_scheduleTimer.cancel();
		super.dispose();
	}

	bool get _isFoodOpen {
		final minutes = _currentTime.hour * 60 + _currentTime.minute;
		final openingTime = 9 * 60;
		final closingTime = _currentTime.weekday == DateTime.saturday
			? 13 * 60
			: 16 * 60;

		return _currentTime.weekday != DateTime.sunday &&
			minutes >= openingTime &&
			minutes < closingTime;
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Food'),
				backgroundColor: const Color(0xFFF8EED2),
			),
			backgroundColor: const Color(0xFFF8EED2),
			body: ListView(
				padding: const EdgeInsets.all(10),
				children: [
					Card(
						child: SizedBox(
							height: 110,
							child: ListTile(
							leading: const Icon(Icons.abc_rounded),
							title: const Text(
								'Boxer',
								style: TextStyle(
									fontWeight: FontWeight.bold,
									color: Colors.black,
								),
							),
							subtitle: Text(
								_isFoodOpen ? 'Open' : 'Closed',
								style: TextStyle(
									color: _isFoodOpen ? Colors.green : Colors.red,
									fontWeight: FontWeight.w600,
								),
							),
							onTap: _isFoodOpen ? () {} : null,
							),
						),
					),
          	Card(
						child: SizedBox(
							height: 110,
							child: ListTile(
							leading: const Icon(Icons.abc_rounded),
							title: const Text(
								'OBC',
								style: TextStyle(
									fontWeight: FontWeight.bold,
									color: Colors.black,
								),
							),
							subtitle: Text(
								_isFoodOpen ? 'Open' : 'Closed',
								style: TextStyle(
									color: _isFoodOpen ? Colors.green : Colors.red,
									fontWeight: FontWeight.w600,
								),
							),
							onTap: _isFoodOpen ? () {} : null,
							),
						),
					),
          Card(
						child: SizedBox(
							height: 110,
							child: ListTile(
							leading: const Icon(Icons.abc_rounded),
							title: const Text(
								'Shoprite',
								style: TextStyle(
									fontWeight: FontWeight.bold,
									color: Colors.black,
								),
							),
							subtitle: Text(
								_isFoodOpen ? 'Open' : 'Closed',
								style: TextStyle(
									color: _isFoodOpen ? Colors.green : Colors.red,
									fontWeight: FontWeight.w600,
								),
							),
							onTap: _isFoodOpen ? () {} : null,
							),
						),
					),
				],
			),
		);
	}
}


