import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:dima_app/provider_samples.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar("Home"),
      body: ListView(
        children: [
          Text(Provider.of<Something>(context).stringa),
          // equivalente a quello sopra
          Text(context.watch<Something>().stringa),
          Text(Provider.of<String>(context)),

          // mutable provider
          // Wrap ONLY the part I want to rebuild in a Consumer of provider type, watch rebuilds everything
          Consumer<CounterProviderSample>(
            builder: (context, providerObj, child) {
              return Text("${providerObj.counter}");
            },
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<CounterProviderSample>(context, listen: false)
                  .incrementCounter();
              // Read inside build should be avoided
              // context.read<CounterProviderSample>().incrementCounter();
            },
            child: const Icon(Icons.add),
          ),

          //Stream provider
          Consumer<int>(
            builder: (context, providerObj, child) {
              return Text("$providerObj");
            },
          ),

          //Future provider
          Consumer<String>(
            builder: (context, providerObj, child) {
              final address = providerObj;
              return Text("$address dsadsa");
            },
          ),

          // long shape
          Center(
            child: Container(
              color: Colors.orange,
              width: 20,
              height: 1000,
            ),
          )
        ],
      ),
    );
  }
}
